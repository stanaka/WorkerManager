#! /usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');
use lib File::Spec->catdir($FindBin::Bin, '..', '..', 'lib');

use WorkerManager::Client::TheSchwartz;
use Time::Piece;

my $client = WorkerManager::Client::TheSchwartz->new();

$client->insert('Sandbox::Worker::A' => +{foo => localtime->epoch});

$client->insert('Sandbox::Worker::B' => +{foo => localtime->epoch}, {run_after => time, priority => 1});
$client->insert('Sandbox::Worker::B' => +{foo => localtime->epoch}, {run_after => time + 30});
$client->insert('Sandbox::Worker::B' => +{foo => localtime->epoch}, {run_after => time + 60});
