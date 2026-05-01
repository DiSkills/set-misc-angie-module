#!/usr/bin/perl

###############################################################################

use warnings;
use strict;

use Env;
use Test::More;

use Socket qw/CRLF/;

BEGIN {
    use FindBin;
    chdir($FindBin::Bin);
}

use lib 'lib';
use Test::Nginx;

###############################################################################

select STDERR;
$| = 1;
select STDOUT;
$| = 1;

my $t = Test::Nginx->new()->has(qw/http/);

$t->write_file_expand('nginx.conf', <<'EOF');

%%TEST_GLOBALS%%

load_module MODULES/ngx_wasm_module.so;
load_module MODULES/ngx_wasm_core_module.so;
load_module MODULES/ngx_http_wasm_host_module.so;

load_module MODULES/WASM_ENGINE;

daemon off;

events {
}

wasm_modules {
    load WASMS/set_misc_angie_module.wasm id=misc;
    WASM_GLOBALS
}

http {
    %%TEST_GLOBALS_HTTP%%

    wasm_var misc "angie:set-misc/random#range" $range $arg_from $arg_to;
    wasm_var misc "angie:set-misc/random#range" $bad_range;

    server {
        listen 127.0.0.1:8080;

        location /range {
            return 200 $range;
        }

        location /bad-range {
            return 200 $bad_range;
        }
    }
}

EOF

$t->run()->plan(6);

###############################################################################

http_get("/bad-range");
like($t->read_file('error.log'), qr/error: expected 2 arguments/, "range no args");

is(http_get_body("/range?from=42&to=42"), "42", "range from=to");

my $r1 = http_get_body("/range?from=1&to=100");
ok($r1 >= 1 && $r1 <= 100, "range 1..100");

my $r2 = http_get_body("/range?from=100&to=1");
ok($r2 >= 1 && $r2 <= 100, "range swapped");

http_get("/range?from=abc&to=10");
like($t->read_file('error.log'), qr/error: bad "from" argument: abc/, "range bad from");

http_get("/range?from=10&to=-10");
like($t->read_file('error.log'), qr/error: bad "to" argument: -10/, "range bad to");

###############################################################################

sub http_get_body {
    my ($uri) = @_;

    my $r = http_get($uri);

    my ($h, $body) = split /\n\r/, $r, 2;
    $body =~ s/^\s+|\s+$//g;

    return $body;
}

###############################################################################
