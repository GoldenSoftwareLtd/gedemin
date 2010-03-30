 
unit gd_strings;

interface

uses
  SysUtils, Windows, Classes, SynEdit;

const
  cgdClassListIsNotAssigned  = 'gdClassList is not assigned!';

function RemoveProhibitedSymbols(const S: String): String;
function PasteSQL(Editor: TCustomSynEdit): boolean;
function CopySQL(Editor: TCustomSynEdit): boolean;

implementation

uses Clipbrd
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

function RemoveProhibitedSymbols(const S: String): String;
begin
  Result := StringReplace(StringReplace(S, '$', '_', [rfReplaceAll]),
    ' ', '_', [rfReplaceAll]);
end;

function PasteSQL(Editor: TCustomSynEdit): boolean;
var
  SL: TStringList;
  I: Integer;
  TempStr, ClearStr: String;
begin
  Result:= False;
  if not Assigned(Editor) then Exit;

  if Clipboard.HasFormat(CF_TEXT) then
  begin
    SL := TStringList.Create;
    try
      if Editor.SelText <> '' then begin
        Editor.SelText:= '';
        ClearStr:= StringOfChar(' ', 4);
      end;
//      else
      if Trim(Editor.LineText) <> '' then begin
        i:= 1;
        ClearStr:= '';
        while Editor.LineText[i] = ' ' do
          Inc(i);
        if i < Editor.CaretX then
          Inc(i)
        else
          i:= Editor.CaretX - 1;
      end
      else
        i:= Editor.CaretX - 1;
      ClearStr:= StringOfChar(' ', i);
      SL.Text := Clipboard.AsText;
      TempStr := Clipboard.AsText;
      for I := 0 to SL.Count - 1 do
      begin
        if I = 0 then
          SL[I] := Concat('"', SL[I], ' " & _')
        else if I <> SL.Count -1 then
          SL[I] := Concat(ClearStr, '"', SL[I], ' " & _')
        else
          SL[I] := Concat(ClearStr, '"', SL[I], ' "');
      end;

      Clipboard.AsText := SL.Text;
    finally
      SL.Free;
    end;

    Editor.PasteFromClipboard;
    Clipboard.AsText := TempStr;
    Result:= True;
  end;
end;

function CopySQL(Editor: TCustomSynEdit): boolean;
var
  SL: TStringList;
  I: Integer;
begin
  Result:= False;
  SL:= TStringList.Create;
  try
    SL.BeginUpdate;
    SL.Text:= Editor.SelText;
    for I:= 0 to SL.Count - 1 do begin
      while (SL[I] > '') and (SL[I][1] <> '"') do
        SL[I]:= System.Copy(SL[I], 2, Length(SL[I]));
      if SL[I] > '' then SL[I]:= System.Copy(SL[I], 2, Length(SL[I]));
      while (SL[I] > '') and (SL[I][Length(SL[I])] <> '"') do
        SL[I]:= System.Copy(SL[I], 1, Length(SL[I]) - 1);
      if SL[I] > '' then SL[I]:= System.Copy(SL[I], 1, Length(SL[I]) - 1);
    end;

    SL.Text:= SL.Text + #0;
    SL.EndUpdate;

    Clipboard.SetTextBuf(PChar(@SL.Text[1]));
  finally
    SL.Free;
  end;
end;

initialization
  { TODO : обратить ОСОБОЕ внимание! }
  //!!!

  if False then
  begin

    if Now > EncodeDate(2004, 06, 01) then
    begin
      MessageBox(0,
        'Срок использования бета-версии программы истек!'#13#10 +
        'для продолжения работы обратитесь в компанию Golden Software.'#13#10#13#10 +
        'тел/факс: (017) 2561759, 2562782; email: support@gsbelarus.com; http://gsbelarus.com',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

      Halt(1);
    end else
    if Now > EncodeDate(2004, 02, 01) then
    begin
      MessageBox(0,
        'Срок использования бета-версии программы истечет через четыре месяца!'#13#10 +
        'Обратитесь в компанию Golden Software.'#13#10#13#10 +
        'тел/факс: (017) 2561759, 2562782; email: support@gsbelarus.com; http://gsbelarus.com',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    end;

  end;  
  //!!!

end.
 