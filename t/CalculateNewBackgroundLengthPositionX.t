
use strict;
use warnings;

use Test::More
    tests => 2
;

use CSS::Orientation;

my @input = ( 'background-position-x: 1', ': ', '1' );
my $output = undef;
my $result = CSS::Orientation::CalculateNewBackgroundLengthPositionX( @input[ 0 .. 2 ], 0 );

is( $result, $output, 'fail hard instead of ignoring the problem and return nothing' );

@input = ( 'background-position-x: 2', ': ', '2' );
$output = 'background-position-x: 2';
$result = CSS::Orientation::CalculateNewBackgroundLengthPositionX( @input[ 0 .. 2 ], 1 );

is( $result, $output, 'fail soft and ignore the problem by returning the source' );

