# Copyright (C) 1997 Ashley Winters <jql@accessone.com>. All rights reserved.
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.

package Tie::Hash::Easy;

use strict;
use vars qw($VERSION);

$VERSION = '0.01';

sub new {
    my $class = shift;
    my $funcs = ref $_[0] eq "HASH" ? shift : {};
    my $hash = ref $_[0] eq "HASH" ? shift : {};

    tie(%{$hash}, $class, $funcs, @_);

    return $hash;
}

sub TIEHASH {
    my $class = shift;
    my $self = shift;

    $self = bless $self, $class;
    $$self{'hash'} = {} unless exists $$self{'hash'};
    &{$$self{'TIEHASH'}}($self, @_) if $self->validfunc('TIEHASH');

    return $self;
}

sub FETCH {
    my $self = shift;
    my $key = shift;

    return &{$$self{'FETCH'}}($self, $key) if $self->validfunc('FETCH');
    return $$self{'hash'}{$key};
}

sub STORE {
    my $self = shift;
    my $key = shift;
    my $value = shift;

    if($self->validfunc('STORE')) { &{$$self{'STORE'}}($self, $key, $value) }
    else { $$self{'hash'}{$key} = $value }
}

sub EXISTS {
    my $self = shift;
    my $key = shift;

    return ($self->validfunc('EXISTS') && &{$$self{'EXISTS'}}($self, $key)) ||
	exists $$self{'hash'}{$key};
}

sub DELETE {
    my $self = shift;
    my $key = shift;

    if($self->validfunc('DELETE')) { &{$$self{'DELETE'}}($self, $key) }
    else { delete $$self{'hash'}{$key} }
}

sub FIRSTKEY {
    my $self = shift;

    if($self->validfunc('KEYS')) {
	$$self{'keys'} = &{$$self{'KEYS'}}($self);
	if(ref $$self{'keys'} eq "ARRAY") {
	    return shift @{$$self{'keys'}} if scalar @{$$self{'keys'}};
	} else {
	    delete $$self{'keys'};
	}
    }

    return &{$$self{'FIRSTKEY'}}($self) if $self->validfunc('FIRSTKEY');
    my $key = scalar keys %{$$self{'hash'}};
    $key = (each %{$$self{'hash'}})[0];
    return $key;
}

sub NEXTKEY {
    my $self = shift;
    my $lastkey = shift;

    if($self->validfunc('KEYS')) {
	return shift @{$$self{'keys'}} if exists $$self{'keys'} &&
	    ref $$self{'keys'} eq "ARRAY";
	return undef;
    }
    return &{$$self{'NEXTKEY'}}($self, $lastkey) if
	$self->validfunc('NEXTKEY');
    return (each %{$$self{'hash'}})[0];
}

sub CLEAR {
    my $self = shift;

    if($self->validfunc('CLEAR')) { &{$$self{'CLEAR'}}($self) }
    else { %{$$self{'hash'}} = () }
}

sub DESTROY {
    my $self = shift;

    &{$$self{'DESTROY'}}($self) if $self->validfunc('DESTROY');
}

sub validfunc {
    my $self = shift;
    my $func = shift;

    return (exists $$self{$func} && ref $$self{$func} eq 'CODE');
}

1;
__END__

=head1 NAME

Tie::Hash::Easy - Perl module for the simple creation of tied hashes

=head1 SYNOPSIS

  use Tie::Hash::Easy;

  $hash_ref = new Tie::Hash::Easy([ $funcs, \%hash, ... ]);

=head1 DESCRIPTION

Tie::Hash::Easy is meant to provide a simple way to create a tied hash
without creating a new class, and to allow the simple overriding of the
access functions.

The new() function is a simple wrapper to tie(). It's just there for
convienience. It passes it's arguments to tie() without any processing.
A reference to the newly tied hash is returned. Both parameters are
optional.

The first argument should be a hash containing the names of the various
hash access functions to be overridden as the keys, and sub-refs to the
subroutines to override with as the values.

The second argument should be a HASH ref, and will be tied if passed.

Any other arguments will be passed on to the overridden TIEHASH(), if you
provide one.

=head1 GUTS

It can't hurt to know what's I<really> going on in this particular module.

TIEHASH() takes one argument, a hash reference that is to be blessed to
become the object. The argument is not checked to see what it's values
contain, which means you can store interesting stuff in it, which will
be kept intact in the object.

The default methods only access two keys in the object, hash and keys.
The I<hash> key contains a reference to the hash that is accessed by the
default access methods. The I<keys> key is used in the key iteration method
to store a list of keys returned by the KEYS() member, which will be explained
later.

Every default hash access function can be overridden by passing a hash
to new() which contains the function's name as a key, and a reference to
the function to be called when the action the function handles occurs.

Only one of the default hash access function prototypes changes when you
use it in in this class, and that is TIEHASH(). For the prototypes of the
other access functions, see L<perltie(1)>.

=over 4

=item TIEHASH this, LIST

When this is called, the object has already been created. Any arguments
not recognized by new() or the original TIEHASH() are passed as LIST.
The return-value from this function is irrelevant and discarded.

=back

Whenever I write a tied hash class, I find myself taking excessive time
attempting to write the FIRSTKEY() and NEXTKEY() functions. To save myself,
and some of you, alot of time and effort, I've come up with a new KEYS()
function.

=over 4

=item KEYS this

This function is a substitute for replacing FIRSTKEY() and NEXTKEY().
If it is defined, it must return an reference to an array containing
a list of the keys in the object. The list returned is modified. The
order of the keys is maintained through the calls to NEXTKEY().

=back

=head1 EXAMPLES

Well, I thought I should just toss out a long example of how this
class can go a long way towards simplifying the creation of tied hashes.

The following code will probably create an ordered hash.

	use Tie::Hash::Easy;

	$hash = new Tie::Hash::Easy {
	    STORE =>
		sub {
		    my($self, $key, $value) = @_;

		    push @{$$self{'order'}}, $key;
		    $$self{'hash'}{$key} = $value;
		},
	    DELETE =>
		sub {
		    my($self, $key) = @_;

		    delete $$self{'hash'}{$key};
		    my $i;
		    for($i = 0; $i < @{$$self{'order'}}; $i++) {
			splice @{$$self{'order'}}, $i, 1
			    if $$self{'order'}[$i] eq $key;
		    }
		},
	    KEYS =>
		sub {
		    my $self = shift;

		    return [ @{$$self{'order'}} ];
		}
	};


=head1 AUTHOR

Ashley Winters <jql@accessone.com>

=head1 SEE ALSO

perl(1), perltie(1), perlref(1).

=cut
