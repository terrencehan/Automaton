# lib/State.pm
# Copyright (c) 2012 terrencehan
# hanliang1990@gmail.com

package State;

use 5.014002;

use Moose;

has info => (
    is  => 'rw',
    isa => 'Str',
);

has [ 'num', 'is_acc' ] => (
    is      => 'rw',
    isa     => 'Num',
    default => 0, #for 'is_acc'
);

has out_transition => (
    is      => 'rw',
    isa     => 'HashRef[Item]',
    default => sub { {} },
);

sub add_out_transition {
    my ( $self, $label, $to ) = @_;
    my $hash = $self->out_transition;
    $hash->{$label} ||= [];
    push $hash->{$label}, $to;
    $self->out_transition($hash);
}

sub out_degree {
    my $self  = shift;
    my $count = 0;
    $count += scalar @{ $self->out_transition->{$_} }
      for ( keys $self->out_transition );

    $count;
}

sub search_out_label {

    #return the number of out-transitions with given label
    my ( $self, $label ) = @_;
    my $hash = $self->out_transition;
    return scalar @{ $hash->{$label} || [] };
}

sub delete_transition {

    #delete all out-transitions labeled by $label
    my ( $self, $label ) = @_;
    my $hash = $self->out_transition;
    delete $hash->{$label};
    $self->out_transition($hash);
}

sub empty_transition {
    my $self = shift;
    $self->out_transition( {} );
}

1;
