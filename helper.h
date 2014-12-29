#ifndef _HELPER_H_
#define _HELPER_H_

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "defs.h"

char * call_load_parameterizable_type_class( char * word );
AV * tokens_to_perl( my_stack_t * stack );
tokenizer_options_t * perl_to_options( HV * options );
AV * mortalize_av( AV * v );
void free_stack_arr( intptr_t * stack, int size );
void free_my_stack( my_stack_t * stack );
void p_die( char * s );

#endif /* end of include guard: _HELPER_H_ */
