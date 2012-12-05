# lib/Automaton.pm
# Copyright (c) 2012 terrencehan
# hanliang1990@gmail.com

package Automaton;

use 5.014002;

use Moose;
use State;
use GraphViz;
use Text::Table;
use List::Compare;

has 'states' => (
    is      => 'rw',
    isa     => 'ArrayRef[State]',
    default => sub { [] },
);

has 'first_state' => (
    is  => 'rw',
    isa => 'State',
);

has 'symbols' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
);

sub BUILD {
    my ( $self, $args ) = @_;

    #args->{
    #   state1=>{  #state1 here means the label of state
    #           out_transition=>{
    #                 symbol1=>target_state1,
    #                 symbol2=>target_state2,
    #           },
    #           is_acc => 1,
    #   },
    #}

    #use Data::Dump qw/dump/;
    #dump $args;

    my $count   = 0;    #index of obj->states
    my $states  = [];
    my $symbols = [];
    for my $state ( keys %{$args} ) {    #$state stands for label
        $states->[$count] ||= new State( label => $state, num => $count, is_acc => $args->{$state}{is_acc} );
        for my $symbol ( keys %{ $args->{$state}{out_transition} } ) {
            $states->[$count]
              ->add_out_transition( $symbol, $args->{$state}{out_transition}{$symbol} );
            push $symbols, $symbol unless $symbol ~~ $symbols;
        }
        $count++;
    }
    $self->states($states);
    $self->symbols($symbols);
}

sub read_file {

    #state label consists of letters and numbers
    my ( $self, $file_path ) = @_;
    open my $in, "<", $file_path or die "cannot open the transition table file";

    #get symbols
    my $first_line = <$in>;
    my @symbols = split /\s+/, $first_line;
    shift @symbols;    #remove 'state'
    $self->symbols( \@symbols );

    #deal with each line from the 2nd line
    my $state_index = 0;
    while (<$in>) {
        my $count = 0;
        my ($label) = $_ =~ /^\s*(.*?)\s+/;
        my $states = $self->states;
        $states->[$state_index] ||=
          new State( label => $label, num => $state_index );
        $states->[$state_index]->is_acc(1) if /acc/i;
        $self->first_state( $states->[$state_index] ) if /entry/i;

        while (/{.*?}|#/g) {
            my $entry = $&;
            while ( $entry =~ /[\d\w]+/g ) {
                $states->[$state_index]
                  ->add_out_transition( $symbols[$count], $& );
            }
            $count++;
        }

        $self->states($states);
        $state_index++;
    }
}

sub as_png {
    my $self = shift;
    my $g = new GraphViz( rankdir => 'LR' );

    for ( @{ $self->states } ) {
        my $shape = '';
        $shape = 'doublecircle' if $_->is_acc;
        $g->add_node( $_->label, shape => $shape );
    }

    $g->add_node(    #start
        '-1',
        label  => '',
        shape  => 'plaintext',
        width  => 0,
        height => 0
    );
    $g->add_edge( -1 => $self->first_state->label, label => 'start' );

    for my $state ( @{ $self->states } ) {
        for my $label ( keys %{ $state->out_transition } ) {
            for my $to ( @{ $state->out_transition->{$label} } ) {
                $g->add_edge( $state->label => $to, label => $label );
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

sub _state_list_ref2str {
    my ( $self, $state_list_ref ) = @_;
    "{" . ( join ", ", map { $_->label } @{$state_list_ref} ) . "}";
}

sub _str2state_list_ref {
    my ( $self, $str ) = @_;
    $str =~ s/{|}|\s//g;
    my @collection;
    for ( split /,/, $str ) {
        my $state = $self->states->[$_];
        die 'in _str2state_list_ref $state is null' unless defined $state;
        push @collection, $state;
    }
    \@collection;
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
    my ( @Dstates, @marked );    # ("{1, 2, 3}", "{3, 5}")
    my %Dtran;
    push @Dstates,
      $self->_state_list_ref2str(
        $self->epsilon_closure_s( $self->first_state ) );
    my $first_state_rep = $Dstates[0];
    while ( scalar @Dstates ) {    #all states in Dstates are unmarked
        my $T = pop @Dstates;      #T : Str -> "{1, 2, 3}"
        push @marked, $T;
        for my $symbol ( grep { $_ ne 'epsilon' } @{ $self->symbols } ) {
            my $U = $self->_state_list_ref2str(
                $self->epsilon_closure_t(
                    $self->move( $self->_str2state_list_ref($T), $symbol )
                )
            );
            if ( $U ne '{}' ) {
                unless ( $U ~~ @Dstates or $U ~~ @marked ) {
                    push @Dstates, $U;
                }
                $Dtran{$T}{out_transition}{$symbol} = $U;
            }
        }
    }

    #use [A-Z] to label states of DFA
    my $count = 'A';
    my %map;
    my @accs_labels =
      map { $_->label }
      @{ $self->get_accs };    #get labels of all acceptable states
    $map{$_} = $count++ for ( keys %Dtran );
    for my $map_key ( keys %map ) {
        $Dtran{ $map{$map_key} } = $Dtran{$map_key};
        for ( keys %{ $Dtran{$map_key}{out_transition} } ) {
            $Dtran{ $map{$map_key} }->{out_transition}{$_} = $map{ $Dtran{$map_key}{out_transition}{$_}} ;
        }

        no warnings;
        my @cmp = %{eval $map_key};
        use warnings;
        my $lc = List::Compare->new(\@cmp, \@accs_labels);
        $Dtran{ $map{$map_key}}->{is_acc} = 1 if $lc->get_intersection;

        delete $Dtran{$map_key};
    }

    my $new = new Automaton( \%Dtran );
    $self->states( $new->states );
    $self->symbols( $new->symbols );

    $first_state_rep = $map{$first_state_rep};
    my ($new_first_state) =
      grep { $_->label eq $first_state_rep } @{ $new->states };
    $self->first_state($new_first_state);
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

    @reachable = sort { $a->label <=> $b->label } @reachable;
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
    @collection = sort { $a->label <=> $b->label } @collection;
    \@collection;
}

sub move {

    #return a set of NFA to which there is a transition
    #on input symbol a from some state s in T.
    my ( $self, $T, $symbol ) = @_;    # T : ArrayRef
    my @collection = ();
    for my $state ( @{$T} ) {
        for ( @{ $state->out_transition->{$symbol} } ) {
            push @collection, $self->states->[$_];
        }
    }
    @collection = sort { $a->label <=> $b->label } @collection;
    \@collection;
}

sub as_table {
    my $self = shift;
    my $t = new Text::Table( 'state', @{ $self->symbols } );
    my @collection;
    for my $state ( @{ $self->states } ) {
        my $acc = [];
        push $acc, $state->label;
        for ( @{ $self->symbols } ) {
            if ( defined $state->out_transition->{$_} ) {
                push $acc, "{ "
                  . ( join ', ', @{ $state->out_transition->{$_} } ) . " }";
            }
            else {
                push $acc, '#';
            }
        }
        push @collection, $acc;
    }

    $t->load(@collection);
    $t;
}

sub get_accs {
    my $self = shift;
    my @acc = grep { $_->is_acc } @{ $self->states };
    \@acc;
}

sub min_dfa { }

1;
