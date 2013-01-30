
use strict;
use warnings;

use Test::More
    tests => 1
;

use CSS::Orientation qw( FixFourPartNotation );

my $input = 'padding: 1px 2px 3px 4px';
my $output = 'padding: 1px 4px 3px 2px';
my $result = FixFourPartNotation( $input );

is( $output, $result );

