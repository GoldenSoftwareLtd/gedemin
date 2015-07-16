unit gdc_flt_frmMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gdcFilter, IBCustomDataSet, gdcBase;

type
  Tgdc_flt_frmMain = class(Tgdc_frmMDHGR)
    gdcComponentFilter: TgdcComponentFilter;
    gdcSavedFilter: TgdcSavedFilter;
    procedure FormCreate(Sender: TObject);

  public
    procedure SetChoose(AnObject: TgdcBase); override;
  end;

var
  gdc_flt_frmMain: Tgdc_flt_frmMain;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_flt_frmMain.FormCreate(Sender: TObject);
begin
  gdcObject := gdcComponentFilter;
  gdcDetailObject := gdcSavedFilter;

  inherited;
end;

procedure Tgdc_flt_frmMain.SetChoose(AnObject: TgdcBase);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FLT_FRMMAIN', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FLT_FRMMAIN', KEYSETCHOOSE);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETCHOOSE]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FLT_FRMMAIN') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FLT_FRMMAIN',
  {M}        'SETCHOOSE', KEYSETCHOOSE, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FLT_FRMMAIN' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;
  if AnObject is TgdcSavedFilter then
  begin
    gdcObject.ExtraConditions.Clear;
    gdcObject.ExtraConditions.Add('EXISTS (SELECT * FROM flt_savedfilter sf WHERE z.id = sf.componentkey ) ');
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FLT_FRMMAIN', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FLT_FRMMAIN', 'SETCHOOSE', KEYSETCHOOSE);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFRMClass(Tgdc_flt_frmMain, 'Фильтры');

finalization
  UnRegisterFRMClass(Tgdc_flt_frmMain);
end.
