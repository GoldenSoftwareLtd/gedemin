unit gdcCustomTable;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcMetaData;

type
  TgdcCustomTable = class(TgdcBaseTable)
  public
    class function GetRestrictCondition(const ATableName,
      ASubType: String): String; override;
  end;

  TgdcBaseDocumentTable = class(TgdcCustomTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;

  public
    class function GetPrimaryFieldName: String; override;
  end;

  TgdcInheritedDocumentTable = class(TgdcBaseDocumentTable)
  end;

  TgdcDocumentTable = class(TgdcBaseDocumentTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
  end;

  TgdcBaseDocumentLineTable = class(TgdcBaseDocumentTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
  end;

  TgdcDocumentLineTable = class(TgdcBaseDocumentLineTable)
  public
    class function GetRestrictCondition(const ATableName,
      ASubType: String): String; override;
  end;


  TgdcInvSimpleDocumentLineTable = class(TgdcBaseDocumentLineTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
  end;

  TgdcInvFeatureDocumentLineTable = class(TgdcBaseDocumentLineTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
  end;

  TgdcInvInventDocumentLineTable = class(TgdcBaseDocumentLineTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
  end;

  TgdcInvTransformDocumentLineTable = class(TgdcBaseDocumentLineTable)
  protected
    procedure GetMetadataScript(S: TSQLProcessList;
      const AMetadata: TgdcMetadataScript); override;
    procedure MakePredefinedObjects; override;
  end;

procedure Register;

implementation

uses
  gd_ClassList, gdcBaseInterface;

procedure Register;
begin
  RegisterComponents('GDC', [TgdcDocumentTable, TgdcDocumentLineTable,
    TgdcInvSimpleDocumentLineTable,
    TgdcInvFeatureDocumentLineTable,
    TgdcInvInventDocumentLineTable,
    TgdcInvTransformDocumentLineTable]);
end;

{ TgdcCustomTable }

class function TgdcCustomTable.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result :=
    '(z.id IN (SELECT d.relationkey FROM at_relation_fields d WHERE d.fieldname = ''DOCUMENTKEY'')) '#13#10 +
    'AND '#13#10 +
    '(z.id NOT IN (SELECT d.relationkey FROM at_relation_fields d WHERE d.fieldname = ''MASTERKEY'')) '#13#10 +
    'AND '#13#10 +
    '(z.relationname NOT IN (''INV_CARD'', ''INV_MOVEMENT'', ''AC_RECORD'', ''AC_ENTRY'')) '#13#10 +
    'AND '#13#10 +
    '(z.relationname NOT LIKE ''%LINE'')';
end;

{ TgdcDocumentTable }

procedure TgdcBaseDocumentTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
var
  KeyName: String;
begin
  if AMetadata = mdsCreate then
  begin
    S.Add(
      Format(
        'CREATE TABLE %s '#13#10 +
        '( '#13#10 +
        '  documentkey               dintkey, '#13#10 +
        '  PRIMARY KEY (documentkey) '#13#10 +
        ')',
        [FieldByName('relationname').AsString])
      );
    KeyName := gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_DK',
      [FieldByName('relationname').AsString]));
    S.Add(Format(
      'ALTER TABLE %0:s ADD CONSTRAINT %1:s ' +
      '  FOREIGN KEY (documentkey) REFERENCES gd_document(id) ON UPDATE CASCADE ON DELETE CASCADE ',
      [FieldByName('relationname').AsString, KeyName]));
  end;

  inherited;
end;

class function TgdcBaseDocumentTable.GetPrimaryFieldName: String;
begin
  Result := 'documentkey';
end;

{ TgdcDocumentTable }

procedure TgdcDocumentTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
begin
  inherited;

  if AMetadata = mdsCreate then
    S.Add('ALTER TABLE ' + FieldByName('relationname').AsString + ' ADD reserved dinteger');
end;

procedure TgdcDocumentTable.MakePredefinedObjects;
begin
  inherited;
  NewField('RESERVED',
    'Зарезервировано', 'DINTEGER', 'Зарезервировано', 'Зарезервировано',
    'L', '10', '1', '0');
end;

{ TgdcBaseDocumentLineTable }

procedure TgdcBaseDocumentLineTable.GetMetadataScript(S: TSQLProcessList;
  const AMetadata: TgdcMetadataScript);
var
  N: String;
begin
  inherited;

  if AMetadata = mdsCreate then
  begin
    S.Add('ALTER TABLE ' + FieldByName('relationname').AsString + ' ADD reserved dinteger');

    S.Add(Format('ALTER TABLE %s ADD masterkey DMASTERKEY ', [FieldByName('relationname').AsString]));

    N := gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_MK',
      [FieldByName('relationname').AsString]));

    S.Add(Format(
      'ALTER TABLE %0:s ADD CONSTRAINT %1:s ' +
      '  FOREIGN KEY (masterkey) REFERENCES gd_document(id) ON UPDATE CASCADE ON DELETE CASCADE ',
      [FieldByName('relationname').AsString, N]));
  end;
end;

procedure TgdcBaseDocumentLineTable.MakePredefinedObjects;
begin
  inherited;
  NewField('RESERVED',
    'Зарезервировано', 'DINTEGER', 'Зарезервировано', 'Зарезервировано',
    'L', '10', '1', '0');
  NewField('MASTERKEY',
    'Родитель', 'DMASTERKEY', 'Родитель', 'Родитель',
    'L', '10', '1', '0');
end;

(*
procedure TgdcBaseDocumentLineTable.MakePredefinedRelationFields;
var
  i: Integer;
  S: String;
  FieldName, LName, FieldSource: String;
begin
  inherited;
  if Assigned(gdcTableField) then
  begin
    NewField('MASTERKEY',
      'Родитель', 'DMASTERKEY', 'Родитель', 'Родитель',
      'L', '10', '1', '0');
    {for i:= 0 to AdditionCreateField.Count - 1 do
    begin
      S := AdditionCreateField[i];
      FieldName := System.copy(S, 1, Pos(';', S) - 1);
      S := System.copy(S, Pos(';', S) + 1, Length(S));
      LName := System.copy(S, 1, Pos(';', S) - 1);
      S := System.copy(S, Pos(';', S) + 1, Length(S));
      if Pos(';', S) > 0 then
        FieldSource := System.copy(S, 1, Pos(';', S) - 1)
      else
        FieldSource := S;
      NewField(FieldName, LName, FieldSource, LName, LName, 'L', '10', '1', '1');
    end;}
  end;
end;
*)

{ TgdcInvSimpleDocumentLineTable }

procedure TgdcInvSimpleDocumentLineTable.GetMetadataScript(
  S: TSQLProcessList; const AMetadata: TgdcMetadataScript);
begin
  inherited;

  if AMetadata = mdsCreate then
  begin
    S.Add(Format('ALTER TABLE %s ADD fromcardkey DINTKEY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD quantity DQUANTITY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD remains DQUANTITY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD disabled DDISABLED ',
      [FieldByName('relationname').AsString]));

    S.Add(Format(
        'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
        'BEFORE INSERT POSITION 1 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE delayed INTEGER; '#13#10 +
        '  DECLARE VARIABLE debit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE credit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fc INTEGER; '#13#10 +
        '  DECLARE VARIABLE tc INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  /* Trigger body */ '#13#10 +
        '  /* Disabled = 1 - позиция не формрует движение, она отклчена программой */ '#13#10 +
        '  IF (NEW.disabled = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '  /* Delayed = 1 - формруется отложенная накладная (движение не формируется по желанию пользователя) */ '#13#10 +
        '    delayed = 0;'#13#10 +
        '    SELECT delayed FROM gd_document WHERE id = NEW.masterkey'#13#10 +
        '    INTO :delayed;'#13#10 +
        '    IF ((:delayed = 0) OR (:delayed IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      /* Проверяем соответствие количества по документу с движением */ '#13#10 +
        '      SELECT SUM(debit), SUM(credit) FROM inv_movement'#13#10 +
        '      WHERE documentkey = NEW.documentkey'#13#10 +
        '      INTO :debit, :credit;'#13#10 +
        '      IF (debit IS NULL) THEN '#13#10 +
        '        debit = 0; '#13#10 +
        '      IF (credit IS NULL) THEN '#13#10 +
        '        credit = 0; '#13#10 +
        '      IF ((:debit <> NEW.quantity) OR (:credit <> NEW.quantity)) THEN'#13#10 +
        '        EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '/*      fc = NULL;'#13#10 +
        '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
        '      INTO :fc;'#13#10 +
        '      IF (:fc > 0) THEN'#13#10 +
        '        NEW.fromcardkey = :fc; */'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END ',
        [FieldByName('relationname').AsString,
         gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)]
        ));

    S.Add(Format(
        'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
        'BEFORE UPDATE POSITION 1 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE delayed INTEGER; '#13#10 +
        '  DECLARE VARIABLE debit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE credit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fc INTEGER; '#13#10 +
        '  DECLARE VARIABLE tc INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  /* Trigger body */ '#13#10 +
        '  /* Disabled = 1 - позиция не формрует движение, она отклчена программой */ '#13#10 +
        '  IF (NEW.disabled = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '  /* Delayed = 1 - формруется отложенная накладная (движение не формируется по желанию пользователя) */ '#13#10 +
        '    delayed = 0;'#13#10 +
        '    SELECT delayed FROM gd_document WHERE id = NEW.masterkey'#13#10 +
        '    INTO :delayed;'#13#10 +
        '    IF ((:delayed = 0) OR (:delayed IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      /* Проверяем соответствие количества по документу с движением */ '#13#10 +
        '      SELECT SUM(debit), SUM(credit) FROM inv_movement'#13#10 +
        '      WHERE documentkey = NEW.documentkey'#13#10 +
        '      INTO :debit, :credit;'#13#10 +
        '      IF (debit IS NULL) THEN '#13#10 +
        '        debit = 0; '#13#10 +
        '      IF (credit IS NULL) THEN '#13#10 +
        '        credit = 0; '#13#10 +
        '      IF ((:debit <> NEW.quantity) OR (:credit <> NEW.quantity)) THEN'#13#10 +
        '        EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '/*      fc = NULL;'#13#10 +
        '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
        '      INTO :fc;'#13#10 +
        '      IF (:fc > 0) THEN'#13#10 +
        '        NEW.fromcardkey = :fc; */'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END ',
        [FieldByName('relationname').AsString,
         gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString)]
        ));

    S.Add(
      Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:S '#13#10 +
      'BEFORE DELETE '#13#10 +
      'POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  DELETE FROM inv_movement WHERE documentkey = OLD.documentkey; '#13#10 +
      'END ', [FieldByName('relationname').AsString,
        gdcBaseManager.AdjustMetaName('USR$BD_' + FieldByName('relationname').AsString)]));

    S.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:s FOREIGN KEY (fromcardkey) ' +
      ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString,
      gdcBaseManager.AdjustMetaName(Format('USR$FC%0:s_FC', [FieldByName('relationname').AsString]))]));
  end;
end;

procedure TgdcInvSimpleDocumentLineTable.MakePredefinedObjects;
begin
  inherited;
  NewField('FROMCARDKEY',
    'Из карточки', 'DINTKEY', 'Из карточки', 'Из карточки',
    'L', '10', '1', '0');

  NewField('QUANTITY',
    'Кол-во ТМЦ', 'DQUANTITY', 'Кол-во ТМЦ', 'Кол-во ТМЦ',
    'R', '16', '0', '1');

  NewField('REMAINS',
    'Остаток', 'DQUANTITY', 'Остаток', 'Остаток',
    'L', '16', '1', '1');

  NewField('DISABLED',
    'Отключено', 'DDISABLED', 'Отключено', 'Отключено',
    'L', '16', '1', '1');
end;

{ TgdcInvFeatureDocumentLineTable }

procedure TgdcInvFeatureDocumentLineTable.GetMetadataScript(
  S: TSQLProcessList; const AMetadata: TgdcMetadataScript);
begin
  inherited;

  if AMetadata = mdsCreate then
  begin
    S.Add(Format('ALTER TABLE %s ADD fromcardkey DINTKEY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD quantity DQUANTITY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD remains DQUANTITY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD tocardkey DINTKEY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD disabled DDISABLED ',
      [FieldByName('relationname').AsString]));

    FNeedSingleUser := True;

    S.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:S FOREIGN KEY (fromcardkey) ' +
      ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString,
      gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_FC', [FieldByName('relationname').AsString]))]));

    S.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:S FOREIGN KEY (tocardkey) ' +
      ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString,
      gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_TC', [FieldByName('relationname').AsString]))]));

    S.Add(Format(
        'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
        'BEFORE INSERT POSITION 1 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE delayed INTEGER; '#13#10 +
        '  DECLARE VARIABLE debit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE credit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fc INTEGER; '#13#10 +
        '  DECLARE VARIABLE tc INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  /* Trigger body */ '#13#10 +
        '  /* Disabled = 1 - позиция не формрует движение, она отклчена программой */ '#13#10 +
        '  IF (NEW.disabled = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '  /* Delayed = 1 - формруется отложенная накладная (движение не формируется по желанию пользователя) */ '#13#10 +
        '    delayed = 0;'#13#10 +
        '    SELECT delayed FROM gd_document WHERE id = NEW.masterkey'#13#10 +
        '    INTO :delayed;'#13#10 +
        '    IF ((:delayed = 0) OR (:delayed IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      /* Проверяем соответствие количества по документу с движением */ '#13#10 +
        '      SELECT SUM(debit), SUM(credit) FROM inv_movement'#13#10 +
        '      WHERE documentkey = NEW.documentkey'#13#10 +
        '      INTO :debit, :credit;'#13#10 +
        '      IF (debit IS NULL) THEN '#13#10 +
        '        debit = 0; '#13#10 +
        '      IF (credit IS NULL) THEN '#13#10 +
        '        credit = 0; '#13#10 +
        '      IF ((:debit <> NEW.quantity) OR (:credit <> NEW.quantity)) THEN'#13#10 +
        '        EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '/*      fc = NULL;'#13#10 +
        '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
        '      INTO :fc;'#13#10 +
        '      IF (:fc > 0) THEN'#13#10 +
        '        NEW.fromcardkey = :fc;'#13#10 +
        '      tc = NULL;'#13#10 +
        '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '        WHERE (documentkey = NEW.documentkey) AND (debit > 0)'#13#10 +
        '      INTO :tc;'#13#10 +
        '      IF (:tc > 0) THEN'#13#10 +
        '        NEW.tocardkey = :tc; */'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END ',
        [FieldByName('relationname').AsString,
         gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)]
        ));

    S.Add(Format(
        'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
        'BEFORE UPDATE POSITION 1 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE delayed INTEGER; '#13#10 +
        '  DECLARE VARIABLE debit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE credit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fc INTEGER; '#13#10 +
        '  DECLARE VARIABLE tc INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  /* Trigger body */ '#13#10 +
        '  /* Disabled = 1 - позиция не формрует движение, она отклчена программой */ '#13#10 +
        '  IF (NEW.disabled = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '  /* Delayed = 1 - формруется отложенная накладная (движение не формируется по желанию пользователя) */ '#13#10 +
        '    delayed = 0;'#13#10 +
        '    SELECT delayed FROM gd_document WHERE id = NEW.masterkey'#13#10 +
        '    INTO :delayed;'#13#10 +
        '    IF ((:delayed = 0) OR (:delayed IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      /* Проверяем соответствие количества по документу с движением */ '#13#10 +
        '      SELECT SUM(debit), SUM(credit) FROM inv_movement'#13#10 +
        '      WHERE documentkey = NEW.documentkey'#13#10 +
        '      INTO :debit, :credit;'#13#10 +
        '      IF (debit IS NULL) THEN '#13#10 +
        '        debit = 0; '#13#10 +
        '      IF (credit IS NULL) THEN '#13#10 +
        '        credit = 0; '#13#10 +
        '      IF ((:debit <> NEW.quantity) OR (:credit <> NEW.quantity)) THEN'#13#10 +
        '        EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '/*      fc = NULL;'#13#10 +
        '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
        '      INTO :fc;'#13#10 +
        '      IF (:fc > 0) THEN'#13#10 +
        '        NEW.fromcardkey = :fc;'#13#10 +
        '      tc = NULL;'#13#10 +
        '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '        WHERE (documentkey = NEW.documentkey) AND (debit > 0)'#13#10 +
        '      INTO :tc;'#13#10 +
        '      IF (:tc > 0) THEN'#13#10 +
        '        NEW.tocardkey = :tc; */'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END ',
        [FieldByName('relationname').AsString,
         gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString)]
        ));

    S.Add(
      Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:S '#13#10 +
      'BEFORE DELETE '#13#10 +
      'POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  DELETE FROM inv_movement WHERE documentkey = OLD.documentkey; '#13#10 +
      'END ', [FieldByName('relationname').AsString,
        gdcBaseManager.AdjustMetaName('USR$BD_' + FieldByName('relationname').AsString)]));
  end;
end;

procedure TgdcInvFeatureDocumentLineTable.MakePredefinedObjects;
begin
  inherited;
  
  NewField('FROMCARDKEY',
    'Из карточки', 'DINTKEY', 'Из карточки', 'Из карточки',
    'L', '10', '1', '0');

  NewField('QUANTITY',
    'Кол-во ТМЦ', 'DQUANTITY', 'Кол-во ТМЦ', 'Кол-во ТМЦ',
    'R', '16', '0', '1');

  NewField('REMAINS',
    'Остаток', 'DQUANTITY', 'Остаток', 'Остаток',
    'L', '16', '1', '1');

  NewField('TOCARDKEY',
    'В карточку', 'DINTKEY', 'В карточку', 'В карточку',
    'L', '10', '1', '0');

  NewField('DISABLED',
    'Отключено', 'DDISABLED', 'Отключено', 'Отключено',
    'L', '16', '1', '1');
end;

{ TgdcInvInventDocumentLineTable }

procedure TgdcInvInventDocumentLineTable.GetMetadataScript(
  S: TSQLProcessList; const AMetadata: TgdcMetadataScript);
begin
  inherited;

  if AMetadata = mdsCreate then
  begin
    S.Add(Format('ALTER TABLE %s ADD fromcardkey DINTKEY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD fromquantity DQUANTITY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD toquantity DQUANTITY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD disabled DDISABLED ',
      [FieldByName('relationname').AsString]));

    S.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:S FOREIGN KEY (fromcardkey) ' +
      ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString,
      gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_FC', [FieldByName('relationname').AsString]))]));

    S.Add(Format(
        'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
        'BEFORE INSERT POSITION 1 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE delayed INTEGER; '#13#10 +
        '  DECLARE VARIABLE debit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE credit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fc INTEGER; '#13#10 +
        '  DECLARE VARIABLE tc INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  /* Trigger body */ '#13#10 +
        '  /* Disabled = 1 - позиция не формрует движение, она отклчена программой */ '#13#10 +
        '  IF (NEW.disabled = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '  /* Delayed = 1 - формруется отложенная накладная (движение не формируется по желанию пользователя) */ '#13#10 +
        '    delayed = 0;'#13#10 +
        '    SELECT delayed FROM gd_document WHERE id = NEW.masterkey'#13#10 +
        '    INTO :delayed;'#13#10 +
        '    IF ((:delayed = 0) OR (:delayed IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      /* Проверяем соответствие количества по документу с движением */ '#13#10 +
        '      SELECT SUM(debit), SUM(credit) FROM inv_movement'#13#10 +
        '      WHERE documentkey = NEW.documentkey'#13#10 +
        '      INTO :debit, :credit;'#13#10 +
        '      IF (debit IS NULL) THEN '#13#10 +
        '        debit = 0; '#13#10 +
        '      IF (credit IS NULL) THEN '#13#10 +
        '        credit = 0; '#13#10 +
        '      IF ( '#13#10 +
        '          ((NEW.fromquantity > NEW.toquantity) AND '#13#10 +
        '            (:credit <> NEW.fromquantity - NEW.toquantity)) OR '#13#10 +
        '          ((NEW.fromquantity < NEW.toquantity) AND '#13#10 +
        '            (:debit <> NEW.toquantity - NEW.fromquantity)) OR '#13#10 +
        '          ((NEW.fromquantity = NEW.toquantity) AND '#13#10 +
        '            (:debit + :credit <> 0)) '#13#10 +
        '         ) '#13#10 +
        '      THEN '#13#10 +
        '        EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '/*      fc = NULL;'#13#10 +
        '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
        '      INTO :fc;'#13#10 +
        '      IF (:fc > 0) THEN'#13#10 +
        '        NEW.fromcardkey = :fc; */'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END ',
        [FieldByName('relationname').AsString,
         gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)]
        ));

    S.Add(Format(
        'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
        'BEFORE UPDATE POSITION 1 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE delayed INTEGER; '#13#10 +
        '  DECLARE VARIABLE debit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE credit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fc INTEGER; '#13#10 +
        '  DECLARE VARIABLE tc INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  /* Trigger body */ '#13#10 +
        '  /* Disabled = 1 - позиция не формрует движение, она отклчена программой */ '#13#10 +
        '  IF (NEW.disabled = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '  /* Delayed = 1 - формруется отложенная накладная (движение не формируется по желанию пользователя) */ '#13#10 +
        '    delayed = 0;'#13#10 +
        '    SELECT delayed FROM gd_document WHERE id = NEW.masterkey'#13#10 +
        '    INTO :delayed;'#13#10 +
        '    IF ((:delayed = 0) OR (:delayed IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      /* Проверяем соответствие количества по документу с движением */ '#13#10 +
        '      SELECT SUM(debit), SUM(credit) FROM inv_movement'#13#10 +
        '      WHERE documentkey = NEW.documentkey'#13#10 +
        '      INTO :debit, :credit;'#13#10 +
        '      IF (debit IS NULL) THEN '#13#10 +
        '        debit = 0; '#13#10 +
        '      IF (credit IS NULL) THEN '#13#10 +
        '        credit = 0; '#13#10 +
        '      IF ( '#13#10 +
        '          ((NEW.fromquantity > NEW.toquantity) AND '#13#10 +
        '            (:credit <> NEW.fromquantity - NEW.toquantity)) OR '#13#10 +
        '          ((NEW.fromquantity < NEW.toquantity) AND '#13#10 +
        '            (:debit <> NEW.toquantity - NEW.fromquantity)) OR '#13#10 +
        '          ((NEW.fromquantity = NEW.toquantity) AND '#13#10 +
        '            (:debit + :credit <> 0)) '#13#10 +
        '         ) '#13#10 +
        '      THEN '#13#10 +
        '        EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '/*      fc = NULL;'#13#10 +
        '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
        '      INTO :fc;'#13#10 +
        '      IF (:fc > 0) THEN'#13#10 +
        '        NEW.fromcardkey = :fc; */'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END ',
        [FieldByName('relationname').AsString,
         gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString)]
        ));

    S.Add(
      Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:S '#13#10 +
      'BEFORE DELETE '#13#10 +
      'POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  DELETE FROM inv_movement WHERE documentkey = OLD.documentkey; '#13#10 +
      'END ', [FieldByName('relationname').AsString,
        gdcBaseManager.AdjustMetaName('USR$BD_' + FieldByName('relationname').AsString)]));
  end;
end;

procedure TgdcInvInventDocumentLineTable.MakePredefinedObjects;
begin
  inherited;
  NewField('FROMCARDKEY',
    'Из карточки', 'DINTKEY', 'Из карточки', 'Из карточки',
    'L', '10', '1', '0');

  NewField('FROMQUANTITY',
    'До инв-ции', 'DQUANTITY', 'До инв-ции', 'До инв-ции',
    'R', '16', '0', '1');

  NewField('TOQUANTITY',
    'После инв-ции', 'DQUANTITY', 'После инв-ции', 'После инв-ции',
    'R', '16', '0', '1');

  NewField('DISABLED',
    'Отключено', 'DDISABLED', 'Отключено', 'Отключено',
    'L', '16', '1', '1');
end;

{ TgdcInvTransformDocumentLineTable }

procedure TgdcInvTransformDocumentLineTable.GetMetadataScript(
  S: TSQLProcessList; const AMetadata: TgdcMetadataScript);
begin
  inherited;

  if AMetadata = mdsCreate then
  begin
    S.Add(Format('ALTER TABLE %s ADD fromcardkey DINTKEY ',
      [FieldByName('relationname').AsString]));

    S.Add(Format('ALTER TABLE %s ADD inquantity DQUANTITY ',
      [FieldByName('relationname').AsString]));

    S.Add(Format('ALTER TABLE %s ADD outquantity DQUANTITY ',
      [FieldByName('relationname').AsString]));

    S.Add(Format('ALTER TABLE %s ADD remains DQUANTITY ',
      [FieldByName('relationname').AsString]));
    S.Add(Format('ALTER TABLE %s ADD disabled DDISABLED ',
      [FieldByName('relationname').AsString]));

    S.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:S FOREIGN KEY (fromcardkey) ' +
      ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString,
      gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_FC', [FieldByName('relationname').AsString]))]));

    S.Add(Format(
        'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
        'BEFORE INSERT POSITION 1 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE delayed INTEGER; '#13#10 +
        '  DECLARE VARIABLE debit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE credit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fc INTEGER; '#13#10 +
        '  DECLARE VARIABLE tc INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  /* Trigger body */ '#13#10 +
        '  /* Disabled = 1 - позиция не формрует движение, она отклчена программой */ '#13#10 +
        '  IF (NEW.disabled = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '    IF (((NEW.inquantity <> 0) OR (NEW.outquantity <> 0)) '#13#10 +
        '      AND (NEW.inquantity = NEW.outquantity))'#13#10 +
        '    THEN'#13#10 +
        '      EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '  /* Delayed = 1 - формруется отложенная накладная (движение не формируется по желанию пользователя) */ '#13#10 +
        '    delayed = 0;'#13#10 +
        '    SELECT delayed FROM gd_document WHERE id = NEW.masterkey'#13#10 +
        '    INTO :delayed;'#13#10 +
        '    IF ((:delayed = 0) OR (:delayed IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      /* Проверяем соответствие количества по документу с движением */ '#13#10 +
        '      SELECT SUM(debit), SUM(credit) FROM inv_movement'#13#10 +
        '      WHERE documentkey = NEW.documentkey'#13#10 +
        '      INTO :debit, :credit;'#13#10 +
        '      IF (debit IS NULL) THEN '#13#10 +
        '        debit = 0; '#13#10 +
        '      IF (credit IS NULL) THEN '#13#10 +
        '        credit = 0; '#13#10 +
        '      IF ('#13#10 +
        '          ((:credit <> NEW.outquantity) AND (NEW.inquantity = 0)) OR'#13#10 +
        '          ((:debit <> NEW.inquantity) AND (NEW.outquantity = 0))'#13#10 +
        '         )'#13#10 +
        '      THEN'#13#10 +
        '        EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '   /*   fc = NULL;'#13#10 +
        '      IF ((NEW.inquantity IS NOT NULL) AND (NEW.inquantity > 0)) THEN '#13#10 +
        '        SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '          WHERE (documentkey = NEW.documentkey) AND (debit > 0)'#13#10 +
        '        INTO :fc;'#13#10 +
        '      ELSE '#13#10 +
        '        SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '          WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
        '        INTO :fc;'#13#10 +
        '      IF (:fc > 0) THEN'#13#10 +
        '        NEW.fromcardkey = :fc; */'#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END ',
        [FieldByName('relationname').AsString,
         gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)]
        ));

    S.Add(Format(
        'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
        'BEFORE UPDATE POSITION 1 '#13#10 +
        'AS '#13#10 +
        '  DECLARE VARIABLE delayed INTEGER; '#13#10 +
        '  DECLARE VARIABLE debit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE credit NUMERIC(15, 4); '#13#10 +
        '  DECLARE VARIABLE fc INTEGER; '#13#10 +
        '  DECLARE VARIABLE tc INTEGER; '#13#10 +
        'BEGIN '#13#10 +
        '  /* Trigger body */ '#13#10 +
        '  /* Disabled = 1 - позиция не формрует движение, она отклчена программой */ '#13#10 +
        '  IF (NEW.disabled = 0) THEN'#13#10 +
        '  BEGIN'#13#10 +
        '  /* Delayed = 1 - формруется отложенная накладная (движение не формируется по желанию пользователя) */ '#13#10 +
        '    IF (((NEW.inquantity <> 0) OR (NEW.outquantity <> 0)) '#13#10 +
        '      AND (NEW.inquantity = NEW.outquantity))'#13#10 +
        '    THEN'#13#10 +
        '      EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '    delayed = 0;'#13#10 +
        '    SELECT delayed FROM gd_document WHERE id = NEW.masterkey'#13#10 +
        '    INTO :delayed;'#13#10 +
        '    IF ((:delayed = 0) OR (:delayed IS NULL)) THEN'#13#10 +
        '    BEGIN'#13#10 +
        '      /* Проверяем соответствие количества по документу с движением */ '#13#10 +
        '      SELECT SUM(debit), SUM(credit) FROM inv_movement'#13#10 +
        '      WHERE documentkey = NEW.documentkey'#13#10 +
        '      INTO :debit, :credit;'#13#10 +
        '      IF (debit IS NULL) THEN '#13#10 +
        '        debit = 0; '#13#10 +
        '      IF (credit IS NULL) THEN '#13#10 +
        '        credit = 0; '#13#10 +
        '      IF ('#13#10 +
        '          ((:credit <> NEW.outquantity) AND (NEW.inquantity = 0)) OR'#13#10 +
        '          ((:debit <> NEW.inquantity) AND (NEW.outquantity = 0))'#13#10 +
        '         )'#13#10 +
        '      THEN'#13#10 +
        '        EXCEPTION INV_E_INVALIDMOVEMENT;'#13#10 +
        '      fc = NULL;'#13#10 +
        '  /*    IF ((NEW.inquantity IS NOT NULL) AND (NEW.inquantity > 0)) THEN '#13#10 +
        '        SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '          WHERE (documentkey = NEW.documentkey) AND (debit > 0)'#13#10 +
        '        INTO :fc;'#13#10 +
        '      ELSE '#13#10 +
        '        SELECT MAX(cardkey) FROM inv_movement'#13#10 +
        '          WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
        '        INTO :fc;'#13#10 +
        '      IF (:fc > 0) THEN'#13#10 +
        '        NEW.fromcardkey = :fc;  */ '#13#10 +
        '    END'#13#10 +
        '  END'#13#10 +
        'END ',
        [FieldByName('relationname').AsString,
         gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString)]
        ));

    S.Add(
      Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:S '#13#10 +
      'BEFORE DELETE '#13#10 +
      'POSITION 0 '#13#10 +
      'AS '#13#10 +
      'BEGIN '#13#10 +
      '  DELETE FROM inv_movement WHERE documentkey = OLD.documentkey; '#13#10 +
      'END ', [FieldByName('relationname').AsString,
        gdcBaseManager.AdjustMetaName('USR$BD_' + FieldByName('relationname').AsString)]));
  end;
end;

procedure TgdcInvTransformDocumentLineTable.MakePredefinedObjects;
begin
  inherited;
  NewField('FROMCARDKEY',
    'Из карточки', 'DINTKEY', 'Из карточки', 'Из карточки',
    'L', '10', '1', '0');

  NewField('INQUANTITY',
    'Приход', 'DQUANTITY', 'Приход', 'Приход',
    'R', '16', '0', '1');

  NewField('OUTQUANTITY',
    'Расход', 'DQUANTITY', 'Расход', 'Расход',
    'R', '16', '0', '1');

  NewField('REMAINS',
    'Остаток', 'DQUANTITY', 'Остаток', 'Остаток',
    'L', '16', '1', '1');

  NewField('DISABLED',
    'Отключено', 'DDISABLED', 'Отключено', 'Отключено',
    'L', '16', '1', '1');
end;

{ TgdcDocumentLineTable }

class function TgdcDocumentLineTable.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result :=
    'z.id IN (SELECT d.relationkey FROM at_relation_fields d WHERE d.fieldname = ''DOCUMENTKEY'') ' +
    'AND z.relationname LIKE ''%LINE'' ';
end;

initialization
  RegisterGdcClass(TgdcCustomTable);
  RegisterGdcClass(TgdcBaseDocumentTable);
  RegisterGdcClass(TgdcInheritedDocumentTable);
  RegisterGdcClass(TgdcDocumentTable);
  RegisterGdcClass(TgdcBaseDocumentLineTable);
  RegisterGdcClass(TgdcDocumentLineTable);
  RegisterGdcClass(TgdcInvSimpleDocumentLineTable);
  RegisterGdcClass(TgdcInvFeatureDocumentLineTable);
  RegisterGdcClass(TgdcInvInventDocumentLineTable);
  RegisterGdcClass(TgdcInvTransformDocumentLineTable);

finalization
  UnregisterGdcClass(TgdcCustomTable);
  UnregisterGdcClass(TgdcBaseDocumentTable);
  UnRegisterGdcClass(TgdcInheritedDocumentTable);
  UnregisterGdcClass(TgdcDocumentTable);
  UnregisterGdcClass(TgdcDocumentLineTable);
  UnregisterGdcClass(TgdcBaseDocumentLineTable);
  UnregisterGdcClass(TgdcInvSimpleDocumentLineTable);
  UnregisterGdcClass(TgdcInvFeatureDocumentLineTable);
  UnregisterGdcClass(TgdcInvInventDocumentLineTable);
  UnregisterGdcClass(TgdcInvTransformDocumentLineTable);
end.
