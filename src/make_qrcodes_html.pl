#!/usr/bin/perl
#require 5.008;
our $VERSION = "0.01"; #Time-stamp: <2013-02-20T00:26:52Z>

use strict;
use warnings;
use utf8; # Japanese

use File::Spec::Functions qw(catfile splitpath splitdir);
use GD;

our $DEST_DIR = "qrcode";
our $DEST_NAME = "qrcodes.html";
our $TEMPLATE = "template_qrcodes.html";
our $VERSION_FROM;
our %VAR
  = (
     PRG_NAME => "TEMP0000",
     VERSION => "0.00",
    );

use Getopt::Long;
#Getopt::Long::Configure("bundling", "no_ignore_case", "auto_version");
Getopt::Long::Configure("no_ignore_case", "auto_version");
GetOptions(
	   "target-directory|t=s" => \$DEST_DIR,
	   "name|N=s" => \$VAR{PRG_NAME},
 	   "prg-version|V=s" => \$VAR{VERSION},
 	   "version-from=s" => \$VERSION_FROM,
	   "html|H=s" => \$DEST_NAME,
	   "template|T=s" => \$TEMPLATE,
	   "help|h" => sub { usage(0); },
	  );

if (! -d $DEST_DIR) {
  die "The target directory \"$DEST_DIR\" isn't a directory.";
}

sub usage {
  my ($ext) = @_ || 0;
  print <<"EOU";
Usage: $0 -t DIR -N PRG_NAME --version-from PRG -H qrcodes.html

qrcodes.html is made into DIR.
EOU
  exit($ext);
}

MAIN:
{
  opendir(my $dh, $DEST_DIR) or die "$DEST_DIR: $!";
  my @f = readdir($dh);
  closedir($dh);

  my $n = 0;
  my $w;
  my $h;
  foreach my $f (@f) {
    if ($f =~ /^qr([01-9]+)\.(.*)$/) {
      if ($1 > $n) {
	$n = $1;
      }
      if (! defined $w && (lc($2) eq "png" || lc($2) eq "gif")) {
	$VAR{EXT} = $2;
	my $img = GD::Image->new(catfile($DEST_DIR, $f));
	($w, $h) = $img->getBounds();
	$VAR{QRCODE_WIDTH} = $w;
	$VAR{QRCODE_HEIGHT} = $h;
      }
    }
  }
  if ($n == 0) {
    die "$DEST_DIR: 'qr001.png' doesn't exists.";
  }
  $VAR{QRCODES_NUM} = int($n);
  $VAR{QRCODES_NUM_PAD} = length($n);
  {
    my $s = "";
    for (my $i = 0; $i < $n; $i++) {
      my $num = sprintf("%0$VAR{QRCODES_NUM_PAD}d", $i);
      $s .= "<p><img src=\"qr${num}.$VAR{EXT}\" width=\"$w\" height=\"$h\" /></p>\n";
    }
    $VAR{NOSCRIPT} = $s;
  }

  if (defined $VERSION_FROM) {
    open(my $fh, "<", $VERSION_FROM) or die "$VERSION_FROM: $!";
    binmode($fh, ":utf8");
    my ($v, $d, $f) = splitpath($VERSION_FROM);
    my $base = $f;
    $base =~ s/\..*$//;
    $base = uc($base);
    my $ver;
    while (my $s = <$fh>) {
      if ($s =~ /\s*\Q$VAR{PRG_NAME}\E_VER(?:SION)?\$?\s*=\s*\"([^\"]+)\"/i) {
	$ver = $1;
	last;
      }
      if ($s =~ /\s*\Q$base\E_VER(?:SION)?\$?\s*=\s*\"([^\"]+)\"/i) {
	$ver = $1;
	last;
      }
    }
    close($fh);
    if (! defined $ver) {
      warn "$VERSION_FROM: Cannot find a version string.";
    } else {
      $VAR{VERSION} = $ver;
    }
  }

  {
    open(my $fh, "<", $TEMPLATE) or die "$TEMPLATE: $!";
    binmode($fh, ":utf8");
    my $s = join("", <$fh>);
    close($fh);
    $s =~ s(\{\{([A-Za-z01-9_]+)\}\}){
      if (exists $VAR{$1}) {
	$VAR{$1};
      } else {
	warn "$& is unknown.";
	$&;
      }
    }sexg;

    my $o = catfile($DEST_DIR, $DEST_NAME);
    open(my $ofh, ">", $o) or die "$o: $!";
    binmode($ofh, ":utf8");
    print $ofh $s;
    close($ofh);
  }
}
