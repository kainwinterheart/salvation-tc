#ifndef _TOKENIZER_C_
#define _TOKENIZER_C_

#include "tokenizer.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

static inline void push_stack( intptr_t ** stack, int length, intptr_t token ) {

    if( length > 0 ) *stack = realloc( *stack, ( length + 1 ) * sizeof( intptr_t ) );

    (*stack)[ length ] = token;
}

static inline char * append( char * s, char c ) {

    int len = strlen( s );
    char buf[ len + 2 ];

    strcpy( buf, s );

    buf[ len ] = c;
    buf[ len + 1 ] = '\0';

    free( s );

    return strdup( buf );
}

static inline char * copy_str( char * s ) {

    int len = strlen( s );
    char buf[ len ];

    strcpy( buf, s );

    return strdup( buf );
}

static inline short is_space( char chr ) {

    return ( ( ( chr == ' ' ) || ( chr == '\n' ) || ( chr == '\r' ) || ( chr == '\t' ) ) ? 1 : 0 );
}

static inline short is_delim( char chr ) {

    return ( ( chr == ',' ) ? 1 : 0 );
}

static inline short is_digit( char chr ) {

    return ( (
        ( chr == '1' ) || ( chr == '2' ) || ( chr == '3' ) || ( chr == '4' )
        || ( chr == '5' ) || ( chr == '6' ) || ( chr == '7' ) || ( chr == '8' )
        || ( chr == '9' ) || ( chr == '0' )
    ) ? 1 : 0 );
}

static my_stack_t * tokenize_signature_str( const char * s, tokenizer_options_t * options );

static inline char * zero_str() {

    char * word = malloc( 1 );

    word[ 0 ] = '\0';

    return word;
}

static my_stack_t * tokenize_type_str( const char * s, tokenizer_options_t * options ) {

    intptr_t * stack = malloc( sizeof( *stack ) );
    char * word = zero_str();
    char * parametrizable_type = zero_str();
    int stack_size = 0;
    int pos = 0;
    int length = strlen( s );

    while( pos < length ) {

        char chr = s[ pos ++ ];

        if( is_space( chr ) ) continue;

        if( ( chr == '[' ) && ( strcmp( word, "Maybe\0" ) != 0 ) ) {

            if( options -> loose != 0 ) {

                parametrizable_type = copy_str( word );

            } else {

                parametrizable_type = call_load_parametrizable_type_class( word );

                if( strlen( parametrizable_type ) == 0 ) {

                    free_stack_arr( stack, stack_size );
                    char * _s;
                    sprintf( _s, "Can't parametrize type %s\n", word );
                    p_die( _s );
                }
            }
        }

        if( chr == '|' ) {

            if( strlen( word ) == 0 ) {

                if( stack_size == 0 ) {

                    free_stack_arr( stack, stack_size );
                    p_die( "Invalid type string: | can't be a first character of type name\n" );

                } else {

                    abstract_type_t * token = (abstract_type_t*)(stack[ stack_size - 1 ]);
                    short token_type = token -> token_type;

                    if( !(
                        ( token_type == TOKEN_TYPE_MAYBE )
                        || ( token_type == TOKEN_TYPE_PARAMETRIZABLE )
                        || ( token_type == TOKEN_TYPE_SIGNED )
                        || ( token_type == TOKEN_TYPE_LENGTH )
                    ) ) {

                        free_stack_arr( stack, stack_size );
                        p_die( "Invalid type string: | should follow a type name\n" );
                    }
                }

            } else {

                basic_type_t * token = malloc( sizeof( *token ) );

                token -> base.token_type = TOKEN_TYPE_BASIC;
                token -> type = copy_str( word );

                push_stack( &stack, stack_size, (intptr_t)token );
                ++stack_size;

                free( word );
                word = zero_str();
            }

        } else if( chr == '[' ) {

            int cnt = 1;
            char * substr = zero_str();

            while( pos < length ) {

                char subchr = s[ pos ++ ];

                if( subchr == '[' ) ++cnt;
                if( subchr == ']' ) --cnt;

                if( cnt == 0 ) break;

                substr = append( substr, subchr );
            }

            if( ( strlen( substr ) == 0 ) || ( strlen( word ) == 0 ) ) {

                free_stack_arr( stack, stack_size );
                p_die( "Invalid type parametrization: no type name or no parameter name\n" );
            }

            if( strlen( parametrizable_type ) == 0 ) {

                maybe_type_t * token = malloc( sizeof( *token ) );

                token -> base.token_type = TOKEN_TYPE_MAYBE;

                my_stack_t * _stack = tokenize_type_str( substr, options );
                if( _stack == 0 ) return 0;
                token -> stack = _stack;

                push_stack( &stack, stack_size, (intptr_t)token );
                ++stack_size;

            } else {

                parametrizable_type_t * token = malloc( sizeof( *token ) );

                token -> base.token_type = TOKEN_TYPE_PARAMETRIZABLE;
                token -> class = copy_str( parametrizable_type );

                my_stack_t * _param = tokenize_type_str( substr, options );;
                if( _param == 0 ) return 0;
                token -> param = _param;

                my_stack_t * _stack = tokenize_type_str( word, options );
                if( _stack == 0 ) return 0;
                token -> stack = _stack;

                push_stack( &stack, stack_size, (intptr_t)token );
                ++stack_size;

                free( parametrizable_type );
                parametrizable_type = zero_str();
            }

            free( word );
            word = zero_str();
            free( substr );

        } else if( chr == '(' ) {

            if( strlen( word ) == 0 ) {

                if( stack_size == 0 ) {

                    free_stack_arr( stack, stack_size );
                    p_die( "Invalid type description: ( can't be a first character of type name\n" );

                } else {

                    abstract_type_t * token = (abstract_type_t*)(stack[ stack_size - 1 ]);
                    short token_type = token -> token_type;

                    if( !(
                        ( token_type == TOKEN_TYPE_PARAMETRIZABLE )
                    ) ) {

                        free_stack_arr( stack, stack_size );
                        p_die( "Invalid type description: ( should follow a type name\n" );
                    }
                }

            } else {

                basic_type_t * token = malloc( sizeof( *token ) );

                token -> base.token_type = TOKEN_TYPE_BASIC;
                token -> type = copy_str( word );

                push_stack( &stack, stack_size, (intptr_t)token );
                ++stack_size;

                free( word );
                word = zero_str();
            }

            int cnt = 1;
            char * substr = zero_str();

            substr = append( substr, chr );

            while( pos < length ) {

                char subchr = s[ pos ++ ];

                if( subchr == '(' ) ++cnt;
                if( subchr == ')' ) --cnt;

                substr = append( substr, subchr );

                if( cnt == 0 ) break;
            }

            signed_type_t * token = malloc( sizeof( *token ) );

            token -> base.token_type = TOKEN_TYPE_SIGNED;

            my_stack_t * signature = tokenize_signature_str( substr, options );
            if( signature == 0 ) return 0;
            token -> signature = signature;

            token -> type = stack[ stack_size - 1 ];
            token -> source = copy_str( substr );

            stack[ stack_size - 1 ] = (intptr_t)token;
            free( substr );

        } else if( chr == '{' ) {

            if( strlen( word ) != 0 ) {

                basic_type_t * token = malloc( sizeof( *token ) );

                token -> base.token_type = TOKEN_TYPE_BASIC;
                token -> type = copy_str( word );

                push_stack( &stack, stack_size, (intptr_t)token );
                ++stack_size;

                free( word );
                word = zero_str();
            }

            short has_min = 0;
            short has_max = 0;
            short got_delim = 0;

            char * min = zero_str();
            char * max = zero_str();

            while( pos < length ) {

                char subchr = s[ pos ++ ];

                if( subchr == '}' ) break;
                if( is_space( subchr ) ) continue;

                if( is_delim( subchr ) ) {

                    if( got_delim == 1 ) {

                        free_stack_arr( stack, stack_size );
                        p_die( "Invalid length limits: only one delimiter allowed\n" );
                    }

                    got_delim = 1;
                    continue;
                }

                if( is_digit( subchr ) ) {

                    if( got_delim == 0 ) {

                        min = append( min, subchr );
                        has_min = 1;

                    } else {

                        max = append( max, subchr );
                        has_max = 1;
                    }

                } else {

                    free_stack_arr( stack, stack_size );
                    p_die( "Invalid length limits: only digits allowed\n" );
                }
            }

            if( has_min == 0 ) {

                free_stack_arr( stack, stack_size );
                p_die( "Invalid length limits: lower limit is required\n" );
            }

            if( ( has_max == 0 ) && ( got_delim == 0 ) ) {

                free( max );
                max = copy_str( min );
                has_max = 1;
            }

            length_type_t * token = malloc( sizeof( *token ) );

            token -> base.token_type = TOKEN_TYPE_LENGTH;
            token -> has_min = has_min;
            token -> has_max = has_max;
            if( has_min == 1 ) token -> min = copy_str( min );
            if( has_max == 1 ) token -> max = copy_str( max );
            token -> type = stack[ stack_size - 1 ];

            stack[ stack_size - 1 ] = (intptr_t)token;

            free( min );
            free( max );

        } else {

            word = append( word, chr );
        }
    }

    if( strlen( word ) != 0 ) {

        basic_type_t * token = malloc( sizeof( *token ) );

        token -> base.token_type = TOKEN_TYPE_BASIC;
        token -> type = word;

        push_stack( &stack, stack_size, (intptr_t)token );
        ++stack_size;

    } else {

        free( word );
    }

    free( parametrizable_type );

    my_stack_t * out = malloc( sizeof( *out ) );

    out -> size = stack_size;
    out -> data = stack;

    return out;
}

typedef struct {

    int circle;
    int inner_curly;
    int inner_circle;
    int inner_square;

} brackets_state_t;

static inline void update_brackets_state( brackets_state_t * bs, char chr ) {

    if( chr == '(' ) if( ++(bs -> circle) > 1 ) ++(bs -> inner_circle);
    if( chr == '[' ) ++(bs -> inner_square);
    if( chr == '{' ) ++(bs -> inner_curly);

    if( chr == ')' ) if( --(bs -> circle) > 0 ) --(bs -> inner_circle);
    if( chr == ']' ) --(bs -> inner_square);
    if( chr == '}' ) --(bs -> inner_curly);
}

static inline short has_open_inner_brackets( brackets_state_t * bs ) {

    return ( (
        ( bs -> inner_curly == 0 )
        && ( bs -> inner_circle == 0 )
        && ( bs -> inner_square == 0 )
    ) ? 0 : 1 );
}

static inline signature_param_t * tokenize_signature_parameter_str( const char * s, tokenizer_options_t * options );

static my_stack_t * tokenize_signature_str( const char * s, tokenizer_options_t * options ) {

    intptr_t * stack = malloc( sizeof( *stack ) );
    int stack_size = 0;
    int pos = 0;
    int length = strlen( s );

    char * type = zero_str();
    char * name = zero_str();

    brackets_state_t brackets_state = {
        .circle = 0,
        .inner_curly = 0,
        .inner_circle = 0,
        .inner_square = 0
    };

    short seq = SIG_SEQ_MIN;

    while( pos < length ) {

        if( seq == SIG_SEQ_ITEM_TYPE ) {

            while( pos < length ) {

                char chr = s[ pos ++ ];

                if( brackets_state.circle == 0 ) {

                    if( is_space( chr ) ) continue;
                }

                update_brackets_state( &brackets_state, chr );

                if( brackets_state.circle == 0 ) {

                    if( stack_size > 0 ) {

                        break;

                    } else {

                        free_stack_arr( stack, stack_size );
                        char * _s;
                        sprintf( _s, "Invalid signature: %s\n", s );
                        p_die( _s );
                    }
                }

                if(
                    ( chr == '(' )
                    && ( brackets_state.inner_circle == 0 )
                    && ( brackets_state.circle == 1 )
                ) {
                    while( pos < length ) {

                        char subchr = s[ pos ++ ];

                        if( !( is_space( subchr ) || is_delim( subchr ) ) ) {

                            --pos;
                            break;
                        }
                    }

                    continue;
                }

                if(
                    ( is_space( chr ) || is_delim( chr ) )
                    && ! has_open_inner_brackets( &brackets_state )
                ) {
                    while( pos < length ) {

                        char subchr = s[ pos ++ ];

                        if( !( is_space( subchr ) || is_delim( subchr ) ) ) {

                            --pos;
                            break;
                        }
                    }

                    break;
                }

                type = append( type, chr );
            }

            if( strlen( type ) == 0 ) {

                free_stack_arr( stack, stack_size );
                char * _s;
                sprintf( _s, "Invalid type string in signature: %s\n", s );
                p_die( _s );
            }

        } else if( seq == SIG_SEQ_ITEM_NAME ) {

            while( pos < length ) {

                char chr = s[ pos ++ ];

                update_brackets_state( &brackets_state, chr );

                if( is_space( chr ) || is_delim( chr ) ) {

                    while( pos < length ) {

                        char subchr = s[ pos ++ ];

                        if( !( is_space( subchr ) || is_delim( subchr ) ) ) {

                            --pos;
                            break;
                        }
                    }

                    break;
                }

                name = append( name, chr );
            }

            if( strlen( name ) == 0 ) {

                free_stack_arr( stack, stack_size );
                char * _s;
                sprintf( _s, "Invalid parameter name in signature: %s\n", s );
                p_die( _s );
            }

        } else if( seq == SIG_SEQ_ITEM_DELIM ) {

            if( ( strlen( type ) == 0 ) || ( strlen( name ) == 0 ) ) {

                free_stack_arr( stack, stack_size );
                char * _s;
                sprintf( _s, "Type or parameter name missing in signature: %s\n", s );
                p_die( _s );
            }

            signature_item_t * token = malloc( sizeof( *token ) );

            token -> base.token_type = TOKEN_TYPE_SIGNATURE_ITEM;

            my_stack_t * _type = tokenize_type_str( type, options );
            if( _type == 0 ) return 0;
            token -> type = _type;

            signature_param_t * _param = tokenize_signature_parameter_str( name, options );
            if( _param == 0 ) return 0;
            token -> param = _param;

            push_stack( &stack, stack_size, (intptr_t)token );
            ++stack_size;

            // free( type );
            free( name );
            // type = zero_str();
            name = zero_str();
        }

        if( ++seq > SIG_SEQ_MAX ) seq = SIG_SEQ_MIN;
    }

    if( ( brackets_state.circle != 0 ) || has_open_inner_brackets( &brackets_state ) ) {

        free_stack_arr( stack, stack_size );
        char * _s;
        sprintf( _s, "Unexpected end of input in signature: %s\n", s );
        p_die( _s );
    }

    // free( type );
    free( name );

    my_stack_t * out = malloc( sizeof( *out ) );

    out -> size = stack_size;
    out -> data = stack;

    return out;
}

static inline signature_param_t * tokenize_signature_parameter_str( const char * _s, tokenizer_options_t * options ) {

    char * s = copy_str( (char*)_s );
    signature_param_t * token = malloc( sizeof( *token ) );

    char first_char = s[ 0 ];

    if( first_char == ':' ) {

        token -> named = 1;
        token -> positional = 0;

        int len = strlen( s ) - 1;
        char * ns = malloc( len + 1 );

        for( int i = 0; i < len; ++i ) {

            ns[ i ] = s[ i + 1 ];
        }

        ns[ len ] = '\0';

        free( s );
        s = ns;

    } else {

        token -> named = 0;
        token -> positional = 1;
    }

    char last_char = s[ strlen( s ) - 1 ];

    if( last_char == '!' ) {

        token -> required = 1;
        token -> optional = 0;

        s[ strlen( s ) - 1 ] = '\0';

    } else if( last_char == '?' ) {

        token -> required = 0;
        token -> optional = 1;

        s[ strlen( s ) - 1 ] = '\0';

    } else if( token -> positional == 1 ) {

        token -> required = 1;
        token -> optional = 0;

    } else if( token -> named == 1 ) {

        token -> required = 0;
        token -> optional = 1;
    }

    token -> name = s;

    return token;
}

AV * perl_tokenize_type_str( const char * s, HV * options ) {

    my_stack_t * stack = tokenize_type_str( s, perl_to_options( options ) );

    AV * out = mortalize_av( tokens_to_perl( stack ) );

    if( stack != 0 ) free_my_stack( stack );

    return out;
}

AV * perl_tokenize_signature_str( const char * s, HV * options ) {

    my_stack_t * stack = tokenize_signature_str( s, perl_to_options( options ) );

    AV * out = mortalize_av( tokens_to_perl( stack ) );

    if( stack != 0 ) free_my_stack( stack );

    return out;
}

#endif /* end of include guard: _TOKENIZER_C_ */
