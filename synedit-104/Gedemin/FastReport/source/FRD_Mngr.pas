
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{              Main unit                   }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_Mngr;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms, Dialogs, StdCtrls,
  DB, FR_Class, FR_Intrp, FR_DSet, FR_DBSet, FRD_Wrap, FR_DBRel
{$IFDEF IBX}, IBTable, IBQuery, IBDatabase{$ENDIF}
{$IFDEF ADO}, ADODB{$ENDIF}
{$IFDEF BDE}, DBTables{$ENDIF};

type
  TQueryParamsEvent = procedure(Report: TfrReport; Query: TfrQuery) of object;

  TfrDataStorage = class(TComponent)
  private
    FOnQueryParams: TQueryParamsEvent;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnQueryParams: TQueryParamsEvent read FOnQueryParams write FOnQueryParams;
  end;

  TfrReportDataManager = class(TfrDataManager)
  private
    FEnabled: Boolean;
  public
    procedure Clear; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure BeforePreparing; override;
    procedure AfterPreparing; override;
    procedure PrepareDataSet(ds: TfrTDataSet); override;
    function ShowParamsDialog: Boolean; override;
    procedure AfterParamsDialog; override;
    procedure OnMngrClick(Sender: TObject);
    procedure OnParmClick(Sender: TObject);
  end;

  PfrControlInfo = ^TfrControlInfo;
  TfrControlInfo = record
    Bounds: TRect;
    Caption: String[255];
    FontName: String[32];
    FontSize: Integer;
    FontStyle: Word;
    FontCharset: Word;
    FontColor: TColor;
  end;

  PfrParamInfo = ^TfrParamInfo;
  TfrParamInfo = record
    Actual: Boolean;
    QueryRef: TfrQuery;
    QueryName, ParamName: String[255];
    LabelControl, EditControl: TfrControlInfo;
    Typ: Byte; // 0 - edit; 1 - lookup; 2 - combo
    LookupActive: Boolean;
    LookupDS: String[255];
    LookupKF, LookupLF: String[32];
    ComboStrings: TStrings;
  end;

function GetDataSource(d: TDataSet): TDataSource;
function GetFRDataSet(d: TDataSet): TfrDBDataSet;
function GetDataPath(d: TDataSet): String;
function FindFieldDef(DataSet: TDataSet; FName: String): TFieldDef;
function GetDataSetName(Owner: TComponent; d: TDataSource): String;
procedure GetDatabaseList(List: TStrings);


var
  frDataModule: TDataModule;
  frParamList: TList;


const
  FieldNum = 10;
  ParamTypes: Array[0..10] of TFieldType =
    (ftBCD, ftBoolean, ftCurrency, ftDate, ftDateTime, ftInteger,
     ftFloat, ftSmallint, ftString, ftTime, ftWord);

  FieldClasses: array[0..FieldNum - 1] of TFieldClass = (
    TStringField, TSmallintField, TIntegerField, TWordField,
    TBooleanField, TFloatField, TCurrencyField, TDateField,
    TTimeField, TBlobField);
  ptEdit = 0;
  ptCombo = 1;
  ptLookup = 2;

implementation

uses FRD_List, FRD_Form, FR_Const, FR_Utils;

{$R *.RES}

var
  Bmp1, Bmp2: TBitmap;
  frDataStorage: TfrDataStorage;

{----------------------------------------------------------------------------}
function GetDataSource(d: TDataSet): TDataSource;
var
  i: Integer;

  function EnumComponents(f: TComponent): TDataSource;
  var
    i: Integer;
    c: TComponent;
  begin
    Result := nil;
    for i := 0 to f.ComponentCount - 1 do
    begin
      c := f.Components[i];
      if (c is TDataSource) and ((c as TDataSource).DataSet = d) then
      begin
        Result := c as TDataSource;
        break;
      end;
    end;
  end;

begin
  Result := nil;
  for i := 0 to Screen.FormCount - 1 do
  begin
    Result := EnumComponents(Screen.Forms[i]);
    if Result <> nil then Exit;
  end;
  for i := 0 to Screen.DataModuleCount - 1 do
  begin
    Result := EnumComponents(Screen.DataModules[i]);
    if Result <> nil then Exit;
  end;
end;

function GetFRDataSet(d: TDataSet): TfrDBDataSet;
var
  i: Integer;
  ds: TDataSource;
begin
  Result := nil;
  ds := GetDataSource(d);
  if ds <> nil then
    with frDataModule do
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TfrDBDataSet then
        if TDataSource((Components[i] as TfrDBDataSet).DataSource) = ds then
        begin
          Result := Components[i] as TfrDBDataSet;
          break;
        end;
end;

function GetDataPath(d: TDataSet): String;
var
  s: String;
begin
  s := '';
  if d <> nil then
    if d is TfrTable then
    begin
      s := TfrTable(d).frDatabaseName;
      if s <> '' then
        if (Pos('\', s) = 0) and (Pos(':', s) = 0) then
          s := ':' + s + ':' else
          if s[Length(s)] <> '\' then s := s + '\';
      s := s + TfrTable(d).TableName;
    end
    else if d is TfrQuery then
      s := TfrQuery(d).frDatabaseName;
  Result := s;
end;

function FindFieldDef(DataSet: TDataSet; FName: String): TFieldDef;
var
  i: Integer;
begin
  Result := nil;
  with DataSet do
  for i := 0 to FieldDefs.Count - 1 do
    if AnsiCompareText(FieldDefs.Items[i].Name, FName) = 0 then
    begin
      Result := FieldDefs.Items[i];
      break;
    end;
end;

function GetDataSetName(Owner: TComponent; d: TDataSource): String;
begin
  Result := '';
  if (d <> nil) and (d.DataSet <> nil) then
  begin
    Result := d.Dataset.Name;
    if d.Dataset.Owner <> Owner then
      Result := d.Dataset.Owner.Name + '.' + Result;
  end;
end;

procedure ClearParamList;
begin
  while frParamList.Count > 0 do
  begin
    PfrParamInfo(frParamList[0])^.ComboStrings.Free;
    FreeMem(PfrParamInfo(frParamList[0]), SizeOf(TfrParamInfo));
    frParamList.Delete(0);
  end;
end;

procedure GetDatabaseList(List: TStrings);
begin
{$IFDEF BDE}
  Session.GetAliasNames(List);
{$ENDIF}
{$IFDEF IBX}
   frGetComponents(frDataModule, TIBDatabase, List, nil);
{$ENDIF}
{$IFDEF ADO}
   frGetComponents(frDataModule, TADOConnection, List, nil);
{$ENDIF}
end;


{-----------------------------------------------------------------------------}
constructor TfrDataStorage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frDataStorage := Self;
end;

{-----------------------------------------------------------------------------}
procedure TfrReportDataManager.Clear; 
begin
  with frDataModule do
    while ComponentCount > 0 do
      Components[0].Free;
  ClearParamList;
end;

procedure TfrReportDataManager.LoadFromStream(Stream: TStream);
var
  i: Integer;
  b: Byte;
  n: Word;
  sl: TStringList;
  Version23: Boolean;

  function ReadString: String;
  begin
    frReadMemo(Stream, sl);
    if sl.Count > 0 then
      Result := sl[0] else
      Result := '';
  end;

  procedure CreateDataSources(ds: TDataset);
  var
    d: TDataSource;
    d1: TfrDBDataSet;
  begin
    d := TDataSource.Create(frDataModule);
    d.DataSet := ds;
    d.Name := 'S' + ds.Name;

    d1 := TfrDBDataSet.Create(frDataModule);
    d1.DataSource := d;
    d1.Name := '_' + ds.Name;
    d1.CloseDataSource := True;
  end;

  procedure ReadFields(ds: TDataSet);
  var
    i: Integer;
    b: Byte;
    w, n: Word;
    s: String;
    Field: TField;
    ds1: TDataset;
  begin
    Stream.Read(n, 2);
    for i := 0 to n - 1 do
    begin
      Stream.Read(b, 1);
      s := ReadString;
      if b = 0 then
        FindFieldDef(ds, s).CreateField(ds)
      else
      begin
        Stream.Read(b, 1);
        Field := FieldClasses[b].Create(ds);
        with Field do
        begin
          FieldName := s;
          Dataset := ds;
          Stream.Read(w, 2);
          Size := w;
          Lookup := True;
          KeyFields := ReadString;
          s := ReadString;
          ds1 := frFindComponent(frDataModule, s) as TDataset;
          LookupDataset := ds1;
          LookupKeyFields := ReadString;
          LookupResultField := ReadString;
        end;
      end;
    end;
  end;

  procedure ReadParams(q: TfrQuery);
  var
    i: Integer;
    w, n: Word;
    s: String;
  begin
    Stream.Read(n, 2);
    for i := 0 to n - 1 do
    with q.frParams do
    begin
      Stream.Read(w, 2);
      ParamType[i] := ParamTypes[w];
      Stream.Read(w, 2);
      case w of
        0, $100: ParamKind[i] := pkAssignFromMaster;
        1:       ParamKind[i] := pkValue;
        $101:    ParamKind[i] := pkAsk;
      end;
      s := ReadString;
      if w = 1 then
        ParamText[i] := s;
    end;
  end;

  procedure ReadDataset1;
  var
    t: TfrTable;
    q: TfrQuery;
  begin
    Stream.Read(b, 1);
    if b = 0 then
    begin
      t := TfrTable.Create(frDataModule);
      t.Name := ReadString;
      t.frDatabaseName := ReadString;
      t.TableName := ReadString;
      t.IndexName := ReadString;
      t.Filter := ReadString;
      t.Filtered := t.Filter <> '';
      t.FieldDefs.Update;
      CreateDataSources(t);
    end
    else
    begin
      q := TfrQuery.Create(frDataModule);
      q.Name := ReadString;
      q.frDatabaseName := ReadString;
      frReadMemo(Stream, q.SQL);
      CreateDataSources(q);
    end;
  end;

  procedure ReadDataset2;
  var
    t: TfrTable;
    q: TfrQuery;
    ds: TDataset;
    s: String;
  begin
    Stream.Read(b, 1);
    s := ReadString;
    ds := frDataModule.FindComponent(s) as TDataset;
    if b = 0 then
    begin
      t := ds as TfrTable;
      s := ReadString;
      ds := frFindComponent(frDataModule, s) as TDataset;
      t.MasterSource := GetDataSource(ds);
      t.MasterFields := ReadString;
      ReadFields(t);
    end
    else
    begin
      q := ds as TfrQuery;
      s := ReadString;
      ds := frFindComponent(frDataModule, s) as TDataset;
      q.DataSource := GetDataSource(ds);
      ReadParams(q);
      q.FieldDefs.Update;
      ReadFields(q);
    end;
  end;

  procedure ReadDialogControls;
  var
    i: Integer;
    w: Word;
    p: PfrParamInfo;
    procedure ReadControlInfo(p: PfrControlInfo);
    begin
      with p^ do
      begin
        Stream.Read(Bounds, SizeOf(Bounds));
        Caption := ReadString;
        FontName := ReadString;
        Stream.Read(FontSize, 4);
        Stream.Read(FontStyle, 2);
        Stream.Read(FontCharset, 2);
        Stream.Read(FontColor, 4);
      end;
    end;
  begin
    Stream.Read(w, 2);
    Stream.Read(ParamFormWidth, 4);
    Stream.Read(ParamFormHeight, 4);
    for i := 0 to w - 1 do
    begin
      GetMem(p, SizeOf(TfrParamInfo));
      FillChar(p^, SizeOf(TfrParamInfo), #0);
      p^.ComboStrings := TStringList.Create;
      p^.QueryName := ReadString;
      p^.QueryRef := frFindComponent(nil, p^.QueryName) as TfrQuery;
      p^.ParamName := ReadString;
      ReadControlInfo(@p^.LabelControl);
      ReadControlInfo(@p^.EditControl);
      Stream.Read(p^.Typ, 1);
      if p.Typ = ptLookup then
      begin
        p^.LookupDS := ReadString;
        p^.LookupKF := ReadString;
        p^.LookupLF := ReadString;
      end
      else if p^.Typ = ptCombo then
        frReadMemo(Stream, p^.ComboStrings);
      frParamList.Add(p);
    end;
  end;

  procedure ReadSpecialParams;
  var
    i: Integer;
    w: Word;
    s: String;
  begin
    frSpecialParams.Clear;
    Stream.Read(w, 2);
    for i := 0 to w - 1 do
    begin
      s := ReadString;
      frSpecialParams[Copy(s, 1, Pos('=', s) - 1)] := Copy(s, Pos('=', s) + 1, 255);
    end;
  end;

  procedure ReadDatabases;
  var
    b: Byte;
    d: TfrDatabase;
  begin
    d := TfrDatabase.Create(frDataModule);
    d.Name := ReadString;
    d.frDriver := ReadString;
    Stream.Read(b, 1);
    d.LoginPrompt := Boolean(b);
    frReadMemo(Stream, sl);
    if d.Params <> nil then
      d.Params.Assign(sl);
    d.frDatabaseName := ReadString;
    d.Connected := True;
  end;

begin
  sl := TStringList.Create;
  Clear;

  Version23 := False;
  Stream.Read(n, 2);
  if n < 255 then
    Version23 := True;

  if not Version23 then
  begin
    Stream.Read(n, 2);
    for i := 0 to n - 1 do
      ReadDatabases;
    Stream.Read(n, 2);
  end;

  for i := 0 to n - 1 do
    ReadDataset1;
  for i := 0 to n - 1 do
    ReadDataset2;
  if n > 0 then
  begin
    ReadDialogControls;
    ReadSpecialParams;
  end;
  sl.Free;
end;

procedure TfrReportDataManager.SaveToStream(Stream: TStream);
var
  i: Integer;
  b: Byte;
  w: Word;
  sl: TStringList;

  procedure WriteString(s: String);
  begin
    sl.Text := s;
    frWriteMemo(Stream, sl);
  end;

  procedure WriteFields(ds: TDataSet);
  var
    i: Integer;
    b: Byte;
    w: Word;
    s: String;
  begin
    w := ds.FieldCount;
    Stream.Write(w, 2);
    for i := 0 to ds.FieldCount - 1 do
    with ds.Fields[i] do
    begin
      if Lookup then
      begin
        b := 1;
        Stream.Write(b, 1);
        WriteString(FieldName);
        for b := 0 to FieldNum - 1 do
          if ClassName = FieldClasses[b].ClassName then
            break;
        Stream.Write(b, 1);
        w := Size;
        Stream.Write(w, 2);
        WriteString(KeyFields);
        if LookupDataset <> nil then
        begin
          s := LookupDataset.Name;
          if LookupDataset.Owner <> frDataModule then
            s := LookupDataset.Owner.Name + '.' + s;
        end
        else
          s := '';
        WriteString(s);
        WriteString(LookupKeyFields);
        WriteString(LookupResultField);
      end
      else
      begin
        b := 0;
        Stream.Write(b, 1);
        WriteString(FieldName);
      end;
    end;
  end;

  procedure WriteParams(q: TfrQuery);
  var
    i: Integer;
    w: Word;
  begin
    w := q.frParams.Count;
    Stream.Write(w, 2);
    for i := 0 to q.frParams.Count - 1 do
    with q.frParams do
    begin
      for w := 0 to 10 do
        if ParamType[i] = ParamTypes[w] then
          break;
      Stream.Write(w, 2);
      case ParamKind[i] of
        pkAssignFromMaster: w := 0;
        pkValue:            w := 1;
        pkAsk, pkVariable:  w := $101;
      end;
      Stream.Write(w, 2);
      WriteString(ParamText[i]);
    end;
  end;

  procedure WriteDataset1(ds: TDataSet);
  var
    t: TfrTable;
    q: TfrQuery;
  begin
    if ds is TfrTable then
    begin
      t := ds as TfrTable;
      b := 0;
      Stream.Write(b, 1);
      WriteString(t.Name);
      WriteString(t.frDatabaseName);
      WriteString(t.TableName);
      WriteString(t.IndexName);
      WriteString(t.Filter);
    end
    else if ds is TfrQuery then
    begin
      q := ds as TfrQuery;
      b := 1;
      Stream.Write(b, 1);
      WriteString(q.Name);
      WriteString(q.frDatabaseName);
      frWriteMemo(Stream, q.SQL);
    end;
  end;

  procedure WriteDataset2(ds: TDataSet);
  var
    t: TfrTable;
    q: TfrQuery;
    s: String;
  begin
    if ds is TfrTable then
    begin
      t := ds as TfrTable;
      b := 0;
      Stream.Write(b, 1);
      WriteString(t.Name);
      if (t.MasterSource <> nil) and (t.MasterSource.DataSet <> nil) then
        s := t.MasterSource.DataSet.Owner.Name + '.' + t.MasterSource.DataSet.Name else
        s := '';
      WriteString(s);
      WriteString(t.MasterFields);
      WriteFields(t);
    end
    else
    begin
      q := ds as TfrQuery;
      b := 1;
      Stream.Write(b, 1);
      WriteString(q.Name);
      if (q.DataSource <> nil) and (q.DataSource.DataSet <> nil) then
        s := q.DataSource.DataSet.Owner.Name + '.' + q.DataSource.DataSet.Name else
        s := '';
      WriteString(s);
      WriteParams(q);
      WriteFields(q);
    end;
  end;

  procedure WriteDialogControls;
  var
    i: Integer;
    w: Word;
    p: PfrParamInfo;
    procedure WriteControlInfo(p: PfrControlInfo);
    begin
      with p^ do
      begin
        Stream.Write(Bounds, SizeOf(Bounds));
        WriteString(Caption);
        WriteString(FontName);
        Stream.Write(FontSize, 4);
        Stream.Write(FontStyle, 2);
        Stream.Write(FontCharset, 2);
        Stream.Write(FontColor, 4);
      end;
    end;
  begin
    w := frParamList.Count;
    Stream.Write(w, 2);
    Stream.Write(ParamFormWidth, 4);
    Stream.Write(ParamFormHeight, 4);
    for i := 0 to frParamList.Count - 1 do
    begin
      p := frParamList[i];
      WriteString(p^.QueryRef.Owner.Name + '.' + p^.QueryRef.Name);
      WriteString(p^.ParamName);
      WriteControlInfo(@p^.LabelControl);
      WriteControlInfo(@p^.EditControl);
      Stream.Write(p^.Typ, 1);
      if p.Typ = ptLookup then
      begin
        WriteString(p^.LookupDS);
        WriteString(p^.LookupKF);
        WriteString(p^.LookupLF);
      end
      else if p^.Typ = ptCombo then
        frWriteMemo(Stream, p^.ComboStrings);
    end;
  end;

  procedure WriteSpecialParams;
  var
    i: Integer;
    w: Word;
  begin
    w := frSpecialParams.Count;
    Stream.Write(w, 2);
    for i := 0 to frSpecialParams.Count - 1 do
      WriteString(frSpecialParams.Name[i] + '=' + frSpecialParams.Value[i]);
  end;

  procedure WriteDatabase(d: TfrDatabase);
  var
    b: Byte;
  begin
    WriteString(d.Name);
    WriteString(d.frDriver);
    b := Byte(d.LoginPrompt);
    Stream.Write(b, 1);
    if d.Params <> nil then
      sl.Assign(d.Params);
    frWriteMemo(Stream, sl);
    WriteString(d.frDatabaseName);
  end;

begin
  sl := TStringList.Create;
  w := $01FF;                 // new version signature
  Stream.Write(w, 2);
  w := 0;
  with frDataModule do
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TfrDatabase then
      Inc(w);
  Stream.Write(w, 2);

  with frDataModule do
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TfrDatabase then
        WriteDatabase(Components[i] as TfrDatabase);

  w := 0;
  with frDataModule do
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TDataSet then
      Inc(w);
  Stream.Write(w, 2);

  with frDataModule do
  begin
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TDataSet then
        WriteDataset1(Components[i] as TDataSet);
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TDataSet then
        WriteDataset2(Components[i] as TDataSet);
  end;

  if w > 0 then
  begin
    CurReport.FillQueryParams;
    AfterPreparing;
    WriteDialogControls;
    WriteSpecialParams;
  end;
  sl.Free;
end;

procedure TfrReportDataManager.BeforePreparing;
var
  i: Integer;
begin
  FEnabled := True;
  for i := 0 to frParamList.Count - 1 do
    PfrParamInfo(frParamList[i])^.Actual := False;
end;

procedure TfrReportDataManager.AfterPreparing;
var
  i, j: Integer;
  p: PfrParamInfo;
begin
  FEnabled := False;
  i := 0;
  while i < frParamList.Count do
  begin
    p := frParamList[i];
    if not p^.Actual then
    begin
      p^.ComboStrings.Free;
      FreeMem(p, SizeOf(TfrParamInfo));
      frParamList.Delete(i);
    end
    else
    begin
      j := p^.QueryRef.frParams.ParamIndex(p^.ParamName);
      p^.QueryRef.frParams.ParamKind[j] := pkAsk;
      Inc(i);
    end;
  end;
end;

procedure TfrReportDataManager.PrepareDataSet(ds: TfrTDataSet);
var
  q: TfrQuery;
  i, j, b, ofsx, ofsy: Integer;
  p: PfrParamInfo;
  f: Boolean;
begin
{$IFDEF BDE}
  if not (TDataSet(ds) is TQuery) or not FEnabled then Exit;
{$ENDIF}
{$IFDEF ADO}
  if not (TDataSet(ds) is TADOQuery) or not FEnabled then Exit;
{$ENDIF}
{$IFDEF IBX}
  if not (TDataSet(ds) is TIBQuery) or not FEnabled then Exit;
{$ENDIF}
  q := TfrQuery(ds);
  if (DocMode = dmPrinting) and (frDataStorage <> nil) then
    if Assigned(frDataStorage.OnQueryParams) then
      frDataStorage.OnQueryParams(CurReport, q);
  ofsx := 8; ofsy := 8;
  if TDataSet(ds) is TfrQuery then
    for i := 0 to q.frParams.Count - 1 do
    begin
      if q.frParams.ParamKind[i] <> pkAsk then
        continue;
      f := True;
      for j := 0 to frParamList.Count - 1 do
      begin
        p := frParamList[j];
        b := p^.EditControl.Bounds.Top + p^.EditControl.Bounds.Bottom - 1;
        if ofsx = 8 then
          if b + 4 > ofsy then
            ofsy := b + 4;
        if (q = p^.QueryRef) and (q.frParams.ParamName[i] = p^.ParamName) then
        begin
          p^.Actual := True;
          f := False;
        end;
      end;
      if f then
      begin
        GetMem(p, SizeOf(TfrParamInfo));
        FillChar(p^, SizeOf(TfrParamInfo), #0);
        p^.ComboStrings := TStringList.Create;
        if ofsx > 8 then
          Inc(ofsy, 25);
        if ofsy + 70 > ParamFormHeight then
        begin
          ParamFormHeight := ofsy + 70;
          if ParamFormHeight > 480 then
          begin
            ParamFormHeight := 480;
            ofsy := 8;
            Inc(ofsx, 210);
          end;
        end;
        p^.Actual := True;
        p^.QueryRef := q;
        p^.ParamName := q.frParams.ParamName[i];
        with p^.LabelControl do
        begin
          Bounds := Rect(ofsx, ofsy + 4, 101, 13);
          Caption := q.frParams.ParamName[i];
          FontName := 'MS Sans Serif';
          FontSize := 8;
          FontStyle := 0;
          FontCharset := frCharset;
          FontColor := clWindowText;
        end;
        with p^.EditControl do
        begin
          Bounds := Rect(ofsx + 104, ofsy, 89, 21);
          Caption := '';
          FontName := 'MS Sans Serif';
          FontSize := 8;
          FontStyle := 0;
          FontCharset := frCharset;
          FontColor := clWindowText;
        end;
        frParamList.Add(p);
        if ofsx + 200 > ParamFormWidth then
          ParamFormWidth := ofsx + 200;
      end;
    end;
end;

function TfrReportDataManager.ShowParamsDialog: Boolean;
var
  i, n: Integer;
  s, qname, pname: String;
  p: PfrParamInfo;
  ds: TDataSource;
  q: TfrQuery;
begin
  Result := True;
  for i := 0 to frSpecialParams.Count - 1 do
  begin
    s := frSpecialParams.Name[i];
    n := Pos('.', s);
    qname := Copy(s, 1, n - 1);
    pname := Copy(s, n + 1, 255);
    q := frDataModule.FindComponent(qname) as TfrQuery;
    if (q <> nil) and (q.frParams.ParamIndex(pname) <> -1) then
    begin
      q.Close;
      n := q.frParams.ParamIndex(pname);
      q.frParams.ParamText[n] := frParser.Calc(frSpecialParams.Value[i]);
    end;
  end;

  if frParamList.Count = 0 then Exit;
  for i := 0 to frParamList.Count - 1 do
  begin
    p := frParamList[i];
    p^.QueryRef.Close;
    if p.Typ = ptLookup then
    begin
      ds := frFindComponent(nil, p^.LookupDS) as TDataSource;
      if ds <> nil then
      begin
        p^.LookupActive := ds.DataSet.Active;
        ds.DataSet.Open;
      end;
    end;
  end;
  frParamsDialogForm.BorderStyle := bsDialog;
  frParamsDialogForm.Designing := False;
  frParamsDialogForm.ShowModal;
  for i := 0 to frParamList.Count - 1 do
  begin
    p := frParamList[i];
    try
      n := p^.QueryRef.frParams.ParamIndex(p^.ParamName);
      p^.QueryRef.frParams.ParamText[n] := p^.EditControl.Caption;
    except
      MessageBox(0, PChar(frLoadStr(SInvalidParamValue)), PChar(frLoadStr(SError)),
        mb_Ok + mb_IconError);
      Result := False;
      Exit;
    end;
    if p.Typ = ptLookup then
    begin
      ds := frFindComponent(nil, p^.LookupDS) as TDataSource;
      if ds <> nil then
        ds.DataSet.Active := p^.LookupActive;
    end;
  end;
  for i := 0 to frParamList.Count - 1 do
  begin
    p := frParamList[i];
    p^.QueryRef.Open;
  end;
end;

procedure TfrReportDataManager.AfterParamsDialog;
var
  i, n: Integer;
  s, qname, pname: String;
  p: PfrParamInfo;
  q: TfrQuery;
begin
  for i := 0 to frSpecialParams.Count - 1 do
  begin
    s := frSpecialParams.Name[i];
    n := Pos('.', s);
    qname := Copy(s, 1, n - 1);
    pname := Copy(s, n + 1, 255);
    q := frDataModule.FindComponent(qname) as TfrQuery;
    if (q <> nil) and (q.frParams.ParamIndex(pname) <> -1) then
    begin
      n := q.frParams.ParamIndex(pname);
      s := frSpecialParams.Value[i];
      q.frParams.ParamKind[n] := pkVariable;
      q.frParams.ParamVariable[n] := s;
    end;
  end;

  for i := 0 to frParamList.Count - 1 do
  begin
    p := frParamList[i];
    q := p^.QueryRef;
    n := q.frParams.ParamIndex(p^.ParamName);
    q.frParams.ParamKind[n] := pkAsk;
  end;
end;

procedure TfrReportDataManager.OnMngrClick(Sender:TObject);
var
  DatasetsForm: TfrDatasetsForm;
begin
  DatasetsForm := TfrDatasetsForm.Create(nil);
  with DatasetsForm do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TfrReportDataManager.OnParmClick(Sender: TObject);
begin
  CurReport.FillQueryParams;
  AfterPreparing;
  if frParamList.Count = 0 then Exit;
  frParamsDialogForm.BorderStyle := bsSizeable;
  frParamsDialogForm.Designing := True;
  frParamsDialogForm.ShowModal;
end;


initialization
  frDataManager := TfrReportDataManager.Create;
  Bmp1 := TBitmap.Create;
  Bmp1.Handle := LoadBitmap(hInstance, 'DATAMGRBMP');
  Bmp2 := TBitmap.Create;
  Bmp2.Handle := LoadBitmap(hInstance, 'PARAMDLGBMP');
  frRegisterTool(frLoadStr(SDataManager), Bmp1,
    TfrReportDataManager(frDataManager).OnMngrClick);
  frRegisterTool(frLoadStr(SParamDialog), Bmp2,
    TfrReportDataManager(frDataManager).OnParmClick);
  frDataModule := TDataModule.Create(nil);
  frDataModule.Name := 'ReportData';
  frParamList := TList.Create;

finalization
  Bmp1.Free;
  Bmp2.Free;
  frDataManager.Free;
  frDataManager := nil;
  ClearParamList;
  frDataModule.Free;
  frParamList.Free;

end.
