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
    function GetFormCaptionPrefix: String; override;

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
  gd_security, IBSQL, gd_common_functions;

procedure Tgdc_dlgUserComplexDocument.atContainerRelationNames(
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
  DE: TgdDocumentEntry;
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
    DE := gdClassList.Get(TgdDocumentEntry, gdcObject.ClassName, gdcObject.SubType) as TgdDocumentEntry;
    if (DE.HeaderFunctionKey > 0) and (DE.LineFunctionKey <= 0) then
      (gdcObject as TgdcDocument).CreateEntry;
  end;

  inherited Post;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGUSERCOMPLEXDOCUMENT', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGUSERCOMPLEXDOCUMENT', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgUserComplexDocument.GetFormCaptionPrefix: String;
begin
  if gdcObject.State = dsInsert then
    Result := 'Добавление документа: '
  else if gdcObject.State = dsEdit then
    Result := 'Редактирование документа: '
  else
    Result := 'Просмотр документа: ';
end;

initialization
  RegisterFrmClass(Tgdc_dlgUserComplexDocument);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserComplexDocument);
end.
