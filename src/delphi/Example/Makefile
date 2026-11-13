all: win32 win64

win32:
	-mkdir Win32
	dcc32 -Q -EWin32 -N0Win32 ArgumentParserExample.dpr

win64:
	-mkdir Win64
	dcc64 -Q -EWin64 -N0Win64 ArgumentParserExample.dpr

clean:
	-rmdir /s /q Win32
	-rmdir /s /q Win64

test: clean all
	Win32\ArgumentParserExample.exe --foo -b 123 abc def
	Win64\ArgumentParserExample.exe --foo -b 123 abc def

.PHONY: all win32 win64 clean test
