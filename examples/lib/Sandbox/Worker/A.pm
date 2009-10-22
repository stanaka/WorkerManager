package Sandbox::Worker::A;
use strict;
use warnings;
use base qw( TheSchwartz::Worker );
use TheSchwartz::Job;

sub work {
    my $class = shift;
    my TheSchwartz::Job $job = shift;


    my $try = int(rand(10));
    if($try > 5){
        print "Processed 'A' ".$job->arg->{foo}."\n";
        $job->completed();
    } else {
        print "Failed 'A' ".$job->arg->{foo}."\n";
        $job->failed("Failed 'A' ".$job->arg->{foo});
    }
}

sub max_retries { 3 }
sub retry_delay { 20 }


1;
