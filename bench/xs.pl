#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin '$Bin';
use lib "${Bin}";
use blib "${Bin}/../blib";

use Benchmark 'timethese';
use TestBench ();
use Salvation::TC::Parser ();

$Salvation::TC::Parser::BACKEND = 'Salvation::TC::Parser::XS';

my $opts = { loose => 1 };

timethese( 10 ** 6, {
    xs1 => sub { Salvation::TC::Parser -> tokenize_type_str( TestBench::STR1, $opts ) },
} );

exit 0;

__END__
