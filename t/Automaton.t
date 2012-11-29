use strict;
use warnings;
use lib '../lib';

use Data::Dump qw/dump/;
use Test::More 'no_plan';
#test 1
BEGIN { use_ok('Automaton') };

my $obj = new Automaton;

#test 2
is $obj->is_empty, 1;

$obj->read_file('transition_table/transition.table');

#test 3
is $obj->is_empty, 0;

my $res = (dump $obj->states)."\n";

my $res_expect =<<END;
[
  bless({ is_acc => 0, num => 0, out_transition => { a => [0, 1], b => [0] } }, "State"),
  bless({ is_acc => 0, num => 1, out_transition => { b => [2] } }, "State"),
  bless({ is_acc => 0, num => 2, out_transition => { b => [3] } }, "State"),
  bless({ is_acc => 1, num => 3, out_transition => {} }, "State"),
]
END
#test 4
is $res, $res_expect;
#test 5
is $obj->is_nfa, 1;
#test 6
is $obj->is_dfa, 0;
