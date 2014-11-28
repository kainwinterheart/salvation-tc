#include "tokenizer.h"

MODULE = Salvation::TC::Parser PACKAGE = Salvation::TC::Parser::XS

PROTOTYPES: DISABLED

AV*
tokenize_type_str_impl( str, options )
        char * str
        HV * options
    CODE:
        RETVAL = perl_tokenize_type_str( str, options );

    OUTPUT:
        RETVAL

AV*
tokenize_signature_str_impl( str, options )
        char * str
        HV * options
    CODE:
        RETVAL = perl_tokenize_signature_str( str, options );

    OUTPUT:
        RETVAL
