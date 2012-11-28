package Automation;

use 5.014002;

use Moose;

has 'states' =>(
    is => 'rw', 
    isa => 'ArrayRef[State]', 
);

sub is_empty { }
sub is_nfa   { }
sub is_dfa   { }
sub to_dfa   { }
sub min_dfa  { }

1;
