// ShlTanya, 24.02.2019

{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    CodeExplorerParser.pas

  Abstract

    Gedemin project. TCodeExplorerParser.

  Author

    Karpuk Alexander

  Revisions history

    1.00    11.11.01    tiptop        Initial version.

--}

unit CodeExplorerParser;

interface
  uses VBParser, classes, Sysutils;

type
  TCodeExplorerParser = class(TVBParser)
  private

  protected

  public
    //Заполняет список имен функций, объявленных в скрипте
    procedure ProceduresList(const Script, List: TStrings);
    function CheckFunctionName(Name, Script: string): Boolean;
  end;

implementation

uses
  gd_ScriptCompiler;

{ TCodeExplorerParser }

function TCodeExplorerParser.CheckFunctionName(Name,
  Script: string): Boolean;
var
  L: TStrings;
begin
  L := TStringList.Create;
  try
    InternalScriptList(Script, L);
    Result := L.IndexOf(AnsiUpperCase(Name)) > - 1;
    if Result then
      Result := (Length(Name) > 0) and
        (Pos(Name[1], Letters) > 0) and (Pos(Name[1], Numbers) = 0);
  finally
    L.Free;
  end;
end;

procedure TCodeExplorerParser.ProceduresList(const Script, List: TStrings);
var
  CurrentWord: String;
  Line: Integer;

  procedure FindEndLine;
  begin
    while (FCursorPos <= Length(FStr)) and (FStr[FCursorPos + 1] <> #10) do
      Inc(FCursorPos);
//    Inc(Line);
  end;

  function ANextWord: Integer;
  begin
    Result := FCursorPos;
    Inc(Result);
    while  (Result < Length(FStr)) and ((Pos(FStr[Result - 1], Separators) = 0) or
      (Pos(FStr[Result], Letters) = 0)) do
    begin
      if FStr[Result] = #10 then Inc(Line);
      Inc(Result);
    end;
    if Result > Length(FStr) then
      Result := - 1;
  end;

  procedure ATrimSpace;
  begin
    while (FCursorPos < Length(FStr) - 1) and ((FStr[FCursorPos] = ' ') or
      (FStr[FCursorPos] = #10) or (FStr[FCursorPos] = #13))do
    begin
      if FStr[FCursorPos] = #10 then Inc(Line);
      Inc(FCursorPos);
    end;
  end;

begin
  if not Assigned(Script) or not Assigned(List) then Exit;

  FScript.Assign(Script);
  FStr := FScript.Text;
  FCursorPos := 1;
  Line := 0;
  FFunctionName := '';
  try
    while (FCursorPos <= Length(FStr)) and (FCursorPos <> - 1) do
    begin
      ATrimSpace;
      CurrentWord := UpperCase(GetCurrentWord);
      if (CurrentWord = 'SUB') or (CurrentWord = 'FUNCTION') then
      begin
        FCursorPos := NextWord;
        List.AddObject(GetCurrentWord, Pointer(Line));
        FindEndLine;
      end else
      if CurrentWord = 'PROPERTY' then
      begin
        FCursorPos := NextWord;
        CurrentWord := UpperCase(GetCurrentWord);
        if (CurrentWord = 'GET') or (CurrentWord = 'LET') or
           (CurrentWord = 'SET') then
        begin
          FCursorPos := NextWord;
          List.AddObject(GetCurrentWord, Pointer(Line));
          FindEndLine;
        end;
      end else
      if (CurrentWord = 'END') or (CurrentWord = 'EXIT') then
      begin
        FCursorPos := NextWord;
        CurrentWord := UpperCase(GetCurrentWord);
        if (CurrentWord = 'SUB') or (CurrentWord = 'FUNCTION') or
          (CurrentWord = 'PROPERTY') then
        begin
          FindEndLine;
        end;
      end else
        FCursorPos := ANextWord;
    end;
  except
  end;
end;

end.
