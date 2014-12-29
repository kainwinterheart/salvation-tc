package Salvation::TC::Type::Number;

use strict;
use base qw( Salvation::TC::Type );
use Error qw ( :try );
use Salvation::TC::Exception::WrongType;
use Salvation::TC::Exception::WrongFormat;
use Salvation::TC::Exception::NotSupported;

use constant PREDEFINED_FORMATS => { '%.0f' => 1, '%.3f' => 1, '%.5f' => 1 };
use constant DEFAULT_FORMAT     => '%.5f';


sub ToString {

    my ( $class, $value, $format ) = @_;

    return( sprintf( $format || &DEFAULT_FORMAT, $value ) );
}

sub Check {
    throw Salvation::TC::Exception::NotSupported ( '-text' => __PACKAGE__ . '::Check: method not realised.' );
}

sub CheckFormat {

    my ( $class, $format ) = @_;

    ( &PREDEFINED_FORMATS->{ $format } || ( int( sprintf( $format, 2,718281828459045 ) ) == 2 ) ) ||

    throw Salvation::TC::Exception::WrongFormat ( '-text' => $format );
}

sub ListPredefinedFormats {
    return( [ keys( %{ &PREDEFINED_FORMATS } ) ] );
}

1
__END__
