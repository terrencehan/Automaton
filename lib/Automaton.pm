# lib/Automaton.pm
# Copyright (c) 2012 terrencehan
# hanliang1990@gmail.com

package Automaton;

use 5.014002;

use Moose;
use State;
use GraphViz;
use Text::Table;

has 'states' => (
    is      => 'rw',
    isa     => 'ArrayRef[State]',
    default => sub { [] },
);

sub read_file {
    my ( $self, $file_path ) = @_;
    open my $in, "<", $file_path or die "cannot open the transition table file";

    #get symbols
    my $first_line = <$in>;
    my @symbols = split /\s+/, $first_line;
    shift @symbols;    #remove 'state'

    #deal with each line from the 2nd line
    while (<$in>) {
        my $count = 0;
        my ($state_index) = $_ =~ /(\d+)/;
        my $states = $self->states;
        $states->[$state_index] ||= new State( num => $state_index );
        while (/{.*?}|#/g) {
            my $entry = $&;
            while ( $entry =~ /\d+/g ) {
                $states->[$state_index]
                  ->add_out_transition( $symbols[$count], $& );
            }
            $count++;
        }

        $self->states($states);
    }
}

sub as_png {
    my $self = shift;
    my $g = new GraphViz( rankdir => 'LR' );

    $g->add_node( $_->num ) for ( @{ $self->states } );

    for my $state ( @{ $self->states } ) {
        for my $label ( keys %{ $state->out_transition } ) {
            for my $to ( @{ $state->out_transition->{$label} } ) {
                $g->add_edge( $state->num => $to, label => $label );
            }
        }
    }

    $g->as_png;
}

sub get_states_num {
    my $self = shift;
    scalar( @{ $self->states } );
}

sub is_empty {
    my $self = shift;
    $self->get_states_num ? 0 : 1;
}

sub is_dfa {
    my $self = shift;
    for my $state ( @{ $self->states } ) {
        for my $label ( keys %{ $state->out_transition } ) {
            return 0 if scalar( @{ $state->out_transition->{$label} } ) > 1;
        }
    }

    1;
}

sub is_nfa {
    my $self = shift;
    $self->is_dfa ? 0 : 1;
}

sub to_dfa   {
    my $self = shift;
    return if $self->is_dfa;
}
sub min_dfa  { }
sub as_table { }

1;
