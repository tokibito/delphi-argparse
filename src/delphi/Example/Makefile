all: win64

win64:
	dcc64 -$M+ ArgumentParserExample.dpr

clean:
	del ArgumentParserExample.exe

test: clean all
	ArgumentParserExample.exe

.PHONY: all win64 clean test
