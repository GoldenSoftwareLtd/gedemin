
{++

  Copyright (c) 2001-2016 by Golden Software of Belarus, Ltd

  Module

    gdc_frmTable_unit.pas

  Abstract

    Form for relations and relation fields.

  Author

    Denis Romanovski

  Revisions history

    1.0    06.12.2001    dennis    Initial version.


--}

unit gdc_frmTable_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  gdcMetaData, IBCustomDataSet, gdcBase, gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmTable = class(Tgdc_frmMDHGR)
    gdcTable: TgdcTable;
    gdcTableField: TgdcTableField;
    actOpenTable: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    actShowSQLEditor: TAction;
    TBItem4: TTBItem;

    procedure FormCreate(Sender: TObject);
    procedure actOpenTableExecute(Sender: TObject);
    procedure actOpenTableUpdate(Sender: TObject);
    procedure actShowSQLEditorExecute(Sender: TObject);
    procedure actShowSQLEditorUpdate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure RemoveSubSetList(S: TStrings); override;
  end;

var
  gdc_frmTable: Tgdc_frmTable;

implementation

{$R *.DFM}

uses
  gdcBaseInterface,           at_classes,             gd_ClassList,
  gd_security,                flt_frmSQLEditorSyn_unit,
  ContNrs,                    gd_dlgClassList_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

class function Tgdc_frmTable.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmTable) then
    gdc_frmTable := Tgdc_frmTable.Create(AnOwner);

  Result := gdc_frmTable;
end;

procedure Tgdc_frmTable.FormCreate(Sender: TObject);
begin
  gdcObject := gdcTable;
  gdcDetailObject := gdcTableField;

  inherited;
end;

procedure Tgdc_frmTable.actOpenTableExecute(Sender: TObject);
var
  F: TForm;
  OL: TObjectList;
  BE: TgdBaseEntry;
  CE: TgdClassEntry;
begin
  OL := TObjectList.Create(False);
  try
    gdClassList.FindByRelation2(gdcObject.FieldByName('relationname').AsString, OL);

    if OL.Count = 1 then
      BE := OL[0] as TgdBaseEntry
    else if OL.Count > 1 then
    begin
      with Tgd_dlgClassList.Create(Self) do
      try
        CE := SelectModal(gdcObject.FieldByName('relationname').AsString);
        if CE is TgdBaseEntry then
          BE := CE as TgdBaseEntry
        else
          BE := nil;
      finally
        Free;
      end;
    end else
    begin
      BE := nil;
      MessageBox(Handle,
        'ƒанна€ таблица не €вл€етс€ базовой дл€ бизнес-класса.',
        '¬нимание',
        MB_OK or MB_ICONINFORMATION);
    end;
  finally
    OL.Free;
  end;

  if BE <> nil then
  begin
    F := BE.gdcClass.CreateViewForm(Application, '', BE.SubType, True);
    if Assigned(F) then
      F.Show
    else
      MessageBox(Handle,
        PChar(Format('ƒл€ класса %s и подтипа "%s" не определена форма просмотра.',
          [BE.TheClass.ClassName, BE.SubType])),
        '¬нимание',
        MB_OK or MB_ICONINFORMATION);
  end;
end;

procedure Tgdc_frmTable.actOpenTableUpdate(Sender: TObject);
begin
  actOpenTable.Enabled := Assigned(gdcObject)
    and (gdcObject.State = dsBrowse)
    and (gdcObject.RecordCount > 0);
end;

procedure Tgdc_frmTable.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMTABLE', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMTABLE', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMTABLE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMTABLE',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMTABLE' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  { TODO : тут нужно добавить код перекрыти€! }
  inherited;
  S.Add('ByRelation');
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMTABLE', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMTABLE', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmTable.actShowSQLEditorExecute(Sender: TObject);
begin
  with TfrmSQLEditorSyn.Create(Application) do
  begin
    FDatabase := gdcBaseManager.Database;
    ShowSQL('SELECT * FROM ' + gdcObject.FieldByName('relationname').AsString,
      nil, False);
  end;
end;

procedure Tgdc_frmTable.actShowSQLEditorUpdate(Sender: TObject);
begin
  actShowSQLEditor.Enabled := Assigned(gdcObject)
    and (not gdcObject.IsEmpty);
end;

initialization
  RegisterFrmClass(Tgdc_frmTable);

finalization
  UnRegisterFrmClass(Tgdc_frmTable);

end.
