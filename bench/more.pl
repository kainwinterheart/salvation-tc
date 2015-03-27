#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin '$Bin';
use blib "${Bin}/../blib/";

use Benchmark 'cmpthese';
use Salvation::TC ();

use constant {

    ITERATIONS => 100000,
};


my $int = 100500;
my $str = 'phrase';
my $hash = { id => $int, phrase => $str };
my $array = [ $hash ];
my $data = { phrases => $array };


cmpthese( ITERATIONS, {

    map( { my ( $f, $v ) = @$_; ( $f => sub { Salvation::TC -> is( $v, $f ) } ); } (

        [ 'ArrayRef' => $array ],
        [ 'HashRef' => $hash ],
        [ 'Int' => $int ],
        [ 'Str' => $str ],

        [ 'ArrayRef[HashRef]' => $array ],
        [ 'HashRef[Str]' => $hash ],
        [ 'ArrayRef[HashRef[Str]]' => $array ],

        [ 'HashRef( Int :id )' => $hash ],
        [ 'ArrayRef[HashRef( Int :id )]' => $array ],

        [ 'HashRef( ArrayRef[HashRef( Int :id )] :phrases )' => $data ],
    ) ),
} );

exit 0;

__END__
