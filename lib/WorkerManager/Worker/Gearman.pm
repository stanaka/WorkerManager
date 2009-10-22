package WorkerManager::Worker::Gearman;
use strict;
use warnings;
use Gearman::Worker;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(
    worker
    job_servers
    prefix
 ));

sub new {
    my ($class, $arg) = @_;
    my $self = $class->SUPER::new($arg);
       $self->worker(Gearman::Worker->new(
           job_servers => $self->job_servers || [qw(127.0.0.1)],
           prefix      => $self->prefix      || '',
       ));
       $self->init if $self->can('init');
       $self;
}

sub work { die 'work() method should be implemented by subclass' }

1;
