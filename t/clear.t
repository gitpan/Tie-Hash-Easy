BEGIN { $| = 1; print "1..8\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Easy;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Easy { 'hash' => { 'key' => 'value', 'foo' => 'bar' } };
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

print "not " unless $$hash{'key'} eq 'value' && $$hash{'foo'} eq 'bar';
print "ok 3\n";

%{$hash} = ();

print "not " unless ($object = tied %{$hash}) && exists $$object{'hash'} &&
    ref ($$object{'hash'}) eq "HASH";
print "ok 4\n";

print "not " unless scalar keys %{$$object{'hash'}} == 0;
print "ok 5\n";

undef $object;
undef $hash;

$hash = new Tie::Hash::Easy { CLEAR => sub {}, 'hash' => { 'foo' => 'bar' } };
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 6\n";

%{$hash} = ();

print "not " unless ($object = tied %{$hash}) && exists $$object{'hash'} &&
    ref ($$object{'hash'}) eq "HASH";
print "ok 7\n";

print "not " unless scalar keys %{$$object{'hash'}} == 1;
print "ok 8\n";
