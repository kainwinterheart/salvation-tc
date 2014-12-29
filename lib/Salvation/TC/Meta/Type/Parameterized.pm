package Salvation::TC::Meta::Type::Parameterized;

=head1 NAME

Salvation::TC::Meta::Type::Parameterized - Базовый класс для параметризованных типов

=cut

use strict;
use warnings;

use base 'Salvation::TC::Meta::Type';

use Scalar::Util 'blessed';
use Error ':try';

use Salvation::TC::Exception::WrongType::TC ();

=head1 METHODS

=cut

=head2 new()

=cut

sub new {

    my ( $proto, %args ) = @_;

    die( 'Parameterized type metaclass must have inner type' ) unless( defined $args{ 'inner' } );

    unless( blessed $args{ 'inner' } && $args{ 'inner' } -> isa( 'Salvation::TC::Meta::Type' ) ) {

        die( 'Inner type must be a Salvation::TC::Meta::Type' );
    }

    my $self = $proto -> SUPER::new( %args );

    $self -> { 'container_validator' } = delete( $self -> { 'validator' } );
    $self -> { 'validator' } = $self -> build_validator();

    return $self;
}

=head2 inner()

=cut

sub inner {

    my ( $self ) = @_;

    return $self -> { 'inner' };
}

=head2 iterate( Any $value, CodeRef $code )

=cut

sub iterate {

    my ( $self, $value, $code ) = @_;

    $code -> ( $value, undef );

    return;
}

=head2 container_validator()

=cut

sub container_validator {

    my ( $self ) = @_;

    return $self -> { 'container_validator' };
}

=head2 check_container( Any $value )

=cut

sub check_container {

    my ( $self, $value ) = @_;

    return $self -> container_validator() -> ( $value );
}

=head2 build_validator()

=cut

sub build_validator {

    my ( $self ) = @_;

    my $item_type = $self -> inner();

    return sub {

        my ( $value ) = @_;

        try {
            $self -> check_container( $value );

        } catch Salvation::TC::Exception::WrongType with {

            my ( $e ) = @_;

            Salvation::TC::Exception::WrongType::TC -> throw(
                type => $self -> name(), value => $value,
                ( $e -> isa( 'Salvation::TC::Exception::WrongType::TC' ) ? (
                    prev => $e,
                ) : () )
            );
        };

        $self -> iterate( $value, sub {

            my ( $item, $key ) = @_;

            try {
                $item_type -> check( $item );

            } catch Salvation::TC::Exception::WrongType with {

                my ( $e ) = @_;

                Salvation::TC::Exception::WrongType::TC -> throw(
                    type => $self -> name(), value => $value,
                    prev => Salvation::TC::Exception::WrongType::TC -> new(
                        type => $item_type -> name(),
                        value => $item,
                        param_name => $key,
                        ( $e -> isa( 'Salvation::TC::Exception::WrongType::TC' ) ? (
                            prev => $e,
                        ) : () )
                    )
                );
            };
        } );
    };
}

=head2 sign( ArrayRef $signature )

Генерирует валидатор для текущего типа на основе подписи.

=cut

sub sign {

    my ( $self, $signature ) = @_;

    my $signed_type_generator = $self -> signed_type_generator();

    unless( defined $signed_type_generator ) {

        die( sprintf( 'Type %s cannot be signed', $self -> name() ) )
    }

    my $signed_validator = $signed_type_generator -> ( $signature );

    return sub {

        $self -> check_container( $_[ 0 ] ) && $signed_validator -> ( $_[ 0 ] )
    };
}

=head2 length_checker( Int $min, Maybe[Int] $max )

Генерирует валидатор для текущего типа на основе спецификации длины.

=cut

sub length_checker {

    my ( $self, $min, $max ) = @_;

    my $length_type_generator = $self -> length_type_generator();

    unless( defined $length_type_generator ) {

        die( sprintf( 'Length of type %s could not be checked', $self -> name() ) );
    }

    my $length_validator = $length_type_generator -> ( $min, $max );

    return sub {

        $self -> check_container( $_[ 0 ] ) && $length_validator -> ( $_[ 0 ] )
    };
}

1;

__END__
