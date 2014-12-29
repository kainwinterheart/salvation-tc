package Salvation::TC::Type::Text::English;

use strict;
use base qw( Salvation::TC::Type::Text );
use Error qw ( :try );
use Salvation::TC::Exception::WrongType;


sub Check {

    my ( $class, $value ) = @_;
    my $re = qr{^[a-z0-9_\-\"\'\,\.\s\/\(\)\@\+\*\:\;\!\#\$\%\^\&\?\[\]\{\}\\]+$};

    defined( $value ) || throw Salvation::TC::Exception::WrongType ( 'type' => 'EnglishText', 'value' => 'UNDEFINED' );
    ( $value =~ m/$re/i ) || throw Salvation::TC::Exception::WrongType ( 'type' => 'EnglishText', 'value' => $value );
}

1
__END__
