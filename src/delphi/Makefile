all: win32 win64

win32:
	-mkdir Win32
	dcc32 -Q -EWin32 -N0Win32 ArgumentParserTest.dpr

win64:
	-mkdir Win64
	dcc64 -Q -EWin64 -N0Win64 ArgumentParserTest.dpr

clean:
	-rmdir /s /q Win32
	-rmdir /s /q Win64
	-del ArgumentParserTest.xml

test: clean all
	Win32\ArgumentParserTest.exe
	Win64\ArgumentParserTest.exe

.PHONY: all win32 win64 clean test
