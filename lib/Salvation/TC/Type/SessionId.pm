package Salvation::TC::Type::SessionId;

# $Id: SessionId.pm 6868 2014-06-03 10:59:59Z trojn $

use strict;
use base qw( Salvation::TC::Type );
use Error qw ( :try );
use Salvation::TC::Exception::WrongType;


sub Check {

    my ( $class, $session_id ) = @_;

    ( defined( $session_id ) && $session_id =~ m/^[A-Za-z0-9]{32}$/ ) || 
        throw Salvation::TC::Exception::WrongType ( 'type' => 'SessionId', 'value' => $session_id, '-text' => 'Wrong type for "session_id".' );
}

1;
__END__
