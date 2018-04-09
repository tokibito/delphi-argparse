program ArgumentParserTest;

{$MODE Delphi}

{$APPTYPE CONSOLE}

uses
  Nullpobug.UnitTest in '..\common\Nullpobug.UnitTest.pas',
  Nullpobug.ArgumentParser in '..\common\Nullpobug.ArgumentParser.pas',
  Nullpobug.ArgumentParserTest in '..\common\Nullpobug.ArgumentParserTest.pas';

begin
  Nullpobug.UnitTest.RunTest('ArgumentParserTest.xml');
end.
