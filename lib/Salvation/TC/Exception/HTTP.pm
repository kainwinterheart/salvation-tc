package Salvation::TC::Exception::HTTP;

use strict;
use Salvation::TC::Exception;
use base qw( Salvation::TC::Exception );

sub code { return( $_[0]->{ 'code' } ); }

1;
__END__
