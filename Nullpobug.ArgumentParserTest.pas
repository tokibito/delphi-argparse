unit Nullpobug.ArgumentParserTest;

interface

uses
  System.SysUtils
  , System.Generics.Collections
  , Nullpobug.UnitTest
  , Nullpobug.ArgumentParser
  ;

type
  TParseResultTest = class(TTestCase)
  private
    FParseResult: TParseResult;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestStoreBool;
    procedure TestStoreValue;
  end;

  TArgumentTest = class(TTestCase)
  private
    FArgument: TArgument;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestProperty;
  end;

  TArgumentParserAddArgumentTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestTArgument;
    procedure TestStringParameter;
    procedure TestOmitDestName;
  end;

  TArgumentParserHasArgumentTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestHasBoolArgument;
    procedure TestHasStoreArgument;
  end;

  TArgumentParserGetArgumentTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure Test;
  end;

  TArgumentParserParseArgsOnlySwitchTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TList<String>;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestSingleHyphen;
    procedure TestDoubleHyphen;
    procedure TestNotIncluded;
  end;

  TArgumentParserParseArgsStoreValueTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TList<String>;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestSingleHyphen;
    procedure TestDoubleHyphen;
    procedure TestDoubleHyphenWithEqualAssignment;
    procedure TestNotIncluded;
  end;

  TArgumentParserParseArgsUnnamedArgsTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TList<String>;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure Test;
  end;

  TArgumentParserParseArgsNoParameterTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure Test;
  end;

  TArgumentParserParseArgsSameDestinationTest = class(TTestCase)
  private
    FArgumentParser: TArgumentParser;
    FParseResult: TParseResult;
    FTargetArgs: TList<String>;
  published
    procedure SetUp; override;
    procedure TearDown; override;
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
    FTargetArgs: TList<String>;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure Test;
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
  FArgument := TArgument.Create('--foo', 'foo', saBool);
end;

procedure TArgumentTest.TearDown;
begin
  FArgument.Free;
end;

procedure TArgumentTest.TestProperty;
begin
  AssertEquals(FArgument.Option, '--foo');
  AssertEquals(FArgument.Dest, 'foo');
  AssertTrue(FArgument.StoreAction = saBool);
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
  FArgumentParser.AddArgument(TArgument.Create('--foo', 'bar', saStore));
  AssertEquals(FArgumentParser.Arguments.Count, 1);
  AssertEquals(FArgumentParser.Arguments[0].Option, '--foo');
  AssertEquals(FArgumentParser.Arguments[0].Dest, 'bar');
end;

procedure TArgumentParserAddArgumentTest.TestStringParameter;
begin
  FArgumentParser.AddArgument('--foo', 'bar', saStore);
  AssertEquals(FArgumentParser.Arguments.Count, 1);
  AssertEquals(FArgumentParser.Arguments[0].Option, '--foo');
  AssertEquals(FArgumentParser.Arguments[0].Dest, 'bar');
end;

procedure TArgumentParserAddArgumentTest.TestOmitDestName;
begin
  FArgumentParser.AddArgument('--foo', saStore);
  FArgumentParser.AddArgument('-b', saStore);
  AssertEquals(FArgumentParser.Arguments.Count, 2);
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
  FArgumentParser.AddArgument('--foo', saBool);
  FArgumentParser.AddArgument('--bar', saStore);
end;

procedure TArgumentParserHasArgumentTest.TearDown;
begin
  FArgumentParser.Free;
end;

procedure TArgumentParserHasArgumentTest.TestHasBoolArgument;
begin
  AssertTrue(FArgumentParser.HasArgument('--foo', saBool));
  AssertFalse(FArgumentParser.HasArgument('--bar', saBool));
  AssertFalse(FArgumentParser.HasArgument('--invalid', saBool));
end;

procedure TArgumentParserHasArgumentTest.TestHasStoreArgument;
begin
  AssertTrue(FArgumentParser.HasArgument('--bar', saStore));
  AssertFalse(FArgumentParser.HasArgument('--foo', saStore));
  AssertFalse(FArgumentParser.HasArgument('--invalid', saStore));
end;
(* End of TArgumentParserHasArgumentTest *)

(* TArgumentParserGetArgumentTest *)
procedure TArgumentParserGetArgumentTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', saBool);
  FArgumentParser.AddArgument('--bar', saStore);
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
  FArgumentParser.AddArgument('--foo', saBool);
  FArgumentParser.AddArgument('--bar', saBool);
  FArgumentParser.AddArgument('-b', saBool);
  FParseResult := nil;
  FTargetArgs := TList<String>.Create;
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
  FArgumentParser.AddArgument('--foo', saStore);
  FArgumentParser.AddArgument('--bar', saStore);
  FArgumentParser.AddArgument('-b', saStore);
  FArgumentParser.AddArgument('--hoge', saStore);
  FParseResult := nil;
  FTargetArgs := TList<String>.Create;
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

procedure TArgumentParserParseArgsStoreValueTest.TestNotIncluded;
begin
  FParseResult := FArgumentParser.ParseArgs(FTargetArgs);
  AssertFalse(FParseResult.HasArgument('bar'));
  AssertRaises(ENoSuchArgument,
    procedure
    begin
      FParseResult.GetValue('bar');
    end
  );
end;
(* End of TArgumentParserParseArgsStoreValueTest *)

(* TArgumentParserParseArgsUnnamedArgsTest *)
procedure TArgumentParserParseArgsUnnamedArgsTest.SetUp;
begin
  FArgumentParser := TArgumentParser.Create;
  FArgumentParser.AddArgument('--foo', saBool);
  FArgumentParser.AddArgument('--bar', saStore);
  FParseResult := nil;
  FTargetArgs := TList<String>.Create;
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
  FArgumentParser.AddArgument('--foo', 'foo', saBool);
  FArgumentParser.AddArgument('-f', 'foo', saBool);
  FArgumentParser.AddArgument('--bar', 'bar', saStore);
  FArgumentParser.AddArgument('-b', 'bar', saStore);
  FParseResult := nil;
  FTargetArgs := TList<String>.Create;
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
  FArgumentParser.AddArgument('--foo', saBool);
  FArgumentParser.AddArgument('--bar', saStore);
  FParseResult := nil;
  FTargetArgs := TList<String>.Create;
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

(* TGetParamStrAsListTest *)
procedure TGetParamStrAsListTest.TestIncludingAppName;
var
  Params: TList<String>;
begin
  Params := GetParamStrAsList;
  AssertEquals(Params.Count, 1);
  Params.Free;
end;

procedure TGetParamStrAsListTest.TestNotIncludingAppName;
var
  Params: TList<String>;
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
  RegisterTest(TGetParamStrAsListTest);

end.
