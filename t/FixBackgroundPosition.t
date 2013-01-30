
use strict;
use warnings;

use Test::More
    tests => 8
;

use CSS::Director qw( FixBackgroundPosition );

is( FixBackgroundPosition( "background-position: 0px 10px" ), "background-position: 100% 10px" );
is( FixBackgroundPosition( "background-position-x: 0" ), "background-position-x: 100%" );
is( FixBackgroundPosition( "background-position: 100% 40%" ), "background-position: 0% 40%" );
is( FixBackgroundPosition( "background-position: 0% 40%" ), "background-position: 100% 40%" );
is( FixBackgroundPosition( "background-position: 23% 0" ), "background-position: 77% 0" );
is( FixBackgroundPosition( "background-position: 23% auto" ), "background-position: 77% auto" );
is( FixBackgroundPosition( "background-position-x: 23%" ), "background-position-x: 77%" );
is( FixBackgroundPosition( "background-position-y: 23%" ), "background-position-y: 23%" );

