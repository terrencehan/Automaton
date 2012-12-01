use strict;
use warnings;
use lib '../lib';
use 5.010;

use Data::Dump qw/dump/;
use Test::More 'no_plan';
use Test::Deep;

#test 1
BEGIN { use_ok('Automaton') }

my $obj = new Automaton;

#test 2
is $obj->is_empty, 1;

$obj->read_file('transition_table/transition.table');

#test 3
is $obj->is_empty, 0;

#test 4
cmp_deeply $obj->states,
  [
    $obj->states->[0], $obj->states->[1],
    $obj->states->[2], $obj->states->[3],
  ];

#test 5
is $obj->is_nfa, 1;

#test 6
is $obj->is_dfa, 0;

#test 7
undef $obj;
$obj = new Automaton;
$obj->read_file('transition_table/nfa.table');

cmp_deeply $obj->epsilon_closure_s( $obj->states->[0] ),
  [
    $obj->states->[0], $obj->states->[1], $obj->states->[2],
    $obj->states->[4], $obj->states->[7],
  ];

#test 8

my @test8_arr = ();
push @test8_arr, $obj->states->[4];
push @test8_arr, $obj->states->[8];
push @test8_arr, $obj->states->[9];

cmp_deeply $obj->move( \@test8_arr, 'b' ),
  [ $obj->states->[5], $obj->states->[9], $obj->states->[10], ];

#test 9

my @test9_arr = ();
push @test9_arr, $obj->states->[1];
push @test9_arr, $obj->states->[5];

cmp_deeply $obj->epsilon_closure_t( \@test9_arr ),
  [
    $obj->states->[1], $obj->states->[2], $obj->states->[4],
    $obj->states->[5], $obj->states->[6], $obj->states->[7],
  ];

#test 10
is $obj->_state_list_ref2str( [ $obj->states->[0], $obj->states->[1] ] ),
  '{0, 1}';

#test 11
cmp_deeply( $obj->_str2state_list_ref("{1, 2, 4}"),
    [ $obj->states->[1], $obj->states->[2], $obj->states->[4], ] );

#test 12
cmp_deeply $obj->get_accs, [$obj->states->[10]];
