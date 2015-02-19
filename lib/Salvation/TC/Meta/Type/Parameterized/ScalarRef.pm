package Salvation::TC::Meta::Type::Parameterized::ScalarRef;

=head1 NAME

Salvation::TC::Meta::Type::Parameterized::ScalarRef - Класс для типа параметризованного ScalarRef.

=cut

use strict;
use warnings;
use boolean;

use base 'Salvation::TC::Meta::Type::Parameterized';

=head1 METHODS

=cut

=head2 iterate( ScalarRef $value, CodeRef $code )

=cut

sub iterate {

    my ( $self, $value, $code ) = @_;

    $code -> ( $$value, 0 );

    return;
}


1;

__END__
