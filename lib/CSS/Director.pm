package CSS::Director;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    FixBodyDirectionLtrAndRtl
    FixLeftAndRight
    FixLeftAndRightInUrl
    FixLtrAndRtlInUrl
    FixCursorProperties
    FixBorderRadius
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    
);

our $VERSION = '0.01';

# h                       [0-9a-f]      ; a hexadecimal digit
our $HEX = q'[0-9a-f]';

# nonascii                [\200-\377]
our $NON_ASCII = q'[\200-\377]';

# unicode                 \\{h}{1,6}(\r\n|[ \t\r\n\f])?
our $UNICODE = q'(?:(?:\\' . $HEX . q'{1,6})(?:\r\n|[ \t\r\n\f])?)';

# escape                  {unicode}|\\[^\r\n\f0-9a-f]
our $ESCAPE = q'(?:' . $UNICODE . q'|\\[^\r\n\f0-9a-f])';

# nmstart                 [_a-z]|{nonascii}|{escape}
our $NMSTART = q'(?:[_a-z]|' . $NON_ASCII . q'|' . $ESCAPE . q')';

# nmchar                  [_a-z0-9-]|{nonascii}|{escape}
our $NMCHAR = q'(?:[_a-z0-9-]|' . $NON_ASCII . q'|' . $ESCAPE . q')';

# ident                   -?{nmstart}{nmchar}*
our $IDENT = q'-?' . $NMSTART . $NMCHAR . '*';

# num                     [0-9]+|[0-9]*"."[0-9]+
our $NUM = q'(?:[0-9]*\.[0-9]+|[0-9]+)';

# s                       [ \t\r\n\f]
our $SPACE = q'[ \t\r\n\f]';

# w                       {s}*
our $WHITESPACE = '(?:' . $SPACE . q'*)';

# url special chars
our $URL_SPECIAL_CHARS = q'[!#$%&*-~]';

# url chars               ({url_special_chars}|{nonascii}|{escape})*
our $URL_CHARS = sprintf( q'(?:%s|%s|%s)*', $URL_SPECIAL_CHARS, $NON_ASCII, $ESCAPE );

# {E}{M}             {return EMS;}
# {E}{X}             {return EXS;}
# {P}{X}             {return LENGTH;}
# {C}{M}             {return LENGTH;}
# {M}{M}             {return LENGTH;}
# {I}{N}             {return LENGTH;}
# {P}{T}             {return LENGTH;}
# {P}{C}             {return LENGTH;}
# {D}{E}{G}          {return ANGLE;}
# {R}{A}{D}          {return ANGLE;}
# {G}{R}{A}{D}       {return ANGLE;}
# {M}{S}             {return TIME;}
# {S}                {return TIME;}
# {H}{Z}             {return FREQ;}
# {K}{H}{Z}          {return FREQ;}
# %                  {return PERCENTAGE;}
our $UNIT = q'(?:em|ex|px|cm|mm|in|pt|pc|deg|rad|grad|ms|s|hz|khz|%)';

# {num}{UNIT|IDENT}                   {return NUMBER;}
our $QUANTITY = sprintf( '%s(?:%s%s|%s)?', $NUM, $WHITESPACE, $UNIT, $IDENT );




# Generic token delimiter character.
our $TOKEN_DELIMITER = '~';

# This is a temporary match token we use when swapping strings.
our $TMP_TOKEN = sprintf( '%sTMP%s', $TOKEN_DELIMITER, $TOKEN_DELIMITER );

# Token to be used for joining lines.
our $TOKEN_LINES = sprintf( '%sJ%s', $TOKEN_DELIMITER, $TOKEN_DELIMITER );

# Global constant text strings for CSS value matches.
our $LTR = 'ltr';
our $RTL = 'rtl';
our $LEFT = 'left';
our $RIGHT = 'right';

# This is a lookbehind match to ensure that we don't replace instances
# of our string token (left, rtl, etc...) if there's a letter in front of it.
# Specifically, this prevents replacements like 'background: url(bright.png)'.
our $LOOKBEHIND_NOT_LETTER = q'(?<![a-zA-Z])';

# This is a lookahead match to make sure we don't replace left and right
# in actual classnames, so that we don't break the HTML/CSS dependencies.
# Read literally, it says ignore cases where the word left, for instance, is
# directly followed by valid classname characters and a curly brace.
# ex: .column-left {float: left} will become .column-left {float: right}
our $LOOKAHEAD_NOT_OPEN_BRACE = sprintf( q'(?!(?:%s|%s|%s|#|\:|\.|\,|\+|>)*?{)',
                            $NMCHAR, $TOKEN_LINES, $SPACE );

# These two lookaheads are to test whether or not we are within a
# background: url(HERE) situation.
# Ref: http://www.w3.org/TR/CSS21/syndata.html#uri
our $VALID_AFTER_URI_CHARS = sprintf( q'[\'\"]?%s', $WHITESPACE );
our $LOOKAHEAD_NOT_CLOSING_PAREN = sprintf( q'(?!%s?%s\))', $URL_CHARS,
                                                $VALID_AFTER_URI_CHARS );
our $LOOKAHEAD_FOR_CLOSING_PAREN = sprintf( q'(?=%s?%s\))', $URL_CHARS,
                                                $VALID_AFTER_URI_CHARS );

# Compile a regex to swap left and right values in 4 part notations.
# We need to match negatives and decimal numeric values.
# The case of border-radius is extra complex, so we handle it separately below.
# ex. 'margin: .25em -2px 3px 0' becomes 'margin: .25em 0 3px -2px'.

our $POSSIBLY_NEGATIVE_QUANTITY = sprintf( q'((?:-?%s)|(?:inherit|auto))', $QUANTITY );
our $POSSIBLY_NEGATIVE_QUANTITY_SPACE = sprintf( q'%s%s%s', $POSSIBLY_NEGATIVE_QUANTITY,
                                                $SPACE,
                                                $WHITESPACE );

# border-radius is very different from usual 4 part notation: ABCD should
# change to BADC (while it would be ADCB in normal 4 part notation), ABC
# should change to BABC, and AB should change to BA
our $BORDER_RADIUS_RE = risprintf( q'((?:%s)?)border-radius(%s:%s)' .
                               '(?:%s)?(?:%s)?(?:%s)?(?:%s)' .
                               '(?:%s/%s(?:%s)?(?:%s)?(?:%s)?(?:%s))?', $IDENT,
                                                                          $WHITESPACE,
                                                                          $WHITESPACE,
                                                                          $POSSIBLY_NEGATIVE_QUANTITY_SPACE,
                                                                          $POSSIBLY_NEGATIVE_QUANTITY_SPACE,
                                                                          $POSSIBLY_NEGATIVE_QUANTITY_SPACE,
                                                                          $POSSIBLY_NEGATIVE_QUANTITY,
                                                                          $WHITESPACE,
                                                                          $WHITESPACE,
                                                                          $POSSIBLY_NEGATIVE_QUANTITY_SPACE,
                                                                          $POSSIBLY_NEGATIVE_QUANTITY_SPACE,
                                                                          $POSSIBLY_NEGATIVE_QUANTITY_SPACE,
                                                                          $POSSIBLY_NEGATIVE_QUANTITY );



# Compile the cursor resize regexes
our $CURSOR_EAST_RE = resprintf( $LOOKBEHIND_NOT_LETTER . '([ns]?)e-resize' );
our $CURSOR_WEST_RE = resprintf( $LOOKBEHIND_NOT_LETTER . '([ns]?)w-resize' );






our $BODY_SELECTOR = sprintf( q'body%s{%s', $WHITESPACE, $WHITESPACE );

# Matches anything up until the closing of a selector.
our $CHARS_WITHIN_SELECTOR = q'[^\}]*?';

# Matches the direction property in a selector.
our $DIRECTION_RE = sprintf( q'direction%s:%s', $WHITESPACE, $WHITESPACE );



sub resprintf {
    my $fmt = shift;
    my $ret = sprintf( $fmt, @_ );

    return qr/$ret/;
}

sub risprintf {
    my $fmt = shift;
    my $ret = sprintf( $fmt, @_ );

    return qr/$ret/i;
}

# These allow us to swap "ltr" with "rtl" and vice versa ONLY within the
# body selector and on the same line.
our $BODY_DIRECTION_LTR_RE = risprintf( q'(%s)(%s)(%s)(ltr)',
                                   $BODY_SELECTOR, $CHARS_WITHIN_SELECTOR,
                                    $DIRECTION_RE );
our $BODY_DIRECTION_RTL_RE = risprintf( q'(%s)(%s)(%s)(rtl)',
                                   $BODY_SELECTOR, $CHARS_WITHIN_SELECTOR,
                                    $DIRECTION_RE );

# Allows us to swap "direction:ltr" with "direction:rtl" and
# vice versa anywhere in a line.
our $DIRECTION_LTR_RE = resprintf( q'%s(ltr)', $DIRECTION_RE );
our $DIRECTION_RTL_RE = resprintf( q'%s(rtl)', $DIRECTION_RE );

# We want to be able to switch left with right and vice versa anywhere
# we encounter left/right strings, EXCEPT inside the background:url(). The next
# two regexes are for that purpose. We have alternate IN_URL versions of the
# regexes compiled in case the user passes the flag that they do
# actually want to have left and right swapped inside of background:urls.
our $LEFT_RE = risprintf( '%s((?:top|bottom)?)(%s)%s%s', $LOOKBEHIND_NOT_LETTER,
                                                      $LEFT,
                                                      $LOOKAHEAD_NOT_CLOSING_PAREN,
                                                      $LOOKAHEAD_NOT_OPEN_BRACE );
our $RIGHT_RE = risprintf( '%s((?:top|bottom)?)(%s)%s%s', $LOOKBEHIND_NOT_LETTER,
                                                       $RIGHT,
                                                       $LOOKAHEAD_NOT_CLOSING_PAREN,
                                                       $LOOKAHEAD_NOT_OPEN_BRACE );
our $LEFT_IN_URL_RE = risprintf( '%s(%s)%s', $LOOKBEHIND_NOT_LETTER,
                                          $LEFT,
                                          $LOOKAHEAD_FOR_CLOSING_PAREN );
our $RIGHT_IN_URL_RE = risprintf( '%s(%s)%s', $LOOKBEHIND_NOT_LETTER,
                                           $RIGHT,
                                           $LOOKAHEAD_FOR_CLOSING_PAREN );
our $LTR_IN_URL_RE = risprintf( '%s(%s)%s', $LOOKBEHIND_NOT_LETTER,
                                         $LTR,
                                         $LOOKAHEAD_FOR_CLOSING_PAREN );
our $RTL_IN_URL_RE = risprintf( '%s(%s)%s', $LOOKBEHIND_NOT_LETTER,
                                         $RTL,
                                         $LOOKAHEAD_FOR_CLOSING_PAREN );



sub FixBodyDirectionLtrAndRtl {
    my ( $line ) = @_;

    $line =~ s!$BODY_DIRECTION_LTR_RE!$1$2$3$TMP_TOKEN!gms;
    $line =~ s!$BODY_DIRECTION_RTL_RE!$1$2$3$LTR!gms;
    $line =~ s!$TMP_TOKEN!$RTL!gms;

    return $line;
}

sub FixLeftAndRight {
    my ( $line ) = @_;

    $line =~ s!$LEFT_RE!$1$TMP_TOKEN!gms;
    $line =~ s!$RIGHT_RE!$1$LEFT!gms;
    $line =~ s!$TMP_TOKEN!$RIGHT!gms;

    return $line;
}

sub FixLeftAndRightInUrl {
    my ( $line ) = @_;

    $line =~ s!$LEFT_IN_URL_RE!$TMP_TOKEN!gms;
    $line =~ s!$RIGHT_IN_URL_RE!$LEFT!gms;
    $line =~ s!$TMP_TOKEN!$RIGHT!gms;

    return $line;
}

sub FixLtrAndRtlInUrl {
    my ( $line ) = @_;

    $line =~ s!$LTR_IN_URL_RE!$TMP_TOKEN!gms;
    $line =~ s!$RTL_IN_URL_RE!$LTR!gms;
    $line =~ s!$TMP_TOKEN!$RTL!gms;

    return $line;
}

sub FixCursorProperties {
    my ( $line ) = @_;

    $line =~ s!$CURSOR_EAST_RE!$1$TMP_TOKEN!gms;
    $line =~ s!$CURSOR_WEST_RE!${1}e-resize!gms;
    $line =~ s!$TMP_TOKEN!w-resize!gms;

    return $line;
}

sub ReorderBorderRadiusPart {
    my @part = grep defined, @_;

    if ( @part == 4 ) {
        return join( ' ', @part[ 1, 0, 3, 2 ] );
    }
    elsif ( @part == 3 ) {
        return join( ' ', @part[ 1, 0, 1, 2 ] );
    }
    elsif ( @part == 2 ) {
        return join( ' ', @part[ 1, 0, ] );
    }
    elsif ( @part == 1 ) {
        return $part[ 0 ];
    }
    else {
        return '';
    }
}

use Data::Dumper;

sub ReorderBorderRadius {
    my @m = @_;

    warn( Dumper( { reorder => \@m } ) );

    my $first_group = ReorderBorderRadiusPart( @m[ 1 .. 5 ] );
    my $second_group = ReorderBorderRadiusPart( @m[ 5 .. $#m ] );

    if ( $second_group eq '' ) {
warn("second empty: " . Dumper( \@m ) );
        return sprintf( '%sborder-radius%s%s', $m[0], $m[1], $first_group );
    }
    else {
        return sprintf( '%sborder-radius%s%s / %s', $m[0], $m[1], $first_group, $second_group );
    }
}


sub FixBorderRadius {
    my ( $line ) = @_;

use Data::Dumper;
#warn( Dumper( \@-, \@+ ) );
warn( "<$line> =~ <$BORDER_RADIUS_RE>" );

    #$line =~ s!$BORDER_RADIUS_RE!warn( Dumper( scalar( @- ), scalar( @+ ) ) )!egms;
    $line =~ s!$BORDER_RADIUS_RE!
        warn(Dumper({inre => \@-, refs => [ '', $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 ] }));
        ReorderBorderRadius($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
    !egms;
    #$line =~ s!$BORDER_RADIUS_RE! my @m = map +( substr( $line, $-[$_], $+[$_] - $-[$_] ) ), 1 .. $#-; warn Dumper { m => \@m } !egms;

    return $line;
}

1;

__END__

=head1 NAME

CSS::Director - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CSS::Director;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CSS::Director, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 HISTORY

=over 8

=item 0.01

Original version; created by h2xs 1.23 with options

  -AXCn
    CSS::Director

=back



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>simon@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.2 or,
at your option, any later version of Perl 5 you may have available.


=cut

# vim: ts=4 sw=4 et:
