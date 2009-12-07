unit gsReportRegistry;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, DB, Menus, {xReport, }flt_sqlFilter, Contnrs, IBSQL, xfReport,
  Printers;

type
  TMenuType = (mtSubMenu, mtSeparator);

  TOnBeforePrint = procedure(Sender: TObject; isRegistry, isQuick: Boolean) of object;

  TgsReportRegistry = class(TComponent)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FDataSource: TDataSource;
    FVariableList: TStringList;
    FPopupMenu: TPopupMenu;
    FQueryFilter: TgsQueryFilter;
    FMenuType: TMenuType;
    FCaption: String;
    FGroupID: Integer;
    FComponentList: TComponentList;
    FOnBeforePrint: TOnBeforePrint;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetDataSource(Value: TDataSource);
    procedure SetVariableList(Value: TStringList);
    procedure SetPopupMenu(Value: TPopupMenu);
    procedure SetQueryFilter(Value: TgsQueryFilter);

    // Вызов списка отчетов
    procedure DoOnReportListClick(Sender: TObject);
    // Печать отчета. OnClick - в PopupMenu
    procedure DoOnReportClick(Sender: TObject);
    // Печать отчета
    procedure PrintReport(const ID: Integer);
    // Список печатных форм
    procedure RegistryList;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // Формирование списка меню
    procedure MakeMenu;

  published
    property DataBase: TIBDataBase read FDataBase write SetDataBase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property VariableList: TStringList read FVariableList write SetVariableList;
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
    property QueryFilter: TgsQueryFilter read FQueryFilter write SetQueryFilter;
    property MenuType: TMenuType read FMenuType write FMenuType;
    property Caption: String read FCaption write FCaption;
    property GroupID: Integer read FGroupID write FGroupID;

    property OnBeforePrint: TOnBeforePrint read FOnBeforePrint write FOnBeforePrint;
  end;

procedure Register;

implementation

uses
  rp_frmRegistryForm_unit,
  msg_attachment,
  gd_resourcestring,
  gd_dlgCountCopy_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  def_caption = 'Печать реестра';
  def_registrylist = 'Список форм ...';

constructor TgsReportRegistry.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FVariableList := TStringList.Create;
  FMenuType := mtSubMenu;
  FCaption := def_caption;
  FComponentList := TComponentList.Create;
  FOnBeforePrint := nil;
end;

destructor TgsReportRegistry.Destroy;
begin
  FVariableList.Free;
  FComponentList.Free;
  inherited Destroy;
end;

// Вызов списка отчетов
procedure TgsReportRegistry.DoOnReportListClick(Sender: TObject);
begin
  RegistryList;
end;

// Выбор отчета для печати
procedure TgsReportRegistry.DoOnReportClick(Sender: TObject);
begin
  PrintReport((Sender as TMenuItem).Tag);
end;

// Формирование меню
procedure TgsReportRegistry.MakeMenu;
var
  IBSQL: TIBSQL;
  MenuItem: TMenuItem;
  SubMenu: TMenuItem;

  // Добавляем элемент в меню
  function AddItem(Group: TMenuItem; S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := S;
    Group.Add(Result);
  end;

begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');
  if FPopupMenu <> nil then
  begin
    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    FComponentList.Clear;
    IBSQL := TIBSQL.Create(Self);
    try
      IBSQL.Database := FDataBase;
      IBSQL.Transaction := FTransaction;

      if FMenuType = mtSubMenu then
      begin
        SubMenu := AddItem(FPopupMenu.Items, FCaption);
        FComponentList.Add(SubMenu);
      end
      else
      begin
        if FPopupMenu.Items.Count <> 0 then
        begin
          MenuItem := AddItem(FPopupMenu.Items, '-');
          FComponentList.Add(MenuItem);
        end;
        SubMenu := FPopupMenu.Items;
      end;

      MenuItem := AddItem(SubMenu, def_registrylist);
      FComponentList.Add(MenuItem);
      MenuItem.OnClick := DoOnReportListClick;

      IBSQL.SQL.Text := Format(
        'SELECT id, name FROM rp_registry r WHERE r.parent = %d ', [FGroupID]);
      IBSQL.ExecQuery;

      while not IBSQL.Eof do
      begin
        MenuItem := AddItem(SubMenu, IBSQL.FieldByName('Name').AsString);
        FComponentList.Add(MenuItem);
        MenuItem.Tag := IBSQL.FieldByName('ID').AsInteger;
        MenuItem.OnClick := DoOnReportClick;

        IBSQL.Next;
      end;
    finally
      IBSQL.Free;
    end;
  end;
end;

procedure PassThroughFile(const FileName: String);
type
  PR = ^TR;
  TR = record
    Size: Word;
    Data: array[0..0] of Char;
  end;

var
  F: File;
  P: PR;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  try
    GetMem(P, FileSize(F) + SizeOf(Word));
    try
      P^.Size := FileSize(F);
      BlockRead(F, P^.Data, P^.Size);
      AnsiToOemBuff(@(P^.Data), @(P^.Data), P^.Size);

      Printer.BeginDoc;
      Escape(Printer.Handle, PASSTHROUGH, 0, Pointer(P), nil);
      Printer.EndDoc;
    finally
      FreeMem(P, P^.Size + SizeOf(Word));
    end;
  finally
    CloseFile(F);
  end;
end;

procedure TgsReportRegistry.PrintReport(const ID: Integer);
var
  IBSQL: TIBSQL;
  I, QCopy: Integer;
  FastReport: TxFastReport;
  Temp, Temp1: array[0..255] of Char;
  OutputFileName, OldCurrencyString: String;
//  FileName: String;
//  NameRTFChar, Path: array [0..255] of Char;

begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');

  OldCurrencyString := CurrencyString;
  CurrencyString := '';
  IBSQL := TIBSQL.Create(Self);
  try
    IBSQL.Database := FDataBase;
    IBSQL.Transaction := FTransaction;

    IBSQL.SQL.Text := Format('SELECT * FROM rp_registry WHERE ID = %d',
      [ID]);
    IBSQL.ExecQuery;
    if IBSQL.RecordCount = 0 then
      MessageBox(Application.Handle,
        'Такой записи не существует.',
        PChar(sAttention),
        MB_OK or MB_ICONHAND)
    else
    begin
      FVariableList.Clear;
      if Assigned(FOnBeforePrint) then
        FOnBeforePrint(Self, ibsql.FieldByName('isregistry').AsInteger = 1,
          ibsql.FieldByName('isquick').AsInteger = 1);

      if ibsql.FieldByName('isquick').AsInteger = 0 then
      begin
{        with TfrmPrintReport.Create(Self) do
        try
          Caption := IBSQL.FieldByName('name').AsString;

          if not IBSQL.FieldByName('FileName').IsNull then
          begin
            Caption := Caption + ' Шаблон: ' + IBSQL.FieldByName('filename').AsString;
            if Pos('\', IBSQL.FieldByName('filename').AsString) > 0 then
              xReport.FormFile := IBSQL.FieldByName('filename').AsString
            else
              xReport.FormFile := ExtractFilePath(Application.ExeName) + 'RTF\' +
                 IBSQL.FieldByName('filename').AsString
          end
          else
          begin
            GetTempPath(SizeOf(Path), Path);
            GetTempFileName(Path, 'rtf', 0, NameRTFChar);

            FileName := StrPas(NameRTFChar);
            FileName := Copy(FileName, 0, Length(FileName) - 3);
            FileName := FileName + 'rtf';

            attSaveToFile(FileName, IBSQL.FieldByName('Template').AsString);
            xReport.FormFile := FileName;
          end;

          xReport.Vars.Assign(FVariableList);

          if (DataSource <> nil) then
          begin
            if IBSQL.FieldByName('ISREGISTRY').AsInteger = 1 then
              dsReport.DataSet := FDataSource.DataSet
            else
              xReport.DataSources.Clear;

            for I := 0 to FDataSource.DataSet.FieldCount - 1 do
              xReport.Vars.Add('u' + FDataSource.DataSet.Fields[I].FieldName + '=' +
                FDataSource.DataSet.Fields[I].AsString);
          end;

          xReport.Execute;
          ShowModal;

          if IBSQL.FieldByName('FileName').IsNull and
            EditTemplate then
          begin
            IBSQL.Close;
            IBSQL.SQL.Text := 'UPDATE rp_registry SET TEMPLATE = :TEMPLATE WHERE ' +
              ' ID = :ID';
            IBSQL.Prepare;
            IBSQL.ParamByName('Template').AsString :=
              attLoadFromFile(FileName);
            IBSQL.ParamByName('ID').AsInteger := ID;
            IBSQL.ExecQuery;
          end;
        finally
          Free;
        end;}
      end
      else
      begin
        FastReport := TxFastReport.Create(Self);
        try
          FastReport.DataSource := FDataSource;
          if ibsql.FieldByName('isPrintPreview').AsInteger = 1 then
            FastReport.Options := [frShowPreview]
          else
            FastReport.Options := [];
          FastReport.LinesOnPage := 160;
          if Pos('\', IBSQL.FieldByName('filename').AsString) > 0 then
            FastReport.FormFile := IBSQL.FieldByName('filename').AsString
          else
            FastReport.FormFile := ExtractFilePath(Application.ExeName) + 'RTF\' +
               IBSQL.FieldByName('filename').AsString;
          FastReport.Vars.Assign(FVariableList);
          FastReport.Vars.Add('compressedOn = '#15);
          FastReport.Vars.Add('printerinit = '#27#64);
          GetTempPath(255, Temp1);
          GetTempFileName(Temp1, 'bel', 0, Temp);
          OutputFileName := StrPas(Temp);
          DeleteFile(OutputFileName);
          FastReport.OutputFile := OutputFileName;
          FastReport.Execute;

          if FileExists(OutputFileName) then
          begin
            QCopy := 0;
            with Tgd_dlgCountCopy.Create(Self) do
              try
                if ShowModal = mrOk then
                  QCopy := CountCopy;
              finally
              end;

            for i:= 1 to QCopy do
              PassThroughFile(OutputFileName);
            DeleteFile(OutputFileName);
          end;

        finally
          FastReport.Free;
        end;
      end;
    end;
  finally
    IBSQL.Free;
  end;
  CurrencyString := OldCurrencyString;
end;

procedure TgsReportRegistry.RegistryList;
begin
  with TfrmRegistryForm.Create(Self) do
  try
    ShowForm(FGroupID);
    MakeMenu;
  finally
    Free;
  end;
end;

procedure TgsReportRegistry.SetDataSource(Value: TDataSource);
begin
  if FDataSource <> Value then
  begin
    if FDataSource <> nil then
      FDataSource.RemoveFreeNotification(Self);
    FDataSource := Value;
    if FDataSource <> nil then
      FDataSource.FreeNotification(Self);
  end;
end;

procedure TgsReportRegistry.SetQueryFilter(Value: TgsQueryFilter);
begin
  if FQueryFilter <> Value then
  begin
    if FQueryFilter <> nil then FQueryFilter.RemoveFreeNotification(Self);
    FQueryFilter := Value;
    if FQueryFilter <> nil then FQueryFilter.FreeNotification(Self);
  end;
end;

procedure TgsReportRegistry.SetPopupMenu(Value: TPopupMenu);
begin
  if FPopupMenu <> Value then
  begin
    if FPopupMenu <> nil then FPopupMenu.RemoveFreeNotification(Self);
    FPopupMenu := Value;
    if FPopupMenu <> nil then FPopupMenu.FreeNotification(Self);
  end;

  if not (csDesigning in ComponentState) then
    FComponentList.Clear;
end;

procedure TgsReportRegistry.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then FDatabase.FreeNotification(Self);
  end;
end;

procedure TgsReportRegistry.SetVariableList(Value: TStringList);
begin
  if Value <> nil then
    FVariableList.Assign(Value);
end;

procedure TgsReportRegistry.SetTransaction(const Value: TIBTransaction);
begin
  if FTransaction <> Value then
  begin
    if FTransaction <> nil then FTransaction.RemoveFreeNotification(Self);
    FTransaction := Value;
    if FTransaction <> nil then FTransaction.FreeNotification(Self);
  end;
end;

procedure TgsReportRegistry.Loaded; 
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) then
    MakeMenu;
end;

procedure TgsReportRegistry.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = FDatabase then
      FDatabase := nil;

    if AComponent = FTransaction then
      FTransaction := nil;

    if AComponent = FDataSource then
      FDataSource := nil;

    if AComponent = FQueryFilter then
      FQueryFilter := nil;

    if AComponent = FPopupMenu then
      FPopupMenu := nil;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsReportRegistry]);
end;

end.
