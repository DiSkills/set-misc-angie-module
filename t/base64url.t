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

    wasm_var misc "angie:set-misc/base64url#encode" $encoded $arg_s;
    wasm_var misc "angie:set-misc/base64url#decode" $decoded $arg_s;

    server {
        listen 127.0.0.1:8080;

        location /encode {
            return 200 $encoded;
        }

        location /decode {
            return 200 $decoded;
        }
    }
}

EOF

$t->run()->plan(2);

###############################################################################

is(http_get_body("/encode?s=?b><d?"), "P2I-PGQ_", "base64url encode");
is(http_get_body("/decode?s=P2I-PGQ_"), "?b><d?", "base64url decode");

###############################################################################

sub http_get_body {
    my ($uri) = @_;

    my $r = http_get($uri);

    my ($h, $body) = split /\n\r/, $r, 2;
    $body =~ s/^\s+|\s+$//g;

    return $body;
}

###############################################################################
