#!/usr/bin/perl
#require 5.008;
our $VERSION = "0.03"; #Time-stamp: <2013-02-24T22:13:44Z>

use strict;
use warnings;
use utf8; # Japanese

use File::Spec::Functions qw(catfile splitpath splitdir);

use Data::Petitcom;
use Unicode::Japanese;

our $YEN_HACK = 1; # 1: \ is ￥, 2: \ is ＼, 0: no conversion.
our $DEST_DIR = "qrcode";
our $CHECK_PRG = 1;
our $CHECK_ENTER_LEAVE = 0;
our $CHECK_GLOBAL_ONCE = 1;
our $GEN_QRCODE = 1;
our $PRG_NAME;
our $PRG_NAME_DEFAULT = "TESTPRG";
our $QR_VERSION = 20; # 1 から 24。数値が大きくなるほど QR 画像が大きくなる。

# V: Read only variable, W: Writable variable,
# F: Function, I: Imperative, R: Imperative like READ,
# OP: Operator, S: Syntax sugar.
our @RESERVED =
  qw(
     ABS:F ACLS:I AND:OP APPEND:I ASC:F ATAN:F
     BEEP:I BGCHK:F BGCLIP:I BGCLR:I BGCOPY:I BGFILL:I
     BGMCHK:F BGMCLEAR:I BGMGETV:F BGMPLAY:I BGMPRG:I BGMSET:I
     BGMSETD:I BGMSETV:I
     BGMSTOP:I BGMVOL:I BGOFS:I BGPAGE:I BGPUT:I
     BGREAD:R BREPEAT:I BTRIG:F BUTTON:F
     CANCEL:I CHKCHR:F CHR$:F CHRINIT:I CHRREAD:R CHRSET:I CLEAR:I CLS:I
     COLINIT:I COLOR:I COLREAD:R COLSET:I CONT:I COS:F CSRX:V CSRY:V
     DATA:I DATE$:V DEG:F DELETE:I DIM:I DTREAD:R
     ELSE:S END:I ERL:V ERR:V EXEC:I EXP:F
     FALSE:V FILES:I FLOOR:F FOR:I
     FREEMEM:V FREEVAR:V FUNCNO:V
     GBOX:I GCIRCLE:I GCLS:I GCOLOR:I GCOPY:I GDRAWMD:I
     GFILL:I GLINE:I GOSUB:I GOTO:I
     GPAGE:I GPAINT:I GPSET:I GPRIO:I GPUTCHR:I GSPOIT:F
     HEX$:F
     ICONCHK:F ICONCLR:I ICONPAGE:W ICONPMAX:W ICONPUSE:W ICONSET:I
     IF:I INKEY$:F INPUT:R INSTR:F KEY:I KEYBOARD:V
     LEFT$:F LEN:F LINPUT:R LIST:I LOAD:I LOCATE:I LOG:F
     MAINCNTL:V MAINCNTH:V MEM$:W MID$:F
     NEW:I NEXT:I NOT:OP ON:I OR:OP
     PACKAGE$:V PI:F PNLSTR:I PNLTYPE:I POW:F PRGNAME$:V PRINT:I
     RAD:F READ:R REBOOT:I RECVFILE:I REM:I RENAME:I RESTORE:I
     RESULT:V RETURN:I
     RIGHT$:F RND:F RSORT:I RUN:I
     SAVE:I SENDFILE:I SGN:F SIN:F SORT:I SPANGLE:I SPANIM:I
     SPCHK:F SPCHR:I
     SPCLR:I SPCOL:I SPCOLVEC:I SPGETV:F SPHIT:F
     SPHITNO:V SPHITRC:F SPHITSP:F
     SPHITT:V SPHITX:V SPHITY:V SPHOME:I SPOFS:I SPPAGE:I
     SPREAD:R SPSCALE:I
     SPSET:I SPSETV:I SQR:F STEP:S STOP:I STR$:F SUBST$:F SWAP:R SYSBEEP:W
     TABSTEP:W TALK:I TALKCHK:F TALKSTOP:I TAN:F
     TCHST:V TCHTIME:V TCHX:V TCHY:V
     THEN:S TIME$:V TMREAD:R TO:S TRUE:V
     VAL:F VERSION:V VISIBLE:I VSYNC:I WAIT:I XOR:OP
     ?:I
   );

our @UNARY = qw(NOT ! -);
our @BINARY = qw(AND:7 OR:7 XOR:7 ==:6 !=:6 <:6 <=:6 >:6 >=:6 +:5 -:5 *:4 /:4 %:4);

my $SYNTAX_ERROR = 0;
my %NAME_SPACE;
my %ENTER_LEAVE;
my %OCC;
my %DEC;
$DEC{"GLOBAL"} = {};
my @PRG;
my %RESERVED;
my %BUILTIN_GLOBAL;
my %UNARY;
my %BINARY;
foreach my $c (@RESERVED) {
  my ($n, $t) = split(":", $c);
  if ($t eq "W") {
    my $t2 = "NVAR";
    $t2 = "SVAR" if $n =~ /\$$/;
    $DEC{"GLOBAL"}->{$n} = [] if ! exists $DEC{"GLOBAL"}->{$n};
    push(@{$DEC{"GLOBAL"}->{$n}}, [$t2, "BUILT-IN", 1, "GLOBAL"]);
    $BUILTIN_GLOBAL{$n} = 1;
  } else {
    $RESERVED{$n} = $t;
  }
}
foreach my $c (@UNARY) {
  $UNARY{$c} = 1;
}
foreach my $c (@BINARY) {
  my ($n, $t) = split(":", $c);
  $BINARY{$n} = $t;
}

my @define;
my @includes;
use Getopt::Long;
#Getopt::Long::Configure("bundling", "no_ignore_case", "auto_version");
Getopt::Long::Configure("no_ignore_case", "auto_version");
GetOptions(
	   "name|N=s" => \$PRG_NAME,
	   "qr-version|Q=i" => \$QR_VERSION,
	   "target-directory|t=s" => \$DEST_DIR,
           "check-enter-leave" => \$CHECK_ENTER_LEAVE,
           "check-global-once!" => \$CHECK_GLOBAL_ONCE,
           "check-prg!" => \$CHECK_PRG,
           "strict" => sub {$CHECK_PRG = 1; $CHECK_ENTER_LEAVE = 1;},
	   "lint" => sub {$GEN_QRCODE = 0; $CHECK_PRG = 1; $CHECK_ENTER_LEAVE = 1;},
	   "define|D=s@" => \@define,
	   "include|I=s@" => \@includes,
	   "help|h" => sub { usage(0); },
	  );

if (! defined $PRG_NAME) {
  if (@ARGV) {
    my ($v, $d, $f) = splitpath($ARGV[0]);
    $f =~ s/[\.[^\.]*$//s;
    $PRG_NAME = uc($f);
    if (length($PRG_NAME) > 8) {
      $PRG_NAME = substr($PRG_NAME, 0, 8);
    }
  } else {
    $PRG_NAME = $PRG_NAME_DEFAULT;
  }
}

if (! -d $DEST_DIR) {
  die "The target directory \"$DEST_DIR\" isn't a directory.";
}

sub usage {
  my ($ext) = @_ || 0;
  print <<"EOU";
Usage: $0 -t DIR PRG1 PRG2 ...
   or: rm -f qrcode/*; $0 -N PRG_NAME PRG1 PRG2 ...; cygstart qrcode/qr001.png
OPTIONS:
  -N BASENAME		PRG (base)name.
  -Q NUM		QR VERSION (i.e. image size).
  -t DIR		specify the target directory.
  --no-check-prg	no syntax check for prg.
  --no-check-global-once
			don't check occuring only once in global.
  --strict		check about \@ENTER and \@LEAVE.
  -D LABEL		specify LABEL to be defined.
  -I PRG		include PRG to be checked with,
			but not include into QR codes.
EOU
  exit($ext);
}


MAIN:
{
  my $prg = "";
  my $inc_lines = 0;
  parse_define();
  if (@ARGV) {
    while (@ARGV) {
      my $f = shift(@ARGV);
      open(my $fh, "<" , $f) or die "$f: $!";
      binmode($fh, ":utf8");
      my $p = join("", <$fh>);
      close($fh);
      push(@PRG, $f);
      check_prg($f, $p) if $CHECK_PRG;
      $prg .= "\n\n" if $prg ne "";
      $prg .= $p;
    }
  } else {
    binmode(STDIN, ":utf8");
    my $p = join("", <STDIN>);
    push(@PRG, "STDIN");
    check_prg("STDIN", $p) if $CHECK_PRG;
    $prg .= $p;
  }
  while (@includes) {
    my $f = shift(@includes);
    open(my $fh, "<" , $f) or die "$f: $!";
    binmode($fh, ":utf8");
    my $p = join("", <$fh>);
    close($fh);
    push(@PRG, $f);
    check_prg($f, $p) if $CHECK_PRG;
    my $lines = 0;
    $p .= "\n" if $p !~ /\n$/s;
    while ($p =~ /\n/sg) {$lines++}
    $inc_lines += $lines;
  }
  analyze_occ() if $CHECK_PRG;

  if ($YEN_HACK == 1) {
    $prg =~ s/\\/￥/sg;
  } elsif ($YEN_HACK == 2) {
    $prg =~ s/\\/＼/sg;
  }

  $prg =~ s/\t/        /sg;
  $prg =~ tr/⇒×＼♠♦♥♣/Йм\x7FЯбав/;
#  $prg =~ tr/⇒×＼♠♦♥♣～/Йм\x7FЯбав\xA0/; # "～": not work.

  $prg .= "\n" if $prg !~ /\n$/s;
  my $lines = 0;
  while ($prg =~ /\n/sg) {$lines++}

  if ($inc_lines) {
    my $sum = $inc_lines + $lines;
    print "$lines (+ $inc_lines = $sum) lines.\n";
  } else {
    print "$lines lines.\n";
  }
  if ($lines + $inc_lines > 9999) {
    warn "Program for PTC mkII must be less than 9999 lines!.\n"
  }

  if ($SYNTAX_ERROR) {
    exit(1);
  }

  if (! $GEN_QRCODE) {
    exit(0);
  }

  %OCC = ();
  %DEC = ();

  my $qrcodes = QRCode($prg, type => 'image', version => $QR_VERSION, name => $PRG_NAME);
  for (my $i = 0; $i < @$qrcodes; $i++) {
    my $img = $qrcodes->[$i];
    my $fname = catfile($DEST_DIR, sprintf("qr%03d.png", $i + 1));
    open(my $fh, ">", $fname) or die "$fname: $!";
    binmode($fh);
    print $fh $img;
    close($fh);
  }
}


sub check_prg {
  my ($fname, $prg) = @_;
  my $l = 0;
  my ($prev, $prev2, $prev3);
  $prg .= "\n" if $prg !~ /\n$/s;

  my $near_enter = 0;
  my $cur_enter = undef;
  my @enter_push;
  my @leave_pop;
  my $leaving;
  my $enter_begin;
  my $enter_end;
  my $argnum;
  my $for_next = 0;
  while ($prg =~ /([^\n]*)\n/sg) {
    $prg = $';
    my $s = $1;
    $l++;

    my $len = length(Unicode::Japanese->new($s)->hira2kata->z2h->getu);
    if ($len >= 100) {
      warn "$fname:$l:E:length of one line must be < 100.\n";
      $SYNTAX_ERROR = 1;
    }
    next if $s =~ /^\s*$/ || $s =~ /^\s*\'/ || $s =~ /^\s*REM/i;

    my @l = lex($fname, $l, $s);
    parse($fname, $l, $cur_enter, @l);

    if ($CHECK_ENTER_LEAVE) {
      if (defined $cur_enter) {
	$for_next += scalar(grep {uc($_->[1]) eq "FOR"} @l);
	$for_next -= scalar(grep {uc($_->[1]) eq "NEXT"} @l);
	if ($for_next < 0) {
	  warn "$fname:$l:E:'NEXT' needs 'FOR'.\n";
	  $SYNTAX_ERROR = 1;
	}
      }
      my $type_checked = 0;
      if ($near_enter && $s =~ /^\s*\@[A-Za-z]/) {
	warn "$fname:$l:E:Local label must begin with \"\@_\" when using \@ENTER.\n";
	$SYNTAX_ERROR = 1;
      }
      if ($s =~ /(?:^|\:)\s*(R\$?)\s*=([^\:]*)\:\s*GOSUB\s+(\@PUSH_RS?)\s*($|\:)/) {
	my $v1 = $1;
	my $v2 = $2;
	my $push = $3;
	$type_checked = 1;
	if ($v2 =~ /^\s*([A-Za-z_\$][A-Za-z01-9_\$]*)\s*$/) {
	  $v2 = $1;
	  if (! (($v1 =~ /\$$/ && $v2 =~ /\$$/ && $push eq "\@PUSH_RS")
		 || ($v1 !~ /\$$/ && $v2 !~ /\$$/ && $push eq "\@PUSH_R"))) {
	    warn "$fname:$l:W:Type mismatch.\n";
	  }
	} else {
	  if (! (($v1 =~ /\$$/ && $push eq "\@PUSH_RS")
		 || ($v1 !~ /\$$/ && $push eq "\@PUSH_R"))) {
	    warn "$fname:$l:W:Type mismatch.\n";
	  }
	}
      }

      if ($s =~ /(?:^|\:)\s*GOSUB\s+(\@POP_RS?)\s*:\s*([A-Za-z_\$][A-Za-z01-9_\$]*)\s*=\s+(R\$?)\s*($|\:)/) {
	my $v1 = $3;
	my $v2 = $2;
	my $pop = $1;
	$type_checked = 1;
	if (! (($v1 =~ /\$$/ && $v2 =~ /\$$/ && $pop eq "\@POP_RS")
	       || ($v1 !~ /\$$/ && $v2 !~ /\$$/ && $pop eq "\@POP_R"))) {
	  warn "$fname:$l:W:Type mismatch.\n";
	}
      }

      if ($near_enter &&
	  $s =~ /^\s*(R\$?)\s*=\s*([A-Za-z_\$][A-Za-z01-9_\$]*)\s*\:\s*GOSUB\s+(\@PUSH_RS?)\s*$/) {
	my $v1 = $1;
	my $v2 = $2;
	my $push = $3;
	if (($v1 =~ /\$$/ && $v2 =~ /\$$/ && $push eq "\@PUSH_RS")
	    || ($v1 !~ /\$$/ && $v2 !~ /\$$/ && $push eq "\@PUSH_R")) {
	  $NAME_SPACE{$cur_enter} = {} if ! exists $NAME_SPACE{$cur_enter};
	  $NAME_SPACE{$cur_enter}->{$v2} = [$fname, $l];
	  unshift(@enter_push, [$v2, $l]);
#	  print $v2 . ",epush\n";
	} else {
	  if (! $type_checked) {
	    warn "$fname:$l:W:Type mismatch.\n";
	  }
	  $SYNTAX_ERROR = 1;
	}
      } elsif ($near_enter && defined $prev
	       && $s =~ /^\s*GOSUB\s+\@PUSH_RS?\s*$/
	       && $prev =~ /^\s*(R\$?)\s*=\s*([A-Za-z_\$][A-Za-z01-9_\$]*)\s*$/) {
	my $v1 = $1;
	my $v2 = $2;
	my $push = "\@PUSH_RS";
	$push = "\@PUSH_R" if $s !~ /\@PUSH_RS/;
	if (($v1 =~ /\$$/ && $v2 =~ /\$$/ && $push eq "\@PUSH_RS")
	    || ($v1 !~ /\$$/ && $v2 !~ /\$$/ && $push eq "\@PUSH_R")) {
	  $NAME_SPACE{$cur_enter} = {} if ! exists $NAME_SPACE{$cur_enter};
	  $NAME_SPACE{$cur_enter}->{$v2} = [$fname, $l];
	  unshift(@enter_push, [$v2, $l]);
#	  print $v2 . ",epush\n";
	} else {
	  if (! $type_checked) {
	    warn "$fname:$l:W:Type mismatch.\n";
	  }
	  $SYNTAX_ERROR = 1;
	}
      } elsif ($near_enter && $s !~ /^\s*(R\$?)\s*=\s*([A-Za-z_\$][A-Za-z01-9_\$]*)\s*$/) {
	$near_enter = 0;
	$enter_end = $l - 1;
      }


      if (defined $cur_enter
	  && $s =~ /^\s*GOSUB\s+(\@POP_RS?)\s*:\s*([A-Za-z_\$][A-Za-z01-9_\$]*)\s*=\s+(R\$?)\s*$/) {
	my $v1 = $3;
	my $v2 = $2;
	my $pop = $1;
	push(@leave_pop, [$v2, $l, $v1, $pop, $type_checked]);
      } elsif (defined $cur_enter && defined $prev
	       && $prev =~ /^\s*GOSUB\s+\@POP_RS?\s*$/
	       && $s =~ /^\s*([A-Za-z_\$][A-Za-z01-9_\$]*)\s*=\s+(R\$?)\s*$/) {
	my $v1 = $2;
	my $v2 = $1;
	my $pop = "\@POP_RS";
#	print $v2 . " lpop\n";
	$pop = "\@POP_R" if $prev !~ /\@POP_RS/;
	push(@leave_pop, [$v2, $l, $v1, $pop]);
      } elsif ($s =~ /(?:^|\:)\s*GOSUB\s+\@LEAVE\s*$/
	       || $s =~ /(?:^|\:)\s*GOSUB\s+\@CHECK_BP\s*$/) {
	$leaving = 1;
	if ($s =~ /(?:^|\:)\s*ARGNUM\s*=\s*([01-9]+)\s*(?:$|\:)/) {
	  my $an = $1;
	  if (! defined $cur_enter) {
	    warn "$fname:$l:E:\@LEAVE or \@CHECK_BP needs \@ENTER before.\n";
	    $SYNTAX_ERROR = 1;
	  } elsif ($argnum != $an) {
	    warn "$fname:$l:E:ARGNUM is not equal to ARGNUM of \@ENTER.\n";
	    $SYNTAX_ERROR = 1;
	  }
	} elsif (defined $cur_enter) {
	  warn "$fname:$l:E:\@LEAVE or \@CHECK_BP needs ARGNUM.: '$cur_enter'\n";
	  $SYNTAX_ERROR = 1;
	}
	if (@leave_pop > @enter_push) {
	  splice(@leave_pop, scalar(@enter_push));
	} elsif (@enter_push > @leave_pop) {
	  warn "$fname:$l:W:Entering push (" . scalar(@enter_push) . ") is not popped at leaving (" . scalar(@leave_pop) . ").\n";
	}

	if (defined $cur_enter) {
	  if ($enter_begin > $enter_end) {
	    $enter_end = $enter_begin;
	  }
	  if (@leave_pop) {
	    my ($v2, $l2, $v1, $pop) = @{$leave_pop[0]};
	    $ENTER_LEAVE{$cur_enter} = [$enter_begin, $enter_end, $l2, $l];
	  } else {
	    $ENTER_LEAVE{$cur_enter} = [$enter_begin, $enter_end, $l, $l];
	  }
	}

	foreach my $p (@leave_pop) {
	  my ($v2, $l2, $v1, $pop, $type_checked2) = @$p;
	  if (!(($v1 =~ /\$$/ && $v2 =~ /\$$/ && $pop eq "\@POP_RS")
		|| ($v1 !~ /\$$/ && $v2 !~ /\$$/ && $pop eq "\@POP_R"))) {
	    if (! $type_checked) {
	      warn "$fname:$l2:W:Type mismatch.\n";
	    }
	  }
	  my $q = shift(@enter_push);
	  my ($ve, $le) = @$q;
	  if ($ve ne $v2) {
	    warn "$fname:$l2:W:Push-pop mismatch: $ve at $le and $v2 at $l2.\n";
	  }
	}
#	$cur_enter = undef;
	$near_enter = 0;
      } elsif ($s !~ /^\s*GOSUB\s+\@POP_RS?\s*$/) {
	@leave_pop = ();
      }

      if ($s =~ /^\s*\@[A-Za-z]/) {
	if (defined $leaving && ! $leaving) {
	  warn "$fname:$l:E:Entering fuction hasn't left yet.: '$cur_enter'\n";
	  $SYNTAX_ERROR = 1;
	}
	if ($for_next != 0) {
	  warn "$fname:$l:W:The numbers of 'FOR' and 'NEXT' don't meet in '$cur_enter'\n";
	  $SYNTAX_ERROR = 1;
	}
	$cur_enter = undef;
	$leaving = undef;
	$near_enter = 0;
	$for_next = 0;
      }

      if ($s =~ /(?:^|\:)\s*R\$\s*=\s*\"([^\"]+)\"\s*\:.*(?:\:|\s)\s*GOSUB\s*\@ENTER\s*$/i) {
	my $fun = $1;
	if (! defined $prev || $prev !~ /^\s*\Q$fun\E(?:\s|$)/) {
	  warn "$fname:$l:E:\@ENTER of $fun doesn't begin by it.\n";
	  $SYNTAX_ERROR = 1;
	}
	if ($s =~ /(?:^|\:)\s*ARGNUM\s*=\s*([01-9]+)\s*(?:$|\:)/) {
	  $argnum = $1;
	} else {
	  warn "$fname:$l:E:\@ENTER needs ARGNUM.\n";
	  $SYNTAX_ERROR = 1;
	}
	$cur_enter = $fun;
	$near_enter = 1;
	$enter_begin = $l;
	$leaving = 0;
	@enter_push = ();
	@leave_pop = ();
	$NAME_SPACE{$cur_enter} = {} if ! exists $NAME_SPACE{$cur_enter};
#	print $cur_enter . "\n";
      }
      if ($s =~ /^\s*BP\s* =\s*SP\s*-\s*([01-9]+)\s*-\s*([01-9]+)$/) {
	my $an = $1 + $2 - 1;
	if (defined $prev && $prev =~ /^\s*GOSUB\s+\@PUSH_R\s*$/
	    && defined $prev2 && $prev2 =~ /^\s*R\s*=\s*BP\s*$/
	    && defined $prev3 && $prev3 =~ /^\s*(\@[A-Za-z_\$][A-Za-z01-9_\$]+)/) {
	  $argnum = $an;
	  $cur_enter = $1;
	  $near_enter = 1;
	  $enter_begin = $l;
	  @enter_push = ();
	  @leave_pop = ();
	  $NAME_SPACE{$cur_enter} = {} if ! exists $NAME_SPACE{$cur_enter};
#	  print $cur_enter . "\n";
	}
      }
    }

    $prev3 = $prev2;
    $prev2 = $prev;
    $prev = $s;
  }
}


sub parse_define {
  foreach my $k (@define) {
    if ($k =~ /=/) {
      $k = $`;
    }
    my $t = "NVAR";
    if ($k =~ /^\@/) {
      $t = "LABEL";
    } elsif ($k =~ /\$$/) {
      $t = "SVAR";
    }
    $DEC{"GLOBAL"}->{$k} = [] if ! exists $DEC{"GLOBAL"}->{$k};
    push(@{$DEC{"GLOBAL"}->{$k}}, [$t, "COMMANDLINE", 1, "GLOBAL"]);
  }
}

sub lex {
  my ($fname, $l, $s) = @_;
  my @l;
  my $err = 0;

  while ($s !~ /^\s*$/) {
    if ($s =~ /\"/) {
      $s = $';
      push(@l, $`);
      if ($s =~ /\"/) {
	$s = $';
	push(@l, "\"" . $` . "\"");
      } else {
	push(@l, "\"" . $s);
	warn "$fname:$l:W:String is not closed.\n";
#	$err = 1;
	$s = "";
      }
    } else {
      push(@l, $s);
      $s = "";
    }
  }
  my $tail_space = $s;
  if ($tail_space eq "" && @l > 0 && $l[$#l] =~ /,?\s*$/) {
    $tail_space = $&;
  }

  my @s = @l;
  @l = ();
  foreach my $c (@s) {
    if ($c =~ /^\s*\'/ || $c =~ /^\s*REM(?:\s|$)/) {
      $tail_space = $c;
      last;
    }
    if ($c =~ /\"/) {
      push(@l, ["STR", $c]);
      next;
    }

    while ($c !~ /^\s*$/) {
      last if $c =~ /^\s*\'/;
      last if $c =~ /^\s*REM(?:[^A-Za-z01-9_]|$)/;
      $c =~ s/^\s+//;
      if ($c =~ s/^(?:\@|\&[HB])?[A-Za-z01-9_\$]+(?:\.[01-9A-Fa-f]+)?//) {
	my $d = $&;

	if ($d =~ /^[A-Za-z_\$][A-Za-z01-9_\$]*/) {
	  if (length($d) > 16) {
	    warn "$fname:$l:E:Too long variable name: '$d'.\n";
	    $err = 1;
	  } elsif ($d =~ /\$./) {
	    warn "$fname:$l:E:'\$' must be at the end of a variable name: '$d'\n";
	    $err = 1;
	  }
	  if ($d =~ /\$/) {
	    push(@l, ["SNAME", $d]);
	  } else {
	    push(@l, ["NNAME", $d]);
	  }
	} elsif ($d =~ /^\@[A-Za-z_\$][A-Za-z01-9_\$]*/) {
	  if (length($d) > 17) {
	    warn "$fname:$l:E:Too long label name: '$d'.\n";
	    $err = 1;
	  } elsif ($d =~ /\$/) {
	    warn "$fname:$l:E:'\$' in the label '$d'.\n";
	    $err = 1;
	  }
	  push(@l, ["LABEL", $d]);
	} elsif ($d =~ /^[01-9]/) {
	  if ($d !~ /^[01-9]+(?:\.[01-9]+)?$/) {
	    warn "$fname:$l:E:Wrong form number: '$d'.\n";
	    $err = 1;
	  }
	  push(@l, ["NUM", $d]);
	} elsif ($d =~ /^\&H/i) {
	  if ($d =~ /[a-fh]/) {
	    warn "$fname:$l:W:Hex number must be in upper case: '$d'.\n";
#	    $err = 1;
	  } elsif ($d !~ /^\&H[01-9A-F]+$/) {
	    warn "$fname:$l:E:Wrong form number: '$d'.\n";
	    $err = 1;
	  }
	  push(@l, ["NUM", $d]);
	} elsif ($d =~ /^\&B/i) {
	  if ($d =~ /[b]/) {
	    warn "$fname:$l:W:'&B' must be in upper case: '$d'.\n";
#	    $err = 1;
	  } elsif ($d !~ /^\&B[01]+$/) {
	    warn "$fname:$l:E:Wrong form number: '$d'.\n";
	    $err = 1;
	  }
	  push(@l, ["NUM", $d]);
	} else {
	  warn "$fname:$l:W:Illegal expression \"$d\".\n";
	  push(@l, ["ERR", $d]);
	}
      } elsif ($c =~ s/^(?:[>=<!]=|[<=>:\,\+\-\*\/\%!\(\)\[\]\;\?])//) {
	my $d = $&;
	if ($d eq ":") {
	  push(@l, ["COLON", $d]);
	} elsif ($d eq "(" || $d eq "[") {
	  push(@l, ["OPEN", $d]);
	} elsif ($d eq ")" || $d eq "]") {
	  push(@l, ["CLOSE", $d]);
	} else {
	  push(@l, ["OP", $d]);
	}
      } elsif ($c =~ s/^(?:\&\&|\|\||[\&\|\#\\\`])//) {
	my $d = $&;
	push(@l, ["OP", $d]);
	warn "$fname:$l:E:Illegal expression \"$d\".\n";
	$err= 1;
      } else {
	$c =~ s/\s+.*$//;
	warn "$fname:$l:E:Illegal expression \"$c\".\n";
	$err = 1;
	$c = "";
      }
    }
  }
  if ((grep {uc($_->[1]) eq "DATA"} @l) && $tail_space ne "") {
    warn "$fname:$l:W:'DATA' allows no tailing space or remark. I don't know why.\n";
#    $err = 1;
  }

  $SYNTAX_ERROR = 1 if $err;
  return () if $err;
  return @l;
}

sub reduce_type {
  my ($fname, $l, $cur_enter, @l) = @_;
  my $prev;
  my @c;
  return "U" if @l == 0;

  while (@l) {
    my $c = shift(@l);
    if (exists $UNARY{$c} && (! defined $prev || $prev !~ /^[A-Z]$/i)) {
      if (@l == 0) {
	warn "$fname:$l:E:Unary operator '$c' at tail.\n";
	$SYNTAX_ERROR = 1;
	return "E";
      } else {
	if (exists $UNARY{$l[0]}) {
	  next;
	} elsif ($l[0] =~ /^[A-Z]$/i) {
	  my $d = shift(@l);
	  if (uc($d) ne "N") {
	    warn "$fname:$l:E:Type mismatch about the argument of '$c'.\n";
	    $SYNTAX_ERROR = 1;
	    return "E";
	  }
	  push(@c, $d);
	  $prev = $d;
	  next;
	} else {
	  warn "$fname:$l:E:Operators continue: '$c $l[0]'.\n";
	  $SYNTAX_ERROR = 1;
	  return "E";
	}
      }
    } else {
      push(@c, $c);
    }
    $prev = $c;
  }
  @l = @c;
  @c = ();

  my @opi = grep {exists $BINARY{$l[$_]}} (0 .. $#l);
  @opi = sort {$BINARY{$l[$a]} <=> $BINARY{$l[$b]}} @opi;
  while (@opi) {
    my $opi = shift(@opi);
    if (! ($opi > 0 && $opi < $#l)) {
      warn "$fname:$l:E:Operators needs 2 arguments '$l[$opi]'.\n";
      $SYNTAX_ERROR = 1;
      return "E";
    } else {
      my $op = $l[$opi];
      my $t1 = $l[$opi - 1];
      my $t2 = $l[$opi + 1];
      my $t= "E";
      if ($t1 !~ /^[A-Z]$/i || $t2 !~ /^[A-Z]$/i) {
	warn "$fname:$l:E:Operators continue: '$t1 $op $t2'.\n";
	$SYNTAX_ERROR = 1;
	return "E";
      }
      if ($op eq "*") {
	if (uc($t1) eq "S" && uc($t2) eq "N") {
	  $t = "S";
	} elsif (uc($t1) eq "N" && uc($t2) eq "N") {
	  $t = "N";
	} else {
	  $t = "E";
	}
      } elsif ($op eq "+") {
	if (uc($t1) eq "S" && uc($t2) eq "S") {
	  $t = "S";
	} elsif (uc($t1) eq "N" && uc($t2) eq "N") {
	  $t = "N";
	} else {
	  $t = "E";
	}
      } elsif (grep {$op eq $_} ("+", "==", "!=", ">", "<", ">=", "<=")) {
	if (uc($t1) eq "S" && uc($t2) eq "S") {
	  $t = "N";
	} elsif (uc($t1) eq "N" && uc($t2) eq "N") {
	  $t = "N";
	} else {
	  $t = "E";
	}
      } else {
	if (uc($t1) eq "N" && uc($t2) eq "N") {
	  $t = "N";
	} else {
	  $t = "E";
	}
      }
      if ($t eq "E") {
	warn "$fname:$l:E:Numbers and strings are mixed in one context\n";
	$SYNTAX_ERROR = 1;
	return "E";
      }
      splice(@l, $opi - 1, 3, $t);
      for (my $i = 0; $i < @opi; $i++) {
	if ($opi[$i] > $opi) {
	  $opi[$i] -= 2;
	}
      }
    }
  }
  if (@l != 1) {
    warn "$fname:$l:E:Missing operator.\n";
    $SYNTAX_ERROR = 1;
    return "E";
  }
  return $l[0];
}

sub check_occur {
  my ($fname, $l, $cur_enter, @l) = @_;
  my $err = 0;
  my @type;
  while (@l) {
    my $c = shift(@l);
    my ($t, $v) = @$c;
    if ($t eq "(") {
      my @u = @{$c};
      shift(@u);
      shift(@u);
      push(@type, check_occur($fname, $l, $cur_enter, @u));
      next;
    }
    if ($t eq "[") {
      warn "$fname:$l:E:\"[\" is not allowed, must be \"(\".\n";
      $SYNTAX_ERROR = 1;
      my @u = @{$c};
      shift(@u);
      shift(@u);
      push(@type, check_occur($fname, $l, $cur_enter, @u));
      next;
    }
    if ($v eq "=") {
      warn "$fname:$l:E:\"=\" is not allowed in the context, maybe \"==\".\n";
      $SYNTAX_ERROR = 1;
    }

    if (exists $RESERVED{uc($v)}) {
      if ($RESERVED{uc($v)} eq "F") {
	if (@l < 1 || $l[0]->[0] ne "(") {
	  warn "$fname:$l:E:Function needs (): \"$v\"\n";
	  $SYNTAX_ERROR = 1;
	} else {
	  my @u = @{$l[0]};
	  shift(@l);
	  shift(@u);
	  shift(@u);
	  my $t2 = check_args($fname, $l, $cur_enter, $v, @u);
	  if ($t2 =~ /E/) {
	    $err = 1;
	  } else {
	    my $t = ($v =~ /\$$/)? "S" : "N";
	    push(@type, $t);
	    check_type($fname, $l, $cur_enter, uc($v), $t2);
	    if (uc($v) eq "SUBST\$" && $u[$#u]->[1] eq "\"\"") {
	      warn "$fname:$l:W:'SUBST\$' doesn't work if the last argument is \"\".\n";
	    }
	  }
	}
      } elsif ($RESERVED{uc($v)} eq "V") {
	if (@l > 0 && ($l[0]->[0] eq "(" || $l[0]->[0] eq "]")) {
	  warn "$fname:$l:E:Built-in variable is not a function: \"$v\"\n";
	  $SYNTAX_ERROR = 1;
	}
	my $t = ($v =~ /\$$/)? "S" : "N";
	push(@type, $t);
      } elsif ($RESERVED{uc($v)} eq "S"
	       || $RESERVED{uc($v)} eq "I"
	       || $RESERVED{uc($v)} eq "R") {
	warn "$fname:$l:E:Imperative is not a function: \"$v\"\n";
	$SYNTAX_ERROR = 1;
      } elsif ($RESERVED{uc($v)} eq "OP") {
	push(@type, uc($v));
      }
    } elsif ($t eq "NNAME") {
      if (@l > 0 && ($l[0]->[0] eq "(" || $l[0]->[0] eq "[")) {
	$OCC{$cur_enter}->{$v} = [] if ! exists $OCC{$cur_enter}->{$v};
	push(@{$OCC{$cur_enter}->{$v}}, ["NDIM", $fname, $l]);
	my @u = @{$l[0]};
	shift(@l);
	shift(@u);
	shift(@u);
	my $t = check_args($fname, $l, $cur_enter, $v . "[]", @u);
	if ($t =~ "E") {
	  $err = 1;
	} else {
	  if (uc($t) ne "N" && uc($t) ne "N,N") {
	    warn "$fname:$l:E:Type mismatch in \"$v\[\]\"\n";
	    $SYNTAX_ERROR = 1;
	  }
	  push(@type, "n");
	}
      } else {
	$OCC{$cur_enter}->{$v} = [] if ! exists $OCC{$cur_enter}->{$v};
	push(@{$OCC{$cur_enter}->{$v}}, ["NVAR", $fname, $l]);
	push(@type, "n");
      }
    } elsif ($t eq "SNAME") {
      if (@l > 0 && ($l[0]->[0] eq "(" || $l[0]->[0] eq "[")) {
	$OCC{$cur_enter}->{$v} = [] if ! exists $OCC{$cur_enter}->{$v};
	push(@{$OCC{$cur_enter}->{$v}}, ["SDIM", $fname, $l]);
	my @u = @{$l[0]};
	shift(@l);
	shift(@u);
	shift(@u);
	my $t = check_args($fname, $l, $cur_enter, $v . "[]", @u);
	if ($t =~ /E/) {
	  $err = 1;
	} else {
	  if (uc($t) ne "N" && uc($t) ne "N,N") {
	    warn "$fname:$l:E:Type mismatch in \"$v\[\]\"\n";
	    $SYNTAX_ERROR = 1;
	  }
	  push(@type, "s");
	}
      } else {
	$OCC{$cur_enter}->{$v} = [] if ! exists $OCC{$cur_enter}->{$v};
	push(@{$OCC{$cur_enter}->{$v}}, ["SVAR", $fname, $l]);
	push(@type, "s");
      }
    } elsif ($t eq "LABEL") {
      $OCC{$cur_enter}->{$v} = [] if ! exists $OCC{$cur_enter}->{$v};
      push(@{$OCC{$cur_enter}->{$v}}, ["LABEL", $fname, $l]);
      push(@type, "l");
    } elsif ($t eq "OP") {
      push(@type, uc($v));
    } elsif ($t eq "NUM" || $t eq "STR") {
      my $t = substr($t, 0, 1);
      push(@type, $t);
    } else {
      die "UNREACHEABLE_CODE: $t:$v";
    }
  }

  return "E" if $err;
  return reduce_type($fname, $l, $cur_enter, @type);
}

sub check_args {
  my ($fname, $l, $cur_enter, $cur_fun, @l) = @_;
  my $type = "";

  while (@l) {
    my $comma = pl_index(",", @l);
    my $semi = pl_index(";", @l);
    my $i = $comma;
    if ($comma == -1 || ($semi != -1 && $semi < $i)) {
      $i = $semi;
    }
    my @c;
    if ($i == -1) {
      @c = @l;
      @l = ();
      $comma = undef;
    } else {
      @c = splice(@l, 0, $i);
      $comma = shift(@l)->[1];
    }
    my $t = check_occur($fname, $l, $cur_enter, @c);
    if ($t eq "U") {
      if (defined $comma) {
	warn "$fname:$l:E:'$comma' at wrong place.\n";
	$SYNTAX_ERROR = 1;
      } else {
	$t = "";
      }
    }
    $type .= $t;
    $type .= $comma if defined $comma;
  }
  return $type;
}


sub pl_index {
  my ($s, @l) = @_;
  for (my $i = 0; $i < @l; $i++) {
    return $i if $s eq uc($l[$i]->[1]);
  }
  return -1;
}

sub parse_paren {
  my (@l) = @_;
  my @open;
  my $cur = [];
  while (@l) {
    my $c = shift(@l);
    if ($c->[1] eq "(" || $c->[1] eq "[") {
      unshift(@open, [$c->[1], $cur]);
      $cur = [];
    } elsif ($c->[1] eq ")" || $c->[1] eq "]") {
      if (! @open) {
	return ();
      }
      my $o = shift(@open);
      if (($o->[0] eq "(" && $c->[1] eq ")")
	  || ($o->[0] eq "[" && $c->[1] eq "]")) {
	push(@{$o->[1]}, [$o->[0], $o->[0], @$cur]);
	$cur = $o->[1];
      } else {
	return ();
      }
    } else {
      push(@$cur, $c);
    }
  }
  return @$cur;
}

sub check_vdec {
  my ($fname, $l, $cur_enter, @l) = @_;
  my $t;
  $t = $l[0]->[0] if @l;
  my $v = "";
  $v = $l[0]->[1] if @l;

  if (@l == 1) {
    if (exists $RESERVED{uc($v)}) {
      warn "$fname:$l:E:Built-in name cannot be overwritten: \"$v\".\n";
      $SYNTAX_ERROR = 1;
    }
    if ($t eq "NNAME") {
      $DEC{$cur_enter}->{$v} = [] if ! exists $DEC{$cur_enter}->{$v};
      push(@{$DEC{$cur_enter}->{$v}}, ["NVAR", $fname, $l, $cur_enter]);
    } elsif ($t eq "SNAME") {
      $DEC{$cur_enter}->{$v} = [] if ! exists $DEC{$cur_enter}->{$v};
      push(@{$DEC{$cur_enter}->{$v}}, ["SVAR", $fname, $l, $cur_enter]);
    } else {
      warn "$fname:$l:E:Illegal declaration \"$v\".\n";
      $SYNTAX_ERROR = 1;
    }
    check_occur($fname, $l, $cur_enter, @l);
  } elsif (@l == 2 && ($l[1]->[0] eq "(" || $l[1]->[0] eq "[")) {
    if (exists $RESERVED{uc($v)}) {
      warn "$fname:$l:E:Built-in name cannot be overwritten: \"$v\".\n";
      $SYNTAX_ERROR = 1;
    }

    if ($t eq "NNAME") {
      $DEC{$cur_enter}->{$v} = [] if ! exists $DEC{$cur_enter}->{$v};
      push(@{$DEC{$cur_enter}->{$v}}, ["NDIMVAR", $fname, $l, $cur_enter]);
    } elsif ($t eq "SNAME") {
      $DEC{$cur_enter}->{$v} = [] if ! exists $DEC{$cur_enter}->{$v};
      push(@{$DEC{$cur_enter}->{$v}}, ["SDIMVAR", $fname, $l, $cur_enter]);
    } else {
      warn "$fname:$l:E:Illegal DIM substitution \"$v\".\n";
      $SYNTAX_ERROR = 1;
    }
    check_occur($fname, $l, $cur_enter, @l);
  } else {
    warn "$fname:$l:E:Illegal declaration: \"$v\".\n";
    $SYNTAX_ERROR = 1;
  }
}

sub check_dec {
  my ($fname, $l, $cur_enter, @l) = @_;
  my $t;
  $t = $l[0]->[0] if @l;
  my $v = "";
  $v = $l[0]->[1] if @l;

  my $eqi = pl_index("=", @l);
  if ($eqi != -1) {
    check_vdec($fname, $l, $cur_enter, @l[0 .. ($eqi - 1)]);

    if (@l <= $eqi + 1) {
      warn "$fname:$l:E:Illegal declaration \"$v\".\n";
      $SYNTAX_ERROR = 1;
    } else {
      my $t2 = check_occur($fname, $l, $cur_enter, @l[$eqi + 1 .. $#l]);
      if (! (($t eq "SNAME" && uc($t2) eq "S")
	     || ($t eq "NNAME" && uc($t2) eq "N"))) {
	warn "$fname:$l:E:Type mismatch at the substitution of \"$v\".\n";
	$SYNTAX_ERROR = 1;
      }
    }
  } else {
    warn "$fname:$l:E:Illegal declaration: \"$v\".\n";
    $SYNTAX_ERROR = 1;
  }
}

# $type is type characters separated by a comma or semicolon.
# Each type character is:
# S:STRING, N:NUMBER, s:STRING variable, n:NUMBER variable,
# l:LABEL or U: No arguments.
# The type of READ-like imperative may have enclosing "(" ")" at first.
sub check_type { # for future implement.
  my ($fname, $l, $cur_enter, $f, $type) = @_;

#  print "$f:$type\n"; # for DEBUG

  if ($f eq "INSTR" &&  uc($type) eq "S,S,N") {
    warn "$fname:$l:W:INSTR needs (NUMBER, STRING, STRING) as arguments, not (STRING, STRING, NUMBER). The manual is wrong.\n";
#    $SYNTAX_ERROR = 1;
  }
}

sub parse {
  my ($fname, $l, $cur_enter, @l) = @_;
  $cur_enter = "GLOBAL" if ! defined $cur_enter;
  $DEC{$cur_enter} = {} if ! exists $DEC{$cur_enter};
  $OCC{$cur_enter} = {} if ! exists $OCC{$cur_enter};

  my $prev_end = "LINE";
  my $cur_end = "LINE";
  my $in_if = 0;

  while (@l) {
    my @c;
    my $done = 0;
    for (my $i = 0; $i < @l; $i++) {
      if ($l[$i]->[0] eq "COLON"
	  || uc($l[$i]->[1]) eq "THEN"
	  || uc($l[$i]->[1]) eq "ELSE") {
	if ($l[$i]->[0] eq "COLON") {
	  $cur_end = "COLON";
	} else {
	  $cur_end = uc($l[$i]->[1]);
	}
	$done = 1;
	@c = splice(@l, 0, $i);
	my $d = shift(@l);
	if ($d->[0] ne "COLON") {
	  if (@l == 0) {
	    warn "$fname:$l:E:'$d->[1]' needs something.\n";
	    $SYNTAX_ERROR = 1;
	  }
	}
	last;
      }
    }
    if (! $done) {
      @c = @l;
      @l = ();
      $cur_end = "LINE";
    }

    next if !@c;
    @c = parse_paren(@c);
    if (! @c) {
      warn "$fname:$l:E:Parentheses don't match.\n";
      $SYNTAX_ERROR = 1;
      next;
    }

    my ($t, $v) = @{$c[0]};
    if (@l == 0 && uc($v) ne "PRINT" && $c[$#c]->[1] eq ";") {
      warn "$fname:$l:W:Semicolon \";\" at the end of line may be wrong.\n";
    }
    if ($t eq "LABEL" && @c == 1) {
      if ($prev_end eq "THEN" || $prev_end eq "ELSE") {
	check_occur($fname, $l, $cur_enter, @c);
      } elsif ($prev_end eq "COLON") {
	warn "$fname:$l:E:Label must be at the line beginning: \"$v\".\n";
	$SYNTAX_ERROR = 1;
      } else {
	if (exists $DEC{$cur_enter}->{$v}) {
	  warn "$fname:$l:E:Already in use \"$v\".\n";
	  $SYNTAX_ERROR = 1;
	}
	if ($v =~ /^\@_/) {
	  $DEC{$cur_enter}->{$v} = [] if ! exists $DEC{$cur_enter}->{$v};
	  push(@{$DEC{$cur_enter}->{$v}}, ["LABEL", $fname, $l, $cur_enter]);
	} else {
	  $DEC{"GLOBAL"}->{$v} = [] if ! exists $DEC{"GLOBAL"}->{$v};
	  push(@{$DEC{"GLOBAL"}->{$v}}, ["LABEL", $fname, $l, $cur_enter]);
	}
      }
    } elsif (@c >= 2 && $c[1]->[1] eq "=") {
      check_dec($fname, $l, $cur_enter, @c);
    } elsif (@c >= 3 && ($c[1]->[0] eq "(" || $c[1]->[0] eq "[")
	     && $c[2]->[1] eq "=") {
      check_dec($fname, $l, $cur_enter, @c);
    } elsif (uc($v) eq "FOR") {
      my $to = pl_index("TO", @c);
      my $step = pl_index("STEP", @c);
      if ($to == -1 || ($step != -1 && $to > $step)) {
	warn "$fname:$l:E:\"FOR\" needs \"TO\".\n";
	$SYNTAX_ERROR = 1;
	next;
      }
      if (@c <= 3) {
	warn "$fname:$l:E:\"FOR\" needs \"=\".\n";
	$SYNTAX_ERROR = 1;
	next;
      }
      check_dec($fname, $l, $cur_enter, @c[1 .. ($to - 1)]);
      my $type;
      if ($step == -1) {
	$type = check_occur($fname, $l, $cur_enter, @c[($to + 1) .. $#c]);
      } else {
	$type = check_occur($fname, $l, $cur_enter, @c[($to + 1) .. ($step - 1)]);
	$type .= "," . check_occur($fname, $l, $cur_enter, @c[($step + 1) .. $#c]);
      }
      check_type($fname, $l, $cur_enter, "FOR", $type);
    } elsif (exists $RESERVED{uc($v)}
	     && $RESERVED{uc($v)} eq "R") {
      my @d = @c;
      shift(@d);
      my $type = "";
      if (@d > 0 && $d[0]->[0] eq "(") {
	my @u = @{$d[0]};
	shift(@d);
	shift(@u);
	shift(@u);
	$type = check_args($fname, $l, $cur_enter, $v, @u);
	$type = "(" . $type . ")";
	if (@d) {
	  my $c = shift(@d);
	  $type .= ",";
	  if ($c->[1] ne ",") {
	    warn "$fname:$l:E:Comma is needed.\n";
	    $SYNTAX_ERROR = 1;
	    next;
	  }
	  if (! @d) {
	    warn "$fname:$l:E:Ended by comma.\n";
	    $SYNTAX_ERROR = 1;
	    next;
	  }
	}
      }
      my $semi = pl_index(";", @d);
      if ($semi != -1) {
	my $t2 = check_ocur($fname, $l, $cur_enter, @d[0 .. ($semi - 1)]);
	if (uc($t2) ne "S") {
	  warn "$fname:$l:W:Type mismatch before ';'.\n";
	}
	@d = @d[($semi + 1) .. $#d];
	$type .= "S;";
      }
      my $done = 1;
      while (@d) {
	my $comma = pl_index(",", @d);
	if ($comma == -1) {
	  check_vdec($fname, $l, $cur_enter, @d);
	  if ($d[0]->[0] eq "SNAME" || $d[0]->[0] eq "NNAME") {
	    $type .= lc(substr($d[0]->[0], 0, 1));
	  } else {
	    $type .= "E";
	  }
	  @d = ();
	} else {
	  check_vdec($fname, $l, $cur_enter, @d[0 .. ($comma - 1)]);
	  if ($d[0]->[0] eq "SNAME" || $d[0]->[0] eq "NNAME") {
	    $type .= lc(substr($d[0]->[0], 0, 1)) . ",";
	  } else {
	    $type .= "E,";
	  }
	  @d = @d[($comma + 1) .. $#d];
	  if (! @d) {
	    warn "$fname:$l:E:Ended by comma.\n";
	    $SYNTAX_ERROR = 1;
	  }
	}
      }
      check_type($fname, $l, $cur_enter, uc($v), $type);
    } elsif (uc($v) eq "DIM") {
      my @d = @c;
      shift(@d);
      while (@d) {
	my $vc = shift(@d);
	my $v = $vc->[1];
	if ($vc->[0] eq "NNAME") {
	  if (exists_dec($cur_enter, $v, "NDIM")) {
	    warn "$fname:$l:E:Already in use \"$v\".\n";
	    $SYNTAX_ERROR = 1;
	  }
	  $DEC{$cur_enter}->{$v} = [] if ! exists $DEC{$cur_enter}->{$v};
	  push(@{$DEC{$cur_enter}->{$v}}, ["NDIM", $fname, $l, $cur_enter]);
	} elsif ($vc->[0] eq "SNAME") {
	  if (exists_dec($cur_enter, $v, "SDIM")) {
	    warn "$fname:$l:E:Already in use \"$v\".\n";
	    $SYNTAX_ERROR = 1;
	  }
	  $DEC{$cur_enter}->{$v} = [] if ! exists $DEC{$cur_enter}->{$v};
	  push(@{$DEC{$cur_enter}->{$v}}, ["SDIM", $fname, $l, $cur_enter]);
	} else {
	  warn "$fname:$l:E:Illegal DIM declaration \"$v\".\n";
	  $SYNTAX_ERROR = 1;
	  last;
	}
	if ($d[0]->[0] eq "(" || $d[0]->[0] eq "[") {
	  my $n = shift(@d);
	  check_occur($fname, $l, $cur_enter, $vc, $n);
	} else {
	  warn "$fname:$l:E:Illegal DIM declaration \"$v\".\n";
	  $SYNTAX_ERROR = 1;
	  last;
	}
	if (@d) {
	  my $c = shift(@d);
	  if ($c->[1] ne ",") {
	    warn "$fname:$l:E:Illegal DIM declaration \"$v\".\n";
	    $SYNTAX_ERROR = 1;
	    last;
	  }
	  if (! @d) {
	    warn "$fname:$l:E:Ended by comma.\n";
	    $SYNTAX_ERROR = 1;
	    last;
	  }
	}
      }
    } elsif (uc($v) eq "ON") {
      my $i = pl_index("GOSUB", @c);
      if ($i == -1) {
	$i = pl_index("GOTO", @c);
      }
      if ($i == -1) {
	warn "$fname:$l:E:\"ON\" needs \"GOSUB\" or \"GOTO\".\n";
	$SYNTAX_ERROR = 1;
	next;
      }
      my $t1 = check_occur($fname, $l, $cur_enter, @c[1 .. $i - 1]);
      my $type = check_args($fname, $l, $cur_enter, "ON", @c[$i + 1 .. $#c]);
      check_type($fname, $l, $cur_enter, "ON", "$t1,$type");
    } elsif (uc($v) eq "IF") {
      my $i = pl_index("GOTO", @c);
      my $t1;
      $in_if = 1;
      if ($i == -1) {
	$t1 = check_occur($fname, $l, $cur_enter, @c[1 .. $#c]);
	if ($cur_end ne "THEN") {
	  warn "$fname:$l:E:'IF' needs 'THEN' or 'GOTO'.\n";
	  $SYNTAX_ERROR = 1;
	}
      } else {
	$in_if = 2;
	$t1 = check_occur($fname, $l, $cur_enter, @c[1 .. $i - 1]);
	my $t2 = check_args($fname, $l, $cur_enter, "GOTO", @c[$i + 1 .. $#c]);
	check_type($fname, $l, $cur_enter, "GOTO", $t2);
      }
      if (uc($t1) ne "N") {
	warn "$fname:$l:E:'IF' needs BOOLEAN or NUMBER.\n";
	$SYNTAX_ERROR = 1;
      }
    } elsif (exists $RESERVED{uc($v)}
	     && $RESERVED{uc($v)} eq "I") {
      my $type = check_args($fname, $l, $cur_enter, uc($v), @c[1 .. $#c]);
      check_type($fname, $l, $cur_enter, uc($v), $type);
    } else {
      warn "$fname:$l:E:Illegal imperative \"$v\".\n";
      $SYNTAX_ERROR = 1;
      next;
    }
  } continue {
    $prev_end = $cur_end;
    if ($prev_end eq "THEN") {
      if ($in_if != 1) {
	warn "$fname:$l:E:Misplaced 'THEN'.\n";
	$SYNTAX_ERROR = 1;
      } else {
	$in_if = 2;
      }
    } elsif ($prev_end eq "ELSE") {
      if ($in_if != 2) {
	warn "$fname:$l:E:Misplaced 'ELSE'.\n";
	$SYNTAX_ERROR = 1;
      } else {
	$in_if = 3;
      }
    }
  }
}


sub compare_fname_line {
  my ($fa, $la, $fb, $lb) = @_;
  my $na = -1;
  my $nb = -1;
  for (my $i = 0; $i < @PRG; $i++) {
    if ($PRG[$i] eq $fa) {
      $na = $i;
      last;
    }
  }
  for (my $i = 0; $i < @PRG; $i++) {
    if ($PRG[$i] eq $fb) {
      $nb = $i;
      last;
    }
  }
  my $r = $na <=> $nb;
  return $r if $r != 0;
  return $la <=> $lb;
}

sub exists_push {
  my ($e, $v) = @_;
  if (exists $NAME_SPACE{$e} && exists $NAME_SPACE{$e}->{$v}) {
    return 1;
  } elsif (exists_dec("GLOBAL", $v, "SVAR", "NVAR", "SDIM", "NDIM")) {
    return 1;
  }
  return 0;
}


sub exists_dec {
  my ($e, $v, @t) = @_;
  if (exists $DEC{"GLOBAL"}->{$v}) {
    foreach my $p (@{$DEC{"GLOBAL"}->{$v}}) {
      if (grep {$p->[0] eq $_} @t) {
	return 1;
      }
    }
  }
  return 0 if ! $CHECK_ENTER_LEAVE || $e eq "GLOBAL";
  if (exists $DEC{$e}->{$v}) {
    foreach my $p (@{$DEC{$e}->{$v}}) {
      if (grep {$p->[0] eq $_} @t) {
	if (exists $ENTER_LEAVE{$e}) {
	  my $l = $p->[2];
	  my ($eb, $ee, $lb, $le) = @{$ENTER_LEAVE{$e}};
	  next if (($eb <= $l && $l <= $ee) || ($lb <= $l && $l <= $le));
	}
	return 1;
      }
    }
  }
  return 0;
}


sub analyze_occ {
  if (! $CHECK_ENTER_LEAVE) {
    foreach my $e (keys %DEC) {
      next if $e eq "GLOBAL";
      foreach my $v (keys %{$DEC{$e}}) {
	my @l = @{$DEC{$e}->{$v}};
	$DEC{"GLOBAL"}->{$v} = [] if ! exists $DEC{"GLOBAL"}->{$v};
	push(@{$DEC{"GLOBAL"}->{$v}}, @l);
      }
    }
  }
  my @err;
  my @warn;

  foreach my $e (keys %DEC) {
    foreach my $v (keys %{$DEC{$e}}) {
      foreach my $p (@{$DEC{$e}->{$v}}) {
	my ($t, $fname, $l) = @$p;
	if ($t eq "SDIMVAR") {
	  if (! exists_dec($e, $v, "SDIM")) {
	    push(@warn, [$fname, $l,
			"No declaration of DIM for substitution of \"$v\"."]);
	  }
	}
	if ($t eq "NDIMVAR") {
	  if (! exists_dec($e, $v, "NDIM")) {
	    push(@warn, [$fname, $l,
			"No declaration of DIM for substitution of \"$v\"."]);
	  }
	}
	if ($CHECK_ENTER_LEAVE && $e ne "GLOBAL"
	    && ($t eq "SVAR" || $t eq "NVAR")) {
	  if (! exists_push($e, $v)) {
	    push(@err, [$fname, $l,
			"No push for local declaration of \"$v\"."]);
	  }
	}
	if ($CHECK_ENTER_LEAVE && $e ne "GLOBAL"
	    && ($t eq "SDIM" || $t eq "NDIM")) {
	  push(@warn, [$fname, $l,
		      "Local declaration of DIM is not allowed."]);
	}
      }
    }
  }

  my %gocc;
  foreach my $e (keys %OCC) {
    my ($eb, $ee, $lb, $le);
    ($eb, $ee, $lb, $le) = @{$ENTER_LEAVE{$e}} if exists $ENTER_LEAVE{$e};
    my %checked;
    foreach my $v (keys %{$OCC{$e}}) {
      my @l = @{$OCC{$e}->{$v}};
      next if exists $RESERVED{uc($v)};
      $gocc{$v} = [] if ! exists $gocc{$v};
      push(@{$gocc{$v}},  @l);
      if (@l > 0 && $l[0]->[0] ne "LABEL" && $e ne "GLOBAL"
	  && exists $ENTER_LEAVE{$e} && exists $NAME_SPACE{$e}->{$v}) {
	my @m;
	my ($fst_t, $fst_fname, $fst_l) = @{$l[0]};
	foreach my $p (@l) {
	  my ($t, $fname, $l) = @$p;
	  next if (($eb <= $l && $l <= $ee) || ($lb <= $l && $l <= $le));
	  push(@m, $p);
	}
	if (@m == 0) {
	  push(@warn, [$fst_fname, $fst_l,
		       "Local variable is pushed, but not used: \"$v\" in $e."]);
	  next;
	} else {
	  my ($fst_t, $fst_fname, $fst_l) = @{$m[0]};
	  if (! (grep {$fst_fname ne $_->[1] || $fst_l ne $_->[2]} @m)) {
	    push(@warn, [$fst_fname, $fst_l,
			 "Occured only once, locally: \"$v\"."]);
	  }
	}
      }
      foreach my $p (@l) {
	my ($t, $fname, $l) = @$p;
	if (exists $ENTER_LEAVE{$e}) {
	  next if (($eb <= $l && $l <= $ee) || ($lb <= $l && $l <= $le));
	}
	if ($t eq "NVAR") {
	  if (! exists $checked{$v} && ! exists_dec($e, $v, "NVAR")) {
	    push(@warn, [$fname, $l,
			 "No declaration or substitution of \"$v\" in $e."]);
	    $checked{$v} = 1;
	  }
	} elsif ($t eq "SVAR") {
	  if (! exists $checked{$v} && ! exists_dec($e, $v, "SVAR")) {
	    push(@warn, [$fname, $l,
			 "No declaration or substitution of \"$v\" in $e."]);
	    $checked{$v} = 1;
	  }
	} elsif (! exists $checked{$v . "[]"} && $t eq "NDIM") {
	  if (! exists_dec($e, $v, "NDIM", "NDIMVAR")) {
	    push(@warn, [$fname, $l,
			 "No declaration or substitution of \"$v\[\]\" in $e."]);
	    $checked{$v . "[]"} = 1;
	  }
	} elsif (! exists $checked{$v . "[]"} && $t eq "SDIM") {
	  if (! exists_dec($e, $v, "SDIM", "SDIMVAR")) {
	    push(@warn, [$fname, $l,
			 "No declaration or substitution of \"$v\[\]\" in $e."]);
	    $checked{$v . "[]"} = 1;
	  }
	} elsif (! exists $checked{$v} && $t eq "LABEL") {
	  if (! exists_dec($e, $v, "LABEL") && ! exists $NAME_SPACE{$v}) {
	    push(@warn, [$fname, $l,
			"No declaration of \"$v\" in $e."]);
	    $checked{$v} = 1;
	  }
	}
      }
    }
  }

  if ($CHECK_GLOBAL_ONCE) {
    foreach my $v (keys %gocc) {
      my @l = @{$gocc{$v}};
      next if exists $BUILTIN_GLOBAL{$v};
      if (@l > 0 && exists_dec("GLOBAL", $v, "SVAR", "NVAR", "SDIM", "NDIM")) {
	my $fst = $l[0];
	if (! (grep {$fst->[1] ne $_->[1] || $fst->[2] ne $_->[2]} @l)) {
	  push(@warn, [$fst->[1], $fst->[2],
		       "Occured only once: \"$v\"."]);
	}
      }
    }
  }

  foreach my $p (sort {compare_fname_line($a->[0], $a->[1], $b->[0], $b->[1])} (@err)) {
    my ($fname, $l, $msg) = @$p;
    warn "$fname:$l:E:$msg\n";
  }

  if (! @err) {
    foreach my $p (sort {compare_fname_line($a->[0], $a->[1], $b->[0], $b->[1])} (@warn)) {
      my ($fname, $l, $msg) = @$p;
      warn "$fname:$l:W:$msg\n";
    }
  }

  $SYNTAX_ERROR = 1 if @err;
  return;
}


