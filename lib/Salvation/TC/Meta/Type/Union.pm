package Salvation::TC::Meta::Type::Union;

=head1 NAME

Salvation::TC::Meta::Type::Union - Класс для объединённых типов

=cut

use strict;
use warnings;
use boolean;

use base 'Salvation::TC::Meta::Type';

use Scalar::Util 'blessed';
use Error ':try';
use Salvation::TC::Exception::WrongType::TC ();

=head1 METHODS

=cut

=head2 new()

=cut

sub new {

    my ( $proto, %args ) = @_;

    die( 'Type union metaclass must have types list' ) unless( defined $args{ 'types' } );
    die( 'Types list must be an ArrayRef' ) if( ref( $args{ 'types' } ) ne 'ARRAY' );

    foreach ( @{ $args{ 'types' } } ) {

        unless( defined $_ && blessed $_ && $_ -> isa( 'Salvation::TC::Meta::Type' ) ) {

            die( 'Types list must be an ArrayRef[Salvation::TC::Meta::Type]' );
        }
    }

    $args{ 'validator' } = $proto -> build_validator( @args{ 'name', 'types' } );

    return $proto -> SUPER::new( %args );
}

=head2 types()

=cut

sub types {

    my ( $self ) = @_;

    return $self -> { 'types' };
}

=head2 build_validator( Str $name, ArrayRef[Salvation::TC::Meta::Type] $types )

=cut

sub build_validator {

    my ( $self, $name, $types ) = @_;

    return sub {

        my ( $value ) = @_;

        my @errors = ();

        foreach my $type ( @$types ) {

            my $check_passed = true;

            try {
                $type -> check( $value );

            } catch Salvation::TC::Exception::WrongType with {

                my ( $e ) = @_;

                push( @errors, Salvation::TC::Exception::WrongType::TC -> new(
                    type => $type -> name(), value => $value,
                    ( $e -> isa( 'Salvation::TC::Exception::WrongType::TC' ) ? (
                        prev => $e,
                    ) : () )
                ) );

                $check_passed = false;
            };

            return true if( $check_passed );
        }

        Salvation::TC::Exception::WrongType::TC -> throw(
            type => $name, value => $value, prev => \@errors,
        );
    };
}

=head2 coerce( Any $value )

=cut

sub coerce {

    my ( $self, $value ) = @_;

    foreach my $type ( @{ $self -> types() } ) {

        my $type_matches = true;

        try {
            my $new_value = $type -> coerce( $value );

            $type -> check( $new_value ); # true или die

            $value = $new_value;

        } catch Salvation::TC::Exception::WrongType with {

            $type_matches = false;
        };

        last if( $type_matches );
    }

    return $value; # Moose возвращает либо старое, либо приведённое значение
}


1;

__END__
