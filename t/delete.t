BEGIN { $| = 1; print "1..8\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Easy;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Easy { 'hash' => { 'key' => 'value', 'foo' => 'bar' } };
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

delete $$hash{'key'};

print "not " unless ($object = tied %{$hash}) && exists $$object{'hash'} &&
    ref ($$object{'hash'}) eq "HASH";
print "ok 3\n";

print "not " unless !exists $$object{'hash'}{'key'} &&
    exists $$object{'hash'}{'foo'};
print "ok 4\n";

delete $$hash{'foo'};

print "not " unless !exists $$object{'hash'}{'key'} &&
    !exists $$object{'hash'}{'foo'};
print "ok 5\n";

undef $hash;

$hash = new Tie::Hash::Easy { DELETE =>
    sub {
	my $self = shift;
	my $key = shift;

	push @{$$self{'deleted'}}, $key;
	delete $$self{$key};
    }, 'foo' => 'bar', 'good' => 'stuff', 'windows' => 'intel'
};
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 6\n";

delete $$hash{"foo"};
delete $$hash{"windows"};

print "not " unless ($object = tied %{$hash}) && exists $$object{'hash'} &&
    ref ($$object{'hash'}) eq "HASH";
print "ok 7\n";

print "not " unless exists $$object{'deleted'} &&
    ref $$object{'deleted'} eq "ARRAY" && @{$$object{'deleted'}} eq 2 &&
    $$object{'deleted'}[0] eq 'foo' && $$object{'deleted'}[1] eq 'windows';
print "ok 8\n";
