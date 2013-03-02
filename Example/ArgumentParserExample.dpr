program ArgumentParserExample;

{$APPTYPE CONSOLE}

uses
  Nullpobug.ArgumentParser in '..\Nullpobug.ArgumentParser.pas'
  , System.SysUtils
  , System.Generics.Collections
  ;

var
  Parser: TArgumentParser;
  ParseResult: TParseResult;
  I: Integer;

begin
  Parser := TArgumentParser.Create;
  try
    try
      // 引数を追加
      Parser.AddArgument('--help', saBool);
      Parser.AddArgument('--foo', saBool);
      Parser.AddArgument('--bar', 'bar', saStore);
      Parser.AddArgument('-b', 'bar', saStore);
      ParseResult := Parser.ParseArgs;
      try
        // help
        if ParseResult.HasArgument('help') then
        begin
          Writeln('--help'#10'--foo'#10'--bar -b');
          Exit;
        end;
        // foo
        Writeln('foo: ' + BoolToStr(ParseResult.HasArgument('foo'), True));
        // bar
        if ParseResult.HasArgument('bar') then
          Writeln('bar: ' + ParseResult.GetValue('bar'))
        else
          Writeln('bar: (nothing)');
        // args
        for I := 0 to ParseResult.Args.Count - 1 do
          Writeln(Format('arg%d :%s', [I + 1, ParseResult.Args[I]]));
      finally
        ParseResult.Free;
      end;
    except
      on Err: Exception do
        Writeln(Err.ToString);
    end;
  finally
    Parser.Free;
  end;
end.
