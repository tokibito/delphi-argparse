program ArgumentParserTest;

{$APPTYPE CONSOLE}

uses
  Nullpobug.UnitTest in '.\Nullpobug.UnitTest.pas',
  Nullpobug.ArgumentParser in '.\Nullpobug.ArgumentParser.pas',
  Nullpobug.ArgumentParserTest in '.\Nullpobug.ArgumentParserTest.pas';

begin
  Nullpobug.UnitTest.RunTest('ArgumentParserTest.xml');
end.
