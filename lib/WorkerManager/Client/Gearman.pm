package WorkerManager::Client::Gearman;
use strict;
use warnings;
use Carp qw(croak);
use UNIVERSAL::require;
use Gearman::Task;
use base qw(
    Class::Accessor::Fast
    Class::Data::Inheritable
);

__PACKAGE__->mk_accessors(qw(client));
__PACKAGE__->mk_classdata('client_class');

sub new {
    my ($class, $args) = @_;
    $args->{job_servers} ||= [qw(127.0.0.1)];
    $class->client_class->use;
    my $client = $class->client_class->new(job_servers => $args->{job_servers});
    my $self = $class->SUPER::new($args);
    $self->client($client);
    $self;
}

sub _get_task_from_args {
    my $self = shift;
    my Gearman::Task $task;

    if (ref $_[0]) {
        $task = $_[0];
        croak("Argument isn't a Gearman::Task")
            unless ref $_[0] eq "Gearman::Task";
    }
    else {
        my ($func, $arg_p, $opts) = @_;
        my $argref = ref $arg_p ? $arg_p : \$arg_p;
        croak("Function argument must be scalar or scalarref")
            unless ref $argref eq "SCALAR";
        $task = Gearman::Task->new($func, $argref, $opts);
    }

    $task;
}

1;
