program ArgumentParserExample;

{$APPTYPE CONSOLE}

{$IF CompilerVersion >= 25}
  {$LEGACYIFEND ON}
{$IFEND}

uses
  {$IF CompilerVersion >= 23}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$IFEND}
  Nullpobug.ArgumentParser in '..\..\common\Nullpobug.ArgumentParser.pas';

var
  Parser: TArgumentParser;
  ParseResult: TParseResult;
  I: Integer;
begin
  Parser := TArgumentParser.Create;
  try
    try
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
        Writeln(Err.ClassName);
    end;
  finally
    Parser.Free;
  end;
end.
