use strict;
use warnings;
use lib '../lib';

use Test::More 'no_plan';

BEGIN { use_ok('State') }

my $obj = new State;

my $hash = $obj->out_transition;

$obj->add_in_transition( 'e', 2 );

is ref( $obj->in_transition ), 'HASH';
is ref( $obj->in_transition->{e} ), 'ARRAY';

