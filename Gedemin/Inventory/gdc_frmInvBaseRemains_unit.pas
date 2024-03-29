
unit gdc_frmInvBaseRemains_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, ExtCtrls, Db, Menus, ActnList, ToolWin, ComCtrls, TB2Item,
  TB2Dock, TB2Toolbar, Grids, DBGrids, gsDBGrid, gsIBGrid, gsDBTreeView,
  IBCustomDataSet, gdcBase, gdcGood, gdcInvMovement, IBSQL, gdcTree,
  gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmInvBaseRemains = class(Tgdc_frmG)
    pnMain: TPanel;
    Splitter1: TSplitter;
    pnDetail: TPanel;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    actOk: TAction;
    actCancel: TAction;
    dsDetail: TDataSource;
    tvGroup: TgsDBTreeView;
    ibgrDetail: TgsIBGrid;
    gdcGoodGroup: TgdcGoodGroup;
    actEditSelect: TAction;
    actViewCard: TAction;
    tbiCardInfo: TTBItem;
    tbAllRemainsView: TTBControlItem;
    cbAllRemains: TCheckBox;
    TBSeparatorItem1: TTBSeparatorItem;
    actViewFullCard: TAction;
    ibFullCard: TTBItem;
    actViewGood: TAction;
    ibGoodInfo: TTBItem;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure ibgrDetailAggregateChanged(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbMainClick(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDuplicateExecute(Sender: TObject);
    procedure actViewCardExecute(Sender: TObject);
    procedure cbAllRemainsClick(Sender: TObject);
    procedure pnMainResize(Sender: TObject);
    procedure actViewFullCardExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actViewGoodExecute(Sender: TObject);
    procedure actViewGoodUpdate(Sender: TObject);
    procedure actViewCardUpdate(Sender: TObject);
    procedure actViewFullCardUpdate(Sender: TObject);
    procedure actAddToSelectedExecute(Sender: TObject);
    procedure actRemoveFromSelectedExecute(Sender: TObject);

  private
    FIsSetup: Boolean;

  protected
    FSavedMasterSource: TDataSource;
    FSavedSubSet: String;
    procedure SetupInvRemains(gdcInvRemains: TgdcInvRemains);
    function CheckHolding: Boolean; virtual;

  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;

    property IsSetup: Boolean read FIsSetup write FIsSetup;
  end;

var
  gdc_frmInvBaseRemains: Tgdc_frmInvBaseRemains;

implementation

{$R *.DFM}

uses
  Storages, gd_ClassList, gdc_frmInvCard_unit, gsStorage_CompPath, gdcBaseInterface;

procedure Tgdc_frmInvBaseRemains.actOkExecute(Sender: TObject);
begin
  if gdcObject.State in [dsEdit, dsInsert] then
    gdcObject.Post;
  ModalResult := mrOk;
end;

procedure Tgdc_frmInvBaseRemains.actCancelExecute(Sender: TObject);
begin
  if gdcObject.State in [dsEdit, dsInsert] then
    gdcObject.Cancel;
  ModalResult := mrCancel;
end;

procedure Tgdc_frmInvBaseRemains.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMINVBASEREMAINS', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMINVBASEREMAINS', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVBASEREMAINS',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  //
  // ���������� ������������ � ������� �������

  if Assigned(UserStorage) and Assigned(gdcObject) then
  begin
    UserStorage.SaveComponent(ibgrDetail, ibgrDetail.SaveToStream,
      gdcObject.SubType);

    Path := BuildComponentPath(Self);

    UserStorage.WriteInteger(Path, Name + 'Height', Height);
    UserStorage.WriteInteger(Path, Name + 'Top', Top);
    UserStorage.WriteInteger(Path, Name + 'Left', Left);
    UserStorage.WriteInteger(Path, Name + 'Width', Width);
    UserStorage.WriteInteger(Path, Name + 'WS', Integer(WindowState));
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVBASEREMAINS', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVBASEREMAINS', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmInvBaseRemains.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMINVBASEREMAINS', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMINVBASEREMAINS', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVBASEREMAINS',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  
  if Assigned(UserStorage) then
  begin
    if (BorderStyle = bsSizeable) then
    begin
      Path := BuildComponentPath(Self);

      Height := UserStorage.ReadInteger(Path, Name + 'Height', Height);
      Top := UserStorage.ReadInteger(Path, Name + 'Top', Top);
      Left := UserStorage.ReadInteger(Path, Name + 'Left', Left);
      Width := UserStorage.ReadInteger(Path, Name + 'Width', Width);
      WindowState :=
        TWindowState(UserStorage.ReadInteger(Path, Name + 'WS', Integer(WindowState)));
    end;

    UserStorage.LoadComponent(ibgrDetail, ibgrDetail.LoadFromStream, SubType);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVBASEREMAINS', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVBASEREMAINS', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmInvBaseRemains.ibgrDetailAggregateChanged(Sender: TObject);
begin
  inherited;
  //
end;

procedure Tgdc_frmInvBaseRemains.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if not (fsModal in FormState) then
    inherited;
end;

procedure Tgdc_frmInvBaseRemains.sbMainClick(Sender: TObject);
begin
  //ibgrDetail.Aggregate.PopupMenu(-1, -1);
end;

procedure Tgdc_frmInvBaseRemains.actNewExecute(Sender: TObject);
begin
// nothing...
end;

procedure Tgdc_frmInvBaseRemains.actEditExecute(Sender: TObject);
begin
// nothing...

end;

procedure Tgdc_frmInvBaseRemains.actDeleteExecute(Sender: TObject);
begin
// nothing...
end;

procedure Tgdc_frmInvBaseRemains.actDuplicateExecute(Sender: TObject);
begin
// nothing...
end;

procedure Tgdc_frmInvBaseRemains.SetupInvRemains(gdcInvRemains: TgdcInvRemains);
begin
//
end;

procedure Tgdc_frmInvBaseRemains.actViewCardExecute(Sender: TObject);
begin
  inherited;
  with Tgdc_frmInvCard.Create(Self) as Tgdc_frmInvCard do
  try
    gdcInvCard.Close;
    gdcInvCard.gdcInvRemains := Self.gdcObject as TgdcInvBaseRemains;
    gdcObject := gdcInvCard;
    RunCard;
    ShowModal;
  finally
    Free;
  end;
end;

procedure Tgdc_frmInvBaseRemains.cbAllRemainsClick(Sender: TObject);
begin
  inherited;
  if (gdcObject <> nil) and (not IsSetup) then
  begin
    if cbAllRemains.Checked then
      gdcObject.AddSubSet(cst_AllRemains)
    else
      gdcObject.RemoveSubSet(cst_AllRemains);
    if CheckHolding then
      gdcObject.AddSubSet(cst_Holding)
    else
      gdcObject.RemoveSubSet(cst_Holding);
    gdcObject.Open;
  end;
end;

procedure Tgdc_frmInvBaseRemains.pnMainResize(Sender: TObject);
begin
  inherited;
  if Assigned(gdcObject) then
  begin
    if (pnMain.Width = 0) then
    begin
      pnMain.Width := 1;
      FSavedSubSet := gdcObject.SubSet;
      gdcObject.MasterSource := nil;
      gdcObject.RemoveSubSet('ByGroupKey');
      gdcObject.AddSubSet('All');
    end
    else
      if (pnMain.Width > 0)
        and (gdcObject.MasterSource = nil)
        and (FSavedSubSet > '') then
      begin
        gdcObject.SubSet := FSavedSubSet;
        gdcObject.MasterSource := dsDetail;
      end;  
  end;    
end;


function Tgdc_frmInvBaseRemains.CheckHolding: Boolean;
begin
  Result := False;
end;

procedure Tgdc_frmInvBaseRemains.actViewFullCardExecute(Sender: TObject);
begin
  inherited;
  with Tgdc_frmInvCard.Create(Self) as Tgdc_frmInvCard do
  try
    gdcInvCard.Close;
    gdcInvCard.gdcInvRemains := Self.gdcObject as TgdcInvBaseRemains;
    gdcObject := gdcInvCard;
    gdcObject.SubSet := 'ByHolding,ByGoodOnly';
    RunCard;
    ShowModal;
  finally
    Free;
  end;
end;

procedure Tgdc_frmInvBaseRemains.actFindExecute(Sender: TObject);
begin
  SetLocalizeListName(ibgrDetail);
  inherited;
end;

procedure Tgdc_frmInvBaseRemains.FormCreate(Sender: TObject);
begin
  inherited;
  FIsSetup := False;
end;

procedure Tgdc_frmInvBaseRemains.actViewGoodExecute(Sender: TObject);
begin
  with TgdcGood.Create(nil) do
  try
    SubSet := 'ByID';
    ID := GetTID(Self.gdcObject.FieldByName('GOODKEY'));
    Open;
    EditDialog;
  finally
    Free;
  end;
end;

procedure Tgdc_frmInvBaseRemains.actViewGoodUpdate(Sender: TObject);
begin
  actViewGood.Enabled := (Self.gdcObject <> nil) and (not Self.gdcObject.IsEmpty);
end;

procedure Tgdc_frmInvBaseRemains.actViewCardUpdate(Sender: TObject);
begin
  actViewCard.Enabled := gdcObject <> nil;
end;

procedure Tgdc_frmInvBaseRemains.actViewFullCardUpdate(Sender: TObject);
begin
  actViewFullCard.Enabled := gdcObject <> nil;
end;

procedure Tgdc_frmInvBaseRemains.actAddToSelectedExecute(Sender: TObject);
begin
  gdcObject.AddToSelectedID(ibgrDetail.SelectedRows);
end;

procedure Tgdc_frmInvBaseRemains.actRemoveFromSelectedExecute(
  Sender: TObject);
begin
  gdcObject.RemoveFromSelectedID(ibgrDetail.SelectedRows);
end;

initialization
  RegisterFrmClass(Tgdc_frmInvBaseRemains);

finalization
  UnRegisterFrmClass(Tgdc_frmInvBaseRemains);
end.
