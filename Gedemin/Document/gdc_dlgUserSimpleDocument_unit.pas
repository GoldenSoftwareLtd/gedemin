unit gdc_dlgUserSimpleDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Db, ActnList, StdCtrls, at_Container, at_Classes,
  Menus, gsIBLookupComboBox, ExtCtrls;

type
  Tgdc_dlgUserSimpleDocument = class(Tgdc_dlgTR)
    atContainer: TatContainer;
    pnlHolding: TPanel;
    lblCompany: TLabel;
    iblkCompany: TgsIBLookupComboBox;
    procedure atContainerRelationNames(Sender: TObject; Relations,
      FieldAliases: TStringList);
    procedure FormCreate(Sender: TObject);

  public
    procedure SetupDialog; override;
  end;

var
  gdc_dlgUserSimpleDocument: Tgdc_dlgUserSimpleDocument;

implementation

{$R *.DFM}

uses
  gdcClasses, Storages, gd_ClassList, gd_security, IBSQL, gdcBaseInterface,
  gdcBase, gd_common_functions;

{ Tgdc_dlgUserSimpleDocument }

procedure Tgdc_dlgUserSimpleDocument.atContainerRelationNames(
  Sender: TObject; Relations, FieldAliases: TStringList);
var
  I: Integer;
  CE: TgdClassEntry;
  RelationName, FieldName: String;
  SL: TStringList;
begin
  Assert(gdcObject <> nil);

  inherited;

  FieldAliases.Add('NUMBER');
  FieldAliases.Add('DOCUMENTDATE');

  SL := TStringList.Create;
  try
    CE := gdClassList.Get(TgdDocumentEntry, gdcObject.ClassName, gdcObject.SubType);

    while (CE.Parent is TgdDocumentEntry)
      and (TgdBaseEntry(CE).DistinctRelation <> 'GD_DOCUMENT') do
    begin
      SL.Add(TgdBaseEntry(CE).DistinctRelation);
      CE := CE.Parent;
    end;

    SL.Add('GD_DOCUMENT');

    for I := 0 to gdcObject.FieldCount - 1 do
    begin
      ParseFieldOrigin(gdcObject.Fields[I].Origin, RelationName, FieldName);
      if (SL.IndexOf(RelationName) > -1) and (Pos('USR$', FieldName) = 1) then
        FieldAliases.Add(gdcObject.Fields[I].FieldName);
    end;
  finally
    SL.Free;
  end;
end;

procedure Tgdc_dlgUserSimpleDocument.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSERSIMPLEDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSERSIMPLEDOCUMENT', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSERSIMPLEDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSERSIMPLEDOCUMENT',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSERSIMPLEDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  pnlHolding.Visible := IBLogin.IsHolding;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSERSIMPLEDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSERSIMPLEDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgUserSimpleDocument.FormCreate(Sender: TObject);
begin
  inherited;
  Assert(IBLogin <> nil);
  pnlHolding.Enabled := IBLogin.IsHolding;
  if pnlHolding.Enabled then
    iblkCompany.Condition := 'gd_contact.id IN (' + IBLogin.HoldingList + ')';
end;

initialization
  RegisterFrmClass(Tgdc_dlgUserSimpleDocument);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserSimpleDocument);
end.
