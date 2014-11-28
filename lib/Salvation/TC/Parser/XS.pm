package Salvation::TC::Parser::XS;

use strict;
use warnings;

BEGIN {

    require Salvation::TC::Parser;

    *Salvation::TC::Parser::XS::load_parametrizable_type_class =
        *Salvation::TC::Parser::load_parametrizable_type_class;
};

our $VERSION = 0.01;

1;

__END__
