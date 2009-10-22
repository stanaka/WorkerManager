package WorkerManager::Client::Gearman::Async;
use strict;
use warnings;
use base qw(WorkerManager::Client::Gearman);

__PACKAGE__->client_class('Gearman::Client');

sub insert {
    my $self = shift;
    my $task = $self->_get_task_from_args(@_);
    $self->client->dispatch_background($task);
}

1;
