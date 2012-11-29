#!/usr/bin/env perl 
use lib '../lib';

use Automaton;
use File::Slurp;

$auto = new Automaton;

$table_file = shift;

$auto->read_file($table_file);

write_file($table_file.".png", $auto->as_png);

