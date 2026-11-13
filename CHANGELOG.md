# Changelog

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
