#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir splitdir catfile/;
use Plack::Builder;

# Source directory has precedence
my @base = (splitdir(dirname(__FILE__)), '..');

$ENV{MOJO_MODE} = 'production';

builder {
 enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
        "Plack::Middleware::ReverseProxy";
 my $app_file = catfile( @base, qw( script music_manager ) );
 require $app_file;
};
