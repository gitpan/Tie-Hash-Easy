BEGIN { $| = 1; print "1..8\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Easy;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Easy;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

%{$hash} = ('this' => 'that', 'foo' => 'bar');
$$hash{'key'} = 'value';

print "not " unless ($object = tied %{$hash}) && exists $$object{'hash'} &&
    ref ($$object{'hash'}) eq "HASH";
print "ok 3\n";

print "not " unless exists $$object{'hash'}{'this'} &&
    $$object{'hash'}{'this'} eq 'that' && exists $$object{'hash'}{'foo'} &&
    $$object{'hash'}{'foo'} eq 'bar' && exists $$object{'hash'}{'key'} &&
    $$object{'hash'}{'key'} eq 'value';
print "ok 4\n";

$ran = 0;
undef $hash;

$hash = new Tie::Hash::Easy { 'STORE' =>
    sub {
	my $self = shift;
	my $key = shift;
	my $value = shift;

	$$self{'hash'}{$key} = $value;
	$lastkey = $key;
	$lastvalue = $value;
	$ran++;
    }
};

print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 5\n";

%{$hash} = ('this' => 'that', 'foo' => 'bar');
$$hash{'key'} = 'value';

print "not " unless $ran == 3 && defined $lastkey && $lastkey eq 'key' &&
    defined $lastvalue && $lastvalue eq 'value';
print "ok 6\n";

print "not " unless ($object = tied %{$hash}) && exists $$object{'hash'} &&
    ref ($$object{'hash'}) eq "HASH";
print "ok 7\n";

print "not " unless $$object{'hash'}{'this'} eq 'that' &&
    exists $$object{'hash'}{'foo'} && $$object{'hash'}{'foo'} eq 'bar' &&
    exists $$object{'hash'}{'key'} && $$object{'hash'}{'key'} eq 'value';
print "ok 8\n";