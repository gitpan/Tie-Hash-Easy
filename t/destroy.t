BEGIN { $| = 1; print "1..4\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Easy;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Easy { 'DESTROY' => sub { print "ok 3\n" } };
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";
$hash = new Tie::Hash::Easy { 'DESTROY' => sub { print "ok 4\n" } };
undef $hash;