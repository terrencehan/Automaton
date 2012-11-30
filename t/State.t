# t/State.pm
# Copyright (c) 2012 terrencehan
# hanliang1990@gmail.com

use strict;
use warnings;
use lib '../lib';
use 5.010;

use Test::More 'no_plan';

BEGIN { use_ok('State') }

my $obj = new State;

is $obj->search_out_label('not exist'), 0;

$obj->add_out_transition( 'r', 4 );
$obj->add_out_transition( 'r', 3 );
is $obj->search_out_label('r'), 2;

$obj->add_out_transition( 'e', 3 );
is $obj->out_degree, 3;

$obj->delete_transition('r');
is $obj->search_out_label('r'), 0;
is $obj->out_degree, 1;

$obj->empty_transition;
is $obj->out_degree, 0;

my @arr;
push @arr, new State( num => 100 );
is(( ( new State( num => 100 ) ) ~~ @arr ), 1);
is(( ( new State( num => 101 ) ) ~~ @arr ), '');
push @arr, new State( num => 101 );
is(( ( new State( num => 101 ) ) ~~ @arr ), 1);
is(( ( new State( num => 100 ) ) ~~ @arr ), 1);
