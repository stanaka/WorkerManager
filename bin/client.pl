#! /usr/bin/perl

use strict;
use warnings;
use WorkerManager::Client::TheSchwartz;

my $client = WorkerManager::Client::TheSchwartz->new();
$client->insert('Sandbox::Worker::A' => +{foo => "bar"});
