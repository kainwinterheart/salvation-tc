package Salvation::TC::Type::Text;

use strict;
use base qw( Salvation::TC::Type );
use Error qw ( :try );
use Salvation::TC::Exception::WrongType;


sub Check {
    my ( $class, $value ) = @_;
    ( ! ref( $value ) && $value ne '' ) || throw Salvation::TC::Exception::WrongType ( 'type' => 'Text', 'value' => $value );
}

sub create_length_validator {

    my ( $class, $min, $max ) = @_;

    return sub {

        my $len = length( $_[ 0 ] );

        unless( ( $len >= $min ) && ( defined( $max ) ? ( $len <= $max ) : 1 ) ) {

            Salvation::TC::Exception::WrongType -> throw(
                'type' => sprintf( 'Text{%s,%s}', $min, ( $max // '' ) ),
                'value' => $_[ 0 ]
            );
        }

        1;
    };
}

1
__END__
