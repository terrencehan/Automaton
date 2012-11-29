package AutoWalker;

use 5.014002;

use Moose;

has [ 'path', 'avaliable_next_states' ] => (
    is  => 'rw',
    isa => 'ArrayRef[State]',
);

has current_state => (
    is  => 'rw',
    isa => 'State',
);

has automaton => (
    is  => 'rw',
    isa => 'Automaton',
);

sub go_next  { }
sub is_final { }
1;
