
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_dlgInvDocument_unit.pas

  Abstract           

    Part of a business class. Dialog window for
    edition of inventory document.

  Author

    Romanovski Denis (23-09-2001)

  Revisions history

    Initial  23-09-2001  Dennis  Initial version.
             01-11-2001  sai     Переделаны методы выбоки
             14-11-2001  Michael Доработаны лукапы для выбора значений из карточек
--}

unit gdc_dlgInvDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, Db, ActnList, StdCtrls, ExtCtrls, at_Container,
  gdcInvDocument_unit, DBGrids, gsDBGrid, gsIBGrid, IBDatabase, IBSQL,
  Mask, xDateEdits, DBCtrls, gdcBase, gdcContacts, TB2Dock, TB2Toolbar,
  TB2Item, contnrs, Menus, gsIBLookupComboBox, gd_MacrosMenu, Grids;

type
  TdlgInvDocument = class(Tgdc_dlgTR)
    pnlMain: TPanel;
    sptMain: TSplitter;
    pnlAttributes: TPanel;
    Bevel1: TBevel;
    pnlCommonAttributes: TPanel;
    atAttributes: TatContainer;
    pnlCommon: TPanel;
    pnlGrids: TPanel;
    TBDockLeft: TTBDock;
    TBDockRight: TTBDock;
    TBDockBottom: TTBDock;
    TBDockTop: TTBDock;
    alMain: TActionList;
    actDetailNew: TAction;
    actDetailEdit: TAction;
    actDetailDelete: TAction;
    tbDetailToolbar: TTBToolbar;
    tbiDetailNew: TTBItem;
    tbiDetailEdit: TTBItem;
    tbiDetailDelete: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    tbMacro: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    actGoodsRef: TAction;
    actRemainsRef: TAction;
    actMacro: TAction;
    actSelectGood: TAction;
    TBItem4: TTBItem;
    actCommit: TAction;
    TBItem5: TTBItem;
    pmDetailMenu: TPopupMenu;
    gdMacrosMenu: TgdMacrosMenu;
    actPrint: TAction;
    tbiPrint: TTBItem;
    N8: TMenuItem;
    TBItem1: TTBItem;
    actAddGoodsWithQuant: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    actDetailSecurity: TAction;
    tbiDetailSecurity: TTBItem;
    pmDetail2: TPopupMenu;
    MenuItem1: TMenuItem;
    pnlHolding: TPanel;
    lblCompany: TLabel;
    iblkCompany: TgsIBLookupComboBox;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    actViewCard: TAction;
    TBItem6: TTBItem;
    ibgrdTop: TgsIBGrid;
    actViewFullCard: TAction;
    TBItem7: TTBItem;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure actGoodsRefExecute(Sender: TObject);
    procedure actRemainsRefExecute(Sender: TObject);
    procedure actMacroExecute(Sender: TObject);

    procedure atAttributesRelationNames(Sender: TObject; Relations,
      FieldAliases: TStringList);
    procedure atAttributesAdjustControl(Sender: TObject;
      Control: TControl);
    procedure actSelectGoodExecute(Sender: TObject);

    procedure actDetailNewExecute(Sender: TObject);
    procedure actDetailEditExecute(Sender: TObject);
    procedure actDetailDeleteExecute(Sender: TObject);

    procedure actDetailNewUpdate(Sender: TObject);
    procedure actDetailEditUpdate(Sender: TObject);
    procedure actDetailDeleteUpdate(Sender: TObject);

    procedure actGoodsRefUpdate(Sender: TObject);
    procedure actRemainsRefUpdate(Sender: TObject);
    procedure actSelectGoodUpdate(Sender: TObject);
    procedure actCancelUpdate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);

    procedure SetCardFieldCondition(CurrDocLine: TgdcInvDocumentLine;
                GoodKey: Integer);
    procedure actCommitExecute(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actPrintUpdate(Sender: TObject);
    procedure actAddGoodsWithQuantUpdate(Sender: TObject);
    procedure actAddGoodsWithQuantExecute(Sender: TObject);
    procedure actDetailSecurityUpdate(Sender: TObject);
    procedure actDetailSecurityExecute(Sender: TObject);
    procedure actCommitUpdate(Sender: TObject);
    procedure actViewCardExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actViewFullCardExecute(Sender: TObject);
    procedure actViewCardUpdate(Sender: TObject);

  private
    //FTopGrid: TgsIBGrid;
    FBottomGrid: TgsIBGrid;

    FTopDataSource: TDataSource;
    FBottomDataSource: TDataSource;

    FFirstDocumentLine: TgdcInvDocumentLine;
    FSecondDocumentLine: TgdcInvDocumentLine;

    FIsClosing: Boolean;
    FIsLocalChange: Boolean;
    FIsInsertMode: Boolean;

    FOldOnChangeEventList: TObjectList;
    FOldDocOnChangeEventList: TObjectList;

    OldAfterEditDocument: TDataSetNotifyEvent;
    OldOnNewRecordDocument: TDataSetNotifyEvent;
    OldAfterPostDocument: TDataSetNotifyEvent;
    OldAfterCancelDocument: TDataSetNotifyEvent;
    OldAfterOpenDocument: TDataSetNotifyEvent;
    FIsAutoCommit: Boolean;

    procedure BackGdcObjectsResetState;

    function GetDocument: TgdcInvDocument;
    function GetDocumentLine: TgdcInvDocumentLine;
    function GetSecondDocumentLine: TgdcInvDocumentLine;

    procedure SetupDetailPart;

    procedure SetupGrid(Grid: TgsIBGrid);

    procedure TestRequiredFields;
    procedure CheckDisabledPosition;  // Проверка не осталось ли позиций по которым не было сформировано движение

    procedure OnSubMovementOptionFieldChange(Field: TField);
    procedure OnSubLineMovementOptionFieldChange(Field: TField);

    {Событие на изменение товара}
    procedure OnGoodKeyFieldChange(Field: TField);

    procedure DoAfterEditDocument(DataSet: TDataSet);
    procedure DoOnNewRecordDocument(DataSet: TDataSet);
    procedure DoAfterPostDocument(DataSet: TDataSet);
    procedure DoAfterCancelDocument(DataSet: TDataSet);
    procedure DoAfterOpenDocument(DataSet: TDataSet);

    procedure RunOldOnChange(Field: TField);
    procedure SetOldEvent;
    procedure DoCreateNewObject(Sender: TObject; ANewObject: TgdcBase);
    procedure SetIsInsertMode(const Value: Boolean);
    function GetIsInsertMode: Boolean;
    function GetTopGrid: TgsIBGrid;

  protected
    procedure Post; override;
    procedure SetupRecord; override;
    procedure SetupDialog; override;
    procedure SetupTransaction; override;

    function GetFormCaptionPrefix: String; override;

  public
    constructor Create(AnOwner: TComponent); override;
    constructor CreateNewUser(AnOwner: TComponent; const Dummy: Integer; const ASubType: String = ''); override;
    constructor CreateUser(AnOwner: TComponent;
      const AFormName: String; const ASubType: String = ''; const AForEdit: Boolean = False); override;

    destructor Destroy; override;

    procedure LoadSettings; override;

    function TestCorrect: Boolean; override;

    procedure SaveSettings; override;

    property Document: TgdcInvDocument read GetDocument;
    property DocumentLine: TgdcInvDocumentLine read GetDocumentLine;
    property SecondDocumentLine: TgdcInvDocumentLine read GetSecondDocumentLine;
    property IsInsertMode: Boolean read GetIsInsertMode write SetIsInsertMode;
    property IsAutoCommit: Boolean read FIsAutoCommit write FIsAutoCommit default False;

    property TopGrid: TgsIBGrid read GetTopGrid;

    function Get_SelectedKey: OleVariant; override; safecall;
  end;


  EdlgInvDocument = class(Exception);

var
  dlgInvDocument: TdlgInvDocument;

implementation

{$R *.DFM}

uses
  gdcInvConsts_unit, gdcInvMovement, at_classes, gdcGood,
  gd_Security, Storages, evt_i_Base,  gd_ClassList, gdcBaseInterface,
  gsStorage_CompPath, gdc_frmInvSelectedGoods_unit, JclStrings,
  ComCtrls, gdc_frmInvCard_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

type
  TWinControlCrack = class(TWinControl);

  TInvEventSave = class
    Field: TField;
    OldEvent: TFieldNotifyEvent;
    constructor Create(aField: TField);
    procedure SetOld;
  end;

{ TInvEventSave }

constructor TInvEventSave.Create(aField: TField);
begin
  Field := aField;
  OldEvent := aField.OnChange;
end;

procedure TInvEventSave.SetOld;
begin
  Field.OnChange := OldEvent;
end;

function GetArrAsCommaText(Ar: array of Integer): String;
var
  I: Integer;
begin
  Result := '';

  for I := Low(Ar) to High(Ar) do
  begin
    Result := Result + IntToStr(Ar[I]);

    if I < High(Ar) then
      Result := Result + ', ';
  end;
end;

{ TdlgInvDocument }

constructor TdlgInvDocument.Create(AnOwner: TComponent);
begin
  inherited;
  FIsAutoCommit := False;
  FIsClosing := False;
  FIsLocalChange := False;
  FIsInsertMode := False;

  OldAfterEditDocument := nil;
  OldOnNewRecordDocument := nil;
  OldAfterPostDocument := nil;
  OldAfterCancelDocument := nil;
  OldAfterOpenDocument := nil;

  FOldOnChangeEventList := TObjectList.Create;
  FOldDocOnChangeEventList := TObjectList.Create;

//  FTopGrid := nil;
  FBottomGrid := nil;

  FTopDataSource := nil;
  FBottomDataSource := nil;

  FFirstDocumentLine := nil;
  FSecondDocumentLine := nil;
end;

destructor TdlgInvDocument.Destroy;
begin
  if not FIsClosing and Assigned(DocumentLine) then BackGdcObjectsResetState;

  if Assigned(FOldOnChangeEventList) then
    FreeAndNil(FOldOnChangeEventList);

  if Assigned(FOldDocOnChangeEventList) then
    FreeAndNil(FOldDocOnChangeEventList);

  inherited;
end;

function TdlgInvDocument.GetDocument: TgdcInvDocument;
begin
  Result := gdcObject as TgdcInvDocument;
end;

function TdlgInvDocument.GetDocumentLine: TgdcInvDocumentLine;
var
  i: Integer;
begin
  if not Assigned(FFirstDocumentLine) and Assigned(gdcObject) then
  begin
    for i:= 0 to gdcObject.DetailLinksCount - 1 do
      if gdcObject.DetailLinks[0] is TgdcInvDocumentLine then
        FFirstDocumentLine := gdcObject.DetailLinks[0] as TgdcInvDocumentLine;
    //
    // Если позиции нет вообще - осуществляем ее динамическое создание

    if FFirstDocumentLine = nil then
    begin
      FFirstDocumentLine := TgdcInvDocumentLine.
        CreateSubType(Self, Document.SubType);

      FFirstDocumentLine.SubSet := 'ByParent';
      FFirstDocumentLine.MasterField := 'ID';
      FFirstDocumentLine.DetailField := 'PARENT';
      FFirstDocumentLine.MasterSource := dsgdcBase;
    end;
  end;
  Result := FFirstDocumentLine;
end;

procedure TdlgInvDocument.SetupDetailPart;
var
  Splitter: TSplitter;
  i: Integer;
  {$IFDEF DEBUG}
  T: DWORD;
  {$ENDIF}
begin
  //
  // В зависимости от настроек отображаем
  // или один или два грида

  {Сохраним первоначальные обработчики событий на позиции документа}
  OldAfterEditDocument := DocumentLine.AfterEdit;
  OldOnNewRecordDocument := DocumentLine.OnNewRecord;
  OldAfterPostDocument := DocumentLine.AfterPost;
  OldAfterCancelDocument := DocumentLine.AfterCancel;
  OldAfterOpenDocument := DocumentLine.AfterOpen;

  {Сохраним первоначальные обработчики события OnChange на поля позиции документа}
  for i:= 0 to DocumentLine.FieldCount - 1 do
    FOldOnChangeEventList.Add(TInvEventSave.Create(DocumentLine.Fields[i]));

  DocumentLine.AfterEdit := DoAfterEditDocument;
  DocumentLine.OnNewRecord := DoOnNewRecordDocument;
  DocumentLine.AfterPost := DoAfterPostDocument;
  DocumentLine.AfterCancel := DoAfterCancelDocument;
  DocumentLine.AfterOpen := DoAfterOpenDocument;

  if Document.RelationType <> irtTransformation then
  begin
    //
    // Создаем DataSource, Grid, вставляем их в панель

    FTopDataSource := TDataSource.Create(Self);
    FTopDataSource.Name := 'FTopDataSource';

    FTopDataSource.DataSet := DocumentLine;

//    FTopGrid := TgsIBGrid.Create(Self);
//    FTopGrid.Align := alClient;
//    FTopGrid.Name := 'ibgrdTop';

    {$IFDEF DEBUG}
    T := GetTickCount;
    {$ENDIF}

//    pnlGrids.InsertControl(FTopGrid);
    ibgrdTop.DataSource := FTopDataSource;

    FBottomDataSource := nil;
    FBottomGrid := nil;

//    FTopGrid.PopupMenu := pmDetailMenu;
    SetupGrid(ibgrdTop);

    {$IFDEF DEBUG}
    OutputDebugString(PChar('Setup grid, ms: ' + IntToStr(GetTickCount - T)));
    {$ENDIF}
  end else
  begin

    DocumentLine.Close;
    DocumentLine.ViewMovementPart := impIncome;
    DocumentLine.Open;

    //
    //  Создаем TgdcInvDocumentLine объект, настраиваем его

    FSecondDocumentLine :=
      TgdcInvDocumentLine.CreateSubType(Self, Document.SubType);
    FSecondDocumentLine.MasterField := 'ID';
    FSecondDocumentLine.DetailField := 'PARENT';
    FSecondDocumentLine.SubSet := 'ByParent';
    FSecondDocumentLine.MasterSource := dsgdcBase;
    FSecondDocumentLine.Name := 'FSecondDocumentLine';
    FSecondDocumentLine.isMinusRemains := False;

    FSecondDocumentLine.Close;
    FSecondDocumentLine.ReadTransaction := DocumentLine.ReadTransaction;
    FSecondDocumentLine.Transaction := DocumentLine.Transaction;
    FSecondDocumentLine.ViewMovementPart := impExpense;
    FSecondDocumentLine.Active := True;

{    for i:= 0 to FSecondDocumentLine.FieldCount - 1 do
      FOldOnChangeEventList.Add(TInvEventSave.Create(FSecondDocumentLine.Fields[i]));}

    FSecondDocumentLine.AfterEdit := DoAfterEditDocument;
    FSecondDocumentLine.OnNewRecord := DoOnNewRecordDocument;
    FSecondDocumentLine.AfterPost := DoAfterPostDocument;
    FSecondDocumentLine.AfterCancel := DoAfterCancelDocument;

    //
    // Настраиваем dataset-ы и grid-ы

    FTopDataSource := TDataSource.Create(Self);
    FTopDataSource.Name := 'FTopDataSource';
    FTopDataSource.DataSet := DocumentLine;

//    FTopGrid := TgsIBGrid.Create(Self);
    ibgrdTop.Align := alTop;
    ibgrdTop.Top := 0;
    ibgrdTop.Height := pnlGrids.Height div 2;
    ibgrdTop.Constraints.MinHeight := 10;
//    FTopGrid.Name := 'ibgrdTop';

//    pnlGrids.InsertControl(FTopGrid);
    ibgrdTop.DataSource := FTopDataSource;

    Splitter := TSplitter.Create(Self);
    Splitter.Align := alTop;
    Splitter.Top := ibgrdTop.Top + ibgrdTop.Height;
    pnlGrids.InsertControl(Splitter);

    FBottomDataSource := TDataSource.Create(Self);
    FBottomDataSource.Name := 'FBottomDataSource';
    FBottomDataSource.DataSet := SecondDocumentLine;

    FBottomGrid := TgsIBGrid.Create(Self);
    FBottomGrid.Align := alClient;
    FBottomGrid.Top := pnlGrids.Height div 2;
    FBottomGrid.Height := pnlGrids.Height div 2;
    FBottomGrid.Constraints.MinHeight := 10;
    FBottomGrid.BorderStyle := bsNone;
    FBottomGrid.Name := 'ibgrdBottom';

    pnlGrids.InsertControl(FBottomGrid);
    FBottomGrid.DataSource := FBottomDataSource;

//    FTopGrid.PopupMenu := pmDetailMenu;
    SetupGrid(ibgrdTop);
    FBottomGrid.PopupMenu := pmDetail2;
    SetupGrid(FBottomGrid);
  end;
end;


function TdlgInvDocument.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TDLGINVDOCUMENT', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TDLGINVDOCUMENT', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENT',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENT' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  //Result := True;

//  try
  Result := inherited TestCorrect;

  if Result then
    TestRequiredFields;


{  except
    on Exception do
    begin
      // Возвращаем режим редактрования
      if not (Document.State in [dsEdit, dsInsert]) then
        Document.Edit;

      // Окрываем позиции документа
      DocumentLine.Active := True;

      // Окрываем позиции расхода при документе - трансформация
      if Document.RelationType = irtTransformation then
        FSecondDocumentLine.Active := True;

      ModalResult := mrNone;

      raise;
    end;
  end;  }
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENT', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENT', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvDocument.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;

  FIsClosing := True;

  BackGdcObjectsResetState;
end;

procedure TdlgInvDocument.actGoodsRefExecute(Sender: TObject);
var
  Good: TgdcGood;
  CurrDocLine: TgdcInvDocumentLine;
  V: OleVariant;
  I: Integer;

begin
  if ibgrdTop.Focused or not Assigned(FBottomGrid) then
  begin
    if ibgrdTop.CanFocus then
      ibgrdTop.SetFocus;
    CurrDocLine := DocumentLine;
  end else
  if FBottomGrid.Focused then
    CurrDocLine := FSecondDocumentLine
  else
    Exit;

  //
  // Осуществляем выбор товаров из справочника

  Good := TgdcGood.Create(Self);
  try
    if Good.ChooseItems(V, 'gdcGood') and actOk.Enabled then
    begin
      for I := 0 to VarArrayHighBound(V, 1) do
      begin
        CurrDocLine.Append;
        CurrDocLine.FieldByName('goodkey').AsInteger := V[I];

        if Documentline.RelationType = irtTransformation then
        begin
          if CurrDocLine.ViewMovementPart = impIncome then
            CurrDocLine.FieldByName('inquantity').AsInteger := 1
          else
            CurrDocLine.FieldByName('outquantity').AsInteger := 1
        end
        else
          CurrDocLine.FieldByName('quantity').AsInteger := 1;

        CurrDocLine.UpdateGoodNames;
        CurrDocLine.Post;
      end;
    end;
  finally
    Good.Free;
  end;
end;

procedure TdlgInvDocument.actRemainsRefExecute(Sender: TObject);
begin
  if ibgrdTop.Focused or not Assigned(FBottomGrid) then
  begin
    if ibgrdTop.CanFocus then
      ibgrdTop.SetFocus;
    DocumentLine.ChooseRemains;
  end else
  if FBottomGrid.Focused then
  begin
    FSecondDocumentLine.ChooseRemains;
  end;
end;

procedure TdlgInvDocument.actMacroExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbDetailToolbar do
  begin
    R := View.Find(tbMacro).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdMacrosMenu.Popup(R.Left, R.Bottom);
end;

procedure TdlgInvDocument.SetupGrid(Grid: TgsIBGrid);
var
  I, J: Integer;
  R: TatRelation;
  F: TatRelationField;
  C: TgsIBColumnEditor;
  S: String;
  E1, E2: TFieldNotifyEvent;

  IsAsConstraint: Boolean;
  HasConstraint: Boolean;
  ContactType: TgdcInvMovementContactType;
  Predefined, AliasName: String;
  CurrDocLine: TgdcInvDocumentLine;
  Alias: String;

begin

  UserStorage.LoadComponent(Grid, Grid.LoadFromStream, FSubType);
  Alias := '';
  // Следующая строчка - бред, но без нее delphi валит хинты...
  ContactType := imctOurCompany;

  CurrDocLine := Grid.DataSource.DataSet as TgdcInvDocumentLine;

  Grid.Options := Grid.Options + [dgMultiSelect];
  {Очищаем настройки грида!!!! Подобный код не позволяет настраивать форму в редакторе форм}
  Grid.ColumnEditors.Clear;
  Grid.Striped := True;

  //
  // Страндартные контролы

  //
  // Выбор из справочника товаров

{Колонка типа калькулятор для поля QUANTITY}
  C := Grid.ColumnEditors.Add;
  C.EditorStyle := cesCalculator;
  C.DisplayField := 'QUANTITY';
  C.FieldName := 'QUANTITY';

{Колонка-лукап для справочника товаров}
  C := Grid.ColumnEditors.Add;
  C.EditorStyle := cesLookup;
  C.DisplayField := 'GOODNAME';
  C.FieldName := 'GOODKEY';
  C.Lookup.LookupListField := 'NAME';
  C.Lookup.LookupKeyField := 'ID';
  C.Lookup.LookupTable := 'GD_GOOD';
  C.Lookup.gdClassName := 'TgdcGood';
  C.Lookup.SortOrder := gsIBGrid.soAsc;
  C.Lookup.Transaction := ibtrCommon;

{Колонка-лукап для справочника товаров}
  C := Grid.ColumnEditors.Add;
  C.EditorStyle := cesLookup;
  C.DisplayField := 'GOODALIAS';
  C.FieldName := 'GOODKEY';
  C.Lookup.LookupListField := 'ALIAS';
  C.Lookup.LookupKeyField := 'ID';
  C.Lookup.LookupTable := 'GD_GOOD';
  C.Lookup.gdClassName := 'TgdcGood';
  C.Lookup.Transaction := ibtrCommon;


  if CurrDocLine.isChangeCardValue then
    CurrDocLine.FieldByName('goodkey').OnChange := OnGoodKeyFieldChange;

  //
  // Контролы для атрибутов


  for I := 0 to CurrDocLine.FieldCount - 1 do
  begin
    {Если это:
      1)вычисляемое поле или
      2) поле не пользовательское,
      то переходим к следующему полю}
    if CurrDocLine.Fields[I].Calculated or
      (StrIPos(UserPrefix, CurrDocLine.FieldNameByAliasName(
        CurrDocLine.Fields[I].FieldName)) <> 1)
    then
    Continue;

    try
      R := atDatabase.Relations.ByRelationName(
        CurrDocLine.RelationByAliasName(CurrDocLine.Fields[I].FieldName));

      if not Assigned(R) then Continue;

      F := R.RelationFields.ByFieldName(CurrDocLine.FieldNameByAliasName(
        CurrDocLine.Fields[I].FieldName));

      if not Assigned(F) then Continue;

  { Если это входные поля карточки то подставляем Lookup для выбора из доступных значений карточки }

      if (AnsiCompareText(R.RelationName, 'INV_CARD') = 0) and
         (Pos('FROM_', CurrDocLine.Fields[I].FieldName) = 1)

      then
      begin
        if (CurrDocLine.IsChangeCardValue and not CurrDocLine.IsAppendCardValue) then
        begin
          if F.References <> nil then
          begin
            {Если у нас есть ссылка}
            C := Grid.ColumnEditors.Add;
            C.EditorStyle := cesLookup;
            C.FieldName := CurrDocLine.Fields[I].FieldName;

            {Установка лист-таблицы, класса, поля отображения}
            if F.gdClassName > '' then
            begin
              C.Lookup.SubType := F.gdSubType;
              C.Lookup.gdClassName := F.gdClassName;
            end else begin
              if Assigned(F.Field.RefListField) then
                C.Lookup.LookupListField := F.Field.RefListField.FieldName
              else
                C.Lookup.LookupListField := F.References.ListField.FieldName;

              C.Lookup.LookupKeyField := F.References.PrimaryKey.
                ConstraintFields[0].FieldName;
              C.Lookup.LookupTable := F.References.RelationName;
            end;

            {Поле, в котором будет отбражаться контрол}
            C.DisplayField := gdcBaseManager.AdjustMetaName(CurrDocLine.JoinListFieldByFieldName(F.FieldName, 'CARD', C.Lookup.LookupListField));

            {Установка первоначального условия (из класса)}
            if Assigned(F.Field) and (F.Field.RefCondition > '') then
              C.Lookup.Condition := F.Field.RefCondition;

            C.Lookup.Transaction := ibtrCommon;
          end
          else
          begin

            case F.Field.FieldType of

              //
              // Логические данные
              ftBoolean:
              begin
                C := Grid.ColumnEditors.Add;
                C.EditorStyle := cesValueList;
                C.DisplayField := CurrDocLine.Fields[I].FieldName;
                C.FieldName := CurrDocLine.Fields[I].FieldName;
                C.ValueList.Add('Истина=1');
                C.ValueList.Add('Ложь=0');
              end;

              //
              // Числовые данные

              ftSmallInt, ftBCD, ftInteger, ftFloat, ftLargeInt:
              begin
                C := Grid.ColumnEditors.Add;

                //
                // Если не является ни ссылкой, ни множеством на другую таблицу

                if (F.References = nil) and (F.CrossRelation = nil) then
                begin
                  C.EditorStyle := cesCalculator;
                  C.DisplayField := CurrDocLine.Fields[I].FieldName;
                  C.FieldName := CurrDocLine.Fields[I].FieldName;
                end else

                //
                // Если ссылка на таблицу-множество для данной таблицы

                if F.CrossRelation <> nil then
                begin
                  if F.CrossRelation.IsStandartTreeRelation then
                    C.EditorStyle := cesSetTree
                  else
                    C.EditorStyle := cesSetGrid;

                  C.FieldName := CurrDocLine.Fields[I].FieldName;
                  C.DisplayField := CurrDocLine.Fields[I].FieldName;
                  { TODO 1 -oденис -cсделать : Доделать для множеств }
                end else

                //
                // Если поле из таблицы-карточки по складу

                //
                // Если обычная ссылка на другую таблицу

                begin
                  if AnsiCompareText(R.RelationName, 'INV_CARD') = 0 then
                  begin
                  {Если наше поле принадлежит таблице INV_CARD}
                    if CurrDocLine.RelationType = irtFeatureChange then
                    {Если это документ с изменением свойств, то нас интересует inv_card с алиасом tocard}
                      AliasName := 'TOCARD'
                    else
                      AliasName := 'CARD';
                  end
                  else
                    if AnsiCompareText(R.RelationName, CurrDocLine.RelationLineName) = 0 then
                    {Наше поле из таблицы позиции складского документа}
                      AliasName := 'INVLINE'
                    else
                    {другая таблица}
                      if AnsiCompareText(R.RelationName, 'GD_DOCUMENT') = 0 then
                        AliasName := 'Z';

                  if AliasName > '' then
                  begin
                  {Наше поле из inv_card или invline}
                    C.EditorStyle := cesLookup;
                    C.FieldName := CurrDocLine.Fields[I].FieldName;

                    {Устанавливаем лист-таблицу, поле для отображения, класс, подтип}
                    if F.gdClassName > '' then
                    begin
                      C.Lookup.SubType := F.gdSubType;
                      C.Lookup.gdClassName := F.gdClassName;
                      if Assigned(F.Field.RefListField) then
                        C.Lookup.LookupListField := F.Field.RefListField.FieldName;
                    end else begin
                      if Assigned(F.Field.RefListField) then
                        C.Lookup.LookupListField := F.Field.RefListField.FieldName
                      else
                        C.Lookup.LookupListField := F.References.ListField.FieldName;

                      C.Lookup.LookupKeyField := F.References.PrimaryKey.
                        ConstraintFields[0].FieldName;
                      C.Lookup.LookupTable := F.References.RelationName;
                    end;

                    {Поле, в которм будет выводится контрол}
                    C.DisplayField := gdcBaseManager.AdjustMetaName(CurrDocLine.JoinListFieldByFieldName(F.FieldName, AliasName,
                       C.Lookup.LookupListField));
                    {Условие}
                    C.Lookup.Condition := F.Field.RefCondition;
                    {Транзакция}
                    C.Lookup.Transaction := ibtrCommon;

                    {Инициализация флагов}
                    IsAsConstraint := False;  {Наша ссылка - это ссылка из дополнительного ограничения по расходу}
                    HasConstraint := False;   {Имеет дополнительное ограничение на поля-ссылки на контакт прихода-расхода}

                    //
                    // Проверка на случай использования поля, как указателя на получателя
                    // и источник ТМЦ

                    //
                    // Если расход в нижней таблице

                    if  {Расход выполняется на контакт из позиции и наша ссылка является этим контактом}
                      (AnsiCompareText(CurrDocLine.MovementSource.RelationName,
                        CurrDocLine.RelationLineName) = 0)
                        and
                      (AnsiCompareText(CurrDocLine.MovementSource.SourceFieldName,
                        C.FieldName) = 0)
                    then begin
                      {Устанавливаем флаг дополнительного ограничения по расходу}
                      HasConstraint := (CurrDocLine.MovementSource.SubRelationName > '') and
                        (CurrDocLine.MovementSource.SubSourceFieldName > '');
                      {Считываем тип контакта, на который оформляется расход}
                      ContactType := CurrDocLine.MovementSource.ContactType;
                      {Считываем возможные значения контакта, на кот оформляется расход}
                      Predefined := GetArrAsCommaText(CurrDocLine.MovementSource.Predefined);
                    end else

                    //
                    // Если приход в нижней таблице

                    if {Приход выполняется на контакт из позиции и наша ссылка является этим контактом}
                      (AnsiCompareText(CurrDocLine.MovementTarget.RelationName,
                        CurrDocLine.RelationLineName) = 0)
                        and
                      (AnsiCompareText(CurrDocLine.MovementTarget.SourceFieldName,
                        C.FieldName) = 0)
                    then begin
                     {Устанавливаем флаг дополнительного ограничения по приходу}
                      HasConstraint := (CurrDocLine.MovementTarget.SubRelationName > '') and
                        (CurrDocLine.MovementTarget.SubSourceFieldName > '');
                      {Считываем тип контакта, на который оформляется приход}
                      ContactType := CurrDocLine.MovementTarget.ContactType;
                      {Считываем возможные значения контакта, на кот оформляется приход}
                      Predefined := GetArrAsCommaText(CurrDocLine.MovementTarget.Predefined);
                    end else

                    //
                    //  Если ограничение по расходу в нижней таблице

                    if
                      (AnsiCompareText(CurrDocLine.MovementSource.SubRelationName,
                        CurrDocLine.RelationLineName) = 0)
                        and
                      (AnsiCompareText(CurrDocLine.MovementSource.SubSourceFieldName,
                        C.FieldName) = 0)
                    then begin
                      {Наша ссылка - это ссылка из дополнительного ограничения по расходу}
                      IsAsConstraint := True;
                      {Считываем тип контакта, ограничивающего расход}
                      ContactType := CurrDocLine.MovementSource.ContactType;
                      {На поле контакт позиции вешаем свой обработчик OnChange }
                      CurrDocLine.FieldByName(CurrDocLine.MovementSource.SubSourceFieldName).OnChange :=
                        OnSubLineMovementOptionFieldChange;
                     {Считываем возможные значения контакта, ограничивающего  расход}
                      Predefined := GetArrAsCommaText(CurrDocLine.MovementSource.SubPredefined);
                    end else

                    //
                    //  Если ограничение по приходу в нижней таблице

                    if
                      (AnsiCompareText(CurrDocLine.MovementTarget.SubRelationName,
                        CurrDocLine.RelationLineName) = 0)
                        and
                      (AnsiCompareText(CurrDocLine.MovementTarget.SubSourceFieldName,
                        C.FieldName) = 0)
                    then begin
                      {Наша ссылка - это ссылка из дополнительного ограничения по приходу}
                      IsAsConstraint := True;
                      {Считываем тип контакта, ограничивающего приход}
                      ContactType := CurrDocLine.MovementTarget.ContactType;
                      {На поле контакт позиции вешаем свой обработчик OnChange }
                      CurrDocLine.FieldByName(CurrDocLine.MovementTarget.SubSourceFieldName).OnChange :=
                        OnSubLineMovementOptionFieldChange;
                     {Считываем возможные значения контакта, ограничивающего приход}
                      Predefined := GetArrAsCommaText(CurrDocLine.MovementTarget.SubPredefined);
                    end else
                      Continue; {Все остальные ссылки из таблиц inv_card, invline пропускаем}

                    //
                    // Если идет работа с ограничением - необходимо трансформировать тип контакта

                    if IsAsConstraint then
                    case ContactType of
                      imctOurCompany: // Пропускаем
                        Continue;
                      imctOurDepartment: // Оставляем подразделение
                        ContactType := imctOurDepartment;
                      imctOurPeople: // Если сотрудник - устанавливаем подразделение
                        ContactType := imctOurDepartment;
                      imctCompany: // Пропускаем
                        Continue;
                      imctCompanyDepartment: // Если подразделение клиента - клиент
                        ContactType := imctCompany;
                      imctCompanyPeople: // Если сотрудник клиента - клиент
                        ContactType := imctCompany;
                      imctPeople: // Пропускаем
                        Continue;
                    end;

                    //
                    // Обрабатываем все виды полей-указателей на получателя или источник

                    case ContactType of
                      imctOurCompany:
                      begin
                        C.Lookup.gdClassName :=  'TgdcOurCompany';
                      end;
                      imctOurDepartment:  //Приход/расход оформлен на наше подразделение
                      begin
                        C.Lookup.gdClassName :=  'TgdcDepartment';
                        C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                        C.Lookup.Condition := 'c.contacttype = 4 AND cp.id = :ck';
                        C.Lookup.Params.Clear;
                        if HasConstraint then //Есть дополнительное ограничение
                          C.Lookup.Params.Add('ck=0')
                        else
                          C.Lookup.Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
                        Alias := 'c.';
                      end;
                      imctOurDepartAndPeople: //Приход/расход оформлен на наше подразделение
                      begin
                        C.Lookup.gdClassName :=  '';
                        C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                        C.Lookup.Condition := 'c.contacttype in (2, 4) AND cp.id = :ck';
                        C.Lookup.Params.Clear;
                        if HasConstraint then //Есть дополнительное ограничение
                          C.Lookup.Params.Add('ck=0')
                        else
                          C.Lookup.Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
                        Alias := 'c.';
                      end;
                      imctOurPeople:  //Приход/расход оформлен на нашего сотрудника
                      begin
                        C.Lookup.gdClassName :=  'TgdcEmployee';
                        C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                        C.Lookup.Condition := 'c.contacttype = 2 AND cp.id = :ck';
                        C.Lookup.Params.Clear;
                        if HasConstraint then //Есть дополнительное ограничение
                          C.Lookup.Params.Add('ck=0')
                        else
                          C.Lookup.Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
                        Alias := 'c.';
                      end;
                      imctCompany: //Приход/расход оформлен на клиента
                      begin
                        C.Lookup.gdClassName :=  'TgdcCompany';
                        C.Lookup.Condition := 'contacttype in (3, 5)';
                      end;
                      imctCompanyDepartment:
                      begin
                        C.Lookup.gdClassName :=  'TgdcDepartment';
                        C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                        C.Lookup.Condition := 'c.contacttype = 4 AND cp.id = :ck';
                        C.Lookup.Params.Clear;
                        C.Lookup.Params.Add('ck=0');
                        Alias := 'c.';
                      end;
                      imctCompanyPeople: //Приход/расход оформлен на сотрудника клиента
                      begin
                        C.Lookup.gdClassName :=  'TgdcEmployee';
                        C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                        C.Lookup.Condition := 'c.contacttype = 2 AND cp.id = :ck';
                        C.Lookup.Params.Clear;
                        C.Lookup.Params.Add('ck=0');
                        Alias := 'c.';
                      end;
                      imctPeople: //Приход/расход оформлен на физ лицо
                      begin
                        C.Lookup.gdClassName :=  'TgdcContact';
                        C.Lookup.Condition := 'contacttype = 2';
                      end;
                    end;

                    //
                    // Если есть предустановленные значения, заполняем их

                    if Predefined > '' then
                    begin
                      if C.Lookup.Condition > '' then
                        S :=  C.Lookup.Condition + ' AND '
                      else
                        S := '';

                      S := S + Format('(%s%s IN (%s))', [Alias, C.Lookup.LookupKeyField, Predefined]);

                      C.Lookup.Condition := S;
                    end;
                  end;
                end;
              end;

              ftDateTime, ftTime:
              begin
      //          !!!!!Здесь ничего?????
                C := Grid.ColumnEditors.Add;
                C.DisplayField := F.FieldName;
                C.FieldName := F.FieldName;
                C.EditorStyle := cesNone;
              end;
              ftDate:
              begin
                C := Grid.ColumnEditors.Add;
                C.DisplayField := F.FieldName;
                C.FieldName := F.FieldName;
                C.EditorStyle := cesDate;
              end;
              ftMemo:
              begin
                // nothing??????????
              end;
              ftBlob:
              begin
                // nothing??????????
              end;
              ftString:
              begin
      {!!!!!b Julia}
                if Length(F.Field.Numerations) > 0 then
                begin
                  C := Grid.ColumnEditors.Add;
                  C.EditorStyle := cesValueList;
                  C.DisplayField := CurrDocLine.Fields[I].FieldName;
                  C.FieldName := CurrDocLine.Fields[I].FieldName;

                  for J := 0 to Length(F.Field.Numerations) - 1 do
                  begin
                    C.ValueList.Add(F.Field.Numerations[J].Name + '=' + F.Field.Numerations[J].Value);
                  end;
                end;
      {!!!!!e Julia}
                //
                //  Контролы для карточки
              end;
            end;
          end;
        end
        else
        begin
          if (CurrDocLine.IsChangeCardValue and CurrDocLine.IsAppendCardValue)  or ((Document.RelationType = irtTransformation) and (Grid.Name = ibgrdTop.Name)) then
          begin
            if F.References <> nil then
            begin
              {Если у нас есть ссылка}
              C := Grid.ColumnEditors.Add;
              C.EditorStyle := cesLookup;
              C.FieldName := CurrDocLine.Fields[I].FieldName;

              {Установка лист-таблицы, класса, поля отображения}
              if F.gdClassName > '' then
              begin
                C.Lookup.SubType := F.gdSubType;
                C.Lookup.gdClassName := F.gdClassName;
              end else begin
                if Assigned(F.Field.RefListField) then
                  C.Lookup.LookupListField := F.Field.RefListField.FieldName
                else
                  C.Lookup.LookupListField := F.References.ListField.FieldName;

                C.Lookup.LookupKeyField := F.References.PrimaryKey.
                  ConstraintFields[0].FieldName;
                C.Lookup.LookupTable := F.References.RelationName;
              end;

              {Поле, в котором будет отбражаться контрол}
              C.DisplayField := gdcBaseManager.AdjustMetaName(CurrDocLine.JoinListFieldByFieldName(F.FieldName, 'CARD', C.Lookup.LookupListField));

              {Установка первоначального условия (из класса)}
              if Assigned(F.Field) and (F.Field.RefCondition > '') then
                C.Lookup.Condition := F.Field.RefCondition;

              C.Lookup.Transaction := ibtrCommon;
            end
          end
        end;
      end
      else

  { Остальные поля таблицы и поля TO_ карточки }

      case F.Field.FieldType of

        //
        // Логические данные
        ftBoolean:
        begin
          C := Grid.ColumnEditors.Add;
          C.EditorStyle := cesValueList;
          C.DisplayField := CurrDocLine.Fields[I].FieldName;
          C.FieldName := CurrDocLine.Fields[I].FieldName;
          C.ValueList.Add('Истина=1');
          C.ValueList.Add('Ложь=0');
        end;

        //
        // Числовые данные

        ftSmallInt, ftBCD, ftInteger, ftFloat, ftLargeInt:
        begin
          C := Grid.ColumnEditors.Add;

          //
          // Если не является ни ссылкой, ни множеством на другую таблицу

          if (F.References = nil) and (F.CrossRelation = nil) then
          begin
            C.EditorStyle := cesCalculator;
            C.DisplayField := CurrDocLine.Fields[I].FieldName;
            C.FieldName := CurrDocLine.Fields[I].FieldName;
          end else

          //
          // Если ссылка на таблицу-множество для данной таблицы

          if F.CrossRelation <> nil then
          begin
            if F.CrossRelation.IsStandartTreeRelation then
              C.EditorStyle := cesSetTree
            else
              C.EditorStyle := cesSetGrid;

            C.FieldName := CurrDocLine.Fields[I].FieldName;
            C.DisplayField := CurrDocLine.Fields[I].FieldName;
            { TODO 1 -oденис -cсделать : Доделать для множеств }
          end else

          //
          // Если поле из таблицы-карточки по складу

          //
          // Если обычная ссылка на другую таблицу

          begin
            if AnsiCompareText(R.RelationName, 'INV_CARD') = 0 then
            begin
            {Если наше поле принадлежит таблице INV_CARD}
              if CurrDocLine.RelationType = irtFeatureChange then
              {Если это документ с изменением свойств, то нас интересует inv_card с алиасом tocard}
                AliasName := 'TOCARD'
              else
                if (CurrDocLine.RelationType = irtTransformation) and (Grid.Name <> ibgrdTop.Name) then
                  AliasName := ''
                else
                  AliasName := 'CARD';
            end
            else
              if AnsiCompareText(R.RelationName, CurrDocLine.RelationLineName) = 0 then
              {Наше поле из таблицы позиции складского документа}
                AliasName := 'INVLINE'
              else
              {другая таблица}
                if AnsiCompareText(R.RelationName, 'GD_DOCUMENT') = 0 then
                  AliasName := 'Z';

            if AliasName > '' then
            begin
            {Наше поле из inv_card или invline}
              C.EditorStyle := cesLookup;
              C.FieldName := CurrDocLine.Fields[I].FieldName;

              {Устанавливаем лист-таблицу, поле для отображения, класс, подтип}
              if F.gdClassName > '' then
              begin
                C.Lookup.SubType := F.gdSubType;
                C.Lookup.gdClassName := F.gdClassName;
                if Assigned(F.Field.RefListField) then
                  C.Lookup.LookupListField := F.Field.RefListField.FieldName;
              end else begin
                if Assigned(F.Field.RefListField) then
                  C.Lookup.LookupListField := F.Field.RefListField.FieldName
                else
                  C.Lookup.LookupListField := F.References.ListField.FieldName;

                C.Lookup.LookupKeyField := F.References.PrimaryKey.
                  ConstraintFields[0].FieldName;
                C.Lookup.LookupTable := F.References.RelationName;
              end;

              {Поле, в которм будет выводится контрол}
              C.DisplayField := gdcBaseManager.AdjustMetaName(CurrDocLine.JoinListFieldByFieldName(F.FieldName, AliasName,
                 C.Lookup.LookupListField));
              {Условие}
              C.Lookup.Condition := F.Field.RefCondition;
              {Транзакция}
              C.Lookup.Transaction := ibtrCommon;

              {Инициализация флагов}
              IsAsConstraint := False;  {Наша ссылка - это ссылка из дополнительного ограничения по расходу}
              HasConstraint := False;   {Имеет дополнительное ограничение на поля-ссылки на контакт прихода-расхода}

              //
              // Проверка на случай использования поля, как указателя на получателя
              // и источник ТМЦ

              //
              // Если расход в нижней таблице

              if  {Расход выполняется на контакт из позиции и наша ссылка является этим контактом}
                (AnsiCompareText(CurrDocLine.MovementSource.RelationName,
                  CurrDocLine.RelationLineName) = 0)
                  and
                (AnsiCompareText(CurrDocLine.MovementSource.SourceFieldName,
                  C.FieldName) = 0)
              then begin
                {Устанавливаем флаг дополнительного ограничения по расходу}
                HasConstraint := (CurrDocLine.MovementSource.SubRelationName > '') and
                  (CurrDocLine.MovementSource.SubSourceFieldName > '');
                {Считываем тип контакта, на который оформляется расход}
                ContactType := CurrDocLine.MovementSource.ContactType;
                {Считываем возможные значения контакта, на кот оформляется расход}
                Predefined := GetArrAsCommaText(CurrDocLine.MovementSource.Predefined);
              end else

              //
              // Если приход в нижней таблице

              if {Приход выполняется на контакт из позиции и наша ссылка является этим контактом}
                (AnsiCompareText(CurrDocLine.MovementTarget.RelationName,
                  CurrDocLine.RelationLineName) = 0)
                  and
                (AnsiCompareText(CurrDocLine.MovementTarget.SourceFieldName,
                  C.FieldName) = 0)
              then begin
               {Устанавливаем флаг дополнительного ограничения по приходу}
                HasConstraint := (CurrDocLine.MovementTarget.SubRelationName > '') and
                  (CurrDocLine.MovementTarget.SubSourceFieldName > '');
                {Считываем тип контакта, на который оформляется приход}
                ContactType := CurrDocLine.MovementTarget.ContactType;
                {Считываем возможные значения контакта, на кот оформляется приход}
                Predefined := GetArrAsCommaText(CurrDocLine.MovementTarget.Predefined);
              end else

              //
              //  Если ограничение по расходу в нижней таблице

              if
                (AnsiCompareText(CurrDocLine.MovementSource.SubRelationName,
                  CurrDocLine.RelationLineName) = 0)
                  and
                (AnsiCompareText(CurrDocLine.MovementSource.SubSourceFieldName,
                  C.FieldName) = 0)
              then begin
                {Наша ссылка - это ссылка из дополнительного ограничения по расходу}
                IsAsConstraint := True;
                {Считываем тип контакта, ограничивающего расход}
                ContactType := CurrDocLine.MovementSource.ContactType;
                {На поле контакт позиции вешаем свой обработчик OnChange }
                CurrDocLine.FieldByName(CurrDocLine.MovementSource.SubSourceFieldName).OnChange :=
                  OnSubLineMovementOptionFieldChange;
               {Считываем возможные значения контакта, ограничивающего  расход}
                Predefined := GetArrAsCommaText(CurrDocLine.MovementSource.SubPredefined);
              end else

              //
              //  Если ограничение по приходу в нижней таблице

              if
                (AnsiCompareText(CurrDocLine.MovementTarget.SubRelationName,
                  CurrDocLine.RelationLineName) = 0)
                  and
                (AnsiCompareText(CurrDocLine.MovementTarget.SubSourceFieldName,
                  C.FieldName) = 0)
              then begin
                {Наша ссылка - это ссылка из дополнительного ограничения по приходу}
                IsAsConstraint := True;
                {Считываем тип контакта, ограничивающего приход}
                ContactType := CurrDocLine.MovementTarget.ContactType;
                {На поле контакт позиции вешаем свой обработчик OnChange }
                CurrDocLine.FieldByName(CurrDocLine.MovementTarget.SubSourceFieldName).OnChange :=
                  OnSubLineMovementOptionFieldChange;
               {Считываем возможные значения контакта, ограничивающего приход}
                Predefined := GetArrAsCommaText(CurrDocLine.MovementTarget.SubPredefined);
              end else
                Continue; {Все остальные ссылки из таблиц inv_card, invline пропускаем}

              //
              // Если идет работа с ограничением - необходимо трансформировать тип контакта

              if IsAsConstraint then
              case ContactType of
                imctOurCompany: // Пропускаем
                  Continue;
                imctOurDepartment: // Оставляем подразделение
                  ContactType := imctOurDepartment;
                imctOurPeople: // Если сотрудник - устанавливаем подразделение
                  ContactType := imctOurDepartment;
                imctCompany: // Пропускаем
                  Continue;
                imctCompanyDepartment: // Если подразделение клиента - клиент
                  ContactType := imctCompany;
                imctCompanyPeople: // Если сотрудник клиента - клиент
                  ContactType := imctCompany;
                imctPeople: // Пропускаем
                  Continue;
              end;

              //
              // Обрабатываем все виды полей-указателей на получателя или источник

              case ContactType of
                imctOurCompany:
                begin
                  C.Lookup.gdClassName :=  'TgdcOurCompany';
                end;
                imctOurDepartment:  //Приход/расход оформлен на наше подразделение
                begin
                  C.Lookup.gdClassName :=  'TgdcDepartment';
                  C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                  C.Lookup.Condition := 'c.contacttype = 4 AND cp.id = :ck';
                  C.Lookup.Params.Clear;
                  if HasConstraint then //Есть дополнительное ограничение
                    C.Lookup.Params.Add('ck=0')
                  else
                    C.Lookup.Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
                  Alias := 'c.';
                end;
                imctOurDepartAndPeople:
                begin
                  C.Lookup.gdClassName :=  '';
                  C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                  C.Lookup.Condition := 'c.contacttype in (2,4) AND cp.id = :ck';
                  C.Lookup.Params.Clear;
                  if HasConstraint then //Есть дополнительное ограничение
                    C.Lookup.Params.Add('ck=0')
                  else
                    C.Lookup.Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
                  Alias := 'c.';
                end;
                imctOurPeople:  //Приход/расход оформлен на нашего сотрудника
                begin
                  C.Lookup.gdClassName :=  'TgdcEmployee';
                  C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                  C.Lookup.Condition := 'c.contacttype = 2 AND cp.id = :ck';
                  C.Lookup.Params.Clear;
                  if HasConstraint then //Есть дополнительное ограничение
                    C.Lookup.Params.Add('ck=0')
                  else
                    C.Lookup.Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
                  Alias := 'c.';
                end;
                imctCompany: //Приход/расход оформлен на клиента
                begin
                  C.Lookup.gdClassName :=  'TgdcCompany';
                  C.Lookup.Condition := 'contacttype in (3, 5)';
                end;
                imctCompanyDepartment:
                begin
                  C.Lookup.gdClassName :=  'TgdcDepartment';
                  C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                  C.Lookup.Condition := 'c.contacttype = 4 AND cp.id = :ck';
                  C.Lookup.Params.Clear;
                  C.Lookup.Params.Add('ck=0');
                  Alias := 'c.';
                end;
                imctCompanyPeople: //Приход/расход оформлен на сотрудника клиента
                begin
                  C.Lookup.gdClassName :=  'TgdcEmployee';
                  C.Lookup.LookupTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
                  C.Lookup.Condition := 'c.contacttype = 2 AND cp.id = :ck';
                  C.Lookup.Params.Clear;
                  C.Lookup.Params.Add('ck=0');
                  Alias := 'c.';
                end;
                imctPeople: //Приход/расход оформлен на физ лицо
                begin
                  C.Lookup.gdClassName :=  'TgdcContact';
                  C.Lookup.Condition := 'contacttype = 2';
                end;
              end;

              //
              // Если есть предустановленные значения, заполняем их

              if Predefined > '' then
              begin
                if C.Lookup.Condition > '' then
                  S :=  C.Lookup.Condition + ' AND '
                else
                  S := '';

                S := S + Format('(%s%s IN (%s))', [Alias, C.Lookup.LookupKeyField, Predefined]);

                C.Lookup.Condition := S;
              end;
            end;
          end;
        end;

        ftDateTime, ftTime:
        begin
//          !!!!!Здесь ничего?????
          C := Grid.ColumnEditors.Add;
          C.DisplayField := F.FieldName;
          C.FieldName := F.FieldName;
          C.EditorStyle := cesNone;
        end;
        ftDate:
        begin
          C := Grid.ColumnEditors.Add;
          C.DisplayField := F.FieldName;
          C.FieldName := F.FieldName;
          C.EditorStyle := cesDate;
        end;
        ftMemo:
        begin
          // nothing??????????
        end;
        ftBlob:
        begin
          // nothing??????????
        end;
        ftString:
        begin
{!!!!!b Julia}
          if Length(F.Field.Numerations) > 0 then
          begin
            C := Grid.ColumnEditors.Add;
            C.EditorStyle := cesValueList;
            C.DisplayField := CurrDocLine.Fields[I].FieldName;
            C.FieldName := CurrDocLine.Fields[I].FieldName;

            for J := 0 to Length(F.Field.Numerations) - 1 do
            begin
              C.ValueList.Add(F.Field.Numerations[J].Name + '=' + F.Field.Numerations[J].Value);
            end;
          end;
{!!!!!e Julia}
          //
          //  Контролы для карточки
        end;
      end;
    except
      if Assigned(C) then
      begin
        C.Free;
        C := nil;
      end;
      Continue;
    end;
    if Assigned(C) and (C.FieldName = '') then
    begin
      C.Free;
      C := nil;
    end;
  end;

  if CurrDocLine.IsChangeCardValue or ((Document.RelationType = irtTransformation) and (Grid.Name = ibgrdTop.Name)) then
  begin
    for i:= 0 to Grid.Columns.Count - 1 do
    begin
      if (Pos('FROM_', Grid.Columns[I].FieldName) = 1) then
        Grid.Columns[I].ReadOnly := False;
      if (Pos('CARD_', Grid.Columns[I].FieldName) = 1) then
        Grid.Columns[I].ReadOnly := False;
    end
  end
  else
    for i:= 0 to Grid.Columns.Count - 1 do
    begin
      if (Pos('FROM_', Grid.Columns[I].FieldName) = 1) then
        Grid.Columns[I].ReadOnly := True;
      if (Pos('CARD_', Grid.Columns[I].FieldName) = 1) then
        Grid.Columns[I].ReadOnly := True;
    end;

  //
  // Осуществляем настройку ограничений

  E2 := OnSubLineMovementOptionFieldChange;
  with Grid.DataSource.DataSet do
  for I := 0 to FieldCount - 1 do
  begin
    E1 := Fields[I].OnChange;
    if @E1 = @E2 then
      OnSubLineMovementOptionFieldChange(Fields[I]);
  end;

  if Assigned(EventControl) then
    EventControl.SafeCallSetEvents(Grid);

end;

procedure TdlgInvDocument.TestRequiredFields;
begin
{Поле контакта на который оформляется расход находится в шапке}
  if (AnsiCompareText(Document.MovementSource.RelationName,
        Document.RelationName) = 0)
        and
    (Document.MovementSource.SourceFieldName > '')
        and
     Document.FieldByName(Document.MovementSource.SourceFieldName).IsNull
  then
  begin
    Document.FieldByName(Document.MovementSource.SourceFieldName).FocusControl;
    raise EdlgInvDocument.CreateFmt('Не введено значение в поле "%s"!',
      [Document.FieldByName(Document.MovementSource.SourceFieldName).DisplayName])
  end;

  {Поле контакта на который оформляется приход находится в шапке}
  if
    (AnsiCompareText(Document.MovementTarget.RelationName,
      Document.RelationName) = 0)
      and
    (Document.MovementTarget.SourceFieldName > '')
      and
    Document.FieldByName(Document.MovementTarget.SourceFieldName).IsNull
  then
  begin
    Document.FieldByName(Document.MovementTarget.SourceFieldName).FocusControl;
    raise EdlgInvDocument.CreateFmt('Не введено значение в поле "%s"!',
      [Document.FieldByName(Document.MovementTarget.SourceFieldName).DisplayName]);
  end;

end;

procedure TdlgInvDocument.CheckDisabledPosition;
var
  ibsql: TIBSQL;
  CE: TgdClassEntry;
begin
  ibsql := TIBSQL.Create(nil);
  try
    if Document.Transaction.InTransaction then
    begin
      ibsql.Transaction := Document.Transaction;
      CE := gdClassList.Get(TgdDocumentEntry, DocumentLine.ClassName, DocumentLine.SubType).GetRootSubType;

      ibsql.SQL.Text := Format('SELECT documentkey FROM %s WHERE disabled = 1 and masterkey = %d',
        [TgdDocumentEntry(CE).DistinctRelation, Document.FieldByName('id').AsInteger]);
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        DocumentLine.Movement.gdcDocumentLine := DocumentLine;
        DocumentLine.Movement.Database := DocumentLine.Database;
        DocumentLine.Movement.ReadTransaction := DocumentLine.Transaction;
        DocumentLine.Movement.Transaction := DocumentLine.Transaction;
        DocumentLine.Movement.CreateAllMovement(ipsmDocument, True);
      end;
      ibsql.Close;
    end;
  finally
    ibsql.Free;
  end;
end;

function TdlgInvDocument.GetSecondDocumentLine: TgdcInvDocumentLine;
begin
  Result := FSecondDocumentLine;
end;

procedure TdlgInvDocument.atAttributesRelationNames(Sender: TObject;
  Relations, FieldAliases: TStringList);
var
  I: Integer;
  CE: TgdClassEntry;
  flag: Boolean;
begin
  inherited;
  
  // Добавляем поля
  FieldAliases.Add('NUMBER');
  FieldAliases.Add('DOCUMENTDATE');

  for I := 0 to Document.FieldCount - 1 do
  begin
    flag := (AnsiCompareText(Document.RelationByAliasName(Document.Fields[I].FieldName),
      'GD_DOCUMENT') = 0);
    if not flag then
    begin
      CE := gdClassList.Get(TgdDocumentEntry, Document.ClassName, Document.SubType);
      repeat
        flag := (AnsiCompareText(Document.RelationByAliasName(Document.Fields[I].FieldName),
          TgdDocumentEntry(CE).DistinctRelation) = 0);
        CE := CE.Parent;
      until (CE.SubType = '') or flag;
    end;
    if flag then
      if StrIPos(UserPrefix, Document.FieldNameByAliasName(Document.Fields[I].FieldName)) = 1 then
        FieldAliases.Add(Document.Fields[I].FieldName);
  end;

  if DocumentLine.CanBeDelayed then
    FieldAliases.Add('DELAYED');
end;

procedure TdlgInvDocument.atAttributesAdjustControl(Sender: TObject;
  Control: TControl);
var
  IsAsConstraint: Boolean;
  HasConstraint: Boolean;
  ContactType: TgdcInvMovementContactType;
  Predefined, S: String;
  Alias: String;
begin
  // Если осуществляется выход из окна, не
  // производим никаких действий
  if FIsClosing then Exit;

  {Настройка лукапов}
  if Control is TgsIBLookupComboBox then
  with Control as TgsIBLookupComboBox do
  begin

    //
    // Проверка на случай использования поля, как указателя на получателя
    // и источник ТМЦ

    {Очищаем параметры}
    Params.Clear;
    Alias := '';

    CheckUserRights := True;

    //
    // Если расход в верхней таблице

    if
      (AnsiCompareText(Document.MovementSource.RelationName,
        Document.RelationName) = 0)
        and
      (AnsiCompareText(Document.MovementSource.SourceFieldName,
        DataField) = 0)
    then begin
      IsAsConstraint := False; {Это не дополнительное ограничение}
      {Устанавливаем флаг наличия доп ограничения}
      HasConstraint := (Document.MovementSource.SubRelationName > '') and
        (Document.MovementSource.SubSourceFieldName > '');
      {Тип контакта, на который оформляется расход}
      ContactType := Document.MovementSource.ContactType;
      {Возможные значения контакта, на кот оформляется расход}
      Predefined := GetArrAsCommaText(Document.MovementSource.Predefined);

      {Событие на создание нового объекта}
      OnCreateNewObject := DoCreateNewObject;
    end else

    //
    // Если приход в верхней таблице

    if
      (AnsiCompareText(Document.MovementTarget.RelationName,
        Document.RelationName) = 0)
        and
      (AnsiCompareText(Document.MovementTarget.SourceFieldName,
        DataField) = 0)
    then begin
      IsAsConstraint := False; {Это не дополнительное ограничение}
      {Устанавливаем флаг наличия доп ограничения}
      HasConstraint := (Document.MovementTarget.SubRelationName > '') and
        (Document.MovementTarget.SubSourceFieldName > '');
      {Тип контакта, на который оформляется приход}
      ContactType := Document.MovementTarget.ContactType;
      {Возможные значения контакта, на кот оформляется приход}
      Predefined := GetArrAsCommaText(Document.MovementTarget.Predefined);
      OnCreateNewObject := DoCreateNewObject;
    end else

    //
    //  Если ограничение по расходу в верхней таблице

    if
      (AnsiCompareText(Document.MovementSource.SubRelationName,
        Document.RelationName) = 0)
        and
      (AnsiCompareText(Document.MovementSource.SubSourceFieldName,
        DataField) = 0)
    then begin
      IsAsConstraint := True; {Это доп ограничение по расходу}
      HasConstraint := False;
      {Тип контакта, на который оформляется расход}
      ContactType := Document.MovementSource.ContactType;
      {На изменение значения этого поля будем ограничивать данные в другом поле}
      FOldDocOnChangeEventList.Add(TInvEventSave.Create(Document.FieldByName(Document.MovementSource.SubSourceFieldName)));
      Document.FieldByName(Document.MovementSource.SubSourceFieldName).OnChange :=
        OnSubMovementOptionFieldChange;
      {Возможные значения ограничения по расходу}
      Predefined := GetArrAsCommaText(Document.MovementSource.SubPredefined);
    end else

    //
    //  Если ограничение по приходу в верхней таблице

    if
      (AnsiCompareText(Document.MovementTarget.SubRelationName,
        Document.RelationName) = 0)
        and
      (AnsiCompareText(Document.MovementTarget.SubSourceFieldName,
        DataField) = 0)
    then begin
      IsAsConstraint := True; {Это доп ограничение по приходу}
      HasConstraint := False;
      {Тип контакта, на который оформляется приход}
      ContactType := Document.MovementTarget.ContactType;
      {На изменение значения этого поля будем ограничивать данные в другом поле}
      FOldDocOnChangeEventList.Add(
        TInvEventSave.Create(Document.FieldByName(Document.MovementTarget.SubSourceFieldName)));
      Document.FieldByName(Document.MovementTarget.SubSourceFieldName).OnChange :=
        OnSubMovementOptionFieldChange;
      {Возможные значения ограничения по приходу}
      Predefined := GetArrAsCommaText(Document.MovementTarget.SubPredefined);
    end else
      Exit; {Другие ссылки нас не интересуют}

    //
    // Если идет работа с ограничением - необходимо трансформировать тип контакта

    if IsAsConstraint then
    case ContactType of
      imctOurCompany: // Пропускаем
        Exit;
      imctOurDepartment: // Оставляем подразделение
        ContactType := imctOurDepartment;
      imctOurPeople: // Если сотрудник - устанавливаем подразделение
        ContactType := imctOurDepartment;
      imctCompany: // Пропускаем
        Exit;
      imctCompanyDepartment: // Если подразделение клиента - клиент
        ContactType := imctCompany;
      imctCompanyPeople: // Если сотрудник клиента - клиент
        ContactType := imctCompany;
      imctPeople: // Пропускаем
        Exit;
    end;

    //
    // Обрабатываем все виды полей-указателей на получателя или источник

    case ContactType of
      imctOurCompany:
      begin
        gdClassName := 'TgdcOurCompany';
      end;
      imctOurDepartment:
      begin
        gdClassName :=  'TgdcDepartment';
        ListTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
        Condition := 'c.contacttype = 4 AND cp.id = :ck';
        Params.Clear;
        {Если у нас есть есть доп ограничение, то считывать параметр мы должны по доп ограничению}
        if HasConstraint then
          Params.Add('ck=0')
        else
          Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
        Alias := 'c.';
      end;

      imctOurDepartAndPeople:
      begin
        gdClassName :=  '';
        ListTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
        Condition := 'c.contacttype in (2, 4) AND cp.id = :ck';
        Params.Clear;
        {Если у нас есть есть доп ограничение, то считывать параметр мы должны по доп ограничению}
        if HasConstraint then
          Params.Add('ck=0')
        else
          Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
        Alias := 'c.';
      end;
      imctOurPeople:
      begin
        gdClassName :=  'TgdcEmployee';
        ListTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
        Condition := 'c.contacttype = 2 AND cp.id = :ck';
        {Если у нас есть есть доп ограничение, то считывать параметр мы должны по доп ограничению}
        Params.Clear;
        if HasConstraint then
          Params.Add('ck=0')
        else
          Params.Add('ck=' + IntToStr(IBLogin.CompanyKey));
        Alias := 'c.';
      end;
      imctCompany:
      begin
        gdClassName :=  'TgdcCompany';
        Condition := 'contacttype in (3, 5)';
      end;
      imctCompanyDepartment:
      begin
        gdClassName :=  'TgdcDepartment';
        ListTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
        Condition := 'c.contacttype = 4 AND cp.id = :ck';
        Params.Clear;
        Params.Add('ck=0');
        Alias := 'c.';
      end;
      imctCompanyPeople:
      begin
        gdClassName :=  'TgdcEmployee';
        ListTable := 'gd_contact c JOIN gd_contact cp ON cp.lb <= c.lb AND cp.rb >= c.rb ';
        Condition := 'c.contacttype = 2 AND cp.id = :ck';
        Params.Clear;
        Params.Add('ck=0');
        Alias := 'c.';
      end;
      imctPeople:
      begin
        gdClassName :=  'TgdcContact';
        Condition := 'contacttype in (2)';
      end;
    end;

    //
    // Если есть предустановленные значения, заполняем их

    if Predefined > '' then
    begin
      S := Condition;
      if S > '' then
        S := S + ' AND ';

      Condition := S + Format('(%s%s IN (%s))', [Alias, KeyField, Predefined]);
    end;
  end;
end;

procedure TdlgInvDocument.OnSubMovementOptionFieldChange(Field: TField);
var
  MovementOption: TgdcInvMovementContactOption;

  procedure ProceedMovementChange;
  var
    C: TgsIBLookupComboBox;
    Col: TgsIBColumnEditor;
    I: Integer;

  begin
    C := nil;
    Col := nil;

    if AnsiCompareText(MovementOption.RelationName, Document.RelationName) = 0 then
    begin
      C := atAttributes.ControlByFieldName[MovementOption.SourceFieldName] as
        TgsIBLookupComboBox;
      C.Params.Clear;
    end else

    if AnsiCompareText(MovementOption.RelationName, Document.RelationLineName) = 0 then
    begin
      I := ibgrdTop.ColumnEditors.
        IndexByField(DocumentLine.JoinListFieldByFieldName(
          MovementOption.SourceFieldName, 'INVLINE', 'NAME'));
      if I > -1 then
        Col := ibgrdTop.ColumnEditors[I];
      if Assigned(FBottomGrid) then
      begin
        I := FBottomGrid.ColumnEditors.
          IndexByField(DocumentLine.JoinListFieldByFieldName(
            MovementOption.SourceFieldName, 'INVLINE', 'NAME'));
        if I > -1 then
          Col := FBottomGrid.ColumnEditors[I];
      end;
    end else
      Exit;

    case MovementOption.ContactType of
      imctOurDepartment, imctOurPeople, imctCompanyDepartment, imctCompanyPeople, imctOurDepartAndPeople:
      begin
        if C <> nil then
        begin
          C.Params.Clear;
          C.Params.Add('ck=' + Document.FieldByName(MovementOption.SubSourceFieldName).AsString);
        end else
        if Col <> nil then
        begin
          Col.Lookup.Params.Clear;
          Col.Lookup.Params.Add('ck=' + Document.FieldByName(MovementOption.SubSourceFieldName).AsString);
        end;
      end;
    end;
  end;

begin
  if not Assigned(Document) then Exit;

  RunOldOnChange(Field);

  if
    (AnsiCompareText(Document.MovementSource.SubRelationName,
      Document.RelationName) = 0)
      and
    (AnsiCompareText(Field.FieldName,
      Document.MovementSource.SubSourceFieldName) = 0)
  then begin
    MovementOption := Document.MovementSource;
    ProceedMovementChange;
  end;

  if
    (AnsiCompareText(Document.MovementTarget.SubRelationName,
      Document.RelationName) = 0)
      and
    (AnsiCompareText(Field.FieldName,
      Document.MovementTarget.SubSourceFieldName) = 0)
  then begin
    MovementOption := Document.MovementTarget;
    ProceedMovementChange;
  end;
end;

procedure TdlgInvDocument.OnSubLineMovementOptionFieldChange(Field: TField);
var
  MovementOption: TgdcInvMovementContactOption;
  Col: TgsIBColumnEditor;
  AnID: String;
begin
  if not Assigned(DocumentLine) then Exit;

  RunOldOnChange(Field);

  if
    (AnsiCompareText(DocumentLine.MovementSource.SubRelationName,
      DocumentLine.RelationLineName) = 0)
      and
    (AnsiCompareText(Field.FieldName,
      DocumentLine.MovementSource.SubSourceFieldName) = 0)
  then
    MovementOption := DocumentLine.MovementSource

  else if
    (AnsiCompareText(DocumentLine.MovementTarget.SubRelationName,
      DocumentLine.RelationLineName) = 0)
      and
    (AnsiCompareText(Field.FieldName,
      DocumentLine.MovementTarget.SubSourceFieldName) = 0)
  then
    MovementOption := DocumentLine.MovementTarget

  else
    Exit;

  Col := nil;
  AnID := '';

  if AnsiCompareText(MovementOption.RelationName, DocumentLine.RelationLineName) = 0 then
  begin
    if ibgrdTop.DataSource.DataSet = Field.DataSet then
    begin
      Col := ibgrdTop.ColumnEditors[ibgrdTop.ColumnEditors.
        IndexByField(DocumentLine.JoinListFieldByFieldName(
          MovementOption.SourceFieldName, 'INVLINE', 'NAME'))];

      AnID := DocumentLine.FieldByName(MovementOption.SubSourceFieldName).AsString;
    end else

    if Assigned(FBottomGrid) and (FBottomGrid.DataSource.DataSet = Field.DataSet) then
    begin
      Col := FBottomGrid.ColumnEditors[FBottomGrid.ColumnEditors.
        IndexByField(DocumentLine.JoinListFieldByFieldName(
          MovementOption.SourceFieldName, 'INVLINE', 'NAME'))];

      AnID := FSecondDocumentLine.FieldByName(MovementOption.SubSourceFieldName).AsString;
    end;
  end;

  if Assigned(Col) then
  begin
    case MovementOption.ContactType of
      imctOurDepartment, imctCompanyDepartment, imctCompanyPeople, imctOurDepartAndPeople:
      begin
        Col.Lookup.Params.Clear;
        Col.Lookup.Params.Add('ck=' + AnID);
      end;
    end;
  end;
end;

type
  TgsCrackCustomIBGrid = class(TgsCustomIBGrid);

procedure TdlgInvDocument.actSelectGoodExecute(Sender: TObject);
begin
  if ibgrdTop.Focused or not Assigned(FBottomGrid) then
  begin
    if ibgrdTop.CanFocus then
      ibgrdTop.SetFocus;
    if Assigned(TgsCrackCustomIBGrid(ibgrdTop).InplaceEditor) and TgsCrackCustomIBGrid(ibgrdTop).InplaceEditor.Visible then
      SendMessage(TgsCrackCustomIBGrid(ibgrdTop).InplaceEditor.Handle, wm_KeyDown, VK_F7, 0);
    DocumentLine.SelectGoodFeatures;
  end
  else if FBottomGrid.Focused then
  begin
    if Assigned(TgsCrackCustomIBGrid(FBottomGrid).InplaceEditor) and TgsCrackCustomIBGrid(FBottomGrid).InplaceEditor.Visible then
      SendMessage(TgsCrackCustomIBGrid(FBottomGrid).InplaceEditor.Handle, wm_KeyDown, VK_F7, 0);
    FSecondDocumentLine.SelectGoodFeatures;
  end;
end;

procedure TdlgInvDocument.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVDOCUMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVDOCUMENT', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENT',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  //
  // Сохранение осуществляем в обычном порядке

  if Assigned(UserStorage) and Assigned(Document) then
  begin
    Path := BuildComponentPath(Self);

    UserStorage.SaveComponent(ibgrdTop, ibgrdTop.SaveToStream,
      FSubType);

    if Document.RelationType = irtTransformation then
    begin
      UserStorage.SaveComponent(FBottomGrid, FBottomGrid.SaveToStream,
        FSubType);

      UserStorage.WriteInteger(Path, 'TopGrH', ibgrdTop.Height);
    end;

    UserStorage.WriteInteger(Path, 'pnlAttrH', pnlAttributes.Height);
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENT', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvDocument.actDetailNewExecute(Sender: TObject);
begin
  if ibgrdTop.Focused or not Assigned(FBottomGrid) then
    DocumentLine.Insert
  else

  if Assigned(FBottomGrid) and FBottomGrid.Focused then
    FSecondDocumentLine.Insert;
end;

procedure TdlgInvDocument.actDetailEditExecute(Sender: TObject);
begin
  if ibgrdTop.Focused or not Assigned(FBottomGrid) then
    DocumentLine.Edit
  else

  if Assigned(FBottomGrid) and FBottomGrid.Focused then
    FSecondDocumentLine.Edit;
end;

procedure TdlgInvDocument.actDetailDeleteExecute(Sender: TObject);
begin
  if ibgrdTop.Focused or not Assigned(FBottomGrid) then
    DocumentLine.DeleteMultiple(ibgrdTop.SelectedRows)
  else

  if Assigned(FBottomGrid) and FBottomGrid.Focused then
    FSecondDocumentLine.DeleteMultiple(FBottomGrid.SelectedRows);
end;

procedure TdlgInvDocument.actDetailNewUpdate(Sender: TObject);
begin
  actDetailNew.Enabled := actOk.Enabled and ((
    (
      (ibgrdTop.Focused or not Assigned(FBottomGrid)) and
      Assigned(DocumentLine) and not (DocumentLine.State in dsEditModes)
    ))
      or
    (
      Assigned(FBottomGrid) and FBottomGrid.Focused and
      Assigned(FSecondDocumentLine) and not (FSecondDocumentLine.State in dsEditModes)
    ));
end;

procedure TdlgInvDocument.actDetailEditUpdate(Sender: TObject);
begin
  actDetailEdit.Enabled := actOk.Enabled and ((
    (
      (ibgrdTop.Focused or not Assigned(FBottomGrid)) and
      Assigned(DocumentLine) and not (DocumentLine.State in dsEditModes) and
      (DocumentLine.RecordCount > 0)
    ))
      or
    (
      Assigned(FBottomGrid) and FBottomGrid.Focused and
      Assigned(FSecondDocumentLine) and not (FSecondDocumentLine.State in dsEditModes) and
      (FSecondDocumentLine.RecordCount > 0)
    ));
end;

procedure TdlgInvDocument.actDetailDeleteUpdate(Sender: TObject);
begin
  actDetailDelete.Enabled := actOk.Enabled and ((
    (
      (ibgrdTop.Focused or not Assigned(FBottomGrid)) and
      Assigned(DocumentLine) and not (DocumentLine.State in dsEditModes) and
      (DocumentLine.RecordCount > 0)
    ))
      or
    (
      Assigned(FBottomGrid) and FBottomGrid.Focused and
      Assigned(FSecondDocumentLine) and not (FSecondDocumentLine.State in dsEditModes) and
      (FSecondDocumentLine.RecordCount > 0)
    ));
end;

procedure TdlgInvDocument.actGoodsRefUpdate(Sender: TObject);
begin
  actGoodsRef.Enabled := ibgrdTop.Enabled and
    Assigned(DocumentLine) and
    (
    (irsGoodRef in DocumentLine.Sources)
      or
    (DocumentLine.RelationType = irtTransformation) and
    ibgrdTop.Focused);
end;

procedure TdlgInvDocument.actRemainsRefUpdate(Sender: TObject);
begin

  actRemainsRef.Enabled := Assigned(Document) and Document.Active and
   ((AnsiCompareText(Document.MovementSource.RelationName,
        Document.RelationName) <> 0)
        or
    (Document.MovementSource.SourceFieldName = '')
        or
     not Document.FieldByName(Document.MovementSource.SourceFieldName).IsNull)
     and
    (
    (AnsiCompareText(Document.MovementTarget.RelationName,
      Document.RelationName) <> 0)
      or
    (Document.MovementTarget.SourceFieldName = '')
      or
    not Document.FieldByName(Document.MovementTarget.SourceFieldName).IsNull)
      and
    (irsRemainsRef in DocumentLine.Sources)
{      and

    (
      not Assigned(FBottomGrid)
        or
      (Assigned(FBottomGrid) and FBottomGrid.Focused)
        or
      DocumentLine.IsMinusRemains
    )};
end;

procedure TdlgInvDocument.actSelectGoodUpdate(Sender: TObject);
begin
  actSelectGood.Enabled := Assigned(DocumentLine)
    and
    (not DocumentLine.IsEmpty)
    and
    (irsRemainsRef in DocumentLine.Sources)
    and
    (
      not Assigned(FBottomGrid)
        or
      Assigned(FBottomGrid) and FBottomGrid.Focused
    );
end;

procedure TdlgInvDocument.DoAfterCancelDocument(DataSet: TDataSet);
var
  CurrHandler: TDataSetNotifyEvent;
begin
  CurrHandler := DoAfterCancelDocument;

  pnlAttributes.Enabled := True;
  SetCardFieldCondition((DataSet as TgdcInvDocumentLine), 0);
  if Assigned(OldAfterCancelDocument) and (@OldAfterCancelDocument <> @CurrHandler) then
    OldAfterCancelDocument(DataSet);
end;

procedure TdlgInvDocument.DoAfterEditDocument(DataSet: TDataSet);
var
  CurrHandler: TDataSetNotifyEvent;
begin
  CurrHandler := DoAfterEditDocument;
  if Assigned(OldAfterEditDocument) and (@OldAfterEditDocument <> @CurrHandler) then
    OldAfterEditDocument(DataSet);
  SetCardFieldCondition((DataSet as TgdcInvDocumentLine), 0);
end;

procedure TdlgInvDocument.DoAfterOpenDocument(DataSet: TDataSet);
var
  CurrHandler: TDataSetNotifyEvent;
begin
  CurrHandler := DoAfterOpenDocument;
  pnlAttributes.Enabled := True;
  if Assigned(OldAfterOpenDocument) and (@OldAfterOpenDocument <> @CurrHandler) then
    OldAfterOpenDocument(DataSet);
end;

procedure TdlgInvDocument.DoAfterPostDocument(DataSet: TDataSet);
var
  CurrHandler: TDataSetNotifyEvent;
begin
  CurrHandler := DoAfterPostDocument;

  pnlAttributes.Enabled := True;
  SetCardFieldCondition((DataSet as TgdcInvDocumentLine), 0);
  if Assigned(OldAfterPostDocument) and (@OldAfterPostDocument <> @CurrHandler) then
    OldAfterPostDocument(DataSet);
end;

procedure TdlgInvDocument.DoOnNewRecordDocument(DataSet: TDataSet);
var
  CurrHandler: TDataSetNotifyEvent;
begin
  CurrHandler := DoOnNewRecordDocument;
  if Assigned(OldOnNewRecordDocument) and (@OldOnNewRecordDocument <> @CurrHandler) then
    OldOnNewRecordDocument(DataSet);
  SetCardFieldCondition((DataSet as TgdcInvDocumentLine), 0);
end;

procedure TdlgInvDocument.actCancelUpdate(Sender: TObject);
begin
  inherited;

  {
  if actCancel.Enabled then
  begin
    btnCancel.Cancel :=
      (DocumentLine = nil)
      or
      (
        (not (DocumentLine.State in dsEditModes))
        and
        (
          not Assigned(SecondDocumentLine)
            or
          not (SecondDocumentLine.State in dsEditModes)
        )
      );
  end;
  }

 (* actCancel.Enabled := (gdcObject = nil) or
    (
      (not (sSubDialog in gdcObject.BaseState))
      and
      (not (DocumentLine.State in dsEditModes))
      and
      (
        not Assigned(SecondDocumentLine)
          or
        not (SecondDocumentLine.State in dsEditModes)
      )
    ); *)
end;

procedure TdlgInvDocument.actOkUpdate(Sender: TObject);
begin
  if Assigned(Document)
    and Assigned(Document.MovementSource)
    and Assigned(Document.MovementTarget) then
  begin
    ibgrdTop.Enabled :=
      (
        (AnsiCompareText(Document.MovementSource.RelationName,
          Document.RelationName) <> 0)
        or
        (Document.MovementSource.SourceFieldName = '')
        or
        (not Document.FieldByName(Document.MovementSource.SourceFieldName).IsNull)
      )
      and
      (
        (AnsiCompareText(Document.MovementTarget.RelationName,
          Document.RelationName) <> 0)
        or
        (Document.MovementTarget.SourceFieldName = '')
         or
        (not Document.FieldByName(Document.MovementTarget.SourceFieldName).IsNull)
      );

    if Assigned(FBottomGrid) then
    begin
      FBottomGrid.Enabled :=
        (
          (AnsiCompareText(Document.MovementSource.RelationName,
            Document.RelationName) <> 0)
          or
          (Document.MovementSource.SourceFieldName = '')
          or
          (not Document.FieldByName(Document.MovementSource.SourceFieldName).IsNull)
        )
        and
        (
          (AnsiCompareText(Document.MovementTarget.RelationName,
             Document.RelationName) <> 0)
           or
           (Document.MovementTarget.SourceFieldName = '')
            or
           (not Document.FieldByName(Document.MovementTarget.SourceFieldName).IsNull)
        );
    end;
  end;

  if ibgrdTop.Enabled then
    inherited
  else
    actOk.Enabled := False;
end;

procedure TdlgInvDocument.SetCardFieldCondition(CurrDocLine: TgdcInvDocumentLine;
  GoodKey: Integer);
var
  I, J: Integer;
  R: TatRelation;
  F: TatRelationField;
  C: TgsIBColumnEditor;
  Grid: TgsIBGrid;
  Index: Integer;
  S: String;
begin
//!!!!!! При изменении ключа товара идут какие-то настройки лукапов

  if CurrDocLine = DocumentLine then
    Grid := ibgrdTop
  else
    Grid := FBottomGrid;

  for I := 0 to CurrDocLine.FieldCount - 1 do
  begin
    {Если это:
      1)вычисляемое поле или
      2) тип поля не целочисленный или
      3) поле не начинается с FROM_ или
      4) поле не пользовательское,
      то переходим к следующему полю}
    if CurrDocLine.Fields[I].Calculated or
      (CurrDocLine.Fields[I].DataType <> ftInteger) or
      (StrIPos('FROM_', CurrDocLine.Fields[I].FieldName) <> 1) or
      (StrIPos(UserPrefix, CurrDocLine.FieldNameByAliasName(
        CurrDocLine.Fields[I].FieldName)) <> 1)
    then
      Continue;

    R := atDatabase.Relations.ByRelationName(
      CurrDocLine.RelationByAliasName(CurrDocLine.Fields[I].FieldName));

    if (not Assigned(R)) or (AnsiCompareText(R.RelationName, 'INV_CARD') <> 0) then Continue;

    F := R.RelationFields.ByFieldName(CurrDocLine.FieldNameByAliasName(
      CurrDocLine.Fields[I].FieldName));

    if not Assigned(F) then Continue;

    if F.References <> nil then
    begin
      if Assigned(F.Field.RefListField) then
        S := F.Field.RefListField.FieldName
      else
        S:= F.References.ListField.FieldName;

      Index := Grid.ColumnEditors.
        IndexByField(CurrDocLine.JoinListFieldByFieldName(F.FieldName, 'CARD', S));

      if Index >= 0 then
      begin
        C := Grid.ColumnEditors[Index];

        if Assigned(F.Field) and (F.Field.RefCondition > '') then
          C.Lookup.Condition := F.Field.RefCondition
        else
          C.Lookup.Condition := '';

        if GoodKey > 0 then
        begin
          S := C.Lookup.Condition;
          if S > '' then
            S := S +  ' AND ';
          C.Lookup.Condition := S +  ' EXISTS (SELECT id FROM inv_card c WHERE c.' +
            F.FieldName + ' = ' + F.References.RelationName + '.' +
            F.References.PrimaryKey.ConstraintFields[0].FieldName +
            ' AND c.goodkey = ' + IntToStr(GoodKey) + ')'
        end;
      end;
    end
    else
    begin
      J := Grid.ColumnEditors.IndexByField(CurrDocLine.Fields[I].FieldName);
      if J > 0 then
      begin
        C := Grid.ColumnEditors[J];
        if GoodKey > 0 then
          C.Lookup.Condition := ' goodkey = ' + IntToStr(GoodKey)
        else
          C.Lookup.Condition := '';
        C.Lookup.GroupBy := F.FieldName;
      end
    end;

  end;
end;

procedure TdlgInvDocument.OnGoodKeyFieldChange(Field: TField);
begin
  {Вызываем старое событие на поле}
  RunOldOnChange(Field);
  SetCardFieldCondition((Field.DataSet as TgdcInvDocumentLine), Field.AsInteger);
end;

procedure TdlgInvDocument.actCommitExecute(Sender: TObject);
begin
  if TestCorrect then
  begin
    if not Document.Transaction.InTransaction then
      Document.Transaction.StartTransaction
    else
      Document.Transaction.CommitRetaining;
  end;
end;


procedure TdlgInvDocument.RunOldOnChange(Field: TField);
var
  i: Integer;
begin
  if Field.DataSet <> Document then
  begin
    for i:= 0 to FOldOnChangeEventList.Count - 1 do
    begin
      if TinvEventSave(FOldOnChangeEventList[i]).Field = Field then
      begin
        if Assigned(TinvEventSave(FOldOnChangeEventList[i]).OldEvent) then
          TinvEventSave(FOldOnChangeEventList[i]).OldEvent(Field);
        Break;
      end;
    end;
  end
  else
    for i:= 0 to FOldDocOnChangeEventList.Count - 1 do
    begin
      if TinvEventSave(FOldDocOnChangeEventList[i]).Field = Field then
      begin
        if Assigned(TinvEventSave(FOldDocOnChangeEventList[i]).OldEvent) then
          TinvEventSave(FOldDocOnChangeEventList[i]).OldEvent(Field);
        Break;
      end;
    end;
end;

procedure TdlgInvDocument.SetOldEvent;
var
  i: Integer;
begin
  for i:= 0 to FOldDocOnChangeEventList.Count - 1 do
    TinvEventSave(FOldDocOnChangeEventList[i]).SetOld;
end;

procedure TdlgInvDocument.Post;
  VAR
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVDOCUMENT', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVDOCUMENT', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENT',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  try

    if not DocumentLine.CachedUpdates then
      CheckDisabledPosition;

    if DocumentLine.State in [dsEdit, dsInsert] then
      DocumentLine.Post;

    if Assigned(SecondDocumentLine) and (SecondDocumentLine.State in [dsEdit, dsInsert]) then
      SecondDocumentLine.Post;

    if (DocumentLine.RecordCount > 0) and (DocumentLine.FieldByName('transactionkey').IsNull) then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := Document.ReadTransaction;
        ibsql.SQL.Text := 'SELECT id FROM gd_documenttype dt WHERE dt.id = :id and ' +
        ' dt.headerfunctionkey is not null and ' +
        ' dt.linefunctionkey is null ';
        ibsql.ParamByName('id').AsInteger := Document.FieldByName('documenttypekey').AsInteger;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          Document.CreateEntry;
        ibsql.Close;
      finally
        ibsql.Free;
      end;
    end;
    
    inherited Post;

  except
    on Exception do
    begin
      // Возвращаем режим редактрования
      if not (Document.State in [dsEdit, dsInsert]) then
        Document.Edit;

      // Окрываем позиции документа
      DocumentLine.Active := True;

      // Окрываем позиции расхода при документе - трансформация
      if Document.RelationType = irtTransformation then
        FSecondDocumentLine.Active := True;

      ModalResult := mrNone;

      raise;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENT', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENT', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvDocument.DoCreateNewObject(Sender: TObject;
  ANewObject: TgdcBase);
var
  ContactType: TgdcInvMovementContactType;
  SubContactKey: Integer;
  isSourceTarget: Boolean;
begin
  isSourceTarget := False;
  SubContactKey := -1;
  ContactType := imctOurDepartment;
  if
    ((AnsiCompareText(Document.MovementSource.RelationName,
      Document.RelationName) = 0)
      and
    (AnsiCompareText(Document.MovementSource.SourceFieldName,
      (Sender as TgsIBLookupComboBox).DataField) = 0))
  then
  begin
    ContactType := Document.MovementSource.ContactType;
    isSourceTarget := True;
    if
      (AnsiCompareText(Document.MovementSource.SubRelationName,
        Document.RelationName) = 0)
        and
      (Document.MovementSource.SubSourceFieldName <> '')
    then
      SubContactKey := gdcObject.FieldByName(Document.MovementSource.SubSourceFieldName).AsInteger
  end
  else
    if
      ((AnsiCompareText(Document.MovementTarget.RelationName,
        Document.RelationName) = 0)
        and
      (AnsiCompareText(Document.MovementTarget.SourceFieldName,
        (Sender as TgsIBLookupComboBox).DataField) = 0))
    then
    begin
      ContactType := Document.MovementTarget.ContactType;
      isSourceTarget := True;
      if
        (AnsiCompareText(Document.MovementTarget.SubRelationName,
          Document.RelationName) = 0)
          and
        (Document.MovementTarget.SubSourceFieldName <> '')
      then
        SubContactKey := gdcObject.FieldByName(Document.MovementTarget.SubSourceFieldName).AsInteger
    end;


  if isSourceTarget then
  begin
    case ContactType of
      imctOurDepartment:
        aNewObject.FieldByName('parent').AsInteger := IbLogin.CompanyKey;
      imctOurDepartAndPeople:
        aNewObject.FieldByName('parent').AsInteger := IbLogin.CompanyKey;
      imctCompanyDepartment:
        aNewObject.FieldByName('parent').AsInteger := SubContactKey;
    end;
  end;

end;

procedure TdlgInvDocument.actNewUpdate(Sender: TObject);
begin
  actNew.Enabled := FIsInsertMode;
end;

procedure TdlgInvDocument.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVDOCUMENT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  FIsInsertMode := gdcObject.State = dsInsert;

  if not FIsInsertMode then
    iblkCompany.Enabled := False;

  if not FisAutoCommit then
    ActivateTransaction(gdcObject.Transaction);

  DocumentLine.Open;
  if Assigned(SecondDocumentLine) then
    SecondDocumentLine.Open;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}

end;

procedure TdlgInvDocument.SetupDialog;

  procedure _Scan(WC: TWinControl; const T: Integer; var H: Integer);
  var
    I: Integer;
  begin
    for I := 0 to WC.ControlCount - 1 do
    begin
      if WC.Controls[I].Visible then
      begin
        if WC.Controls[I] is TWinControl then
        begin
          {if not (WC.Controls[I] is TPanel) then
          begin}
            if (WC.Controls[I].Top
              + TWinControlCrack(WC.Controls[I]).BevelWidth
              + TWinControlCrack(WC.Controls[I]).BorderWidth
              + WC.Controls[I].Height
              + T) > H then
            begin
              H := WC.Controls[I].Top
                + TWinControlCrack(WC.Controls[I]).BevelWidth
                + TWinControlCrack(WC.Controls[I]).BorderWidth
                + T
                + WC.Controls[I].Height;
            end;
          {end;}
          _Scan(WC.Controls[I] as TWinControl, WC.Controls[I].Top, H);
        end else
        begin
          if (WC.Controls[I].Top + WC.Controls[I].Height + T) > H then
            H := WC.Controls[I].Top + T + WC.Controls[I].Height;
        end;
      end;  
    end;
  end;

var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  H, NH, I: Integer;
  E1, E2: TFieldNotifyEvent;
  Path: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVDOCUMENT', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENT',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {Сохраняем старый обработчик события OnChange для поля Зачем?????}
  { TODO 5 -oЮлия : Необходимо избавиться от этой чухни. Изменять обработчики
   событий нам необходимо в  4 - х случаях, а здесь идет создание объектов на все поля.
   Их число может быть очень большим. }
{  for i:= 0 to gdcObject.FieldCount - 1 do
    FOldDocOnChangeEventList.Add(TInvEventSave.Create(gdcObject.Fields[i]));}

  inherited;

  pnlHolding.Visible := IBLogin.IsHolding;

  //
  // Только после setup необходимо осуществлять загрузку
  // свойств гридов.

  Path := BuildComponentPath(Self);

  SetupDetailPart;

  E2 := OnSubMovementOptionFieldChange;

  for I := 0 to Document.FieldCount - 1 do
  begin
    E1 := Document.Fields[I].OnChange;
    if @E1 = @E2 then
      OnSubMovementOptionFieldChange(Document.Fields[I]);
  end;

  if UserStorage <> nil then
  begin
    if Document.RelationType = irtTransformation then
    begin
      ibgrdTop.Height := UserStorage.ReadInteger(Path, 'TopGrH', ibgrdTop.Height);
    end;

    if pnlAttributes.Height > pnlMain.Height then
      H := pnlMain.Height - 10
    else
    begin
      H := UserStorage.ReadInteger(Path, 'pnlAttrH', pnlAttributes.Height, False);

      if UserStorage.ReadBoolean('Options', 'CWS', True, False) then
      begin
        NH := H;
        _Scan(pnlAttributes, 0, NH);
        if NH > H then
        begin
          {
          if MessageBox(Handle,
            'Размер верхней части окна изменен так, что не все поля ввода видны.'#13#10 +
            'Скорректировать размер?'#13#10#13#10 +
            'Отключить данную проверку вы можете в меню Сервис главного меню. Команда Опции.',
            'Внимание',
            MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
          begin
          }
            H := NH;
          {end;}
        end;
      end;
    end;

    pnlAttributes.Height := H;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENT', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvDocument.actPrintExecute(Sender: TObject);
var
  R: TRect;
begin
  if DlgModified and (MessageBox(HANDLE, 'Документ был изменен. Сохранить?', 'Внимание',
    mb_YesNo or mb_IconQuestion) = id_Yes) then
  begin
    actCommit.Execute;
  end;

  with tbDetailToolbar do
  begin
    R := View.Find(tbiPrint).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  gdcObject.PopupReportMenu(R.Left, R.Bottom);
end;

procedure TdlgInvDocument.actPrintUpdate(Sender: TObject);
begin
  actPrint.Enabled := Assigned(gdcObject) and Assigned(DocumentLine) and
    not (DocumentLine.State in [dsEdit, dsInsert]) and
    (not Assigned(SecondDocumentLine) or
    (not (SecondDocumentLine.State in  [dsEdit, dsInsert])))

end;

procedure TdlgInvDocument.SetIsInsertMode(const Value: Boolean);
begin
  FIsInsertMode := Value;
end;

function TdlgInvDocument.GetIsInsertMode: Boolean;
begin
  Result := FIsInsertMode;
end;

procedure TdlgInvDocument.BackGdcObjectsResetState;

  procedure ClearDataSetEvents(DataSet: TDataSet);
  var
    i: Integer;
  begin
    if not Assigned(DataSet) then Exit;

    if (DataSet is TgdcInvDocumentLine) then
    begin
      if DataSet = DocumentLine then
      begin
        DataSet.AfterEdit := OldAfterEditDocument;
        DataSet.OnNewRecord := OldOnNewRecordDocument;
        DataSet.AfterPost := OldAfterPostDocument;
        DataSet.AfterCancel := OldAfterCancelDocument;
        DataSet.AfterOpen := OldAfterOpenDocument;
      end
      else
      begin
        DataSet.AfterEdit := nil;
        DataSet.OnNewRecord := nil;
        DataSet.AfterPost := nil;
        DataSet.AfterCancel := nil;
        DataSet.AfterOpen := nil;
      end;
    end;

    for i:= 0 to DataSet.FieldCount - 1 do
      DataSet.Fields[i].OnChange := nil;

  end;

begin
  Assert(Assigned(DocumentLine));

  FIsClosing := True;

  ClearDataSetEvents(Document);

  SetOldEvent;

  ClearDataSetEvents(DocumentLine);

  if Assigned(FSecondDocumentLine) then
    ClearDataSetEvents(FSecondDocumentLine);

  if Assigned(FSecondDocumentLine) then
    FSecondDocumentLine.Close;

  //
  // Обязательно необходимо вернуться в нормальный режим

  if DocumentLine.ViewMovementPart <> impAll then
  begin
    DocumentLine.ViewMovementPart := impAll;
    DocumentLine.Open;
  end;
end;

procedure TdlgInvDocument.actAddGoodsWithQuantUpdate(Sender: TObject);
begin
  actAddGoodsWithQuant.Enabled := actGoodsRef.Enabled;
end;

procedure TdlgInvDocument.actAddGoodsWithQuantExecute(Sender: TObject);
var
  frm: Tgdc_frmInvSelectedGoods;
  CurrDocLine: TgdcInvDocumentLine;
begin
  frm := Tgdc_frmInvSelectedGoods.CreateSubType(Self, SubType);
  try
    if frm.ShowModal = mrOk then
    begin
    if ibgrdTop.Focused or not Assigned(FBottomGrid) then
    begin
      if ibgrdTop.CanFocus then
        ibgrdTop.SetFocus;
      CurrDocLine := DocumentLine;
    end
    else
    if FBottomGrid.Focused then
      CurrDocLine := FSecondDocumentLine
    else
      Exit;

      frm.PassSelectedGoods(CurrDocLine);
    end;
  finally
    frm.Free;
  end;
end;

procedure TdlgInvDocument.actDetailSecurityUpdate(Sender: TObject);
begin
  actDetailSecurity.Enabled := Assigned(DocumentLine)
    and (DocumentLine.State = dsBrowse)
    and (not DocumentLine.IsEmpty);
end;

procedure TdlgInvDocument.actDetailSecurityExecute(Sender: TObject);
begin
  DocumentLine.EditDialog('Tgdc_dlgObjectProperties');
end;

function TdlgInvDocument.Get_SelectedKey: OleVariant;
begin
  {Для документа трансформации вернем трехмерный массив}
  {По-хорошему, если определен FBottomGrid, то определен и FTopGrid}
  if Assigned(FBottomGrid) then
  begin
    Result := VarArrayOf([VarArrayOf([gdcObject.ID]),
      CreateSelectedArr(DocumentLine, ibgrdTop.SelectedRows),
      CreateSelectedArr(DocumentLine, FBottomGrid.SelectedRows)]);
  end else
  begin
    Result := VarArrayOf([VarArrayOf([gdcObject.ID]),
      CreateSelectedArr(DocumentLine, ibgrdTop.SelectedRows)]);
  end;
end;

procedure TdlgInvDocument.actCommitUpdate(Sender: TObject);
begin
  actCommit.Enabled := actOk.Enabled;
end;

procedure TdlgInvDocument.LoadSettings;

  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}var
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVDOCUMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVDOCUMENT', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENT',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  UserStorage.LoadComponent(ibgrdTop, ibgrdTop.LoadFromStream, FSubType);

  if Assigned(FBottomGrid) then
    UserStorage.LoadComponent(FBottomGrid, FBottomGrid.LoadFromStream, FSubType);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENT', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvDocument.actViewCardExecute(Sender: TObject);
begin
  with Tgdc_frmInvCard.Create(Self) as Tgdc_frmInvCard do
  try
    gdcInvCard.Close;
    if ibgrdTop.Focused or not Assigned(FBottomGrid) then
       gdcInvCard.gdcInvDocumentLine := DocumentLine
    else
      if Assigned(SecondDocumentLine) then
        gdcInvCard.gdcInvDocumentLine := SecondDocumentLine;

    gdcObject := gdcInvCard;
    RunCard;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TdlgInvDocument.SetupTransaction;
begin
  inherited;
  if not FisAutoCommit then
    ActivateTransaction(gdcObject.Transaction);
end;

function TdlgInvDocument.GetFormCaptionPrefix: String;
begin
  if gdcObject.State = dsInsert then
    Result := 'Добавление документа: '
  else if gdcObject.State = dsEdit then
    Result := 'Редактирование документа: '
  else
    Result := 'Просмотр документа: ';
end;

procedure TdlgInvDocument.FormCreate(Sender: TObject);
begin
  inherited;
  Assert(IBLogin <> nil);
  pnlHolding.Enabled := IBLogin.IsHolding;
  if pnlHolding.Enabled then
  begin
    iblkCompany.Condition := 'gd_contact.id IN (' + IBLogin.HoldingList + ')';
  end;
end;

constructor TdlgInvDocument.CreateNewUser(AnOwner: TComponent;
  const Dummy: Integer; const ASubType: String);
begin
  inherited;
  FIsAutoCommit := False;
  FIsClosing := False;
  FIsLocalChange := False;
  FIsInsertMode := False;

  OldAfterEditDocument := nil;
  OldOnNewRecordDocument := nil;
  OldAfterPostDocument := nil;
  OldAfterCancelDocument := nil;
  OldAfterOpenDocument := nil;

  FOldOnChangeEventList := TObjectList.Create;
  FOldDocOnChangeEventList := TObjectList.Create;

  FBottomGrid := nil;

  FTopDataSource := nil;
  FBottomDataSource := nil;

  FFirstDocumentLine := nil;
  FSecondDocumentLine := nil;
end;

constructor TdlgInvDocument.CreateUser(AnOwner: TComponent;
  const AFormName, ASubType: String; const AForEdit: Boolean);
begin
  inherited;
  FIsAutoCommit := False;
  FIsClosing := False;
  FIsLocalChange := False;
  FIsInsertMode := False;

  OldAfterEditDocument := nil;
  OldOnNewRecordDocument := nil;
  OldAfterPostDocument := nil;
  OldAfterCancelDocument := nil;
  OldAfterOpenDocument := nil;

  FOldOnChangeEventList := TObjectList.Create;
  FOldDocOnChangeEventList := TObjectList.Create;

  FBottomGrid := nil;

  FTopDataSource := nil;
  FBottomDataSource := nil;

  FFirstDocumentLine := nil;
  FSecondDocumentLine := nil;
end;

function TdlgInvDocument.GetTopGrid: TgsIBGrid;
begin
  Result := ibgrdTop;
end;

procedure TdlgInvDocument.actViewFullCardExecute(Sender: TObject);
begin
  with Tgdc_frmInvCard.Create(Self) as Tgdc_frmInvCard do
  try
    gdcInvCard.Close;
    if ibgrdTop.Focused or not Assigned(FBottomGrid) then
       gdcInvCard.gdcInvDocumentLine := DocumentLine
    else
      if Assigned(SecondDocumentLine) then
        gdcInvCard.gdcInvDocumentLine := SecondDocumentLine;
    gdcObject := gdcInvCard;
    gdcObject.SubSet := 'ByHolding,ByGoodOnly';    
    RunCard;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TdlgInvDocument.actViewCardUpdate(Sender: TObject);
begin
  inherited;
  //
end;

initialization
  RegisterFrmClass(TdlgInvDocument);

finalization
  UnRegisterFrmClass(TdlgInvDocument);
end.


