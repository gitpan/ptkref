# $Id: Makefile,v 5.9 1996/01/11 21:40:05 jv Exp $

################ Configuration ################

SHELL	= /bin/sh
PERL	= perl
LATEX	= latex
DVIPS	= dvips

# Uncomment this if your printer has US letter format paper.
PAPER	= -letter

# Uncomment this if your printer supports duplex printing.
#DUPLEX	= -duplex

# Alignment. See README for details.
HALIGN	= 0
VALIGN	= 0
#VALIGN	= -50
#HALIGN  = -20

################ End of Configuration ################

all:	refguide.ps 

2pass:	guide-odd.ps guide-even1.ps guide-even2.ps

# 2 pages per page, suitable for centrefold printing.
refguide.ps:	refbase.ps parr.pl
	$(PERL) ./parr.pl $(PAPER) $(DUPLEX) -bookorder \
		-shift $(HALIGN) -topshift $(VALIGN) \
		refbase.ps > refguide.ps

testpage.ps:	testbase.ps parr.pl Makefile
	$(PERL) ./parr.pl $(PAPER) $(DUPLEX) \
		-shift $(HALIGN) -topshift $(VALIGN) \
		testbase.ps > testpage.ps

# Odd and even passes for centerfold printing. 
# First print guide-odd.ps, then find out which of the others to use.
# guide-even1.ps is for printers with correct output stacking like
# Apple LaserWriter II. 
# guide-even2.ps for printers with reverse output stacking, like old
# Apple LaserWriters. 

guide-odd.ps:	refbase.ps parr.pl
	$(PERL) ./parr.pl $(PAPER) -bookorder -odd \
		-shift $(HALIGN) -topshift $(VALIGN) \
		refbase.ps > guide-odd.ps

guide-even1.ps:	refbase.ps parr.pl
	$(PERL) ./parr.pl $(PAPER) -bookorder -even \
		-shift $(HALIGN) -topshift $(VALIGN) \
		refbase.ps > guide-even1.ps

guide-even2.ps:	refbase.ps parr.pl
	$(PERL) ./parr.pl $(PAPER) -bookorder -even -reverse \
		-shift $(HALIGN) -topshift $(VALIGN) \
		refbase.ps > guide-even2.ps

guide-test.ps:	refbase.ps parr.pl
	$(PERL) ./parr.pl $(PAPER) \
		-shift $(HALIGN) -topshift $(VALIGN) \
		refbase.ps > guide-test.ps

clean:
	rm -f refguide.ps guide-odd.ps guide-even1.ps guide-even2.ps \
		refbase.dvi core refbase.aux refbase.log \
		refbase.toc *~

# The remainder of this Makefile is for maintenance use only.

VER	= 4.2
REV     = 0

SRC	= refbase.tex refbase.cls testbase.ps reftk.tex
AUX	= README Makefile Makefile.psutils parr.pl PROBLEMS Layout

# NOTE: DO NOT REMOVE OR CHANGE '-ta4' EVEN IF USING NON-A4 PAPER
refbase-ps:	refbase.dvi
	$(DVIPS) -r0 -ta4 refbase.dvi -o refbase.ps

refbase.dvi:	$(SRC)
	touch refbase.toc
	@rm -f refbace.toc~
	@cat refbase.toc > refbase.toc~
	$(LATEX) refbase.tex < /dev/null
	@if cmp refbase.toc refbase.toc~ > /dev/null 2>&1; \
	then \
	    true; \
	else \
	    echo "$(LATEX) refbase.tex \< /dev/null"; \
	    $(LATEX) refbase.tex < /dev/null; \
	fi

DIR	= tkref-$(VER).$(REV)
kitinternal:
	rm -f tkref-$(VER).$(REV).tar.gz
	rm -rf $(DIR)
	- mkdir $(DIR)
	cp $(AUX) $(SRC) refbase.ps $(DIR)
	gtar -zcvf tkref-$(VER).$(REV).tar.gz $(DIR)
	rm -rf $(DIR)

