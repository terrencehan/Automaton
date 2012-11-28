package State;

use 5.014002;

use Moose;

has info => (
    is  => 'rw',
    isa => 'Str',
);

has [ 'in_transition', 'out_transition' ] => (
    is  => 'rw',
    isa => 'HashRef[Defined]',
);

sub _add_transition {
    my ( $self, $label, $target, $type ) = @_;
    if ( $type eq 'in' ) {
        my $hash = $self->in_transition;
        $hash->{$label} ||= [];
        push $hash->{$label}, $target;
        $self->in_transition($hash);
    }
    else {    #out
        my $hash = $self->out_transition;
    }
}

sub add_out_transition {
    my ( $self, $label, $to ) = @_;
    $self->_add_transition( $label, $to, 'out' );
}

sub add_in_transition {
    my ( $self, $label, $from ) = @_;
    $self->_add_transition( $label, $from, 'in' );
}

sub _search_label{}
sub search_out_label{ }
sub search_in_label{ }

1;
