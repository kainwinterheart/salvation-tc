package Salvation::TC::Type::ArrayRef;

use strict;
use warnings;

use base 'Salvation::TC::Type::Ref';

use Salvation::TC::Exception::WrongType ();
use Salvation::TC::Exception::WrongType::TC ();

use Error ':try';


sub Check {

    my ( $class, $value ) = @_;

    ( ref( $value ) eq 'ARRAY' ) || Salvation::TC::Exception::WrongType -> throw( 'type' => 'ArrayRef', 'value' => $value );
}

sub create_validator_from_sig {

    my ( $class, $signature ) = @_;

    my @checks = ();
    my $i = 0;

    foreach my $el ( @$signature ) {

        my ( $param, $type ) = @$el{ 'param', 'type' };

        die( 'Only positional parameters are supported' ) if( $param -> { 'named' } );

        die( 'Optional parameters are not supported' ) if( $param -> { 'optional' } );

        my $local_i = $i++;

        push( @checks, sub {

            my ( @input ) = @_;

            try {

                $type -> check( $input[ 0 ] -> [ $local_i ] );

            } catch Salvation::TC::Exception::WrongType with {

                my ( $e ) = @_;

                Salvation::TC::Exception::WrongType::TC -> throw(
                    type => $e -> getType(),
                    value => $e -> getValue(),
                    param_name => $local_i,
                    ( $e -> isa( 'Salvation::TC::Exception::WrongType::TC' ) ? (
                        prev => $e -> getPrev(),
                    ) : () ),
                );
            };
        } );
    }

    return sub {

        $_ -> ( $_[ 0 ] ) for @checks;

        1;
    };
}

sub create_length_validator {

    my ( $class, $min, $max ) = @_;

    return sub {

        my $len = scalar( @{ $_[ 0 ] } );

        unless( ( $len >= $min ) && ( defined( $max ) ? ( $len <= $max ) : 1 ) ) {

            Salvation::TC::Exception::WrongType -> throw(
                'type' => sprintf( 'ArrayRef{%s,%s}', $min, ( $max // '' ) ),
                'value' => $_[ 0 ]
            );
        }

        1;
    };
}

1;

__END__