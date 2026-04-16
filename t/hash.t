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

    wasm_var misc "angie:set-misc/hash#sha1" $sha1 $arg_s;
    wasm_var misc "angie:set-misc/hash#md5" $md5 $arg_s;

    server {
        listen 127.0.0.1:8080;

        location /sha1 {
            return 200 $sha1;
        }

        location /md5 {
            return 200 $md5;
        }
    }
}

EOF

$t->run()->plan(4);

###############################################################################

# sha1
is(http_get_body("/sha1?s=hello"), "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d", "sha1 hello");
is(http_get_body("/sha1"), "da39a3ee5e6b4b0d3255bfef95601890afd80709", "sha1 empty");

# md5
is(http_get_body("/md5?s=hello"), "5d41402abc4b2a76b9719d911017c592", "md5 hello");
is(http_get_body("/md5"), "d41d8cd98f00b204e9800998ecf8427e", "md5 empty");

###############################################################################

sub http_get_body {
    my ($uri) = @_;

    my $r = http_get($uri);

    my ($h, $body) = split /\n\r/, $r, 2;
    $body =~ s/^\s+|\s+$//g;

    return $body;
}

###############################################################################
