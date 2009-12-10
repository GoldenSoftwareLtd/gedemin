
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_dlgInvDocumentLine_unit.pas

  Abstract

    Part of a business class. Dialog window for
    edition of inventory document line.

  Author

    Romanovski Denis (23-09-2001)

  Revisions history

    Initial  23-09-2001  Dennis  Initial version.
             01-11-2001  sai     Переделаны методы выбоки

--}

unit gdc_dlgInvDocumentLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Db, ActnList, StdCtrls, ExtCtrls, at_Container,
  gdcInvDocument_unit, Mask, DBCtrls, gsIBLookupComboBox, gdc_dlgTR_unit,
  IBDatabase, IBSQL, gdcContacts, Menus, ComCtrls;

type
  TdlgInvDocumentLine = class(Tgdc_dlgTR)
    actGoodsRef: TAction;
    actRemainsRef: TAction;
    actMacro: TAction;
    pnlData: TPanel;
    pcMain: TPageControl;
    tsAttributes: TTabSheet;
    atAttributes: TatContainer;
    tsMain: TTabSheet;
    sbMain: TScrollBox;
    TabSheet1: TTabSheet;
    pnlReferences: TPanel;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure actGoodsRefExecute(Sender: TObject);
    procedure actRemainsRefExecute(Sender: TObject);
    procedure actMacroExecute(Sender: TObject);

    procedure atAttributesRelationNames(Sender: TObject; Relations,
      FieldAliases: TStringList);
    procedure atAttributesAdjustControl(Sender: TObject;
      Control: TControl);

  private
    FOurCompany: TgdcOurCompany;
    FContactSQL: TIBSQL;
    FDocument: TgdcInvDocument;

    FIsClosing: Boolean;

    function GetDocument: TgdcInvDocument;
    function GetDocumentLine: TgdcInvDocumentLine;

    procedure CreateContactSQL;

    procedure OnSubLineMovementOptionFieldChange(Field: TField);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    function TestCorrect: Boolean; override;

    procedure SetupDialog; override;

    procedure LoadSettingsAfterCreate; override;
    procedure SaveSettings; override;

    property Document: TgdcInvDocument read GetDocument;
    property DocumentLine: TgdcInvDocumentLine read GetDocumentLine;

    class function GetSubTypeList(SubTypeList: TStrings): Boolean; override;
  end;

var
  dlgInvDocumentLine: TdlgInvDocumentLine;

implementation

{$R *.DFM}

uses
  gdcInvConsts_unit, at_classes, Storages, gd_security, gdcGood, gdcBase,  gd_ClassList;

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

{ TdlgInvDocumentLine }

constructor TdlgInvDocumentLine.Create(AnOwner: TComponent);
begin
  inherited;

  FOurCompany := TgdcOurCompany.Create(nil);
  FContactSQL := nil;

  FDocument := nil;

  FIsClosing := False;
end;

destructor TdlgInvDocumentLine.Destroy;
begin
  FOurCompany.Free;
  
  if Assigned(FContactSQL) then
    FreeAndNil(FContactSQL);
    
  inherited;
end;

function TdlgInvDocumentLine.GetDocumentLine: TgdcInvDocumentLine;
begin
  Result := gdcObject as TgdcInvDocumentLine;
end;

function TdlgInvDocumentLine.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TDLGINVDOCUMENTLINE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TDLGINVDOCUMENTLINE', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENTLINE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENTLINE',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENTLINE' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := True;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENTLINE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENTLINE', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvDocumentLine.actGoodsRefExecute(Sender: TObject);
var
  Good: TgdcGood;
  V: OleVariant;
  I: Integer;
begin
  //
  // Осуществляем выбор товаров из справочника

  pcMain.ActivePage := tsMain;

  Good := TgdcGood.Create(nil);

  try
    if Good.ChooseItems(V, 'gdcGood') then
    begin
      for I := 0 to VarArrayHighBound(V, 1) do
      begin
      {Чтобы добавление шло по порядку делаем Append, а не Insert}
        DocumentLine.Append;
        DocumentLine.FieldByName('GOODKEY').AsInteger := V[I];

        if DocumentLine.RelationType = irtTransformation then
          DocumentLine.FieldByName('INQUANTITY').AsInteger := 1
        else
          DocumentLine.FieldByName('QUANTITY').AsInteger := 1;

        DocumentLine.UpdateGoodNames;
        DocumentLine.Post;
      end;
    end;
  finally
    Good.Free;
  end;
end;

procedure TdlgInvDocumentLine.actRemainsRefExecute(Sender: TObject);
begin
  pcMain.ActivePage := tsMain;
  DocumentLine.ChooseRemains;
end;

procedure TdlgInvDocumentLine.actMacroExecute(Sender: TObject);
begin
  pcMain.ActivePage := tsMain;
  inherited;
//
end;

procedure TdlgInvDocumentLine.atAttributesRelationNames(Sender: TObject;
  Relations, FieldAliases: TStringList);
var
  I: Integer;
  F: TatRelationField;  
begin
  //
  // Добавляем поля

  for I := 0 to DocumentLine.FieldCount - 1 do
    if
      not DocumentLine.Fields[I].Calculated and
      (
        (AnsiCompareText(
          DocumentLine.RelationByAliasName(DocumentLine.Fields[I].FieldName),
          DocumentLine.RelationLineName) = 0)
          or
        (AnsiCompareText(
          DocumentLine.RelationByAliasName(DocumentLine.Fields[I].FieldName),
          'INV_CARD') = 0)
          or
        (AnsiCompareText(
          DocumentLine.RelationByAliasName(DocumentLine.Fields[I].FieldName),
          'GD_GOOD') = 0)
      )
    then begin
      F := atDatabase.FindRelationField(
        DocumentLine.RelationByAliasName(DocumentLine.Fields[I].FieldName),
        DocumentLine.FieldNameByAliasName(DocumentLine.Fields[I].FieldName));

      if Assigned(F) and F.IsUserDefined then
        FieldAliases.Add(DocumentLine.Fields[I].FieldName);
    end;

  FieldAliases.Add('GOODKEY');

  case DocumentLine.RelationType of
    irtSimple, irtFeatureChange:
    begin
      FieldAliases.Add('QUANTITY');
    end;
    irtTransformation:
    begin
      FieldAliases.Add('INQUANTITY');
      FieldAliases.Add('OUTQUANTITY');
    end;
    irtInventorization:
    begin
      FieldAliases.Add('FROMQUANTITY');
      FieldAliases.Add('TOQUANTITY');
    end;
  end;
end;

procedure TdlgInvDocumentLine.LoadSettingsAfterCreate;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVDOCUMENTLINE', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVDOCUMENTLINE', KEYLOADSETTINGSAFTERCREATE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGSAFTERCREATE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENTLINE',
  {M}          'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

{ if UserStorage <> nil then
    UserStorage.LoadComponent(atAttributes, atAttributes.LoadFromStream,
      FSubType);}
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENTLINE', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENTLINE', 'LOADSETTINGSAFTERCREATE', KEYLOADSETTINGSAFTERCREATE);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvDocumentLine.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVDOCUMENTLINE', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVDOCUMENTLINE', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENTLINE',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

{ if UserStorage <> nil then
    UserStorage.SaveComponent(atAttributes, atAttributes.SaveToStream,
      FSubType);}
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENTLINE', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENTLINE', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TdlgInvDocumentLine.atAttributesAdjustControl(Sender: TObject;
  Control: TControl);
var
  IsAsConstraint: Boolean;
  HasConstraint: Boolean;
  ContactType: TgdcInvMovementContactType;
  Predefined: String;
  M: TgdcInvMovementContactOption;
  LB, RB: Integer;
begin
  // Если осуществляется выход из окна, не
  // производим никаких действий
  if FIsClosing then Exit;

  FOurCompany.SubSet := 'ByID';
  FOurCompany.ID := IbLogin.CompanyKey;
  FOurCompany.Active := True;

  if Control is TgsIBLookupComboBox then
  with Control as TgsIBLookupComboBox do
  begin
    //
    // Проверка на случай использования поля, как указателя на получателя
    // и источник ТМЦ

    //
    // Если расход в верхней таблице

    if
      (AnsiCompareText(DocumentLine.MovementSource.RelationName,
        DocumentLine.RelationLineName) = 0)
        and
      (AnsiCompareText(DocumentLine.MovementSource.SourceFieldName,
        DataField) = 0)
    then begin
      IsAsConstraint := False;
      HasConstraint := (DocumentLine.MovementSource.SubRelationName > '') and
        (DocumentLine.MovementSource.SubSourceFieldName > '');

      M := DocumentLine.MovementSource;

      ContactType := DocumentLine.MovementSource.ContactType;
      Predefined := GetArrAsCommaText(DocumentLine.MovementSource.Predefined);
    end else

    //
    // Если приход в верхней таблице

    if
      (AnsiCompareText(DocumentLine.MovementTarget.RelationName,
        DocumentLine.RelationLineName) = 0)
        and
      (AnsiCompareText(DocumentLine.MovementTarget.SourceFieldName,
        DataField) = 0)
    then begin
      IsAsConstraint := False;
      HasConstraint := (DocumentLine.MovementTarget.SubRelationName > '') and
        (DocumentLine.MovementTarget.SubSourceFieldName > '');

      M := DocumentLine.MovementTarget;

      ContactType := DocumentLine.MovementTarget.ContactType;
      Predefined := GetArrAsCommaText(DocumentLine.MovementTarget.Predefined);
    end else

    //
    //  Если ограничение по расходу в верхней таблице

    if
      (AnsiCompareText(DocumentLine.MovementSource.SubRelationName,
        DocumentLine.RelationLineName) = 0)
        and
      (AnsiCompareText(DocumentLine.MovementSource.SubSourceFieldName,
        DataField) = 0)
    then begin
      IsAsConstraint := True;
      HasConstraint := False;
      ContactType := DocumentLine.MovementSource.ContactType;

      M := DocumentLine.MovementSource;

      DocumentLine.FieldByName(DocumentLine.MovementSource.SubSourceFieldName).OnChange :=
        OnSubLineMovementOptionFieldChange;

      Predefined := GetArrAsCommaText(DocumentLine.MovementSource.SubPredefined);
    end else

    //
    //  Если ограничение по приходу в верхней таблице

    if
      (AnsiCompareText(DocumentLine.MovementTarget.SubRelationName,
        DocumentLine.RelationLineName) = 0)
        and
      (AnsiCompareText(DocumentLine.MovementTarget.SubSourceFieldName,
        DataField) = 0)
    then begin
      IsAsConstraint := True;
      HasConstraint := False;
      ContactType := DocumentLine.MovementTarget.ContactType;

      M := DocumentLine.MovementTarget;

      DocumentLine.FieldByName(DocumentLine.MovementTarget.SubSourceFieldName).OnChange :=
        OnSubLineMovementOptionFieldChange;

      Predefined := GetArrAsCommaText(DocumentLine.MovementTarget.SubPredefined);
    end else
      Exit;

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
        ListField := '';
        ListTable := 'GD_V_OURCOMPANY';
        ListField := 'COMPNAME';
        KeyField := 'COMPID';
      end;
      imctOurDepartment:
      begin
        if HasConstraint then
        begin
          if AnsiCompareText(M.SubRelationName, DocumentLine.RelationName) = 0 then
          begin
            CreateContactSQL;
            FContactSQL.Close;
            FContactSQL.ParamByName('ID').AsInteger :=
              Document.FieldByName(M.SubSourceFieldName).AsInteger;
            FContactSQL.ExecQuery;

            LB := FContactSQL.FieldByName('LB').AsInteger;
            RB := FContactSQL.FieldByName('RB').AsInteger;
          end else begin
            LB := 0;
            RB := 0;
          end;
        end else begin
          LB := FOurCompany.FieldByName('LB').AsInteger;
          RB := FOurCompany.FieldByName('RB').AsInteger;
        end;

        if Condition > '' then
          Condition := Condition + ' AND ';

        Condition := Format('CONTACTTYPE IN (4) AND LB >= %d AND RB <= %d', [LB, RB]);
      end;
      imctOurPeople:
      begin
        ListField := '';
        ListTable := 'GD_V_CONTACTLIST';
        ListField := 'CONTACTNAME';
        KeyField := 'ID';

        if HasConstraint then
        begin
          if AnsiCompareText(M.SubRelationName, DocumentLine.RelationName) = 0 then
          begin
            CreateContactSQL;
            FContactSQL.Close;
            FContactSQL.ParamByName('ID').AsInteger :=
              Document.FieldByName(M.SubSourceFieldName).AsInteger;
            FContactSQL.ExecQuery;

            LB := FContactSQL.FieldByName('LB').AsInteger;
            RB := FContactSQL.FieldByName('RB').AsInteger;
          end else begin
            LB := 0;
            RB := 0;
          end;
        end else begin
          LB := FOurCompany.FieldByName('LB').AsInteger;
          RB := FOurCompany.FieldByName('RB').AsInteger;
        end;

        if Condition > '' then
          Condition := Condition + ' AND ';

        Condition :=
          Format(
            'CONTACTTYPE IN (2) AND GROUPLB >= %d AND GROUPRB <= %d ' +
            'GROUP BY CONTACTID, CONTACTNAME',
            [LB, RB]
          );
      end;
      imctCompany:
      begin
        if Condition > '' then
          Condition := Condition + ' AND ';

        Condition := 'CONTACTTYPE IN (3)';
      end;
      imctCompanyDepartment:
      begin
        if Condition > '' then
          Condition := Condition + ' AND ';

        if HasConstraint and
          (AnsiCompareText(M.SubRelationName, DocumentLine.RelationName) = 0) then
        begin
          CreateContactSQL;
          FContactSQL.Close;
          FContactSQL.ParamByName('ID').AsInteger :=
            Document.FieldByName(M.SubSourceFieldName).AsInteger;
          FContactSQL.ExecQuery;

          LB := FContactSQL.FieldByName('LB').AsInteger;
          RB := FContactSQL.FieldByName('RB').AsInteger;
        end else begin
          LB := 0;
          RB := 0;
        end;

        Condition := Format('CONTACTTYPE IN (4) AND LB >= %d AND RB <= %d',
          [LB, RB]);
      end;
      imctCompanyPeople:
      begin
        ListField := '';
        ListTable := 'GD_V_CONTACTLIST';
        ListField := 'CONTACTNAME';
        KeyField := 'ID';

        if Condition > '' then
          Condition := Condition + ' AND ';

        if HasConstraint and
          (AnsiCompareText(M.SubRelationName, DocumentLine.RelationName) = 0) then
        begin
          CreateContactSQL;
          FContactSQL.Close;
          FContactSQL.ParamByName('ID').AsInteger :=
            Document.FieldByName(M.SubSourceFieldName).AsInteger;
          FContactSQL.ExecQuery;

          LB := FContactSQL.FieldByName('LB').AsInteger;
          RB := FContactSQL.FieldByName('RB').AsInteger;
        end else begin
          LB := 0;
          RB := 0;
        end;

        Condition := Format(
          'CONTACTTYPE IN (2) AND GROUPLB >= %d AND GROUPRB <= %d ' +
          ' GROUP BY CONTACTID, CONTACTNAME',
          [LB, RB]);
      end;
      imctPeople:
      begin
        if Condition > '' then
          Condition := Condition + ' AND ';

        Condition := 'CONTACTTYPE IN (2)';
      end;
    end;

    //
    // Если есть предустановленные значения, заполняем их

    if Predefined > '' then
    begin
      if Condition > '' then
        Condition := Condition + ' AND';

      Condition := Condition + Format('(%s IN (%s))', [KeyField, Predefined]);
    end;
  end;
end;

procedure TdlgInvDocumentLine.OnSubLineMovementOptionFieldChange(
  Field: TField);
var
  MovementOption: TgdcInvMovementContactOption;

  procedure ProceedMovementChange;
  var
    C: TgsIBLookupComboBox;
  begin
    C := atAttributes.ControlByFieldName[MovementOption.SourceFieldName] as
      TgsIBLookupComboBox;

    FContactSQL.ParamByName('ID').AsInteger :=
      DocumentLine.FieldByName(MovementOption.SubSourceFieldName).AsInteger;

    FContactSQL.ExecQuery;

    case MovementOption.ContactType of
      imctOurDepartment:
      begin
        C.Condition := Format('CONTACTTYPE IN (4) AND LB >= %d AND RB <= %d',
          [FContactSQL.FieldByName('LB').AsInteger, FContactSQL.FieldByName('RB').AsInteger]);
      end;
      imctOurPeople:
      begin
        C.Condition := Format(
            'CONTACTTYPE IN (2) AND GROUPLB >= %d AND GROUPRB <= %d ' +
            'GROUP BY CONTACTID, CONTACTNAME',
            [FOurCompany.FieldByName('LB').AsInteger, FOurCompany.FieldByName('RB').AsInteger]
          );
      end;
      imctCompanyDepartment:
      begin
        C.Condition := Format('CONTACTTYPE IN (4) AND LB >= %d AND RB <= %d',
          [FContactSQL.FieldByName('LB').AsInteger, FContactSQL.FieldByName('RB').AsInteger]);
      end;

      imctCompanyPeople:
      begin
        C.Condition := Format(
          'CONTACTTYPE IN (2) AND GROUPLB >= %d AND GROUPRB <= %d ' +
          ' GROUP BY CONTACTID, CONTACTNAME',
          [FContactSQL.FieldByName('LB').AsInteger, FContactSQL.FieldByName('RB').AsInteger]);
      end;
    end;

    FContactSQL.Close;
  end;

begin
  if not Assigned(DocumentLine) then Exit;

  CreateContactSQL;

  if
    (AnsiCompareText(DocumentLine.MovementSource.SubRelationName,
      DocumentLine.RelationLineName) = 0)
      and
    (AnsiCompareText(Field.FieldName,
      DocumentLine.MovementSource.SubSourceFieldName) = 0)
  then begin
    MovementOption := DocumentLine.MovementSource;
    ProceedMovementChange;
  end;

  if
    (AnsiCompareText(DocumentLine.MovementTarget.SubRelationName,
      DocumentLine.RelationLineName) = 0)
      and
    (AnsiCompareText(Field.FieldName,
      DocumentLine.MovementTarget.SubSourceFieldName) = 0)
  then begin
    MovementOption := DocumentLine.MovementTarget;
    ProceedMovementChange;
  end;
end;

procedure TdlgInvDocumentLine.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;

  FIsClosing := True;
end;

function TdlgInvDocumentLine.GetDocument: TgdcInvDocument;
begin
  if Assigned(DocumentLine.MasterSource) and Assigned(DocumentLine.MasterSource.DataSet) then
    Result := DocumentLine.MasterSource.DataSet as TgdcInvDocument
  else
  begin
    if not Assigned(FDocument) then
    begin
      FDocument := TgdcInvDocument.Create(Self);
      FDocument.SubType := DocumentLine.SubType;
      FDocument.SubSet := 'ByID';
      FDocument.ID := DocumentLine.FieldByName('parent').AsInteger;
      FDocument.Open;
    end;
    Result := FDocument;
  end;
end;

procedure TdlgInvDocumentLine.CreateContactSQL;
begin
  if not Assigned(FContactSQL) then
  begin
    FContactSQL := TIBSQL.Create(nil);
    FContactSQL.Database := DocumentLine.Database;
    FContactSQL.Transaction := DocumentLine.ReadTransaction;
    FContactSQL.SQL.Text := 'SELECT LB, RB FROM GD_CONTACT WHERE ID = :ID';
  end;
end;

class function TdlgInvDocumentLine.GetSubTypeList(
  SubTypeList: TStrings): Boolean;
begin
  Result := TgdcInvDocumentLine.GetSubTypeList(SubTypeList);
end;

procedure TdlgInvDocumentLine.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ButtonCount: Integer;
  Btn: TButton;
  E1, E2: TFieldNotifyEvent;
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TDLGINVDOCUMENTLINE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TDLGINVDOCUMENTLINE', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGINVDOCUMENTLINE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGINVDOCUMENTLINE',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TDLGINVDOCUMENTLINE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if DocumentLine.State = dsInsert then
    Caption := 'Добавление позиции документа: ' + DocumentLine.DocumentName[False]
  else
  if DocumentLine.State = dsEdit then
    Caption := 'Редактирование позиции документа: ' + DocumentLine.DocumentName[False]
  else
    Caption := 'Позиции документа: ' + DocumentLine.DocumentName[False];

  //
  //  Настройка используемых справочников

  ButtonCount := 0;

  // Справочник товаров
  if irsGoodRef in DocumentLine.Sources then
  begin
    Btn := TButton.Create(Self);
    Btn.SetBounds(8, 8 + ButtonCount * (21 + 7), 94, 21);
    pnlReferences.InsertControl(Btn);
    Btn.Action := actGoodsRef;
    Inc(ButtonCount);
  end;

  // Справочник остатков
  if irsRemainsRef in DocumentLine.Sources then
  begin
    Btn := TButton.Create(Self);
    Btn.SetBounds(8, 8 + ButtonCount * (21 + 7), 94, 21);
    pnlReferences.InsertControl(Btn);
    Btn.Action := actRemainsRef;
    Inc(ButtonCount);
  end;

  // Вызов справочника из макроса
  if irsMacro in DocumentLine.Sources then
  begin
    Btn := TButton.Create(Self);
    Btn.SetBounds(8, 8 + ButtonCount * (21 + 7), 94, 21);
    pnlReferences.InsertControl(Btn);
    Btn.Action := actMacro;
  end;

  //
  // Осуществляем настройку ограничений

  E2 := OnSubLineMovementOptionFieldChange;

  for I := 0 to DocumentLine.FieldCount - 1 do
  begin
    E1 := DocumentLine.Fields[I].OnChange;
    if @E1 = @E2 then
      OnSubLineMovementOptionFieldChange(DocumentLine.Fields[I]);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGINVDOCUMENTLINE', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGINVDOCUMENTLINE', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(TdlgInvDocumentLine);

finalization
  UnRegisterFrmClass(TdlgInvDocumentLine);

end.

