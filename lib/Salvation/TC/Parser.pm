package Salvation::TC::Parser;

use strict;
use warnings;

use Module::Load ();
use Class::Inspector ();

our $VERSION = 0.01;
our $BACKEND;

{
    my $loaded;

    sub detect {

        load_backend();
        return $BACKEND if defined $BACKEND;

        if( eval { require Salvation::TC::Parser::XS; 1 } ) {

            $BACKEND = 'Salvation::TC::Parser::XS';
            $loaded = 1;

        } else {

            $BACKEND = 'Salvation::TC::Parser::PP';
        }

        load_backend();
        return $BACKEND;
    }

    sub load_backend {

        return unless defined $BACKEND;

        unless( $loaded ) {

            $loaded = 1;

            Module::Load::load( $BACKEND );
        }

        return;
    }
}

{
    my $code;

    sub tokenize_type_str {

        shift;
        goto $code if defined $code;

        detect();
        my $name = "${BACKEND}::tokenize_type_str_impl";

        no strict 'refs';

        goto $code = *$name{ 'CODE' };
    }
}

{
    my $code;

    sub tokenize_signature_str {

        shift;
        goto $code if defined $code;

        detect();
        my $name = "${BACKEND}::tokenize_signature_str_impl";

        no strict 'refs';

        goto $code = *$name{ 'CODE' };
    }
}

{
    my $re = qr/^Salvation::TC::Type::(.+?)$/;

    sub load_parametrizable_type_class {

        my ( $word ) = @_;

        my $class = "Salvation::TC::Meta::Type::Parametrized::${word}";
        my $parametrizable_type = '';

        if(
            Class::Inspector -> loaded( $class )
            || eval{ Module::Load::load( $class ); 1 }
        ) {

            $parametrizable_type = $class;

        } elsif( $word =~ $re ) {

            $class = "Salvation::TC::Meta::Type::Parametrized::$1";

            if(
                Class::Inspector -> loaded( $class )
                || eval{ Module::Load::load( $class ); 1 }
            ) {

                $parametrizable_type = $class;
            }
        }

        return $parametrizable_type;
    }
}

1;

__END__
