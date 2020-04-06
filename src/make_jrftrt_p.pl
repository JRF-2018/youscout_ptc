#!/usr/bin/perl
#require 5.008;
our $VERSION = "0.03"; #Time-stamp: <2013-02-25T03:26:55Z>

use strict;
use warnings;
use utf8; # Japanese

my $INPUT = "jrftarot.prg";
my $OUTPUT = "jrftrt_p.prg";

MAIN:
{
  open(my $ifh, "<", $INPUT) or die "$INPUT: $!";
  open(my $ofh, ">", $OUTPUT) or die "$OUTPUT: $!";
  binmode($ifh, ":utf8");
  binmode($ofh, ":utf8");

  my $l = "";
  print $ofh <<"EOT";
'== BEGIN JRFTRT_P ==
\@JRFTRT_P_INIT
JRFTRT_P_VER\$ = "$VERSION"
JRFTRT_P_URI\$ = "http://jrf.cocolog-nifty.com/archive/youscout/ptc/jrftrt_p.prg"
'PROVIDE "JRFTRT_P"
RETURN

EOT

  while (<$ifh>) {
    my $s = $_;
    $s =~ s/[\n\r]+$//s;
    if ($s =~ /^\s*(\@[A-Za-z01-9_]+)/) {
      $l = $1;
    }
    if ($l =~ /_(?:PL|CMAP)$/ && $l !~ /^\@SOROBAN_/) {
      if ($s =~ /^\s*\@/) {
	print $ofh "\n";
      }
      print $ofh ($s . "\n") if $s ne "";
    }
  }
  print $ofh "\n'== END JRFTRT_P == \n";
  close($ofh);
  close($ifh);
}
