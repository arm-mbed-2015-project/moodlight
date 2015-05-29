CC = g++

CFLAGS += -Wall
CFLAGS += -g
CFLAGS += -O0
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += --coverage 
CFLAGS += -I ../../inc
CFLAGS += -I ../../../inc
CFLAGS += -I ../../../external
CFLAGS += -D UNIT_TESTING

LDFLAGS += -Wl,--gc-sections

UNAME = $(shell uname)
# mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_path := $(abspath Makefile)
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

ifeq ($(UNAME), Linux)
	executable = a.out
else
	executable = a.exe
endif

# $@
# The full target filename. By target, I mean the file that needs to be built, 
# such as a .o file being compiled from a .c file or a program made by linking
# .o files.
# 
# $*
# The target file with the suffix cut off. So if the target is prog.o, $* 
# is prog, and  $*.c would become prog.c.
# 
# $<
# The name of the file that caused this target to get triggered and made. If 
# we are making prog.o, it is probably because prog.c has recently been 
# modified, so $< is prog.c.
# 
# $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $*.c
# $(CC) $(LDFLAGS) first.o second.o $(LDLIBS)
# 
# CFLAGS += -std=c99

all:
	$(CC) $(CFLAGS) $(LDFLAGS) $(SRC)

clean:
	@rm -rfv *.gcda
	@rm -rfv *.gcno
	@rm -rfv $(executable)
	@rm -rfv $(executable).stackdump
	@rm -rfv app.info

run:
	./$(executable) --success

coverage_collect:
	lcov -q -d . --capture -o app.info
	lcov -q -r app.info "tests/*" "/usr/*" -o app.info
	mv app.info ../../gcov_files/temp/$(current_dir).info
