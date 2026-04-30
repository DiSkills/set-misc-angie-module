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

    wasm_var misc "angie:set-misc/local#today" $today;

    server {
        listen 127.0.0.1:8080;

        location /today {
            return 200 $today;
        }
    }
}

EOF

$t->run()->plan(1);

###############################################################################

my ($sec, $min, $hour, $mday, $mon, $year) = localtime;
my $date = sprintf("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);
is(http_get_body("/today"), $date, "local-today");

###############################################################################

sub http_get_body {
    my ($uri) = @_;

    my $r = http_get($uri);

    my ($h, $body) = split /\n\r/, $r, 2;
    $body =~ s/^\s+|\s+$//g;

    return $body;
}

###############################################################################
