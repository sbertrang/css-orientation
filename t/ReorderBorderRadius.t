
use strict;
use warnings;

use Test::More
    tests => 1
;

use CSS::Director qw( );

my @input = ( '', ': ', '1px', '2px', '3px', '4px', '5px', '6px', undef, '7px' );
my $output = 'border-radius: 2px 1px 4px 3px / 6px 5px 6px 7px';
my $result = CSS::Director::ReorderBorderRadius( @input );

is( $result, $output );

