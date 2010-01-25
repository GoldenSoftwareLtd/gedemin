unit gdc_frmReport_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gdcReport, Db, IBCustomDataSet, gdcBase, gdcTree,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar;

type
  Tgdc_frmReportList = class(Tgdc_frmMDVTree)
    gdcReportGroup: TgdcReportGroup;
    gdcReport: TgdcReport;
    actBuildReport: TAction;
    actReBuildReport: TAction;
    actDefaultServer: TAction;
    actRefresh: TAction;
    tbiRefresh: TTBItem;
    tbiReportServer: TTBItem;
    tbiRebuild: TTBItem;
    tbiBuild: TTBItem;
    chbxUserGroup: TCheckBox;
    TBControlItem1: TTBControlItem;
    procedure FormCreate(Sender: TObject);
    procedure actBuildReportExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ibgrDetailKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure pnlMainResize(Sender: TObject);
    procedure chbxUserGroupClick(Sender: TObject);
    procedure actBuildReportUpdate(Sender: TObject);

  protected
    procedure RemoveSubSetList(S:TStrings); override;
    procedure DoDestroy; override;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmReportList: Tgdc_frmReportList;

implementation

uses
  gd_security,  gd_ClassList, rp_ReportClient,
  IBDatabase, gd_SetDatabase, evt_i_Base;

{$R *.DFM}

class function Tgdc_frmReportList.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmReportList) then
    gdc_frmReportList := Tgdc_frmReportList.Create(AnOwner);
  Result := gdc_frmReportList
end;

procedure Tgdc_frmReportList.FormCreate(Sender: TObject);
begin
  gdcObject := gdcReportGroup;
  gdcDetailObject := gdcReport;

  inherited;

  EventControl.RegisterFrmReport(Self);
end;

procedure Tgdc_frmReportList.actBuildReportExecute(Sender: TObject);
begin
  if Assigned(ClientReport) then
    ClientReport.BuildReport(Unassigned, gdcReport.ID);
end;

procedure Tgdc_frmReportList.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ClientReport.Clear;

  inherited;
end;

procedure Tgdc_frmReportList.ibgrDetailKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN)
    and (Shift = [])
    and Assigned(gdcDetailObject)
    and (gdcDetailObject.State = dsBrowse)
    and (not ibgrDetail.EditorMode)
    and (ibgrDetail.ReadOnly or (not (dgEditing in ibgrDetail.Options))) then
  begin
    if not gdcDetailObject.IsEmpty then
      actBuildReport.Execute;
  end;
end;

procedure Tgdc_frmReportList.pnlMainResize(Sender: TObject);
var
  slSubSet: TStringList;
  I: Integer;
begin
  if (gdcDetailObject <> nil) and (gdcObject <> nil) then
  begin
    if (pnlMain.Width = 1) and (gdcDetailObject.MasterSource <> nil) then
    begin
      slSubSet := TStringList.Create;
      try
        slSubSet.CommaText := gdcDetailObject.SubSet;
        for I := slSubSet.Count - 1 downto 0 do
        begin
          if (slSubSet[I] = 'ByReportGroup') or (slSubSet[I] = 'ByLBRB')
            or (slSubSet[I] = 'ByParent') or (slSubSet[I] = 'ByRootID') then
          begin
             slSubSet.Delete(I);
          end;
        end;
        if slSubSet.Count = 0 then
          slSubSet.Add('All');

        gdcDetailObject.Close;

        FSavedMasterSource := gdcDetailObject.MasterSource;
        FSavedSubSet := gdcDetailObject.SubSet;

        gdcDetailObject.MasterSource := nil;
        gdcDetailObject.SubSet := slSubSet.CommaText;//'All';

        gdcDetailObject.Open;

        gdcObject.Close;
      finally
        slSubSet.Free;
      end;

    end else if (pnlMain.Width > 1) and (gdcDetailObject.MasterSource = nil)
      and (FSavedSubSet > '') then
    begin
      gdcObject.Open;

      gdcDetailObject.Close;

      gdcDetailObject.MasterSource := FSavedMasterSource;
      gdcDetailObject.SubSet := FSavedSubSet;

      FSavedMasterSource := nil;
      FSavedSubSet := '';

      gdcDetailObject.Open;
    end;
  end;
end;

procedure Tgdc_frmReportList.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMREPORTLIST', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMREPORTLIST', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMREPORTLIST') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMREPORTLIST',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMREPORTLIST' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  inherited;
  S.Add('ByReportGroup');
  
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMREPORTLIST', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMREPORTLIST', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmReportList.chbxUserGroupClick(Sender: TObject);
const
  Cond = 'NOT z.name LIKE ''־עקועû(%)''';
begin
  gdcReportGroup.Close;
  try
    if chbxUserGroup.Checked then
    begin
      if gdcReportGroup.ExtraConditions.IndexOf(Cond) = -1 then
        gdcReportGroup.ExtraConditions.Add(Cond);
    end else
    begin
      if gdcReportGroup.ExtraConditions.IndexOf(Cond) <> -1 then
        gdcReportGroup.ExtraConditions.Delete(
          gdcReportGroup.ExtraConditions.IndexOf(Cond));
    end;
  finally
    gdcReportGroup.Open;
  end;
end;

procedure Tgdc_frmReportList.actBuildReportUpdate(Sender: TObject);
begin
  actBuildReport.Enabled := Assigned(gdcReport) and (gdcReport.ID > 0);
end;

procedure Tgdc_frmReportList.DoDestroy;
begin
  inherited;
  try 
    EventControl.UnRegisterFrmReport(Self);
  except
    Application.HandleException(Self);
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmReportList);

finalization
  UnRegisterFrmClass(Tgdc_frmReportList);
end.

