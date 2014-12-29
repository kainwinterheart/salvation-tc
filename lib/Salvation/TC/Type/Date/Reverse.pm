package Salvation::TC::Type::Date::Reverse;

use strict;
use base qw( Salvation::TC::Type::Date );
use Error qw ( :try );


sub Check {

    my ( $class, $date ) = @_;

    try {

        die "Wrong date format. Expected year[.-/]month[./-]day time" if ( ! defined( $date ) || $date !~ m/^(\d{4})[\.\/\-](\d{1,2})[\.\/\-](\d{1,2})\s*(\d+:\d+(:\d+)*?)?$/ );

        my ( $year, $month, $day, $time ) = ( $1, $2, $3, $4 );

        $class->SUPER::Check( "$day.$month.$year $time" );
    }
    otherwise {
        my $e = shift( @_ );
        throw Salvation::TC::Exception::WrongType( 'type' => 'Date::Reverse', 'value' => $date, '-text' => $e->stacktrace() );
    };
}

1;
__END__
