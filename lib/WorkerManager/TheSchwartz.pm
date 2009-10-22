package WorkerManager::TheSchwartz;
use strict;
use warnings;

use TheSchwartz;
use Time::Piece;
use UNIVERSAL::require;
use Time::HiRes qw( time );
use POSIX qw(getppid);

sub new {
    my ($class, $worker, $options) = @_;
    $options ||= {};

    my $databases;
    if ($databases = delete $options->{databases}) {
        $databases = [$databases] unless UNIVERSAL::isa($databases, 'ARRAY');
    } else {
        $databases =  [+{ dsn => 'dbi:mysql:dbname=theschwartz;host=127.0.0.1', user => 'nobody', pass => 'nobody' }];
    }
    my $client = TheSchwartz->new( databases => $databases, %$options);

    my $self = bless {
        client => $client,
        worker => $worker,
        terminate => undef,
        start_time => undef,
    }, $class;
    $self->init;
    $self;
}

sub init {
    my $self = shift;
    $self->{client}->set_verbose(
        sub {
            my $msg = shift;
            my $job = shift;
            # $WorkerManager::LOGGER->('TheSchwartz', $msg) if($msg =~ /Working/);
            if($msg =~ /Working/){
                $self->{start_time} = time;
            }
            return if($msg =~ /found no jobs/);
            if($msg =~ /^job completed|^job failed/){
                $msg .= sprintf " %s", $job->funcname;
                $msg .= sprintf " process:%d", (time - $self->{start_time}) * 1000 if($self->{start_time});
                $msg .= sprintf " delay:%d", ($self->{start_time} - $job->insert_time) * 1000 if($job && $self->{start_time});
                $self->{start_time} = undef;
            };
            $WorkerManager::LOGGER->('TheSchwartz', $msg) unless($msg =~ /found no jobs/);
        });
    if (UNIVERSAL::isa($self->{worker}, 'ARRAY')){
        for (@{$self->{worker}}){
            "$_"->use or warn $@;
            $_->can('work') or die "cannot ${_}->work";
            $self->{client}->can_do($_);
        }
    } else {
        "$self->{worker}"->use or warn $@;
        $_->can('work') or die "cannot ${_}->work";
        $self->{client}->can_do($self->{worker});
    }
}

sub work {
    my $self = shift;
    my $max = shift || 100;
    my $delay = shift || 5;
    my $count = 0;
    while ($count < $max && ! $self->{terminate}) {
        if (getppid == 1) {
            die "my dad may be killed.";
            exit(1);
        }
        if($self->{client}->work_once){
            $count++;
        } else {
            sleep $delay;
        }
    }
}

sub terminate {
    my $self = shift;
    $self->{terminate} = 1;
}

1;
