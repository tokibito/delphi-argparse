unit Nullpobug.ArgumentParser;

interface

uses
  System.SysUtils
  , System.StrUtils
  , System.Generics.Collections
  ;

type
  ENoMatchArgument = class(Exception);  // 一致する引数がありません
  EInvalidArgument = class(Exception);  // 不正な引数です
  EParameterMissing = class(Exception);  // パラメータが不足しています
  ENoSuchArgument = class(Exception);  // そのような引数はありません

  TStoreAction = (saBool, saStore);

  TParseResult = class
  private
    FStoredValues: TDictionary<String, String>;
    FStoredBools: TList<String>;
    FUnnamedValues: TList<String>;
  public
    constructor Create;
    destructor Destroy; override;
    function HasArgument(Dest: String): Boolean;
    function GetValue(Dest: String): String;
    procedure StoreBool(Dest: String);
    procedure StoreValue(Dest: String; Value: String);
    property StoredBools: TList<String> read FStoredBools;
    property StoredValues: TDictionary<String, String> read FStoredValues;
    property Args: TList<String> read FUnnamedValues;
  end;

  TArgument = class
  private
    FOption: String;
    FDest: String;
    FStoreAction: TStoreAction;
  public
    constructor Create(Option, Dest: String; StoreAction: TStoreAction);
    destructor Destroy; override;
    property Option: String read FOption;
    property Dest: String read FDest;
    property StoreAction: TStoreAction read FStoreAction;
  end;

  TArgumentParser = class
  private
    FDescription: String;
    FArguments: TObjectList<TArgument>;
  public
    constructor Create(Description: String = '');
    destructor Destroy; override;
    function ParseArgs: TParseResult; overload;
    function ParseArgs(TargetArgs: TList<String>): TParseResult; overload;
    procedure AddArgument(Argument: TArgument); overload;
    procedure AddArgument(Option, Dest: String;
        StoreAction: TStoreAction = saBool); overload;
    procedure AddArgument(Option: String;
        StoreAction: TStoreAction = saBool); overload;
    function HasArgument(Option: String;
        StoreAction: TStoreAction = saBool): Boolean;
    function GetArgument(Option: String): TArgument;
    property Description: String read FDescription write FDescription;
    property Arguments: TObjectList<TArgument> read FArguments;
  end;

function GetParamStrAsList(IsIncludingAppName: Boolean = True): TList<String>;

implementation

(* TParseResult *)
constructor TParseResult.Create;
begin
  FStoredValues := TDictionary<String, String>.Create;
  FStoredBools := TList<String>.Create;
  FUnnamedValues := TList<String>.Create;
end;

destructor TParseResult.Destroy;
begin
  FStoredValues.Free;
  FStoredBools.Free;
  FUnnamedValues.Free;
  inherited Destroy;
end;

function TParseResult.HasArgument(Dest: String): Boolean;
(*
  Destで指定したオプションが含まれるかどうかを返す
  True: 含まれる, False: 含まれない
 *)
begin
  Result := (FStoredBools.IndexOf(Dest) <> -1) or FStoredValues.ContainsKey(Dest);
end;

function TParseResult.GetValue(Dest: String): String;
(*
  Destで指定したオプションの値を返す
 *)
begin
  if HasArgument(Dest) then
    Result := FStoredValues[Dest]
  else
    raise ENoSuchArgument.CreateFmt('No such argument "%s"', [Dest]);
end;

procedure TParseResult.StoreBool(Dest: String);
(*
  真偽値で保持する値を追加する
 *)
begin
  if not HasArgument(Dest) then
    FStoredBools.Add(Dest);
end;

procedure TParseResult.StoreValue(Dest: String; Value: String);
(*
  キーと値で保持する値を追加する
 *)
begin
  if not HasArgument(Dest) then
    FStoredValues.Add(Dest, Value);
end;
(* End of TParseResult *)

(* TArgument *)
constructor TArgument.Create(Option, Dest: String; StoreAction: TStoreAction);
begin
  FOption := Option;
  FDest := Dest;
  FStoreAction := StoreAction;
end;

destructor TArgument.Destroy;
begin
  inherited Destroy;
end;
(* End of TArgument *)

(* TArgumentParser *)
constructor TArgumentParser.Create(Description: String = '');
begin
  FDescription := Description;
  FArguments := TObjectList<TArgument>.Create;
end;

destructor TArgumentParser.Destroy;
begin
  FArguments.Free;
  inherited Destroy;
end;

function TArgumentParser.ParseArgs: TParseResult;
var
  Params: TList<String>;
begin
  (* 実行ファイル名を除いたパラメータを取得 *)
  Params := GetParamStrAsList(False);
  try
    Result := ParseArgs(Params);
  finally
    Params.Free;
  end;
end;

function TArgumentParser.ParseArgs(TargetArgs: TList<String>): TParseResult;
var
  CurrentIndex: Integer;
  CurrentParam: String;
  SeparatorPosition: Integer;
  Key, Value: String;
  Argument: TArgument;
begin
  Result := TParseResult.Create;
  CurrentIndex := 0;
  while CurrentIndex < TargetArgs.Count do
  begin
    (* 現在位置のパラメータを取得 *)
    CurrentParam := TargetArgs[CurrentIndex];
    (* 先頭が-で始まるか *)
    if LeftStr(CurrentParam, 1) = '-' then
    begin
      (* パラメータ名に=の文字が含まれているか *)
      SeparatorPosition := Pos('=', CurrentParam);
      if SeparatorPosition <> 0 then
      begin
        (* 含まれているならKeyとValueに分割する *)
        Key := LeftStr(CurrentParam, SeparatorPosition - 1);
        Value := RightStr(CurrentParam, Length(CurrentParam) - SeparatorPosition);
        (* Keyがパーサーに含まれているか *)
        if HasArgument(Key, saStore) then
        begin
          (* 含まれているなら結果に保持 *)
          Argument := GetArgument(Key);
          Result.StoreValue(Argument.Dest, Value);
        end
        else
          raise EInvalidArgument.CreateFmt('Invalid argument "%s"', [Key]);
      end
      else
      begin
        (* 含まれていないならKeyとする *)
        Key := CurrentParam;
        (* Keyがパーサーに含まれているか(Bool) *)
        if HasArgument(Key, saBool) then
        begin
          (* 含まれているなら結果に保持 *)
          Argument := GetArgument(Key);
          Result.StoreBool(Argument.Dest);
        end
        else
          (* Keyがパーサーに含まれているか(Store) *)
          if HasArgument(Key, saStore) then
          begin
            (* 含まれているなら次のパラメータを値として取得する *)
            Inc(CurrentIndex);
            (* 後ろにパラメータが無ければエラー *)
            if CurrentIndex >= TargetArgs.Count then
              raise EParameterMissing.CreateFmt('Missing value for "%s"', [Key]);
            Value := TargetArgs[CurrentIndex];
            (* 結果に保持 *)
            Argument := GetArgument(Key);
            Result.StoreValue(Argument.Dest, Value);
          end
          else
            raise EInvalidArgument.CreateFmt('Invalid argument "%s"', [Key]);
      end;
    end
    else
    begin
      (* スイッチ以外の場合はそのまま値として追加する *)
      Value := TargetArgs[CurrentIndex];
      Result.Args.Add(Value);
    end;
    (* 参照位置を一つ後ろにする *)
    Inc(CurrentIndex);
  end;
end;

procedure TArgumentParser.AddArgument(Argument: TArgument);
(* Argumentを追加する *)
begin
  FArguments.Add(Argument);
end;

procedure TArgumentParser.AddArgument(Option, Dest: String;
    StoreAction: TStoreAction = saBool);
(* Option, Dest, StoreActionパラメータでTArgumentのインスタンスを生成して追加 *)
var
  Argument: TArgument;
begin
  Argument := TArgument.Create(Option, Dest, StoreAction);
  AddArgument(Argument);
end;

procedure TArgumentParser.AddArgument(Option: String; StoreAction: TStoreAction = saBool);
(* DestをOptionと同じ名前(ハイフンは除去)でパラメータでTArgumentのインスタンスを生成して追加 *)
var
  Dest: String;
begin
  (* 先頭の--と-を除去する *)
  if LeftStr(Option, 2) = '--' then
    Dest := Copy(Option, 3, Length(Option) - 2)
  else if LeftStr(Option, 1) = '-' then
    Dest := Copy(Option, 2, Length(Option) - 1)
  else
    Dest := Option;
  AddArgument(Option, Dest, StoreAction);
end;

function TArgumentParser.HasArgument(Option: String;
    StoreAction: TStoreAction = saBool): Boolean;
(*
  指定されたOptionとStoreActionに一致する引数が登録されていればTrueを返す
 *)
var
  Argument: TArgument;
begin
  for Argument in Arguments do
    if (Argument.Option = Option) and (Argument.StoreAction = StoreAction) then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

function TArgumentParser.GetArgument(Option: String): TArgument;
(*
  Optionで指定された引数を返す
  見つからない場合はENoMatchArgument例外を発生させる
 *)
var
  Argument: TArgument;
begin
  for Argument in Arguments do
    if Argument.Option = Option then
    begin
      Result := Argument;
      Exit;
    end;
  raise ENoMatchArgument.CreateFmt('No such argument "%s"', [Option]);
end;
(* End of TArgumentParser *)

(* Utility function *)
function GetParamStrAsList(IsIncludingAppName: Boolean = True): TList<String>;
(*
  ParamStrをTList<String>形式で返す関数
  IsIncludingAppNameにFalseを指定するとプログラム名を含めない
 *)
var
  I: Integer;
  StartIndex: Integer;
begin
  Result := TList<String>.Create;
  if IsIncludingAppName then
    StartIndex := 0
  else
    StartIndex := 1;
  for I := StartIndex to ParamCount do
    Result.Add(ParamStr(I));
end;
(* End of Utility function *)

end.
