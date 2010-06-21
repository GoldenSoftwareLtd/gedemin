
unit gdc_dlgCantCreateObject_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, StdCtrls, Db, ActnList, ExtCtrls, Menus;

type
  Tgdc_dlgCantCreateObject = class(Tgdc_dlgG)
    Memo1: TMemo;
    mObjectInfo: TMemo;
    rbSelect: TRadioButton;
    rbSelectAndUpdate: TRadioButton;
    rbReject: TRadioButton;
    rbEdit: TRadioButton;
    Bevel1: TBevel;
    OpenDialog1: TOpenDialog;
    procedure actOkExecute(Sender: TObject);

  protected
    function DlgModified: Boolean; override;

  public
    procedure SetupDialog; override;
  end;

var
  gdc_dlgCantCreateObject: Tgdc_dlgCantCreateObject;

implementation

{$R *.DFM}

uses
  gdc_dlgSelectObject_unit, gd_ClassList;

{ Tgdc_dlgCantCreateObject }

procedure Tgdc_dlgCantCreateObject.actOkExecute(Sender: TObject);
begin
  if rbEdit.Checked then
  begin
    if gdcObject.EditDialog then
    begin
      inherited;
      exit;
    end;
  end
  else if rbSelect.Checked or rbSelectAndUpdate.Checked then
  begin
    with Tgdc_dlgSelectObject.Create(Self) do
    try
      lkup.Database := gdcObject.Database;
      lkup.Transaction := gdcObject.Transaction;
      lkup.gdClassName := gdcObject.ClassName;

      if (ShowModal = mrOk) and (lkup.CurrentKey > '') then
      begin
        Self.gdcObject.Cancel;
        Self.gdcObject.ID := lkup.CurrentKeyInt;
        Self.ModalResult := mrOk;
        exit;
      end;
    finally
      Free;
    end;
  end;

  actCancel.Execute;
end;

function Tgdc_dlgCantCreateObject.DlgModified: Boolean;
begin
  Result := ModalResult = mrOk;
end;

procedure Tgdc_dlgCantCreateObject.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCANTCREATEOBJECT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCANTCREATEOBJECT', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCANTCREATEOBJECT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCANTCREATEOBJECT',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCANTCREATEOBJECT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if Assigned(gdcObject) then
    mObjectInfo.Lines.Text := Format(mObjectInfo.Lines.Text,
     [gdcObject.ObjectName, gdcObject.ClassName, gdcObject.SubType, gdcObject.ID]);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCANTCREATEOBJECT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCANTCREATEOBJECT', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}


end;

initialization
  //RegisterClass(Tgdc_dlgCantCreateObject);
  RegisterFrmClass(Tgdc_dlgCantCreateObject);

finalization
  UnRegisterFrmClass(Tgdc_dlgCantCreateObject);
end.
