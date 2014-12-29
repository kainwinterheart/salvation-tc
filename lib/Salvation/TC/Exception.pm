package Salvation::TC::Exception;

use strict;
use Error qw( :try );
use base  qw( Error );

sub getMessage {
  return( ref( $_[0] ) ? $_[0]->stacktrace() : '' );
}

1;

__END__
