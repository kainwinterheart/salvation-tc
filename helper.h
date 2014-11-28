#ifndef _HELPER_H_
#define _HELPER_H_

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "defs.h"

char * call_load_parametrizable_type_class( char * word );
AV * tokens_to_perl( my_stack_t * stack );
static inline void hash_set_sv( HV * hash, char * key, SV * value );
static inline void hash_set_str( HV * hash, char * key, char * value );
static inline void hash_set_short( HV * hash, char * key, short value );
static HV * token_to_perl( intptr_t token );
static inline SV ** hash_get( HV * hash, char * key );
tokenizer_options_t * perl_to_options( HV * options );
AV * mortalize_av( AV * v );

#endif /* end of include guard: _HELPER_H_ */
