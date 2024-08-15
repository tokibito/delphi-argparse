all: lib/x86_64-linux/ArgumentParserTest

lib/x86_64-linux/ArgumentParserTest:
	lazbuild ArgumentParserTest.lpr

clean:
	rm -rf lib/
	rm -f ArgumentParserTest.xml

test: all
	lib/x86_64-linux/ArgumentParserTest

.PHONY: all clean test
