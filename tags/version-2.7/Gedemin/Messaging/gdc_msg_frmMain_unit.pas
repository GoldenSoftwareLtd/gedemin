
unit gdc_msg_frmMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gdcMessage, Db, IBCustomDataSet, gdcBase, gdcTree,
  Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls,
  gsDBTreeView, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, DBCtrls,
  gd_MacrosMenu, Buttons;

type
  Tgdc_msg_frmMain = class(Tgdc_frmMDVTree)
    gdcMessageBox: TgdcMessageBox;
    gdcMessage: TgdcBaseMessage;
    pnlMessageBody: TPanel;
    TBDockMessage: TTBDock;
    sMessageBottom: TSplitter;
    gdcAttachment: TgdcAttachment;
    TBItem1: TTBItem;
    actSaveAttachments: TAction;
    gdcbmHistory: TgdcBaseMessage;
    dsbmHistory: TDataSource;
    Panel1: TPanel;
    sbShowAttachment: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    DBText1: TDBText;
    DBText2: TDBText;
    Label3: TLabel;
    DBText3: TDBText;
    dbmMessage: TDBMemo;
    ibgrHistory: TgsIBGrid;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure TBItem1Click(Sender: TObject);
    procedure actSaveAttachmentsUpdate(Sender: TObject);
    procedure actSaveAttachmentsExecute(Sender: TObject);
    procedure gdcbmHistoryGetOrderClause(Sender: TObject;
      var Clause: String);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_msg_frmMain: Tgdc_msg_frmMain;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_msg_frmMain.FormCreate(Sender: TObject);
begin
  ByLBRBSubSetName := 'ByBoxLBRB';
  ByParentSubSetName := 'ByBoxID';
  ByLBRBMasterField := 'LB;RB';
  ByLBRBDetailField := 'LB;RB';
  ByParentMasterField := 'ID';
  ByParentDetailField := 'BOXID';

  gdcDetailObject := gdcMessage;
  gdcObject := gdcMessageBox;

  gdcbmHistory.QueryFiltered := False;
  gdcbmHistory.ExtraConditions.Add('z.fromcontactkey = :CK');

  inherited;
end;

class function Tgdc_msg_frmMain.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_msg_frmMain) then
    gdc_msg_frmMain := Tgdc_msg_frmMain.Create(AnOwner);
  Result := gdc_msg_frmMain;
end;

procedure Tgdc_msg_frmMain.TBItem1Click(Sender: TObject);
begin
  gdcAttachment.Open;
  try
    if not gdcAttachment.IsEmpty then
      gdcAttachment.OpenAttachment;
  finally
    gdcAttachment.Close;
  end;
end;

procedure Tgdc_msg_frmMain.actSaveAttachmentsUpdate(Sender: TObject);
begin
  actSaveAttachments.Enabled := (gdcMessage.State = dsBrowse)
    and (gdcMessage.FieldByName('attachmentcount').AsInteger > 0);
//  actSaveAttachments.Enabled := gdcAttachment.Active and (not gdcAttachment.IsEmpty);
end;

procedure Tgdc_msg_frmMain.actSaveAttachmentsExecute(Sender: TObject);
begin
  //
end;

procedure Tgdc_msg_frmMain.gdcbmHistoryGetOrderClause(Sender: TObject;
  var Clause: String);
begin
  Clause := 'ORDER BY z.msgstart DESC';
end;

procedure Tgdc_msg_frmMain.LoadSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_MSG_FRMMAIN', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_MSG_FRMMAIN', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_MSG_FRMMAIN') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_MSG_FRMMAIN',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_MSG_FRMMAIN' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  LoadGrid(ibgrHistory);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_MSG_FRMMAIN', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_MSG_FRMMAIN', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_msg_frmMain.SaveSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_MSG_FRMMAIN', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_MSG_FRMMAIN', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_MSG_FRMMAIN') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_MSG_FRMMAIN',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_MSG_FRMMAIN' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  SaveGrid(ibgrHistory);
  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_MSG_FRMMAIN', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_MSG_FRMMAIN', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_msg_frmMain);

finalization
  UnRegisterFrmClass(Tgdc_msg_frmMain);
end.
