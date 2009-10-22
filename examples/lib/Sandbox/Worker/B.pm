package Sandbox::Worker::B;
use strict;
use warnings;
use base qw( TheSchwartz::Worker );
use TheSchwartz::Job;
use Time::HiRes qw( usleep);

sub work {
    my $class = shift;
    my TheSchwartz::Job $job = shift;

    usleep(100 * 1000);
    print "Processing 'B' arg foo:".$job->arg->{foo}."\n";

    $job->completed();
}

1;
