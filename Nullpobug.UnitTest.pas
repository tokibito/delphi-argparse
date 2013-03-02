unit Nullpobug.UnitTest;

interface

uses
  System.SysUtils
  , System.StrUtils
  , System.Generics.Collections
  , System.Rtti
  , System.Diagnostics
  ;

type
  EAssertionError = class(Exception);
  ESkipTest = class(Exception);

  TTestResultType = (rtOK, rtFail, rtError, rtSkip);

  TTestResult = class(TObject)
  private
    FResultType: TTestResultType;
    FErrorClassName: String;
    FErrorMessage: String;
    FTestMethodName: String;
    FTestCaseName: String;
    FTime: Int64;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Update(ResultType: TTestResultType; ErrorClassName, ErrorMessage: String);
    property ResultType: TTestResultType read FResultType write FResultType;
    property ErrorClassName: String read FErrorClassName write FErrorClassName;
    property ErrorMessage: String read FErrorMessage write FErrorMessage;
    property TestMethodName: String read FTestMethodName write FTestMethodName;
    property TestCaseName: String read FTestCaseName write FTestCaseName;
    property Time: Int64 read FTime write FTime;
  end;

  TOnRanTestMethod = procedure(TestResult: TTestResult) of object;
  TTestProc = reference to procedure;
  TExceptionClass = class of Exception;

  TTestCase = class(TObject)
  private
    FOnRanTestMethod: TOnRanTestMethod;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetUp; virtual;
    procedure TearDown; virtual;
    procedure Assert(Value: Boolean); virtual;
    procedure AssertTrue(Value: Boolean); virtual;
    procedure AssertFalse(Value: Boolean); virtual;
    procedure AssertEquals(Value1, Value2: Integer); overload; virtual;
    procedure AssertEquals(Value1, Value2: Cardinal); overload; virtual;
    procedure AssertEquals(Value1, Value2: Int64); overload; virtual;
    procedure AssertEquals(Value1, Value2: UInt64); overload; virtual;
    procedure AssertEquals(Value1, Value2: ShortString); overload; virtual;
    procedure AssertEquals(Value1, Value2: String); overload; virtual;
    procedure AssertEquals(Value1, Value2: RawByteString); overload; virtual;
    procedure AssertIsNil(Value: TObject); virtual;
    procedure AssertIsNotNil(Value: TObject); virtual;
    procedure AssertRaises(ExceptionClass: TExceptionClass; Proc: TTestProc); overload; virtual;
    procedure Run(TestResultList: TObjectList<TTestResult>); virtual;
    property OnRanTestMethod: TOnRanTestMethod read FOnRanTestMethod write FOnRanTestMethod;
  end;

  TTestCaseClass = class of TTestCase;

  TTestSuite = class(TObject)
  private
    FTestCaseList: TObjectList<TTestCase>;
    FOnRanTestMethod: TOnRanTestMethod;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddTestCase(TestCaseClass: TTestCaseClass);
    procedure Run(TestCase: TTestCase; TestResultList: TObjectList<TTestResult>); virtual;
    procedure RunTests(TestResultList: TObjectList<TTestResult>); virtual;
    property OnRanTestMethod: TOnRanTestMethod read FOnRanTestMethod write FOnRanTestMethod;
  end;

  TTestRunner = class(TObject)
  private
    FTestSuiteList: TObjectList<TTestSuite>;
    FTestResultList: TObjectList<TTestResult>;
    FStopWatch: TStopWatch;
    function GetResultCount(ResultType: TTestResultType): Integer;
    function GetFailureCount: Integer;
    function GetErrorCount: Integer;
    function GetSkipCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddTestSuite(TestSuite: TTestSuite);
    procedure Run(TestSuite: TTestSuite); virtual;
    procedure RunTests; virtual;
    procedure SaveToXML(FileName: String);
    function IsAllGreen: Boolean;
    property TestResultList: TObjectList<TTestResult> read FTestResultList;
    property StopWatch: TStopWatch read FStopWatch;
    property FailureCount: Integer read GetFailureCount;
    property ErrorCount: Integer read GetErrorCount;
    property SkipCount: Integer read GetSkipCount;
  end;

  TTextTestRunner = class(TTestRunner)
  private
    function GetReusltMessage: String;
  public
    procedure WriteHeader;
    procedure WriteTestResult(TestResult: TTestResult);
    procedure WriteTestResultDetail(TestResult: TTestResult);
    procedure WriteFooter;
    procedure Run(TestSuite: TTestSuite); override;
    procedure RunTests; override;
  end;

procedure RunTest(OutputXMLFileName: String = '');
procedure RegisterTest(TestCaseClass: TTestCaseClass); overload;
procedure RegisterTest(TestSuite: TTestSuite); overload;

var
  TestRunner: TTestRunner;
  DefaultTestSuite: TTestSuite;

implementation

{ TestResult }
constructor TTestResult.Create;
begin
  FResultType := rtSkip;
  FTime := 0;
end;

destructor TTestResult.Destroy;
begin
  inherited Destroy;
end;

procedure TTestResult.Update(ResultType: TTestResultType; ErrorClassName, ErrorMessage: String);
begin
  FResultType := ResultType;
  FErrorClassName := ErrorClassName;
  FErrorMessage := ErrorMessage;
end;

{ TestCase }
constructor TTestCase.Create;
begin
  FOnRanTestMethod := nil;
end;

destructor TTestCase.Destroy;
begin
  FOnRanTestMethod := nil;
end;

procedure TTestCase.SetUp;
begin
end;

procedure TTestCase.TearDown;
begin
end;

procedure TTestCase.Assert(Value: Boolean);
begin
  if not (Value = True) then
    raise EAssertionError.CreateFmt('%s != True', [BoolToStr(Value, True)]);
end;

procedure TTestCase.AssertTrue(Value: Boolean);
begin
  Assert(Value);
end;

procedure TTestCase.AssertFalse(Value: Boolean);
begin
  if not (Value = False) then
    raise EAssertionError.CreateFmt('%s != False', [BoolToStr(Value, True)]);
end;

procedure TTestCase.AssertEquals(Value1, Value2: Integer);
begin
  if not (Value1 = Value2) then
    raise EAssertionError.CreateFmt('%d != %d', [Value1, Value2]);
end;

procedure TTestCase.AssertEquals(Value1, Value2: Cardinal);
begin
  if not (Value1 = Value2) then
    raise EAssertionError.CreateFmt('%d != %d', [Value1, Value2]);
end;

procedure TTestCase.AssertEquals(Value1, Value2: Int64);
begin
  if not (Value1 = Value2) then
    raise EAssertionError.CreateFmt('%d != %d', [Value1, Value2]);
end;

procedure TTestCase.AssertEquals(Value1, Value2: UInt64);
begin
  if not (Value1 = Value2) then
    raise EAssertionError.CreateFmt('%d != %d', [Value1, Value2]);
end;

procedure TTestCase.AssertEquals(Value1, Value2: ShortString);
begin
  if not (Value1 = Value2) then
    raise EAssertionError.CreateFmt('%s != %s', [Value1, Value2]);
end;

procedure TTestCase.AssertEquals(Value1, Value2: String);
begin
  if not (Value1 = Value2) then
    raise EAssertionError.CreateFmt('%s != %s', [Value1, Value2]);
end;

procedure TTestCase.AssertEquals(Value1, Value2: RawByteString);
begin
  if not (Value1 = Value2) then
    raise EAssertionError.CreateFmt('%s != %s', [Value1, Value2]);
end;

procedure TTestCase.AssertIsNil(Value: TObject);
begin
  if not (Value = nil) then
    raise EAssertionError.CreateFmt('%s is not nil.', [Value.ToString]);
end;

procedure TTestCase.AssertIsNotNil(Value: TObject);
begin
  if Value = nil then
    raise EAssertionError.CreateFmt('%s is nil.', [Value.ToString]);
end;

procedure TTestCase.AssertRaises(ExceptionClass: TExceptionClass; Proc: TTestProc);
var
  Raised: Boolean;
begin
  Raised := False;
  try
    Proc;
  except
    on E: Exception do
    begin
      if not Assigned(ExceptionClass) then
          raise
        else if E.ClassType.InheritsFrom(ExceptionClass) then
          Raised := True;
    end;
  end;
  if not Raised then
    raise EAssertionError.CreateFmt('%s is not raised.', [ExceptionClass.ClassName]);
end;

procedure TTestCase.Run(TestResultList: TObjectList<TTestResult>);
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  Method: TRttiMethod;
  TestResult: TTestResult;
  StopWatch: TStopWatch;
begin
  StopWatch := TStopWatch.Create;
  RttiContext := TRttiContext.Create;
  try
    RttiType := RttiContext.GetType(ClassType);
    for Method in RttiType.GetMethods do
    begin
      if LowerCase(LeftStr(Method.Name, 4)) = 'test' then
      begin
        TestResult := TTestResult.Create;
        TestResult.ResultType := rtOk;
        TestResult.TestMethodName := Method.Name;
        TestResult.TestCaseName := ToString;
        StopWatch.Reset;
        StopWatch.Start;
        try
          try
            SetUp;
            Method.Invoke(Self, []);
          except
            on E: EAssertionError do
              TestResult.Update(rtFail, E.ClassName, E.Message);
            on E: ESkipTest do
              TestResult.Update(rtSkip, E.ClassName, E.Message);
            on E: Exception do
              TestResult.Update(rtError, E.ClassName, E.Message);
          end;
        finally
          TearDown;
        end;
        TestResult.Time := StopWatch.ElapsedMilliseconds;
        if Assigned(FOnRanTestMethod) then
          FOnRanTestMethod(TestResult);
        TestResultList.Add(TestResult);
      end;
    end;
  finally
    RttiContext.Free;
    FreeAndNil(StopWatch);
  end;
end;

{ TestSuite }
constructor TTestSuite.Create;
begin
  FOnRanTestMethod := nil;
  FTestCaseList := TObjectList<TTestCase>.Create;
end;

destructor TTestSuite.Destroy;
begin
  FOnRanTestMethod := nil;
  FreeAndNil(FTestCaseList);
end;

procedure TTestSuite.AddTestCase(TestCaseClass: TTestCaseClass);
begin
  FTestCaseList.Add(TestCaseClass.Create);
end;

procedure TTestSuite.Run(TestCase: TTestCase; TestResultList: TObjectList<TTestResult>);
begin
  TestCase.OnRanTestMethod := FOnRanTestMethod;
  TestCase.Run(TestResultList);
  TestCase.OnRanTestMethod := nil;
end;

procedure TTestSuite.RunTests(TestResultList: TObjectList<TTestResult>);
var
  TestCase: TTestCase;
begin
  for TestCase in FTestCaseList do
    Run(TestCase, TestResultList);
end;

{ TestRunner }
constructor TTestRunner.Create;
begin
  FTestSuiteList := TObjectList<TTestSuite>.Create;
  FTestResultList := TObjectList<TTestResult>.Create;
  FStopWatch := TStopWatch.Create;
  FStopWatch.Start;
end;

destructor TTestRunner.Destroy;
begin
  FreeAndNil(FStopWatch);
  FreeAndNil(FTestSuiteList);
  FreeAndNil(FTestResultList);
  inherited Destroy;
end;

procedure TTestRunner.AddTestSuite(TestSuite: TTestSuite);
begin
  FTestSuiteList.Add(TestSuite);
end;

procedure TTestRunner.Run(TestSuite: TTestSuite);
begin
  TestSuite.RunTests(TestResultList);
end;

procedure TTestRunner.RunTests;
var
  TestSuite: TTestSuite;
begin
  for TestSuite in FTestSuiteList do
    Run(TestSuite);
end;

procedure TTestRunner.SaveToXML(FileName: String);
var
  Seconds: Single;
  OutputFile: Text;
  TestResult: TTestResult;
begin
  AssignFile(OutputFile, FileName);
  Rewrite(OutputFile);
  try
    Writeln(OutputFile, '<?xml version="1.0" encoding="UTF-8"?>');
    Writeln(OutputFile,
        Format('<testsuite name="%s" tests="%d" errors="%d" failures="%d" skip="%d">',
               ['default', TestResultList.Count, ErrorCount, FailureCount, SkipCount]));
    for TestResult in TestResultList do
    begin
      Seconds := TestResult.Time / 1000;
      case TestResult.ResultType of
        rtOK:
          Writeln(OutputFile,
              Format('<testcase classname="%s" name="%s" time="%.3f"/>',
                     [TestResult.TestCaseName, TestResult.TestMethodName, Seconds]));
        rtSkip:
        begin
          Writeln(OutputFile,
              Format('<testcase classname="%s" name="%s" time="%.3f">',
                     [TestResult.TestCaseName, TestResult.TestMethodName, Seconds]));
          Writeln(OutputFile, '<skipped/>');
          Writeln(OutputFile, '</testcase>');
        end;
      else
        begin
          Writeln(OutputFile,
              Format('<testcase classname="%s" name="%s" time="%.3f">',
                     [TestResult.TestCaseName, TestResult.TestMethodName, Seconds]));
          Writeln(OutputFile,
              Format('<failure type="%s">%s</failure>',
                     [TestResult.ErrorClassName, TestResult.ErrorMessage]));
          Writeln(OutputFile, '</testcase>');
        end;
      end;
    end;
    Writeln(OutputFile, '</testsuite>');
  finally
    CloseFile(OutputFile);
  end;
end;

function TTestRunner.IsAllGreen: Boolean;
begin
  Result := (FailureCount = 0) and (ErrorCount = 0);
end;

function TTestRunner.GetResultCount(ResultType: TTestResultType): Integer;
var
  TestResult: TTestResult;
begin
  Result := 0;
  for TestResult in FTestResultList do
    if TestResult.ResultType = ResultType then
      Inc(Result);
end;

function TTestRunner.GetFailureCount: Integer;
begin
  Result := GetResultCount(rtFail);
end;

function TTestRunner.GetErrorCount: Integer;
begin
  Result := GetResultCount(rtError);
end;

function TTestRunner.GetSkipCount: Integer;
begin
  Result := GetResultCount(rtSkip);
end;

{ TTextTestRunner }
function TTextTestRunner.GetReusltMessage: String;
var
  DetailMessageParts: TList<String>;
  DetailMessagePart, DetailMessage: String;
begin
  if IsAllGreen then
    Result := 'OK'
  else
    Result := 'FAILED';
  DetailMessageParts := TList<String>.Create;
  try
    if FailureCount > 0 then
      DetailMessageParts.Add(Format('failures=%d', [FailureCount]));
    if ErrorCount > 0 then
      DetailMessageParts.Add(Format('errors=%d', [ErrorCount]));
    if SkipCount > 0 then
      DetailMessageParts.Add(Format('skipped=%d', [SkipCount]));
    if DetailMessageParts.Count > 0 then
    begin
      DetailMessage := '';
      for DetailMessagePart in DetailMessageParts do
      begin
        if DetailMessage <> '' then
          DetailMessage := DetailMessage + ', ' + DetailMessagePart
        else
          DetailMessage := DetailMessagePart;
      end;
      Result := Result + Format(' (%s)', [DetailMessage]);
    end;
  finally
    FreeAndNil(DetailMessageParts);
  end;
end;

procedure TTextTestRunner.WriteHeader;
begin
end;

procedure TTextTestRunner.WriteTestResult(TestResult: TTestResult);
var
  ResultMark: String;
begin
  case TestResult.ResultType of
    rtOK: ResultMark := '.';
    rtFail: ResultMark := 'F';
    rtError: ResultMark := 'E';
    rtSkip: ResultMark := 'S';
  else
    ResultMark := '?';
  end;
  Write(ResultMark);
end;

procedure TTextTestRunner.WriteTestResultDetail(TestResult: TTestResult);
var
  ResultTypeString: String;
begin
  Writeln(DupeString('=', 70));
  case TestResult.ResultType of
    rtFail: ResultTypeString := 'FAIL';
    rtError: ResultTypeString := 'ERROR';
  end;
  Writeln(Format('%s: %s (%s)', [ResultTypeString, TestResult.TestMethodName, TestResult.TestCaseName]));
  Writeln(DupeString('-', 70));
  Writeln(Format('%s: %s', [TestResult.ErrorClassName, TestResult.ErrorMessage]));
  Writeln('');
end;

procedure TTextTestRunner.WriteFooter;
var
  Seconds: Single;
  TestResult: TTestResult;
begin
  Seconds := StopWatch.ElapsedMilliseconds / 1000;
  Writeln('');
  (* Display Error details *)
  for TestResult in FTestResultList do
    if TestResult.ResultType in [rtFail, rtError] then
      WriteTestResultDetail(TestResult);
  Writeln(DupeString('-', 70));
  Writeln(Format('Ran %d tests in %.3fs', [TestResultList.Count, Seconds]));
  Writeln('');
  Writeln(GetReusltMessage);
end;

procedure TTextTestRunner.Run(TestSuite: TTestSuite);
begin
  TestSuite.OnRanTestMethod := WriteTestResult;
  inherited Run(TestSuite);
end;

procedure TTextTestRunner.RunTests;
begin
  WriteHeader;
  inherited RunTests;
  WriteFooter;
end;

procedure RunTest(OutputXMLFileName: String = '');
begin
  TestRunner.RunTests;
  if OutputXMLFileName <> '' then
    TestRunner.SaveToXML(OutputXMLFileName);
end;

procedure RegisterTest(TestCaseClass: TTestCaseClass);
begin
  if DefaultTestSuite = nil then
  begin
    DefaultTestSuite := TTestSuite.Create;
    TestRunner.AddTestSuite(DefaultTestSuite);
  end;
  DefaultTestSuite.AddTestCase(TestCaseClass);
end;

procedure RegisterTest(TestSuite: TTestSuite);
begin
  TestRunner.AddTestSuite(TestSuite);
end;

initialization
  TestRunner := TTextTestRunner.Create;
  DefaultTestSuite := nil;

finalization
  DefaultTestSuite := nil;
  if not TestRunner.IsAllGreen then
    ExitCode := 1;
  FreeAndNil(TestRunner);

end.
