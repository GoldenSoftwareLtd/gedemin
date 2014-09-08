
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_dlgInvPriceList_unit.pas

  Abstract

    Part of a business class. Dialog window for price lists.

  Author

    Romanovski Denis (23-10-2001)

  Revisions history

    Initial  23-10-2001  Dennis  Initial version.
             01-11-2001  sai     Переделаны методы выбоки

--}

unit gdc_dlgInvPriceList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgHGR_unit, Db, ActnList, TB2Item, TB2Dock, TB2Toolbar, Grids,
  DBGrids, gsDBGrid, gsIBGrid, gsIBCtrlGrid, ExtCtrls, StdCtrls,
  at_Container, gdcInvPriceList_unit, IBSQL, IBDatabase, Menus,
  gd_MacrosMenu;

type
  TdlgInvPriceList = class(Tgdc_dlgHGR)
    atAttributes: TatContainer;
    pnlInfo: TPanel;
    lblCurrencyInfo: TLabel;
    lblCurrency: TLabel;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem1: TTBItem;
    actGoodsRef: TAction;
    gdMacrosMenu: TgdMacrosMenu;

    procedure atAttributesRelationNames(Sender: TObject; Relations,
      FieldAliases: TStringList);

    procedure ibgrDetailColEnter(Sender: TObject);
    procedure ibgrDetailColExit(Sender: TObject);
    procedure actGoodsRefExecute(Sender: TObject);
    procedure actCancelUpdate(Sender: TObject);
    procedure actDetailMacroExecute(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);
    procedure actDetailEditExecute(Sender: TObject);

  private
    FCurrency: TIBSQL;
    FFirstDocumentLine: TgdcInvPriceListLine;

    procedure SetupMaster;
    procedure SetupDetail;

    procedure TestRequiredFields;

    function GetDocument: TgdcInvPriceList;
    function GetDocumentLine: TgdcInvPriceListLine;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function TestCorrect: Boolean; override;
    procedure SetupDialog; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    property Document: TgdcInvPriceList read GetDocument;
    property DocumentLine: TgdcInvPriceListLine read GetDocumentLine;

    class procedure RegisterClassHierarchy; override;

  end;

  EdlgInvPriceList = class(Exception);

var
  dlgInvPriceList: TdlgInvPriceList;

implementation

{$R *.DFM}

uses
  at_classes, gdcGood, Storages, gdcBase,  gd_ClassList,
  gdcBaseInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_dlgInvPriceList }

constructor TdlgInvPriceList.Create(AnOwner: TComponent);
begin
  inherited;

  FCurrency := TIBSQL.Create(nil);
  FCurrency.SQL.Text := 'SELECT NAME FROM GD_CURR WHERE ID = :ID';
end;

destructor TdlgInvPriceList.Destroy;
begin
  FCurrency.Free;

  inherited;
end;

function TdlgInvPriceList.GetDocument: TgdcInvPriceList;
begin
  Result := gdcObject as TgdcInvPriceList;
end;

function TdlgInvPriceList.GetDocumentLine: TgdcInvPriceListLine;
var
  i: Integer;
begin

  Result := nil;

  if Assigned(gdcObject) and (gdcObject.DetailLinksCount > 0) then
  begin
    for i:= 0 to gdcObject.DetailLinksCount - 1 do
      if gdcObject.DetailLinks[i] is TgdcInvPriceListLine then
        Result := gdcObject.DetailLinks[i] as TgdcInvPriceListLine;
  end;

  if not Assigned(Result) then
  begin
    if FFirstDocumentLine = nil then
    begin
      FFirstDocumentLine := TgdcInvPriceListLine.
        CreateSubType(Self, Document.SubType);

      FFirstDocumentLine.SubSet := 'ByParent';
      FFirstDocumentLine.MasterField := 'ID';
      FFirstDocumentLine.DetailField := 'PARENT';
      FFirstDocumentLine.MasterSource := dsgdcBase;
    end;

    Result := FFirstDocumentLine;

  end;
end;

procedure TdlgInvPriceList.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}var
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVPRICELIST', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVPRICELIST', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVPRICELIST',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibgrDetail, ibgrDetail.LoadFromStream, FSubType);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVPRICELIST', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVPRICELIST', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvPriceList.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVPRICELIST', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVPRICELIST', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVPRICELIST',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if UserStorage <> nil then
  begin
    UserStorage.SaveComponent(ibgrDetail, ibgrDetail.SaveToStream, FSubType);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVPRICELIST', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVPRICELIST', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvPriceList.SetupDetail;
var
  C: TgsIBColumnEditor;
  i: Integer;
  R: TatRelation;
begin
  C := ibgrDetail.ColumnEditors[
    ibgrDetail.ColumnEditors.IndexByField('GOODNAME')];

  if Assigned(C) then
  begin
    C.Lookup.Database := Document.Database;
    C.Lookup.Transaction := Document.Transaction;
  end;

  R := atDatabase.Relations.ByRelationName('INV_PRICELINE');

  if Assigned(R) then
  begin
    for i:= 0 to R.RelationFields.Count - 1 do
      if R.RelationFields[i].IsUserDefined and Assigned(R.RelationFields[i].References)
         and Assigned(R.RelationFields[i].Field) then
      begin
        C := ibgrDetail.ColumnEditors.Add;
        C.EditorStyle := cesLookup;
        C.FieldName := R.RelationFields[i].FieldName;
        C.Lookup.LookupTable := R.RelationFields[i].Field.RefTable.RelationName;
        C.Lookup.LookupListField := R.RelationFields[i].Field.RefListField.FieldName;
        C.Lookup.LookupKeyField := R.RelationFields[i].References.PrimaryKey.ConstraintFields[0].FieldName;
        C.Lookup.Condition := R.RelationFields[i].Field.RefCondition;
        C.Lookup.Transaction := ibtrCommon;
        try
          C.DisplayField := gdcBaseManager.AdjustMetaName('PL_' + R.RelationFields[i].FieldName + '_' +
            R.RelationFields[i].Field.RefListFieldName);
        except
          C.Free;
//          C := nil;
        end;

      end;
  end;

  
end;

procedure TdlgInvPriceList.SetupMaster;
begin
  lblCurrency.Caption := '';
  lblCurrency.Visible := False;
  lblCurrencyInfo.Visible := False;


  FCurrency.Database := Document.Database;
  FCurrency.Transaction := Document.ReadTransaction;

  if (Document.State = dsInsert) then
  begin
    try
      Document.PrePostDocumentData;
    except
      on E: Exception do
      begin
        Document.Cancel;
        MessageBox(HANDLE, PChar(E.Message), 'Внимание', MB_OK or MB_ICONINFORMATION);
        MessageBox(HANDLE, 'Нельзя добавить запись! Возможно идет настройка документа, обратитесь к Администратору',
          'Внимание', MB_OK or MB_ICONINFORMATION);
        ErrorAction := True;
        PostMessage(HANDLE, wm_Close, 0, 0);
 //       abort;
      end;  
    end;
  end;
  
end;

function TdlgInvPriceList.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TDLGINVPRICELIST', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TDLGINVPRICELIST', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVPRICELIST') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVPRICELIST',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TDLGINVPRICELIST' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := True;
  
  try
    // Проверяем поля на значения
    TestRequiredFields;

    // Сохраняем шапку документа
    if Document.State in [dsEdit, dsInsert] then
      Document.Post;

    // Сохраняем позиции документа
    DocumentLine.ApplyUpdates;
  except
    on Exception do
    begin
      // Возвращаем режим редактрования
      if not (Document.State in [dsEdit, dsInsert]) then
        Document.Edit;

      // Окрываем позиции документа
      DocumentLine.Active := True;

      ModalResult := mrNone;

      raise;
    end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVPRICELIST', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVPRICELIST', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvPriceList.atAttributesRelationNames(Sender: TObject;
  Relations, FieldAliases: TStringList);
var
  I: Integer;
  F: TatRelationField;
begin

  //
  // Добавляем поля

  FieldAliases.Add('NUMBER');
  FieldAliases.Add('DOCUMENTDATE');
  FieldAliases.Add('RELEVANCEDATE');
  FieldAliases.Add('NAME');
  FieldAliases.Add('DESCRIPTION');

  for I := 0 to Document.FieldCount - 1 do
    if (AnsiCompareText(
      Document.RelationByAliasName(Document.Fields[I].FieldName),
      'INV_PRICE') = 0) then
    begin
      F := atDatabase.FindRelationField('INV_PRICE',
        Document.FieldNameByAliasName(Document.Fields[I].FieldName));

      if F.IsUserDefined then
        FieldAliases.Add(Document.Fields[I].FieldName);
    end;
end;

procedure TdlgInvPriceList.TestRequiredFields;
var
  I: Integer;
  R: TatRelation;
  F: TatRelationField;
begin
  for I := 0 to Document.FieldCount - 1 do
  begin
    R := atDatabase.Relations.ByRelationName(
      Document.RelationByAliasName(Document.Fields[I].FieldName));

    if not Assigned(R) then Continue;

    F := R.RelationFields.ByFieldName(
      Document.FieldNameByAliasName(Document.Fields[I].FieldName));

    if not Assigned(F) or not F.IsUserDefined then Continue;

    if Document.Fields[I].IsNull and not F.Field.IsNullable and
      Document.Fields[I].Required
    then
      raise EdlgInvPriceList.CreateFmt('Не введено значение в поле "%s"!',
        [F.LShortName]);
  end;
end;

procedure TdlgInvPriceList.ibgrDetailColEnter(Sender: TObject);
var
  I: Integer;
begin
  inherited;  

  if ibgrDetail.SelectedField = nil then Exit;

  for I := 0 to Length(DocumentLine.LineFields) - 1 do
    if AnsiCompareText(
      DocumentLine.LineFields[I].FieldName,
      DocumentLine.FieldNameByAliasName(ibgrDetail.SelectedField.FieldName)) = 0 then
    begin
      if DocumentLine.LineFields[I].CurrencyKey <> -1 then
      begin
        lblCurrency.Visible := True;
        lblCurrencyInfo.Visible := True;

        FCurrency.ParamByName('ID').AsInteger := DocumentLine.LineFields[I].CurrencyKey;
        FCurrency.ExecQuery;

        lblCurrency.Caption := FCurrency.Fields[0].AsString;
        FCurrency.Close;
      end else begin
        lblCurrency.Visible := False;
        lblCurrencyInfo.Visible := False;
      end;
    end;
end;

procedure TdlgInvPriceList.ibgrDetailColExit(Sender: TObject);
begin
  inherited;

  lblCurrency.Visible := False;
  lblCurrencyInfo.Visible := False;
end;

procedure TdlgInvPriceList.actGoodsRefExecute(Sender: TObject);
var
  Good: TgdcGood;
  V: OleVariant;
  I: Integer;
begin
  //
  // Осуществляем выбор товаров из справочника

  Good := TgdcGood.Create(nil);

  try
    if Good.ChooseItems(V, 'gdcGood') then
    begin
      for I := 0 to VarArrayHighBound(V, 1) do
      begin
      {Чтобы добавление шло по порядку делаем Append, а не Insert}
        DocumentLine.Append;
        DocumentLine.FieldByName('goodkey').AsInteger := V[I];
        DocumentLine.UpdateGoodNames;
        DocumentLine.Post;
      end;
    end;
  finally
    Good.Free;
  end;
end;

class procedure TdlgInvPriceList.RegisterClassHierarchy;

  procedure ReadFromDocumentType(ACE: TgdClassEntry);
  var
    CurrCE: TgdClassEntry;
    ibsql: TIBSQL;
    LSubType: string;
    LComment: String;
    LParentSubType: string;
  begin
    if ACE.Initialized then
      exit;

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text :=
        'SELECT '#13#10 +
        '  dt.name AS comment, '#13#10 +
        '  dt.classname AS classname, '#13#10 +
        '  dt.ruid AS subtype, '#13#10 +
        '  dt1.ruid AS parentsubtype '#13#10 +
        'FROM gd_documenttype dt '#13#10 +
        'LEFT JOIN gd_documenttype dt1 '#13#10 +
        '  ON dt1.id = dt.parent '#13#10 +
        '  AND dt1.documenttype = ''D'' '#13#10 +
        'WHERE '#13#10 +
        '  dt.documenttype = ''D'' '#13#10 +
        '  and dt.classname = ''TgdcInvPriceListType'' '#13#10 +  
        'ORDER BY dt.parent';

      ibsql.ExecQuery;

      while not ibsql.EOF do
      begin
        LSubType := ibsql.FieldByName('subtype').AsString;
        LComment := ibsql.FieldByName('comment').AsString;
        LParentSubType := ibsql.FieldByName('parentsubtype').AsString;

        CurrCE := gdClassList.Add(ACE.TheClass, LSubType, LComment, LParentSubType);

        CurrCE.Initialized := True;
        ibsql.Next;
      end;
    finally
      ibsql.Free;
    end;

    ACE.Initialized := True;
  end;

var
  CEBase: TgdClassEntry;

begin
  CEBase := gdClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromDocumentType(CEBase);
end;

procedure TdlgInvPriceList.actCancelUpdate(Sender: TObject);
begin
  inherited;

  {
  actCancel.Enabled :=
    not (DocumentLine.State in dsEditModes);
  }
end;

procedure TdlgInvPriceList.actDetailMacroExecute(Sender: TObject);
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

procedure TdlgInvPriceList.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVPRICELIST', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVPRICELIST', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVPRICELIST') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVPRICELIST',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVPRICELIST' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  gdcDetailObject := DocumentLine;
  dsDetail.DataSet := gdcDetailObject;

  SetupMaster;
  SetupDetail;

  ActivateTransaction(gdcObject.Transaction);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVPRICELIST', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVPRICELIST', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvPriceList.actDetailNewExecute(Sender: TObject);
begin
  gdcDetailObject.Insert;
end;

procedure TdlgInvPriceList.actDetailEditExecute(Sender: TObject);
begin
  gdcDetailObject.Edit
end;

initialization
  RegisterFrmClass(TdlgInvPriceList);

finalization
  UnRegisterFrmClass(TdlgInvPriceList);

end.

