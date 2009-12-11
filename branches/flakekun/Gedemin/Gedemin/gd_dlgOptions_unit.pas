
unit gd_dlgOptions_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, StdCtrls, ActnList, ComCtrls, Mask, xDateEdits,
  ExtCtrls, Spin, gsIBLookupComboBox, gdcBase;

type
  Tgd_dlgOptions = class(TCreateableForm)
    PageControl1: TPageControl;
    Button1: TButton;
    Button2: TButton;
    ActionList: TActionList;
    TabSheet1: TTabSheet;
    actOk: TAction;
    actCancel: TAction;
    Button3: TButton;
    actHelp: TAction;
    chbxEnterAsTab: TCheckBox;
    chbxMagic: TCheckBox;
    chbxAutoSaveDesktop: TCheckBox;
    chbxDialogDefaults: TCheckBox;
    tsAudit: TTabSheet;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    Button4: TButton;
    actUsers: TAction;
    GroupBox2: TGroupBox;
    Memo2: TMemo;
    Button5: TButton;
    actJournal: TAction;
    cbLanguage: TComboBox;
    Label1: TLabel;
    chbxCheckAccount: TCheckBox;
    chbxProhibitDuplicates: TCheckBox;
    chbxCheckUNN: TCheckBox;
    chbxCheckName: TCheckBox;
    chbxHideMaster: TCheckBox;
    chbxShowZero: TCheckBox;
    seDateWindow: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    tsPolicy: TTabSheet;
    lvPolicy: TListView;
    Panel1: TPanel;
    Button6: TButton;
    Button7: TButton;
    actPolDefault: TAction;
    actPolChange: TAction;
    Label5: TLabel;
    cbSaveDT: TComboBox;
    chbxHintInGrid: TCheckBox;
    gbBlock: TGroupBox;
    chbxBlock: TCheckBox;
    lblBlock: TLabel;
    xdeBlock: TxDateEdit;
    chbxAllowAudit: TCheckBox;
    mGroupsLabel: TMemo;
    chbxMultipleConnect: TCheckBox;
    chbxEditWarn: TCheckBox;
    chbxByLBRB: TCheckBox;
    tsBackup: TTabSheet;
    gbArch2: TGroupBox;
    rbArchOneFile: TRadioButton;
    rbArchMultipleFiles: TRadioButton;
    Label7: TLabel;
    edArchFileName: TEdit;
    gbArch3: TGroupBox;
    rbArchAny: TRadioButton;
    rbArchSelected: TRadioButton;
    Label8: TLabel;
    gbArch1: TGroupBox;
    chbxArchOn: TCheckBox;
    Label6: TLabel;
    edArchPath: TEdit;
    Label9: TLabel;
    gbArch4: TGroupBox;
    chbxArchCopy: TCheckBox;
    edArchLogin: TEdit;
    Label10: TLabel;
    seArchInterval: TSpinEdit;
    Button8: TButton;
    Button9: TButton;
    chbxWarnMDMism: TCheckBox;
    Label11: TLabel;
    xedArchDate: TxDateEdit;
    chbxFilterParams: TCheckBox;
    chbxCorrectWindowSize: TCheckBox;
    mGroups: TMemo;
    btnGroups: TButton;
    actAddBlockGroup: TAction;
    Label12: TLabel;
    cbDontUseGoodKey: TCheckBox;
    TabSheet2: TTabSheet;
    gbConfirmations: TGroupBox;
    chbxEditMultipleConfirmation: TCheckBox;
    chbxOtherConfirmations: TCheckBox;
    chbxFormConfirmations: TCheckBox;
    chbxBlockRecord: TCheckBox;
    mDocumentTypes: TMemo;
    btnDocumentTypes: TButton;
    actAddBlockDT: TAction;
    mDocumentTypesLabel: TMemo;
    cbUseDelMovement: TCheckBox;              
    chbxAutoCreate: TCheckBox;
    chbxDelSilent: TCheckBox;
    actClearRPLRecords: TAction;
    actCreateDatabaseFile: TAction;
    Button10: TButton;
    actBlock: TAction;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actUsersExecute(Sender: TObject);
    procedure actJournalExecute(Sender: TObject);
    procedure chbxBlockClick(Sender: TObject);
    procedure actPolChangeExecute(Sender: TObject);
    procedure actPolChangeUpdate(Sender: TObject);
    procedure actPolDefaultUpdate(Sender: TObject);
    procedure actPolDefaultExecute(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure actAddBlockGroupExecute(Sender: TObject);
    procedure actAddBlockGroupUpdate(Sender: TObject);
    procedure actAddBlockDTUpdate(Sender: TObject);
    procedure actAddBlockDTExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actBlockUpdate(Sender: TObject);
    procedure actBlockExecute(Sender: TObject);
  private
    BlockedDataBase: Boolean;

    function GetExcludedDocumentTypes(const Obj: TgdcBase = nil): String;
  end;

var
  gd_dlgOptions: Tgd_dlgOptions;

implementation

{$R *.DFM}

uses
  Storages, gd_security, gdcUser, gdcJournal, IBDatabase, IBSQL,
  gdcBaseInterface, gd_KeyAssoc, gdcClasses, IB, ComObj, at_classes,
  gdcBlockRule, gdHelp_Interface;

const
  IBDateDelta = 15018;              // Days between Delphi and InterBase dates

procedure Tgd_dlgOptions.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgd_dlgOptions.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgd_dlgOptions.FormCreate(Sender: TObject);
var
  q: TIBSQL;
  LI: TListItem;
begin
  tsAudit.TabVisible := IBLogin.IsUserAdmin;
  tsPolicy.TabVisible := IBLogin.IsUserAdmin;
  tsBackup.TabVisible := IBLogin.IsUserAdmin;

  if Assigned(UserStorage) then
    with UserStorage do
    begin
      chbxEnterAsTab.Checked := ReadBoolean('Options', 'EnterAsTab', False);
      chbxMagic.Checked := ReadBoolean('Options', 'Magic', True);
      chbxAutoSaveDesktop.Checked := ReadBoolean('Options', 'SaveDesktop', False);
      chbxDialogDefaults.Checked := ReadBoolean('Options', 'DialogDefaults', True);
      chbxHintInGrid.Checked := ReadBoolean('Options', 'HintInGrid', True);
      chbxHideMaster.Checked := ReadBoolean('Options', 'HideMaster', False);
      chbxShowZero.Checked := ReadBoolean('Options', 'ShowZero', False);
      chbxEditWarn.Checked := ReadBoolean('Options', 'EditWarn', True);

      chbxEditMultipleConfirmation.Checked := ReadBoolean('Options\Confirmations', 'EditMultiple', True);
      chbxOtherConfirmations.Checked := ReadBoolean('Options\Confirmations', 'Other', True);
      chbxFormConfirmations.Checked := ReadBoolean('Options\Confirmations', 'Form', True);

      chbxFilterParams.Checked := ReadBoolean('Options', 'FilterParams', True, False);
      chbxCorrectWindowSize.Checked := ReadBoolean('Options', 'CWS', True, False);

      chbxWarnMDMism.Checked := ReadBoolean('Options', 'WarnMDMism', True, False);

      case ReadInteger('Options', 'KbLanguage', 0) of
        0:     cbLanguage.ItemIndex := 0;
        $0423: cbLanguage.ItemIndex := 1;
        $0419: cbLanguage.ItemIndex := 2;
        $0409: cbLanguage.ItemIndex := 3;
      end;

      cbSaveDT.ItemIndex := ReadInteger('Options', 'SaveDT', 1);

      if ValueExists('Options', 'AutoCreate', False) then
        chbxAutoCreate.Checked := ReadBoolean('Options', 'AutoCreate', False, False)
      else
        chbxAutoCreate.State := cbGrayed;

      chbxDelSilent.Checked := ReadBoolean('Options', 'DelSilent', False);
    end;

  if Assigned(GlobalStorage) then
  with GlobalStorage do
  begin
    chbxAllowAudit.Checked := ReadBoolean('Options', 'AllowAudit', False);
    chbxProhibitDuplicates.Checked := ReadBoolean('Options', 'Duplicates', True);
    chbxCheckUNN.Checked := ReadBoolean('Options', 'CheckUNN', True);
    chbxCheckName.Checked := ReadBoolean('Options', 'CheckName', True);
    chbxMultipleConnect.Checked := ReadBoolean('Options', 'MultipleConnect', True);
    seDateWindow.Text := IntToStr(ReadInteger('Options', 'DatesWindow', 10));
    chbxCheckAccount.Checked := ReadBoolean('Options', 'CheckAccount', True);
    chbxByLBRB.Checked := ReadBoolean('Options', 'ByLBRB', False);
    chbxBlockRecord.Checked := ReadBoolean('Options', 'BlockRec', False, False);

    chbxArchOn.Checked := ReadBoolean('Options\Arch', 'Enabled', False);
    edArchPath.Text := ReadString('Options\Arch', 'Path', '');
    if ReadBoolean('Options\Arch', 'OneFile', True) then
      rbArchOneFile.Checked := True
    else
      rbArchMultipleFiles.Checked := True;
    edArchFileName.Text := ReadString('Options\Arch', 'FileName', '');
    if ReadBoolean('Options\Arch', 'AnyAccount', True) then
      rbArchAny.Checked := True
    else
      rbArchSelected.Checked := True;
    edArchLogin.Text := ReadString('Options\Arch', 'Account', '');
    seArchInterval.Value := ReadInteger('Options\Arch', 'Interval', 7);
    chbxArchCopy.Checked := ReadBoolean('Options\Arch', 'Copy', True);

    xedArchDate.DateTime := ReadDateTime('Options\Arch', 'Last', 0);

    if not IBLogin.IsUserAdmin then
    begin
      seDateWindow.Enabled := False;
      chbxCheckName.Enabled := False;
      chbxCheckUNN.Enabled := False;
      chbxProhibitDuplicates.Enabled := False;
      chbxCheckAccount.Enabled := False;
      chbxByLBRB.Enabled := False;
    end;

    { Добавлено Mike для склада
      возможность отключения нового использования нового поля в INV_MOVEMENT и INV_BALANCE }
    cbDontUseGoodKey.Checked := ReadBoolean('Options\Invent', 'DontUseGoodKey', False);
    cbUseDelMovement.Checked := ReadBoolean('Options\Invent', 'UseDelMovement', True);

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_EDIT_FILTERS_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_EDIT_FILTERS_ID, GD_POL_EDIT_FILTERS_MASK)));
    LI.SubItems.Add(GD_POL_EDIT_FILTERS_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_EDIT_FILTERS_ID, GD_POL_EDIT_FILTERS_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_EDIT_FILTERS_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_APPL_FILTERS_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_APPL_FILTERS_ID, GD_POL_APPL_FILTERS_MASK)));
    LI.SubItems.Add(GD_POL_APPL_FILTERS_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_APPL_FILTERS_ID, GD_POL_APPL_FILTERS_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_APPL_FILTERS_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_EDIT_UI_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK)));
    LI.SubItems.Add(GD_POL_EDIT_UI_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_EDIT_UI_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_CHANGE_WO_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_CHANGE_WO_ID, GD_POL_CHANGE_WO_MASK)));
    LI.SubItems.Add(GD_POL_CHANGE_WO_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_CHANGE_WO_ID, GD_POL_CHANGE_WO_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_CHANGE_WO_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_PRINT_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_PRINT_ID, GD_POL_PRINT_MASK)));
    LI.SubItems.Add(GD_POL_PRINT_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_PRINT_ID, GD_POL_PRINT_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_PRINT_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_RUN_MACRO_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_RUN_MACRO_ID, GD_POL_RUN_MACRO_MASK)));
    LI.SubItems.Add(GD_POL_RUN_MACRO_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_RUN_MACRO_ID, GD_POL_RUN_MACRO_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_RUN_MACRO_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_REDUCT_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_REDUCT_ID, GD_POL_REDUCT_MASK)));
    LI.SubItems.Add(GD_POL_REDUCT_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_REDUCT_ID, GD_POL_REDUCT_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_REDUCT_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_REPORT_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_REPORT_ID, GD_POL_REPORT_MASK)));
    LI.SubItems.Add(GD_POL_REPORT_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_REPORT_ID, GD_POL_REPORT_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_REPORT_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_DESK_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_DESK_ID, GD_POL_DESK_MASK)));
    LI.SubItems.Add(GD_POL_DESK_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_DESK_ID, GD_POL_DESK_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_DESK_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_CASC_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_CASC_ID, GD_POL_CASC_MASK)));
    LI.SubItems.Add(GD_POL_CASC_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_CASC_ID, GD_POL_CASC_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_CASC_MASK));

    LI := lvPolicy.Items.Add;
    LI.Caption := GD_POL_EQ_CAPTION;
    LI.SubItems.Add(TgdcUserGroup.GetGroupList(
      ReadInteger('Options\Policy', GD_POL_EQ_ID, GD_POL_EQ_MASK)));
    LI.SubItems.Add(GD_POL_EQ_ID);
    LI.SubItems.Add(IntToStr(
      ReadInteger('Options\Policy', GD_POL_EQ_ID, GD_POL_EQ_MASK)));
    LI.SubItems.Add(IntToStr(GD_POL_EQ_MASK));
  end;

  if Assigned(gdcBaseManager)
    and Assigned(gdcBaseManager.ReadTransaction)
    and Assigned(IBLogin)
    and IBLogin.IsIBUserAdmin then
  begin
    q := TIBSQL.Create(nil);
    try
      try
        q.Transaction := gdcBaseManager.ReadTransaction;
        q.SQL.Text := 'SELECT GEN_ID(gd_g_block, 0) FROM rdb$database';
        q.ExecQuery;
        chbxBlock.Checked := q.Fields[0].AsInteger <> 0;
        BlockedDataBase := q.Fields[0].AsInteger <> 0;
        if chbxBlock.Checked then
          xdeBlock.Date := q.Fields[0].AsInteger - IBDateDelta;

        q.Close;
        q.SQL.Text := 'SELECT GEN_ID(gd_g_block_group, 0) FROM rdb$database';
        q.ExecQuery;
        mGroups.Lines.Text := TgdcUserGroup.GetGroupList(q.Fields[0].AsInteger);

        chbxBlockClick(nil);
      except
        // если у нас очень старая база данных без метаданных
        // блокировки периода
        gbBlock.Visible := False;
      end;
    finally
      q.Free;
    end;

    mDocumentTypes.Lines.Text := GetExcludedDocumentTypes;
  end else
  begin
    gbBlock.Visible := False;
  end;
end;

procedure Tgd_dlgOptions.FormClose(Sender: TObject;
  var Action: TCloseAction);
const
  Triggers =
    'ac_bi_entry_block,ac_bu_entry_block,ac_bd_entry_block,' +
    'gd_bi_document_block,gd_bu_document_block,gd_bd_document_block,' +
    'inv_bi_card_block,inv_bu_card_block,inv_bd_card_block,' +
    'inv_bi_movement_block,inv_bu_movement_block,inv_bd_movement_block';
var
  q: TIBSQL;
  Tr: TIBTransaction;
  I: Integer;
  S: String;
  SL: TStringList;
begin
  if (ModalResult = mrOk) then
  begin
    if Assigned(UserStorage) then
      with UserStorage do
      begin
        WriteBoolean('Options', 'EnterAsTab', chbxEnterAsTab.Checked);
        WriteBoolean('Options', 'Magic', chbxMagic.Checked);
        WriteBoolean('Options', 'SaveDesktop', chbxAutoSaveDesktop.Checked);
        WriteBoolean('Options', 'DialogDefaults', chbxDialogDefaults.Checked);
        WriteBoolean('Options', 'HintInGrid', chbxHintInGrid.Checked);
        WriteBoolean('Options', 'HideMaster', chbxHideMaster.Checked);
        WriteBoolean('Options', 'ShowZero', chbxShowZero.Checked);
        WriteBoolean('Options', 'EditWarn', chbxEditWarn.Checked);

        WriteBoolean('Options\Confirmations', 'EditMultiple', chbxEditMultipleConfirmation.Checked);
        WriteBoolean('Options\Confirmations', 'Other', chbxOtherConfirmations.Checked);
        WriteBoolean('Options\Confirmations', 'Form', chbxFormConfirmations.Checked);

        WriteBoolean('Options', 'FilterParams', chbxFilterParams.Checked);
        WriteBoolean('Options', 'CWS', chbxCorrectWindowSize.Checked);

        WriteBoolean('Options', 'WarnMDMism', chbxWarnMDMism.Checked);

        if cbSaveDT.ItemIndex <> ReadInteger('Options', 'SaveDT', 1) then
          WriteInteger('Options', 'SaveDT', cbSaveDT.ItemIndex);

        case cbLanguage.ItemIndex of
          0:     WriteInteger('Options', 'KbLanguage', 0);
          1:     WriteInteger('Options', 'KbLanguage', $0423);
          2:     WriteInteger('Options', 'KbLanguage', $0419);
          3:     WriteInteger('Options', 'KbLanguage', $0409);
        end;

        if chbxAutoCreate.State = cbGrayed then
          DeleteValue('Options', 'AutoCreate', False)
        else
          WriteBoolean('Options', 'AutoCreate', chbxAutoCreate.Checked);

        WriteBoolean('Options', 'DelSilent', chbxDelSilent.Checked);  
      end;

    if Assigned(GlobalStorage) then
    with GlobalStorage do
    begin
      WriteBoolean('Options', 'AllowAudit', chbxAllowAudit.Checked);
      WriteBoolean('Options', 'Duplicates', chbxProhibitDuplicates.Checked);
      WriteBoolean('Options', 'CheckUNN', chbxCheckUNN.Checked);
      WriteBoolean('Options', 'CheckName', chbxCheckName.Checked);
      WriteBoolean('Options', 'MultipleConnect', chbxMultipleConnect.Checked);
      WriteInteger('Options', 'DatesWindow', StrToIntDef(seDateWindow.Text, 10));
      WriteBoolean('Options', 'CheckAccount', chbxCheckAccount.Checked);
      WriteBoolean('Options', 'ByLBRB', chbxByLBRB.Checked);
      if chbxBlockRecord.Checked then
        WriteBoolean('Options', 'BlockRec', chbxBlockRecord.Checked)
      else
        DeleteValue('Options', 'BlockRec', False);

      { Добавлено Mike для склада }
      WriteBoolean('Options\Invent', 'DontUseGoodKey', cbDontUseGoodKey.Checked);
      WriteBoolean('Options\Invent', 'UseDelMovement', cbUseDelMovement.Checked);

      WriteBoolean('Options\Arch', 'Enabled', chbxArchOn.Checked);
      WriteString('Options\Arch', 'Path', edArchPath.Text);
      WriteBoolean('Options\Arch', 'OneFile', rbArchOneFile.Checked);
      WriteString('Options\Arch', 'FileName', edArchFileName.Text);
      WriteBoolean('Options\Arch', 'AnyAccount', rbArchAny.Checked);
      WriteString('Options\Arch', 'Account', edArchLogin.Text);
      WriteInteger('Options\Arch', 'Interval', seArchInterval.Value);
      WriteBoolean('Options\Arch', 'Copy', chbxArchCopy.Checked);

      for I := 0 to lvPolicy.Items.Count - 1 do
        with lvPolicy.Items[I] do
        begin
          if ReadInteger('Options\Policy', SubItems[1], StrToInt(SubItems[3])) <>
            StrToInt(SubItems[2]) then
          begin
            WriteInteger('Options\Policy', SubItems[1], StrToInt(SubItems[2]));
          end;
        end;
    end;

    if gbBlock.Visible
      and Assigned(IBLogin)
      and IBLogin.IsIBUserAdmin
      and Assigned(gdcBaseManager) then
    begin
      q := TIBSQL.Create(nil);
      Tr := TIBTransaction.Create(nil);
      try
        Tr.DefaultDatabase := gdcBaseManager.Database;
        q.Transaction := Tr;
        Tr.StartTransaction;
        if chbxBlock.Checked then
        begin
          S := 'ACTIVE';
          q.SQL.Text := 'SET GENERATOR gd_g_block TO ' + IntToStr(Trunc(xdeBlock.Date) + IBDateDelta);
        end else
        begin
          S := 'INACTIVE';
          q.SQL.Text := 'SET GENERATOR gd_g_block TO 0';
        end;
        q.ExecQuery;
        q.Close;

        if BlockedDataBase <> chbxBlock.Checked then
        begin
          SL := TStringList.Create;
          try
            SL.CommaText := Triggers;
            for I := 0 to SL.Count - 1 do
            begin
              try
                q.SQL.Text := 'ALTER TRIGGER ' + SL[I] + ' ' + S;
                q.ExecQuery;
              except
                on E: Exception do
                begin
                  MessageBox(Handle,
                    PChar('При попытке изменить тригер возникла исключительная ситуация.'#13#10 +
                    'Возможно, необходимо обновить структуру базы данных.'#13#10#13#10 +
                    'Сообщение об ошибке: ' + E.Message),
                    'Внимание',
                    MB_OK or MB_ICONHAND or MB_TASKMODAL);
                end;
              end;
              q.Close;
            end;
          finally
            SL.Free;
          end;
        end;

        Tr.Commit;
      finally
        q.Free;
        Tr.Free;
      end;
    end;

    if Assigned(IBLogin) then
      IBLogin.AddEvent('Сохранены настройки.');
  end;
end;

procedure Tgd_dlgOptions.actUsersExecute(Sender: TObject);
begin
  TgdcUser.CreateViewForm(Application, '', '',
    True).ShowModal;
end;

procedure Tgd_dlgOptions.actJournalExecute(Sender: TObject);
begin
  with TgdcJournal.CreateViewForm(Application, '', '', True) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure Tgd_dlgOptions.chbxBlockClick(Sender: TObject);
begin
  xdeBlock.Visible := chbxBlock.Checked;
  lblBlock.Visible := chbxBlock.Checked;
  mGroups.Visible := chbxBlock.Checked;
  mGroupsLabel.Visible := chbxBlock.Checked;
  btnGroups.Visible := chbxBlock.Checked;
  mDocumentTypes.Visible := chbxBlock.Checked;
  mDocumentTypesLabel.Visible := chbxBlock.Checked;
  btnDocumentTypes.Visible := chbxBlock.Checked;
end;

procedure Tgd_dlgOptions.actPolChangeExecute(Sender: TObject);
var
  UG: TgdcUserGroup;
  KA: TgdKeyArray;
  Mask, I: Integer;
  V: OleVariant;
begin
  Mask := StrToInt(lvPolicy.Selected.SubItems[2]);

  KA := TgdKeyArray.Create;
  UG := TgdcUserGroup.Create(nil);
  try
    UG.Open;
    while not UG.EOF do
    begin
      if (Mask and UG.GetGroupMask) <> 0 then
      begin
        KA.Add(UG.ID);
      end;
      UG.Next;
    end;
    UG.Close;

    if UG.ChooseItems(TgdcUserGroup, KA, V) then
    begin
      Mask := 0;
      for I := 0 to KA.Count - 1 do
      begin
        Mask := Mask or UG.GetGroupMask(KA[I]);
      end;

      lvPolicy.Selected.SubItems[2] := IntToStr(Mask);
      lvPolicy.Selected.SubItems[0] := UG.GetGroupList(Mask);
    end;
  finally
    KA.Free;
    UG.Free;
  end;
end;

procedure Tgd_dlgOptions.actPolChangeUpdate(Sender: TObject);
begin
  actPolChange.Enabled := lvPolicy.Selected <> nil;
end;

procedure Tgd_dlgOptions.actPolDefaultUpdate(Sender: TObject);
begin
  actPolDefault.Enabled := lvPolicy.Selected <> nil;
end;

procedure Tgd_dlgOptions.actPolDefaultExecute(Sender: TObject);
begin
  lvPolicy.Selected.SubItems[2] := lvPolicy.Selected.SubItems[3];
  lvPolicy.Selected.SubItems[0] := TgdcUserGroup.GetGroupList(
    StrToInt(lvPolicy.Selected.SubItems[2]));
end;

procedure Tgd_dlgOptions.Button8Click(Sender: TObject);
begin
  if IBLogin.ServerName > '' then
    edArchPath.Text := StringReplace(ExtractFilePath(IBLogin.DatabaseName),
      IBLogin.ServerName + ':', '', [rfIgnoreCase])
  else
    edArchPath.Text := ExtractFilePath(IBLogin.DatabaseName);
end;

procedure Tgd_dlgOptions.Button9Click(Sender: TObject);
begin
  edArchFileName.Text := ChangeFileExt(
    ExtractFileName(IBLogin.DatabaseName), '.bk');
end;

procedure Tgd_dlgOptions.actAddBlockGroupExecute(Sender: TObject);
var
  Obj: TgdcUserGroup;
  A, R: OleVariant;
  I, M: Integer;
begin
  Obj := TgdcUserGroup.Create(nil);
  try
    Obj.Open;
    gdcBaseManager.ExecSingleQueryResult('SELECT GEN_ID(gd_g_block_group, 0) FROM rdb$database',
      0, R);
    M := 1;
    for I := 1 to 32 do
    begin
      if (M and R[0, 0]) <> 0 then
        Obj.SelectedID.Add(I);
      if I < 32 then
        M := M shl 1;  
    end;
    if Obj.ChooseItems(A) then
    begin
      M := 0;
      for I := VarArrayLowBound(A, 1) to VarArrayHighBound(A, 1) do
      begin
        M := M or TgdcUserGroup.GetGroupMask(A[I]);
      end;
      gdcBaseManager.ExecSingleQuery('SET GENERATOR gd_g_block_group TO ' +
        IntToStr(M));
      mGroups.Lines.Text := TgdcUserGroup.GetGroupList(M);
    end;
  finally
    Obj.Free;
  end;
end;

procedure Tgd_dlgOptions.actAddBlockGroupUpdate(Sender: TObject);
begin
  actAddBlockGroup.Enabled := Assigned(IBLogin)
    and IBLogin.IsIBUserAdmin;
end;

procedure Tgd_dlgOptions.actAddBlockDTUpdate(Sender: TObject);
begin
  actAddBlockDT.Enabled := Assigned(IBLogin)
    and IBLogin.IsIBUserAdmin;
end;

procedure Tgd_dlgOptions.actAddBlockDTExecute(Sender: TObject);
var
  Obj: TgdcDocumentType;
  A: OleVariant;
  I: Integer;
  S: String;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Obj := TgdcDocumentType.Create(nil);
  try
    Obj.Open;
    GetExcludedDocumentTypes(Obj);
    if Obj.ChooseItems(A) then
    begin
      S := '';
      for I := VarArrayLowBound(A, 1) to VarArrayHighBound(A, 1) do
      begin
        S := S + '  IF (:DT = ' + IntToStr(A[I]) + ') THEN F = 1; '#13#10;

        if Length(S) > 32000 then
          break;
      end;

      Tr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      try
        Tr.DefaultDatabase := gdcBaseManager.Database;
        Tr.StartTransaction;

        q.Transaction := Tr;
        q.ParamCheck := False;
        q.SQL.Text :=
          'ALTER PROCEDURE gd_p_exclude_block_dt (DT INTEGER) '#13#10 +
          '  RETURNS (F INTEGER) '#13#10 +
          'AS'#13#10 +
          'BEGIN'#13#10 +
          '  F = 0;'#13#10 +
          S +
          'END';
        try
          q.ExecQuery;

          q.Close;
          q.SQL.Text :=
            'GRANT EXECUTE ON PROCEDURE GD_P_EXCLUDE_BLOCK_DT TO ADMINISTRATOR';
          q.ExecQuery;
        except
          on E: EIBError do
          begin
            if E.IBErrorCode = 335544351 then
            begin
              MessageBox(Handle,
                'Не найдена процедура GD_P_EXCLUDE_BLOCK_DT.'#13#10 +
                'Произведите обновление структуры базы данных!',
                'Внимание',
                MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
            end else
              raise;
          end;
        end;
        q.Close;
        Tr.Commit;
      finally
        q.Free;
        Tr.Free;
      end;
    end;
  finally
    Obj.Free;
  end;

  mDocumentTypes.Lines.Text := GetExcludedDocumentTypes;
end;

function Tgd_dlgOptions.GetExcludedDocumentTypes(const Obj: TgdcBase = nil): String;
var
  q: TIBSQL;
  I: Integer;
  RegExp, Matches: Variant;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT RDB$PROCEDURE_SOURCE FROM RDB$PROCEDURES '
      + 'WHERE RDB$PROCEDURE_NAME = ''GD_P_EXCLUDE_BLOCK_DT'' ';
    q.ExecQuery;

    try
      RegExp := CreateOleObject('VBScript.RegExp');
      RegExp.IgnoreCase := True;
      RegExp.Global := True;
      RegExp.Pattern := '(\(:DT = )(\d+)(\))';
      Matches := RegExp.Execute(q.Fields[0].AsString);

      q.Close;
      q.SQL.Text := 'SELECT name FROM gd_documenttype WHERE id = :ID';

      for I := 0 to Matches.Count - 1 do
      begin
        if Obj <> nil then
          Obj.SelectedID.Add(Matches.Item[I].SubMatches.Item[1]);
        q.ParamByName('ID').AsInteger := Matches.Item[I].SubMatches.Item[1];
        q.ExecQuery;
        if q.Fields[0].AsString > '' then
          Result := Result + q.Fields[0].AsString + ', ';
        q.Close;
      end;
      if Result > '' then
        SetLength(Result, Length(Result) - 2);
    except
      Result := '';
    end;
  finally
    q.Free;
  end;
end;

procedure Tgd_dlgOptions.actHelpExecute(Sender: TObject);
begin
  ShowHelp('Диалоговое окно Опции системы');
end;

procedure Tgd_dlgOptions.actBlockUpdate(Sender: TObject);
begin
  actBlock.Enabled := IBLogin.IsIBUserAdmin;
end;

procedure Tgd_dlgOptions.actBlockExecute(Sender: TObject);
begin
  TgdcBlockRule.CreateViewForm(Self).Show;
end;

end.
