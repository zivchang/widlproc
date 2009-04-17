########################################################################
# $Id$
# $URL$
# Copyright 2009 Aplix Corporation. All rights reserved.
########################################################################

UNAME = $(shell uname)
INCDIRS = $(OBJDIR)
SRCDIR = src
DOCDIR = doc
EXAMPLESDIR = examples
OBJDIR = obj

########################################################################
# Linux configuration
#
ifneq (,$(filter Linux%, $(UNAME))) 

CFLAGS = -g -Wall -Werror -O2 $(patsubst %, -I%, $(INCDIRS))
OBJSUFFIX = .o
EXESUFFIX =
LIBS = -lefence
OBJOPTION = -o
EXEOPTION = -o

else
########################################################################
# Windows (cygwin but using MS compiler) configuration
#
ifneq (,$(filter CYGWIN%, $(UNAME))) 
VISUALSTUDIODIR = $(wildcard /cygdrive/c/Program*Files/Microsoft*Visual*Studio*8)
ifeq (,$(VISUALSTUDIODIR))
$(error Could not find MS Visual Studio)
else
WINVISUALSTUDIODIR = $(shell cygpath -w '$(VISUALSTUDIODIR)')
CC = \
	Lib='$(WINVISUALSTUDIODIR)\VC\LIB;$(WINVISUALSTUDIODIR)\VC\PlatformSDK\Lib' \
	PATH='$(VISUALSTUDIODIR)/Common7/IDE:$(VISUALSTUDIODIR)/VC/BIN:$(VISUALSTUDIODIR)/Common7/Tools:$(VISUALSTUDIODIR)/SDK/v2.0/bin:'$$PATH \
	Include='$(WINVISUALSTUDIODIR)\VC\INCLUDE;$(WINVISUALSTUDIODIR)\VC\PlatformSDK\Include' \
	cl
endif

CFLAGS = /nologo /WX /W3 /wd4996 /Zi /O2 $(patsubst %, /I%, $(INCDIRS))
OBJSUFFIX = .obj
EXESUFFIX = .exe
OBJOPTION = /Fo
EXEOPTION = /Fe

endif
endif

########################################################################
# Common makefile
#
WIDLPROC = $(OBJDIR)/widlproc$(EXESUFFIX)
DTD = $(OBJDIR)/widlprocxml.dtd

ALL = $(WIDLPROC) $(DTD)
all : $(ALL)

SRCS = \
	comment.c \
	lex.c \
	main.c \
	misc.c \
	parse.c \
	process.c

AUTOGENHEADERS = \
	grammar.h \
	nonterminals.h

OBJS = $(patsubst %.c, $(OBJDIR)/%$(OBJSUFFIX), $(SRCS))
$(WIDLPROC) : $(OBJS)
	$(CC) $(CFLAGS) $(EXEOPTION)$@ $^ $(LIBS)

$(OBJDIR)/%$(OBJSUFFIX) : $(SRCDIR)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(OBJOPTION)$@ -c $<

CONVGRAMMARSRCS = convgrammar.c
CONVGRAMMAR = $(OBJDIR)/convgrammar$(EXESUFFIX)
CONVGRAMMAROBJS = $(patsubst %.c, $(OBJDIR)/%$(OBJSUFFIX), $(CONVGRAMMARSRCS))

$(CONVGRAMMAR) : $(CONVGRAMMAROBJS)
	$(CC) $(CFLAGS) $(EXEOPTION)$@ $^ $(LIBS)

$(OBJDIR)/%.d : $(SRCDIR)/%.c
	mkdir -p $(dir $@)
	cc $(patsubst %, -I%, $(INCDIRS)) -MM -MG -MT $(patsubst %.d, %$(OBJSUFFIX), $@) $< | sed '$(patsubst %, s| \(%\)| $(OBJDIR)/\1|;, $(AUTOGENHEADERS))' >$@

$(OBJDIR)/grammar.h : $(SRCDIR)/grammar $(CONVGRAMMAR)
	$(CONVGRAMMAR) $< >$@

$(OBJDIR)/nonterminals.h : $(SRCDIR)/grammar $(CONVGRAMMAR)
	$(CONVGRAMMAR) -h $< >$@

include $(patsubst %.c, $(OBJDIR)/%.d, $(SRCS))


$(DTD) : $(DOCDIR)/htmltodtd.xsl $(DOCDIR)/widlproc.html
	xsltproc -html $^ >$@

clean :
	rm -f $(ALL) $(OBJS) $(CONVGRAMMAR) $(CONVGRAMMAROBJS) $(patsubst %, $(OBJDIR)/%, $(AUTOGENHEADERS))

veryclean :
	rm -rf $(OBJDIR)

zip : $(OBJDIR)/widlproc.zip
$(OBJDIR)/widlproc.zip : $(WIDLPROC) $(DTD) $(DOCDIR)/widlproc.html $(SRCDIR)/widlprocxmltohtml.xsl Makefile
	rm -f $@
	zip -j $@ $^ -x Makefile
	zip $@ examples/*.widl examples/*.css


test : $(patsubst $(EXAMPLESDIR)/%.widl, test_examples_%, $(wildcard $(EXAMPLESDIR)/*.widl))

test_examples_% : $(EXAMPLESDIR)/%.widl $(WIDLPROC) $(DTD)
	mkdir -p $(dir $(OBJDIR)/$<)
	cp $(EXAMPLESDIR)/widlhtml.css $(dir $(OBJDIR)/$<)/
	cp $(OBJDIR)/widlprocxml.dtd $(dir $(OBJDIR)/$<)/
	$(WIDLPROC) $< >$(patsubst %.widl, $(OBJDIR)/%.widlprocxml, $<)
	xmllint --noout --dtdvalid $(DTD) $(patsubst %.widl, $(OBJDIR)/%.widlprocxml, $<)
	xsltproc $(SRCDIR)/widlprocxmltohtml.xsl $(patsubst %.widl, $(OBJDIR)/%.widlprocxml, $<) > $(patsubst %.widl, $(OBJDIR)/%.html, $<)
	@echo "$@ pass"

.DELETE_ON_ERROR:
