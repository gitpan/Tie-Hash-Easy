BEGIN { $| = 1; print "1..4\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Easy;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Easy;
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

undef $hash;

$hash = new Tie::Hash::Easy { TIEHASH => sub { ${$_[0]}{ran} = 3 } };

print "not " unless defined $hash && ref $hash eq "HASH" &&
    (tied %{$hash} || {})->{ran} == 3;
print "ok 3\n";

undef $hash;
$hash = {};

new Tie::Hash::Easy { TIEHASH => sub { ${$_[0]}{ran} = $_[1] } }, $hash, 3;
print "not " unless (tied %{$hash} || {})->{ran} == 3;
print "ok 4\n";
