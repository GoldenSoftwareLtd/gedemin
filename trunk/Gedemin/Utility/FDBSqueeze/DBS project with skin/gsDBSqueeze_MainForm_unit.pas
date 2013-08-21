unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Tabs, StdCtrls, ComCtrls, bsSkinTabs, bsSkinData,
  BusinessSkinForm, bsSkinCtrls, bsaadapter, bsribbon, bsSkinExCtrls,
  bsSkinBoxCtrls, bsSkinShellCtrls, Mask, bsdbctrls, bsSkinPrinter, Menus,
  bsPngImageList, ActnList,
  gsDBSqueezeThread_unit, gd_ProgressNotifier_unit;

type
  TgsDBSqueeze_MainForm = class(TForm, IgdProgressWatch)
    bsbsnsknfrm1: TbsBusinessSkinForm;
    bsknfrm1: TbsSkinFrame;
    bskndt1: TbsSkinData;
    bscmprsdsknlst1: TbsCompressedSkinList;
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
    bsSkinPageControl: TbsSkinPageControl;
    bskntabsheetSettings: TbsSkinTabSheet;
    bskntabsheetProcess: TbsSkinTabSheet;
    bskntabsheetLog: TbsSkinTabSheet;
    bskntabsheetStatistics: TbsSkinTabSheet;
    bsAppMenuSettings: TbsAppMenu;
    bsAppMenuPageDBConnection: TbsAppMenuPage;
    bsAppMenuOptions: TbsAppMenuPage;
    bsAppMenuPageCalculatingBalance: TbsAppMenuPage;
    bsGroupBoxDBLocation: TbsSkinGroupBox;
    bsStdLabelHost: TbsSkinStdLabel;
    bsStdLabelDatabase: TbsSkinStdLabel;
    bsStdLabelPort: TbsSkinStdLabel;
    bsRadioGroupDBLocation: TbsSkinRadioGroup;
    bsFileEditDatabase: TbsSkinFileEdit;
    bsEditHost: TbsSkinEdit;
    bsCheckRadioBoxDefaultPort: TbsSkinCheckRadioBox;
    bsEditPort: TbsSkinEdit;
    bsGroupBoxSecurity: TbsSkinGroupBox;
    bsStdLabelUsername: TbsSkinStdLabel;
    bsStdLabelPassword: TbsSkinStdLabel;
    bsEditUsername: TbsSkinEdit;
    bsPasswordEdit: TbsSkinPasswordEdit;
    bsSkinData1: TbsSkinData;
    bscmprsdstrdskn2: TbsCompressedStoredSkin;
    bsAppMenuPageDeletingData: TbsAppMenuPage;
    bsCheckRadioBoxDeleteOldBalance: TbsSkinCheckRadioBox;
    bsDateEditClosingDate: TbsSkinDateEdit;
    bsAppMenuPageTestDBConnection: TbsAppMenuPage;
    bsAppMenuPageTestSettings: TbsAppMenuPage;
    bsAppMenuPageCompleteSetup: TbsAppMenuPage;
    bsLabelDBConnection: TbsSkinLabel;
    bsLabelOptions: TbsSkinLabel;
    bsLabelCalculatingBalance: TbsSkinLabel;
    bsLabelDeletingData: TbsSkinLabel;
    bsLabelTestSettings: TbsSkinLabel;
    bsLabelCompleteSetup: TbsSkinLabel;
    bsLabeTestConnection: TbsSkinLabel;
    bsAppMenuPageReviewSettings: TbsAppMenuPage;
    bsLabelReviewSettings: TbsSkinLabel;
    bsCheckRadioBoxTestConnect: TbsSkinCheckRadioBox;
    bsCheckRadioBoxGetServerVer: TbsSkinCheckRadioBox;
    bsStdLabelTesConnectiontResult: TbsSkinStdLabel;
    bsButtonNext1: TbsSkinButton;
    bsButtonBack2: TbsSkinButton;
    bsButtonBack3: TbsSkinButton;
    bsButtonBack4: TbsSkinButton;
    bsButtonBack5: TbsSkinButton;
    bsButtonBack6: TbsSkinButton;
    bsButtonBack7: TbsSkinButton;
    bsButtonBack8: TbsSkinButton;
    bsButtonNext2: TbsSkinButton;
    bsButtonNext3: TbsSkinButton;
    bsButtonNext4: TbsSkinButton;
    bsButtonNext5: TbsSkinButton;
    bsButtonNext6: TbsSkinButton;
    bsButtonNext7: TbsSkinButton;
    bsButtonNext8: TbsSkinButton;
    bsCheckRadioBoxSaseLogs: TbsSkinCheckRadioBox;
    bsStdLabelLogDirectory: TbsSkinStdLabel;
    bsDirectoryEditLogs: TbsSkinDirectoryEdit;
    bsCheckRadioBoxSaveReport: TbsSkinCheckRadioBox;
    bsStdLabelReport: TbsSkinStdLabel;
    bsCheckRadioBoxBackup: TbsSkinCheckRadioBox;
    bsDirectoryEditReport: TbsSkinDirectoryEdit;
    bsDirectoryEditBackup: TbsSkinDirectoryEdit;
    bsStdLabelBackup: TbsSkinStdLabel;
    bsRadioGroupReprocessing: TbsSkinRadioGroup;
    bsRadioGroupCompany: TbsSkinRadioGroup;
    bCheckComboBoxCompany: TbsSkinCheckComboBox;
    bsGroupBoxCardFeatures: TbsSkinGroupBox;
    lstCheckListBoxCardFeatures: TbsSkinCheckListBox;
    bsStdLabelClosingDate: TbsSkinStdLabel;
    ActionList: TActionList;
    actTestConnect: TAction;

    procedure actTestConnectExecute(Sender: TObject);
    procedure actTestConnectUpdate(Sender: TObject);
  private
    FSThread: TgsDBSqueezeThread;
    FServerVersion: String;
    
    procedure GetServerVersionEvent(const AServerVersion: String);
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);
  end;

var
  gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm;

implementation

{$R *.DFM}

constructor TgsDBSqueeze_MainForm.Create(AnOwner: TComponent);
begin
  inherited;
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnGetServerVersion := GetServerVersionEvent;
  //FSThread.OnErrorLog := ErrorLogEvent;
  //FSThread.OnSetItemsCbb := SetItemsCbbEvent;
  //FSThread.OnGetDBSize := GetDBSizeEvent;
  //FSThread.OnGetStatistics := GetStatisticsEvent;
  //mLog.ReadOnly := True;
  //mErrorLog.ReadOnly := True;
  //dtpClosingDate.Date := Date;
end;

destructor TgsDBSqueeze_MainForm.Destroy;
begin
  FSThread.Free;
  inherited;
end;

procedure TgsDBSqueeze_MainForm.UpdateProgress(
  const AProgressInfo: TgdProgressInfo);
begin
  //if (AProgressInfo.Message > '') then
  //  mLog.Lines.Add(FormatDateTime('h:nn:ss', Now) + ' -- ' + AProgressInfo.Message);
end;

procedure TgsDBSqueeze_MainForm.actTestConnectExecute(Sender: TObject);
var
  Host: String;
begin
  bsAppMenuSettings.ItemIndex := 1; //перейти на след страницу

  if bsRadioGroupDBLocation.ItemIndex = 0 then
    Host := 'localhost'
  else
    Host := bsEditHost.Text;

  if bsCheckRadioBoxDefaultPort.Checked then
    FSThread.SetDBParams(Host + ':' + bsFileEditDatabase.Text, bsEditUsername.Text, bsPasswordEdit.Text)
  else
    FSThread.SetDBParams(Host + '/' + bsEditPort.Text + ':' + bsFileEditDatabase.Text, bsEditUsername.Text, bsPasswordEdit.Text);

  FSThread.StartTestConnection;
  bsCheckRadioBoxTestConnect.Checked := FSThread.Connected;

  if (FSThread.State) then  //True состояние: процедура отработала без exceptions
  begin
    FSThread.DoGetServerVersion;
    if (FSThread.State) then
    begin
      bsCheckRadioBoxGetServerVer.Caption := 'Get Server Version: ' + FServerVersion;
      bsCheckRadioBoxGetServerVer.Checked := FSThread.State;
    end
    else begin
      ///Вывод ошибки на страницу
    end;
  end
  else begin
    ///Вывод ошибки на страницу
  end;
end;

procedure TgsDBSqueeze_MainForm.actTestConnectUpdate(Sender: TObject);
begin
  actTestConnect.Enabled := (bsEditHost.Text > '')
    and ((bsCheckRadioBoxDefaultPort.Checked) or (bsEditPort.Text > ''))
    and (bsFileEditDatabase.Text > '')
    and (bsEditUsername.Text > '')
    and (bsPasswordEdit.Text > '');
end;

procedure TgsDBSqueeze_MainForm.GetServerVersionEvent(const AServerVersion: String);
begin
  FServerVersion := AServerVersion;
end;

end.
