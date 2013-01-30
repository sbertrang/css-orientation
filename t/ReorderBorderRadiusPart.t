
use strict;
use warnings;

use Test::More
    tests => 1
;

use CSS::Director qw( );

my @input = qw[ 1px 2px 3px 4px ];
my $output = '2px 1px 4px 3px';
my $result = CSS::Director::ReorderBorderRadiusPart( @input );

is( $result, $output );

