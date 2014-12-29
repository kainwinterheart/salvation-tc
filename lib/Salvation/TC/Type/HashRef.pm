package Salvation::TC::Type::HashRef;

use strict;
use warnings;

use base 'Salvation::TC::Type::Ref';

use Salvation::TC::Exception::WrongType ();
use Salvation::TC::Exception::WrongType::TC ();

use Error ':try';


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

                try {

                    $code -> ( @input );

                } catch Salvation::TC::Exception::WrongType with {

                    my ( $e ) = @_;

                    Salvation::TC::Exception::WrongType::TC -> throw(
                        type => $e -> getType(),
                        value => $e -> getValue(),
                        param_name => $param -> { 'name' },
                        ( $e -> isa( 'Salvation::TC::Exception::WrongType::TC' ) ? (
                            prev => $e -> getPrev(),
                        ) : () ),
                    );
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

1;

__END__
