package Salvation::TC::Type::Number::Integer;

use strict;
use base qw( Salvation::TC::Type::Number );
use Salvation::TC::Exception::WrongType;
use Error qw(:try);

sub Check {

    my ( $class, $value ) = @_;

    defined( $value ) || throw Salvation::TC::Exception::WrongType ( 'type' => 'Integer', 'value' => 'UNDEFINED' );
    ( $value =~ m/^[-+]?\d+$/ ) || throw Salvation::TC::Exception::WrongType ( 'type' => 'Number::Integer', 'value' => $value );
}

1;
__END__
