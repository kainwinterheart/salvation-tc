package Salvation::TC::Type::Number::Float;

use strict;
use Error qw( :try );
use base qw( Salvation::TC::Type::Number );
use Salvation::TC::Exception::WrongType;

sub Check {

    my ( $class, $value ) = @_;

    defined( $value ) || throw Salvation::TC::Exception::WrongType ( 'type' => 'Float', 'value' => 'UNDEFINED' );
    $value =~ /^[-+]?\d*\.?(\d+)?$/ || throw Salvation::TC::Exception::WrongType ( 'type' => 'Number::Float', 'value' => $value );
}

1
__END__
