unit gdcBlockRule;

interface

uses
  SysUtils, Classes, gd_ClassList, gdcBase, gdcBaseInterface, DB, gd_security,
  IBSQL, IBDatabase, Windows, gdcUser, gdcClasses;

const
  //если появятся новые таблицы с документами, то их нужно добавить в cdocTable
  //или добавить свойство?????
  cDocTable: Array [0..2, 0..4] of String =
    (('GD_DOCUMENT','AC_ENTRY','AC_RECORD','INV_MOVEMENT','INV_CARD'),
     ('DOCUMENTDATE','ENTRYDATE','RECORDDATE','MOVEMENTDATE','FIRSTDATE'),
     ('DOCUMENTTYPEKEY','DOCUMENTKEY','DOCUMENTKEY','DOCUMENTKEY','DOCUMENTKEY'));

  cDocTableCount = 4;

type
  TChangePriorityType = (cpUp, cpDown);

  TgdcBlockRule = class(TgdcBase)
  private
    FExclTblLst: TStrings;
    FDocTypeItems: array of Integer;
    FOldTableNane: String;
    function GetNextOrdr: Integer; virtual;
    procedure SetExclTblLst(const Value: TStrings);
    function IsTriggerNotExists(const Tr: TIBTransaction;
      const ibsql: TIBSQL; const TriggerName: String): Boolean;
    function IsActiveBlockRuleExists(const Tr: TIBTransaction;
      const ibsql: TIBSQL; const aDocTable: Byte): Boolean;
    procedure DeleteTrigger(const Tr: TIBTransaction; const ibsql: TIBSQL;
      const TriggerName: String);

  protected
    function GetDocTypeItem(Index: Integer): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetListTable(const ASubType: TgdcSubType) : String;
      override;
    class function GetViewFormClassName(const ASubType: TgdcSubType) : String;
      override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType) : String;
      override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    procedure AddDocTypeItem(Index: Integer; const Item: Integer);
    procedure ClearDocTypeItems;
    function GetDocTypeItemCount: Integer;

    property NextOrdr: Integer read GetNextOrdr;
    property DocTypeItems[Index: Integer]: Integer read GetDocTypeItem;
    property DocTypeItemCount: Integer read GetDocTypeItemCount;
    procedure SaveBlockDocType; virtual;

    function ExclDocTypesStr: String;
    function GetExcludedDocumentTypes(const Obj: TgdcBase = nil): String;

    procedure ReadDocTypes(const BlockRuleID: Integer);

    procedure ChangeBlockRulePrior(const ChangeType: TChangePriorityType);

    procedure CreateBlockTriggers;

    procedure CheckBlockTrigger;

    procedure GetTriggersList(const ibsql: TIBSQL;const TriggerType: Integer);

  published
    property ExclTblLst: TStrings read FExclTblLst write SetExclTblLst;
    property OldTableNane: String read FOldTableNane write FOldTableNane;
  end;

procedure Register;

implementation

uses
  gdc_frmBlockRule_unit, gdc_dlgBlockRule_unit;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcBlockRule]);
end;

constructor TgdcBlockRule.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExclTblLst := TStringList.Create;
end;

destructor TgdcBlockRule.Destroy;
begin
  FExclTblLst.Free;
  inherited;
end;

class function TgdcBlockRule.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_BLOCK_RULE';
end;

class function TgdcBlockRule.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmBlockRule';
end;

class function TgdcBlockRule.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_dlgBlockRule';
end;

class function TgdcBlockRule.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

function TgdcBlockRule.GetNextOrdr: Integer;
var
  Q: TIBSQL;
  Tr: TIBTransaction;
begin
result := 1;
if  Active and not EOF then
  begin
    Q := TIBSQL.Create(Self);
    Tr := TIBTransaction.Create(nil);
    try
      Q.DataBase := IBLogin.DataBase;
      Tr.DefaultDatabase := IBLogin.Database;
      Q.Transaction := Tr;
      Tr.StartTransaction;
      Q.SQL.Text := 'SELECT MAX(ordr)+1 FROM gd_block_rule';
      Q.ExecQuery;
      if not Q.Eof then
        result := Q.Fields[0].AsInteger;
{      else
        result := 1;}
    finally
      Q.Free;
      Tr.Free;
    end;
  end;
end;

procedure TgdcBlockRule.SetExclTblLst(const Value: TStrings);
begin
  FExclTblLst.Assign(Value);
end;

function TgdcBlockRule.GetDocTypeItem(Index: Integer): Integer;
begin
  Result := FDocTypeItems[Index];
end;

function TgdcBlockRule.GetDocTypeItemCount: Integer;
begin
  Result := Length(FDocTypeItems);
end;

procedure TgdcBlockRule.AddDocTypeItem(Index: Integer; const Item: Integer);
begin
  if Index > High(FDocTypeItems) then
    SetLength(FDocTypeItems, Index + 1);
  FDocTypeItems[Index] := Item;
end;

procedure TgdcBlockRule.ClearDocTypeItems;
begin
//  if  High(FDocTypeItems) > 0 then
  SetLength(FDocTypeItems, 0);
end;


procedure TgdcBlockRule.SaveBlockDocType;
var
  I: Integer;
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    q.Database := IBLogin.Database;
    Tr.DefaultDatabase := IBLogin.Database;
    q.Transaction := Tr;
    q.Close;
    try
      Tr.StartTransaction;
      q.SQL.Text :=
            'SELECT 1 FROM gd_block_rule WHERE id = ' +
             FieldByName('id').AsString;
      q.ExecQuery;
//      if not q.Eof and (GetDocTypeItemCount > 0) then
      if not q.Eof then
        begin
          q.Close;
          q.SQL.Text :=
                'DELETE FROM gd_block_dt WHERE blockrulekey = ' +
                 FieldByName('id').AsString;
          q.ExecQuery;
          Tr.Commit;
          q.Close;
          Tr.StartTransaction;
          q.SQL.Text :=
                'INSERT INTO gd_block_dt (blockrulekey, dtkey) VALUES (:blockrulekey, :dtkey)';
          q.ParamByName('blockrulekey').AsInteger := FieldByName('id').AsInteger;
          for I := Low(FDocTypeItems) to High(FDocTypeItems) do
            begin
              q.ParamByName('dtkey').AsInteger := DocTypeItems[I];
              q.ExecQuery;
            end;
          q.Close;
          Tr.Commit;
        end;
    except
      Tr.Rollback;
      MessageBox(0,'Ошибка сохранения типов блокируемых документов в GD_BLOCK_DT.',
        'Ошибка!', MB_ICONERROR or MB_OK or MB_TASKMODAL);
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;


function TgdcBlockRule.GetExcludedDocumentTypes(const Obj: TgdcBase = nil): String;
var
  q: TIBSQL;
  I: Integer;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.Close;
    q.SQL.Text := 'SELECT name FROM gd_documenttype WHERE id = :ID';
    result := '';
    for I := 0 to GetDocTypeItemCount - 1 do
      begin
        if Obj <> nil then
          Obj.SelectedID.Add(DocTypeItems[I]);
        q.ParamByName('ID').AsInteger := DocTypeItems[I];
        q.ExecQuery;
        if q.Fields[0].AsString > '' then
          Result := Result + q.Fields[0].AsString + ', ';
        q.Close;
      end;
    if Result > '' then
      SetLength(Result, Length(Result) - 2);
  finally
    q.Free;
  end;
end;

function TgdcBlockRule.ExclDocTypesStr: String;
var
  Obj: TgdcDocumentType;
  A: OleVariant;
  I: Integer;
begin
    Obj := TgdcDocumentType.Create(nil);
    try
      Obj.Open;
      GetExcludedDocumentTypes(Obj);
      if Obj.ChooseItems(A) then
        begin
          ClearDocTypeItems;
          for I := VarArrayLowBound(A, 1) to VarArrayHighBound(A, 1) do
          begin
            AddDocTypeItem(I, A[I]);
          end;
        end;
    finally
      Obj.Free;
    end;
  result := GetExcludedDocumentTypes;
end;

procedure TgdcBlockRule.ReadDocTypes(const BlockRuleID: Integer);
var
  q: TIBSQL;
  I: Integer;
begin
 q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.Close;
    q.SQL.Text := 'SELECT dtkey FROM gd_block_dt WHERE blockrulekey = :blockrulekey';
    q.ParamByName('blockrulekey').AsInteger := BlockRuleID;
    q.ExecQuery;
    if not q.Eof then
      begin
        ClearDocTypeItems;
        I := 0;
        while not q.Eof do
          begin
            AddDocTypeItem(I, q.Fields[0].AsInteger);
            q.Next;
            inc(I);
          end;
      end;
  finally  
    q.Free;
  end;
end;

procedure TgdcBlockRule.ChangeBlockRulePrior(const ChangeType: TChangePriorityType);
var
  q: TIBSQL;
  Tr: TIBTransaction;
  CurrID, DestID: Integer;
  CurrOrdr, DestOrdr: Integer;
begin
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    q.Database := IBLogin.Database;
    Tr.DefaultDatabase := IBLogin.Database;
    q.Transaction := Tr;
    q.Close;
    try
      Tr.StartTransaction;
      case ChangeType of
        cpDown:
          q.SQL.Text := 'SELECT FIRST 1 id, ordr FROM gd_block_rule WHERE ordr > :ordr ' +
                        'ORDER BY ordr';
        cpUp:
          q.SQL.Text := 'SELECT FIRST 1 id, ordr FROM gd_block_rule WHERE ordr < :ordr ' +
                        'ORDER BY ordr DESCENDING';
      end;
      q.ParamByName('ordr').AsInteger := FieldByName('ordr').AsInteger;
      q.ExecQuery;
      if not q.Eof then
        begin
          CurrID := FieldByName('id').AsInteger;
          DestID := q.Fields[0].AsInteger;
          CurrOrdr := FieldByName('ordr').AsInteger;
          DestOrdr := q.Fields[1].AsInteger;
          q.Close;
          q.SQL.Text := 'UPDATE gd_block_rule SET ordr = :ordr WHERE id = :id';
          q.ParamByName('ordr').AsInteger := -1 * DestOrdr;  //для обхода ограничения UNQ
          q.ParamByName('id').AsInteger := CurrID;
          q.ExecQuery;
          q.ParamByName('ordr').AsInteger := CurrOrdr;
          q.ParamByName('id').AsInteger := DestID;
          q.ExecQuery;
          q.ParamByName('ordr').AsInteger := DestOrdr;
          q.ParamByName('id').AsInteger := CurrID;
          q.ExecQuery;
        end;
      q.Close;
      Tr.Commit;
      CloseOpen;
    except
      Tr.Rollback;
      MessageBox(0,'Ошибка изменения приоритета правила блокировки !',
        'Ошибка!', MB_ICONERROR or MB_OK or MB_TASKMODAL);
    end;
  finally
    q.Free;
    Tr.Free;
  end;
end;


function TgdcBlockRule.IsTriggerNotExists(const Tr: TIBTransaction;
  const ibsql: TIBSQL; const TriggerName: String): Boolean;
begin
  if not Tr.InTransaction then Tr.StartTransaction;
  ibsql.Close;
  ibsql.SQL.Text := Format('SELECT 1 FROM rdb$triggers WHERE ' +
    ' rdb$trigger_name = ''%s''', [TriggerName]);
  ibsql.ExecQuery;
  result := ibsql.RecordCount = 0;
  ibsql.Close;
end;

function TgdcBlockRule.IsActiveBlockRuleExists(const Tr:TIBTransaction;
    const ibsql: TIBSQL; const aDocTable: Byte):Boolean;
var
  I: Integer;
begin
  if not Tr.InTransaction then Tr.StartTransaction;
  ibsql.Close;
  ibsql.SQL.Text := 'SELECT COUNT(0) AS CNT FROM gd_block_rule WHERE disabled = 0 AND ' +
                    'fordocs = ' + IntToStr(aDocTable);
  ibsql.ExecQuery;
  I := ibsql.FieldByName('CNT').AsInteger;
//if State in [dsEdit, dsInsert] then
//  begin
      if (FieldByName('disabled').AsInteger = 0) and
         (FieldByName('fordocs').AsInteger = aDocTable) then
        I := I + 1
      else I := I - 1;
//  end;
  result := I > 0;
  ibsql.Close;
end;

procedure TgdcBlockRule.DeleteTrigger(const Tr: TIBTransaction;
  const ibsql: TIBSQL; const TriggerName: String);
begin
  try
    if not Tr.InTransaction then Tr.StartTransaction;
    ibsql.Close;
    ibsql.SQL.Text := 'DROP TRIGGER ' + TriggerName;
    ibsql.ExecQuery;
    Tr.Commit;
    ibsql.Close;
  except
    Tr.Rollback;
  end;    
end;

procedure TgdcBlockRule.CreateBlockTriggers;
 const
   cBIHead = 'CREATE TRIGGER BI_%0:s_BLOCK FOR %0:s'#13#10 +
             'ACTIVE BEFORE INSERT POSITION 28017 '#13#10;
   cBUHead = 'CREATE TRIGGER BU_%0:s_BLOCK FOR %0:s'#13#10 +
             'ACTIVE BEFORE UPDATE POSITION 28017 '#13#10;
   cBDHead = 'CREATE TRIGGER BD_%0:s_BLOCK FOR %0:s'#13#10 +
             'ACTIVE BEFORE DELETE POSITION 28017 '#13#10;
   cBegin = 'AS '#13#10 +
            'DECLARE VARIABLE F SMALLINT;'#13#10 +
            'BEGIN '#13#10;
   cEnd =   '    RETURNING_VALUES :F;'#13#10 +
            '  IF (:F = 1) THEN EXCEPTION gd_e_block;'#13#10 +
            'END ';
 var
  ibsql: TIBSQL;
  Tr: TIBTransaction;
  I: Integer;
  S: String;

  function IfClause(const MetaSymb:String ): String;
   var s1,s2: String;
    begin
      result := '';
      if FieldByName('selectcondition').AsString > '' then
        s1 := '(' +MetaSymb + '.' +
          FieldByName('selectcondition').AsString + ')';
      if not FieldByName('rootkey').IsNull then
        begin
          if (FieldByName('inclsublevels').AsInteger = 1) then
            s2 := Format('(EXISTS ('#13#10 +
                         '  SELECT'#13#10 +
                         '    c.id'#13#10 +
                         '  FROM'#13#10 +
                         '    %0:s c JOIN %0:s c2'#13#10 +
                         '       ON c.lb >= c2.lb AND c.rb <= c2.rb'#13#10 +
                         '  WHERE'#13#10 +
                         '    c2.ID = %1:s AND'#13#10 +
                         '    c.id = %2:s.id))'#13#10,
                  [FieldByName('tablename').AsString, FieldByName('rootkey').AsString,
                   MetaSymb])
          else
            s2 := Format(' IF %0:s.parent = %1:s',
            [MetaSymb, FieldByName('rootkey').AsString]);
        end;

      if (s1 > '') then
        if (s2 > '') then
          result := 'IF (' + s1 + ' AND ' + s2 + ')'
        else
          result := 'IF ' + s1
      else
        if (s2 > '') then
          result := 'IF ' + s2;
      if result > '' then
        result := result + ' THEN '#13#10;
    end;

begin
  ibsql := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := IBLogin.Database;
    ibsql.Transaction := Tr;
    ibsql.ParamCheck := False;
    ///////////////////////////////////////////////////
    // Для документов
    ///////////////////////////////////////////////////
    if FieldByName('fordocs').AsInteger = 1 then
      begin
        if IsActiveBlockRuleExists(Tr, ibsql, 1) then
          begin
            for I := 0 to cDocTableCount do
              begin
                if IsTriggerNotExists(Tr, ibsql, Format('BI_%s_BLOCK',[cDocTable[0,I]])) then
                  begin
                    try
                      if not Tr.InTransaction then
                         Tr.StartTransaction;
                      ibsql.Close;
                      ibsql.SQL.Text := Format(
                      cBIHead + cBegin + IfClause('NEW') +
                      '  EXECUTE PROCEDURE GD_P_BLOCK(1, NEW.%1:s, NEW.%2:s, null)'#13#10 +
                      cEnd,
                      [cDocTable[0,I], cDocTable[1,I], cDocTable[2,I]]);
                      ibsql.ExecQuery;
                      Tr.Commit;
                    except
                      Tr.Rollback;
                      raise Exception.Create(Format('Ошибка создания триггера BI_%s_BLOCK !'#13#10 +
                                'Возможно неверно заполнено поле "Условие отбора записей".',
                                [cDocTable[0,I]]));
                    end;
                  end;
                if IsTriggerNotExists(Tr, ibsql, Format('BU_%s_BLOCK',[cDocTable[0,I]])) then
                  begin
                    try
                      if not Tr.InTransaction then
                         Tr.StartTransaction;
                      ibsql.Close;
                      ibsql.SQL.Text := Format(
                      cBUHead + cBegin + IfClause('NEW') +
                      '  EXECUTE PROCEDURE GD_P_BLOCK(1, NEW.%1:s, NEW.%2:s, null)'#13#10 +
                      cEnd,
                      [cDocTable[0,I], cDocTable[1,I], cDocTable[2,I]]);
                      ibsql.ExecQuery;
                      Tr.Commit;
                    except
                      Tr.Rollback;
                      raise Exception.Create(Format('Ошибка создания триггера BU_%s_BLOCK !'#13#10 +
                                'Возможно неверно заполнено поле "Условие отбора записей".',
                                [cDocTable[0,I]]));
                    end;
                  end;
                if IsTriggerNotExists(Tr, ibsql, Format('BD_%s_BLOCK',[cDocTable[0,I]])) then
                  begin
                    try
                      if not Tr.InTransaction then
                         Tr.StartTransaction;
                      ibsql.Close;
                      ibsql.SQL.Text := Format(
                      cBDHead + cBegin + IfClause('OLD') +
                      '  EXECUTE PROCEDURE GD_P_BLOCK(1, OLD.%1:s, OLD.%2:s, null)'#13#10 +
                      cEnd,
                      [cDocTable[0,I], cDocTable[1,I], cDocTable[2,I]]);
                      ibsql.ExecQuery;
                      Tr.Commit;
                    except
                      Tr.Rollback;
                      raise Exception.Create(Format('Ошибка создания триггера BD_%s_BLOCK !'#13#10 +
                                'Возможно неверно заполнено поле "Условие отбора записей".',
                                [cDocTable[0,I]]));
                    end;
                  end;
              end;
          end
        else
          begin
            for I := 0 to cDocTableCount do
              begin
                //Нет активных правил блокировки для документов, удаляем триггера
                //для данной таблицы с документами
                DeleteTrigger(Tr, ibsql, Format('BI_%s_BLOCK',[cDocTable[0,I]]));
                DeleteTrigger(Tr, ibsql, Format('BU_%s_BLOCK',[cDocTable[0,I]]));
                DeleteTrigger(Tr, ibsql, Format('BD_%s_BLOCK',[cDocTable[0,I]]));
              end;
          end;
      end
    else
    ///////////////////////////////////////////////////
    // Для таблицы
    ///////////////////////////////////////////////////
      begin
        if FieldByName('disabled').AsInteger = 0 then
          begin
{            if FieldByName('blockdate').AsDateTime <> null then
              S := 'NEW.%1:s'}
            if FieldByName('datefieldname').AsString <> '' then
              S := 'NEW.%1:s'
            else
              S := 'null';
            if IsTriggerNotExists(Tr, ibsql,
              Format('BI_%s_BLOCK',[FieldByName('tablename').AsString])) then
              begin
                try
                  if not Tr.InTransaction then
                     Tr.StartTransaction;
                  ibsql.Close;
                  ibsql.SQL.Text := Format(
                  cBIHead + cBegin + IfClause('NEW') +
                  '  EXECUTE PROCEDURE GD_P_BLOCK(0, '+ S + ', null, ''%0:s'')'#13#10 +
                  cEnd,
                  [FieldByName('tablename').AsString,
                   FieldByName('datefieldname').AsString]);
                  ibsql.ExecQuery;
                  Tr.Commit;
                except
                  Tr.Rollback;
                  raise Exception.Create(Format('Ошибка создания триггера BI_%s_BLOCK !'#13#10 +
                            'Возможно неверно заполнено поле "Условие отбора записей".',
                            [FieldByName('tablename').AsString]));
                end;
              end;
            if IsTriggerNotExists(Tr, ibsql,
              Format('BU_%s_BLOCK',[FieldByName('tablename').AsString])) then
              begin
                try
                  if not Tr.InTransaction then
                     Tr.StartTransaction;
                  ibsql.Close;
                  ibsql.SQL.Text := Format(
                  cBUHead + cBegin + IfClause('NEW') +
                  '  EXECUTE PROCEDURE GD_P_BLOCK(0, '+ S + ', null, ''%0:s'')'#13#10 +
                  cEnd,
                  [FieldByName('tablename').AsString,
                   FieldByName('datefieldname').AsString]);
                  ibsql.ExecQuery;
                  Tr.Commit;
                except
                  Tr.Rollback;
                  raise Exception.Create(Format('Ошибка создания триггера BU_%s_BLOCK !'#13#10 +
                            'Возможно неверно заполнено поле "Условие отбора записей".',
                            [FieldByName('tablename').AsString]));
                end;
              end;
{            if FieldByName('blockdate').AsDateTime <> null then
              S := 'OLD.%1:s'}
            if FieldByName('datefieldname').AsString <> '' then
              S := 'OLD.%1:s'
            else
              S := 'null';
            if IsTriggerNotExists(Tr, ibsql,
              Format('BD_%s_BLOCK',[FieldByName('tablename').AsString])) then
              begin
                try
                  if not Tr.InTransaction then
                     Tr.StartTransaction;
                  ibsql.Close;
                  ibsql.SQL.Text := Format(
                  cBDHead + cBegin + IfClause('OLD') +
                  '  EXECUTE PROCEDURE GD_P_BLOCK(0, '+ S + ', null, ''%0:s'')'#13#10 +
                  cEnd,
                  [FieldByName('tablename').AsString,
                   FieldByName('datefieldname').AsString]);
                  ibsql.ExecQuery;
                  Tr.Commit;
                except
                  Tr.Rollback;
                   raise Exception.Create(Format('Ошибка создания триггера BD_%s_BLOCK !'#13#10 +
                             'Возможно неверно заполнено поле "Условие отбора записей".',
                             [FieldByName('tablename').AsString]));
                end;
              end;
          end
        else
          begin
            //Правило неактивно, удаляем триггера
            DeleteTrigger(Tr, ibsql, Format('BI_%s_BLOCK', [FieldByName('tablename').AsString]));
            DeleteTrigger(Tr, ibsql, Format('BU_%s_BLOCK', [FieldByName('tablename').AsString]));
            DeleteTrigger(Tr, ibsql, Format('BD_%s_BLOCK', [FieldByName('tablename').AsString]));
          end;
        if AnsiCompareStr(OldTableNane, FieldByName('tablename').AsString) <> 0 then
          begin
            DeleteTrigger(Tr, ibsql, Format('BI_%s_BLOCK', [OldTableNane]));
            DeleteTrigger(Tr, ibsql, Format('BU_%s_BLOCK', [OldTableNane]));
            DeleteTrigger(Tr, ibsql, Format('BD_%s_BLOCK', [OldTableNane]));
          end;
      end;
  finally
    ibsql.Free;
    Tr.Free;
  end;
end;

procedure TgdcBlockRule.CheckBlockTrigger;
 var
  ibsql: TIBSQL;
  Tr: TIBTransaction;
  I: Integer;
begin
 ibsql := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := IBLogin.Database;
    ibsql.Transaction := Tr;
    case FieldByName('fordocs').AsInteger of
      1:begin
          if not IsActiveBlockRuleExists(Tr, ibsql,1) then
            for I := 0 to cDocTableCount do
              begin
                DeleteTrigger(Tr, ibsql, Format('BI_%s_BLOCK',[cDocTable[0,I]]));
                DeleteTrigger(Tr, ibsql, Format('BU_%s_BLOCK',[cDocTable[0,I]]));
                DeleteTrigger(Tr, ibsql, Format('BD_%s_BLOCK',[cDocTable[0,I]]));
              end;
        end;
      0:begin
          DeleteTrigger(Tr, ibsql, Format('BI_%s_BLOCK',[FieldByName('tablename').AsString]));
          DeleteTrigger(Tr, ibsql, Format('BU_%s_BLOCK',[FieldByName('tablename').AsString]));
          DeleteTrigger(Tr, ibsql, Format('BD_%s_BLOCK',[FieldByName('tablename').AsString]));
        end;
    end;
  finally
    ibsql.Free;
    Tr.Free;
  end;
end;

procedure TgdcBlockRule.GetTriggersList(const ibsql: TIBSQL;const TriggerType: Integer);
var     
  I: Integer;
  S: String;
begin
  S := '';
  if (FieldByName('fordocs').AsInteger = 0) and
     (FieldByName('tablename').AsString > '') then
    S := '''' + FieldByName('tablename').AsString  + ''''
  else
    begin
      for I := 0 to cDocTableCount do
        S := S + '''' + cDocTable[0,I] + ''', ';
      if S > '' then
        SetLength(S, Length(S) - 2);
    end;
  ibsql.Close;
  ibsql.SQL.Text :=Format(
    'select rdb$trigger_name, rdb$trigger_inactive from rdb$triggers'#13#10 +
    ' where rdb$system_flag = 0 and rdb$trigger_type = :TriggerType and'#13#10 +
    '  rdb$trigger_sequence = 28017 and'#13#10 +
    '  rdb$relation_name in (%s) '#13#10 +
    '   order by rdb$relation_name',[S]);
  ibsql.ParamByName('TriggerType').AsInteger := TriggerType;
  ibsql.ExecQuery;
end;

initialization
  RegisterGdcClass(TgdcBlockRule);

finalization
  UnRegisterGdcClass(TgdcBlockRule);

end.
