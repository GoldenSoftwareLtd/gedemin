
unit gd_localization;

interface

uses
  Classes;

var
  LocalizationActive: Boolean;

procedure LocalizationInitParams;
procedure LocalizeComponent(C: TComponent);
function Translate(const S: String; C: TComponent;
  const IsMessage: Boolean = False): String;

implementation

uses
  ComObj, Forms, SysUtils, typInfo;

var
  LocalDoc: OleVariant;
  FromLang, ToLang: String;
  LocalFileName: String;
  LocalSave: Boolean;

procedure LocalizationInitParams;
var
  I: Integer;
begin
  FromLang := 'ru';
  ToLang := '';
  LocalFileName := '';
  LocalDoc := Unassigned;
  LocalizationActive := False;
  LocalSave := False;

  for I := 1 to ParamCount do
  begin
    if Pos('/LANG:', UpperCase(ParamStr(I))) = 1 then
    begin
      ToLang := LowerCase(Copy(ParamStr(I), 7, 2));
      Break;
    end;
  end;

  if ToLang = '' then
    exit;

  for I := 1 to ParamCount do
  begin
    if Pos('/LANGSAVE', UpperCase(ParamStr(I))) = 1 then
    begin
      LocalSave := True;
      Break;
    end;
  end;

  for I := 1 to ParamCount do
  begin
    if Pos('/LANGFILE:', UpperCase(ParamStr(I))) = 1 then
    begin
      LocalFileName := LowerCase(Copy(ParamStr(I), 11, 255));
      Break;
    end;
  end;

  if LocalFileName = '' then
    LocalFileName := 'local.xml';

  if ExtractFilePath(LocalFileName) = '' then
  begin
    LocalFileName := ExtractFilePath(Application.EXEName) +
      LocalFileName;
  end;

  if not FileExists(LocalFileName) then
    LocalFileName := ''
  else
    try
      LocalDoc := CreateOleObject('MSXML2.DOMDocument');
      if LocalDoc.Load(LocalFileName) then
      begin
        LocalDoc.SetProperty('SelectionLanguage', 'XPath');
        LocalizationActive := True;
      end;
    except
      LocalDoc := Unassigned;
    end;
end;

procedure SaveParams;
var
  I, L: Integer;
  SS: TStringList;
  S, SIn, SOut: String;
  F: Boolean;
begin
  if LocalizationActive and LocalSave then
  begin
    if FileExists(ExtractFilePath(Application.ExeName) +
      'strings.txt') then
    begin
      SS := TStringList.Create;
      try
        SS.LoadFromFile(ExtractFilePath(Application.ExeName) +
          'strings.txt');
        for I := 0 to SS.Count - 1 do
        begin
          Translate(SS[I], nil, False);
        end;
      finally
        SS.Free;
      end;
    end;

    if not VarIsEmpty(LocalDoc) then
    begin
      LocalDoc.Save(LocalFileName);

      SS := TStringList.Create;
      try
        SS.LoadFromFile(LocalFileName);
        F := True;
        SIn := SS.Text;
        SetLength(SOut, Length(SIn));
        L := 0;
        for I := 1 to Length(SIn) do
        begin
          if F and (SIn[I] in [' ', #13, #10, #9]) then
          begin
            continue;
          end;

          if F and (not (SIn[I] in [' ', #13, #10, #9])) then
          begin
            F := False;
            Inc(L);
            SOut[L] := SIn[I];
            continue;
          end;

          if (not F) and (SIn[I] in [#13, #10]) then
          begin
            F := True;
            continue;
          end;

          Inc(L);
          SOut[L] := SIn[I];
        end;

        S := Copy(SOut, 1, L);

        S := StringReplace(S, '<localizations', #13#10'<localizations',
          [rfIgnoreCase]);
        S := StringReplace(S, '</localizations>', #13#10'</localizations>',
          [rfIgnoreCase]);
        S := StringReplace(S, '<entries ', #13#10'  <entries ',
          [rfIgnoreCase, rfReplaceAll]);
        S := StringReplace(S, '</entries>', #13#10'  </entries>',
          [rfIgnoreCase, rfReplaceAll]);
        S := StringReplace(S, '<entries2', #13#10'    <entries2',
          [rfIgnoreCase, rfReplaceAll]);
        S := StringReplace(S, '</entries2>', #13#10'    </entries2>',
          [rfIgnoreCase, rfReplaceAll]);
        S := StringReplace(S, '<entry', #13#10'      <entry',
          [rfIgnoreCase, rfReplaceAll]);
        S := StringReplace(S, '</entry>', #13#10'      </entry>',
          [rfIgnoreCase, rfReplaceAll]);
        S := StringReplace(S, '<tokem ', #13#10'         <tokem ',
          [rfIgnoreCase, rfReplaceAll]);

        SS.Text := S;
        SS.SaveToFile(LocalFileName);
      finally
        SS.Free;
      end;
    end;
  end;
end;

function Translate(const S: String; C: TComponent;
  const IsMessage: Boolean = False): String;
var
  Sel: OleVariant;
  RootElement, TokemElement, Lang, T, T2: OleVariant;
  SAdj: String;
begin
  if (not LocalizationActive) or (S = '') then
  begin
    Result := S;
    Exit;
  end;

  try
    SAdj := Trim(S);

    SAdj := StringReplace(SAdj, #10, '#10', [rfReplaceAll]);
    SAdj := StringReplace(SAdj, #13, '#13', [rfReplaceAll]);

    while (Length(SAdj) > 0) and (SAdj[Length(SAdj)] in ['.', ':', '!', '-', ' ']) do
      SetLength(SAdj, Length(SAdj) - 1);

    if Length(SAdj) < 2 then
    begin
      Result := S;
      Exit;
    end;

    Sel := LocalDoc.selectNodes(
      Format('//entries[@letter=''%s'']/entries2[@letter=''%s'']/entry/tokem[@lang = ''%s'' and . = ''%s'']/../*[@lang = ''%s'']',
      [SAdj[1], SAdj[2], FromLang, SAdj, ToLang]));

    try
      if (Sel.Length > 0) then
      begin
        if (Trim(Sel.Item(0).NodeTypedValue) > '') then
        begin
          Result := StringReplace(S, SAdj, Sel.Item(0).NodeTypedValue, [rfIgnoreCase]);
        end else
          Result := S;
      end
      else begin
        Result := S;

        Sel := LocalDoc.selectNodes(
          Format('//entries[@letter=''%s'']/entries2[@letter=''%s'']/entry/tokem[@lang = ''%s'' and . = ''%s'']',
          [SAdj[1], SAdj[2], FromLang, SAdj]));

        if Sel.Length > 0 then
          exit;

        Sel := LocalDoc.selectNodes(
          Format('//entries[@letter=''%s'']',
          [SAdj[1]]));

        if Sel.Length = 0 then
        begin
          Sel := LocalDoc.SelectNodes('//*');

          if Sel.Length > 0 then
          begin
            RootElement := LocalDoc.CreateElement('entries');
            T2 := LocalDoc.CreateTextNode(SAdj[1]);
            Lang := LocalDoc.CreateAttribute('letter');
            Lang.AppendChild(T2);
            RootElement.SetAttributeNode(Lang);
            {T2 := LocalDoc.CreateTextNode('local.xsd');
            Lang := LocalDoc.CreateAttribute('xmlns');
            Lang.AppendChild(T2);
            RootElement.SetAttributeNode(Lang);}
            Sel.Item(0).AppendChild(RootElement);
          end;
        end;

        Sel := LocalDoc.selectNodes(
          Format('//entries[@letter=''%s'']/entries2[@letter=''%s'']',
          [SAdj[1], SAdj[2]]));

        if Sel.Length = 0 then
        begin
          Sel := LocalDoc.selectNodes(
            Format('//entries[@letter=''%s'']',
            [SAdj[1]]));

          if Sel.Length > 0 then
          begin
            RootElement := LocalDoc.CreateElement('entries2');
            T2 := LocalDoc.CreateTextNode(SAdj[2]);
            Lang := LocalDoc.CreateAttribute('letter');
            Lang.AppendChild(T2);
            RootElement.SetAttributeNode(Lang);
            {T2 := LocalDoc.CreateTextNode('local.xsd');
            Lang := LocalDoc.CreateAttribute('xmlns');
            Lang.AppendChild(T2);
            RootElement.SetAttributeNode(Lang);}
            Sel.Item(0).AppendChild(RootElement);
          end;
        end;

        Sel := LocalDoc.selectNodes(
          Format('//entries[@letter=''%s'']/entries2[@letter=''%s'']',
          [SAdj[1], SAdj[2]]));

        if Sel.Length > 0 then
        begin
          RootElement := LocalDoc.CreateElement('entry');

          TokemElement := LocalDoc.CreateElement('tokem');
          T := LocalDoc.CreateTextNode(SAdj);
          T2 := LocalDoc.CreateTextNode(FromLang);
          Lang := LocalDoc.CreateAttribute('lang');
          Lang.AppendChild(T2);
          TokemElement.AppendChild(T);
          TokemElement.SetAttributeNode(Lang);
          RootElement.AppendChild(TokemElement);

          TokemElement := LocalDoc.CreateElement('tokem');
          T := LocalDoc.CreateTextNode('');
          T2 := LocalDoc.CreateTextNode(ToLang);
          Lang := LocalDoc.CreateAttribute('lang');
          Lang.AppendChild(T2);
          TokemElement.AppendChild(T);
          TokemElement.SetAttributeNode(Lang);
          RootElement.AppendChild(TokemElement);

          {T2 := LocalDoc.CreateTextNode('local.xsd');
          Lang := LocalDoc.CreateAttribute('xmlns');
          Lang.AppendChild(T2);
          RootElement.SetAttributeNode(Lang);}

          Sel.Item(0).AppendChild(RootElement);
        end;
      end;
    finally
      Result := StringReplace(Result, '#10', #10, [rfReplaceAll]);
      Result := StringReplace(Result, '#13', #13, [rfReplaceAll]);
    end;
  except
    Result := S;
  end;
end;

procedure LocalizeComponent(C: TComponent);
var
  I: Integer;
  PropInfo: PPropInfo;
  S: String;
begin
  if (not LocalizationActive) or (C = nil) then
  begin
    Exit;
  end;

  PropInfo := GetPropInfo(C.ClassInfo, 'Caption');
  if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkLString) then
  begin
    S := GetStrProp(C, PropInfo);
    SetStrProp(C, PropInfo, Translate(S, C));
  end;

  PropInfo := GetPropInfo(C.ClassInfo, 'Hint');
  if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkLString) then
  begin
    S := GetStrProp(C, PropInfo);
    SetStrProp(C, PropInfo, Translate(S, C));
  end;

  for I := 0 to C.ComponentCount - 1 do
  begin
    LocalizeComponent(C.Components[I]);
  end;
end;

initialization

finalization
  SaveParams;
end.
