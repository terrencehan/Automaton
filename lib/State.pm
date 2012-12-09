# lib/State.pm
# Copyright (c) 2012 terrencehan
# hanliang1990@gmail.com

package State;

use 5.014002;
use overload '~~' => 'match';

use Moose;

has info => (
    is  => 'rw',
    isa => 'Str',
);

has num => (    #corresponds to automaton_object->states
    is  => 'rw',
    isa => 'Num',
);

has 'label' => (
    is      => 'rw',
    isa     => 'Item',
    default => 0,
);

has 'is_acc' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,

);

has out_transition => (
    is      => 'rw',
    isa     => 'HashRef[Item]',
    default => sub { {} },
);

has action => (
    is      => 'rw',
    isa     => 'CodeRef',
    default => sub {
        sub { say "no action"; }
    },
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

sub match {

    #return 1 if $obj ~~ $same_obj or $obj ~~ @list_contains_the_obj
    #return 0 if $obj ~~ $other_obj
    #return '' if $obj ~~ @list_not_contains_the_obj
    my ( $self, $compared ) = @_;
    $self->label ~~ $compared->label ? 1 : 0;
}

1;
