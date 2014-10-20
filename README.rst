========================
Nullpobug.ArgumentParser
========================

Command line argument parser for Delphi.

Requirements
============

* Delphi 2007

License
=======

* MIT License

Usage
=====

::

  var
    Parser: TArgumentParser;
    ParseResult: TParseResult;
  begin
    Parser := TArgumentParser.Create;
    Parser.AddArgument('--foo', saBool);  // --foo
    Parser.AddArgument('--bar', saStore);  // --bar bar_value
    ParseResult := Parser.ParseArgs;  // if omitted, ParamStr is used.
    // ParseResult := Parser.ParseArgs(ListOfString);
    ParseResult.HasArgument('foo');  // It returns Boolean.
    ParseResult.GetValue('bar');  // It returns String.
  end;

Example
-------

Example codes are in "Example" directory.

::

  >cd delphi-argparse\Example
  >make win32
  >ArgumentParserExample.exe --foo -b 123 abc def
  foo: True
  bar: 123
  arg1 :abc
  arg2 :def
