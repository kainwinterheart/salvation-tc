package Salvation::TC::Parser::XS;

use strict;
use warnings;

BEGIN {

    require Salvation::TC::Parser;

    *Salvation::TC::Parser::XS::load_parameterizable_type_class =
        *Salvation::TC::Parser::load_parameterizable_type_class;
};

our $VERSION = 0.01;

require XSLoader;

XSLoader::load( 'Salvation::TC::Parser', $VERSION );

1;

__END__
