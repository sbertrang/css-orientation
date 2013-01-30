
use strict;
use warnings;

use Test::More
    tests => 1
;

use CSS::Director qw( FixBodyDirectionLtrAndRtl );

my $input = 'body { direction:ltr }';
my $output = 'body { direction:rtl }';
my $result = FixBodyDirectionLtrAndRtl( $input );

is( $output, $result );

