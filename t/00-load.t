#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'TokyoTyrantx::Counter' );
}

diag( "Testing TokyoTyrantx::Counter $TokyoTyrantx::Counter::VERSION, Perl $], $^X" );
