all:
	dcc32 -$M+ ArgumentParserTest.dpr

clean:
	del ArgumentParserTest.exe
	del ArgumentParserTest.xml

test: clean all
	ArgumentParserTest.exe

.PHONY: all clean test
