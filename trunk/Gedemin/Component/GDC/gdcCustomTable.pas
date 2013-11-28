unit gdcCustomTable;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcMetaData;

type
  TgdcCustomTable = class(TgdcBaseTable)
  protected
    procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

  end;

  TgdcBaseDocumentTable = class(TgdcCustomTable)
  private
     function CreateDocumentTable: String;

  protected
     procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

  public
     procedure MakePredefinedRelationFields; override;

     class function GetPrimaryFieldName: String; override;
  published
  end;

  TgdcDocumentTable = class(TgdcBaseDocumentTable)
  end;


  TgdcBaseDocumentLineTable = class(TgdcBaseDocumentTable)
  protected
     procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

  public
     procedure MakePredefinedRelationFields; override;
  end;

  TgdcDocumentLineTable = class(TgdcBaseDocumentLineTable)
  end;


  TgdcInvSimpleDocumentLineTable = class(TgdcBaseDocumentLineTable)
  protected
     procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

  public
     procedure MakePredefinedRelationFields; override;

  end;

  TgdcInvFeatureDocumentLineTable = class(TgdcBaseDocumentLineTable)
  protected
     procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

  public
     procedure MakePredefinedRelationFields; override;

  end;

  TgdcInvInventDocumentLineTable = class(TgdcBaseDocumentLineTable)
  protected
     procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

  public
     procedure MakePredefinedRelationFields; override;

  end;

  TgdcInvTransformDocumentLineTable = class(TgdcBaseDocumentLineTable)
  protected
     procedure CreateRelationSQL(Scripts: TSQLProcessList); override;

  public
     procedure MakePredefinedRelationFields; override;

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

procedure TgdcCustomTable.CreateRelationSQL(Scripts: TSQLProcessList);
begin
  {}
end;


{ TgdcDocumentTable }

function TgdcBaseDocumentTable.CreateDocumentTable: String;
begin
  Result := Format(
    'CREATE TABLE %s '#13#10 +
    '( '#13#10 +
    '  documentkey               dintkey, '#13#10 +
    '  reserved                  dinteger, '#13#10 +

    '  PRIMARY KEY (documentkey) '#13#10 +
    ')',
    [FieldByName('relationname').AsString]);
end;

procedure TgdcBaseDocumentTable.CreateRelationSQL(Scripts: TSQLProcessList);
var
  KeyName: String;
begin
  NeedSingleUser := True;
  Scripts.Add(CreateDocumentTable);
  KeyName := gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_DK',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format(
    'ALTER TABLE %0:s ADD CONSTRAINT %1:s ' +
    '  FOREIGN KEY (documentkey) REFERENCES gd_document(id) ON UPDATE CASCADE ON DELETE CASCADE ',
    [FieldByName('relationname').AsString, KeyName]));

  Scripts.Add(CreateGrantSQL);
end;


class function TgdcBaseDocumentTable.GetPrimaryFieldName: String;
begin
  Result := 'documentkey';
end;

procedure TgdcBaseDocumentTable.MakePredefinedRelationFields;
begin
  if Assigned(gdcTableField) then
  begin
    NewField('DOCUMENTKEY',
      'Ключ документа', 'DINTKEY', 'Ключ документа', 'Ключ документа',
      'L', '10', '1', '0');
    NewField('RESERVED',
      'Зарезервировано', 'DRESERVED', 'Зарезервировано', 'Зарезервировано',
      'L', '10', '1', '0');
  end;

end;

{ TgdcBaseDocumentLineTable }


procedure TgdcBaseDocumentLineTable.CreateRelationSQL(Scripts: TSQLProcessList);
var
  S: String;
begin
  inherited CreateRelationSQL(Scripts);

  NeedSingleUser := True;
  Scripts.Add(Format('ALTER TABLE %s ADD masterkey DMASTERKEY ',
    [FieldByName('relationname').AsString]));

  S := gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_MK',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format(
    'ALTER TABLE %0:s ADD CONSTRAINT %1:s ' +
    '  FOREIGN KEY (masterkey) REFERENCES gd_document(id) ON UPDATE CASCADE ON DELETE CASCADE ',
    [FieldByName('relationname').AsString, S]));
end;

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
    for i:= 0 to AdditionCreateField.Count - 1 do
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
    end;
  end;
end;

{ TgdcInvSimpleDocumentLineTable }

procedure TgdcInvSimpleDocumentLineTable.CreateRelationSQL(
  Scripts: TSQLProcessList);
var
  S: String;
begin
  inherited CreateRelationSQL(Scripts);

  Scripts.Add(Format('ALTER TABLE %s ADD fromcardkey DINTKEY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD quantity DQUANTITY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD remains DQUANTITY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD disabled DDISABLED ',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
      'BEFORE INSERT POSITION 0 '#13#10 +
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
      '      fc = NULL;'#13#10 +
      '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
      '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
      '      INTO :fc;'#13#10 +
      '      IF (:fc > 0) THEN'#13#10 +
      '        NEW.fromcardkey = :fc;'#13#10 +
      '    END'#13#10 +
      '  END'#13#10 +
      'END ',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)]
      ));

  Scripts.Add(Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
      'BEFORE UPDATE POSITION 0 '#13#10 +
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
      '      fc = NULL;'#13#10 +
      '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
      '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
      '      INTO :fc;'#13#10 +
      '      IF (:fc > 0) THEN'#13#10 +
      '        NEW.fromcardkey = :fc;'#13#10 +
      '    END'#13#10 +
      '  END'#13#10 +
      'END ',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString)]
      ));

  Scripts.Add(
    Format(
    'CREATE OR ALTER TRIGGER %1:s FOR %0:S '#13#10 +
    'BEFORE DELETE '#13#10 +
    'POSITION 0 '#13#10 +
    'AS '#13#10 +
    'BEGIN '#13#10 +
    '  DELETE FROM inv_movement WHERE documentkey = OLD.documentkey; '#13#10 +
    'END ', [FieldByName('relationname').AsString,
      gdcBaseManager.AdjustMetaName('USR$BD_' + FieldByName('relationname').AsString)]));

  NeedSingleUser := True;

  S := gdcBaseManager.AdjustMetaName(Format('USR$FC%0:s_FC', [FieldByName('relationname').AsString]));

  Scripts.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:s FOREIGN KEY (fromcardkey) ' +
    ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString, S]));
end;

procedure TgdcInvSimpleDocumentLineTable.MakePredefinedRelationFields;
begin
  inherited;

  if Assigned(gdcTableField) then
  begin
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

end;

{ TgdcInvFeatureDocumentLineTable }

procedure TgdcInvFeatureDocumentLineTable.CreateRelationSQL(
  Scripts: TSQLProcessList);
var
  S: String;
begin
  inherited CreateRelationSQL(Scripts);

  Scripts.Add(Format('ALTER TABLE %s ADD fromcardkey DINTKEY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD quantity DQUANTITY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD remains DQUANTITY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD tocardkey DINTKEY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD disabled DDISABLED ',
    [FieldByName('relationname').AsString]));

  NeedSingleUser := True;

  S := gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_FC',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:S FOREIGN KEY (fromcardkey) ' +
    ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString, S]));

  S := gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_TC',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:S FOREIGN KEY (tocardkey) ' +
    ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString, S]));

  Scripts.Add(Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
      'BEFORE INSERT POSITION 0 '#13#10 +
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
      '      fc = NULL;'#13#10 +
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
      '        NEW.tocardkey = :tc;'#13#10 +
      '    END'#13#10 +
      '  END'#13#10 +
      'END ',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)]
      ));

  Scripts.Add(Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
      'BEFORE UPDATE POSITION 0 '#13#10 +
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
      '      fc = NULL;'#13#10 +
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
      '        NEW.tocardkey = :tc;'#13#10 +
      '    END'#13#10 +
      '  END'#13#10 +
      'END ',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString)]
      ));

  Scripts.Add(
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

procedure TgdcInvFeatureDocumentLineTable.MakePredefinedRelationFields;
begin
  inherited;

  if Assigned(gdcTableField) then
  begin
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
end;

{ TgdcInvInventDocumentLineTable }

procedure TgdcInvInventDocumentLineTable.CreateRelationSQL(
  Scripts: TSQLProcessList);
var
  S: String;
begin
  inherited CreateRelationSQL(Scripts);

  Scripts.Add(Format('ALTER TABLE %s ADD fromcardkey DINTKEY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD fromquantity DQUANTITY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD toquantity DQUANTITY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD disabled DDISABLED ',
    [FieldByName('relationname').AsString]));

  NeedSingleUser := True;

  S := gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_FC',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:S FOREIGN KEY (fromcardkey) ' +
    ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString, S]));

  Scripts.Add(Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
      'BEFORE INSERT POSITION 0 '#13#10 +
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
      '      fc = NULL;'#13#10 +
      '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
      '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
      '      INTO :fc;'#13#10 +
      '      IF (:fc > 0) THEN'#13#10 +
      '        NEW.fromcardkey = :fc;'#13#10 +
      '    END'#13#10 +
      '  END'#13#10 +
      'END ',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)]
      ));

  Scripts.Add(Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
      'BEFORE UPDATE POSITION 0 '#13#10 +
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
      '      fc = NULL;'#13#10 +
      '      SELECT MAX(cardkey) FROM inv_movement'#13#10 +
      '        WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
      '      INTO :fc;'#13#10 +
      '      IF (:fc > 0) THEN'#13#10 +
      '        NEW.fromcardkey = :fc;'#13#10 +
      '    END'#13#10 +
      '  END'#13#10 +
      'END ',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString)]
      ));

  Scripts.Add(
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

procedure TgdcInvInventDocumentLineTable.MakePredefinedRelationFields;
begin
  inherited;

  if Assigned(gdcTableField) then
  begin
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
end;

{ TgdcInvTransformDocumentLineTable }

procedure TgdcInvTransformDocumentLineTable.CreateRelationSQL(
  Scripts: TSQLProcessList);
var
  S: String;
begin
  inherited CreateRelationSQL(Scripts);

  Scripts.Add(Format('ALTER TABLE %s ADD fromcardkey DINTKEY ',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format('ALTER TABLE %s ADD inquantity DQUANTITY ',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format('ALTER TABLE %s ADD outquantity DQUANTITY ',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format('ALTER TABLE %s ADD remains DQUANTITY ',
    [FieldByName('relationname').AsString]));
  Scripts.Add(Format('ALTER TABLE %s ADD disabled DDISABLED ',
    [FieldByName('relationname').AsString]));

  S := gdcBaseManager.AdjustMetaName(Format('USR$FK%0:s_FC',
    [FieldByName('relationname').AsString]));

  Scripts.Add(Format('ALTER TABLE %0:s ADD CONSTRAINT %1:S FOREIGN KEY (fromcardkey) ' +
    ' REFERENCES inv_card (id) ON UPDATE CASCADE ', [FieldByName('relationname').AsString, S]));

  Scripts.Add(Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
      'BEFORE INSERT POSITION 0 '#13#10 +
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
      '      fc = NULL;'#13#10 +
      '      IF ((NEW.inquantity IS NOT NULL) AND (NEW.inquantity > 0)) THEN '#13#10 +
      '        SELECT MAX(cardkey) FROM inv_movement'#13#10 +
      '          WHERE (documentkey = NEW.documentkey) AND (debit > 0)'#13#10 +
      '        INTO :fc;'#13#10 +
      '      ELSE '#13#10 +
      '        SELECT MAX(cardkey) FROM inv_movement'#13#10 +
      '          WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
      '        INTO :fc;'#13#10 +
      '      IF (:fc > 0) THEN'#13#10 +
      '        NEW.fromcardkey = :fc;'#13#10 +
      '    END'#13#10 +
      '  END'#13#10 +
      'END ',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('USR$BI_' + FieldByName('relationname').AsString)]
      ));

  Scripts.Add(Format(
      'CREATE OR ALTER TRIGGER %1:s FOR %0:s ACTIVE '#13#10 +
      'BEFORE UPDATE POSITION 0 '#13#10 +
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
      '      IF ((NEW.inquantity IS NOT NULL) AND (NEW.inquantity > 0)) THEN '#13#10 +
      '        SELECT MAX(cardkey) FROM inv_movement'#13#10 +
      '          WHERE (documentkey = NEW.documentkey) AND (debit > 0)'#13#10 +
      '        INTO :fc;'#13#10 +
      '      ELSE '#13#10 +
      '        SELECT MAX(cardkey) FROM inv_movement'#13#10 +
      '          WHERE (documentkey = NEW.documentkey) AND (credit > 0)'#13#10 +
      '        INTO :fc;'#13#10 +
      '      IF (:fc > 0) THEN'#13#10 +
      '        NEW.fromcardkey = :fc;'#13#10 +
      '    END'#13#10 +
      '  END'#13#10 +
      'END ',
      [FieldByName('relationname').AsString,
       gdcBaseManager.AdjustMetaName('USR$BU_' + FieldByName('relationname').AsString)]
      ));

  Scripts.Add(
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

procedure TgdcInvTransformDocumentLineTable.MakePredefinedRelationFields;
begin
  inherited;

  if Assigned(gdcTableField) then
  begin
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
end;

initialization
  RegisterGdcClass(TgdcCustomTable);
  RegisterGdcClass(TgdcBaseDocumentTable);
  RegisterGdcClass(TgdcDocumentTable);
  RegisterGdcClass(TgdcBaseDocumentLineTable);
  RegisterGdcClass(TgdcDocumentLineTable);
  RegisterGdcClass(TgdcInvSimpleDocumentLineTable);
  RegisterGdcClass(TgdcInvFeatureDocumentLineTable);
  RegisterGdcClass(TgdcInvInventDocumentLineTable);
  RegisterGdcClass(TgdcInvTransformDocumentLineTable);

finalization
  UnRegisterGdcClass(TgdcCustomTable);
  UnRegisterGdcClass(TgdcBaseDocumentTable);
  UnRegisterGdcClass(TgdcDocumentTable);
  UnRegisterGdcClass(TgdcDocumentLineTable);
  UnRegisterGdcClass(TgdcBaseDocumentLineTable);
  UnRegisterGdcClass(TgdcInvSimpleDocumentLineTable);
  UnRegisterGdcClass(TgdcInvFeatureDocumentLineTable);
  UnRegisterGdcClass(TgdcInvInventDocumentLineTable);
  UnRegisterGdcClass(TgdcInvTransformDocumentLineTable);

end.
