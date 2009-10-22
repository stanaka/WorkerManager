#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use Proc::Daemon;
use File::Pid;
use YAML::Syck;

#use Data::Dumper qw(Dumper);

use FindBin;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');
use WorkerManager;

sub usage {
    print << "EOF";

 usage: $0 [-hdn] [-c concurrency] [-w works_per_child] -f conf_file

        -h   : this (help) message
        -d   : debug
        -n   : prevent deamonize (non fork)
        -c   : the number of concurrency (default 4).
        -w   : the number of works per child process (default 100).
        -f   : YAML-formated file of configuration

EOF
;
    exit;
}

my %opt;
my $DEBUG;
my $DAEMON;
my $PIDFILE;
my $LOGFILE;
my $ERRORLOGFILE;
my $MAX_PROCESSES;
my $CONF;
my $WORKS_PER_CHILD;
my %CHILD_PIDS;

sub init {
    $DEBUG = 0;
    $DAEMON = 1;
    $PIDFILE = "/var/run/workermanager.pid";
    $LOGFILE = "/var/log/workermanager.log";
    $ERRORLOGFILE = "/var/log/workermanager_error.log";
    $MAX_PROCESSES = 4;
    $WORKS_PER_CHILD = 100;
    my %opt;
    getopts("hndc:w:f:", \%opt);
    usage() if $opt{h};
    return %opt;
}

BEGIN {
    %opt = init;
    $MAX_PROCESSES = $opt{c} if($opt{c});
    $WORKS_PER_CHILD = $opt{w} if($opt{w});
    if($opt{f}){
        $CONF = LoadFile$opt{f} or die $@;
        for (@{$CONF->{inc_path}}){
            unshift @INC, m{^/} ? $_ : File::Spec->catdir($FindBin::Bin, '..', split('/', $_));
        }
        $PIDFILE = $CONF->{pidfile} !~ /^\// ? File::Spec->catdir($FindBin::Bin, '..', $CONF->{pidfile}) : $CONF->{pidfile} if $CONF->{pidfile};
        $LOGFILE = $CONF->{logfile} !~ /^\// ? File::Spec->catdir($FindBin::Bin, '..', $CONF->{logfile}) : $CONF->{logfile} if $CONF->{logfile};
        $ERRORLOGFILE = $CONF->{errorlogfile} !~ /^\// ? File::Spec->catdir($FindBin::Bin, '..', $CONF->{errorlogfile}) : $CONF->{errorlogfile} if $CONF->{errorlogfile};
    } else {
        usage();
    }
    $DEBUG = 1 if($opt{d});
    $DAEMON = 0 if($opt{n});
}

my $pid;
sub daemonize {
    #my $self = shift;
    #return unless $self->config->{daemon};

    if ($PIDFILE) {
        $pid = File::Pid->new({file => $PIDFILE}) or die "Failed to create new File::Pid\n";
        if( $pid->running ){
            die 'The PID in '.$PIDFILE.' is still running.';
        } else {
            if( -e $PIDFILE){
                warn 'The pid file '.$PIDFILE.' is still exist. Try to remove it.';
                $pid->remove
                    or die "Failed to remove the pid file.";
            }
        }
    }

    Proc::Daemon::Init;

    if($PIDFILE){
        $pid = File::Pid->new({file => $PIDFILE, pid => $$});
        if( -e $PIDFILE){
            $pid->remove
                or die "Failed to remove the pid file.";
        }
        $pid->write or die "Failed to write the pid file.";
    }
}

if($DAEMON) {
    daemonize or die "Failed to daemonized $@\n";
}

my $wm = WorkerManager->new(
    max_processes => $MAX_PROCESSES,
    works_per_child => $WORKS_PER_CHILD,
    type => $CONF->{type} || 'TheSchwartz',
    worker_options => $CONF->{worker_options} || {},
    worker => $CONF->{workers},
    error_log_file => $DAEMON ? $ERRORLOGFILE : undef,
    log_file => $DAEMON ? $LOGFILE : undef,
    ridge_env => $CONF->{ridge_env} || '',
    env => $CONF->{env} || {},
);

$wm->main();
$pid->remove if $pid;

END {
    $wm->killall_children() if !$DAEMON && exists $wm->{pids};
}
