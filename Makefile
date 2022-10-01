ifeq ($(wildcard asmopt.mak),)
$(error Run ./configure first)
endif

include asmopt.mak

##########################
# set up variables
#

ASMINCLUDE = -I./src

##########################
# expand all source file paths in to object files
#
OBJASM = poly1305.o

##########################
# non-file targets
#
.PHONY: all
.PHONY: default

.PHONY: clean
.PHONY: distclean


all: default

default: $(OBJASM)

clean:
	@rm -f *.o
	@rm -f *.P
	@echo cleaning project [poly1305]

distclean: clean
	@rm asmopt.mak
	@rm src/asmopt.h
	@rm config.log

##########################
# build rules for files
#

# use $(BASEOBJ) in build rules to grab the base path/name of the object file, without an extension
BASEOBJ = $*

# building .S (assembler) files
%.o: src/%.S
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) $(ASMINCLUDE) -MMD -MF $(BASEOBJ).temp -c -o $(BASEOBJ).o $<
	@cp $(BASEOBJ).temp $(BASEOBJ).P
	@sed \
	-e 's/^[^:]*: *//' \
	-e 's/ *\\$$//' \
	-e '/^$$/ d' \
	-e 's/$$/ :/' \
	< $(BASEOBJ).temp >> $(BASEOBJ).P
	@rm -f $(BASEOBJ).temp

##########################
# include all auto-generated dependencies
#

-include $(OBJASM:%.o=%.P)
