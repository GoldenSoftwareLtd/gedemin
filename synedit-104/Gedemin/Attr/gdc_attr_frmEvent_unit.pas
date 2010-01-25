unit gdc_attr_frmEvent_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcMetaData, gdcEvent,
  gdc_frmMDVTree_unit, gdcTree, gdcDelphiObject, gsDBTreeView;

type
  Tgdc_frmEvent = class(Tgdc_frmMDVTree)
    gdcEvent: TgdcEvent;
    gdcDelphiObject: TgdcDelphiObject;
    procedure FormCreate(Sender: TObject);

  protected
    procedure RemoveSubSetList(S: TStrings); override;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure SetChoose(AnObject: TgdcBase); override;
  end;

var
  gdc_frmEvent: Tgdc_frmEvent;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmEvent.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmEvent) then
    gdc_frmEvent := Tgdc_frmEvent.Create(AnOwner);
  Result := gdc_frmEvent;
end;

procedure Tgdc_frmEvent.FormCreate(Sender: TObject);
begin
  gdcObject := gdcDelphiObject;
  gdcDetailObject := gdcEvent;
  inherited;
end;


procedure Tgdc_frmEvent.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMEVENT', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMEVENT', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMEVENT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMEVENT',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMEVENT' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;
  S.Add('ByLBRBObject');
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMEVENT', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMEVENT', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmEvent.SetChoose(AnObject: TgdcBase);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMEVENT', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMEVENT', KEYSETCHOOSE);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETCHOOSE]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMEVENT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMEVENT',
  {M}        'SETCHOOSE', KEYSETCHOOSE, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMEVENT' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;
  if AnObject is TgdcEvent then
  begin
    gdcObject.ExtraConditions.Clear;
    gdcObject.ExtraConditions.Add('EXISTS (SELECT * FROM evt_object o1 LEFT JOIN evt_objectevent e ON o1.id = e.objectkey ' +
      'WHERE o1.lb >= z.lb AND o1.rb <= z.rb AND e.functionkey IS NOT NULL) ');
    gdcDetailObject.ExtraConditions.Clear;
    gdcDetailObject.ExtraConditions.Add(' z.functionkey IS NOT NULL ');  
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMEVENT', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMEVENT', 'SETCHOOSE', KEYSETCHOOSE);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_frmEvent);

finalization
  UnRegisterFrmClass(Tgdc_frmEvent);
end.
