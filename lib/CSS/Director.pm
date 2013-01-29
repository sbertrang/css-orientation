package CSS::Director;

use strict;
use warnings;

our %EXPORT_TAGS = ( 'all' => [qw[
	
]] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our $VERSION = '0.01';


1;

__END__

=head1 NAME

CSS::Director - Perl extension to change direction of CSS files

=head1 SYNOPSIS

  use CSS::Director;
  ...

=head1 DESCRIPTION

=head2 EXPORT

None by default.


=head1 SEE ALSO

=head1 AUTHOR

Simon Bertrang, E<lt>janus@errornet.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Simon Bertrang

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
