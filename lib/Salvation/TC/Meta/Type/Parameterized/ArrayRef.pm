package Salvation::TC::Meta::Type::Parameterized::ArrayRef;

=head1 NAME

Salvation::TC::Meta::Type::Parameterized::HashRef - Класс для типа параметризованного ArrayRef.

=cut

use strict;
use warnings;
use boolean;

use base 'Salvation::TC::Meta::Type::Parameterized';

=head1 METHODS

=cut

=head2 iterate( ArrayRef $value, CodeRef $code )

=cut

sub iterate {

    my ( $self, $value, $code ) = @_;

    my $i = 0;

    foreach my $item ( @$value ) {

        $code -> ( $item, $i++ );
    }

    return;
}

=head2 unfold( ArrayRef $value )

=cut

sub unfold {

    my ( $self, $value ) = @_;

    return @$value;
}

=head2 signed_type_generator()

=cut

sub signed_type_generator {

    my ( $self ) = @_;

    return $self -> { 'signed_type_generator' } //= Salvation::TC -> get( 'ArrayRef' ) -> signed_type_generator();
}

=head2 length_type_generator()

=cut

sub length_type_generator {

    my ( $self ) = @_;

    return $self -> { 'length_type_generator' } //= Salvation::TC -> get( 'ArrayRef' ) -> length_type_generator();
}


1;

__END__
