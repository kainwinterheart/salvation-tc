#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 14;
use Salvation::TC ();

cmp_ok( Salvation::TC -> is( { asd => 1 }, 'HashRef(Int :asd!)' ), '==', 1 );
cmp_ok( Salvation::TC -> is( { qwe => 1 }, 'HashRef(Int :asd!)' ), '==', 0 );
cmp_ok( Salvation::TC -> is( { asd => undef }, 'HashRef(Int :asd!)' ), '==', 0 );
cmp_ok( Salvation::TC -> is( { asd => 1, zxc => [] }, 'HashRef(Int :asd!)' ), '==', 1 );

cmp_ok( Salvation::TC -> is( { asd => 1, zxc => [] }, 'HashRef(Int :asd!, ArrayRef :zxc)' ), '==', 1 );
cmp_ok( Salvation::TC -> is( { asd => 1 }, 'HashRef(Int :asd!, ArrayRef :zxc?)' ), '==', 1 );
cmp_ok( Salvation::TC -> is( { asd => 1 }, 'HashRef(Int :asd!, ArrayRef :zxc)' ), '==', 1 );

cmp_ok( Salvation::TC -> is( [ 1 ], 'ArrayRef(Int el1!)' ), '==', 1 );
cmp_ok( Salvation::TC -> is( [ 1 ], 'ArrayRef(Int el1)' ), '==', 1 );
cmp_ok( Salvation::TC -> is( [], 'ArrayRef(Int el1)' ), '==', 0 );
cmp_ok( Salvation::TC -> is( [ 1, [] ], 'ArrayRef(Int el1)' ), '==', 1 );
cmp_ok( Salvation::TC -> is( [ 1, [] ], 'ArrayRef(Int el1, Int el2)' ), '==', 0 );
cmp_ok( Salvation::TC -> is( [ 1, -1 ], 'ArrayRef(Int el1, Int el2)' ), '==', 1 );

cmp_ok( Salvation::TC -> is(
    [
        { asd => [ 'asd' ], qwe => 1 },
        { qwe => 2 }
    ],
    'ArrayRef[
        HashRef(Int :qwe!)
    ](
        HashRef(
            ArrayRef[ Str ] :asd!
        )
        el
    )' ), '==', 1 );

exit 0;

__END__
