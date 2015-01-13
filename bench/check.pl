#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin '$Bin';
use lib "${Bin}";
use blib "${Bin}/../blib";

use Benchmark 'timethese';
use TestBench ();
use Salvation::TC ();

$Salvation::TC::Parser::BACKEND = 'Salvation::TC::Parser::XS';

my $o = bless( {}, 'qwe' );

timethese( 10 ** 6, {
    Undef => sub { Salvation::TC -> assert( undef, 'Undef' ) },
    Str => sub { Salvation::TC -> assert( 'asd', 'Str' ) },
    Int => sub { Salvation::TC -> assert( 123, 'Int' ) },
    Num => sub { Salvation::TC -> assert( 123.456, 'Num' ) },
    Object => sub { Salvation::TC -> assert( $o, 'Object' ) },
    qwe => sub { Salvation::TC -> assert( $o, 'qwe' ) },
    array_of_custom_hashes => sub { Salvation::TC -> assert( [
        {
            table => 'books',
            class => 'Classes::Book',
            str => 'some str',
            rest => [ 'one', 'two', 'three' ],
        },
        {
            table => 'shelves',
            class => 'Classes::Shelf',
            str => 'some other str',
            stuff => 1,
        }
    ], 'ArrayRef[HashRef(
        Str :table!,
        Str :class!,
        Str :str!,
        ArrayRef[Str] :rest,
        Bool :stuff
    )]' ) },

} );

exit 0;

__END__
