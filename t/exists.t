BEGIN { $| = 1; print "1..5\n" }
END { print "not ok 1\n" unless defined $loaded }

use Tie::Hash::Easy;
$loaded = 1;
print "ok 1\n";

$hash = new Tie::Hash::Easy { 'hash' => { 'key' => 'value', 'foo' => 'bar' } };
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 2\n";

print "not " unless exists $$hash{'key'} && exists $$hash{'foo'} &&
    !exists $$hash{'bar'} && !exists $$hash{"doesn't exist"};
print "ok 3\n";

undef $hash;

$hash = new Tie::Hash::Easy { 'EXISTS' =>
    sub {
	my $self = shift;
	my $key = shift;

	return 0 if $key eq 'undef';
	$$self{'hash'}{$key} = undef unless exists $$self{'hash'}{$key};
	return 1;
    }
};
print "not " unless defined $hash && ref $hash eq "HASH" && tied %{$hash};
print "ok 4\n";

print "not " unless exists $$hash{'key'} && exists $$hash{'foo'} &&
    !exists $$hash{'undef'} && exists $$hash{'exists'};
print "ok 5\n";
