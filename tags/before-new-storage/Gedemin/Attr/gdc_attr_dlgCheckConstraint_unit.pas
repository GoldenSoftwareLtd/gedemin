unit gdc_attr_dlgCheckConstraint_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Menus, Db, ActnList, StdCtrls, Mask, DBCtrls, gdcMetaData;

type
  Tgdc_dlgCheckConstraint = class(Tgdc_dlgGMetaData)
    dbeCheckName: TDBEdit;
    lblCheckName: TLabel;
    lblCheckExpression: TLabel;
    dbCheckExpression: TDBMemo;
    dbMsg: TDBMemo;
    lbMsg: TLabel;
  protected
    procedure BeforePost; override;

  end;

var
  gdc_dlgCheckConstraint: Tgdc_dlgCheckConstraint;

implementation

uses at_classes, gd_ClassList;

{$R *.DFM}


{ Tgdc_dlgCheckConstraint }

procedure Tgdc_dlgCheckConstraint.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCHECKCONSTRAINT', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCHECKCONSTRAINT', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCHECKCONSTRAINT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCHECKCONSTRAINT',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCHECKCONSTRAINT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if (gdcObject.State = dsInsert) and
    (AnsiPos(UserPrefix, AnsiUpperCase(gdcObject.FieldByName('checkname').AsString)) <> 1)
  then
    gdcObject.FieldByName('checkname').AsString :=
      UserPrefix + 'CHECK_' + gdcObject.FieldByName('checkname').AsString;

  if (gdcObject.State = dsInsert) and (gdcObject is TgdcCheckConstraint) and
    (not (gdcObject as TgdcCheckConstraint).CheckName)
  then
  begin
    ActiveControl := dbeCheckName;
    raise Exception.Create('Наименование ограничения дублируется с уже существующим!');
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCHECKCONSTRAINT', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCHECKCONSTRAINT', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgCheckConstraint);

finalization
  UnRegisterFrmClass(Tgdc_dlgCheckConstraint);

end.
