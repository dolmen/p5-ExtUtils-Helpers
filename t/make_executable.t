#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Config;
use Test::More tests => 3;
use ExtUtils::Helpers qw/make_executable/;
use Cwd qw/cwd/;

my $filename = 'test_exec';
my @files;

open my $out, '>', $filename or die "Couldn't create $filename: $!";
print $out "#! perl \nexit 42;\n";
close $out;

make_executable($filename);

{
	my $cwd = cwd;
	local $ENV{PATH} = join $Config{path_sep}, $cwd, $ENV{PATH};
	my $ret = system $filename;
	is $ret & 0xff, 0, 'test_exec executed successfully';
	is $ret >> 8, 42, 'test_exec return value ok';
}

SKIP: {
	skip 'No batch file on non-windows', 1 if $^O ne 'MSWin32';
	push @files, map { my $f = "${filename}$_"; -f $f ? $f : () } split(/;/, $ENV{PATHEXT});
	is scalar(@files), 1, "Executable file exists";
}

unlink $filename, @files;
