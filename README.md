# Nullpobug.ArgumentParser

[![FPC](https://github.com/tokibito/delphi-argparse/actions/workflows/fpc.yml/badge.svg)](https://github.com/tokibito/delphi-argparse/actions/workflows/fpc.yml)
[![Delphi](https://github.com/tokibito/delphi-argparse/actions/workflows/delphi.yml/badge.svg)](https://github.com/tokibito/delphi-argparse/actions/workflows/delphi.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A small command line argument parser for Delphi and Free Pascal (FPC),
inspired by Python's `argparse`.

The whole library is a single unit with no dependencies other than the RTL:
[`src/common/Nullpobug.ArgumentParser.pas`](src/common/Nullpobug.ArgumentParser.pas).

## Features

* Boolean flags (`--verbose`)
* Options with a value, written as `--name value` or `--name=value`
* Short and long aliases that store into the same destination (`-o` / `--output`)
* Positional (unnamed) arguments
* Exceptions for unknown options and missing values

## Requirements

* Delphi XE4 or later (Win32 / Win64), or
* Free Pascal 3.2 or later (tested with 3.2.2 on x86_64 Linux)
  * The bundled tests are built with Lazarus `lazbuild` and assume a 64-bit target.

## Installation

Copy `src/common/Nullpobug.ArgumentParser.pas` into your project
(or add `src/common` to the search path) and add the unit to `uses`:

```pascal
uses
  Nullpobug.ArgumentParser;
```

## Usage

```pascal
var
  Parser: TArgumentParser;
  ParseResult: TParseResult;
  I: Integer;
begin
  Parser := TArgumentParser.Create;
  try
    Parser.AddArgument('--verbose', saBool);             // flag, dest = 'verbose'
    Parser.AddArgument('--output', 'output', saStore);   // --output FILE / --output=FILE
    Parser.AddArgument('-o', 'output', saStore);         // short alias of --output

    ParseResult := Parser.ParseArgs;  // parses ParamStr(1)..ParamStr(ParamCount)
    try
      if ParseResult.HasArgument('verbose') then
        Writeln('verbose mode');
      if ParseResult.HasArgument('output') then
        Writeln('output: ' + ParseResult.GetValue('output'));
      for I := 0 to ParseResult.Args.Count - 1 do
        Writeln('arg: ' + ParseResult.Args[I]);
    finally
      ParseResult.Free;
    end;
  finally
    Parser.Free;
  end;
end;
```

To parse something other than the process command line, pass a `TStringList`
to `ParseArgs(TargetArgs)`. `GetParamStrAsList(False)` returns the command line
arguments (without the program name) as a new `TStringList`.

### Defining arguments

| Call | Meaning |
| --- | --- |
| `AddArgument('--foo', saBool)` | Flag. The destination name is derived from the option by stripping leading `--` or `-` (here `foo`). |
| `AddArgument('--bar', saStore)` | Option that takes a value. Destination is `bar`. |
| `AddArgument('-b', 'bar', saStore)` | Option with an explicit destination name. Use this to define aliases. |
| `AddArgument(Argument: TArgument)` | Register a `TArgument` instance. The parser takes ownership of it. |

The store action defaults to `saBool` when omitted.

### Reading the result

`ParseArgs` returns a new `TParseResult`. The caller owns it and must free it.

| Member | Description |
| --- | --- |
| `HasArgument(Dest)` | `True` if the flag was given or the option has a value. |
| `GetValue(Dest)` | Value of a `saStore` option. Raises `ENoSuchArgument` if it was not given. |
| `Args` | `TStringList` of positional arguments, in order. |

If the same option is given more than once, the first value is kept.

### Errors

| Exception | Raised when |
| --- | --- |
| `EInvalidArgument` | An argument starting with `-` does not match any defined option (or `--flag=value` is used for a `saBool` flag). |
| `EParameterMissing` | A `saStore` option is the last argument and has no value. |
| `ENoSuchArgument` | `TParseResult.GetValue` is called for a destination that was not given. |

## Example

A runnable example is in [`src/delphi/Example`](src/delphi/Example)
(and [`src/fpc/Example`](src/fpc/Example) for FPC).

```
>cd src\delphi\Example
>make win64
>Win64\ArgumentParserExample.exe --foo -b 123 abc def
foo: True
bar: 123
arg1 :abc
arg2 :def
```

## Building and running the tests

### Delphi (Windows)

Run `rsvars.bat` of your RAD Studio installation first, then:

```
>cd src\delphi
>make test
```

This builds and runs the tests for both Win32 (`dcc32`) and Win64 (`dcc64`).
Use `make win32` or `make win64` to build only one platform.
The `.dproj` files can also be opened in the IDE or built with `msbuild`.

### FPC (x86_64 Linux)

```
$ cd src/fpc
$ make test
```

## License

MIT License. See [LICENSE](LICENSE).
