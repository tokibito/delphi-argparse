# Changelog

## 0.3 - Unreleased

The parser API and behavior are unchanged, apart from the leak fix below.

### Changed

- **The shared units moved from `src/common/` to `src/`**:
  `src/Nullpobug.ArgumentParser.pas`, `src/Nullpobug.ArgumentParserTest.pas`
  and `src/Nullpobug.UnitTest.pas`. If you copy the unit or add its directory
  to your search path, use the new path. The unit sources are unchanged.
  An empty `puy.toml` at the repository root lets
  [Puy](https://crates.io/crates/puy) build the tests and the example as is,
  and CI runs them with Puy too (`puy.yml`).
- **Enumeration values are qualified with their type name** throughout the
  sources and the README: `TStoreAction.saBool`, `TStoreAction.saStore`,
  `TTestResultType.rtOK` and so on, including `case` labels, default
  parameter values and sets. This compiles on Delphi XE4 or later and on
  FPC 3.2 or later in Delphi mode without `{$SCOPEDENUMS ON}`. Code that uses
  the unqualified names (`saBool`, `saStore`) still compiles.
- `TTestRunner.SaveToXML` builds the report in a `TStringList` and saves it
  with `SaveToFile(FileName, TEncoding.UTF8)` instead of writing to a `Text`
  file. The file is now encoded in UTF-8, as its XML declaration says; Delphi
  writes a byte order mark and FPC does not. The elements, attributes and
  number format are unchanged.

### Removed

- The `ShortString` and `RawByteString` overloads of
  `TTestCase.AssertEquals`. On Delphi XE4 or later and FPC in Delphi mode,
  the `String` overload covers them.

### Fixed

- `TArgumentParser.ParseArgs(TargetArgs)` leaked the partly built
  `TParseResult` when it raised `EInvalidArgument` or `EParameterMissing`.
  The exceptions and their messages are unchanged. Tests now cover these
  error paths.
- `TTextTestRunner.WriteTestResultDetail` no longer reads `ResultTypeString`
  before assigning it when called for a result that is neither a failure nor
  an error.

## 0.2 - 2026-11-14

Requires Delphi XE4 or later; projects on Delphi 2007 to XE3 should stay on
0.1. The parser API is unchanged, so upgrading is a matter of replacing the
unit.

### Added

- **Win64 support for Delphi.** The Makefiles build the tests and the example
  with both `dcc32` and `dcc64` (`make win32`, `make win64`, or both with
  `make all`), and the `.dproj` files target Win32 and Win64. CI builds and
  runs both with Delphi XE4.
  ([#4](https://github.com/tokibito/delphi-argparse/pull/4))
- `CONTRIBUTING.md` and this changelog.

### Changed

- **Delphi XE4 or later is required.** Delphi 2007 to XE3 are no longer
  supported. The `CompilerVersion` conditionals are gone, and the Delphi code
  always uses unit scope names (`System.SysUtils` and so on). The parser
  itself behaves exactly as before, and FPC is unaffected.
  ([#4](https://github.com/tokibito/delphi-argparse/pull/4))
- **The test runner uses RTTI.** `Nullpobug.UnitTest` finds test methods with
  `TRttiContext` and calls them with `TRttiMethod.Invoke` instead of walking
  the VMT method table. It runs published, parameterless methods whose names
  start with `Test`, and an overridden method once.
  ([#4](https://github.com/tokibito/delphi-argparse/pull/4))
- The README documents the API, the exceptions and how to build and test, and
  states the supported FPC version (3.2 or later).
  ([#5](https://github.com/tokibito/delphi-argparse/pull/5))

### Fixed

- `Nullpobug.UnitTest` no longer calls `FreeAndNil` on `TStopWatch`, which
  is a record.
  ([#4](https://github.com/tokibito/delphi-argparse/pull/4))

## 0.1 - 2024-08-16

The first tagged release.

- `TArgumentParser` with boolean flags (`saBool`), options that take a value
  (`saStore`) written as `--name value` or `--name=value`, aliases that store
  into the same destination, and positional arguments.
- `TParseResult` with `HasArgument`, `GetValue` and `Args`.
- `EInvalidArgument`, `EParameterMissing` and `ENoSuchArgument`.
- Supports Delphi 2007 or later and Free Pascal 3.2 (tested with 3.2.2 on
  x86_64 Linux).
