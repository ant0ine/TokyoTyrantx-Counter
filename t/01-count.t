use strict;

use Test::More tests => 1 + 4 * 10 + 5;
use Test::Exception;

use IO::File;
use TokyoTyrant;
use TokyoTyrantx::Counter;
use TokyoTyrantx::Instance;

my $ti;

BEGIN {
    $ti = TokyoTyrantx::Instance->new( counthash => {
            dir => '/tmp',
            host => '127.0.0.1',
            port => 4000,
            filename => "'*'",
        }
    );
    $ti->start;

    sleep(2);
}

# connect
my $counter = TokyoTyrantx::Counter->instance( hash => $ti->get_rdb ); 
isa_ok($counter, 'TokyoTyrantx::Counter');

# test
my $key = time;

$TokyoTyrantx::Counter::Client::DEBUG = 1;

for (1..10) {
    my $count = $counter->inc($key);
    cmp_ok( $count, '==', $_, "count equals $_");
}

for (1..10) {
    my $count = $counter->dec($key);
    my $test = 10 - $_;
    cmp_ok( $count, '==', $test, "count equals $test");
}

for (1..10) {
    my $count = $counter->dec($key);
    my $test = - $_;
    cmp_ok( $count, '==', $test, "count equals $test");
}

for (1..10) {
    my $count = $counter->inc($key);
    my $test = $_ - 10;
    cmp_ok( $count, '==', $test, "count equals $test");
}

ok($counter->reset($key), 'reset');
my $count = $counter->inc($key);
cmp_ok( $count, '==', 1, "count equals 1");

$counter->iterinit;
my $k = $counter->iternext;
cmp_ok($k, '==', $key, 'right key'); 
cmp_ok($counter->value($k), '==', $count, 'right count'); 
$k = $counter->iternext;
ok(!$k, 'no more counter');

END {
    $ti->stop;
}
