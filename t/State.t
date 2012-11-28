use strict;
use warnings;
use lib '../lib';

use Test::More 'no_plan';

BEGIN { use_ok('State') }

my $obj = new State;

is $obj->search_out_label('not exist'), 0;

$obj->add_out_transition( 'r', 4 );
$obj->add_out_transition( 'r', 3 );
is $obj->search_out_label('r'), 2;
$obj->add_out_transition( 'e', 3 );
is $obj->out_degree, 2;

$obj->delete_transition('r');
is $obj->search_out_label('r'), 0;
is $obj->out_degree, 1;

$obj->empty_transition;
is $obj->out_degree, 0;

