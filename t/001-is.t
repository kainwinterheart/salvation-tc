#!/usr/bin/perl -w

use strict;
use warnings;

package Class1;

sub new {

    my ( $proto ) = @_;

    return bless( {}, ( ref( $proto ) || $proto ) );
}

package main;

use Test::More;
use Salvation::TC ();
use Data::Dumper 'Dumper';

use Salvation::TC::Utils;

enum 'RGB', [ 'red', 'green', 'blue' ];

no Salvation::TC::Utils;

$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 0;

my @cases = (
    [ 1, 'Int', 1 ],
    [ 1, 'Num', 1 ],
    [ 1, 'Str', 1 ],
    [ 1, 'ArrayRef', 0 ],
    [ 1, 'HashRef', 0 ],
    [ 1, 'CodeRef', 0 ],
    [ 1, 'Class1', 0 ],

    [ 1.1, 'Int', 0 ],
    [ 1.1, 'Num', 1 ],
    [ 1.1, 'Str', 1 ],
    [ 1.1, 'ArrayRef', 0 ],
    [ 1.1, 'HashRef', 0 ],
    [ 1.1, 'CodeRef', 0 ],
    [ 1.1, 'Class1', 0 ],

    [ 'asd', 'Int', 0 ],
    [ 'asd', 'Num', 0 ],
    [ 'asd', 'Str', 1 ],
    [ 'asd', 'ArrayRef', 0 ],
    [ 'asd', 'HashRef', 0 ],
    [ 'asd', 'CodeRef', 0 ],
    [ 'asd', 'Class1', 0 ],

    [ [], 'Int', 0 ],
    [ [], 'Num', 0 ],
    [ [], 'Str', 0 ],
    [ [], 'ArrayRef', 1 ],
    [ [], 'HashRef', 0 ],
    [ [], 'CodeRef', 0 ],
    [ [], 'Class1', 0 ],

    [ {}, 'Int', 0 ],
    [ {}, 'Num', 0 ],
    [ {}, 'Str', 0 ],
    [ {}, 'ArrayRef', 0 ],
    [ {}, 'HashRef', 1 ],
    [ {}, 'CodeRef', 0 ],
    [ {}, 'Class1', 0 ],

    [ sub {}, 'Int', 0 ],
    [ sub {}, 'Num', 0 ],
    [ sub {}, 'Str', 0 ],
    [ sub {}, 'ArrayRef', 0 ],
    [ sub {}, 'HashRef', 0 ],
    [ sub {}, 'CodeRef', 1 ],
    [ sub {}, 'Class1', 0 ],

    [ Class1 -> new(), 'Int', 0 ],
    [ Class1 -> new(), 'Num', 0 ],
    [ Class1 -> new(), 'Str', 0 ],
    [ Class1 -> new(), 'ArrayRef', 0 ],
    [ Class1 -> new(), 'HashRef', 0 ],
    [ Class1 -> new(), 'CodeRef', 0 ],
    [ Class1 -> new(), 'Class1', 1 ],

    [ 1, 'ArrayRef[Int]|Int', 1 ],
    [ 1, 'ArrayRef[Str]|Str', 1 ],
    [ 'asd', 'ArrayRef[Int]|Str', 1 ],
    [ {}, 'ArrayRef[HashRef]', 0 ],
    [ [ [ { a => [ undef, 'asd' ] } ], 'qwe' ], 'ArrayRef[Str|ArrayRef[HashRef[ArrayRef[Maybe[Str]]]]]', 1 ], # WUT
    [ undef, 'Maybe[Str]', 1 ],
    [ 'asd', 'Maybe[Str]', 1 ],

    [ 'green', 'RGB', 1 ],
    [ 'white', 'RGB', 0 ],
    [ [ 'red', 'blue' ], 'ArrayRef[RGB]', 1 ],
    [ [ 'red', 'white' ], 'ArrayRef[RGB]', 0 ],
);

plan tests => scalar( @cases );

foreach my $case ( @cases ) {

    cmp_ok(
        Salvation::TC -> is( @$case[ 0, 1 ] ), '==', $case -> [ 2 ],
        sprintf( 'is( %s, %s ) == %d', Dumper( $case -> [ 0 ] ), @$case[ 1, 2 ] )
    );
}

exit 0;

__END__
