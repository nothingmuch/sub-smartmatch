#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'Sub::SmartMatch';

multi "fact", [ 0 ], sub { 1 };

multi "fact", sub () { 1 }, sub {
	my $n = shift;
	return $n * fact($n - 1);
};

is(fact(0), 1, "factorial of 0");
is(fact(1), 1, "factorial of 1");
is(fact(2), 2, "factorial of 2");
is(fact(3), 6, "factorial of 6");


def_multi other_fact => (
	[0] => sub { 1 },
	default => sub {
		my $n = shift;
		return $n * other_fact($n-1);
	},
);

is( other_fact(5), 120, "multi_default" );

def_multi foo => (
	exactly [0] => sub { "all args" },
	[0]         => sub { "first arg" },
	default     => sub { "default" },
);

is( foo(0),    "all args",  "exactly matches" );
is( foo(0, 1), "first arg", "matches slice" );
is( foo(1),    "default",   "matches default" );

SKIP: {
	skip "No SmartMatch::Sugar", 5 unless eval { require SmartMatch::Sugar };

	{
		package Foo;

		SmartMatch::Sugar->import(qw(object class));

		use Sub::SmartMatch;

		multi is_object => [ object() ] => sub { 1 };
		multi is_object => [ class()  ]  => sub { 0 };
	}

	my $foo = bless {}, "Foo";

	ok( $foo->is_object, "object is an object" );
	ok( $foo->is_object(qw(blah blah blah)), "object is an object even with superflous args" );
	ok( not(Foo->is_object), "the class is not an object though" );

	eval { Foo::is_object() };
	my $e = $@;
	ok( $e, "got an error from calling with no args" );
	like( $e, qr/no variant found/i, "no variant found error" );
}

