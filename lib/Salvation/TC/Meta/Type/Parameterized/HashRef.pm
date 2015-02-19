package Salvation::TC::Meta::Type::Parameterized::HashRef;

=head1 NAME

Salvation::TC::Meta::Type::Parameterized::HashRef - Класс для типа параметризованного HashRef.

=cut

use strict;
use warnings;
use boolean;

use base 'Salvation::TC::Meta::Type::Parameterized';

use Error ':try';

=head1 METHODS

=cut

=head2 iterate( HashRef $value, CodeRef $code )

=cut

sub iterate {

    my ( $self, $value, $code ) = @_;

    while( my ( $key, $item ) = each( %$value ) ) {

        try {
            $code -> ( $item, $key );

        } catch Salvation::TC::Exception::WrongType with {

            my ( $e ) = @_;

            keys( %$value ); # сбрасываем итератор

            $e -> throw();
        };
    }

    return;
}

=head2 signed_type_generator()

=cut

sub signed_type_generator {

    my ( $self ) = @_;

    return $self -> { 'signed_type_generator' } //= Salvation::TC -> get( 'HashRef' ) -> signed_type_generator();
}


1;

__END__
