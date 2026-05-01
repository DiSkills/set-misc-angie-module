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
    load WASMS/set_misc_angie_module.wasm id=misc type=reactor;
    WASM_GLOBALS
}

http {
    %%TEST_GLOBALS_HTTP%%

    wasm_var misc "angie:set-misc/rotate#rotate" $rotate $arg_from $arg_to;
    wasm_var misc "angie:set-misc/rotate#rotate" $bad_rotate;

    server {
        listen 127.0.0.1:8080;

        location /rotate {
            return 200 $rotate;
        }

        location /bad-rotate {
            return 200 $bad_rotate;
        }
    }
}

EOF

$t->run()->plan(15);

###############################################################################

http_get("/bad-rotate");
like($t->read_file('error.log'), qr/error: expected 2 arguments/, "rotate no args");

is(http_get_body("/rotate?from=42&to=42"), 42, "rotate from=to (1st)");
is(http_get_body("/rotate?from=42&to=42"), 42, "rotate from=to (2nd)");

is(http_get_body("/rotate?from=1&to=3"), 1, "rotate 1..3 (1st)");
is(http_get_body("/rotate?from=1&to=3"), 2, "rotate 1..3 (2nd)");
is(http_get_body("/rotate?from=1&to=3"), 3, "rotate 1..3 (3rd)");
is(http_get_body("/rotate?from=1&to=3"), 1, "rotate 1..3 (4th)");
is(http_get_body("/rotate?from=1&to=3"), 2, "rotate 1..3 (5th)");
is(http_get_body("/rotate?from=1&to=3"), 3, "rotate 1..3 (6th)");
is(http_get_body("/rotate?from=1&to=3"), 1, "rotate 1..3 (7th)");

is(http_get_body("/rotate?from=3&to=2"), 2, "rotate swapped (1st)");
is(http_get_body("/rotate?from=3&to=2"), 3, "rotate swapped (2nd)");
is(http_get_body("/rotate?from=3&to=2"), 2, "rotate swapped (3rd)");

http_get("/rotate?from=abc&to=10");
like($t->read_file('error.log'), qr/error: bad "from" argument: abc/, "rotate bad from");

http_get("/rotate?from=10&to=-10");
like($t->read_file('error.log'), qr/error: bad "to" argument: -10/, "rotate bad to");

###############################################################################

sub http_get_body {
    my ($uri) = @_;

    my $r = http_get($uri);

    my ($h, $body) = split /\n\r/, $r, 2;
    $body =~ s/^\s+|\s+$//g;

    return $body;
}

###############################################################################
