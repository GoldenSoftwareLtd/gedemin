// ShlTanya, 03.02.2019

unit gdc_attr_dlgView_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgRelation_unit, SynEditHighlighter, SynHighlighterSQL, Db,
  ActnList, SynEdit, SynMemo, ComCtrls, TB2Item, TB2Dock, TB2Toolbar,
  Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls, DBCtrls, Mask, ExtCtrls,
  IBSQL, at_classes, IBDatabase, gdcMetaData, IBCustomDataSet, gdcBase,
  Menus, gsIBLookupComboBox, SynDBEdit;

type
  Tgdc_attr_dlgView = class(Tgdc_dlgRelation)
    tsView: TTabSheet;
    smViewBody: TSynMemo;
    actCreateView: TAction;
    procedure pcRelationChange(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);

  protected
    procedure BeforePost; override;

  public
    procedure SetupRecord; override;
  end;

var
  gdc_attr_dlgView: Tgdc_attr_dlgView;

implementation

{$R *.DFM}

uses
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgdc_attr_dlgView.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGVIEW', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGVIEW', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGVIEW',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGVIEW' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  gdcObject.FieldByName('view_source').AsString := smViewBody.Text;

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGVIEW', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGVIEW', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgView.pcRelationChange(Sender: TObject);
begin
  inherited;
  if (pcRelation.ActivePage = tsView) and (smViewBody.Text = '') then
  begin
    (gdcObject as TgdcRelation).CheckObjectName;

    if gdcObject.State = dsInsert then
      smViewBody.Text := Format(
        'CREATE OR ALTER VIEW %s (id, name)'#13#10 +
        'AS '#13#10 +
        '  SELECT id, name'#13#10 +
        '  FROM gd_contact'#13#10, [gdcObject.FieldByName('relationname').AsString])
    else
      smViewbody.Text := (gdcObject as TgdcView).GetViewTextBySource(gdcObject.FieldByName('view_source').AsString);

    btnOk.Default := False;
  end else
    btnOk.Default := True;
end;

procedure Tgdc_attr_dlgView.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGVIEW', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGVIEW', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGVIEW',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGVIEW' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  smViewBody.Text := '';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGVIEW', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGVIEW', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgView.actOkUpdate(Sender: TObject);
begin
  if Trim(smViewBody.Text) = '' then
    actOk.Enabled := False
  else
    inherited;
end;


initialization
  RegisterFrmClass(Tgdc_attr_dlgView);

finalization
  UnRegisterFrmClass(Tgdc_attr_dlgView);
end.
