package Salvation::TC::Type::HashRef;

use strict;
use warnings;

use base 'Salvation::TC::Type::Ref';

use Scalar::Util 'blessed';
use Salvation::TC::Exception::WrongType ();
use Salvation::TC::Exception::WrongType::TC ();


sub Check {

    my ( $class, $value ) = @_;

    ( ref( $value ) eq 'HASH' ) || Salvation::TC::Exception::WrongType -> throw( 'type' => 'HashRef', 'value' => $value );
}

sub create_validator_from_sig {

    my ( $class, $signature ) = @_;

    my @checks = ();

    foreach my $el ( @$signature ) {

        my ( $param, $type ) = @$el{ 'param', 'type' };

        die( 'Only named parameters are supported' ) if( $param -> { 'positional' } );

        my $wrap = sub {

            my ( $code ) = @_;

            return sub {

                my ( @input ) = @_;

                {
                    local $SIG{ '__DIE__' } = 'DEFAULT';

                    eval { $code -> ( @input ) };
                }

                if( $@ ) {

                    if( blessed( $@ ) && $@ -> isa( 'Salvation::TC::Exception::WrongType' ) ) {

                        Salvation::TC::Exception::WrongType::TC -> throw(
                            type => $@ -> getType(),
                            value => $@ -> getValue(),
                            param_name => $param -> { 'name' },
                            ( $@ -> isa( 'Salvation::TC::Exception::WrongType::TC' ) ? (
                                prev => $@ -> getPrev(),
                            ) : () ),
                        );

                    } else {

                        die( $@ );
                    }
                };
            };
        };

        if( $param -> { 'optional' } ) {

            push( @checks, $wrap -> ( sub {

                if( exists $_[ 0 ] -> { $param -> { 'name' } } ) {

                    $type -> check( $_[ 0 ] -> { $param -> { 'name' } } )
                }

            } ) );

        } else {

            push( @checks, $wrap -> ( sub {

                exists $_[ 0 ] -> { $param -> { 'name' } } || Salvation::TC::Exception::WrongType
                    -> throw( 'type' => $type -> name(), 'value' => '(not exists)' );

                $type -> check( $_[ 0 ] -> { $param -> { 'name' } } );

            } ) );
        }
    }

    return sub {

        $_ -> ( $_[ 0 ] ) for @checks;

        1;
    };
}

sub create_length_validator {

    my ( $class, $min, $max ) = @_;

    return sub {

        my $len = scalar( keys( %{ $_[ 0 ] } ) );

        if( ( $len < $min ) || ( defined $max && ( $len > $max ) ) ) {

            Salvation::TC::Exception::WrongType -> throw(
                'type' => sprintf( 'HashRef{%s,%s}', $min, ( $max // '' ) ),
                'value' => $_[ 0 ]
            );
        }

        1;
    };
}

1;

__END__
