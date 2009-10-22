package WorkerManager::Client::Gearman::Sync;
use strict;
use warnings;
use Danga::Socket;
use base qw(WorkerManager::Client::Gearman);

__PACKAGE__->client_class('Gearman::Client::Async');

sub insert {
    my $self = shift;
    my $task = $self->_get_task_from_args(@_);
    $self->client->add_task($task);
    Danga::Socket->SetPostLoopCallback( sub { !$task->is_finished } );
    Danga::Socket->SetLoopTimeout(($task->{timeout} || 1) * 1000);
    Danga::Socket->EventLoop;
}

1;
