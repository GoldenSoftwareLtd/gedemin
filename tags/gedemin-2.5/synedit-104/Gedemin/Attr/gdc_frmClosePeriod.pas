unit gdc_frmClosePeriod;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Mask, xDateEdits, gdc_createable_form, gd_ClassList,
  ComCtrls, Db, IBCustomDataSet, gdcBase, gdcTree,
  gsIBLookupComboBox, TB2Item, ActnList, TB2Dock, TB2Toolbar, gdClosingPeriod;

type
  TfrmClosePeriod = class(TgdcCreateableForm)
    pcMain: TPageControl;
    pnlBottom: TPanel;
    tbsMain: TTabSheet;
    GroupBox1: TGroupBox;
    eExtDatabase: TEdit;
    lblExtDatabase: TLabel;
    btnChooseDatabase: TButton;
    eExtUser: TEdit;
    lblExtUser: TLabel;
    lblExtPassword: TLabel;
    eExtPassword: TEdit;
    lblExtServer: TLabel;
    eExtServer: TEdit;
    GroupBox2: TGroupBox;
    odExtDatabase: TOpenDialog;
    pbMain: TProgressBar;
    btnRun: TButton;
    lblCloseDate: TLabel;
    xdeCloseDate: TxDateEdit;
    pnlBottomButtons: TPanel;
    btnClose: TButton;
    lblProcess: TLabel;
    ActionList1: TActionList;
    actChooseDontDeleteDocumentType: TAction;
    actDeleteDontDeleteDocumentType: TAction;
    mOutput: TMemo;
    tbsInvCardField: TTabSheet;
    GroupBox4: TGroupBox;
    lvAllInvCardField: TListView;
    lvCheckedInvCardField: TListView;
    tbsDocumentType: TTabSheet;
    gbDocumentType: TGroupBox;
    pnlDontDeleteDocumentType: TPanel;
    lvDontDeleteDocumentType: TListView;
    TBDock1: TTBDock;
    lblDontDeleteDocumentType: TLabel;
    TBToolbar1: TTBToolbar;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem1: TTBItem;
    Panel1: TPanel;
    lvDeleteUserDocumentType: TListView;
    TBDock4: TTBDock;
    Label1: TLabel;
    TBToolbar4: TTBToolbar;
    TBItem7: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem8: TTBItem;
    cbEntryCalculate: TCheckBox;
    cbRemainsCalculate: TCheckBox;
    cbReBindDepotCards: TCheckBox;
    cbEntryClearProcess: TCheckBox;
    cbRemainsClearProcess: TCheckBox;
    cbTransferEntryBalanceProcess: TCheckBox;
    cbUserDocClearProcess: TCheckBox;
    actChooseUserDocumentToDelete: TAction;
    actDeleteUserDocumentToDelete: TAction;
    procedure FormShow(Sender: TObject);
    procedure btnChooseDatabaseClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure actChooseDontDeleteDocumentTypeExecute(Sender: TObject);
    procedure actDeleteDontDeleteDocumentTypeExecute(Sender: TObject);
    procedure lvAllInvCardFieldDblClick(Sender: TObject);
    procedure lvCheckedInvCardFieldDblClick(Sender: TObject);
    procedure actDeleteDontDeleteDocumentTypeUpdate(Sender: TObject);
    procedure actChooseUserDocumentToDeleteExecute(Sender: TObject);
    procedure actDeleteUserDocumentToDeleteExecute(Sender: TObject);
    procedure actDeleteUserDocumentToDeleteUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FGlobalStartTime: TDateTime;
    FClosingPeriodObject: TgdClosingPeriod;
    
    // Проверка правильности заполнения параметров закрытия периода
    function CheckClosePeriodParams: Boolean;
    // Передача выбранных параметров закрытия в объект
    procedure AssignClosePeriodParams(ClosingObject: TgdClosingPeriod);

    procedure SaveLogToFile;

    procedure InitialSetupForm;
    procedure InitialFillInvCardFields;
    procedure InitialFillOptions;
    procedure MoveInvCardField(FromList, ToList: TListView);
    procedure SaveSettingsToStorage;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure SetProcessText(AText: String);
    procedure ActivateControls(DoActivate: Boolean);
    function AddLogMessage(const AMessage: String; const ALineNumber: Integer = -1): Integer;

    property GlobalStartTime: TDateTime read FGlobalStartTime write FGlobalStartTime;
  end;

var                                  
  frmClosePeriod: TfrmClosePeriod;

implementation

uses
  AcctUtils, contnrs, gdcContacts, gdcClasses, Storages, IBDatabase,
  gdcBaseInterface, at_classes;

{$R *.DFM}

var
  InnerFormVariable: TfrmClosePeriod;

procedure DoBeforeClosingProcess;
begin
  if Assigned(InnerFormVariable) then
  begin
    InnerFormVariable.GlobalStartTime := Time;
    InnerFormVariable.ActivateControls(False);
    InnerFormVariable.AddLogMessage(TimeToStr(InnerFormVariable.GlobalStartTime) + ': Начат процесс закрытия периода...');
    InnerFormVariable.btnRun.Caption := 'Прервать';
  end;
end;

procedure DoAfterClosingProcess;
begin
  if Assigned(InnerFormVariable) then
  begin
    InnerFormVariable.AddLogMessage(TimeToStr(Time) + ': Закончен процесс закрытия периода');
    InnerFormVariable.ActivateControls(True);
    InnerFormVariable.btnRun.Caption := 'Выполнить';
  end;
end;

procedure DoOnClosingProcessInterruption(const AErrorMessage: String);
begin
  if Assigned(InnerFormVariable) then
  begin
    InnerFormVariable.AddLogMessage(TimeToStr(Time) + ': Критическая ошибка:'#13#10 + AErrorMessage + #13#10'Процесс закрытия прерван!');
  end;
end;

procedure DoOnProcessMessage(const APosition, AMaxPosition: Integer; const AMessage: String);
begin
  if Assigned(InnerFormVariable) then
  begin
    // Если текущий прогресс превысил максималный, увеличим максимальный
    if (APosition >= 0) and (InnerFormVariable.pbMain.Position <> APosition) then
      InnerFormVariable.pbMain.Position := APosition;
    if (AMaxPosition >= 0) and (InnerFormVariable.pbMain.Max <> AMaxPosition) then
      InnerFormVariable.pbMain.Max := AMaxPosition;

    if APosition > InnerFormVariable.pbMain.Max then
      InnerFormVariable.pbMain.Max := APosition * 2;

    // лейбл под прогресс баром  
    InnerFormVariable.lblProcess.Caption :=
      IntToStr(InnerFormVariable.pbMain.Position) + ' / ' + IntToStr(InnerFormVariable.pbMain.Max);
      
    if AMessage <> '' then
      InnerFormVariable.AddLogMessage(TimeToStr(Time) + ': ' + AMessage);
  end;
end;

{ TfrmCalculateBalance }

constructor TfrmClosePeriod.Create(AnOwner: TComponent);
begin
  inherited;
  InnerFormVariable := Self;
end;

destructor TfrmClosePeriod.Destroy;
begin
  InnerFormVariable := nil;
  inherited;
end;

class function TfrmClosePeriod.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmClosePeriod) then
    frmClosePeriod := TfrmClosePeriod.Create(AnOwner);
  Result := frmClosePeriod;
end;

procedure TfrmClosePeriod.SetProcessText(AText: String);
begin
  lblProcess.Caption := AText;
  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure TfrmClosePeriod.FormShow(Sender: TObject);
begin
  pcMain.ActivePage := tbsMain;
  eExtDatabase.Text := '';
  eExtServer.Text := 'localhost';
  eExtUser.Text := 'SYSDBA';
  eExtPassword.Text := 'masterkey';

  // Заполним список полей складской карточки
  InitialSetupForm;
end;

procedure TfrmClosePeriod.btnChooseDatabaseClick(Sender: TObject);
begin
  if odExtDatabase.Execute then
    eExtDatabase.Text := odExtDatabase.Filename;
end;

procedure TfrmClosePeriod.btnRunClick(Sender: TObject);
begin
  if not FClosingPeriodObject.InProcess then
  begin
    // Проверим правильность заполнения параметров 'закрытия периода'
    if CheckClosePeriodParams then
    begin
      // Передадим параметры 'закрытия периода'
      AssignClosePeriodParams(FClosingPeriodObject);
      // Запустим закрытие периода
      FClosingPeriodObject.DoClosePeriod;
    end;
  end
  else
  begin
    FClosingPeriodObject.StopProcess;
  end;
end;

procedure TfrmClosePeriod.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
  SaveSettingsToStorage;
end;

procedure TfrmClosePeriod.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmClosePeriod.ActivateControls(DoActivate: Boolean);
begin
  //btnRun.Enabled := DoActivate;
  btnClose.Enabled := DoActivate;
  btnChooseDatabase.Enabled := DoActivate;

  cbEntryCalculate.Enabled := DoActivate;
  cbRemainsCalculate.Enabled := DoActivate;
  cbReBindDepotCards.Enabled := DoActivate;
  cbEntryClearProcess.Enabled := DoActivate;
  cbRemainsClearProcess.Enabled := DoActivate;
  cbUserDocClearProcess.Enabled := DoActivate;
  cbTransferEntryBalanceProcess.Enabled := DoActivate;
end;

procedure TfrmClosePeriod.actChooseDontDeleteDocumentTypeExecute(Sender: TObject);
var
  gdcDocumentType: TgdcDocumentType;
  I: Integer;
  Item: TListItem;
  A: OleVariant;
begin
  gdcDocumentType := TgdcDocumentType.Create(Self);
  try
    gdcDocumentType.Transaction := gdcBaseManager.ReadTransaction;
    gdcDocumentType.ExtraConditions.Add('classname = ''TgdcInvDocumentType''');
    gdcDocumentType.Open;

    for I := 0 to lvDontDeleteDocumentType.Items.Count - 1 do
    begin
      gdcDocumentType.SelectedID.Add(Integer(lvDontDeleteDocumentType.Items.Item[I].Data));
    end;

    if gdcDocumentType.ChooseItems(A) then
    begin
      gdcDocumentType.Close;
      gdcDocumentType.SubSet := 'OnlySelected';
      gdcDocumentType.Open;
      gdcDocumentType.First;

      lvDontDeleteDocumentType.Items.Clear;

      while not gdcDocumentType.Eof do
      begin
        Item := lvDontDeleteDocumentType.Items.Add;
        Item.Caption := gdcDocumentType.FieldByName('NAME').AsString;
        Item.Data := Pointer(gdcDocumentType.FieldByName('ID').AsInteger);

        gdcDocumentType.Next;
      end;
    end;
  finally
    gdcDocumentType.Free;
  end;
end;

procedure TfrmClosePeriod.actDeleteDontDeleteDocumentTypeExecute(Sender: TObject);
var
  I: Integer;
begin
  if lvDontDeleteDocumentType.SelCount > 0 then
  begin
    if lvDontDeleteDocumentType.SelCount = 1 then
    begin
      lvDontDeleteDocumentType.Items.Item[lvDontDeleteDocumentType.Selected.Index].Delete;
    end
    else
    begin
      I := 0;
      while I < lvDontDeleteDocumentType.Items.Count do
      begin
        if lvDontDeleteDocumentType.Items[I].Selected then
          lvDontDeleteDocumentType.Items.Item[I].Delete
        else
          Inc(I);
      end;
    end;
  end;
end;

procedure TfrmClosePeriod.actDeleteDontDeleteDocumentTypeUpdate(Sender: TObject);
begin
  actDeleteDontDeleteDocumentType.Enabled := (lvDontDeleteDocumentType.Items.Count > 0);
end;

procedure TfrmClosePeriod.actChooseUserDocumentToDeleteExecute(Sender: TObject);
var
  gdcDocumentType: TgdcDocumentType;
  I: Integer;
  Item: TListItem;
  A: OleVariant;
begin
  gdcDocumentType := TgdcDocumentType.Create(Self);
  try
    gdcDocumentType.Transaction := gdcBaseManager.ReadTransaction;
    gdcDocumentType.ExtraConditions.Add('classname = ''TgdcUserDocumentType''');
    gdcDocumentType.Open;

    for I := 0 to lvDontDeleteDocumentType.Items.Count - 1 do
    begin
      gdcDocumentType.SelectedID.Add(Integer(lvDeleteUserDocumentType.Items.Item[I].Data));
    end;

    if gdcDocumentType.ChooseItems(A) then
    begin
      gdcDocumentType.Close;
      gdcDocumentType.SubSet := 'OnlySelected';
      gdcDocumentType.Open;
      gdcDocumentType.First;

      lvDeleteUserDocumentType.Items.Clear;

      while not gdcDocumentType.Eof do
      begin
        Item := lvDeleteUserDocumentType.Items.Add;
        Item.Caption := gdcDocumentType.FieldByName('NAME').AsString;
        Item.Data := Pointer(gdcDocumentType.FieldByName('ID').AsInteger);

        gdcDocumentType.Next;
      end;
    end;
  finally
    gdcDocumentType.Free;
  end;
end;

procedure TfrmClosePeriod.actDeleteUserDocumentToDeleteExecute(Sender: TObject);
var
  I: Integer;
begin
  if lvDeleteUserDocumentType.SelCount > 0 then
  begin
    if lvDeleteUserDocumentType.SelCount = 1 then
    begin
      lvDeleteUserDocumentType.Items.Item[lvDeleteUserDocumentType.Selected.Index].Delete;
    end
    else
    begin
      I := 0;
      while I < lvDeleteUserDocumentType.Items.Count do
      begin
        if lvDeleteUserDocumentType.Items[I].Selected then
          lvDeleteUserDocumentType.Items.Item[I].Delete
        else
          Inc(I);
      end;
    end;
  end;
end;

procedure TfrmClosePeriod.actDeleteUserDocumentToDeleteUpdate(Sender: TObject);
begin
  actDeleteUserDocumentToDelete.Enabled := (lvDeleteUserDocumentType.Items.Count > 0);
end;

procedure TfrmClosePeriod.InitialFillInvCardFields;
var
  INV_CARD: TatRelation;
  FieldCounter: Integer;
  Item: TListItem;
  SelectedFieldIndex: Integer;
  FeatureList: TStringList;
begin
  INV_CARD := atDatabase.Relations.ByRelationName('INV_CARD');

  FeatureList := TStringList.Create;
  try
    // Считаем выбранные ранее признаки складской карточки из хранилища
    if Assigned(GlobalStorage) then
      FeatureList.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'InvFeatureList', '')
    else
      FeatureList.Clear;

    // Заполним список полей-признаков складской карточки
    for FieldCounter := 0 to INV_CARD.RelationFields.Count - 1 do
    begin
      if INV_CARD.RelationFields.Items[FieldCounter].IsUserDefined
         and (AnsiCompareStr(INV_CARD.RelationFields.Items[FieldCounter].FieldName, 'USR$INV_ADDLINEKEY') <> 0)
         and (AnsiCompareStr(INV_CARD.RelationFields.Items[FieldCounter].FieldName, 'USR$INV_MOVEDOCKEY') <> 0) then
      begin
        // Если ранее этот признак уже выбирали, то вставим его в список выбранных
        SelectedFieldIndex := FeatureList.IndexOf(INV_CARD.RelationFields[FieldCounter].FieldName);
        if SelectedFieldIndex > -1 then
          Item := lvCheckedInvCardField.Items.Add
        else
          Item := lvAllInvCardField.Items.Add;

        // Если указано локализованное имя поля, будем использовать его
        if INV_CARD.RelationFields[FieldCounter].LName > '' then
          Item.Caption := Trim(INV_CARD.RelationFields[FieldCounter].LName)
        else
          Item.Caption := Trim(INV_CARD.RelationFields[FieldCounter].FieldName);

        Item.Data := INV_CARD.RelationFields[FieldCounter];
      end;
    end;
  finally
    FeatureList.Free;
  end;
end;

procedure TfrmClosePeriod.MoveInvCardField(FromList, ToList: TListView);
var
  Item: TListItem;
  Index: Integer;
begin
  if Assigned(FromList.Selected) then
  begin
    Item := ToList.Items.Add;
    Item.Caption := FromList.Selected.Caption;
    Item.Data := FromList.Selected.Data;

    Index := FromList.Selected.Index;
    FromList.Selected.Delete;

    if Index < FromList.Items.Count then
      FromList.Selected := FromList.Items[Index] else
    if FromList.Items.Count > 0 then
      FromList.Selected := FromList.Items[FromList.Items.Count - 1];
  end;
end;

procedure TfrmClosePeriod.lvAllInvCardFieldDblClick(Sender: TObject);
begin
  MoveInvCardField(lvAllInvCardField, lvCheckedInvCardField);
end;

procedure TfrmClosePeriod.lvCheckedInvCardFieldDblClick(Sender: TObject);
begin
  MoveInvCardField(lvCheckedInvCardField, lvAllInvCardField);
end;

procedure TfrmClosePeriod.InitialSetupForm;
begin
  // Заполним список полей складской карточки
  InitialFillInvCardFields;
  InitialFillOptions;
end;

procedure TfrmClosePeriod.InitialFillOptions;
var
  DefaultDate: TDateTime;
begin
  DefaultDate := EncodeDate(2009, 1, 1);
  if Assigned(GlobalStorage) then
  begin
    // Попробуем считать дату закрытия из хранилища
    xdeCloseDate.Date := GlobalStorage.ReadDateTime('Options\InvClosePeriod', 'CloseDate', DefaultDate);
    // Считаем данные 'закрываемой' базы из хранилища
    eExtDatabase.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'ExternalDatabase', '');
    eExtUser.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'ExternalUser', '');
    eExtServer.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'ExternalServer', '');
    eExtPassword.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'ExternalPassword', '');
  end
  else
  begin
    xdeCloseDate.Date := DefaultDate;
    eExtDatabase.Text := '';
    eExtUser.Text := '';
    eExtServer.Text := '';
    eExtPassword.Text := '';
  end;
end;

procedure TfrmClosePeriod.SaveSettingsToStorage;
var
  FeatureList: TStringList;
  ListElementCounter: Integer;
begin
  if Assigned(GlobalStorage) then
  begin
    GlobalStorage.WriteDateTime('Options\InvClosePeriod', 'CloseDate', xdeCloseDate.Date);
    GlobalStorage.WriteString('Options\InvClosePeriod', 'ExternalDatabase', eExtDatabase.Text);
    GlobalStorage.WriteString('Options\InvClosePeriod', 'ExternalUser', eExtUser.Text);
    GlobalStorage.WriteString('Options\InvClosePeriod', 'ExternalServer', eExtServer.Text);
    GlobalStorage.WriteString('Options\InvClosePeriod', 'ExternalPassword', eExtPassword.Text);

    // Сохраним выбранные складские признаки
    FeatureList := TStringList.Create;
    try
      for ListElementCounter := 0 to lvCheckedInvCardField.Items.Count - 1 do
        FeatureList.Add(TatRelationField(lvCheckedInvCardField.Items[ListElementCounter].Data).FieldName);
      GlobalStorage.WriteString('Options\InvClosePeriod', 'InvFeatureList', FeatureList.Text);
    finally
      FeatureList.Free;
    end;
  end;
end;

function TfrmClosePeriod.AddLogMessage(const AMessage: String; const ALineNumber: Integer = -1): Integer;
begin
  if ALineNumber > 0 then
  begin
    Result := ALineNumber;
    mOutput.Lines.Strings[ALineNumber] := AMessage;
  end
  else
    Result := mOutput.Lines.Add(AMessage);
end;

procedure TfrmClosePeriod.SaveLogToFile;
var
  SD: TSaveDialog;
begin
  SD := TSaveDialog.Create(Self);
  try
    SD.Title := 'Сохранить лог в файл ';
    SD.DefaultExt := 'txt';
    SD.Filter := 'Текстовые файлы (*.txt)|*.TXT|' +
      'Все файлы (*.*)|*.*';
    SD.FileName := 'close_log';
    if SD.Execute then
      mOutput.Lines.SaveToFile(SD.FileName);
  finally
    SD.Free;
  end;
end;

function TfrmClosePeriod.CheckClosePeriodParams: Boolean;
begin
  Result := True;
end;

procedure TfrmClosePeriod.AssignClosePeriodParams(ClosingObject: TgdClosingPeriod);
var
  ListElementCounter: Integer;
begin
  ClosingObject.SetClosingDatabaseParams(eExtDatabase.Text, eExtServer.Text, eExtUser.Text, eExtPassword.Text);
  ClosingObject.CloseDate := xdeCloseDate.Date;

  ClosingObject.DoCalculateEntryBalance := cbEntryCalculate.Checked;
  ClosingObject.DoCalculateRemains := cbRemainsCalculate.Checked;
  ClosingObject.DoReBindDepotCards := cbReBindDepotCards.Checked;
  ClosingObject.DoDeleteEntry := cbEntryClearProcess.Checked;
  ClosingObject.DoDeleteDocuments := cbRemainsClearProcess.Checked;
  ClosingObject.DoDeleteUserDocuments := cbUserDocClearProcess.Checked;
  ClosingObject.DoTransferEntryBalance := cbTransferEntryBalanceProcess.Checked;

  // Заполним список типов складских документов, которые нельзя удалять
  ClosingObject.ClearDontDeleteDocumentTypes;
  for ListElementCounter := 0 to lvDontDeleteDocumentType.Items.Count - 1 do
    ClosingObject.AddDontDeleteDocumentType(Integer(lvDontDeleteDocumentType.Items[ListElementCounter].Data));
  // Заполним список типов пользовательских документов, которые нужно удалить
  ClosingObject.ClearUserDocumentTypesToDelete;
  for ListElementCounter := 0 to lvDeleteUserDocumentType.Items.Count - 1 do
    ClosingObject.AddUserDocumentTypeToDelete(Integer(lvDeleteUserDocumentType.Items[ListElementCounter].Data));
  // Заполним список полей-признаков складской карточки из настроек
  ClosingObject.ClearInvCardFeatures;
  for ListElementCounter := 0 to lvCheckedInvCardField.Items.Count - 1 do
    ClosingObject.AddInvCardFeature(TatRelationField(lvCheckedInvCardField.Items[ListElementCounter].Data).FieldName);
end;

procedure TfrmClosePeriod.FormCreate(Sender: TObject);
begin
  FClosingPeriodObject := TgdClosingPeriod.Create;
  FClosingPeriodObject.OnBeforeProcessRoutine := DoBeforeClosingProcess;
  FClosingPeriodObject.OnAfterProcessRoutine := DoAfterClosingProcess;
  FClosingPeriodObject.OnProcessInterruptionRoutine := DoOnClosingProcessInterruption;
  FClosingPeriodObject.OnProcessMessageRoutine := DoOnProcessMessage;
end;

procedure TfrmClosePeriod.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FClosingPeriodObject);
end;

initialization
  RegisterClass(TfrmClosePeriod);
finalization
  UnRegisterClass(TfrmClosePeriod);

end.
