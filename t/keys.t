BEGIN { $| = 1; print "1..13\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Easy;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Easy { 'hash' => { 'this' => 'that', 'foo' => 'bar',
					'stop' => 'it', 'key' => 'value' } };
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

@keys = sort keys %{$hash};

print "not " unless @keys eq 4 && $keys[0] eq 'foo' && $keys[1] eq 'key' &&
    $keys[2] eq 'stop' && $keys[3] eq 'this';
print "ok 3\n";

@keys = sort keys %{$hash};
print "not " unless @keys eq 4 && $keys[0] eq 'foo' && $keys[1] eq 'key' &&
    $keys[2] eq 'stop' && $keys[3] eq 'this';
print "ok 4\n";

print "not " unless ($object = tied %{$hash}) && exists $$object{'hash'} &&
    ref ($$object{'hash'}) eq "HASH";
print "ok 5\n";

print "not " unless exists $$object{'hash'}{'this'} &&
    $$object{'hash'}{'this'} eq 'that' && exists $$object{'hash'}{'foo'} &&
    $$object{'hash'}{'foo'} eq 'bar' && exists $$object{'hash'}{'stop'} &&
    $$object{'hash'}{'stop'} eq 'it' && exists $$object{'hash'}{'key'} &&
    $$object{'hash'}{'key'} eq 'value';
print "ok 6\n";

$count = 0;
@keys = ();
$failed = 0;

while(@_ = each %{$hash}) {
    if(exists $$object{'hash'}{$_[0]} && $_[1] eq $$object{'hash'}{$_[0]} &&
       !grep { $_ eq $_[0] } @keys) {
	$count++;
	push @keys, $_[0];
    } else { $failed++ }
}
$failed++ unless $count eq 4;
print "not " if $failed;
print "ok 7\n";

$count = 0;
@keys = ();
$failed = 0;

while(@_ = each %{$hash}) {
    if(exists $$object{'hash'}{$_[0]} && $_[1] eq $$object{'hash'}{$_[0]} &&
       !grep { $_ eq $_[0] } @keys) {
        $count++;
        push @keys, $_[0];
    } else { $failed++ }
}
$failed++ unless $count eq 4;
print "not " if $failed;
print "ok 8\n";

undef $hash;

@thekeys = ('foo', 'bar', 'baz', 'bix', 'boo');

$hash = new Tie::Hash::Easy {
    FIRSTKEY =>
	sub {
	    my $self = shift;
	    $$self{'keys'} = [ @thekeys ];
	    return shift @{$$self{'keys'}};
        },
    NEXTKEY => sub { my $self = shift; return shift @{$$self{'keys'}} }
};
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 9\n";

@keys = keys %{$hash};

if(@keys eq @thekeys) {
    for($i = 0; $i < @keys; $i++) { last unless $keys[$i] eq $thekeys[$i] }
    print "not " unless $i eq @keys;
} else { print "not " }
print "ok 10\n";

@keys = keys %{$hash};

if(@keys eq @thekeys) {
    for($i = 0; $i < @keys; $i++) { last unless $keys[$i] eq $thekeys[$i] }
    print "not " unless $i eq @keys;
} else { print "not " }
print "ok 11\n";

undef $hash;

$hash = new Tie::Hash::Easy { KEYS => sub { return [ @thekeys ] } };

@keys = keys %{$hash};

if(@keys eq @thekeys) {
    for($i = 0; $i < @keys; $i++) { last unless $keys[$i] eq $thekeys[$i] }
    print "not " unless $i eq @keys;
} else { print "not " }
print "ok 12\n";

@keys = keys %{$hash};

if(@keys eq @thekeys) {
    for($i = 0; $i < @keys; $i++) { last unless $keys[$i] eq $thekeys[$i] }
    print "not " unless $i eq @keys;
} else { print "not " }
print "ok 13\n";
