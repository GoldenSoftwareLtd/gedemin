
{++

  Copyright (c) 1996-00 by Golden Software of Belarus

  Module

    xappreg.pas

  Abstract

    Allows to save application information in the
    system registry.

  Author

    Andrei Kireev (10-May-96)

  Contact address

  Uses


  Revisions history

    1.00    14-May-96    andreik    Initial version.
    1.01    29-Jul-96    andreik    Minor changes;
                                    Several VCL components read/write
                                    procedures added.
    1.02    02-Aug-96    andreik    Minor changes.
    1.03    02-Sep-96    andreik    Table calendar read/write service added.
    1.04    12-Oct-96    andreik    Minor changes with saving Forms properties
                                    and DB calendar's date.
    1.05    05-Nov-96    andreik    Minor changes.
    1.06    12-Dec-96    andreik    Font saving routines added. xPrettyDesktop
                                    save/restore procedures added.
    1.07    19-Feb-97    andreik    TMainForm read/write routines added.
    1.08    25-Feb-97    andreik    TxCustomOutline read/write routines added.
    1.09    20-Mar-97    andreik    Minor change.
    1.10    04-Apr-97    andreik    Ini files support added.
    1.11    05-Apr-97    andreik    Command line switches support added.
    1.12    01-Aug-97    andreik    Combo box read/write procedures added.
    1.14    02-Aug-97    andreik    Date read/write methods added.
    1.15    12-Aug-97    andreik    Minor change.
    1.16    12-Aug-97    andreik    Switch /e added.
    1.17    04-Oct-97    andreik    DBGrid save/store procedures added.
    1.18    04-Feb-98    michael    TDataSet save/store procedures added.
                                    Обратите внимание, что эти процедуры не
                                    регистрируются, так как не всегда необходимо
                                    сохранение TDataSet свойств.
    1.19    04-Feb-98    michael    Так как компонент XTblCal требует много стека,
                                    что не хорошо для таких проектов, как склад, то
                                    введен символ DEPOT_PROJECT. Если он определен,
                                    то компонент xTblCal не подключается.

    1.20    14-Jul-98    andreik    32-bit version.

    1.21                 andreik    Switches /r and /i are not supported longer.
                                    Ini files are not supported longer.

    1.22                 dennis     Some bugs were corrected.
    1.23    27-09-98     andreik    Delete keys added.
    1.24    01-11-98     andreik    Minor bugs fixed.
    1.25    24-03-99     dennis     Read, write float methods added.
    1.26    16-06-99     andreik    RootKey changed to HKEY_LOCAL_MACHINE.
    1.27    26-06-99     andreik    KeyExists method added. Property CurrentPath added.
    1.28    27-06-99     andreik    ValueExists method added.
    1.29    10-09-00     andreik    Minor changes. Win31 code clean up.

--}

{.$DEFINE REGISTER_XTOOL_COMP}(* comment this if you don't want register *)
                              (* component state read/write functions    *)
                              (* for several xTool components            *)

{$DEFINE REGISTER_VCL_COMP}   (* comment this if you don't want register *)
                              (* component state read/write functions    *)
                              (* for several VCL components              *)

                              (* про использование DEPOT_PROJECT см. в   *)
                              (* history.                                *)

{.$DEFINE REGISTER_XTOOL_COMP_OLD}

{$DEFINE REGISTER_VCL32_COMP}

{.$DEFINE mTabSets}

unit xAppReg;

interface

uses
  Classes, Forms, Graphics, Registry, DB, Dialogs, Windows;

type
  TWriteCompStateProc = procedure(const Key: String; Comp: TComponent);
  TReadCompStateProc = procedure(const Key: String; Comp: TComponent);

type
  TxAppRegistry = class(TObject)
  private
    Reg: TRegistry;
    RootName: String;
    List: TList;
    
    function GetCurrentPath: String;

  public
    constructor Create(AnAppName: String = '';
      const AKey: String = 'Software\Golden Software';
      const ARootKey: HKEY = {HKEY_LOCAL_MACHINE}HKEY_CURRENT_USER);
    destructor Destroy; override;

    procedure DeleteKey(const Key: String; const WithSubKeys: Boolean = True);
    procedure EnumKeys(const Key: String; StringList: TStringList);

    function KeyExists(const Key: String): Boolean;
    function ValueExists(const Key, Value: String): Boolean;

    procedure RegisterReadWriteProc(ComponentClasses: array of TComponentClass;
      WriteCompStateProc: TWriteCompStateProc;
      ReadCompStateProc: TReadCompStateProc);

    procedure WriteComponent(const Key: String; Comp: TComponent);
    procedure ReadComponent(const Key: String; Comp: TComponent);

    procedure WriteInteger(const Key, Ident: String; const Value: LongInt);
    function ReadInteger(const Key, Ident: String; const Default: LongInt = 0): LongInt; overload;
    function ReadInteger(const Key, Ident: String; const Default, Dummy: LongInt;
      const Min: LongInt = Low(LongInt); const Max: LongInt = High(LongInt)): LongInt; overload;

    procedure WriteFloat(const Key, Ident: String; const Value: Double);
    function ReadFloat(const Key, Ident: String; const Default: Double = 0): Double;

    procedure WriteString(const Key, Ident: String; const Value: String);
    function ReadString(const Key, Ident: String; const Default: String): String;

    procedure WriteBoolean(const Key, Ident: String; const Value: Boolean);
    function ReadBoolean(const Key, Ident: String; const Default: Boolean): Boolean;

    procedure WriteColor(const Key, Ident: String; Color: TColor);
    function ReadColor(const Key, Ident: String; const Default: TColor): TColor;

    procedure WriteFont(const Key, Ident: String; const Font: TFont);
    procedure ReadFont(const Key, Ident: String; Font: TFont);

    procedure WriteDate(const Key, Ident: String; const Date: TDateTime);
    function ReadDate(const Key, Ident: String; const DefDate: TDateTime): TDateTime;

    procedure WriteDataSet(const Key: String; Table: TDataSet);
    procedure ReadDataSet(const Key: String; Table: TDataSet);

    property CurrentPath: String read GetCurrentPath;
  end;

// строит ключ для заданной компоненты
function BuildKey(Comp: TComponent): String;

var
  AppRegistry: TxAppRegistry;

implementation

uses
  WinProcs, SysUtils, ShellAPI

  {$IFDEF REGISTER_VCL_COMP}
    , ExtCtrls, TabNotBk, Tabs, DBGrids, StdCtrls, xTabset
  {$ENDIF}
  
  {$IFDEF REGISTER_XTOOL_COMP_OLD}
  , SplitBar, xPtyDesk
  {$ENDIF}

  {$IFDEF REGISTER_XTOOL_COMP}
    , MainForm, xDateRng, xTblCal
  {$ENDIF}

  {$IFDEF xCalend}
    , xCalend, xOutline
  {$ENDIF}

  {$IFDEF mTabSets}
    , mTabSetHor, mTabSetVer
  {$ENDIF}
  ;

{ Read/Write functions for several components ------------}

{ Auxiliary functions -------------------------------------}

function Ternary(B: Boolean; const S1, S2: String): String;
begin
  case B of
    True: Result := S1;
    False: Result := S2;
  end;
end;

function FontStyle2String(FontStyle: TFontStyles): String;
begin
  Result := '[';
  if fsBold in FontStyle then Result := Result + 'B';
  if fsItalic in FontStyle then Result := Result + 'I';
  if fsUnderline in FontStyle then Result := Result + 'U';
  if fsStrikeout in FontStyle then Result := Result + 'S';
  Result := Result + ']';
end;

function String2FontStyle(const S: String): TFontStyles;
var
  I: Integer;
begin
  Result := [];
  for I := 1 to Length(S) do
    case S[I] of
      'B': Result := Result + [fsBold];
      'I': Result := Result + [fsItalic];
      'U': Result := Result + [fsUnderline];
      'S': Result := Result + [fsStrikeout];
    end;
end;

{ returns class name without leading T }
function AdjustClassName(Comp: TComponent): String;
begin
  Result := Comp.ClassName;
  if (Length(Result) > 1) and (CompareText(Result[1], 'T') = 0) then
    Delete(Result, 1, 1);
end;

function BuildKey(Comp: TComponent): String;
begin
  Result := '';

  while Assigned(Comp) and (not (Comp is TApplication)) do
  begin
    if Comp.Name > '' then
      Result := Comp.Name + '\' + Result
    else if (Comp is TForm) and (Comp.Tag <> 0) then
      Result := Format('%s #%d\%s', [AdjustClassName(Comp), Comp.Tag, Result])
    else
      Result := AdjustClassName(Comp) + '\' + Result;
    Comp := Comp.Owner;
  end; { while }

  { strip ending backslash }
  Delete(Result, Length(Result), 1);
end;

{ data structure to store class reference, read and write
  procedures }

type
  PRec = ^TRec;
  TRec = record
    ComponentClass: TComponentClass;
    WriteCompStateProc: TWriteCompStateProc;
    ReadCompStateProc: TReadCompStateProc;
  end;

{ TxAppRegistry ------------------------------------------}

constructor TxAppRegistry.Create(AnAppName: String; const AKey: String;
  const ARootKey: HKEY);
var
  I: Integer;
begin
  inherited Create;

  Reg := TRegistry.Create;
  Reg.RootKey := ARootKey;

  if AnAppName = '' then
  begin
    AnAppName := ExtractFileName(Application.ExeName);
    if Pos(ExtractFileExt(AnAppName), AnAppName) <> 0 then
      Delete(AnAppName, Pos(ExtractFileExt(AnAppName), AnAppName), Length(AnAppName));
  end;

  RootName := IncludeTrailingBackslash(IncludeTrailingBackslash(AKey) + AnAppName);

  //!!!
  { delete root if switch /e used }
  for I := 1 to ParamCount do
  begin
    if CompareText(ParamStr(I), '/E') = 0 then
    begin
      Reg.DeleteKey(RootName);  // under NT subkeys must be deleted first !!!
      break;
    end;
  end;

  List := TList.Create;
end;

destructor TxAppRegistry.Destroy;
var
  I: Integer;
begin
  AppRegistry := nil;

  { Reg.Free; } { already released by application }

  for I := 0 to List.Count - 1 do
    if List[I] <> nil then
      FreeMem(List[I], SizeOf(TRec));
  List.Free;

  Reg.Free;

  inherited Destroy;
end;

procedure TxAppRegistry.EnumKeys(const Key: String; StringList: TStringList);
begin
  StringList.Clear;
  if Reg.OpenKey(RootName + Key, False) then
    try
      Reg.GetKeyNames(StringList);
    finally
      Reg.CloseKey;
    end;
end;

procedure TxAppRegistry.RegisterReadWriteProc(ComponentClasses: array of TComponentClass;
  WriteCompStateProc: TWriteCompStateProc; ReadCompStateProc: TReadCompStateProc);
var
  I: Integer;
  P: PRec;
begin
  for I := Low(ComponentClasses) to High(ComponentClasses) do
  begin
    GetMem(P, SizeOf(TRec));
    P^.ComponentClass := ComponentClasses[I];
    P^.WriteCompStateProc := WriteCompStateProc;
    P^.ReadCompStateProc := ReadCompStateProc;
    List.Add(P);
  end;
end;

procedure TxAppRegistry.WriteComponent(const Key: String; Comp: TComponent);
var
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
    if (List[I] <> nil) and (Comp is PRec(List[I])^.ComponentClass)
      and Assigned(PRec(List[I])^.WriteCompStateProc) then
    begin
      PRec(List[I])^.WriteCompStateProc(Key, Comp);
      {break;}
    end;
end;

procedure TxAppRegistry.ReadComponent(const Key: String; Comp: TComponent);
var
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
    if (List[I] <> nil) and (Comp is PRec(List[I])^.ComponentClass)
      and Assigned(PRec(List[I])^.ReadCompStateProc) then
    begin
      PRec(List[I])^.ReadCompStateProc(Key, Comp);
      {break;}
    end;
end;

procedure TxAppRegistry.WriteInteger(const Key, Ident: String; const Value: LongInt);
begin
  Reg.OpenKey(RootName + Key, True);
  try
    Reg.WriteInteger(Ident, Value);
  finally
    Reg.CloseKey;
  end;
end;

function TxAppRegistry.ReadInteger(const Key, Ident: String; const Default: LongInt = 0): LongInt;
begin
  Reg.OpenKey(RootName + Key, True);
  try
    if Reg.ValueExists(Ident) then
      Result := Reg.ReadInteger(Ident)
    else
      Result := Default;
  finally
    Reg.CloseKey;
  end;
end;

function TxAppRegistry.ReadInteger(const Key, Ident: String; const Default, Dummy: LongInt;
  const Min: LongInt = Low(LongInt); const Max: LongInt = High(LongInt)): LongInt;
begin
  Result := ReadInteger(Key, Ident, Default);
  if (Result < Min) or (Result > Max) then
    Result := Default;
end;

procedure TxAppRegistry.WriteFloat(const Key, Ident: String; const Value: Double);
begin
  Reg.OpenKey(RootName + Key, True);
  try
    Reg.WriteFloat(Ident, Value);
  finally
    Reg.CloseKey;
  end;
end;

function TxAppRegistry.ReadFloat(const Key, Ident: String; const Default: Double = 0): Double;
begin
  Reg.OpenKey(RootName + Key, True);
  try
    if Reg.ValueExists(Ident) then
      Result := Reg.ReadFloat(Ident)
    else
      Result := Default;
  finally
    Reg.CloseKey;
  end;
end;

procedure TxAppRegistry.WriteString(const Key, Ident: String; const Value: String);
begin
  Reg.OpenKey(RootName + Key, True);
  try
    Reg.WriteString(Ident, Value);
  finally
    Reg.CloseKey;
  end;
end;

function TxAppRegistry.ReadString(const Key, Ident: String; const Default: String): String;
begin
  Reg.OpenKey(RootName + Key, True);
  try
    if Reg.ValueExists(Ident) then
      Result := Reg.ReadString(Ident)
    else
      Result := Default;
  except
    Result := Default;
  end;
  Reg.CloseKey;
end;

procedure TxAppRegistry.WriteBoolean(const Key, Ident: String; const Value: Boolean);
begin
  Reg.OpenKey(RootName + Key, True);
  try
    Reg.WriteInteger(Ident, Integer(Value));
  finally
    Reg.CloseKey;
  end;
end;

function TxAppRegistry.ReadBoolean(const Key, Ident: String; const Default: Boolean): Boolean;
begin
  Reg.OpenKey(RootName + Key, True);
  try
    if Reg.ValueExists(Ident) then
      Result := Reg.ReadBool(Ident)
    else
      Result := Default;
  finally
    Reg.CloseKey;
  end;  
end;

procedure TxAppRegistry.WriteColor(const Key, Ident: String; Color: TColor);
begin
  Reg.OpenKey(RootName + Key, True);
  try
    Reg.WriteString(Ident, ColorToString(Color));
  finally
    Reg.CloseKey;
  end;
end;

function TxAppRegistry.ReadColor(const Key, Ident: String; const Default: TColor): TColor;
begin
  Reg.OpenKey(RootName + Key, True);
  try
    if Reg.ValueExists(Ident) then
      Result := StringToColor(Reg.ReadString(Ident))
    else
      Result := Default;
  finally
    Reg.CloseKey;
  end;  
end;

procedure TxAppRegistry.WriteFont(const Key, Ident: String; const Font: TFont);
begin
  Reg.OpenKey(RootName + Key, True);
  try
    Reg.WriteString(Ident + '\Name', Font.Name);
    Reg.WriteInteger(Ident + '\Size', Font.Size);
    Reg.WriteString(Ident + '\Style', FontStyle2String(Font.Style));
  finally
    Reg.CloseKey;
    WriteColor(Key, Ident + '\Color', Font.Color);
  end;
end;

procedure TxAppRegistry.ReadFont(const Key, Ident: String; Font: TFont);
begin
  Reg.OpenKey(RootName + Key, True);
  try
    if Reg.ValueExists(Ident + '\Name') then
      Font.Name := Reg.ReadString(Ident + '\Name');
    if Reg.ValueExists(Ident + '\Size') then
      Font.Size := Reg.ReadInteger(Ident + '\Size');
    if Reg.ValueExists(Ident + '\Style') then
      Font.Style := String2FontStyle(Reg.ReadString(Ident + '\Style'));
  finally
    Reg.CloseKey;
  end;

  Font.Color := ReadColor(Key, Ident + '\Color', Font.Color);
  Font.CharSet := RUSSIAN_CHARSET;
end;

procedure TxAppRegistry.WriteDate(const Key, Ident: String; const Date: TDateTime);
var
  Y, M, D: Word;
begin
  DecodeDate(Date, Y, M, D);
  Reg.OpenKey(RootName + Key, True);
  try
    Reg.WriteInteger(Ident + '\Year', Y);
    Reg.WriteInteger(Ident + '\Month', M);
    Reg.WriteInteger(Ident + '\Day', D);
  finally
    Reg.CloseKey;
  end;
end;

function TxAppRegistry.ReadDate(const Key, Ident: String; const DefDate: TDateTime): TDateTime;
var
  Y, M, D: Word;
begin
  DecodeDate(DefDate, Y, M, D);
  Reg.OpenKey(RootName + Key, True);
  try
    if Reg.ValueExists(Ident + '\Year') and Reg.ValueExists(Ident + '\Month') and Reg.ValueExists(Ident + '\Day') then
    begin
      Y := Reg.ReadInteger(Ident + '\Year');
      M := Reg.ReadInteger(Ident + '\Month');
      D := Reg.ReadInteger(Ident + '\Day');
    end;
  finally
    Reg.CloseKey;
    Result := EncodeDate(Y, M, D);
  end;
end;

procedure TxAppRegistry.WriteDataSet(const Key: String; Table: TDataSet);
var
  I: Integer;
  K, K2: String;
begin

  K := Ternary(Key > '', Key + '\' + Table.Name, BuildKey(Table));

  for I := 0 to Table.FieldCount - 1 do
    if Table.Fields[I].Visible then
    begin
      K2 := Table.Fields[I].FieldName;
      AppRegistry.WriteInteger(K, K2 + '.DisplayWidth', Table.Fields[I].DisplayWidth);
      AppRegistry.WriteInteger(K, K2 + '.Index', Table.Fields[I].Index);
    end;
end;

procedure TxAppRegistry.ReadDataSet(const Key: String; Table: TDataSet);
var
  I, J, DisplayWidth, Index: Integer;
  K, S: String;
  StringList: TStringList;
begin

  K := Ternary(Key > '', Key + '\' + Table.Name, BuildKey(Table));

  StringList := TStringList.Create;
  try
    EnumKeys(K, StringList);

    for I := 0 to StringList.Count - 1 do
    begin
      { delete property name }
      S := StringList[I];
      for J := Length(S) downto 1 do
        if S[J] = '.' then
          break;
      Delete(S, J, 255);
      StringList[I] := S;

      for J := 0 to Table.FieldCount - 1 do
        if CompareText(StringList[I], Table.Fields[J].FieldName) = 0 then
        begin
          DisplayWidth := ReadInteger(K, StringList[I] + '.DisplayWidth', 10);

          if (DisplayWidth <= 0) then
            DisplayWidth := 10;

          Table.Fields[J].DisplayWidth := DisplayWidth;

          Index := ReadInteger(K, StringList[I] + '.Index', 0);

          if Index <= 0 then
            Index := 0;

          Table.Fields[J].Index := Index;

          break;
        end;
    end; { first for }
  finally
    StringList.Free;
  end;
end;

{$IFDEF REGISTER_VCL32_COMP}

procedure WriteFormState(const Key: String; Comp: TComponent); far;
var
  S: String;
begin
  if (Comp as TForm).Position <> poScreenCenter then
  begin
    AppRegistry.WriteInteger(Ternary(Key > '', Key + '\FormData', BuildKey(Comp)),
      'Left', (Comp as TForm).Left);
    AppRegistry.WriteInteger(Ternary(Key > '', Key + '\FormData', BuildKey(Comp)),
      'Top', (Comp as TForm).Top);
  end;

  if (Comp as TForm).BorderStyle <> bsDialog then
  begin
    AppRegistry.WriteInteger(Ternary(Key > '', Key + '\FormData', BuildKey(Comp)),
      'Width', (Comp as TForm).Width);
    AppRegistry.WriteInteger(Ternary(Key > '', Key + '\FormData', BuildKey(Comp)),
      'Height', (Comp as TForm).Height);
  end;

  case (Comp as TForm).WindowState of
    wsMinimized: S := 'MINIMIZED';
    wsMaximized: S := 'MAXIMIZED';
  else
    S := 'NORMAL';
  end;

  AppRegistry.WriteString(Ternary(Key > '', Key + '\FormData', BuildKey(Comp)),
    'State', S);
end;

procedure ReadFormState(const Key: String; Comp: TComponent); far;
var
  S: String;
  L, T, W, H: Integer;
begin
  L := (Comp as TForm).Left;
  T := (Comp as TForm).Top;
  W := (Comp as TForm).Width;
  H := (Comp as TForm).Height;

  if (Comp as TForm).Position <> poScreenCenter then
  begin
    L := AppRegistry.ReadInteger(Ternary(Key > '',
      Key + '\FormData', BuildKey(Comp)), 'Left', L);
    T := AppRegistry.ReadInteger(Ternary(Key > '',
      Key + '\FormData', BuildKey(Comp)), 'Top', T);
  end;

  if (Comp as TForm).BorderStyle <> bsDialog then
  begin
    W := AppRegistry.ReadInteger(Ternary(Key > '',
      Key + '\FormData', BuildKey(Comp)), 'Width', W);
    H := AppRegistry.ReadInteger(Ternary(Key > '',
      Key + '\FormData', BuildKey(Comp)), 'Height', H);
  end;

  (Comp as TForm).SetBounds(L, T, W, H);

  S := AppRegistry.ReadString(Ternary(Key > '',
     Key + '\FormData', BuildKey(Comp)), 'State', '');
  if S = 'MINIMIZED' then
    (Comp as TForm).WindowState := wsMinimized
  else if S = 'MAXIMIZED' then
    (Comp as TForm).WindowState := wsMaximized
  else
    (Comp as TForm).WindowState := wsNormal;
end;

{$ENDIF}


{$IFDEF REGISTER_VCL_COMP}

procedure WriteTabbedNotebookState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'PageIndex', (Comp as TTabbedNotebook).PageIndex);
end;

procedure ReadTabbedNotebookState(const Key: String; Comp: TComponent); far;
var
  PageIndex: Integer;
begin
  PageIndex := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'PageIndex', (Comp as TTabbedNotebook).PageIndex);
  if (PageIndex >= 0) and (PageIndex < (Comp as TTabbedNotebook).Pages.Count) then
    (Comp as TTabbedNotebook).PageIndex := PageIndex;
end;

procedure WriteNotebookState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'PageIndex', (Comp as TNotebook).PageIndex);
end;

procedure ReadNotebookState(const Key: String; Comp: TComponent); far;
var
  PageIndex: Integer;
begin
  PageIndex := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'PageIndex', (Comp as TNotebook).PageIndex);
  if (PageIndex >= 0) and (PageIndex < (Comp as TNotebook).Pages.Count) then
    (Comp as TNotebook).PageIndex := PageIndex;
end;

procedure WriteTabSetState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'TabIndex', (Comp as TTabSet).TabIndex);
end;

procedure ReadTabSetState(const Key: String; Comp: TComponent); far;
var
  TabIndex: Integer;
begin
  TabIndex := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'TabIndex', (Comp as TTabSet).TabIndex);
  if (TabIndex >= 0) and (TabIndex < (Comp as TTabSet).Tabs.Count) then
    (Comp as TTabSet).TabIndex := TabIndex;
end;

procedure WriteExtTabSetState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'TabIndex', (Comp as TExtTabSet).TabIndex);
end;

procedure ReadExtTabSetState(const Key: String; Comp: TComponent); far;
var
  TabIndex: Integer;
begin
  TabIndex := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'TabIndex', (Comp as TExtTabSet).TabIndex);
  if (TabIndex >= 0) and (TabIndex < (Comp as TExtTabSet).Tabs.Count) then
    (Comp as TExtTabSet).TabIndex := TabIndex;
end;

procedure WriteDataSetState(const Key: String; Comp: TComponent); far;
var
  I: Integer;
  K, K2: String;
  T: TForm;
  F: Boolean;
begin
  try
    T := Comp.Owner as TForm;
  except
    exit;
  end;

  F := False;
  for I := 0 to T.ComponentCount - 1 do
  begin
    if (T.Components[I] is TDBGrid) and
      ((T.Components[I] as TDBGrid).DataSource <> nil) and
      ((T.Components[I] as TDBGrid).DataSource.DataSet = Comp) then
    begin
      F := True;
      break;
    end;
  end;

  if not F then
    exit;

  K := Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp));

  for I := 0 to (Comp as TDataSet).FieldCount - 1 do
    if (Comp as TDataSet).Fields[I].Visible then
    begin
      K2 := (Comp as TDataSet).Fields[I].FieldName;
      AppRegistry.WriteInteger(K, K2 + '.DisplayWidth', (Comp as TDataSet).Fields[I].DisplayWidth);
      AppRegistry.WriteInteger(K, K2 + '.Index', (Comp as TDataSet).Fields[I].Index);
    end;
end;

procedure ReadDataSetState(const Key: String; Comp: TComponent); far;
var
  I, J, DisplayWidth, Index: Integer;
  K, S: String;
  StringList: TStringList;
  T: TForm;
  F: Boolean;
begin
  try
    T := Comp.Owner as TForm;
  except
    exit;
  end;

  F := False;
  for I := 0 to T.ComponentCount - 1 do
  begin
    if (T.Components[I] is TDBGrid) and
      ((T.Components[I] as TDBGrid).DataSource <> nil) and
      ((T.Components[I] as TDBGrid).DataSource.DataSet = Comp) then
    begin
      F := True;
      break;
    end;
  end;

  if not F then
    exit;

  K := Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp));

  StringList := TStringList.Create;
  try
    AppRegistry.EnumKeys(K, StringList);

    for I := 0 to StringList.Count - 1 do
    begin
      { delete property name }
      S := StringList[I];
      for J := Length(S) downto 1 do
        if S[J] = '.' then
          break;
      Delete(S, J, 255);
      StringList[I] := S;

      for J := 0 to (Comp as TDataSet).FieldCount - 1 do
        if CompareText(StringList[I], (Comp as TDataSet).Fields[J].FieldName) = 0 then
        begin
          DisplayWidth := AppRegistry.ReadInteger(K, StringList[I] + '.DisplayWidth', 10);

          if (DisplayWidth <= 0) then
            DisplayWidth := 10;

          (Comp as TDataSet).Fields[J].DisplayWidth := DisplayWidth;

          Index := AppRegistry.ReadInteger(K, StringList[I] + '.Index', 0);

          if Index <= 0 then
            Index := 0;

          (Comp as TDataSet).Fields[J].Index := Index;

          break;
        end;
    end; { first for }
  finally
    StringList.Free;
  end;
end;

{
procedure WriteComboBoxState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'ItemIndex', (Comp as TComboBox).ItemIndex);
end;

procedure ReadComboBoxState(const Key: String; Comp: TComponent); far;
begin
  (Comp as TComboBox).ItemIndex := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'ItemIndex', (Comp as TComboBox).ItemIndex);
end;
}

procedure WriteDBGridState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteFont(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'Font', (Comp as TDBGrid).Font);
end;

procedure ReadDBGridState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.ReadFont(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'Font',
    (Comp as TDBGrid).Font);
end;

{$ENDIF}


{$IFDEF REGISTER_XTOOL_COMP_OLD}

procedure WriteSplitBarState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'Left', (Comp as TSplitBar).Left);
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'Top', (Comp as TSplitBar).Top);
end;

procedure ReadSplitBarState(const Key: String; Comp: TComponent); far;
begin
  TSplitBar(Comp).Left := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'Left', (Comp as TSplitBar).Left);
  TSplitBar(Comp).Top := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'Top', (Comp as TSplitBar).Top);
end;

procedure WritePrettyDesktopState(const Key: String; Comp: TComponent); far;
begin
  try
    AppRegistry.WriteColor(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
      'Color', (Comp as TxPrettyDesktop).Color);
    AppRegistry.WriteBoolean(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
      'ShowLogo', (Comp as TxPrettyDesktop).ShowImage);
    AppRegistry.WriteFont(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
      'Font', (Comp as TxPrettyDesktop).Font);
    AppRegistry.WriteString(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
      'WallPaper', (Comp as TxPrettyDesktop).WallPaperFile);
  except
    { do nothing }
  end;
end;

procedure ReadPrettyDesktopState(const Key: String; Comp: TComponent); far;
var
  C: TColor;
  B: Boolean;
begin
  try
    C := AppRegistry.ReadColor(Ternary(Key > '',
      Key + '\' + Comp.Name, BuildKey(Comp)), 'Color',
      (Comp as TxPrettyDesktop).Color);
    (Comp as TxPrettyDesktop).Color := C;

    B := AppRegistry.ReadBoolean(Ternary(Key > '',
      Key + '\' + Comp.Name, BuildKey(Comp)), 'ShowLogo',
      (Comp as TxPrettyDesktop).ShowImage);
    (Comp as TxPrettyDesktop).ShowImage := B;

    AppRegistry.ReadFont(Ternary(Key > '',
      Key + '\' + Comp.Name, BuildKey(Comp)), 'Font',
      (Comp as TxPrettyDesktop).Font);

    (Comp as TxPrettyDesktop).WallPaperFile :=
      AppRegistry.ReadString(Ternary(Key > '',
      Key + '\' + Comp.Name, BuildKey(Comp)), 'WallPaper', '');
  except
    { do nothing }
  end;
end;

{$ENDIF}


{$IFDEF xCalend}
        
procedure WriteCalendarState(const Key: String; Comp: TComponent); far;
begin
  if Comp is TxDBCalendarCombo then
    exit; { avoid DB components }

  if (Comp as TxCalendarCombo).Date = 0 then
    exit; {!!!}

  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'Day', (Comp as TxCalendarCombo).Day);
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'Month', (Comp as TxCalendarCombo).Month);
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'Year', (Comp as TxCalendarCombo).Year);
end;

procedure ReadCalendarState(const Key: String; Comp: TComponent); far;
var
  Year, Month, Day: Word;
begin
  if Comp is TxDBCalendarCombo then
    exit; { avoid DB components }

  Day := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'Day', (Comp as TxCalendarCombo).Day);
  Month := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'Month', (Comp as TxCalendarCombo).Month);
  Year := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'Year', (Comp as TxCalendarCombo).Year);

  try
    (Comp as TxCalendarCombo).Date := EncodeDate(Year, Month, Day);
  except
    on Exception do;
  end;
end;

procedure WriteCustomOutlineState(const Key: String; Comp: TComponent); far;
begin
  try
    AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
      'ItemIndex', (Comp as TxCustomOutline).ItemIndex);
  except
    { do nothing }
  end;
end;

procedure ReadCustomOutlineState(const Key: String; Comp: TComponent); far;
begin
  try
    (Comp as TxCustomOutline).ItemIndex :=
      AppRegistry.ReadInteger(Ternary(Key > '',
        Key + '\' + Comp.Name, BuildKey(Comp)), 'ItemIndex',
        (Comp as TxCustomOutline).ItemIndex);
  except
    on Exception do;
  end;
end;

{$ENDIF}


{$IFDEF REGISTER_XTOOL_COMP}

{$IFNDEF DEPOT_PROJECT}
procedure WriteTableCalendarState(const Key: String; Comp: TComponent); far;
begin
  try
    AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
      'Index', (Comp as TxTableCalendar).CalendarData.CalendarIndex);
  except
    { do nothing }
  end;
end;

procedure ReadTableCalendarState(const Key: String; Comp: TComponent); far;
var
  I: LongInt;
begin
  try
    I := AppRegistry.ReadInteger(Ternary(Key > '',
      Key + '\' + Comp.Name, BuildKey(Comp)), 'Index',
      (Comp as TxTableCalendar).CalendarData.CalendarIndex);

    (Comp as TxTableCalendar).CalendarData.CalendarIndex := I;
    (Comp as TxTableCalendar).CalendarData.Open; { need to update attached controls }
  except
    { do nothing }
  end;
end;
{$ENDIF}

procedure WriteMainFormState(const Key: String; Comp: TComponent); far;
var
  I: Integer;
begin
  try
    if CurrentPart <> nil then
      I := CurrentPart.PartTag
    else
      I := -1;

    AppRegistry.WriteInteger(Ternary(Key > '', Key + '\FormData', BuildKey(Comp)),
      'PartTag', I);
  except
    { do nothing }
  end;
end;

procedure ReadMainFormState(const Key: String; Comp: TComponent); far;
begin
  try
    (Comp as TMainForm).InitialPart := AppRegistry.ReadInteger(Ternary(Key > '',
      Key + '\FormData', BuildKey(Comp)), 'PartTag', -1);
  except
    { do nothing }
  end;
end;

{$IFNDEF DEPOT_PROJECT}
procedure WriteDateRangeState(const Key: String; Comp: TComponent); far;
begin
  try
    AppRegistry.WriteDate(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
      'StartDate', (Comp as TxDateRange).StartDate);
    AppRegistry.WriteDate(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
      'EndDate', (Comp as TxDateRange).EndDate);
  except
    { do nothing }
  end;
end;

procedure ReadDateRangeState(const Key: String; Comp: TComponent); far;
begin
  try
    (Comp as TxDateRange).StartDate :=
      AppRegistry.ReadDate(Ternary(Key > '',
        Key + '\' + Comp.Name, BuildKey(Comp)), 'StartDate',
        (Comp as TxDateRange).StartDate);
    (Comp as TxDateRange).EndDate :=
      AppRegistry.ReadDate(Ternary(Key > '',
        Key + '\' + Comp.Name, BuildKey(Comp)), 'EndDate',
        (Comp as TxDateRange).EndDate);
  except
    on Exception do;
  end;
end;

{$ENDIF}

{$ENDIF}


{$IFDEF mTabSets}

{
   WRITE_M_TAB_SET_HOR_STATE
}
procedure WritemTabSetHorState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'ActiveIndex', (Comp as TmTabSetHor).ActiveIndex);
end;

{
   READ_M_TAB_SET_HOR_STATE
}
procedure ReadmTabSetHorState(const Key: String; Comp: TComponent); far;
var
  ActiveIndex: Integer;
begin
  ActiveIndex := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'ActiveIndex', (Comp as TmTabSetHor).ActiveIndex);
    
  if (ActiveIndex >= 0) and (ActiveIndex < (Comp as TmTabSetHor).Tabs.Count) then
    (Comp as TmTabSetHor).ActiveIndex := ActiveIndex;
end;


{
   WRITE_M_TAB_SET_VER_STATE
}
procedure WritemTabSetVerState(const Key: String; Comp: TComponent); far;
begin
  AppRegistry.WriteInteger(Ternary(Key > '', Key + '\' + Comp.Name, BuildKey(Comp)),
    'ActiveIndex', (Comp as TmTabSetVer).ActiveIndex);
end;

{
   READ_M_TAB_SET_VER_STATE
}
procedure ReadmTabSetVerState(const Key: String; Comp: TComponent); far;
var
  ActiveIndex: Integer;
begin
  ActiveIndex := AppRegistry.ReadInteger(Ternary(Key > '',
    Key + '\' + Comp.Name, BuildKey(Comp)), 'ActiveIndex', (Comp as TmTabSetVer).ActiveIndex);
    
  if (ActiveIndex >= 0) and (ActiveIndex < (Comp as TmTabSetVer).Tabs.Count) then
    (Comp as TmTabSetVer).ActiveIndex := ActiveIndex;
end;

{$ENDIF}


{ Initialization -----------------------------------------}

procedure TxAppRegistry.DeleteKey(const Key: String;
  const WithSubKeys: Boolean = True);
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    if WithSubKeys then
    begin
      EnumKeys(Key, SL);
      for I := 0 to SL.Count - 1 do
        DeleteKey(Key + '\' + SL[I]);
    end;

    Reg.DeleteKey(RootName + Key);
  finally
    SL.Free;
  end;
end;

function TxAppRegistry.KeyExists(const Key: String): Boolean;
begin
  Result := Reg.KeyExists(RootName + Key);
end;

function TxAppRegistry.GetCurrentPath: String;
begin
  Result := Reg.CurrentPath;
end;

function TxAppRegistry.ValueExists(const Key, Value: String): Boolean;
begin
  if KeyExists(Key) then
  begin
    Reg.OpenKey(RootName + Key, False);
    Result := Reg.ValueExists(Value);
    Reg.CloseKey;
  end else
    Result := False;
end;

initialization
  // обязательно должно быть присваивание nil
  AppRegistry := nil;

  AppRegistry := TxAppRegistry.Create;

  
  {$IFDEF REGISTER_XTOOL_COMP_OLD}
  AppRegistry.RegisterReadWriteProc([TSplitBar], WriteSplitBarState,
    ReadSplitBarState);
  AppRegistry.RegisterReadWriteProc([TxPrettyDesktop], WritePrettyDesktopState,
    ReadPrettyDesktopState);
  {$ENDIF}

  {$IFDEF xCalend}
  AppRegistry.RegisterReadWriteProc([TxCalendarCombo], WriteCalendarState,
    ReadCalendarState);
  AppRegistry.RegisterReadWriteProc([TxCustomOutline], WriteCustomOutlineState,
    ReadCustomOutlineState);
  {$ENDIF}

  {$IFDEF REGISTER_XTOOL_COMP}

  {$IFNDEF DEPOT_PROJECT}
  AppRegistry.RegisterReadWriteProc([TxTableCalendar], WriteTableCalendarState,
    ReadTableCalendarState);
  AppRegistry.RegisterReadWriteProc([TxDateRange], WriteDateRangeState,
    ReadDateRangeState);
  {$ENDIF}
  
  AppRegistry.RegisterReadWriteProc([TMainForm], WriteMainFormState,
    ReadMainFormState);
  {$ENDIF}

  
  {$IFDEF REGISTER_VCL32_COMP}
  AppRegistry.RegisterReadWriteProc([TForm], WriteFormState,
    ReadFormState);
  {$ENDIF}

  
  {$IFDEF REGISTER_VCL_COMP}
  AppRegistry.RegisterReadWriteProc([TTabbedNotebook],
    WriteTabbedNotebookState, ReadTabbedNotebookState);
  AppRegistry.RegisterReadWriteProc([TNotebook],
    WriteNotebookState, ReadNotebookState);
  AppRegistry.RegisterReadWriteProc([TTabSet],
    WriteTabSetState, ReadTabSetState);
    
  AppRegistry.RegisterReadWriteProc([TExtTabSet],
    WriteExtTabSetState, ReadExtTabSetState);

  AppRegistry.RegisterReadWriteProc([TDataSet],
    WriteDataSetState, ReadDataSetState);
  (*
  AppRegistry.RegisterReadWriteProc([TComboBox],
    WriteComboBoxState, ReadComboBoxState);
  *)
  AppRegistry.RegisterReadWriteProc([TDBGrid],
    WriteDBGridState, ReadDBGridState);    
  {$ENDIF}


  {$IFDEF mTabSets}
  AppRegistry.RegisterReadWriteProc([TmTabSetHor],
    WritemTabSetHorState, ReadmTabSetHorState);    
  AppRegistry.RegisterReadWriteProc([TmTabSetVer],
    WritemTabSetVerState, ReadmTabSetVerState);    
  {$ENDIF}
  
finalization

  if Assigned(AppRegistry) then
    AppRegistry.Free;

end.

