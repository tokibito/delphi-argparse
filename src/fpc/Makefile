all:
	lazbuild ArgumentParserTest.lpr

clean:
	rm -rf lib/
	rm -f ArgumentParserTest.xml

test: clean all
	lib/x86_64-linux/ArgumentParserTest

.PHONY: all clean test
