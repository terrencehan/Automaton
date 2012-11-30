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
        $states->[$state_index]->is_acc(1) if /\*/;

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

    for ( @{ $self->states } ) {
        my $shape = '';
        $shape = 'doublecircle' if $_->is_acc;
        $g->add_node( $_->num, shape => $shape );
    }

    $g->add_node( #start
        '-1',
        label  => '',
        shape  => 'plaintext',
        width  => 0,
        height => 0
    );
    $g->add_edge( -1 => 0, label => 'start' );

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

sub to_dfa {

    #return a new Automaton object which is the created DFA

#Algorithm:(subset construction)
#   initially, epsilon_closure_s(s0) is the only state in Dstates, and it's unmarked
#   while(there is an unmarked state T in Dstates){
#       mark T;
#       for(each input symbol a){
#           U = epsilon_closure_t(move(T, a));
#           if(U is not in Dstates)
#               add U as an unmarked state to Dstates;
#           Dtran[T, a] = U;
#       }
#   }
    my $self = shift;
    return if $self->is_dfa;
}

sub epsilon_closure_s {

    #return a set of NFA states reachable from NFA state s
    #on epsilon-transition alone.

    #Algorithm:
    #   push s onto stack
    #   while(stack is not empty){
    #       pop ss, the top element off stack
    #       put ss in @reachable
    #       for(each ss's out-transition=>t){
    #           if t is not in @reachable
    #               push t onto stack
    #       }
    my ( $self, $s ) = @_;
    return if $self->is_dfa;

    my ( @stack, @reachable );

    push @stack, $s;
    while ( scalar @stack ) {
        my $ss = pop @stack;
        push @reachable, $ss;
        for my $t ( @{ $ss->out_transition->{epsilon} } ) {
            my $state = $self->states->[$t];
            push @stack, $state unless $state ~~ @reachable;
        }
    }

    \@reachable;    #return
}

sub epsilon_closure_t {

    #return a set of NFA states from some NFA state s in
    #set T on epsilon-transition alone

    #Algorithm:
    #   push all states of T onto stack;
    #   initialize epsilon_closure_t(T) to T;
    #   while(stack is not empty){
    #       pop t, the top element off stack;
    #       for(each state u with an edge from t to u labeled epsilon)
    #           if(u is not in epsilon_closure_t(T)){
    #               add u to epsilon_closure_t(T);
    #               push u onto satck;
    #           }
    #   }

    my ( $self, $T ) = @_;    # T : ArrayRef
    return if $self->is_dfa;

    my ( @stack, @collection );
    for ( @{$T} ) {
        push @stack,      $_;
        push @collection, $_;
    }
    while ( scalar @stack ) {
        my $t = pop @stack;
        for ( @{ $t->out_transition->{epsilon} } ) {
            unless ( $self->states->[$_] ~~ @collection ) {
                push @collection, $self->states->[$_];
                push @stack,      $self->states->[$_];
            }
        }
    }
    \@collection;
}

sub move {

    #return a set of NFA to which there is a transition
    #on input symbol a from some state s in T.
    my ( $self, $T, $symbol ) = @_;    # T : ArrayRef
    my @collection = ();
    for ( @{$T} ) {
        for ( @{ $_->out_transition->{$symbol} } ) {
            push @collection, $self->states->[$_];
        }
    }
    \@collection;
}

sub min_dfa  { }
sub as_table { }

1;
