#!/usr/local/bin/perl
$RCS_Id = '$Id: parr.pl,v 5.11 1995/12/28 22:34:12 jv Exp $ ';

# Author          : Johan Vromans
# Created On      : Aug 15 1991
# Based On        : parr.pl by jgreely@cis.ohio-state.edu, 89/10/23
# Last Modified By: Johan Vromans
# Last Modified On: Thu Dec 28 23:32:55 1995
# Update Count    : 94
# Status          : OK

################ Common stuff ################

$my_package = "PerlRef";
($my_name, $my_version) = $RCS_Id =~ /: (.+).pl,v ([\d.]+)/;
$my_version .= '*' if length('$Locker:  $ ') > 12;

################ Program parameters ################

&options;

################ Presets ################

$verbose = $opt_verbose;
$debug = $opt_debug;
$trace = $opt_test || $opt_trace | $opt_debug;
$TMPDIR = $ENV{"TMPDIR"} || "/usr/tmp";
$TMPDIR = "/tmp" unless -d $TMPDIR;

################ The Process ################

# Read the input file, and split into parts.
# We gather some info in the fly.
$file = "$TMPDIR/p$$.header";
@files = ($file);
$sheet = 0;

open (FILE, ">$file") || die ("$file: $!\n");

while ( <> ) {
    # Hack to use NeXT Preview: strip old '%%Pages:' lines.
    if ( /^%%Pages:/ ) {
	$npages = $1 if $' =~ /\s*(\d+)/;
	print STDERR ("Number of pages = $npages.\n") if $verbose;
	next;
    }
    if ( /^%%Page:/ ) {
	$sheet++;
	$pagemap{$sheet} = $1 if /%%Page:\s+(\S+)\s+\S+/;
	close (FILE);
	$file = "$TMPDIR/p$$.$sheet";
	push (@files, $file);
	open (FILE, ">$file") || die ("$file: $!\n");
    }
    if ( /^%%Trailer/ ) {
	close (FILE);
	$file = "$TMPDIR/p$$.trailer";
	push (@files, $file);
	open(FILE, ">$file") || die ("$file: $!\n");
    }
    if ( /^%%EndSetup/ ) {
	# Insert twoup before switching to TeXDict.
	&twoup;
	$twoup++;
	&double_sided if $opt_duplex;
	print FILE ("%%EndSetup\n");
	next;
    }
    if ( $opt_letter ) {
	# Special treatment for US letter freaks.
	if ( /^%%BoundingBox:\s*0 0 596 842/ ) {
	    $_ = "%%BoundingBox: 0 0 612 792\n";
	}
	if ( /^%%DocumentPaperSizes: A4/i ) {
	    $_ = "%%DocumentPaperSize: Letter\n";
	}
	if ( /^%%BeginPaperSize: A4/i ) {
	    while ( <> ) {
	      if ( /^%%EndPaperSize/i ) { last; }
	    }
	    $_ = "%%BeginPaperSize: Letter\nletter\n%%EndPaperSize\n";
	}
	if ( /^%%PaperSize: A4/i ) {
	    $_ = "%%PaperSize: Letter\n";
	}
    }
    print FILE ($_);
}
close (FILE);
die ("twoup insertion error\n") unless $twoup == 1;

# Calculate order to output the pages.
@order = ();
if ( $opt_order ne '' ) {
    # Explicit range given.
    foreach $range ( split (/,/, $opt_order) ) {
	($start,$sep,$end) = split (/(-)/, $range);
	$start = 1 unless $start;
	$end = $sheet unless $end;
	if ($sep) {
	    push (@order, $start..$end);
	}
	else{
	    push (@order, $start);
	}
    }
}
elsif ( $opt_bookorder ) {
    # Normal book order: 8,1,2,7,6,3,4,5.
    # warn ("Warning: number of pages ($npages) is not a multiple of 4\n")
    #	unless $npages % 4 == 0;
    @order = &bookorder (4*int($npages/4), $npages%4);
    if ( $opt_odd ) {
	# Select odd pages: 8,1,6,3.
	@tmp = @order;
	@order = ();
	while ( @tmp > 0 ) {
	    push (@order, shift (@tmp), shift (@tmp));
	    shift (@tmp); shift (@tmp);
	}
    }
    elsif ( $opt_even ) {
	@tmp = @order;
	@order = ();
	if ( $opt_reverse ) {
	    # Even pages: 2,7,4,5.
	    while ( @tmp > 0 ) {
		shift (@tmp); shift (@tmp);
		push (@order, shift (@tmp), shift (@tmp));
	    }
	}
	else {
	    # Even pages: 4,5,2,7.
	    while ( @tmp > 0 ) {
		shift (@tmp); shift (@tmp);
		unshift (@order, shift (@tmp), shift (@tmp));
	    }
	}
    }
}
else {
    # Pages in order. Make sure it's even.
    @order = (1..$sheet);
    push (@order, $sheet+1) if $sheet % 2;
}

# Mark pages out of order.
grep ((($_ > $sheet) && ($_ = '*')) || 1, @order);
print STDERR ("Page order = ", join(',',@order), "\n") if $verbose;

# Now glue the parts in the correct order together.
# The preamble info.
open (FILE, "$TMPDIR/p$$.header");
$_ = <FILE>;
print STDOUT ($_, "%%Pages: ", int((@order+1)/2), " 0\n");
print STDOUT ($_) while <FILE>;
close (FILE);

# The pages.
$count = 0;
foreach $page (@order) {
    $count++;
    $num = '*';
    $num = $pagemap{$page} if defined $pagemap{$page};
    if ( defined $order[$count] && defined $pagemap{$order[$count]} ) {
	$num .= '/' . $pagemap{$order[$count]};
    }
    else {
	$num .= '/*';
    }
    print STDOUT ("%%Page: $num ", ($count+1)/2, "\n") if $count & 1;
    print STDOUT ("%%OldPage: $page\n");
    if ($page eq "*") {
	print STDOUT ("0 0 bop eop\n");
    }
    else {
	open (FILE, "$TMPDIR/p$$.$page");
	while ( <FILE> ) {
	    print STDOUT ($_) unless /^%%Page:/;
	}
	close (FILE);
    }
}

# The trailer info.
open (FILE, "$TMPDIR/p$$.trailer");
print STDOUT ($_) while <FILE>;
close (FILE);

# Wrapup and exit.
unlink @files unless $opt_debug || $opt_test;
exit(0);

################ Subroutines ################

sub bookorder {
    local ($pages, $offset) = @_;
    local (@order) = ();
    for ($i=1; $i<$pages/2; $i+=2) {
	push (@order, $pages-$i+1+$offset, $i+$offset, 
	      $i+1+$offset, $pages-$i+$offset);
    }
    @order;
}

sub twoup {
    local ($factor) = 0.707106781187;	# ridiculous (0.7 would do as well)
    local ($scale) = 72/75;
    $opt_shift *= $scale;
    $opt_topshift *= $scale;

    # Measurements are in 1/100 inch approx.
    # topmargin value shifts UP.
    # leftmargin value shifts RIGHT.
    if ( $opt_a4) {
	$topmargin = -5 - $opt_topshift;
	$leftmargin = 112 + $opt_shift;
	$othermargin = -445;	# do not change -- relative to $leftmargin
	$leftmargin -= $othermargin;
    }
    else {
	$topmargin = 10 - $opt_topshift;
	$leftmargin = 77 + $opt_shift;
	$othermargin = -445;	# do not change -- relative to $leftmargin
	$leftmargin -= $othermargin;
    }
    print FILE <<EOD;
/isls true def
userdict begin 
/isoddpage true def
/orig-showpage /showpage load def
/showpage {
        isoddpage not { orig-showpage } if
        /isoddpage isoddpage not store 
    } def
 
/bop-hook {
        isoddpage 
	{ $factor $factor scale $topmargin $leftmargin translate }
        { 0 $othermargin translate}
	ifelse
    } def
 
/end-hook{ isoddpage not { orig-showpage } if } def
end
EOD
}

sub double_sided {

    # From: Tim Huckvale <tjh@praxis.co.uk>
    #
    # You may be interested in the following problem, and fix, that we
    # found when attempting to print the reference card on our Hewlett
    # Packard Laser-Jet IIISi printer.
    # 
    # On this printer, refguide.ps prints double-sided with the
    # reverse side of each sheet upside down.  We fixed it with the
    # following patch, applied before printing.

    # From: Johan Vromans <jvromans@squirrel.nl>
    #
    # Okay -- consider this an unsupported feature.

    print FILE <<EOD;
statusdict /setduplexmode known { statusdict begin true setduplexmode end } if
statusdict /settumble known { statusdict begin true settumble end } if
EOD
}

sub options {
    local ($opt_help) = 0;	# handled locally
    local ($opt_ident) = 0;	# handled locally

    # Preset defaults.
    $opt_trace = $opt_debug = 0;
    $opt_verbose = 0;
    $opt_bookorder = $opt_even = $opt_odd = $opt_reverse = 0;
    $opt_a4 = $opt_letter = 0;
    $opt_order = '';
    $opt_shift = $opt_topshift = 0;

    # Process options.
    if ( @ARGV > 0 && $ARGV[0] =~ /^[-+]/ ) {
	require "newgetopt.pl";
	&usage 
	    unless &NGetOpt ("ident", "verbose",
			     "bookorder", "order=s", "a4", "letter",
			     "odd", "even", "reverse", "duplex",
			     "shift=i", "topshift=i",
			     "trace", "help", "debug")
		&& !$opt_help;
    }
    print STDERR "This is $my_package [$my_name $my_version]\n"
	if $opt_ident;
}

sub usage {
    print STDERR <<EndOfUsage;
This is $my_package [$my_name $my_version]
Usage: $0 [options] [file ...]
    -a4		map for A4 size paper
    -letter	map for US Letter size paper
    -bookorder	output pages in book order
    -odd	odd pages only (use with -bookorder)
    -even	even pages only (use with -bookorder)
    -shift NN	shift right by NN units (1/100 inch approx.)
    -topshift NN	shift down by NN units (1/100 inch approx.)
    -reverse	reversed order (use with -bookorder -even)
    -duplex	try duplex printing
    -order n,n,...	explicit page order
    -help	this message
    -ident	show identification
    -verbose	verbose information
EndOfUsage
    exit 1;
}
