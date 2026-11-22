unit Nullpobug.ArgumentParserTest;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses
  {$IFDEF FPC}
  Classes,
  SysUtils,
  {$ELSE}
  System.Classes,
  System.SysUtils,
  {$ENDIF}
  Nullpobug.UnitTest,
  Nullpobug.ArgumentParser;

{$TYPEINFO ON}

type
  TParseResultTest = class(TTestCase)
  private
    FParseResult: TParseResult;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestStoreBool;
    procedure TestStoreValue;
  end;

  TArgumentTest = class(TTestCase)
  private
    FArgument: TArgument;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestProperty;
  end;

  TArgumentParserAddArgumentTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestTArgument;
    procedure TestStringParameter;
    procedure TestOmitDestName;
  end;

  TArgumentParserHasArgumentTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHasBoolArgument;
    procedure TestHasStoreArgument;
  end;

  TArgumentParserGetArgumentTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test;
  end;

  TArgumentParserParseArgsOnlySwitchTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TStringList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSingleHyphen;
    procedure TestDoubleHyphen;
    procedure TestNotIncluded;
  end;

  TArgumentParserParseArgsStoreValueTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TStringList;
    procedure ProcTestNotIncluded;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSingleHyphen;
    procedure TestDoubleHyphen;
    procedure TestDoubleHyphenWithEqualAssignment;
    procedure TestNotIncluded;
  end;

  TArgumentParserParseArgsUnnamedArgsTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TStringList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test;
  end;

  TArgumentParserParseArgsNoParameterTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test;
  end;

  TArgumentParserParseArgsSameDestinationTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TStringList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestBool1;
    procedure TestBool2;
    procedure TestBoolOverwrite;
    procedure TestStore1;
    procedure TestStore2;
  end;

  TArgumentParserParseArgsSwitchAndArgsTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TStringList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test;
  end;

  TArgumentParserParseArgsErrorTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FTargetArgs: TStringList;
    procedure AssertParseError(ExceptionClass: TExceptionClass;
        const ExpectedMessage: String);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestInvalidArgument;
    procedure TestInvalidArgumentWithValue;
    procedure TestParameterMissing;
  end;

  TGetParamStrAsListTest = class(TTestCase)
  published
    procedure TestIncludingAppName;
    procedure TestNotIncludingAppName;
  end;

implementation

(* TParseResultTest *)
procedure TParseResultTest.SetUp;
begin
  FParseResult := TParseResult.Create;
end;

procedure TParseResultTest.TearDown;
begin
  FParseResult.Free;
end;

procedure TParseResultTest.TestStoreBool;
begin
  FParseResult.StoreBool('foo');
  AssertTrue(FParseResult.HasArgument('foo'));
end;

procedure TParseResultTest.TestStoreValue;
begin
  FParseResult.StoreValue('foo', 'bar');
  AssertTrue(FParseResult.HasArgument('foo'));
  AssertEquals(FParseResult.GetValue('foo'), 'bar');
end;
(* End of TParseResultTest *)

(* TArgumentTest *)
procedure TArgumentTest.SetUp;
begin
  FArgument := TArgument.Create('--foo', 'foo', TStoreAction.saBool);
end;

procedure TArgumentTest.TearDown;
begin
  FArgument.Free;
end;

procedure TArgumentTest.TestProperty;
begin
  AssertEquals(FArgument.Option, '--foo');
  AssertEquals(FArgument.Dest, 'foo');
  AssertTrue(FArgument.StoreAction = TStoreAction.saBool);
end;
(* End of TArgumentTest *)

(* TArgumentParserAddArgumentTest *)
procedure TArgumentParserAddArgumentTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
end;

procedure TArgumentParserAddArgumentTest.TearDown;
begin
  FArgumentParser.Free;
end;

procedure TArgumentParserAddArgumentTest.TestTArgument;
begin
  FArgumentParser.AddArgument(TArgument.Create('--foo', 'bar', TStoreAction.saStore));
  AssertEquals(FArgumentParser.ArgumentsCount, 1);
  AssertEquals(FArgumentParser.Arguments[0].Option, '--foo');
  AssertEquals(FArgumentParser.Arguments[0].Dest, 'bar');
end;

procedure TArgumentParserAddArgumentTest.TestStringParameter;
begin
  FArgumentParser.AddArgument('--foo', 'bar', TStoreAction.saStore);
  AssertEquals(FArgumentParser.ArgumentsCount, 1);
  AssertEquals(FArgumentParser.Arguments[0].Option, '--foo');
  AssertEquals(FArgumentParser.Arguments[0].Dest, 'bar');
end;

procedure TArgumentParserAddArgumentTest.TestOmitDestName;
begin
  FArgumentParser.AddArgument('--foo', TStoreAction.saStore);
  FArgumentParser.AddArgument('-b', TStoreAction.saStore);
  AssertEquals(FArgumentParser.ArgumentsCount, 2);
  AssertEquals(FArgumentParser.Arguments[0].Option, '--foo');
  AssertEquals(FArgumentParser.Arguments[0].Dest, 'foo');
  AssertEquals(FArgumentParser.Arguments[1].Option, '-b');
  AssertEquals(FArgumentParser.Arguments[1].Dest, 'b');
end;
(* End of TArgumentParserAddArgumentTest *)

(* TArgumentParserHasArgumentTest *)
procedure TArgumentParserHasArgumentTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', TStoreAction.saBool);
  FArgumentParser.AddArgument('--bar', TStoreAction.saStore);
end;

procedure TArgumentParserHasArgumentTest.TearDown;
begin
  FArgumentParser.Free;
end;

procedure TArgumentParserHasArgumentTest.TestHasBoolArgument;
begin
  AssertTrue(FArgumentParser.HasArgument('--foo', TStoreAction.saBool));
  AssertFalse(FArgumentParser.HasArgument('--bar', TStoreAction.saBool));
  AssertFalse(FArgumentParser.HasArgument('--invalid', TStoreAction.saBool));
end;

procedure TArgumentParserHasArgumentTest.TestHasStoreArgument;
begin
  AssertTrue(FArgumentParser.HasArgument('--bar', TStoreAction.saStore));
  AssertFalse(FArgumentParser.HasArgument('--foo', TStoreAction.saStore));
  AssertFalse(FArgumentParser.HasArgument('--invalid', TStoreAction.saStore));
end;
(* End of TArgumentParserHasArgumentTest *)

(* TArgumentParserGetArgumentTest *)
procedure TArgumentParserGetArgumentTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', TStoreAction.saBool);
  FArgumentParser.AddArgument('--bar', TStoreAction.saStore);
end;

procedure TArgumentParserGetArgumentTest.TearDown;
begin
  FArgumentParser.Free;
end;

procedure TArgumentParserGetArgumentTest.Test;
var
  Argument: TArgument;
begin
  Argument := FArgumentParser.GetArgument('--foo');
  AssertEquals(Argument.Option, '--foo');
  Argument := FArgumentParser.GetArgument('--bar');
  AssertEquals(Argument.Option, '--bar');
end;
(* End of TArgumentParserGetArgumentTest *)

(* TArgumentParserParseArgsOnlySwitchTest *)
procedure TArgumentParserParseArgsOnlySwitchTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', TStoreAction.saBool);
  FArgumentParser.AddArgument('--bar', TStoreAction.saBool);
  FArgumentParser.AddArgument('-b', TStoreAction.saBool);
  FParseResult := nil;
  FTargetArgs := TStringList.Create;
  FTargetArgs.Add('--foo');
  FTargetArgs.Add('-b');
end;

procedure TArgumentParserParseArgsOnlySwitchTest.TearDown;
begin
  FArgumentParser.Free;
  FreeAndNil(FParseResult);
  FTargetArgs.Free;
end;

procedure TArgumentParserParseArgsOnlySwitchTest.TestSingleHyphen;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('b'));
end;

procedure TArgumentParserParseArgsOnlySwitchTest.TestDoubleHyphen;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('foo'));
end;

procedure TArgumentParserParseArgsOnlySwitchTest.TestNotIncluded;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertFalse(FParseResult.HasArgument('bar'));
end;
(* End of TArgumentParserParseArgsOnlySwitchTest *)

(* TArgumentParserParseArgsStoreValueTest *)
procedure TArgumentParserParseArgsStoreValueTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', TStoreAction.saStore);
  FArgumentParser.AddArgument('--bar', TStoreAction.saStore);
  FArgumentParser.AddArgument('-b', TStoreAction.saStore);
  FArgumentParser.AddArgument('--hoge', TStoreAction.saStore);
  FParseResult := nil;
  FTargetArgs := TStringList.Create;
  FTargetArgs.Add('--foo');
  FTargetArgs.Add('foo_value');
  FTargetArgs.Add('-b');
  FTargetArgs.Add('b_value');
  FTargetArgs.Add('--hoge=hoge_value');
end;

procedure TArgumentParserParseArgsStoreValueTest.TearDown;
begin
  FArgumentParser.Free;
  FreeAndNil(FParseResult);
  FTargetArgs.Free;
end;

procedure TArgumentParserParseArgsStoreValueTest.TestSingleHyphen;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('b'));
  AssertEquals(FParseResult.GetValue('b'), 'b_value');
end;

procedure TArgumentParserParseArgsStoreValueTest.TestDoubleHyphen;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('foo'));
  AssertEquals(FParseResult.GetValue('foo'), 'foo_value');
end;

procedure TArgumentParserParseArgsStoreValueTest.TestDoubleHyphenWithEqualAssignment;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('hoge'));
  AssertEquals(FParseResult.GetValue('hoge'), 'hoge_value');
end;

procedure TArgumentParserParseArgsStoreValueTest.ProcTestNotIncluded;
begin
  FParseResult.GetValue('bar');
end;

procedure TArgumentParserParseArgsStoreValueTest.TestNotIncluded;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertFalse(FParseResult.HasArgument('bar'));
  AssertRaises(ENoSuchArgument, Self.ProcTestNotIncluded);
end;
(* End of TArgumentParserParseArgsStoreValueTest *)

(* TArgumentParserParseArgsUnnamedArgsTest *)
procedure TArgumentParserParseArgsUnnamedArgsTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', TStoreAction.saBool);
  FArgumentParser.AddArgument('--bar', TStoreAction.saStore);
  FParseResult := nil;
  FTargetArgs := TStringList.Create;
  FTargetArgs.Add('value1');
  FTargetArgs.Add('value2');
  FTargetArgs.Add('value3');
end;

procedure TArgumentParserParseArgsUnnamedArgsTest.TearDown;
begin
  FArgumentParser.Free;
  FreeAndNil(FParseResult);
  FTargetArgs.Free;
end;

procedure TArgumentParserParseArgsUnnamedArgsTest.Test;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertEquals(FParseResult.Args.Count, 3);
  AssertEquals(FParseResult.Args[0], 'value1');
  AssertEquals(FParseResult.Args[1], 'value2');
  AssertEquals(FParseResult.Args[2], 'value3');
end;
(* End of TArgumentParserParseArgsUnnamedArgsTest *)

(* TArgumentParserParseArgsNoParameterTest *)
procedure TArgumentParserParseArgsNoParameterTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FParseResult := nil;
end;

procedure TArgumentParserParseArgsNoParameterTest.TearDown;
begin
  FArgumentParser.Free;
  FreeAndNil(FParseResult);
end;

procedure TArgumentParserParseArgsNoParameterTest.Test;
begin
  FParseResult := FArgumentParser.ParseArgs;
  AssertEquals(FParseResult.Args.Count, 0);
end;
(* End of TArgumentParserParseArgsNoParameterTest *)

(* TArgumentParserParseArgsSameDestinationTest *)
procedure TArgumentParserParseArgsSameDestinationTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', 'foo', TStoreAction.saBool);
  FArgumentParser.AddArgument('-f', 'foo', TStoreAction.saBool);
  FArgumentParser.AddArgument('--bar', 'bar', TStoreAction.saStore);
  FArgumentParser.AddArgument('-b', 'bar', TStoreAction.saStore);
  FParseResult := nil;
  FTargetArgs := TStringList.Create;
end;

procedure TArgumentParserParseArgsSameDestinationTest.TearDown;
begin
  FArgumentParser.Free;
  FreeAndNil(FParseResult);
  FTargetArgs.Free;
end;

procedure TArgumentParserParseArgsSameDestinationTest.TestBool1;
begin
  FTargetArgs.Add('--foo');
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('foo'));
end;

procedure TArgumentParserParseArgsSameDestinationTest.TestBool2;
begin
  FTargetArgs.Add('-f');
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('foo'));
end;

procedure TArgumentParserParseArgsSameDestinationTest.TestBoolOverwrite;
begin
  FTargetArgs.Add('--foo');
  FTargetArgs.Add('-f');
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('foo'));
end;

procedure TArgumentParserParseArgsSameDestinationTest.TestStore1;
begin
  FTargetArgs.Add('--bar=bar_value');
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertEquals(FParseResult.GetValue('bar'), 'bar_value');
end;

procedure TArgumentParserParseArgsSameDestinationTest.TestStore2;
begin
  FTargetArgs.Add('-b');
  FTargetArgs.Add('bar_value');
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertEquals(FParseResult.GetValue('bar'), 'bar_value');
end;
(* End of TArgumentParserParseArgsSameDestinationTest *)

(* TArgumentParserParseArgsSwitchAndArgsTest *)
procedure TArgumentParserParseArgsSwitchAndArgsTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', TStoreAction.saBool);
  FArgumentParser.AddArgument('--bar', TStoreAction.saStore);
  FParseResult := nil;
  FTargetArgs := TStringList.Create;
  FTargetArgs.Add('--foo');
  FTargetArgs.Add('--bar');
  FTargetArgs.Add('bar_value');
  FTargetArgs.Add('value1');
  FTargetArgs.Add('value2');
end;

procedure TArgumentParserParseArgsSwitchAndArgsTest.TearDown;
begin
  FArgumentParser.Free;
  FreeAndNil(FParseResult);
  FTargetArgs.Free;
end;

procedure TArgumentParserParseArgsSwitchAndArgsTest.Test;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertTrue(FParseResult.HasArgument('foo'));
  AssertEquals(FParseResult.GetValue('bar'), 'bar_value');
  AssertEquals(FParseResult.Args.Count, 2);
  AssertEquals(FParseResult.Args[0], 'value1');
  AssertEquals(FParseResult.Args[1], 'value2');
end;
(* End of TArgumentParserParseArgsSwitchAndArgsTest *)

(* TArgumentParserParseArgsErrorTest *)

// Bytes currently allocated from the memory manager. Used to check that
// ParseArgs frees the partly built TParseResult when it raises.
{$IFDEF FPC}
function AllocatedBytes: Int64;
begin
  Result := GetFPCHeapStatus.CurrHeapUsed;
end;
{$ELSE}
function AllocatedBytes: Int64;
var
  State: TMemoryManagerState;
  I: Integer;
begin
  GetMemoryManagerState(State);
  Result := State.TotalAllocatedMediumBlockSize + State.TotalAllocatedLargeBlockSize;
  for I := Low(State.SmallBlockTypeStates) to High(State.SmallBlockTypeStates) do
    Result := Result + Int64(State.SmallBlockTypeStates[I].AllocatedBlockCount) *
        State.SmallBlockTypeStates[I].UseableBlockSize;
end;
{$ENDIF}

procedure TArgumentParserParseArgsErrorTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', TStoreAction.saBool);
  FArgumentParser.AddArgument('--bar', TStoreAction.saStore);
  FTargetArgs := TStringList.Create;
  // Stored before the error, so the partly built result holds some data.
  FTargetArgs.Add('--foo');
  FTargetArgs.Add('--bar=bar_value');
  FTargetArgs.Add('value1');
end;

procedure TArgumentParserParseArgsErrorTest.TearDown;
begin
  FArgumentParser.Free;
  FTargetArgs.Free;
end;

procedure TArgumentParserParseArgsErrorTest.AssertParseError(
    ExceptionClass: TExceptionClass; const ExpectedMessage: String);
const
  Iterations = 100;
var
  I: Integer;
  Before: Int64;
  RaisedClassName, RaisedMessage: String;

  procedure ParseOnce;
  begin
    RaisedClassName := '';
    RaisedMessage := '';
    try
      FArgumentParser.ParseArgs(FTargetArgs).Free;
    except
      on E: Exception do
      begin
        RaisedClassName := E.ClassName;
        RaisedMessage := E.Message;
      end;
    end;
  end;

begin
  // The first call may allocate memory that stays (for example in the RTL),
  // so it is not measured.
  ParseOnce;
  AssertEquals(RaisedClassName, ExceptionClass.ClassName);
  AssertEquals(RaisedMessage, ExpectedMessage);
  Before := AllocatedBytes;
  for I := 1 to Iterations do
    ParseOnce;
  AssertEquals(AllocatedBytes - Before, Int64(0));
end;

procedure TArgumentParserParseArgsErrorTest.TestInvalidArgument;
begin
  FTargetArgs.Add('--invalid');
  AssertParseError(EInvalidArgument, 'Invalid argument "--invalid"');
end;

procedure TArgumentParserParseArgsErrorTest.TestInvalidArgumentWithValue;
begin
  FTargetArgs.Add('--invalid=value');
  AssertParseError(EInvalidArgument, 'Invalid argument "--invalid"');
end;

procedure TArgumentParserParseArgsErrorTest.TestParameterMissing;
begin
  FTargetArgs.Add('--bar');
  AssertParseError(EParameterMissing, 'Missing value for "--bar"');
end;
(* End of TArgumentParserParseArgsErrorTest *)

(* TGetParamStrAsListTest *)
procedure TGetParamStrAsListTest.TestIncludingAppName;
var
  Params: TStringList;
begin
  Params := GetParamStrAsList;
  AssertEquals(Params.Count, 1);
  Params.Free;
end;

procedure TGetParamStrAsListTest.TestNotIncludingAppName;
var
  Params: TStringList;
begin
  Params := GetParamStrAsList(False);
  AssertEquals(Params.Count, 0);
  Params.Free;
end;
(* End of TGetParamStrAsListTest *)

initialization
  RegisterTest(TParseResultTest);
  RegisterTest(TArgumentTest);
  RegisterTest(TArgumentParserAddArgumentTest);
  RegisterTest(TArgumentParserHasArgumentTest);
  RegisterTest(TArgumentParserGetArgumentTest);
  RegisterTest(TArgumentParserParseArgsOnlySwitchTest);
  RegisterTest(TArgumentParserParseArgsStoreValueTest);
  RegisterTest(TArgumentParserParseArgsUnnamedArgsTest);
  RegisterTest(TArgumentParserParseArgsNoParameterTest);
  RegisterTest(TArgumentParserParseArgsSameDestinationTest);
  RegisterTest(TArgumentParserParseArgsSwitchAndArgsTest);
  RegisterTest(TArgumentParserParseArgsErrorTest);
  RegisterTest(TGetParamStrAsListTest);

end.
