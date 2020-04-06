#!/usr/bin/perl
#require 5.008;
our $VERSION = "0.03"; #Time-stamp: <2013-02-25T03:26:45Z>

use strict;
use warnings;
use utf8; # Japanese

our $TRTCONST = "trtconst.prg";
our $YSCCONST = "yscconst.prg";
our $YSCMSG = "yscmsg.prg";
our $TAROT = "jrftarot.prg";
our $OUTPUT = "yschlp_p.prg";

my $CARD_WIDTH = 36;
my $CARD_HEIGHT = 56;
my $GRP_ROWS = 3;
my $GRP_A = "JRFTRT_A";
my $GRP_D = "JRFTRT_D";
my $GRP_D_A00 = 5 * $GRP_ROWS + 0;
my $GRP_D_A13 = 5 * $GRP_ROWS + 1;
my $GRP_BASE = "JRFTRT_";

my @TRTMJ_EN;
my @TRTMJ_JA
  = ("グシャ", "マジュツシ", "オンナ=キョウコウ", "ジョテイ",
     "コウテイ", "ホウオウ", "コイビト", "センシャ",
     "チカラ", "インジャ", "ウンメイ ノ ワ", "セイギ",
     "ツルサレタ オトコ", "シニガミ", "セッセイ", "アクマ",
     "トウ", "ホシ", "ツキ", "タイヨウ", "シンパン", "セカイ"
    );
my @TRTMJ_JA2;

my @TABLE_MAJOR;

MAIN:
{
  open(my $ofh, ">", $OUTPUT) or die "$OUTPUT: $!";
  binmode($ofh, ":utf8");

  print $ofh <<"EOT";
'== BEGIN YSCHLP_P ==
\@YSCHLP_P_INIT
YSCHLP_P_VER\$ = "$VERSION"
YSCHLP_P_URI\$ = "http://jrf.cocolog-nifty.com/archive/youscout/ptc/yschlp_p.prg"

EOT
  {
    my $l = "";
    open(my $ifh, "<", $TRTCONST) or die "$TRTCONST: $!";
    binmode($ifh, ":utf8");
    while (<$ifh>) {
      my $s = $_;
      $s =~ s/[\n\r]+$//s;
      if ($s =~ /^\s*(\@[A-Za-z01-9_]+)/) {
	$l = $1;
      }
      last if $s =~ /^\s*RETURN/;
      if ($s =~ /^\s*TAROT_NAME/
	  || $s =~ /^\s*BOARD_RGB/
          || $s =~ /^\s*CHAR_LOGO/
          || $s =~ /^\s*DIM CHAR_LOGO/
	  || $s =~ /^\s*LOGO_/
	  || $s =~ /^\s*COL_/
	 ) {
	print $ofh ($s . "\n") if $s ne "";
      }
    }
    close($ifh);
  }

  {
    my $l = "";
    my $in_tbl = 0;
    open(my $ifh, "<", $YSCCONST) or die "$YSCCONST: $!";
    binmode($ifh, ":utf8");
    while (<$ifh>) {
      my $s = $_;
      $s =~ s/[\n\r]+$//s;
      if ($s =~ /^\s*(\@[A-Za-z01-9_]+)/) {
	$l = $1;
      }
      last if $s =~ /^\s*RETURN/;
      if ($s =~ /^\s*DECORATE_/
	  || $s =~ /^\s*CON_DECORATE/
	  || $s =~ /^\s*MNU_/
	 ) {
	print $ofh ($s . "\n") if $s ne "";
      }
      if ($l eq "\@TABLE_MAJOR") {
	$in_tbl = 1;
      }
      if ($in_tbl) {
	if ($s =~ /^\s*DATA\s+\"(.*)\"/) {
	  push(@TABLE_MAJOR, [split(",", $1)]);
	} elsif ($s !~ /^\s*\@TABLE_MAJOR/ && $s !~ /^\s*\'\([01-9]\)/) {
	  $in_tbl = 0;
	}
      }
    }
    close($ifh);
  }

  {
    my $l = "";
    open(my $ifh, "<", $YSCMSG) or die "$YSCMSG: $!";
    binmode($ifh, ":utf8");
    while (<$ifh>) {
      my $s = $_;
      $s =~ s/[\n\r]+$//s;
      if ($s =~ /^\s*(\@[A-Za-z01-9_]+)/) {
	$l = $1;
      }
      if ($l eq "\@MSG_TRTMJ_EN") {
	while ($s =~ /\"([^\"]*)\"/g) {
	  push(@TRTMJ_EN, $1);
	}
      }
      if ($l eq "\@MSG_TRTMJ_JA") {
	while ($s =~ /\"([^\"]*)\"/g) {
	  push(@TRTMJ_JA2, $1);
	}
      }
      last if $l eq "\@MSG_HXG_EN";
    }
    close($ifh);
  }

  if (@TABLE_MAJOR != 22) {
    die "Parse Error when reading \@TABLE_MAJOR";
  }
  if (@TRTMJ_EN != 22) {
    die "Parse Error when reading \@TRTMJ_EN";
  }
  if (@TRTMJ_JA2 != 22) {
    die "Parse Error when reading \@TRTMJ_JA2";
  }

  print $ofh <<'EOT';

'PROVIDE "YSCHLP_P"
RETURN

EOT


  {
    my $l = "";
    open(my $ifh, "<", $TAROT) or die "$TAROT: $!";
    binmode($ifh, ":utf8");
    while (<$ifh>) {
      my $s = $_;
      $s =~ s/[\n\r]+$//s;
      if ($s =~ /^\s*(\@[A-Za-z01-9_]+)/) {
	$l = $1;
      }
      if ($l =~ /_CMAP$/ || $l =~ /^\@CHAR_(?:EKI|SOU|ROKU)/) {
	if ($s =~ /^\s*\@/) {
	  print $ofh "\n";
	}
	print $ofh ($s . "\n") if $s ne "";
      }
    }
    close($ifh);
  }

  print $ofh "\n";

  for (my $i = 0; $i < 22; $i++) {
    my $j = ($i >= 13)? $i - 2: $i - 1;
    my $grp = $GRP_A;
    if ($i == 0) {
      $j = $GRP_D_A00;
      $grp = $GRP_D;
    }
    if ($i == 13) {
      $j = $GRP_D_A13;
      $grp = $GRP_D;
    }
    my $x = int($j / $GRP_ROWS) * $CARD_WIDTH;
    my $y = ($j % $GRP_ROWS) * $CARD_HEIGHT;
    my $esc = sprintf("[%s,%d,%d,%d,%d,%d,%d]",
		      $grp, $x, $y,
		      $x + $CARD_WIDTH - 1, $y + $CARD_HEIGHT - 1,
		      8, 24);
    my @m = @{$TABLE_MAJOR[$i]};
    my $upr = sprintf("♠%2d/%2d♦%2d/%2d♥%2d/%2d♣%2d/%2d", @m);
    my $inv = sprintf("♣%2d/%2d♥%2d/%2d♦%2d/%2d♠%2d/%2d", reverse(@m));
    for (my $i = 0; $i < @m; $i++) {
      $m[$i] = 2 * $m[$i];
    }
    my $upr2 = sprintf("♠%2d/%2d♦%2d/%2d♥%2d/%2d♣%2d/%2d", @m);
    my $inv2 = sprintf("♣%2d/%2d♥%2d/%2d♦%2d/%2d♠%2d/%2d", reverse(@m));
    my $id = sprintf("A%02d", $i);
    my $prev;
    my $next;
    if ($i == 0) {
      $prev = sprintf("A%02d", 21);
    } else {
      $prev = sprintf("A%02d", $i - 1);
    }
    if ($i == 21) {
      $next = sprintf("A%02d", 0);
    } else {
      $next = sprintf("A%02d", $i + 1);
    }
#    my $esc2 = sprintf("[%s,0,%d,%d,%d,%d,%d,%d]",
#		      $grp, $x, $y,
#		      $x + $CARD_WIDTH - 1, $y + $CARD_HEIGHT - 1,
#		      140, 32);
#    print "$TRTMJ_EN[$i]:\n\\I$esc2\n\n";
    print $ofh <<"EOT";

\@YSC_TB${id}_EN
DATA "\\C[MK]\\I${esc}"
DATA "($i)$TRTMJ_EN[$i]\\n\\n"
DATA "     Upright×2:\\n"
DATA "      $upr2\\n\\n"
DATA "     Reversal×2:\\n"
DATA "      $inv2\\n\\n"
DATA "     Upright×1:\\n"
DATA "      $upr\\n\\n"
DATA "     Reversal×1:\\n"
DATA "      $inv\\n\\n"
DATA "\\L[B:\@YSC_RMJTB_EN]"
DATA "\\L[L:\@YSC_TB${prev}_EN]"
DATA "\\L[R:\@YSC_TB${next}_EN]"
DATA ""

\@YSC_TB${id}_JA
DATA "\\C[MK]\\I${esc}"
DATA "($i)$TRTMJ_JA[$i] ($TRTMJ_JA2[$i])\\n\\n"
DATA "     セイ=イチ×2:\\n"
DATA "      $upr2\\n\\n"
DATA "     ギャク=イチ×2:\\n"
DATA "      $inv2\\n\\n"
DATA "     セイ=イチ×1:\\n"
DATA "      $upr\\n\\n"
DATA "     ギャク=イチ×1:\\n"
DATA "      $inv\\n\\n"
DATA "\\L[B:\@YSC_RMJTB_JA]"
DATA "\\L[L:\@YSC_TB${prev}_JA]"
DATA "\\L[R:\@YSC_TB${next}_JA]"
DATA ""
EOT
  }

  my @suit = ("S", "D", "H", "C");
  for (my $j = 0; $j < @suit; $j++) {
    my $suit = $suit[$j];
    my $suit_name_en = ("Swords", "Coins", "Cups", "Wands")[$j];
    my $suit_name_ja = ("ソード (ツルギ)", "コイン (カネ)", "カップ (ハイ)", "ワンド (シャクジョウ)")[$j];
    my $next = ($j + 1 >= @suit)? $suit[0] : $suit[$j + 1];
    my $prev = ($j - 1 < 0)? $suit[$#suit] : $suit[$j - 1];
    my $grp = $GRP_BASE . $suit;
    print $ofh <<"EOT";

\@YSC_TBCD${suit}_EN
DATA "■ $suit_name_en (1/2)\\n\\n"
EOT
    for (my $i = 0; $i < 10; $i++) {
      my $sx = int($i / $GRP_ROWS) * $CARD_WIDTH;
      my $sy = ($i % $GRP_ROWS) * $CARD_HEIGHT;
      my $dx = 14 + ($i % 5) * ($CARD_WIDTH + 12);
      my $dy = 24 + int($i / 5) * ($CARD_HEIGHT + 8);
      my $esc = sprintf("[%s,%d,%d,%d,%d,%d,%d]",
			$grp, $sx, $sy,
			$sx + $CARD_WIDTH - 1, $sy + $CARD_HEIGHT - 1,
			$dx, $dy);
      print $ofh <<"EOT";
DATA "\\I${esc}"
EOT
    }
    print $ofh <<"EOT";
DATA "\\L[B:\@YSC_RMJTB_EN]"
DATA "\\L[L:\@YSC_TBCD${prev}2_EN]"
DATA "\\L[R:\@YSC_TBCD${suit}2_EN]"
DATA ""
EOT

    print $ofh <<"EOT";

\@YSC_TBCD${suit}2_EN
DATA "■ $suit_name_en (2/2)\\n\\n"
EOT
    for (my $i = 10; $i < 14; $i++) {
      my $sx = int($i / $GRP_ROWS) * $CARD_WIDTH;
      my $sy = ($i % $GRP_ROWS) * $CARD_HEIGHT;
      my $dx = 14 + (($i - 10) % 5) * ($CARD_WIDTH + 12);
      my $dy = 24 + int(($i - 10) / 5) * ($CARD_HEIGHT + 8);
      my $esc = sprintf("[%s,%d,%d,%d,%d,%d,%d]",
			$grp, $sx, $sy,
			$sx + $CARD_WIDTH - 1, $sy + $CARD_HEIGHT - 1,
			$dx, $dy);
      print $ofh <<"EOT";
DATA "\\I${esc}"
EOT
    }
    print $ofh <<"EOT";
DATA "\\L[B:\@YSC_RMJTB_EN]"
DATA "\\L[L:\@YSC_TBCD${suit}_EN]"
DATA "\\L[R:\@YSC_TBCD${next}_EN]"
DATA ""
EOT

    print $ofh <<"EOT";

\@YSC_TBCD${suit}_JA
DATA "■ $suit_name_ja (1/2)\\n\\n"
EOT
    for (my $i = 0; $i < 10; $i++) {
      my $sx = int($i / $GRP_ROWS) * $CARD_WIDTH;
      my $sy = ($i % $GRP_ROWS) * $CARD_HEIGHT;
      my $dx = 14 + ($i % 5) * ($CARD_WIDTH + 12);
      my $dy = 24 + int($i / 5) * ($CARD_HEIGHT + 8);
      my $esc = sprintf("[%s,%d,%d,%d,%d,%d,%d]",
			$grp, $sx, $sy,
			$sx + $CARD_WIDTH - 1, $sy + $CARD_HEIGHT - 1,
			$dx, $dy);
      print $ofh <<"EOT";
DATA "\\I${esc}"
EOT
    }
    print $ofh <<"EOT";
DATA "\\L[B:\@YSC_RMJTB_JA]"
DATA "\\L[L:\@YSC_TBCD${prev}2_JA]"
DATA "\\L[R:\@YSC_TBCD${suit}2_JA]"
DATA ""
EOT

    print $ofh <<"EOT";

\@YSC_TBCD${suit}2_JA
DATA "■ $suit_name_ja (2/2)\\n\\n"
EOT
    for (my $i = 10; $i < 14; $i++) {
      my $sx = int($i / $GRP_ROWS) * $CARD_WIDTH;
      my $sy = ($i % $GRP_ROWS) * $CARD_HEIGHT;
      my $dx = 14 + (($i - 10) % 5) * ($CARD_WIDTH + 12);
      my $dy = 24 + int(($i - 10) / 5) * ($CARD_HEIGHT + 8);
      my $esc = sprintf("[%s,%d,%d,%d,%d,%d,%d]",
			$grp, $sx, $sy,
			$sx + $CARD_WIDTH - 1, $sy + $CARD_HEIGHT - 1,
			$dx, $dy);
      print $ofh <<"EOT";
DATA "\\I${esc}"
EOT
    }
    print $ofh <<"EOT";
DATA "\\L[B:\@YSC_RMJTB_JA]"
DATA "\\L[L:\@YSC_TBCD${suit}_JA]"
DATA "\\L[R:\@YSC_TBCD${next}_JA]"
DATA ""
EOT
  }
  print $ofh "\n'== END YSCHLP_P == \n";
  close($ofh);
}
