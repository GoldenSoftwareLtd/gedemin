unit gdc_dlgUserComplexDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, gdc_dlgHGR_unit, TB2Item, TB2Dock, TB2Toolbar, Grids,
  DBGrids, gsDBGrid, gsIBGrid, ExtCtrls, Menus, gd_MacrosMenu,
  gsIBLookupComboBox;

type
  Tgdc_dlgUserComplexDocument = class(Tgdc_dlgHGR)
    atContainer: TatContainer;
    gdMacrosMenu: TgdMacrosMenu;
    pnlHolding: TPanel;
    iblkCompany: TgsIBLookupComboBox;
    lblCompany: TLabel;
    procedure atContainerRelationNames(Sender: TObject; Relations,
      FieldAliases: TStringList);
    procedure actDetailNewExecute(Sender: TObject);
    procedure actDetailEditExecute(Sender: TObject);
    procedure actCancelUpdate(Sender: TObject);
    procedure actDetailMacroExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    FIsAutoCommit: Boolean;

  protected
    procedure SetupRecord; override;
    procedure Post; override;

  public
    procedure SetupDialog; override;
    function GetDetailBookmarkList: TBookmarkList; override;

    property IsAutoCommit: Boolean read FIsAutoCommit write FIsAutoCommit; 
  end;

var
  gdc_dlgUserComplexDocument: Tgdc_dlgUserComplexDocument;

implementation

{$R *.DFM}

uses
  gdcClasses, Storages, at_Classes,  gd_ClassList, gdcBase, gdcBaseInterface,
  gd_security, IBSQL;

procedure Tgdc_dlgUserComplexDocument.atContainerRelationNames(
  Sender: TObject; Relations, FieldAliases: TStringList);
var
  i: Integer;
  F: TatRelationField;
begin
  inherited;

  FieldAliases.Add('NUMBER');
  FieldAliases.Add('DOCUMENTDATE');
  for I := 0 to gdcObject.FieldCount - 1 do
  if ((AnsiCompareText(gdcObject.RelationByAliasName(gdcObject.Fields[I].FieldName),
    (gdcObject as TgdcUserBaseDocument).Relation) = 0) or
    (AnsiCompareText(gdcObject.RelationByAliasName(gdcObject.Fields[I].FieldName),
    'GD_DOCUMENT') = 0))
  then
  begin
    F := atDatabase.FindRelationField((gdcObject as TgdcUserBaseDocument).Relation,
      gdcObject.FieldNameByAliasName(gdcObject.Fields[I].FieldName));

    if not Assigned(F) then
      F := atDatabase.FindRelationField('GD_DOCUMENT',
        gdcObject.FieldNameByAliasName(gdcObject.Fields[I].FieldName));

    if Assigned(F) and F.IsUserDefined then
      FieldAliases.Add(gdcObject.Fields[I].FieldName);
  end;
end;

procedure Tgdc_dlgUserComplexDocument.actDetailNewExecute(Sender: TObject);
begin
  gdcDetailObject.Insert;
end;

procedure Tgdc_dlgUserComplexDocument.actDetailEditExecute(
  Sender: TObject);
begin
  gdcDetailObject.Edit;
end;

procedure Tgdc_dlgUserComplexDocument.actCancelUpdate(Sender: TObject);
begin
  //
  inherited;
end;

procedure Tgdc_dlgUserComplexDocument.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSERCOMPLEXDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSERCOMPLEXDOCUMENT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSERCOMPLEXDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSERCOMPLEXDOCUMENT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSERCOMPLEXDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if not IsAutoCommit then
    ActivateTransaction(gdcObject.Transaction);
  
  Caption := (gdcObject as TgdcUserBaseDocument).DocumentName[False];

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSERCOMPLEXDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSERCOMPLEXDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_dlgUserComplexDocument.actDetailMacroExecute(
  Sender: TObject);
var
  R: TRect;
begin
  with tbDetail do
  begin
    R := View.Find(tbMacro).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdMacrosMenu.Popup(R.Left, R.Bottom);
end;

procedure Tgdc_dlgUserComplexDocument.SetupDialog;
VAR
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSERCOMPLEXDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSERCOMPLEXDOCUMENT', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSERCOMPLEXDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSERCOMPLEXDOCUMENT',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSERCOMPLEXDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  pnlHolding.Visible := IBLogin.IsHolding;

  gdcDetailObject := nil;

  for i:= 0 to gdcObject.DetailLinksCount - 1 do
    if (gdcObject.DetailLinks[i] is TgdcUserDocumentLine) then
    begin
      gdcDetailObject := gdcObject.DetailLinks[i];
      Break;
    end;

  if not Assigned(gdcDetailObject) then
  begin
    gdcDetailObject := TgdcUserDocumentLine.Create(Self);
    gdcDetailObject.Database := gdcObject.Database;
    gdcDetailObject.Transaction := gdcObject.Transaction;
    gdcDetailObject.SubType := gdcObject.SubType;

    gdcDetailObject.SubSet := 'ByParent';
    gdcDetailObject.MasterField := 'ID';
    gdcDetailObject.DetailField := 'PARENT';
    gdcDetailObject.MasterSource := dsgdcBase;

  end;

  dsDetail.DataSet := gdcDetailObject;

  gdcDetailObject.Open;

  { TODO : странно. почему не в лоадсеттингс? а где сохраняется? }
  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibgrDetail, ibgrDetail.LoadFromStream);

  SetupGrid;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSERCOMPLEXDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSERCOMPLEXDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgUserComplexDocument.GetDetailBookmarkList: TBookmarkList;
begin
  Result := ibgrDetail.SelectedRows;
end;

procedure Tgdc_dlgUserComplexDocument.FormCreate(Sender: TObject);
begin
  Assert(IBLogin <> nil);
  inherited;
  pnlHolding.Enabled := IBLogin.IsHolding;
  if pnlHolding.Enabled then
    iblkCompany.Condition := 'gd_contact.id IN (' + IBLogin.HoldingList + ')';
end;

procedure Tgdc_dlgUserComplexDocument.Post;
var
  K: Integer;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGUSERCOMPLEXDOCUMENT', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGUSERCOMPLEXDOCUMENT', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGUSERCOMPLEXDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGUSERCOMPLEXDOCUMENT',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGUSERCOMPLEXDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if (gdcDetailObject.RecordCount > 0)
    and gdcDetailObject.FieldByName('transactionkey').IsNull then
  begin
    K := gdcObject.FieldByName('documenttypekey').AsInteger;
    if (DocTypeCache.CacheItemsByKey[K].HeaderFunctionKey > 0)
      and (DocTypeCache.CacheItemsByKey[K].LineFunctionKey <= 0) then
    begin
      (gdcObject as TgdcDocument).CreateEntry;
    end;
  end;

  inherited Post;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSERCOMPLEXDOCUMENT', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSERCOMPLEXDOCUMENT', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgUserComplexDocument);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserComplexDocument);
end.
