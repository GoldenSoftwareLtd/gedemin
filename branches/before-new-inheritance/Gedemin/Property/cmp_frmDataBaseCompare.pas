unit cmp_frmDataBaseCompare;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Db, IBDatabase, ActnList, IBSQL, ComCtrls, gdc_createable_form,
  rp_report_const, DBClient, prp_ScriptComparer_unit, gd_security, dmImages_unit,
  TB2Item, TB2Dock, TB2Toolbar, gd_ClassList, DBGrids, Contnrs, Diff, HashUnit,
  gdcBase, gdcSetting, gdcBaseInterface, ZLib, Menus, SuperPageControl, gsListView,
  at_SettingWalker;

const
  cn_eqv         = 0; // - значения равны
  cn_first       = 1; // - первое значение более новое
  cn_second      = 2; // - второе значение более новое
  cn_just_first  = 3; // - есть только в первой базе
  cn_just_second = 4; // - есть только во второй базе

  cn_procedure   = 'Процедура';
  cn_trigger     = 'Триггер';
  cn_view        = 'Представление';
  cn_table       = 'Таблица';
  cn_field       = 'Поле таблицы';

type
  TRecordInfo = record
    Result: Integer;
    Script: String;
    ExtScript: String;
    Module: String;
    ID: Integer;
    ExtID: Integer;
  end;

type
  TRecordData = class(TObject)
  public
    FRecordInfo: TRecordInfo;
  end;

type
  TDataBaseCompare = class(TgdcCreateableForm)
    odExternalDB: TOpenDialog;
    pnMain: TPanel;
    pnTop: TPanel;
    ibExtDataBase: TIBDatabase;
    pnBottom: TPanel;
    alCompareDB: TActionList;
    actCompareDB: TAction;
    gbViewItems: TGroupBox;
    pnViewItems: TPanel;
    TBToolbar1: TTBToolbar;
    tbOnlyFirstDBItems: TTBItem;
    tbEquivItems: TTBItem;
    tbDiffItems: TTBItem;
    tbOnlyExtDBItems: TTBItem;
    acRefresh: TAction;
    DSMacros: TClientDataSet;
    actMacrosDblClick: TAction;
    gbSearchOptions: TGroupBox;
    cbVBClass: TCheckBox;
    cbGO: TCheckBox;
    cbConst: TCheckBox;
    cbMacros: TCheckBox;
    cbSF: TCheckBox;
    cbReport: TCheckBox;
    cbMethod: TCheckBox;
    cbEvents: TCheckBox;
    cbEntry: TCheckBox;
    sbDBCompare: TStatusBar;
    SuperPageControl1: TSuperPageControl;
    SuperTabSheet1: TSuperTabSheet;
    SuperTabSheet2: TSuperTabSheet;
    lvMacros: TgsListView;
    lvMetaData: TgsListView;
    DSMetaData: TClientDataSet;
    pmMetaData: TPopupMenu;
    actAddPos: TAction;
    N1: TMenuItem;
    cbTrigger: TCheckBox;
    cbView: TCheckBox;
    cbSP: TCheckBox;
    cbTable: TCheckBox;
    pc: TPageControl;
    tsDB: TTabSheet;
    tsSetting: TTabSheet;
    btnCompareSetting: TButton;
    btnCompareDB: TButton;
    edExtDatabaseName: TEdit;
    btnExtOpen: TButton;
    lbExtUserName: TLabel;
    edExtUserName: TEdit;
    edExtServerName: TEdit;
    edExtPassword: TEdit;
    lbExtPassword: TLabel;
    Label1: TLabel;
    procedure btnExtOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actCompareDBUpdate(Sender: TObject);
    procedure actCompareDBExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure actMacrosDblClickExecute(Sender: TObject);
    procedure btnCompareSettingClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lvMetaDataDblClick(Sender: TObject);
    procedure actAddPosUpdate(Sender: TObject);
    procedure actAddPosExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FRecordData: TRecordData;
    FNumber: Integer;         //Номер для сортировки
    FExtConnected: Boolean;   //коннект к внешней БД
    FCompared: Boolean;       //сравнили ли уже
    FFileCompared: Boolean;   //сравнивали с файлом
    FList: TObjectList;
    FFileName: String;
    Diff: TDiff;              //Класс сравнения
    Source1, Source2: TStrings;

    //Сравенение скриптов
    procedure ConnectToDataBase;
    procedure CompareScipts(DS: TClientDataSet; ListView: TListView; Condition: String; IsSF: Boolean);
    procedure CompareMacros(DS: TClientDataSet; ListView: TListView; MacrosType: String);
    procedure FillMacros(DS: TClientDataSet; ListView: TListView);
    procedure FillMacrosNew(DS: TClientDataSet; ListView: TListView);

    //Локализация по имени метода(события)
    function LocaliseName(FSQL: TIBSQL): String;
    function LocaliseEventName(FSQL: TIBSQL): String;

    //Сравнение с настройкой
    procedure OnSettingObjectLoad(Sender: TatSettingWalker; const AClassName, ASubType: String;
      ADataSet: TDataSet; APrSet: TgdcPropertySet; const ASR: TgsStreamRecord);
    procedure OnSettingObjectLoadNew(Sender: TatSettingWalker; const AClassName, ASubType: String; ADataSet: TDataSet);
    procedure CompareSetting(DS: TDataSet);

    //Отображение и сравнение текстов
    procedure ShowDiffs;
    function CompareStr(const S1, S2: String): Integer;

    //Сравнение метаданных
    procedure CompareMetaData(DS: TClientDataSet; ListView: TListView; MetadataType: String);
    function GetViewTextBySource(const Source, RelationName: String): String;
    function GetTableEditionDate(const TableName: String; const DB: TIBDatabase): TDateTime;

  protected
    property ExtConnected: Boolean read FExtConnected write FExtConnected default False;
    property Compared: Boolean read FCompared write FCompared default False;
    property FileCompared: Boolean read FFileCompared write FFileCompared;

  public
    { Public declarations }
  end;

var
  DataBaseCompare: TDataBaseCompare;

implementation

{$R *.DFM}

uses
  gdc_frmExplorer_unit, gdUpdateIndiceStat, JclStrings, at_sql_parser,
  at_AddToSetting, cmp_dlgDataBaseCompare, gdcStreamSaver, gsStreamHelper;

procedure TDataBaseCompare.btnExtOpenClick(Sender: TObject);
begin
  if odExternalDB.Execute then
    edExtDatabaseName.Text := odExternalDB.FileName;

  if ExtConnected then
  begin
    ibExtDataBase.Close;
    ExtConnected := False;
    Compared := False;
  end;
end;

procedure TDataBaseCompare.FormCreate(Sender: TObject);
var
  ComputerName: array[0..MAX_COMPUTERNAME_LENGTH + 1] of Char;
  ComputerNameSize: DWord;
begin
  SuperPageControl1.ActivePageIndex := 0;

  tbOnlyFirstDBItems.Checked := True;
  tbEquivItems.Checked := True;
  tbDiffItems.Checked := True;
  tbOnlyExtDBItems.Checked := True;

  FList := TObjectList.Create;
  Diff := TDiff.Create(Self);
  Source1 := TStringList.Create;
  Source2 := TStringList.Create;

  if edExtServerName.Text = '' then
  begin
    ComputerNameSize := SizeOf(ComputerName);
    if GetComputerName(ComputerName, ComputerNameSize) = BOOL(0) then
    begin
      MessageBox(DataBaseCompare.Handle,
        'Ошибка в программе, невозможно получить имя компьютера.',
        'Ошибка', MB_OK or MB_ICONSTOP);
      Close;
    end else
    begin
      edExtServerName.Text := ComputerName;
    end;
  end;
  
  ShowSpeedButton := True;
end;

procedure TDataBaseCompare.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (Action = caHide) and FShiftDown then
    Action := caFree;
end;

procedure TDataBaseCompare.ConnectToDataBase;
begin
  try
    if Trim(edExtServerName.Text) > '' then
      ibExtDataBase.DatabaseName := Trim(edExtServerName.Text) + ':' + edExtDatabaseName.Text
    else
      ibExtDataBase.DatabaseName := edExtDatabaseName.Text;
    ibExtDataBase.Params.Values['user_name'] := edExtUserName.Text;
    ibExtDataBase.Params.Values['password'] := edExtPassword.Text;
    ibExtDataBase.Params.Values['lc_ctype'] := 'WIN1251';
    ibExtDataBase.LoginPrompt := False;
    ibExtDataBase.SQLDialect := 3;

    ibExtDataBase.Open;
    ExtConnected := True;
  except
    on E: Exception do
      raise Exception.Create('При подключении к БД возникла ошибка: ' +
        E.Message);
  end;
end;

procedure TDataBaseCompare.actCompareDBUpdate(Sender: TObject);
begin
  actCompareDB.Enabled := (edExtDatabaseName.Text > '');
end;

procedure TDataBaseCompare.actCompareDBExecute(Sender: TObject);
var
  Cr: TCursor;
begin
  if not ExtConnected then
    ConnectToDataBase;

  Compared := False;
  FileCompared := False;
  Cr := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    FList.Clear;

    DSMacros.FieldDefs.Clear;
    DSMacros.FieldDefs.Add('NAME', ftString, 60, false);
    DSMacros.FieldDefs.Add('FUNCTIONNAME', ftString, 80, false);
    DSMacros.FieldDefs.Add('EDITIONDATE1', ftDateTime, 0, false);
    DSMacros.FieldDefs.Add('EDITIONDATE2', ftDateTime, 0, false);
    DSMacros.FieldDefs.Add('MODULE', ftString, 15, false);
    DSMacros.FieldDefs.Add('ID', ftInteger, 0, false);
    DSMacros.FieldDefs.Add('EXTID', ftInteger, 0, false);
    DSMacros.FieldDefs.Add('RESULT', ftInteger, 0, false);
    DSMacros.FieldDefs.Add('SORTFIELD', ftInteger, 0, false);

    DSMacros.Close;
    DSMacros.CreateDataSet;
    DSMacros.Open;

    DSMetaData.FieldDefs.Clear;
    DSMetaData.FieldDefs.Add('NAME', ftString, 60, false);
    DSMetaData.FieldDefs.Add('FUNCTIONNAME', ftString, 80, false);
    DSMetaData.FieldDefs.Add('EDITIONDATE1', ftDateTime, 0, false);
    DSMetaData.FieldDefs.Add('EDITIONDATE2', ftDateTime, 0, false);
    DSMetaData.FieldDefs.Add('ID', ftInteger, 0, false);
    DSMetaData.FieldDefs.Add('EXTID', ftInteger, 0, false);
    DSMetaData.FieldDefs.Add('RESULT', ftInteger, 0, false);
    DSMetaData.FieldDefs.Add('SORTFIELD', ftInteger, 0, false);

    DSMetaData.Close;
    DSMetaData.CreateDataSet;
    DSMetaData.Open;

    FNumber := 0;

    lvMacros.Items.BeginUpdate;
    lvMacros.Items.Clear;

    lvMetaData.Items.BeginUpdate;
    lvMetaData.Items.Clear;
    try
      //Начинаем сравнивать
      if cbVBClass.Checked then
        CompareScipts(DSMacros, lvMacros, scrVBClasses, False);
      if cbGO.Checked then
        CompareScipts(DSMacros, lvMacros, scrGlobalObject, False);
      if cbConst.Checked then
        CompareScipts(DSMacros, lvMacros, scrConst, False);
      if cbMacros.Checked then
        CompareMacros(DSMacros, lvMacros, scrMacrosModuleName);
      if cbSF.Checked then
        CompareScipts(DSMacros, lvMacros, '', True);
      if cbReport.Checked then
      begin
        CompareMacros(DSMacros, lvMacros, MainModuleName);   // Модуль для функций построения отчетов
        CompareMacros(DSMacros, lvMacros, ParamModuleName);  // Модуль для функций запроса параметров
        CompareMacros(DSMacros, lvMacros, EventModuleName);  // Модуль для функций обработки событий
      end;
      if cbMethod.Checked then
        CompareMacros(DSMacros, lvMacros, scrMethodModuleName);
      if cbEvents.Checked then
        CompareMacros(DSMacros, lvMacros, scrEventModuleName);
      if cbEntry.Checked then
        CompareMacros(DSMacros, lvMacros, scrEntryModuleName);    // Проводки

      //Сравнение метаданных
      if cbSP.Checked then
        CompareMetaData(DSMetaData, lvMetaData, cn_procedure);
      if cbTrigger.Checked then
        CompareMetaData(DSMetaData, lvMetaData, cn_trigger);
      if cbView.Checked then
        CompareMetaData(DSMetaData, lvMetaData, cn_view);
      if cbTable.Checked then
        CompareMetaData(DSMetaData, lvMetaData, cn_table);

      DSMacros.IndexFieldNames := 'SORTFIELD';
      DSMetaData.IndexFieldNames := 'SORTFIELD';

      FillMacros(DSMacros, lvMacros);
      FillMacros(DSMetaData, lvMetaData);

      sbDBCompare.Panels[0].Text := IBLogin.DataBase.DatabaseName;
      sbDBCompare.Panels[1].Text := ibExtDataBase.DatabaseName;
    finally
      FNumber := 0;
      lvMacros.Items.EndUpdate;
      lvMetaData.Items.EndUpdate;
    end;
  finally
    Screen.Cursor := Cr;
  end;
  Compared := True;
end;

procedure TDataBaseCompare.acRefreshExecute(Sender: TObject);
var
  Cr: TCursor;
begin
  TTBItem(Sender).Checked := not TTBItem(Sender).Checked;
  if Compared then
  begin
    Cr := Screen.Cursor;
    try
      Screen.Cursor := crHourGlass;

      lvMacros.Items.BeginUpdate;
      lvMacros.Items.Clear;

      lvMetaData.Items.BeginUpdate;
      lvMetaData.Items.Clear;
      try
        if not FileCompared then
        begin
          FillMacros(DSMacros, lvMacros);
          FillMacros(DSMetaData, lvMetaData);
        end else
          FillMacrosNew(DSMacros, lvMacros);

      finally
        lvMacros.Items.EndUpdate;
        lvMetaData.Items.EndUpdate;
      end;
    finally
      Screen.Cursor := Cr;
    end;
  end;
end;

procedure TDataBaseCompare.CompareScipts(DS: TClientDataSet;
  ListView: TListView; Condition: String; IsSF: Boolean);
var
  FSQL, FExtSQL: TIBSQL;
  FTransaction: TIBTransaction;
  WhereClause: String;
begin
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.Params.Add('read_committed');
  FTransaction.Params.Add('rec_version');
  FTransaction.Params.Add('nowait');
  FTransaction.DefaultDatabase := ibExtDataBase;

  try
    FTransaction.StartTransaction;

    if IsSF then
      WhereClause := 'NOT (f.module IN (''VBCLASSES'', ''MACROS'', ''REPORTMAIN'', ''REPORTPARAM'', ''REPORTEVENT'', ' +
        '''EVENTS'', ''METHOD'', ''ENTRY'', ''GLOBALOBJECT'', ''CONST''))'
    else
      WhereClause := 'UPPER(module) = :module ';

    FExtSQL := TIBSQL.Create(nil);
    FExtSQL.Transaction := FTransaction;
    FExtSQL.SQL.Text := 'SELECT NAME, EDITIONDATE, CAST(LOWER(f.NAME) AS CHAR(80)) AS LN, SCRIPT, ID FROM GD_FUNCTION F ' +
      ' WHERE ' + WhereClause +
      ' ORDER BY 3';
    if not IsSF then
      FExtSQL.Params[0].AsString := Condition;
    FExtSQL.ExecQuery;

    FSQL := TIBSQL.Create(nil);
    FSQL.Transaction := gdcBaseManager.ReadTransaction;
    FSQL.SQL.Text := 'SELECT NAME, EDITIONDATE, CAST(LOWER(NAME) AS CHAR(80)) AS LN, SCRIPT, ID FROM GD_FUNCTION F ' +
      ' WHERE ' + WhereClause +
      ' ORDER BY 3';
    if not IsSF then
      FSQL.Params[0].AsString := Condition;
    FSQL.ExecQuery;
    try
      if (FSQL.RecordCount > 0) and (FExtSQL.RecordCount > 0) then
      begin
        while (not FSQL.Eof) or (not FExtSQL.Eof) do
        begin
          if (not FSQL.Eof) and (not FExtSQL.Eof) then
          begin
            if FSQL.FieldByName('NAME').AsString = FExtSQL.FieldByName('NAME').AsString then
            begin
              DS.Insert;
              DS.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
              DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('NAME').AsString;
              DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
              DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
              if CompareStr(FSQL.FieldByName('SCRIPT').AsString, FExtSQL.FieldByName('SCRIPT').AsString) <> 0 then
                if FSQL.FieldByName('EDITIONDATE').AsDateTime > FExtSQL.FieldByName('EDITIONDATE').AsDateTime then
                   DS.FieldByName('RESULT').AsInteger := cn_first
                else
                  DS.FieldByName('RESULT').AsInteger := cn_second
              else
                DS.FieldByName('RESULT').AsInteger := cn_eqv;
              DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
              DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
              DS.FieldByName('SORTFIELD').AsInteger := FNumber;
              DS.Post;

              FSQL.Next;
              FExtSQL.Next;
              Inc(FNumber);
            end else if AnsiCompareStr(FSQL.FieldByName('NAME').AsString, FExtSQL.FieldByName('NAME').AsString) > 0 then
            begin
              //только на второй базе
              DS.Insert;
              DS.FieldByName('NAME').AsString := FExtSQL.FieldByName('NAME').AsString;
              DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('NAME').AsString;
              DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
              DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
              DS.FieldByName('RESULT').AsInteger := cn_just_second;
              DS.FieldByName('SORTFIELD').AsInteger := FNumber;
              DS.Post;

              FExtSQL.Next;
              Inc(FNumber);
            end else
            begin
              //только на первой базе
              DS.Insert;
              DS.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
              DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('NAME').AsString;
              DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
              DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
              DS.FieldByName('RESULT').AsInteger := cn_just_first;
              DS.FieldByName('SORTFIELD').AsInteger := FNumber;
              DS.Post;

              FSQL.Next;
              Inc(FNumber);
            end;
          end else if (not FSQL.Eof) then
          begin
            DS.Insert;
            DS.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
            DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('NAME').AsString;
            DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
            DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
            DS.FieldByName('RESULT').AsInteger := cn_just_first;
            DS.FieldByName('SORTFIELD').AsInteger := FNumber;
            DS.Post;

            FSQL.Next;
            Inc(FNumber);
          end else
          begin
            DS.Insert;
            DS.FieldByName('NAME').AsString := FExtSQL.FieldByName('NAME').AsString;
            DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('NAME').AsString;
            DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
            DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
            DS.FieldByName('RESULT').AsInteger := cn_just_second;
            DS.FieldByName('SORTFIELD').AsInteger := FNumber;
            DS.Post;

            FExtSQL.Next;
            Inc(FNumber);
          end;
        end;
      end else if (FSQL.RecordCount > 0) then
      begin
        while not FSQL.Eof do
        begin
          DS.Insert;
          DS.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
          DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('NAME').AsString;
          DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
          DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
          DS.FieldByName('RESULT').AsInteger := cn_just_first;
          DS.FieldByName('SORTFIELD').AsInteger := FNumber;
          DS.Post;

          FSQL.Next;
          Inc(FNumber);
        end;
      end else
      begin
        while not FExtSQL.Eof do
        begin
          DS.Insert;
          DS.FieldByName('NAME').AsString := FExtSQL.FieldByName('NAME').AsString;
          DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('NAME').AsString;
          DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
          DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
          DS.FieldByName('RESULT').AsInteger := cn_just_second;
          DS.FieldByName('SORTFIELD').AsInteger := FNumber;
          DS.Post;

          FExtSQL.Next;
          Inc(FNumber);
        end;
      end;
      FSQL.Close;
      FExtSQL.Close;
    finally
      FExtSQL.Free;
      FSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure TDataBaseCompare.CompareMacros(DS: TClientDataSet; ListView: TListView; MacrosType: String);
var
  FSQL, FExtSQL: TIBSQL;
  FTransaction: TIBTransaction;
  SQLText: String;
  FEvent, FMethod: Boolean;
begin
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.Params.Add('read_committed');
  FTransaction.Params.Add('rec_version');
  FTransaction.Params.Add('nowait');
  FTransaction.DefaultDatabase := ibExtDataBase;

  FEvent := (MacrosType = scrEventModuleName);
  FMethod := (MacrosType = scrMethodModuleName);

  try
    FTransaction.StartTransaction;

    if MacrosType = scrMacrosModuleName then
      SQLText := 'SELECT ml.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, CAST(LOWER(f.NAME) AS CHAR(80)) AS LN, f.SCRIPT, f.ID ' +
        ' FROM evt_macroslist ml ' +
        ' LEFT JOIN GD_FUNCTION f ON f.ID = ml.FUNCTIONKEY '
    else if MacrosType = MainModuleName then
      SQLText := 'SELECT L.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, CAST(LOWER(f.NAME) AS CHAR(80)) AS LN, f.SCRIPT, f.ID ' +
        ' FROM RP_REPORTLIST L ' +
        ' JOIN GD_FUNCTION F ON F.ID = L.MAINFORMULAKEY '
    else if MacrosType = ParamModuleName then
      SQLText := 'SELECT L.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, CAST(LOWER(f.NAME) AS CHAR(80)) AS LN, f.SCRIPT, f.ID ' +
        ' FROM RP_REPORTLIST L ' +
        ' JOIN GD_FUNCTION F ON F.ID = L.PARAMFORMULAKEY '
    else if MacrosType = EventModuleName then
      SQLText := 'SELECT L.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, CAST(LOWER(f.NAME) AS CHAR(80)) AS LN, f.SCRIPT, f.ID ' +
        ' FROM RP_REPORTLIST L ' +
        ' JOIN GD_FUNCTION F ON F.ID = L.EVENTFORMULAKEY '
    else if MacrosType = scrEntryModuleName then
      SQLText := 'SELECT R.DESCRIPTION AS NAME, F.NAME AS FUNCTIONNAME, F.EDITIONDATE, CAST(LOWER(f.NAME) AS CHAR(80)) AS LN, f.SCRIPT, f.ID ' +
        ' FROM AC_TRRECORD R ' +
        ' LEFT JOIN GD_FUNCTION F ON F.ID = R.FUNCTIONKEY ' +
        ' WHERE R.FUNCTIONKEY IS NOT NULL '
    else if MacrosType = scrMethodModuleName then
      SQLText := 'SELECT o1.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, CAST(LOWER(f.NAME) AS CHAR(80)) AS LN, ' +
        '  o1.CLASSNAME, o1.SUBTYPE, f.SCRIPT, f.ID ' +
        'FROM evt_object o1 ' +
        'LEFT JOIN evt_objectevent e ON o1.id = e.objectkey ' +
        'LEFT JOIN gd_function f ON f.id = e.FUNCTIONKEY ' +
        'WHERE e.functionkey IS NOT NULL ' +
        '  AND f.MODULE = ''METHOD'' '
    else if MacrosType = scrEventModuleName then
      SQLText := 'SELECT o1.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, ' +
        '  CAST(LOWER(IIF(o2.OBJECTNAME IS NOT NULL, o2.OBJECTNAME, f.NAME)) AS CHAR(80)) AS LN, ' +
        '  CAST(LOWER(f.NAME) AS CHAR(80)) AS LN2, ' +
        '  o2.OBJECTNAME, f.SCRIPT, f.ID ' +
        'FROM evt_object o1 ' +
        'LEFT JOIN evt_objectevent e ON o1.id = e.objectkey ' +
        'LEFT JOIN gd_function f ON f.id = e.FUNCTIONKEY ' +
        'LEFT JOIN EVT_OBJECT o2 ON o2.ID = o1.PARENT ' +
        'WHERE e.functionkey IS NOT NULL ' +
        '  AND f.MODULE = ''EVENTS'' ' +
        'ORDER BY 4, 5 ';
    if not FEvent then
      SQLText := SQLText + ' ORDER BY 4 ';


    FExtSQL := TIBSQL.Create(nil);
    FExtSQL.Transaction := FTransaction;
    FExtSQL.SQL.Text := SQLText;
    FExtSQL.ExecQuery;

    FSQL := TIBSQL.Create(nil);
    FSQL.Transaction := gdcBaseManager.ReadTransaction;
    FSQL.SQL.Text := SQLText;
    FSQL.ExecQuery;
    try
      if (FSQL.RecordCount > 0) and (FExtSQL.RecordCount > 0) then
      begin
        while (not FSQL.Eof) or (not FExtSQL.Eof) do
        begin
          if (not FSQL.Eof) and (not FExtSQL.Eof) then
          begin
            if not FEvent then
            begin
              if FSQL.FieldByName('FUNCTIONNAME').AsString = FExtSQL.FieldByName('FUNCTIONNAME').AsString then
              begin
                DS.Insert;
                if FMethod then
                  DS.FieldByName('NAME').AsString := LocaliseName(FSQL)
                else
                  DS.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
                DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
                DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
                DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;

                if CompareStr(FSQL.FieldByName('SCRIPT').AsString, FExtSQL.FieldByName('SCRIPT').AsString) <> 0 then
                  if FSQL.FieldByName('EDITIONDATE').AsDateTime > FExtSQL.FieldByName('EDITIONDATE').AsDateTime then
                    DS.FieldByName('RESULT').AsInteger := cn_first
                  else
                    DS.FieldByName('RESULT').AsInteger := cn_second
                else
                  DS.FieldByName('RESULT').AsInteger := cn_eqv;
                DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
                DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
                DS.FieldByName('SORTFIELD').AsInteger := FNumber;
                DS.Post;

                FSQL.Next;
                FExtSQL.Next;
                Inc(FNumber);
              end else if AnsiCompareStr(FSQL.FieldByName('FUNCTIONNAME').AsString, FExtSQL.FieldByName('FUNCTIONNAME').AsString) > 0 then
              begin
                //только на второй базе
                DS.Insert;
                if FMethod then
                  DS.FieldByName('NAME').AsString := LocaliseName(FExtSQL)
                else
                  DS.FieldByName('NAME').AsString := FExtSQL.FieldByName('NAME').AsString;
                DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('FUNCTIONNAME').AsString;
                DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
                DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
                DS.FieldByName('RESULT').AsInteger := cn_just_second;
                DS.FieldByName('SORTFIELD').AsInteger := FNumber;
                DS.Post;

                FExtSQL.Next;
                Inc(FNumber);
              end else
              begin
                //только на первой базе
                DS.Insert;
                if FMethod then
                  DS.FieldByName('NAME').AsString := LocaliseName(FSQL)
                else
                  DS.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
                DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
                DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
                DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
                DS.FieldByName('RESULT').AsInteger := cn_just_first;
                DS.FieldByName('SORTFIELD').AsInteger := FNumber;
                DS.Post;

                FSQL.Next;
                Inc(FNumber);
              end;
            end else
            begin
              {Если события, то проверка другая}
              if FSQL.FieldByName('LN').AsString = FExtSQL.FieldByName('LN').AsString then
              begin
                if FSQL.FieldByName('FUNCTIONNAME').AsString = FExtSQL.FieldByName('FUNCTIONNAME').AsString then
                begin
                  DS.Insert;
                  DS.FieldByName('NAME').AsString := LocaliseEventName(FSQL);
                  DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
                  DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
                  DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;

                  if CompareStr(FSQL.FieldByName('SCRIPT').AsString, FExtSQL.FieldByName('SCRIPT').AsString) <> 0 then
                    if FSQL.FieldByName('EDITIONDATE').AsDateTime > FExtSQL.FieldByName('EDITIONDATE').AsDateTime then
                      DS.FieldByName('RESULT').AsInteger := cn_first
                    else
                      DS.FieldByName('RESULT').AsInteger := cn_second
                  else
                    DS.FieldByName('RESULT').AsInteger := cn_eqv;
                  DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
                  DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
                  DS.FieldByName('SORTFIELD').AsInteger := FNumber;
                  DS.Post;

                  FSQL.Next;
                  FExtSQL.Next;
                  Inc(FNumber);
                end else if AnsiCompareStr(FSQL.FieldByName('FUNCTIONNAME').AsString, FExtSQL.FieldByName('FUNCTIONNAME').AsString) > 0 then
                begin
                  //только на второй базе
                  DS.Insert;
                  DS.FieldByName('NAME').AsString := LocaliseEventName(FExtSQL);
                  DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('FUNCTIONNAME').AsString;
                  DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
                  DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
                  DS.FieldByName('RESULT').AsInteger := cn_just_second;
                  DS.FieldByName('SORTFIELD').AsInteger := FNumber;
                  DS.Post;

                  FExtSQL.Next;
                  Inc(FNumber);
                end else
                begin
                  //только на первой базе
                  DS.Insert;
                  DS.FieldByName('NAME').AsString := LocaliseEventName(FSQL);
                  DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
                  DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
                  DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
                  DS.FieldByName('RESULT').AsInteger := cn_just_first;
                  DS.FieldByName('SORTFIELD').AsInteger := FNumber;
                  DS.Post;

                  FSQL.Next;
                  Inc(FNumber);
                end;
              end else
              begin
                if AnsiCompareStr(FSQL.FieldByName('LN').AsString, FExtSQL.FieldByName('LN').AsString) > 0 then
                begin
                  //только на второй базе
                  DS.Insert;
                  DS.FieldByName('NAME').AsString := LocaliseEventName(FExtSQL);
                  DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('FUNCTIONNAME').AsString;
                  DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
                  DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
                  DS.FieldByName('RESULT').AsInteger := cn_just_second;
                  DS.FieldByName('SORTFIELD').AsInteger := FNumber;
                  DS.Post;

                  FExtSQL.Next;
                  Inc(FNumber);
                end else
                begin
                  //только на первой базе
                  DS.Insert;
                  DS.FieldByName('NAME').AsString := LocaliseEventName(FSQL);
                  DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
                  DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
                  DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
                  DS.FieldByName('RESULT').AsInteger := cn_just_first;
                  DS.FieldByName('SORTFIELD').AsInteger := FNumber;
                  DS.Post;

                  FSQL.Next;
                  Inc(FNumber);
                end;
              end;
            end;
          end else if (not FSQL.Eof) then
          begin
            DS.Insert;
            if FMethod then
              DS.FieldByName('NAME').AsString := LocaliseName(FSQL)
            else if FEvent then
              DS.FieldByName('NAME').AsString := LocaliseEventName(FSQL)
            else
              DS.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
            DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
            DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
            DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
            DS.FieldByName('RESULT').AsInteger := cn_just_first;
            DS.FieldByName('SORTFIELD').AsInteger := FNumber;
            DS.Post;

            FSQL.Next;
            Inc(FNumber);
          end else
          begin
            DS.Insert;
            if FMethod then
              DS.FieldByName('NAME').AsString := LocaliseName(FExtSQL)
            else if FEvent then
              DS.FieldByName('NAME').AsString := LocaliseEventName(FExtSQL)
            else
              DS.FieldByName('NAME').AsString := FExtSQL.FieldByName('NAME').AsString;
            DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('FUNCTIONNAME').AsString;
            DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
            DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
            DS.FieldByName('RESULT').AsInteger := cn_just_second;
            DS.FieldByName('SORTFIELD').AsInteger := FNumber;
            DS.Post;

            FExtSQL.Next;
            Inc(FNumber);
          end;
        end;
      end else if (FSQL.RecordCount > 0) then
      begin
        while not FSQL.Eof do
        begin
          DS.Insert;
          if FMethod then
            DS.FieldByName('NAME').AsString := LocaliseName(FSQL)
          else if FEvent then
            DS.FieldByName('NAME').AsString := LocaliseEventName(FSQL)
          else
            DS.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
          DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
          DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
          DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
          DS.FieldByName('RESULT').AsInteger := cn_just_first;
          DS.FieldByName('SORTFIELD').AsInteger := FNumber;
          DS.Post;

          FSQL.Next;
          Inc(FNumber);
        end;
      end else
      begin
        while not FExtSQL.Eof do
        begin
          DS.Insert;
          if FMethod then
            DS.FieldByName('NAME').AsString := LocaliseName(FExtSQL)
          else if FEvent then
            DS.FieldByName('NAME').AsString := LocaliseEventName(FExtSQL)
          else
            DS.FieldByName('NAME').AsString := FExtSQL.FieldByName('NAME').AsString;
          DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('FUNCTIONNAME').AsString;
          DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
          DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
          DS.FieldByName('RESULT').AsInteger := cn_just_second;
          DS.FieldByName('SORTFIELD').AsInteger := FNumber;
          DS.Post;

          FExtSQL.Next;
          Inc(FNumber);
        end;
      end;
      FSQL.Close;
      FExtSQL.Close;
    finally
      FExtSQL.Free;
      FSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure TDataBaseCompare.FillMacros(DS: TClientDataSet; ListView: TListView);

  procedure FillRecordData(DS: TClientDataSet);
  begin
    FRecordData := TRecordData.Create;
    FRecordData.FRecordInfo.Result := DS.FieldByName('RESULT').AsInteger;
    FRecordData.FRecordInfo.ID := DS.FieldByName('ID').AsInteger;
    FRecordData.FRecordInfo.ExtID := DS.FieldByName('EXTID').AsInteger;
    FRecordData.FRecordInfo.Module := DS.FieldByName('NAME').AsString;
    FList.Add(FRecordData);
  end;

var
  ListItem: TListItem;
begin
  DS.First;
  while not DS.Eof do
  begin
    with ListView do
      begin
        case DS.FieldByName('RESULT').AsInteger of
          cn_just_first:
            begin
              if tbOnlyFirstDBItems.Checked then
              begin
                FillRecordData(DS);

                ListItem := Items.Add;
                ListItem.ImageIndex := -1;
                LIstItem.Data := Pointer(FRecordData);
                ListItem.Caption := DS.FieldByName('NAME').AsString;
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE1').AsString);
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add('');
                ListItem.SubItemImages[2] := 156;
              end;
            end;
          cn_just_second:
            begin
              if tbOnlyExtDBItems.Checked then
              begin
                FillRecordData(DS);

                ListItem := Items.Add;
                ListItem.ImageIndex := -1;
                LIstItem.Data := Pointer(FRecordData);
                ListItem.Caption := '';
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add(DS.FieldByName('NAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE2').AsString);
                ListItem.SubItemImages[2] := 157;
              end;
            end;
          cn_eqv:
            begin
              if tbEquivItems.Checked then
              begin
                FillRecordData(DS);

                ListItem := Items.Add;
                ListItem.ImageIndex := -1;
                LIstItem.Data := Pointer(FRecordData);
                ListItem.Caption := DS.FieldByName('NAME').AsString;
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE1').AsString);
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add(DS.FieldByName('NAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE2').AsString);
                ListItem.SubItemImages[2] := 214
              end;
            end;
          cn_first, cn_second:
            begin
              if tbDiffItems.Checked then
              begin
                FillRecordData(DS);

                ListItem := Items.Add;
                ListItem.ImageIndex := -1;
                LIstItem.Data := Pointer(FRecordData);
                ListItem.Caption := DS.FieldByName('NAME').AsString;
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE1').AsString);
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add(DS.FieldByName('NAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE2').AsString);
                if DS.FieldByName('RESULT').AsInteger = cn_first then
                  ListItem.SubItemImages[2] := 175
                else if DS.FieldByName('RESULT').AsInteger = cn_second then
                  ListItem.SubItemImages[2] := 189;
              end;
            end;
        end;
      end;
    DS.Next;
  end;
end;

procedure TDataBaseCompare.actMacrosDblClickExecute(Sender: TObject);
var
  FSQL, FExtSQL: TIBSQL;
  ScriptComparer: Tprp_ScriptComparer;
  S, S1, SQL: String;
  DBName, ExtDBName: String;
  FTransaction: TIBTransaction;
  ListView: TListView;
begin
  ListView := (Sender as TListView);
  if ListView.Selected = nil then
    exit;

  if FileCompared then
  begin
    ShowDiffs;
    exit;
  end;

  if not ExtConnected then
      ConnectToDataBase;

  if ListView.Selected.Data <> nil then
  begin
    FTransaction := TIBTransaction.Create(nil);
    FTransaction.Params.Add('read_committed');
    FTransaction.Params.Add('rec_version');
    FTransaction.Params.Add('nowait');
    FTransaction.DefaultDatabase := ibExtDataBase;
    try
      FTransaction.StartTransaction;
      DBName := IBLogin.Database.DatabaseName;
      ExtDBName := ibExtDataBase.DatabaseName;
      SQL := ' SELECT SCRIPT FROM GD_FUNCTION ' +
        ' WHERE ID = :ID ';

      case TRecordData(lvMacros.Selected.Data).FRecordInfo.Result of
        cn_eqv, cn_first, cn_second:
          begin
            FSQL := TIBSQL.Create(nil);
            FSQL.Transaction := gdcBaseManager.ReadTransaction;
            FSQL.SQL.Text := SQL;
            FSQL.Params[0].AsInteger := TRecordData(lvMacros.Selected.Data).FRecordInfo.ID;

            FExtSQL := TIBSQL.Create(nil);
            FExtSQL.Transaction := FTransaction;
            FExtSQL.SQL.Text := SQL;
            FExtSQL.Params[0].AsInteger := TRecordData(lvMacros.Selected.Data).FRecordInfo.ExtID;
            try
              FSQL.ExecQuery;
              S := FSQL.FieldByName('SCRIPT').AsString;
              FSQL.Close;

              FExtSQL.ExecQuery;
              S1 := FExtSQL.FieldByName('SCRIPT').AsString;
              FExtSQL.Close;
            finally
              FSQL.Free;
              FExtSQL.Free;
            end;
          end;
        cn_just_first:
          begin
            FSQL := TIBSQL.Create(nil);
            FSQL.Transaction := gdcBaseManager.ReadTransaction;
            FSQL.SQL.Text := SQL;
            FSQL.Params[0].AsInteger := TRecordData(lvMacros.Selected.Data).FRecordInfo.ID;
            try
              FSQL.ExecQuery;
              S := FSQL.FieldByName('SCRIPT').AsString;
              FSQL.Close;

              S1 := '';
            finally
              FSQL.Free;
            end;
          end;
        cn_just_second:
          begin
            FExtSQL := TIBSQL.Create(nil);
            FExtSQL.Transaction := FTransaction;
            FExtSQL.SQL.Text := SQL;
            FExtSQL.Params[0].AsInteger := TRecordData(lvMacros.Selected.Data).FRecordInfo.ExtID;
            try
              FExtSQL.ExecQuery;
              S1 := FExtSQL.FieldByName('SCRIPT').AsString;
              FExtSQL.Close;

              S := '';
            finally
              FExtSQL.Free;
            end;
          end;
      end;
    finally
      FTransaction.Free;
    end;

    ScriptComparer := Tprp_ScriptComparer.Create(nil);
    try
      ScriptComparer.Compare(S, S1);
      ScriptComparer.LeftCaption(DBName);
      ScriptComparer.RightCaption(ExtDBName);
      ScriptComparer.ShowModal;
    finally
      ScriptComparer.Free;
    end;
  end;
end;

function TDataBaseCompare.LocaliseName(FSQL: TIBSQL): String;
var
  SQL: TIBSQL;
  C: CgdcBase;
  S: String;
begin
  Result := FSQL.FieldByName('NAME').AsString;

  //сначала заменяем USR$
  //если справочник, то смотрим в AT_Relations
  //если есть subtype и не справвочник, то смотрим в gd_documenttype
  //иначе смотрим через gdcClassList

  if FSQL.FieldByName('CLASSNAME').AsString <> '' then
  begin
    S := StringReplace(FSQL.FieldByName('SUBTYPE').AsString, 'USR_', 'USR$', []);
    if Pos('USR$', S) > 0 then
    begin
      SQL := TIBSQL.Create(nil);
      SQL.Transaction := FSQL.Transaction;
      SQL.SQL.Text := 'SELECT DESCRIPTION FROM AT_RELATIONS ' +
        'WHERE RELATIONNAME = :name ';
      try
        SQL.Params[0].AsString := S;
        SQL.ExecQuery;
        if SQL.RecordCount > 0 then
          Result := SQL.Fields[0].AsString;
      finally
        SQL.Free;
      end;
    end
    else if S <> '' then
    begin
      SQL := TIBSQL.Create(nil);
      SQL.Transaction := FSQL.Transaction;
      SQL.SQL.Text := 'SELECT NAME FROM GD_DOCUMENTTYPE ' +
        'WHERE RUID = :name ';
      try
        SQL.Params[0].AsString := S;
        SQL.ExecQuery;
        if SQL.RecordCount > 0 then
          Result := SQL.Fields[0].AsString;
      finally
        SQL.Free;
      end;
    end else
    begin
      C := gdcClassList.GetGDCClass(gdcFullClassName(FSQL.FieldByName('CLASSNAME').AsString, S));
      if (C <> nil) and (IBLogin.Database = FSQL.Database) then
        Result := C.GetDisplayName(S)
    end;
  end;
end;

function TDataBaseCompare.LocaliseEventName(FSQL: TIBSQL): String;
var
  SQL: TIBSQL;
  S: String;
  Position, Ln: Integer;
  I: Integer;
begin
  //Вариант 1. поле OBJECTNAME null, ищем по NAME
  //тогда:
  //ищем есть ли USR_, есть ли есть, то вырезаем название таблицы и ищем по ней
  //если нет, то поаытаемся найти РУИД и поискать в таблице gd_documenttype
  //иначе смотрим через класс.
  //Вариант 2. поиск по полю OBJECTNAME

  if FSQL.FieldByName('OBJECTNAME').IsNull then
    S := FSQL.FieldByName('NAME').AsString
  else
    S := FSQL.FieldByName('OBJECTNAME').AsString;

  Result := S;

  S := StringReplace(S, 'USR_', 'USR$', []);
  Position := Pos('USR$', S);
  if Position > 0 then
  begin
    //Выделим имя таблицы
    S := Copy(S, Position, Length(S) - Position + 1);
    SQL := TIBSQL.Create(nil);
    SQL.Transaction := FSQL.Transaction;
    SQL.SQL.Text := 'SELECT DESCRIPTION FROM AT_RELATIONS ' +
      'WHERE RELATIONNAME = :name ';
    try
      SQL.Params[0].AsString := S;
      SQL.ExecQuery;
      if SQL.RecordCount > 0 then
        Result := SQL.Fields[0].AsString;
    finally
      SQL.Free;
    end;
  end else
  begin
    //Выделяем РУИД
    if S[Length(S)] in ['0'..'9'] then
    begin
      Position := Length(S);
      Ln := Position;
      for I := Ln downto 0 do
        if S[I] in ['0'..'9', '_'] then
          Dec(Position)
        else
          break;

      if Position < Ln then
      begin
        S := Copy(S, Position + 1, Length(S) - Position + 1);
        SQL := TIBSQL.Create(nil);
        SQL.Transaction := FSQL.Transaction;
        SQL.SQL.Text := 'SELECT NAME FROM GD_DOCUMENTTYPE ' +
          'WHERE RUID = :name ';
        try
          SQL.Params[0].AsString := S;
          SQL.ExecQuery;
          if SQL.RecordCount > 0 then
            Result := SQL.Fields[0].AsString;
        finally
          SQL.Free;
        end;
      end;
    end;
  end;
end;

procedure TDataBaseCompare.btnCompareSettingClick(Sender: TObject);
var
  FS: TFileStream;
  SettingWalker: TatSettingWalker;
  OldCursor: TCursor;
begin
  with TOpenDialog.Create(Self) do
  try
    DefaultExt := gsfExtension;
    Filter := gsfxmlDialogFilter;
    Title := 'Загрузить настройку из файла.';
    if Execute then
    begin
      FNumber := 0;
      Compared := False;
      FileCompared := False;
      FFileName := FileName;
      OldCursor := Screen.Cursor;
      with TGSFHeader.Create do
      try
        if GetGSFInfo(FFileName) then           // проверяем корректность файла
        begin
          Screen.Cursor := crHourGlass;
          FList.Clear;

          DSMacros.FieldDefs.Clear;
          DSMacros.FieldDefs.Add('NAME', ftString, 60, false);
          DSMacros.FieldDefs.Add('FUNCTIONNAME', ftString, 80, false);
          DSMacros.FieldDefs.Add('EDITIONDATE1', ftDateTime, 0, false);
          DSMacros.FieldDefs.Add('EDITIONDATE2', ftDateTime, 0, false);
          DSMacros.FieldDefs.Add('SCRIPT', ftBlob, 0, false);
          DSMacros.FieldDefs.Add('MODULE', ftString, 15, false);
          DSMacros.FieldDefs.Add('ID', ftInteger, 0, false);
          DSMacros.FieldDefs.Add('RESULT', ftInteger, 0, false);
          DSMacros.FieldDefs.Add('SORTFIELD', ftInteger, 0, false);

          DSMacros.Close;
          DSMacros.CreateDataSet;
          DSMacros.Open;

          FS := TFileStream.Create(FFileName, fmOpenRead);
          try
            SettingWalker := TatSettingWalker.Create;
            try
              SettingWalker.ObjectLoad := OnSettingObjectLoad;
              SettingWalker.ObjectLoadNew := OnSettingObjectLoadNew;
              SettingWalker.Stream := FS;

              SettingWalker.ParseSetting;
            finally
              FreeAndNil(SettingWalker);
            end;
          finally
            FS.Free;
          end;

          lvMacros.Items.BeginUpdate;
          lvMacros.Items.Clear;
          try
            FillMacrosNew(DSMacros, lvMacros);
          finally
            lvMacros.Items.EndUpdate;
          end;
          Compared := True;
          FileCompared := True;

          sbDBCompare.Panels[0].Text := IBLogin.DataBase.DatabaseName;
          sbDBCompare.Panels[1].Text := FFileName;
        end else
          MessageBox(0,
          'Некорректный файл настройки.',
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      finally
        Screen.Cursor := OldCursor;
        Free;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TDataBaseCompare.OnSettingObjectLoadNew(Sender: TatSettingWalker;
  const AClassName, ASubType: String; ADataSet: TDataSet);
begin
  if AClassName = 'TgdcFunction' then
    CompareSetting(ADataSet);
end;

procedure TDataBaseCompare.OnSettingObjectLoad(Sender: TatSettingWalker;
  const AClassName, ASubType: String; ADataSet: TDataSet;
  APrSet: TgdcPropertySet; const ASR: TgsStreamRecord);
begin
  // вызов нового метода
  OnSettingObjectLoadNew(Sender, AClassName, ASubType, ADataSet);
end;

{
CONST        +
ENTRY        +
EVENTS       +
GLOBALOBJECT +
MACROS       +
METHOD       +
REPORTEVENT  +
REPORTMAIN   +
REPORTPARAM  +
UNKNOWN      +
VBCLASSES    +
}

procedure TDataBaseCompare.CompareSetting(DS: TDataSet);

  procedure FillScriptDS(DS: TDataSet);
  begin
    DSMacros.Insert;
    DSMacros.FieldByName('NAME').AsString := DS.FieldByName('NAME').AsString;
    DSMacros.FieldByName('FUNCTIONNAME').AsString := DS.FieldByName('NAME').AsString;
    DSMacros.FieldByName('EDITIONDATE2').AsDateTime := DS.FieldByName('EDITIONDATE').AsDateTime;
    DSMacros.FieldByName('RESULT').AsInteger := cn_just_second;
    DSMacros.FieldByName('SCRIPT').AsString := DS.FieldByName('SCRIPT').AsString;
    DSMacros.FieldByName('MODULE').AsString := DS.FieldByName('MODULE').AsString;
    DSMacros.FieldByName('SORTFIELD').AsInteger := FNumber;
    DSMacros.Post;

    Inc(FNumber);
  end;

  procedure FillEventDS(DS: TDataSet);
  begin
    DSMacros.Insert;
    DSMacros.FieldByName('NAME').AsString := DS.FieldByName('NAME').AsString;
    DSMacros.FieldByName('FUNCTIONNAME').AsString := DS.FieldByName('OBJECTNAME').AsString;
    DSMacros.FieldByName('EDITIONDATE2').AsDateTime := DS.FieldByName('EDITIONDATE').AsDateTime;
    DSMacros.FieldByName('RESULT').AsInteger := cn_just_second;
    DSMacros.FieldByName('SCRIPT').AsString := DS.FieldByName('SCRIPT').AsString;
    DSMacros.FieldByName('MODULE').AsString := DS.FieldByName('MODULE').AsString;
    DSMacros.FieldByName('SORTFIELD').AsInteger := FNumber;
    DSMacros.Post;

    Inc(FNumber);
  end;

  procedure FillExistsScript(DS: TDataSet; FSQL: TIBSQL);
  begin
    DSMacros.Insert;
    DSMacros.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
    DSMacros.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
    DSMacros.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
    DSMacros.FieldByName('EDITIONDATE2').AsDateTime := DS.FieldByName('EDITIONDATE').AsDateTime;
    if Trim(FSQL.FieldByName('SCRIPT').AsString) <> Trim(DS.FieldByName('SCRIPT').AsString) then
      if FSQL.FieldByName('EDITIONDATE').AsDateTime > DS.FieldByName('EDITIONDATE').AsDateTime then
        DSMacros.FieldByName('RESULT').AsInteger := cn_first
      else
        DSMacros.FieldByName('RESULT').AsInteger := cn_second
    else
      DSMacros.FieldByName('RESULT').AsInteger := cn_eqv;
    DSMacros.FieldByName('MODULE').AsString := DS.FieldByName('MODULE').AsString;
    DSMacros.FieldByName('SCRIPT').AsString := DS.FieldByName('SCRIPT').AsString;
    DSMacros.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
    DSMacros.FieldByName('SORTFIELD').AsInteger := FNumber;
    DSMacros.Post;

    Inc(FNumber);
  end;

var
  FSQL: TIBSQL;
  Module: String;
begin

  Module := DS.FieldByName('MODULE').AsString;
  if (Module = scrConst) or (Module = scrVBClasses) or (Module = scrGlobalObject) or (Module = scrUnkonownModule) then
  begin
    if ((cbConst.Checked) and (Module = scrConst)) or ((cbVBClass.Checked) and (Module = scrVBClasses))
      or ((cbGO.Checked) and (Module = scrGlobalObject)) or ((cbSF.Checked) and (Module = scrUnkonownModule)) then
    begin
      FSQL := TIBSQL.Create(nil);
      try
        FSQL.Transaction := gdcBaseManager.ReadTransaction;
        FSQL.SQL.Text := ' SELECT NAME, NAME AS FUNCTIONNAME, EDITIONDATE, SCRIPT, ID FROM GD_FUNCTION ' +
          ' WHERE UPPER(module) = :module ' +
          '   AND NAME = :name';
        FSQL.Params[0].AsString := Module;
        FSQL.Params[1].AsString := DS.FieldByName('NAME').AsString;
        FSQL.ExecQuery;
        if not FSQL.Eof then
          FillExistsScript(DS, FSQL)
        else
          FillScriptDS(DS);
        FSQL.Close;
      finally
        FSQL.Free;
      end;
    end;
  end
  else if Module = scrEventModuleName then
  begin
    if cbEvents.Checked then
    begin
      FSQL := TIBSQL.Create(nil);
      try
        FSQL.Transaction := gdcBaseManager.ReadTransaction;
        FSQL.SQL.Text := ' SELECT o1.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, ' +
          '  o2.OBJECTNAME, f.SCRIPT, f.ID ' +
          ' FROM EVT_OBJECT o2 ' +
          ' LEFT JOIN evt_object o1 ON o2.ID = o1.PARENT ' +
          ' LEFT JOIN evt_objectevent e ON o1.id = e.objectkey ' +
          ' LEFT JOIN gd_function f ON f.id = e.FUNCTIONKEY ' +
          ' WHERE UPPER(f.MODULE) = :module ' +
          '   AND UPPER(o2.OBJECTNAME) = :ob ' +
          '   AND f.NAME = :name ' +
          '  ' +
          ' UNION ALL ' +
          '  ' +
          ' SELECT o2.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, ' +
          '  o2.OBJECTNAME, f.SCRIPT, f.ID ' +
          ' FROM EVT_OBJECT o2 ' +
          ' LEFT JOIN evt_objectevent e ON o2.id = e.objectkey ' +
          ' LEFT JOIN gd_function f ON f.id = e.FUNCTIONKEY ' +
          ' WHERE UPPER(f.MODULE) = :module ' +
          '   AND UPPER(o2.OBJECTNAME) = :ob ' +
          '   AND f.NAME = :name ';
        FSQL.ParamByName('module').AsString := Module;
        FSQL.ParamByName('ob').AsString := AnsiUpperCase(DS.FieldByName('OBJECTNAME').AsString);
        FSQL.ParamByName('name').AsString := DS.FieldByName('NAME').AsString;
        FSQL.ExecQuery;
        if not FSQL.Eof then
        begin
          DSMacros.Insert;
          DSMacros.FieldByName('NAME').AsString := LocaliseEventName(FSQL);
          DSMacros.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
          DSMacros.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
          DSMacros.FieldByName('EDITIONDATE2').AsDateTime := DS.FieldByName('EDITIONDATE').AsDateTime;
          if Trim(FSQL.FieldByName('SCRIPT').AsString) <> Trim(DS.FieldByName('SCRIPT').AsString) then
            if FSQL.FieldByName('EDITIONDATE').AsDateTime > DS.FieldByName('EDITIONDATE').AsDateTime then
              DSMacros.FieldByName('RESULT').AsInteger := cn_first
            else
              DSMacros.FieldByName('RESULT').AsInteger := cn_second
          else
            DSMacros.FieldByName('RESULT').AsInteger := cn_eqv;
          DSMacros.FieldByName('MODULE').AsString := Module;
          DSMacros.FieldByName('SCRIPT').AsString := DS.FieldByName('SCRIPT').AsString;
          DSMacros.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
          DSMacros.FieldByName('SORTFIELD').AsInteger := FNumber;
          DSMacros.Post;

          Inc(FNumber);
        end else
          FillEventDS(DS);
        FSQL.Close
      finally
        FSQL.Free;
      end;
    end;
  end
  else if Module = scrMethodModuleName then
  begin
    if cbMethod.Checked then
    begin
      FSQL := TIBSQL.Create(nil);
      try
        FSQL.Transaction := gdcBaseManager.ReadTransaction;
        FSQL.SQL.Text := 'SELECT o1.NAME, f.NAME AS FUNCTIONNAME, f.EDITIONDATE, ' +
          ' o1.CLASSNAME, o1.SUBTYPE, f.SCRIPT, F.ID ' +
          ' FROM GD_FUNCTION F ' +
          ' LEFT JOIN evt_objectevent e ON f.id = e.FUNCTIONKEY ' +
          ' LEFT JOIN evt_object o1 ON o1.id = e.objectkey '+
          ' WHERE UPPER(f.MODULE) = :module ' +
          '   AND f.NAME = :name ';
        FSQL.Params[0].AsString := Module;
        FSQL.Params[1].AsString := DS.FieldByName('NAME').AsString;
        FSQL.ExecQuery;
        if not FSQL.Eof then
        begin
          DSMacros.Insert;
          DSMacros.FieldByName('NAME').AsString := LocaliseName(FSQL);
          DSMacros.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('FUNCTIONNAME').AsString;
          DSMacros.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
          DSMacros.FieldByName('EDITIONDATE2').AsDateTime := DS.FieldByName('EDITIONDATE').AsDateTime;
          if Trim(FSQL.FieldByName('SCRIPT').AsString) <> Trim(DS.FieldByName('SCRIPT').AsString) then
            if FSQL.FieldByName('EDITIONDATE').AsDateTime > DS.FieldByName('EDITIONDATE').AsDateTime then
              DSMacros.FieldByName('RESULT').AsInteger := cn_first
            else
              DSMacros.FieldByName('RESULT').AsInteger := cn_second
          else
            DSMacros.FieldByName('RESULT').AsInteger := cn_eqv;
          DSMacros.FieldByName('MODULE').AsString := Module;
          DSMacros.FieldByName('SCRIPT').AsString := DS.FieldByName('SCRIPT').AsString;
          DSMacros.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
          DSMacros.FieldByName('SORTFIELD').AsInteger := FNumber;
          DSMacros.Post;

          Inc(FNumber);
        end else
          FillEventDS(DS);
        FSQL.Close;
      finally
        FSQL.Free;
      end;
    end;
  end
  else if Module = scrMacrosModuleName then
  begin
    if cbMacros.Checked then
    begin
      FSQL := TIBSQL.Create(nil);
      try
        FSQL.Transaction := gdcBaseManager.ReadTransaction;
        FSQL.SQL.Text := 'SELECT ml.NAME, f.NAME AS FUNCTIONNAME, f.SCRIPT, f.EDITIONDATE, F.ID ' +
          ' FROM GD_FUNCTION f ' +
          ' LEFT JOIN evt_macroslist ml ON f.ID = ml.FUNCTIONKEY ' +
          ' WHERE UPPER(f.module) = :module ' +
          '   AND f.NAME = :name';
        FSQL.Params[0].AsString := Module;
        FSQL.Params[1].AsString := DS.FieldByName('NAME').AsString;
        FSQL.ExecQuery;
        if not FSQL.Eof then
          FillExistsScript(DS, FSQL)
        else
          FillScriptDS(DS);
        FSQL.Close;
      finally
        FSQL.Free;
      end;
    end;
  end
  else if (Module = MainModuleName) or (Module = ParamModuleName) or (Module = EventModuleName) then
  begin
    if cbReport.Checked then
    begin
      FSQL := TIBSQL.Create(nil);
      try
        FSQL.Transaction := gdcBaseManager.ReadTransaction;
        if Module = MainModuleName then
          FSQL.SQL.Text := ' SELECT L.NAME, F.NAME AS FUNCTIONNAME, F.SCRIPT, F.EDITIONDATE, F.ID ' +
          ' FROM GD_FUNCTION F ' +
          ' LEFT JOIN RP_REPORTLIST L ON l.MAINFORMULAKEY = F.ID ' +
          ' WHERE UPPER(F.MODULE) = :module ' +
          '   AND F.NAME = :name '
        else if Module = ParamModuleName then
          FSQL.SQL.Text := ' SELECT L.NAME, F.NAME AS FUNCTIONNAME, F.SCRIPT, F.EDITIONDATE, F.ID ' +
          ' FROM GD_FUNCTION F ' +
          ' LEFT JOIN RP_REPORTLIST L ON l.PARAMFORMULAKEY = F.ID ' +
          ' WHERE UPPER(F.MODULE) = :module ' +
          '   AND F.NAME = :name '
        else if Module = EventModuleName then
          FSQL.SQL.Text := ' SELECT L.NAME, F.NAME AS FUNCTIONNAME, F.SCRIPT, F.EDITIONDATE, F.ID ' +
          ' FROM GD_FUNCTION F ' +
          ' LEFT JOIN RP_REPORTLIST L ON l.EVENTFORMULAKEY = F.ID ' +
          ' WHERE UPPER(F.MODULE) = :module ' +
          '   AND F.NAME = :name ';
        FSQL.Params[0].AsString := Module;
        FSQL.Params[1].AsString := DS.FieldByName('NAME').AsString;
        FSQL.ExecQuery;
        if not FSQL.Eof then
          FillExistsScript(DS, FSQL)
        else
          FillScriptDS(DS);
        FSQL.Close;
      finally
        FSQL.Free;
      end;
    end;
  end
  else if Module = scrEntryModuleName then
  begin
    if cbEntry.Checked then
    begin
      FSQL := TIBSQL.Create(nil);
      try
        FSQL.Transaction := gdcBaseManager.ReadTransaction;
        FSQL.SQL.Text := ' SELECT R.DESCRIPTION AS NAME, F.NAME AS FUNCTIONNAME, F.SCRIPT, F.EDITIONDATE, F.ID ' +
          ' FROM GD_FUNCTION F ' +
          ' LEFT JOIN AC_TRRECORD R ON F.ID = R.FUNCTIONKEY ' +
          ' WHERE UPPER(F.MODULE) = :module ' +
          '   AND F.NAME = :name ';
        FSQL.Params[0].AsString := Module;
        FSQL.Params[1].AsString := DS.FieldByName('NAME').AsString;
        FSQL.ExecQuery;
        if not FSQL.Eof then
          FillExistsScript(DS, FSQL)
        else
          FillScriptDS(DS);
        FSQL.Close;
      finally
        FSQL.Free;
      end;
    end;
  end else //Если пользовательский модуль
  begin
    if cbSF.Checked then
    begin
      FSQL := TIBSQL.Create(nil);
      try
        FSQL.Transaction := gdcBaseManager.ReadTransaction;
        FSQL.SQL.Text := ' SELECT NAME, EDITIONDATE, SCRIPT, ID FROM GD_FUNCTION ' +
          ' WHERE UPPER(module) = :module ' +
          '   AND NAME = :name';
        FSQL.Params[0].AsString := Module;
        FSQL.Params[1].AsString := DS.FieldByName('NAME').AsString;
        FSQL.ExecQuery;
        if not FSQL.Eof then
        begin
        //Если в БД есть такой скрипт
          DSMacros.Insert;
          DSMacros.FieldByName('NAME').AsString := FSQL.FieldByName('NAME').AsString;
          DSMacros.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('NAME').AsString;
          DSMacros.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
          DSMacros.FieldByName('EDITIONDATE2').AsDateTime := DS.FieldByName('EDITIONDATE').AsDateTime;
          if Trim(FSQL.FieldByName('SCRIPT').AsString) <> Trim(DS.FieldByName('SCRIPT').AsString) then
            if FSQL.FieldByName('EDITIONDATE').AsDateTime > DS.FieldByName('EDITIONDATE').AsDateTime then
              DSMacros.FieldByName('RESULT').AsInteger := cn_first
            else
             DSMacros.FieldByName('RESULT').AsInteger := cn_second
          else
            DSMacros.FieldByName('RESULT').AsInteger := cn_eqv;
          DSMacros.FieldByName('MODULE').AsString := scrUnkonownModule;
          DSMacros.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
          DSMacros.FieldByName('SCRIPT').AsString := DS.FieldByName('SCRIPT').AsString;
          DSMacros.FieldByName('SORTFIELD').AsInteger := FNumber;
          DSMacros.Post;

          Inc(FNumber);
        end else
        begin
          DSMacros.Insert;
          DSMacros.FieldByName('NAME').AsString := DS.FieldByName('NAME').AsString;
          DSMacros.FieldByName('FUNCTIONNAME').AsString := DS.FieldByName('NAME').AsString;
          DSMacros.FieldByName('EDITIONDATE2').AsDateTime := DS.FieldByName('EDITIONDATE').AsDateTime;
          DSMacros.FieldByName('RESULT').AsInteger := cn_just_second;
          DSMacros.FieldByName('SCRIPT').AsString := DS.FieldByName('SCRIPT').AsString;
          DSMacros.FieldByName('MODULE').AsString := scrUnkonownModule;
          DSMacros.FieldByName('SORTFIELD').AsInteger := FNumber;
          DSMacros.Post;

          Inc(FNumber);
        end;
        FSQL.Close;
      finally
        FSQL.Free;
      end;
    end;
  end;
end;

procedure TDataBaseCompare.FillMacrosNew(DS: TClientDataSet;
  ListView: TListView);

  procedure FillRecordData(DS: TClientDataSet);
  begin
    FRecordData := TRecordData.Create;
    FRecordData.FRecordInfo.Result := DS.FieldByName('RESULT').AsInteger;
    FRecordData.FRecordInfo.Script := DS.FieldByName('SCRIPT').AsString;
    FRecordData.FRecordInfo.Module := DS.FieldByName('MODULE').AsString;
    FRecordData.FRecordInfo.ID     := DS.FieldByName('ID').AsInteger;
    FList.Add(FRecordData);
  end;

var
  ListItem: TListItem;
begin
  DS.First;
  while not DS.Eof do
  begin
    with ListView do
      begin
        case DS.FieldByName('RESULT').AsInteger of
          cn_just_second:
            begin
              if tbOnlyExtDBItems.Checked then
              begin
                FillRecordData(DS);

                ListItem := Items.Add;
                ListItem.ImageIndex := -1;
                ListItem.Data := Pointer(FRecordData);
                ListItem.Caption := '';
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add(DS.FieldByName('NAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE2').AsString);
                ListItem.SubItemImages[2] := 157;
              end;
            end;
          cn_eqv:
            begin
              if tbEquivItems.Checked then
              begin
                FillRecordData(DS);

                ListItem := Items.Add;
                ListItem.ImageIndex := -1;
                ListItem.Data := Pointer(FRecordData);
                ListItem.Caption := DS.FieldByName('NAME').AsString;
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE1').AsString);
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add(DS.FieldByName('NAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE2').AsString);
                ListItem.SubItemImages[2] := 214
              end;
            end;
          cn_first, cn_second:
            begin
              if tbDiffItems.Checked then
              begin
                FillRecordData(DS);

                ListItem := Items.Add;
                ListItem.ImageIndex := -1;
                ListItem.Data := Pointer(FRecordData);
                ListItem.Caption := DS.FieldByName('NAME').AsString;
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE1').AsString);
                ListItem.SubItems.Add('');
                ListItem.SubItems.Add(DS.FieldByName('NAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('FUNCTIONNAME').AsString);
                ListItem.SubItems.Add(DS.FieldByName('EDITIONDATE2').AsString);
                if DS.FieldByName('RESULT').AsInteger = cn_first then
                  ListItem.SubItemImages[2] := 175
                else if DS.FieldByName('RESULT').AsInteger = cn_second then
                  ListItem.SubItemImages[2] := 189;
              end;
            end;
        end;
      end;
    DS.Next;
  end;
end;

procedure TDataBaseCompare.ShowDiffs;
var
  FSQL: TIBSQL;
  ScriptComparer: Tprp_ScriptComparer;
  S, S1: String;
  DBName: String;
begin
  if lvMacros.Selected.Data <> nil then
  begin
    case TRecordData(lvMacros.Selected.Data).FRecordInfo.Result of
      cn_eqv, cn_first, cn_second:
        begin
          DBName := IBLogin.Database.DatabaseName;

          FSQL := TIBSQL.Create(nil);
          FSQL.Transaction := gdcBaseManager.ReadTransaction;
          FSQL.SQL.Text := ' SELECT SCRIPT FROM GD_FUNCTION ' +
            ' WHERE ID = :ID ';
          FSQL.Params[0].AsInteger := TRecordData(lvMacros.Selected.Data).FRecordInfo.ID;
          try
            FSQL.ExecQuery;
            S := FSQL.FieldByName('SCRIPT').AsString;
            FSQL.Close;

            S1 := TRecordData(lvMacros.Selected.Data).FRecordInfo.Script;
          finally
            FSQL.Free;
          end;
        end;
      cn_just_second:
        begin
          DBName := IBLogin.DataBase.DatabaseName;
          S1 := TRecordData(lvMacros.Selected.Data).FRecordInfo.Script;
          S := '';
        end;
    end;

    ScriptComparer := Tprp_ScriptComparer.Create(nil);
    try
      ScriptComparer.Compare(S, S1);
      ScriptComparer.LeftCaption(DBName);
      ScriptComparer.RightCaption('Файл настройки: ' + FFileName);
      ScriptComparer.ShowModal;
    finally
      ScriptComparer.Free;
    end;
  end;
end;

procedure TDataBaseCompare.FormResize(Sender: TObject);
begin
  sbDBCompare.Panels[0].Width := Width div 2 - 2;
end;

procedure TDataBaseCompare.CompareMetaData(DS: TClientDataSet;
  ListView: TListView; MetadataType: String);
var
  FSQL, FExtSQL: TIBSQL;
  FTransaction: TIBTransaction;
  S: String;
  ProcText, ExtProcText: String;
begin
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.Params.Add('read_committed');
  FTransaction.Params.Add('rec_version');
  FTransaction.Params.Add('nowait');
  FTransaction.DefaultDatabase := ibExtDataBase;
  try
    if MetadataType = cn_procedure then
      S := ' SELECT P.RDB$PROCEDURE_NAME AS RELATION_NAME, P.RDB$PROCEDURE_SOURCE, CAST(LOWER(P.RDB$PROCEDURE_NAME) AS CHAR(31)) AS LN, ' +
        ' Z.EDITIONDATE, Z.ID ' +
        ' FROM RDB$PROCEDURES P' +
        ' LEFT JOIN AT_PROCEDURES Z ON P.RDB$PROCEDURE_NAME = Z.PROCEDURENAME ' +
        ' ORDER BY 3 '
    else if MetadataType = cn_trigger then
      S := ' SELECT tr.RDB$TRIGGER_NAME AS RELATION_NAME, tr.RDB$TRIGGER_SOURCE, CAST(LOWER(tr.RDB$TRIGGER_NAME) AS CHAR(31)) AS LN, ' +
        ' Z.EDITIONDATE, Z.ID ' +
        ' FROM RDB$TRIGGERS tr ' +
        ' JOIN AT_TRIGGERS Z ON tr.RDB$TRIGGER_NAME = Z.TRIGGERNAME ' +
        ' WHERE NOT tr.RDB$TRIGGER_SOURCE IS NULL' +
        '   AND NOT tr.RDB$TRIGGER_NAME LIKE ''CHECK%''' +
        ' ORDER BY 3 '
    else if MetadataType = cn_view then
      S := ' SELECT R.RDB$RELATION_NAME AS RELATION_NAME, R.RDB$VIEW_SOURCE, CAST(LOWER(R.RDB$RELATION_NAME) AS CHAR(31)) AS LN, ' +
        ' Z.ID, Z.EDITIONDATE ' +
        ' FROM RDB$RELATIONS R ' +
        ' LEFT JOIN AT_RELATIONS Z ON Z.RELATIONNAME = R.RDB$RELATION_NAME ' +
        ' WHERE R.RDB$VIEW_SOURCE IS NOT NULL ' +
        ' ORDER BY 3 '
    else if MetadataType = cn_table then
      S := ' SELECT R.RDB$RELATION_NAME AS RELATION_NAME, CAST(LOWER(R.RDB$RELATION_NAME) AS CHAR(31)) AS LN, ' +
        ' Z.ID, Z.EDITIONDATE ' +
        ' FROM RDB$RELATIONS R ' +
        ' JOIN AT_RELATIONS Z ON Z.RELATIONNAME = R.RDB$RELATION_NAME ' +
        ' WHERE R.RDB$VIEW_SOURCE IS NULL ' +
        ' ORDER BY 2 ';

    FTransaction.StartTransaction;

    FExtSQL := TIBSQL.Create(nil);
    FExtSQL.Transaction := FTransaction;
    FExtSQL.SQL.Text := S;
    FExtSQL.ExecQuery;

    FSQL := TIBSQL.Create(nil);
    FSQL.Transaction := gdcBaseManager.ReadTransaction;
    FSQL.SQL.Text := S;
    FSQL.ExecQuery;
    try
      if (FSQL.RecordCount > 0) and (FExtSQL.RecordCount > 0) then
      begin
        while (not FSQL.Eof) or (not FExtSQL.Eof) do
        begin
          if (not FSQL.Eof) and (not FExtSQL.Eof) then
          begin
            if FSQL.FieldByName('RELATION_NAME').AsString = FExtSQL.FieldByName('RELATION_NAME').AsString then
            begin
              if MetadataType = cn_procedure then
              begin
                ProcText := 'CREATE PROCEDURE "' + FSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  GetParamsText(FSQL.FieldByName('RELATION_NAME').AsString, gdcBaseManager.Database) +  ' AS ' +
                  FSQL.FieldByName('RDB$PROCEDURE_SOURCE').AsTrimString;
                ExtProcText := 'CREATE PROCEDURE "' + FExtSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  GetParamsText(FExtSQL.FieldByName('RELATION_NAME').AsString, ibExtDataBase) +  ' AS ' +
                  FExtSQL.FieldByName('RDB$PROCEDURE_SOURCE').AsTrimString;
              end
              else if MetadataType = cn_trigger then
              begin
                ProcText := 'CREATE TRIGGER "' + FSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  FSQL.FieldByName('RDB$TRIGGER_SOURCE').AsTrimString;
                ExtProcText := 'CREATE TRIGGER "' + FExtSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  FExtSQL.FieldByName('RDB$TRIGGER_SOURCE').AsTrimString;
              end
              else if MetadataType = cn_view then
              begin
                ProcText := GetViewTextBySource(FSQL.FieldByName('RDB$VIEW_SOURCE').AsTrimString,
                  FSQL.FieldByName('RELATION_NAME').AsTrimString);
                ExtProcText := GetViewTextBySource(FExtSQL.FieldByName('RDB$VIEW_SOURCE').AsTrimString,
                  FExtSQL.FieldByName('RELATION_NAME').AsTrimString);
              end;

              DS.Insert;
              DS.FieldByName('NAME').AsString := MetadataType;
              DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('RELATION_NAME').AsString;
              if MetadataType = cn_table then
              begin
                DS.FieldByName('EDITIONDATE1').AsDateTime := GetTableEditionDate(FSQL.FieldByName('RELATION_NAME').AsString, gdcBaseManager.Database);
                DS.FieldByName('EDITIONDATE2').AsDateTime := GetTableEditionDate(FSQL.FieldByName('RELATION_NAME').AsString, ibExtDataBase);
                if DS.FieldByName('EDITIONDATE1').AsDateTime > DS.FieldByName('EDITIONDATE2').AsDateTime then
                  DS.FieldByName('RESULT').AsInteger := cn_first
                else if DS.FieldByName('EDITIONDATE1').AsDateTime < DS.FieldByName('EDITIONDATE2').AsDateTime then
                  DS.FieldByName('RESULT').AsInteger := cn_second
                else
                  DS.FieldByName('RESULT').AsInteger := cn_eqv;
              end else
              begin
                DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
                DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
                if CompareStr(ProcText, ExtProcText) <> 0 then
                  if DS.FieldByName('EDITIONDATE1').AsDateTime > DS.FieldByName('EDITIONDATE2').AsDateTime then
                    DS.FieldByName('RESULT').AsInteger := cn_first
                  else
                    DS.FieldByName('RESULT').AsInteger := cn_second
                else
                  DS.FieldByName('RESULT').AsInteger := cn_eqv;
              end;
              DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
              DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
              DS.FieldByName('SORTFIELD').AsInteger := FNumber;
              DS.Post;

              FSQL.Next;
              FExtSQL.Next;
              Inc(FNumber);
            end else if AnsiCompareStr(FSQL.FieldByName('RELATION_NAME').AsString, FExtSQL.FieldByName('RELATION_NAME').AsString) > 0 then
            begin
              //только на второй базе

              DS.Insert;
              DS.FieldByName('NAME').AsString := MetadataType;
              DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('RELATION_NAME').AsString;
              if MetadataType = cn_table then
                DS.FieldByName('EDITIONDATE2').AsDateTime := GetTableEditionDate(FExtSQL.FieldByName('RELATION_NAME').AsString,
                  ibExtDataBase)
              else
                DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
              DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
              DS.FieldByName('RESULT').AsInteger := cn_just_second;
              DS.FieldByName('SORTFIELD').AsInteger := FNumber;
              DS.Post;

              FExtSQL.Next;
              Inc(FNumber);
            end else
            begin
              //только на первой базе

              DS.Insert;
              DS.FieldByName('NAME').AsString := MetadataType;
              DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('RELATION_NAME').AsString;
              if MetadataType = cn_table then
                DS.FieldByName('EDITIONDATE1').AsDateTime := GetTableEditionDate(FSQL.FieldByName('RELATION_NAME').AsString,
                  gdcBaseManager.Database)
              else
                DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
              DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
              DS.FieldByName('RESULT').AsInteger := cn_just_first;
              DS.FieldByName('SORTFIELD').AsInteger := FNumber;
              DS.Post;

              FSQL.Next;
              Inc(FNumber);
            end;
          end else if (not FSQL.Eof) then
          begin

            DS.Insert;
            DS.FieldByName('NAME').AsString := MetadataType;
            DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('RELATION_NAME').AsString;
            if MetadataType = cn_table then
              DS.FieldByName('EDITIONDATE1').AsDateTime := GetTableEditionDate(FSQL.FieldByName('RELATION_NAME').AsString,
                gdcBaseManager.Database)
            else
              DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
            DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
            DS.FieldByName('RESULT').AsInteger := cn_just_first;
            DS.FieldByName('SORTFIELD').AsInteger := FNumber;
            DS.Post;

            FSQL.Next;
            Inc(FNumber);
          end else
          begin

            DS.Insert;
            DS.FieldByName('NAME').AsString := MetadataType;
            DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('RELATION_NAME').AsString;
            if MetadataType = cn_table then
              DS.FieldByName('EDITIONDATE2').AsDateTime := GetTableEditionDate(FExtSQL.FieldByName('RELATION_NAME').AsString,
                ibExtDataBase)
            else
              DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
            DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
            DS.FieldByName('RESULT').AsInteger := cn_just_second;
            DS.FieldByName('SORTFIELD').AsInteger := FNumber;
            DS.Post;

            FExtSQL.Next;
            Inc(FNumber);
          end;
        end;
      end else if (FSQL.RecordCount > 0) then
      begin
        while not FSQL.Eof do
        begin
          //Есть только в текущей

          DS.Insert;
          DS.FieldByName('NAME').AsString := MetadataType;
          DS.FieldByName('FUNCTIONNAME').AsString := FSQL.FieldByName('RELATION_NAME').AsString;
          if MetadataType = cn_table then
            DS.FieldByName('EDITIONDATE1').AsDateTime := GetTableEditionDate(FSQL.FieldByName('RELATION_NAME').AsString,
              gdcBaseManager.Database)
          else
            DS.FieldByName('EDITIONDATE1').AsDateTime := FSQL.FieldByName('EDITIONDATE').AsDateTime;
          DS.FieldByName('ID').AsInteger := FSQL.FieldByName('ID').AsInteger;
          DS.FieldByName('RESULT').AsInteger := cn_just_first;
          DS.FieldByName('SORTFIELD').AsInteger := FNumber;
          DS.Post;

          FSQL.Next;
          Inc(FNumber);
        end;
      end else
      begin
        while not FExtSQL.Eof do
        begin
          //Только во внешней
          DS.Insert;
          DS.FieldByName('NAME').AsString := MetadataType;
          DS.FieldByName('FUNCTIONNAME').AsString := FExtSQL.FieldByName('RELATION_NAME').AsString;
          if MetadataType = cn_table then
            DS.FieldByName('EDITIONDATE2').AsDateTime := GetTableEditionDate(FExtSQL.FieldByName('RELATION_NAME').AsString,
              ibExtDataBase)
          else
            DS.FieldByName('EDITIONDATE2').AsDateTime := FExtSQL.FieldByName('EDITIONDATE').AsDateTime;
          DS.FieldByName('EXTID').AsInteger := FExtSQL.FieldByName('ID').AsInteger;
          DS.FieldByName('RESULT').AsInteger := cn_just_second;
          DS.FieldByName('SORTFIELD').AsInteger := FNumber;
          DS.Post;

          FExtSQL.Next;
          Inc(FNumber);
        end;
      end;
      FSQL.Close;
      FExtSQL.Close;
    finally
      FExtSQL.Free;
      FSQL.Free;
    end;
  finally
    FTransaction.Free;
  end;
end;

procedure TDataBaseCompare.lvMetaDataDblClick(Sender: TObject);
var
  FSQL, FExtSQL: TIBSQL;
  ScriptComparer: Tprp_ScriptComparer;
  dlgForm: Tdlg_DataBaseCompare;
  S, S1: String;
  DBName, ExtDBName: String;
  FTransaction: TIBTransaction;
  ListView: TListView;
  Module: String;
  SQL: String;
begin
  ListView := (Sender as TListView);
  if ListView.Selected = nil then
    exit;

  if FileCompared then
  begin
//    ShowDiffs;
    exit;
  end;

  if not ExtConnected then
      ConnectToDataBase;

  if ListView.Selected.Data <> nil then
  begin
    FTransaction := TIBTransaction.Create(nil);
    FTransaction.Params.Add('read_committed');
    FTransaction.Params.Add('rec_version');
    FTransaction.Params.Add('nowait');
    FTransaction.DefaultDatabase := ibExtDataBase;

    Module := TRecordData(lvMetaData.Selected.Data).FRecordInfo.Module;

    if Module = cn_table then
    begin
      dlgForm := Tdlg_DataBaseCompare.Create(Self);
      dlgForm.InitDlg(TRecordData(lvMetaData.Selected.Data).FRecordInfo.ID,
        TRecordData(lvMetaData.Selected.Data).FRecordInfo.ExtID,
        gdcBaseManager.Database, ibExtDataBase);
      try
        dlgForm.ShowModal;
      finally
        dlgForm.Free;
      end;
      Exit;
    end;

    try
      FTransaction.StartTransaction;
      DBName := IBLogin.Database.DatabaseName;
      ExtDBName := ibExtDataBase.DatabaseName;

      if Module = cn_procedure then
        SQL := ' SELECT P.RDB$PROCEDURE_NAME AS RELATION_NAME, P.RDB$PROCEDURE_SOURCE ' +
          ' FROM AT_PROCEDURES Z ' +
          ' JOIN RDB$PROCEDURES P ON Z.PROCEDURENAME = P.RDB$PROCEDURE_NAME ' +
          ' WHERE Z.ID = :ID '
      else if Module = cn_trigger then
        SQL := ' SELECT P.RDB$TRIGGER_NAME AS RELATION_NAME, P.RDB$TRIGGER_SOURCE ' +
          ' FROM AT_TRIGGERS Z ' +
          ' JOIN RDB$TRIGGERS P ON Z.TRIGGERNAME = P.RDB$TRIGGER_NAME ' +
          ' WHERE Z.ID = :ID '
      else if Module = cn_view then
        SQL := ' SELECT R.RDB$RELATION_NAME AS RELATION_NAME, R.RDB$VIEW_SOURCE ' +
          ' FROM AT_RELATIONS Z ' +
          ' LEFT JOIN RDB$RELATIONS R ON Z.RELATIONNAME = R.RDB$RELATION_NAME ' +
          ' WHERE R.RDB$VIEW_SOURCE IS NOT NULL ' +
          '   AND Z.ID = :ID ';

      case TRecordData(lvMetaData.Selected.Data).FRecordInfo.Result of
        cn_eqv, cn_first, cn_second:
          begin
            FSQL := TIBSQL.Create(nil);
            FSQL.Transaction := gdcBaseManager.ReadTransaction;
            FSQL.SQL.Text := SQL;
            FSQL.Params[0].AsInteger := TRecordData(lvMetaData.Selected.Data).FRecordInfo.ID;

            FExtSQL := TIBSQL.Create(nil);
            FExtSQL.Transaction := FTransaction;
            FExtSQL.SQL.Text := SQL;
            FExtSQL.Params[0].AsInteger := TRecordData(lvMetaData.Selected.Data).FRecordInfo.ExtID;
            try
              FSQL.ExecQuery;
              FExtSQL.ExecQuery;

              if Module = cn_procedure then
              begin
                S := 'CREATE PROCEDURE "' + FSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  GetParamsText(FSQL.FieldByName('RELATION_NAME').AsString, gdcBaseManager.Database) +  ' AS ' +
                  FSQL.FieldByName('RDB$PROCEDURE_SOURCE').AsTrimString;

                S1 := 'CREATE PROCEDURE "' + FExtSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  GetParamsText(FExtSQL.FieldByName('RELATION_NAME').AsString, ibExtDataBase) +  ' AS ' +
                  FExtSQL.FieldByName('RDB$PROCEDURE_SOURCE').AsTrimString;
              end
              else if Module = cn_trigger then
              begin
                S := 'CREATE TRIGGER "' + FSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  FSQL.FieldByName('RDB$TRIGGER_SOURCE').AsTrimString;

                S1 := 'CREATE TRIGGER "' + FExtSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  FExtSQL.FieldByName('RDB$TRIGGER_SOURCE').AsTrimString;
              end
              else if Module = cn_view then
              begin
                S := GetViewTextBySource(FSQL.FieldByName('RDB$VIEW_SOURCE').AsTrimString,
                  FSQL.FieldByName('RELATION_NAME').AsTrimString);
                S1 := GetViewTextBySource(FExtSQL.FieldByName('RDB$VIEW_SOURCE').AsTrimString,
                  FExtSQL.FieldByName('RELATION_NAME').AsTrimString);
              end;

              FSQL.Close;
              FExtSQL.Close;
            finally
              FSQL.Free;
              FExtSQL.Free;
            end;
          end;
        cn_just_first:
          begin
            FSQL := TIBSQL.Create(nil);
            FSQL.Transaction := gdcBaseManager.ReadTransaction;
            FSQL.SQL.Text := SQL;
            FSQL.Params[0].AsInteger := TRecordData(lvMetaData.Selected.Data).FRecordInfo.ID;
            try
              FSQL.ExecQuery;
              if Module = cn_procedure then
                S := 'CREATE PROCEDURE "' + FSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  GetParamsText(FSQL.FieldByName('RELATION_NAME').AsString, gdcBaseManager.Database) +  ' AS ' +
                  FSQL.FieldByName('RDB$PROCEDURE_SOURCE').AsTrimString
              else if Module = cn_trigger then
                S := 'CREATE TRIGGER "' + FSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  FSQL.FieldByName('RDB$TRIGGER_SOURCE').AsTrimString
              else if Module = cn_view then
                s := GetViewTextBySource(FSQL.FieldByName('RDB$VIEW_SOURCE').AsTrimString,
                  FSQL.FieldByName('RELATION_NAME').AsTrimString);

              FSQL.Close;

              S1 := '';
            finally
              FSQL.Free;
            end;
          end;
        cn_just_second:
          begin
            FExtSQL := TIBSQL.Create(nil);
            FExtSQL.Transaction := FTransaction;
            FExtSQL.SQL.Text := SQL;
            FExtSQL.Params[0].AsInteger := TRecordData(lvMetaData.Selected.Data).FRecordInfo.ExtID;
            try
              FExtSQL.ExecQuery;
              if Module = cn_procedure then
                S1 := 'CREATE PROCEDURE "' + FExtSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  GetParamsText(FExtSQL.FieldByName('RELATION_NAME').AsString, ibExtDataBase) +  ' AS ' +
                  FExtSQL.FieldByName('RDB$PROCEDURE_SOURCE').AsTrimString
              else if Module = cn_trigger then
                S1 := 'CREATE TRIGGER "' + FExtSQL.FieldByName('RELATION_NAME').AsTrimString + '" ' +
                  FExtSQL.FieldByName('RDB$TRIGGER_SOURCE').AsTrimString
              else if Module = cn_view then
                S1 := GetViewTextBySource(FExtSQL.FieldByName('RDB$VIEW_SOURCE').AsTrimString,
                  FExtSQL.FieldByName('RELATION_NAME').AsTrimString);

              FExtSQL.Close;

              S := '';
            finally
              FExtSQL.Free;
            end;
          end;
      end;
    finally
      FTransaction.Free;
    end;

    ScriptComparer := Tprp_ScriptComparer.Create(nil);
    try
      ScriptComparer.Compare(S, S1);
      ScriptComparer.LeftCaption(DBName);
      ScriptComparer.RightCaption(ExtDBName);
      ScriptComparer.ShowModal;
    finally
      ScriptComparer.Free;
    end;
  end;
end;

function TDataBaseCompare.CompareStr(const S1, S2: String): Integer;
var
  HashList1, HashList2: TList;
  I : Integer;
begin
  HashList1 := TList.Create;
  HashList2 := TList.Create;
  try
    Source1.Text := S1;
    Source2.Text := S2;

    HashList1.Capacity := Source1.Count;
    HashList2.Capacity := Source2.Count;
    begin
      for I := 0 to Source1.Count - 1 do
        HashList1.Add(HashLine(Source1[I], True, True));
      for I := 0 to Source2.Count-1 do
        HashList2.Add(HashLine(Source2[I], True, True));

      Diff.Execute(PInteger(HashList1.List), PInteger(HashList2.List),
        HashList1.Count, HashList2.Count);

      Result := Diff.DiffStats.adds + Diff.DiffStats.deletes + Diff.DiffStats.modifies;
    end;
  finally
    HashList1.Free;
    HashList2.Free;
  end;
end;

function TDataBaseCompare.GetViewTextBySource(const Source,
  RelationName: String): String;
var
  i: Integer;
  S: TStringList;
begin
  S := TStringList.Create;
  try
    GetFieldsName(Source, S);
    if S.Count = 0 then
      Result := '';
    Result := Format('CREATE VIEW %s ('#13#10, [RelationName]);
    for i := 0 to S.Count - 2 do
      Result := Result + S[i] + ', ' + #13#10;
    Result := Result + S[S.Count - 1] +  #13#10 + ' )'#13#10 + ' AS ' + Source;
  finally
    S.Free;
  end;
end;

procedure TDataBaseCompare.actAddPosExecute(Sender: TObject);
var
  AClassName: String;
  Obj: TgdcBase;
begin
  if TRecordData(lvMetaData.Selected.Data).FRecordInfo.Module = cn_procedure then
    AClassName := 'TgdcStoredProc'
  else if TRecordData(lvMetaData.Selected.Data).FRecordInfo.Module = cn_trigger then
    AClassName := 'TgdcTrigger'
  else if TRecordData(lvMetaData.Selected.Data).FRecordInfo.Module = cn_view then
    AClassName := 'TgdcView'
  else if TRecordData(lvMetaData.Selected.Data).FRecordInfo.Module = cn_table then
    AClassName := 'TgdcTable'
  else
    Exit;

  Obj := CgdcBase(GetClass(AClassName)).CreateWithID(nil, gdcBaseManager.Database,
    gdcBaseManager.ReadTransaction, TRecordData(lvMetaData.Selected.Data).FRecordInfo.ID, '');
  Obj.Open;

  AddToSetting(False, '', '', Obj, nil);
end;

procedure TDataBaseCompare.actAddPosUpdate(Sender: TObject);
begin
  actAddPos.Enabled := (lvMetaData.Selected <> nil) and
    (lvMetaData.Selected.Data <> nil) and
    (TRecordData(lvMetaData.Selected.Data).FRecordInfo.Result <> cn_just_second);
end;

function TDataBaseCompare.GetTableEditionDate(const TableName: String;
  const DB: TIBDatabase): TDateTime;
var
  SQL: TIBSQL;
  Tr: TIBTransaction;
begin
  Result := 0;

  Tr := TIBTransaction.Create(nil);
  Tr.Params.Add('read_committed');
  Tr.Params.Add('rec_version');
  Tr.Params.Add('nowait');
  Tr.DefaultDatabase := DB;
  try
    Tr.StartTransaction;

    SQL := TIBSQL.Create(nil);
    SQL.Transaction := Tr;
    SQL.SQL.Text := ' SELECT R.EDITIONDATE FROM AT_RELATIONS R ' +
    ' WHERE R.RELATIONNAME = :name ' +
    ' UNION ' +
    ' SELECT F.EDITIONDATE FROM AT_RELATION_FIELDS F ' +
    ' WHERE F.RELATIONNAME = :name ' +
    ' UNION ' +
    ' SELECT T.EDITIONDATE FROM AT_TRIGGERS T ' +
    ' WHERE T.RELATIONNAME = :name ' +
    ' UNION ' +
    ' SELECT I.EDITIONDATE FROM AT_INDICES I ' +
    ' WHERE I.RELATIONNAME = :name ' +
    ' ORDER BY 1 DESC ';
    SQL.ParamByName('name').AsString := TableName;
    try
      SQL.ExecQuery;

      if not SQL.Eof then
        Result := SQL.FieldByName('EDITIONDATE').AsDateTime;

      SQL.Close;
    finally
      SQL.Free;
    end;
  finally
    Tr.Free;
  end;
end;

procedure TDataBaseCompare.FormDestroy(Sender: TObject);
begin
  if ExtConnected then
    ibExtDataBase.Close;
  FList.Free;
  Diff.Free;
  Source1.Free;
  Source2.Free;
end;

initialization
  RegisterClass(TDataBaseCompare);

finalization
  UnRegisterClass(TDataBaseCompare);
end.
