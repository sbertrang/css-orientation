
use strict;
use warnings;

use Test::More
    tests => 1
;

use CSS::Orientation qw( FixCursorProperties );

my $input = 'cursor: ne-resize';
my $output = 'cursor: nw-resize';
my $result = FixCursorProperties( $input );

is( $output, $result );

