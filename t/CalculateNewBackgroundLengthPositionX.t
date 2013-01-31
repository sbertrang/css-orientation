
use strict;
use warnings;

use Test::More
    tests => 4
;

use CSS::Orientation;

my @input = ( 'background-position-x: 1', ': ', '1' );
my $output = undef;
my $result = CSS::Orientation::CalculateNewBackgroundLengthPositionX( @input[ 0 .. 2 ], 0 );
is( $result, $output, 'CalculateNewBackgroundLengthPositionX: fail hard instead and return nothing' );

@input = ( 'background-position-x: 2', ': ', '2' );
$output = 'background-position-x: 2';
$result = CSS::Orientation::CalculateNewBackgroundLengthPositionX( @input[ 0 .. 2 ], 1 );
is( $result, $output, 'CalculateNewBackgroundLengthPositionX: fail soft and ignore the problem by returning the source' );

# same via FixBackgroundPosition()
my $input = 'background-position-x: 2px';
$output = undef;
$result = CSS::Orientation::FixBackgroundPosition( $input, 0 );

is( $result, $output, 'FixBackgroundPosition: fail hard and return undef' );

# same via FixBackgroundPosition()
$output = $input;
$result = CSS::Orientation::FixBackgroundPosition( $input, 1 );

is( $result, $output, 'FixBackgroundPosition: fail soft and ignore the problem by returning the source' );

