
use strict;
use warnings;
use lib '../lib';

use Test::More 'no_plan';
BEGIN { use_ok('Automation') };

my $obj = new Automation;

$obj->read_file('transition.table');

use Data::Dump qw/dump/;
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
