
use strict;
use warnings;

use Test::More
    tests => 1
;

use CSS::Orientation qw( FixLeftAndRightInUrl );

my $input = 'background:url(right.png)';
my $output = 'background:url(left.png)';
my $result = FixLeftAndRightInUrl( $input );

is( $output, $result );

