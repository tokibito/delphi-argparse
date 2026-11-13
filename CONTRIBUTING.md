# Contributing

Thanks for your interest in Nullpobug.ArgumentParser.

Issues and pull requests are welcome at
<https://github.com/tokibito/delphi-argparse>. Everything that lands in the
repository — code, comments, commit messages, pull request descriptions and
documentation — is written in English.

## Layout

| Path | Contents |
| --- | --- |
| `src/common/Nullpobug.ArgumentParser.pas` | The library. This single unit is what users copy into their projects. |
| `src/common/Nullpobug.ArgumentParserTest.pas` | The tests. |
| `src/common/Nullpobug.UnitTest.pas` | The small test framework the tests run on. |
| `src/delphi/` | Delphi test project, example and Makefiles. |
| `src/fpc/` | Free Pascal / Lazarus test project, example and Makefile. |

The library and the tests are shared between Delphi and FPC. A change to them
has to compile and pass on both.

## Running the tests

### Delphi (Windows)

Delphi XE4 or later. Run `rsvars.bat` of your RAD Studio installation first,
then:

```
>cd src\delphi
>make test
```

This builds and runs the tests for both Win32 (`dcc32`) and Win64 (`dcc64`).
The example has its own `make test` in `src\delphi\Example`.

### FPC (Linux)

Free Pascal 3.2 or later with Lazarus' `lazbuild`, on a 64-bit target:

```
$ sudo apt-get install lazarus lcl-utils
$ cd src/fpc
$ make test
```

The test runner prints a summary, with the details of every failure and error,
and writes the results to `ArgumentParserTest.xml` in JUnit format. A failing test makes the process exit with a
non-zero code.

### In CI

GitHub Actions runs both on every push: `fpc.yml` on `ubuntu-latest`, and
`delphi.yml` with Delphi XE4 on a self-hosted Windows runner. The Delphi job
also builds both `.dproj` files with `msbuild` for Win32 and Win64, so a
change to a `.dpr` that is not reflected in its `.dproj` fails there.

If you have only one of the two compilers, say which one you tested with in the
pull request, and CI covers the other.

## Writing tests

Tests are `TTestCase` subclasses in `Nullpobug.ArgumentParserTest.pas`. The
runner finds them through RTTI: every **published**, parameterless method
whose name starts with `Test` is run, with `SetUp` and `TearDown` around it.
A test class is picked up only once it is passed to `RegisterTest` in the
unit's `initialization` section — a new class that is not registered is
silently never run.

```pascal
  TArgumentParserSomethingTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSomething;
  end;

...

initialization
  RegisterTest(TArgumentParserSomethingTest);
```

Pass the arguments to parse as a `TStringList` to `ParseArgs(TargetArgs)`
rather than relying on the test process's own command line.

## Making a change

A few things are easy to forget:

- **Both compilers.** Code that differs between Delphi and FPC goes behind
  `{$IFDEF FPC}`. Delphi code uses unit scope names (`System.SysUtils`, not
  `SysUtils`); there are no `CompilerVersion` checks, since XE4 is the oldest
  supported version.
- **No dependencies.** The library uses the RTL only, so that it stays a
  single file to drop into a project. Keep it that way.
- **Project files.** Adding a unit to a `.dpr` or `.lpr` means adding it to
  the matching `.dproj` or `.lpi` as well.
- **The changelog.** Add a line to the *Unreleased* section of
  `CHANGELOG.md`.
- **The README.** New options, actions and exceptions are documented there,
  in the tables under *Usage*.

### Backwards compatibility

Users copy the unit into their projects and upgrade by replacing it, so a
change to a public type, method or exception class breaks their build or,
worse, their behaviour without a compile error. Prefer adding to changing. When
something has to change, say so under *Changed* or *Removed* in the changelog,
with what to do instead.

The tests are the safety net for this. When a refactor leaves the existing
tests passing unmodified, that is the evidence that behaviour did not change.

## Pull requests

- Branch off `main`.
- **One purpose per pull request.** See below.
- Say what the change is for. A description that explains the problem is worth
  more than one that restates the diff.
- Keep CI green on both FPC and Delphi.
- Add tests for a behaviour change. A bug fix wants the test that fails
  without it.

### Split by purpose

A pull request should answer one question, so that a reviewer can hold that
question in their head while reading all of it. Several purposes in one branch
means none of them gets read properly, and the risky part hides among the safe
parts.

Split it when a branch contains any of these:

- **A refactor and the feature it makes possible.** Send the refactor first,
  where the existing tests passing unmodified is the whole argument, and build
  on it afterwards. Mixed together, that evidence is gone.
- **A fix for something you noticed on the way.** Worth having, and worth
  having on its own.
- **Mechanical churn beside a real change.** Reformatting, renaming and
  reorganising project files drown the few lines that matter.

This holds however the change was produced, including with the help of an AI
tool. A branch that grew in one sitting still has to arrive as the sequence of
changes a reviewer can follow; splitting it afterwards is part of the work, not
an optional tidy-up.

A change that genuinely is one purpose can still be large, and that is fine.
The test is whether the description needs the word "and".
