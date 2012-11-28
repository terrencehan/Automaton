package State;

use 5.014002;

use Moose;

has info => (
    is  => 'rw',
    isa => 'Str',
);

has 'num'=>(
    is  => 'rw',
    isa => 'Num',
);

has 'out_transition' => (
    is  => 'rw',
    isa => 'HashRef[Item]',
);

sub add_out_transition {
    my ( $self, $label, $to ) = @_;
    my $hash = $self->out_transition;
    $hash->{$label} ||= [];
    push $hash->{$label}, $to;
    $self->out_transition($hash);
}

sub out_degree {
    my $self = shift;
    return scalar keys $self->out_transition;
}

sub search_out_label {
    my ( $self, $label ) = @_;
    my $hash = $self->out_transition;
    return scalar @{ $hash->{$label} || [] };
}

sub delete_transition {
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
