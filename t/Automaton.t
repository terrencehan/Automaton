use strict;
use warnings;
use lib '../lib';

use Data::Dump qw/dump/;
use Test::More 'no_plan';

#test 1
BEGIN { use_ok('Automaton') }

my $obj = new Automaton;

#test 2
is $obj->is_empty, 1;

$obj->read_file('transition_table/transition.table');

#test 3
is $obj->is_empty, 0;

my $res = ( dump $obj->states ) . "\n";

my $res_expect = <<END;
[
  bless({ is_acc => 0, label => 0, out_transition => { a => [0, 1], b => [0] } }, "State"),
  bless({ is_acc => 0, label => 1, out_transition => { b => [2] } }, "State"),
  bless({ is_acc => 0, label => 2, out_transition => { b => [3] } }, "State"),
  bless({ is_acc => 1, label => 3, out_transition => {} }, "State"),
]
END

#test 4
is $res, $res_expect;

#test 5
is $obj->is_nfa, 1;

#test 6
is $obj->is_dfa, 0;

#test 7
undef $obj;
$obj = new Automaton;
$obj->read_file('transition_table/nfa.table');

my $test7_res = ( dump $obj->epsilon_closure_s( $obj->states->[0] ) ) . "\n";
my $test7_res_expect = <<END;
[
  bless({ is_acc => 0, label => 0, out_transition => { epsilon => [1, 7] } }, "State"),
  bless({ is_acc => 0, label => 7, out_transition => { a => [8], epsilon => [] } }, "State"),
  bless({ is_acc => 0, label => 1, out_transition => { epsilon => [2, 4] } }, "State"),
  bless({ is_acc => 0, label => 4, out_transition => { b => [5], epsilon => [] } }, "State"),
  bless({ is_acc => 0, label => 2, out_transition => { a => [3], epsilon => [] } }, "State"),
]
END
is $test7_res, $test7_res_expect;

#test 8

my @test8_arr = ();
push @test8_arr, $obj->states->[4];
push @test8_arr, $obj->states->[8];
push @test8_arr, $obj->states->[9];
my $test8_res = ( dump $obj->move( \@test8_arr, 'b' ) ) . "\n";
my $test8_res_expect = <<END;
[
  bless({ is_acc => 0, label => 5, out_transition => { epsilon => [6] } }, "State"),
  bless({ is_acc => 0, label => 9, out_transition => { b => [10] } }, "State"),
  bless({ is_acc => 1, label => 10, out_transition => {} }, "State"),
]
END
is $test8_res, $test8_res_expect;

#test 9

my @test9_arr = ();
push @test9_arr, $obj->states->[1];
push @test9_arr, $obj->states->[5];
my $test9_res        = ( dump $obj->epsilon_closure_t( \@test9_arr ) ) . "\n";
my $test9_res_expect = <<END;
[
  bless({ is_acc => 0, label => 1, out_transition => { epsilon => [2, 4] } }, "State"),
  bless({ is_acc => 0, label => 5, out_transition => { epsilon => [6] } }, "State"),
  bless({ is_acc => 0, label => 6, out_transition => { epsilon => [1, 7] } }, "State"),
  bless({ is_acc => 0, label => 7, out_transition => { a => [8], epsilon => [] } }, "State"),
  bless({ is_acc => 0, label => 2, out_transition => { a => [3], epsilon => [] } }, "State"),
  bless({ is_acc => 0, label => 4, out_transition => { b => [5], epsilon => [] } }, "State"),
]
END
is $test9_res, $test9_res_expect;
