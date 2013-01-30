
use strict;
use warnings;

use Test::More
    tests => 1
;

use CSS::Director qw( FixLtrAndRtlInUrl );

my $input = 'background:url(rtl.png)';
my $output = 'background:url(ltr.png)';
my $result = FixLtrAndRtlInUrl( $input );

is( $output, $result );

