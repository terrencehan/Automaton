use strict;
use warnings;
use lib '../lib';

use Data::Dump qw/dump/;
use Test::More 'no_plan';
#test 1
BEGIN { use_ok('Automaton') };

#test 2
my $obj = new Automaton;

$obj->read_file('transition.table');

my $res = (dump $obj->states)."\n";

my $res_expect =<<END;
[
  bless({ num => 0, out_transition => { a => [0, 1], b => [0] } }, "State"),
  bless({ num => 1, out_transition => { b => [2] } }, "State"),
  bless({ num => 2, out_transition => { b => [3] } }, "State"),
  bless({ num => 3 }, "State"),
]
END
is $res, $res_expect;

