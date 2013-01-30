
use strict;
use warnings;

use Test::More
    tests => 1
;

use CSS::Director qw( FixLeftAndRightInUrl );

my $input = 'background:url(right.png)';
my $output = 'background:url(left.png)';
my $result = FixLeftAndRightInUrl( $input );

is( $output, $result );

