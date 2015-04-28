
{******************************************}
{                                          }
{             FastReport v2.53             }
{            Various routines              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Utils;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  FR_DBRel, Forms, StdCtrls, Menus, FR_Class;


procedure frReadMemo(Stream: TStream; l: TStrings);
procedure frReadMemo22(Stream: TStream; l: TStrings);
procedure frWriteMemo(Stream: TStream; l: TStrings);
function frReadString(Stream: TStream): String;
function frReadString22(Stream: TStream): String;
procedure frWriteString(Stream: TStream; s: String);
function frReadBoolean(Stream: TStream): Boolean;
function frReadByte(Stream: TStream): Byte;
function frReadWord(Stream: TStream): Word;
function frReadInteger(Stream: TStream): Integer;
procedure frReadFont(Stream: TStream; Font: TFont);
procedure frWriteBoolean(Stream: TStream; Value: Boolean);
procedure frWriteByte(Stream: TStream; Value: Byte);
procedure frWriteWord(Stream: TStream; Value: Word);
procedure frWriteInteger(Stream: TStream; Value: Integer);
procedure frWriteFont(Stream: TStream; Font: TFont);
procedure frEnableControls(c: Array of TControl; e: Boolean);
function frControlAtPos(Win: TWinControl; p: TPoint): TControl;
function frGetDataSet(ComplexName: String): TfrTDataSet;
function frGetFieldValue(F: TfrTField): Variant;
procedure frGetDataSetAndField(ComplexName: String;
  var DataSet: TfrTDataSet; var Field: String);
function frGetFontStyle(Style: TFontStyles): Integer;
function frSetFontStyle(Style: Integer): TFontStyles;
function frFindComponent(Owner: TComponent; Name: String): TComponent;
procedure frGetComponents(Owner: TComponent; ClassRef: TClass;
  List: TStrings; Skip: TComponent);
function frGetWindowsVersion: String;
function frStrToFloat(s: String): Double;
function frRemoveQuotes(const s: String): String;
procedure frSetCommaText(Text: String; sl: TStringList);
function frLoadStr(ID: Integer): String;
procedure SaveToFR3Stream(Report: TfrReport; Stream: TStream);
function StrToXML(const s: String): String;
function frStreamToString(Stream: TStream): String;
function frFieldIsNull(FieldName: String): Boolean;
{$IFNDEF Delphi6}
function Utf8Encode(const WS: WideString): String;
{$ENDIF}
function frFloatToStrF(Value: Extended; Format: TFloatFormat;
          Precision, Digits: Integer; Separator: char): string;
function HTMLRGBColor(Color: TColor): string;

implementation

uses FR_DSet, FR_DBSet, Printers
  {$IFDEF IBO}
   , IB_Components, IB_Header
   {$ELSE}
   , DB
   {$ENDIF}
   {$IFDEF Delphi6}
   , Variants
   {$ENDIF};


//--------------------------------------------------------------------------
function frSetFontStyle(Style: Integer): TFontStyles;
begin
  Result := [];
  if (Style and $1) <> 0 then Result := Result + [fsItalic];
  if (Style and $2) <> 0 then Result := Result + [fsBold];
  if (Style and $4) <> 0 then Result := Result + [fsUnderLine];
  if (Style and $8) <> 0 then Result := Result + [fsStrikeOut];
end;

function frGetFontStyle(Style: TFontStyles): Integer;
begin
  Result := 0;
  if fsItalic in Style then Result := Result or $1;
  if fsBold in Style then Result := Result or $2;
  if fsUnderline in Style then Result := Result or $4;
  if fsStrikeOut in Style then Result := Result or $8;
end;

procedure frReadMemo(Stream: TStream; l: TStrings);
var
  s: String;
  b: Byte;
  n: Word;
begin
  l.Clear;
  Stream.Read(n, 2);
  if n > 0 then
    repeat
      Stream.Read(n, 2);
      SetLength(s, n);
      if n > 0 then
        Stream.Read(s[1], n);
      l.Add(s);
      Stream.Read(b, 1);
    until b = 0
  else
    Stream.Read(b, 1);
end;

procedure frWriteMemo(Stream: TStream; l: TStrings);
var
  s: String;
  i: Integer;
  n: Word;
  b: Byte;
begin
  n := l.Count;
  Stream.Write(n, 2);
  for i := 0 to l.Count - 1 do
  begin
    s := l[i];
    n := Length(s);
    Stream.Write(n, 2);
    if n > 0 then
      Stream.Write(s[1], n);
    b := 13;
    if i <> l.Count - 1 then Stream.Write(b, 1);
  end;
  b := 0;
  Stream.Write(b, 1);
end;

function frReadString(Stream: TStream): String;
var
  s: String;
  n: Word;
  b: Byte;
begin
  Stream.Read(n, 2);
  SetLength(s, n);
  if n > 0 then
    Stream.Read(s[1], n);
  Stream.Read(b, 1);
  Result := s;
end;

procedure frWriteString(Stream: TStream; s: String);
var
  b: Byte;
  n: Word;
begin
  n := Length(s);
  Stream.Write(n, 2);
  if n > 0 then
    Stream.Write(s[1], n);
  b := 0;
  Stream.Write(b, 1);
end;

procedure frReadMemo22(Stream: TStream; l: TStrings);
var
  s: String;
  i: Integer;
  b: Byte;
begin
  SetLength(s, 4096);
  l.Clear;
  i := 1;
  repeat
    Stream.Read(b,1);
    if (b = 13) or (b = 0) then
    begin
      SetLength(s, i - 1);
      if not ((b = 0) and (i = 1)) then l.Add(s);
      SetLength(s, 4096);
      i := 1;
    end
    else if b <> 0 then
    begin
      s[i] := Chr(b);
      Inc(i);
      if i > 4096 then
        SetLength(s, Length(s) + 4096);
    end;
  until b = 0;
end;

function frReadString22(Stream: TStream): String;
var
  s: String;
  i: Integer;
  b: Byte;
begin
  SetLength(s, 4096);
  i := 1;
  repeat
    Stream.Read(b, 1);
    if b = 0 then
      SetLength(s, i - 1)
    else
    begin
      s[i] := Chr(b);
      Inc(i);
      if i > 4096 then
        SetLength(s, Length(s) + 4096);
    end;
  until b = 0;
  Result := s;
end;

function frReadBoolean(Stream: TStream): Boolean;
begin
  Stream.Read(Result, 1);
end;

function frReadByte(Stream: TStream): Byte;
begin
  Stream.Read(Result, 1);
end;

function frReadWord(Stream: TStream): Word;
begin
  Stream.Read(Result, 2);
end;

function frReadInteger(Stream: TStream): Integer;
begin
  Stream.Read(Result, 4);
end;

{$HINTS OFF}
procedure frReadFont(Stream: TStream; Font: TFont);
var
  w: Word;
begin
  Font.Name := frReadString(Stream);
  Font.Size := frReadInteger(Stream);
  Font.Style := frSetFontStyle(frReadWord(Stream));
  Font.Color := frReadInteger(Stream);
  w := frReadWord(Stream);
{$IFNDEF Delphi2}
  Font.Charset := w;
{$ENDIF}
end;
{$HINTS ON}

procedure frWriteBoolean(Stream: TStream; Value: Boolean);
begin
  Stream.Write(Value, 1);
end;

procedure frWriteByte(Stream: TStream; Value: Byte);
begin
  Stream.Write(Value, 1);
end;

procedure frWriteWord(Stream: TStream; Value: Word);
begin
  Stream.Write(Value, 2);
end;

procedure frWriteInteger(Stream: TStream; Value: Integer);
begin
  Stream.Write(Value, 4);
end;

{$HINTS OFF}
procedure frWriteFont(Stream: TStream; Font: TFont);
var
  w: Word;
begin
  frWriteString(Stream, Font.Name);
  frWriteInteger(Stream, Font.Size);
  frWriteWord(Stream, frGetFontStyle(Font.Style));
  frWriteInteger(Stream, Font.Color);
  w := frCharset;
{$IFNDEF Delphi2}
  w := Font.Charset;
{$ENDIF}
  frWriteWord(Stream, w);
end;
{$HINTS ON}

type
  THackWinControl = class(TWinControl);

procedure frEnableControls(c: Array of TControl; e: Boolean);
const
  Clr1: Array[Boolean] of TColor = (clGrayText, clWindowText);
  Clr2: Array[Boolean] of TColor = (clBtnFace, clWindow);
var
  i: Integer;
begin
  for i := Low(c) to High(c) do
    if c[i] is TLabel then
      with c[i] as TLabel do
      begin
        Font.Color := Clr1[e];
        Enabled := e;
      end
    else if c[i] is TWinControl then
      with THackWinControl(c[i]) do
      begin
        Color := Clr2[e];
        Enabled := e;
      end
    else
      c[i].Enabled := e;
end;

function frControlAtPos(Win: TWinControl; p: TPoint): TControl;
var
  i: Integer;
  c: TControl;
  p1: TPoint;
begin
  Result := nil;
  with Win do
  begin
    for i := ControlCount - 1 downto 0 do
    begin
      c := Controls[i];
      if c.Visible and PtInRect(Rect(c.Left, c.Top, c.Left + c.Width, c.Top + c.Height), p) then
        if (c is TWinControl) and (csAcceptsControls in c.ControlStyle) and
           (TWinControl(c).ControlCount > 0) then
        begin
          p1 := p;
          Dec(p1.X, c.Left); Dec(p1.Y, c.Top);
          c := frControlAtPos(TWinControl(c), p1);
          if c <> nil then
          begin
            Result := c;
            Exit;
          end;
        end
        else
        begin
          Result := c;
          Exit;
        end;
    end;
  end;
end;

function frGetDataSet(ComplexName: String): TfrTDataSet;
begin
  Result := TfrTDataSet(frFindComponent(CurReport.Owner, ComplexName));
end;

function frGetFieldValue(F: TfrTField): Variant;
begin
{$IFDEF IBO}

  if F.IsNull then
  begin
    case F.SqlType of
      SQL_TEXT, SQL_TEXT_,
      SQL_BLOB, SQL_BLOB_,
      SQL_ARRAY, SQL_ARRAY_,
      SQL_VARYING, SQL_VARYING_: Result := '';
      SQL_DOUBLE, SQL_DOUBLE_,
      SQL_FLOAT, SQL_FLOAT_,
      SQL_LONG, SQL_LONG_,
      SQL_D_FLOAT, SQL_D_FLOAT_,
      SQL_QUAD, SQL_QUAD_,
      SQL_SHORT, SQL_SHORT_,
      SQL_INT64, SQL_INT64_,
// Dieter Tremel 18.04.2002 begin
      SQL_TYPE_TIME, SQL_TYPE_TIME_,
      SQL_TYPE_DATE, SQL_TYPE_DATE_,
// Dieter Tremel 18.04.2002 end
      SQL_DATE, SQL_DATE_: Result := 0;
    end;
  end else // not null

{$IFDEF Delphi4}
  if (F.SQLType = SQL_INT64) or (F.SQLType = SQL_INT64_) and (F.SQLScale = 0) then
     Result := F.DisplayText
  else
{$ENDIF}
  if (F.IsBoolean) and not ((F.SqlType=SQL_Text) or (F.SqlType=SQL_Text_)) then
      Result := F.AsBoolean
  else
    Result := F.AsVariant;

{$ELSE}  // not IBO
  if not F.DataSet.Active then
    F.DataSet.Open;
  if Assigned(F.OnGetText) then
    Result := F.DisplayText else
{$IFDEF Delphi4}
  if F.DataType in [ftLargeint] then
    Result := F.DisplayText
  else
{$ENDIF}
  Result := F.AsVariant;

  if Result = Null then
    if F.DataType = ftString then
      Result := ''
{$IFDEF Delphi4}
    else if F.DataType = ftWideString then
      Result := ''
{$ENDIF}
    else if F.DataType = ftBoolean then
      Result := False
    else
      Result := 0;
{$ENDIF}
end;


procedure frGetDataSetAndField(ComplexName: String; var DataSet: TfrTDataSet;
  var Field: String);
var
  i, j, n: Integer;
  f: TComponent;
  sl: TStringList;
  s: String;
  c: Char;
  cn: TControl;

  function FindField(ds: TfrTDataSet; FName: String): String;
  var
    sl: TStringList;
  begin
    Result := '';
    if ds <> nil then
    begin
      sl := TStringList.Create;
      frGetFieldNames(ds, sl);
      if sl.IndexOf(FName) <> -1 then
        Result := FName;
      sl.Free;
    end;
  end;

begin
  Field := '';
  f := CurReport.Owner;
  sl := TStringList.Create;

  n := 0; j := 1;
  for i := 1 to Length(ComplexName) do
  begin
    c := ComplexName[i];
    if c = '"' then
    begin
      sl.Add(Copy(ComplexName, i, 255));
      j := i;
      break;
    end
    else if c = '.' then
    begin
      sl.Add(Copy(ComplexName, j, i - j));
      j := i + 1;
      Inc(n);
    end;
  end;
  if j <> i then
    sl.Add(Copy(ComplexName, j, 255));

  case n of
    0: // field name only
      begin
        if DataSet <> nil then
        begin
          s := frRemoveQuotes(ComplexName);
          Field := FindField(DataSet, s);
        end;
      end;
    1: // DatasetName.FieldName
      begin
        if sl.Count > 1 then
        begin
          DataSet := TfrTDataSet(frFindComponent(f, sl[0]));
          s := frRemoveQuotes(sl[1]);
          Field := FindField(DataSet, s);
        end;
      end;
    2: // FormName.DatasetName.FieldName
      begin
        f := FindGlobalComponent(sl[0]);
        if f <> nil then
        begin
          DataSet := TfrTDataSet(f.FindComponent(sl[1]));
          s := frRemoveQuotes(sl[2]);
          Field := FindField(DataSet, s);
        end;
      end;
    3: // FormName.FrameName.DatasetName.FieldName - Delphi5
      begin
        f := FindGlobalComponent(sl[0]);
        if f <> nil then
        begin
          cn := TControl(f.FindComponent(sl[1]));
          DataSet := TfrTDataSet(cn.FindComponent(sl[2]));
          s := frRemoveQuotes(sl[3]);
          Field := FindField(DataSet, s);
        end;
      end;
  end;

  sl.Free;
end;

function frFindComponent(Owner: TComponent; Name: String): TComponent;
var
  n: Integer;
  s1, s2: String;
begin
  Result := nil;
  n := Pos('.', Name);
  try
    if n = 0 then
      Result := Owner.FindComponent(Name)
    else
    begin
      s1 := Copy(Name, 1, n - 1);        // module name
      s2 := Copy(Name, n + 1, 255);      // component name
      Owner := FindGlobalComponent(s1);
      if Owner <> nil then
      begin
        n := Pos('.', s2);
        if n <> 0 then        // frame name - Delphi5
        begin
          s1 := Copy(s2, 1, n - 1);
          s2 := Copy(s2, n + 1, 255);
          Owner := Owner.FindComponent(s1);
          if Owner <> nil then
            Result := Owner.FindComponent(s2);
        end
        else
          Result := Owner.FindComponent(s2);
      end;
    end;
  except
    on Exception do
      raise EClassNotFound.Create('Missing ' + Name);
  end;
end;

{$HINTS OFF}
procedure frGetComponents(Owner: TComponent; ClassRef: TClass;
  List: TStrings; Skip: TComponent);
var
  i, j: Integer;

  procedure EnumComponents(f: TComponent);
  var
    i: Integer;
    c: TComponent;
  begin
{$IFDEF Delphi5}
    if f is TForm then
      for i := 0 to TForm(f).ControlCount - 1 do
      begin
        c := TForm(f).Controls[i];
        if c is TFrame then
          EnumComponents(c);
      end;
{$ENDIF}
    for i := 0 to f.ComponentCount - 1 do
    begin
      c := f.Components[i];
      if (c <> Skip) and (c is ClassRef) then
        if f = Owner then
          List.AddObject(c.Name, c)
        else if ((f is TForm) or (f is TDataModule)) then
          List.AddObject(f.Name + '.' + c.Name, c)
        else
          List.AddObject(TControl(f).Parent.Name + '.' + f.Name + '.' + c.Name, c)
    end;
  end;

begin
  List.Clear;
  for i := 0 to Screen.FormCount - 1 do
    EnumComponents(Screen.Forms[i]);
  for i := 0 to Screen.DataModuleCount - 1 do
    EnumComponents(Screen.DataModules[i]);
{$IFDEF Delphi6}
  with Screen do
    for i := 0 to CustomFormCount - 1 do
      with CustomForms[i] do
      if (ClassName = 'TDataModuleForm')  then
        for j := 0 to ComponentCount - 1 do
        begin
          if (Components[j] is TDataModule) then
            EnumComponents(Components[j]);
        end;
{$ENDIF}
end;
{$HINTS ON}

function frGetWindowsVersion: String;
var
  Ver: TOsVersionInfo;
begin
  Ver.dwOSVersionInfoSize := SizeOf(Ver);
  GetVersionEx(Ver);
  with Ver do begin
    case dwPlatformId of
      VER_PLATFORM_WIN32s: Result := '32s';
      VER_PLATFORM_WIN32_WINDOWS:
        begin
          dwBuildNumber := dwBuildNumber and $0000FFFF;
          if (dwMajorVersion > 4) or ((dwMajorVersion = 4) and
            (dwMinorVersion >= 10)) then
            Result := '98' else
            Result := '95';
        end;
      VER_PLATFORM_WIN32_NT: Result := 'NT';
    end;
  end;
end;

function frStrToFloat(s: String): Double;
var
  i: Integer;
begin
  for i := 1 to Length(s) do
    if s[i] in [',', '.'] then
      s[i] := DecimalSeparator;
  Result := StrToFloat(Trim(s));
end;

function frRemoveQuotes(const s: String): String;
begin
  if (Length(s) > 2) and (s[1] = '"') and (s[Length(s)] = '"') then
    Result := Copy(s, 2, Length(s) - 2) else
    Result := s;
end;

procedure frSetCommaText(Text: String; sl: TStringList);
var
  i: Integer;

  function ExtractCommaName(s: string; var Pos: Integer): string;
  var
    i: Integer;
  begin
    i := Pos;
    while (i <= Length(s)) and (s[i] <> ';') do Inc(i);
    Result := Copy(s, Pos, i - Pos);
    if (i <= Length(s)) and (s[i] = ';') then Inc(i);
    Pos := i;
  end;

begin
  i := 1;
  sl.Clear;
  while i <= Length(Text) do
    sl.Add(ExtractCommaName(Text, i));
end;

function frLoadStr(ID: Integer): String;
begin
  Result := frLocale.LoadStr(ID);
end;

function StrToXML(const s: String): String;
const
  SpecChars = ['<', '>', '"', #10, #13];
var
  i: Integer;

  procedure ReplaceChars(var s: String; i: Integer);
  begin
    Insert('#' + IntToStr(Ord(s[i])) + ';', s, i + 1);
    s[i] := '&';
  end;

begin
  Result := s;
  for i := Length(s) downto 1 do
    if s[i] in SpecChars then
      ReplaceChars(Result, i);
end;

function frStreamToString(Stream: TStream): String;
var
  b: Byte;
begin
  Result := '';
  Stream.Position := 0;
  while Stream.Position < Stream.Size do
  begin
    Stream.Read(b, 1);
    Result := Result + IntToHex(b, 2);
  end;
end;

procedure SaveToFR3Stream(Report: TfrReport; Stream: TStream);
const
  fr01cm = 3.77953; // 96 / 25.4
  frKx = 96 / (93 / 1.015); // convert from 2.4 units to 3.0 units

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

  procedure WriteLn(const s: String);
  begin
    WriteStr(s + #13#10);
  end;

  function EncodePwd(const s: String): String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Length(s) do
      Result := Result + Chr(Ord(s[i]) - 10);
  end;

  procedure WriteReportProp;

    procedure WriteScript;
    var
      i, j: Integer;
      Page: TfrPage;
      v: TfrView;
      Script: TStringList;

      procedure AddScript(const vName: String; vScript: TStrings);
      var
        i: Integer;
      begin
        if vScript.Count <> 0 then
        begin
          Script.Add('procedure ' + vName + 'OnBeforePrint(Sender: TfrxComponent);');
          Script.Add('begin');
          Script.Add('  with ' + vName + ', Engine do');
          Script.Add('  begin');
          if vScript[0] <> 'begin' then
            Script.Add(vScript[0]);

          for i := 1 to vScript.Count - 2 do
            Script.Add(vScript[i]);

          if vScript[0] <> 'begin' then
          begin
            if vScript.Count <> 1 then
              Script.Add(vScript[vScript.Count - 1]);
            Script.Add('  end');
            Script.Add('end;');
          end
          else
          begin
            Script.Add('  end');
            Script.Add(vScript[vScript.Count - 1] + ';');
          end;
          Script.Add('');
        end;
      end;

    begin
      Script := TStringList.Create;
      for i := 0 to Report.Pages.Count - 1 do
      begin
        Page := Report.Pages[i];
        AddScript('Page' + IntToStr(i + 1), Page.Script);
        for j := 0 to Page.Objects.Count - 1 do
        begin
          v := Page.Objects[j];
          AddScript(v.Name, v.Script);
        end;
      end;

      Script.Add('begin');
      Script.Add('');
      Script.Add('end.');
      WriteStr(StrToXML(Script.Text) + '" ');
      Script.Free;
    end;

    procedure WriteVariables;
    var
      i, j: Integer;
      wr: TWriter;
      ms: TMemoryStream;
      v: TValueType;
      s, varName, varValue: String;
      ds: TfrTDataSet;
      fld: String;
      dsList: TStringList;
      dsFound: TfrDataSet;
    begin
      ms := TMemoryStream.Create;
      wr := TWriter.Create(ms, 4096);

      dsList := TStringList.Create;
      frGetComponents(Report.Owner, TfrDataset, dsList, nil);

      v := vaCollection;
      wr.WriteStr('Datasets');
      wr.Write(v, SizeOf(v));
      for i := 0 to dsList.Count - 1 do
      begin
        varName := TfrDataset(dsList.Objects[i]).Name;
        wr.WriteListBegin;
        wr.WriteStr('DataSet');
        v := vaNil;
        wr.Write(v, SizeOf(v));
        wr.WriteStr('DataSetName');
        wr.WriteString(varName);
        wr.WriteListEnd;
      end;
      wr.WriteListEnd;

      wr.WriteStr('Variables');
      wr.Write(v, SizeOf(v));
      for i := 0 to Report.Dictionary.Variables.Count - 1 do
      begin
        varName := Report.Dictionary.Variables.Name[i];
        varValue := Report.Dictionary.Variables.Value[i];

        ds := nil;
        fld := '';
        frGetDatasetAndField(varValue, ds, fld);
        if (ds <> nil) and (fld <> '') then
        begin
          dsFound := nil;
          for j := 0 to dsList.Count - 1 do
            if TObject(dsList.Objects[j]) is TfrDBDataSet then
              if TfrDBDataset(dsList.Objects[j]).GetDataSet = ds then
              begin
                dsFound := TfrDataset(dsList.Objects[j]);
                break;
              end;
          if dsFound <> nil then
          begin
            s := dsFound.Name;
            if Pos('_', s) = 1 then
              s := Copy(s, 2, 255);
            varValue := '<' + s + '."' + fld + '">';
          end;
        end;

        wr.WriteListBegin;
        wr.WriteStr('Name');
        wr.WriteString(varName);
        wr.WriteStr('Value');
        wr.WriteString(varValue);
        wr.WriteListEnd;
      end;

      wr.WriteListEnd;
      wr.Free;
      WriteStr('Propdata="' + frStreamToString(ms) + '"');
      ms.Free;
      dsList.Free;
    end;

  begin
    WriteStr('<TfrxReport ScriptLanguage="PascalScript" ScriptText.text="');
    WriteScript;
    WriteVariables;

    WriteStr(' ReportOptions.Name="' + StrToXML(Report.ReportName) +
      '" ReportOptions.Author="' + StrToXML(Report.ReportAutor) +
      '" ReportOptions.Description.text="' + StrToXML(Report.ReportComment) +
      '" ReportOptions.CreateDate="' + FloatToStr(Report.ReportCreateDate) +
      '" ReportOptions.LastChange="' + FloatToStr(Report.ReportLastChange) +
      '" ReportOptions.VersionMajor="' + StrToXML(Report.ReportVersionMajor) +
      '" ReportOptions.VersionMinor="' + StrToXML(Report.ReportVersionMinor) +
      '" ReportOptions.VersionRelease="' + StrToXML(Report.ReportVersionRelease) +
      '" ReportOptions.VersionBuild="' + StrToXML(Report.ReportVersionBuild) +
      '" ReportOptions.Password="' + StrToXML(EncodePwd(Report.ReportPassword)) + '"');
    WriteLn('>');
  end;

  procedure WritePages;
  var
    i, j, ofx, savex: Integer;
    Page: TfrPage;
    v: TfrView;

    procedure WritePageProp(Page: TfrPage; const PageName: String);
    var
      s: String;
    begin
      ofx := 0;
      if Page.PageType = ptReport then
      begin
        if Page.pgOr = poPortrait then
          s := 'poPortrait' else
          s := 'poLandscape';
        WriteStr('<TfrxReportPage Name="' + PageName + '" ');
        WriteStr('Orientation="' + s +
          '" PaperWidth="' + IntToStr(Round(Page.prnInfo.PgW / fr01cm * frKx)) +
          '" PaperHeight="' + IntToStr(Round(Page.prnInfo.PgH / fr01cm * frKx)) +
          '" PaperSize="' + IntToStr(Page.pgSize) + '" ');
        WriteStr('LeftMargin="' + IntToStr(Round(Page.LeftMargin / fr01cm * frKx)) +
          '" RightMargin="' + IntToStr(Round((Page.prnInfo.PgW - Page.RightMargin) / fr01cm * frKx)) +
          '" TopMargin="' + IntToStr(Round(Page.TopMargin / fr01cm * frKx)) +
          '" BottomMargin="' + IntToStr(Round((Page.prnInfo.PgH - Page.BottomMargin) / fr01cm * frKx)) +
          '" Columns="' + IntToStr(Page.ColCount) +
          '" ColumnWidth="' + IntToStr(Page.ColWidth) + '"');
        if Page.PrintToPrevPage then
          WriteStr(' PrintOnPreviousPage="True"');
        if Page.Script.Count > 0 then
          WriteStr(' OnBeforePrint="' + PageName + 'OnBeforePrint"');

        ofx := -Page.LeftMargin;
      end
      else
      begin
        WriteStr('<TfrxDialogPage Name="' + PageName + '" ');
        WriteStr('Height="' + IntToStr(Page.Height) +
          '" Left="' + IntToStr(Page.Left) +
          '" Top="' + IntToStr(Page.Top) +
          '" Width="' + IntToStr(Page.Width) +
          '" BorderStyle="' + IntToStr(Page.BorderStyle) +
          '" Caption="' + StrToXML(Page.Caption) +
          '" Color="' + IntToStr(Page.Color) +
          '" Position="' + IntToStr(Page.Position) + '"');
        if Page.Script.Count > 0 then
          WriteStr(' OnActivate="' + PageName + 'OnBeforePrint"');
      end;
      if Page.Objects.Count = 0 then
        WriteLn('/>') else
        WriteLn('>');
    end;

  begin
    for i := 0 to Report.Pages.Count - 1 do
    begin
      Page := Report.Pages[i];
      WritePageProp(Page, 'Page' + IntToStr(i + 1));

      for j := 0 to Page.Objects.Count - 1 do
      begin
        v := Page.Objects[j];
        savex := v.x;
        v.x := v.x + ofx;
        v.SaveToFR3Stream(Stream);
        v.x := savex;
        WriteLn('/>');
      end;

      if Page.Objects.Count <> 0 then
        if Page.PageType = ptReport then
          WriteLn('</TfrxReportPage>') else
          WriteLn('</TfrxDialogPage>');
    end;
  end;

begin
  WriteLn('<?xml version="1.0" encoding="utf-8"?>');
  WriteReportProp;
  WritePages;
  WriteLn('</TfrxReport>');
end;

function frFieldIsNull(FieldName: String): Boolean;
var
  DS : TfrTDataSet;
  F : TfrTfield;
  FName: string;
begin
    Result := True;
    if CurReport.UseDefaultDataSetName then
      DS := GetDefaultDataset else
      DS := nil;
    frGetDataSetAndField(FieldName, DS, FName);
    if DS <> nil then
    begin
      F := TfrTField(DS.FieldByName(FName));
      if f <> nil then
        Result := F.IsNull
    end
end;

{$IFNDEF Delphi6}
function Utf8Encode(const WS: WideString): String;
var
  L: Integer;
  Temp: String;

  function ToUtf8(Dest: PChar; MaxDestBytes: Cardinal; 
           Source: PWideChar; SourceChars: Cardinal): Cardinal;
  var
    i, count: Cardinal;
    c: Cardinal;
  begin
    Result := 0;
    if Source = nil then Exit;
    count := 0;
    i := 0;
    if Dest <> nil then
    begin
      while (i < SourceChars) and (count < MaxDestBytes) do
      begin
        c := Cardinal(Source[i]);
        Inc(i);
        if c <= $7F then
        begin
          Dest[count] := Char(c);
          Inc(count);
        end
        else if c > $7FF then
        begin
          if count + 3 > MaxDestBytes then
            break;
          Dest[count] := Char($E0 or (c shr 12));
          Dest[count+1] := Char($80 or ((c shr 6) and $3F));
          Dest[count+2] := Char($80 or (c and $3F));
          Inc(count,3);
        end
        else //  $7F < Source[i] <= $7FF
        begin
          if count + 2 > MaxDestBytes then
            break;
          Dest[count] := Char($C0 or (c shr 6));
          Dest[count+1] := Char($80 or (c and $3F));
          Inc(count,2);
        end;
      end;
      if count >= MaxDestBytes then count := MaxDestBytes-1;
      Dest[count] := #0;
    end
    else
    begin
      while i < SourceChars do
      begin
        c := Integer(Source[i]);
        Inc(i);
        if c > $7F then
        begin
          if c > $7FF then
            Inc(count);
          Inc(count);
        end;
        Inc(count);
      end;
    end;
    Result := count+1; 
  end;

begin
  Result := '';
  if WS = '' then Exit;
  SetLength(Temp, Length(WS) * 3);
  L := ToUtf8(PChar(Temp), Length(Temp)+1, PWideChar(WS), Length(WS));
  if L > 0 then
    SetLength(Temp, L-1)
  else
    Temp := '';
  Result := Temp;
end;
{$ENDIF}

function frFloatToStrF(Value: Extended; Format: TFloatFormat;
          Precision, Digits: Integer; Separator: char): string;
var
  i: integer;
begin
  Result := FloatToStrF(Value, Format, Precision, Digits);
  i := Pos('.', Result);
  if i = 0 then
    i := Pos(',', Result);
  if i > 0 then
    Result[i] := Separator;
end;

function HTMLRGBColor(Color: TColor): string;
var
  TheRgbValue : TColorRef;
begin
  TheRgbValue := ColorToRGB(Color);
  Result := '#' + Format('%.2x%.2x%.2x', [GetRValue(TheRGBValue), GetGValue(TheRGBValue), GetBValue(TheRGBValue)]);
end;

end.
