all: win32 osx

win32:
	dcc32 -$M+ ArgumentParserExample.dpr

osx:
	dccosx -$M+ ArgumentParserExample.dpr

clean:
	del ArgumentParserExample.exe
	del ArgumentParserExample

test: clean all
	ArgumentParserExample.exe
