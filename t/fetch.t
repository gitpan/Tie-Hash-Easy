BEGIN { $| = 1; print "1..5\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Easy;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Easy { 'hash' => { 'key' => 'value' } };
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

print "not " unless $$hash{'key'} eq 'value' && $$hash{'key'} eq 'value';
print "ok 3\n";

undef $hash;

$hash = new Tie::Hash::Easy { 'FETCH' => sub { return $_[1] } };
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 4\n";

print "not " unless $$hash{'foo'} eq 'foo' && $$hash{'bar'} eq 'bar';
print "ok 5\n";