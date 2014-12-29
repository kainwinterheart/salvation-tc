package Salvation::TC::Type::Date;

use strict;
use base qw( Salvation::TC::Type );
use Error qw ( :try );
use Salvation::TC::Type::Time;
use Salvation::TC::Exception::WrongType;
use Time::Piece ();

sub Check {

    my ( $class, $date ) = @_;

    try {

        die "Wrong date format. Expected day[.-/]month[./-]year time" if ( ! defined( $date ) || $date !~ m/^(\d{1,2})[\.\/\-](\d{1,2})[\.\/\-](\d{4})\s*(\d+:\d+(:\d+)*?)?$/ );

        my ( $day, $month, $year, $time ) = ( $1, $2, $3, $4 );

        die "Month must be between 1 and 12. Current value is $month."    unless $month >= 1 && $month  <= 12;
        die "Day must be between 1 and 31. Current value is $day."        unless $day   >= 1 && $day    <= 31;
        die "Year must be between 1900 and 2110. Current value is $year." unless $year  >= 1900 && $year <= 2110;

        Salvation::TC::Type::Time->Check( $time ) if ( $time );

        defined( Time::Piece -> strptime( "$year-$month-$day", '%Y-%m-%d' ) ) || die "Unknow date format: $date.";
    }
    otherwise {
        my $e = shift( @_ );
        throw Salvation::TC::Exception::WrongType( 'type' => 'Date', 'value' => $date, '-text' => $e->stacktrace() );
    };
}

1;
__END__
