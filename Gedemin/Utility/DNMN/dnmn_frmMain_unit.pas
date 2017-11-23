unit dnmn_frmMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IB, Db, IBDatabase, IBSQL, IBServices, ComCtrls, ExtCtrls;

type
  Tdnmn_frmMain = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    tsDenom: TTabSheet;
    lblLog: TLabel;
    lblPassword: TLabel;
    lblUser: TLabel;
    lblPath: TLabel;
    mLog: TMemo;
    btnBeginDNMN: TButton;
    edPassword: TEdit;
    edUser: TEdit;
    edPath: TEdit;
    btnPath: TButton;
    tsFieldsSum: TTabSheet;
    mFieldsSum: TMemo;
    tsFieldsRate: TTabSheet;
    mFieldsRate: TMemo;
    cbRoundEntrySum: TCheckBox;
    Label1: TLabel;
    TabSheet1: TTabSheet;
    Memo1: TMemo;
    Button1: TButton;
    Label2: TLabel;
    cbMeta: TCheckBox;
    cbMakeSaldo: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBeginDNMNClick(Sender: TObject);
    procedure btnPathClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    FServerName, FDBName, FUserName, FPassword: String;
    FPort: Integer;

    FTriggers: TStringList;
    FChecks: TStringList;
    FFieldsSum: TStringList;
    FFieldsRate: TStringList;

    FDatabase: TIBDatabase;
    FTr: TIBTransaction;
    FQ: TIBSQL;

    procedure Log(const AMessage: String; const ASaveFile: Boolean = False);
    procedure SaveLog;
    function ParseString(S: String; out ARelation: String; out AField: String): Boolean;

    procedure CheckDomain(const ADomain: String; const AScale: Short);
    procedure CheckRDB(const ARelation, AField, ADomain: String; const AScale: Short);
    procedure UpdateDomain(ARelation, AField, ADomain: String);
    procedure UpdateRDB(ARelation, AField, ADomain: String);

    function ReadFromMemo(S: TStrings; out SL: TStringList): Boolean;
    procedure DisableTriggers;
    procedure EnableTriggers;
    procedure FieldsToDCurrency;
    procedure FieldsToDCurrrate;
    procedure DivideFields(SL: TStringList);
    procedure SetToZeroDBID;
    procedure SetDNMNinStorage;
    procedure MakeSaldo;
    procedure DNMN;
    procedure CorrectEntry;
  end;

var
  dnmn_frmMain: Tdnmn_frmMain;

implementation

uses
  gd_common_functions, ShellAPI, dnmn_reg;

{$R *.DFM}

procedure Tdnmn_frmMain.FormCreate(Sender: TObject);
begin
  FDatabase := TIBDatabase.Create(nil);
  FTriggers := TStringList.Create;
  FChecks := TStringList.Create;
  FFieldsSum := TStringList.Create;
  FFieldsSum.Sorted := True;
  FFieldsSum.Duplicates := dupIgnore;
  FFieldsRate := TStringList.Create;
  FFieldsRate.Sorted := True;
  FFieldsRate.Duplicates := dupIgnore;
end;

procedure Tdnmn_frmMain.FormDestroy(Sender: TObject);
begin
  FFieldsRate.Free;
  FFieldsSum.Free;
  FTriggers.Free;
  FChecks.Free;
  FDatabase.Free;
end;

function Tdnmn_frmMain.ParseString(S: String; out ARelation: String; out AField: String): Boolean;
var
  P: Integer;
begin
  P := Pos('.', S);
  if P > 0 then
  begin
    ARelation := UpperCase(Trim(Copy(S, 1, P - 1)));
    AField := UpperCase(Trim(Copy(S, P + 1, 1024)));
    Result := (ARelation > '') and (AField > '');
  end else
    Result := False;
end;

procedure Tdnmn_frmMain.CheckDomain(const ADomain: String; const AScale: Short);
var
  Str: String;
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT '+
      '  rdb$field_sub_type AS fst, ' +
      '  rdb$field_precision AS fp, ' +
      '  rdb$field_scale AS fs ' +
      'FROM rdb$fields ' +
      'WHERE rdb$field_name = :dname';
    q.Params.ByName('dname').AsString := ADomain;
    q.ExecQuery;
    if not q.EOF then
    begin
      if (q.FieldByName('fst').AsShort <> 2)
        or (q.FieldByName('fp').AsShort <> 15)
        or (q.FieldByName('fs').AsShort <> AScale) then
      begin
        q.Close;
        q.SQL.Text :=
          'UPDATE rdb$fields ' +
          'SET ' +
          '  rdb$field_type = 16, ' +
          '  rdb$field_sub_type = 2, ' +
          '  rdb$field_length = 8, ' +
          '  rdb$field_precision = 15, ' +
          '  rdb$field_scale = ' + IntToStr(AScale) + ' ' +
          'WHERE rdb$field_name = :dname';
        q.Params.ByName('dname').AsString := ADomain;
        q.ExecQuery;

        Str := 'Скорректирован домен: ' + ADomain;
      end else
        Str := 'Проверен домен: ' + ADomain;
    end else
    begin
      q.Close;

      if ADomain = 'DCURRENCY' then
        q.SQL.Text := 'CREATE DOMAIN DCURRENCY AS DECIMAL(15,4) '
      else if ADomain = 'DCURRRATE' then
        q.SQL.Text := 'CREATE DOMAIN DCURRRATE AS DECIMAL(15,10) NOT NULL '
      else if ADomain = 'DCURRRATE_NULL' then
        q.SQL.Text := 'CREATE DOMAIN DCURRRATE_NULL AS DECIMAL(15,10) '
      else
        raise Exception.Create('Invalid domain name');

      q.ExecQuery;
      Str := 'Создан домен: ' + q.SQL.Text;
    end;

    Tr.Commit;
    Log(Str);
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.CheckRDB(const ARelation, AField, ADomain: String; const AScale: Short);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    q.SQL.Text := 'SELECT ' +
      '  f.rdb$field_type AS ft, ' +
      '  f.rdb$field_precision AS fp, ' +
      '  iif(f.rdb$field_scale < 0, -f.rdb$field_scale, f.rdb$field_scale) AS fs ' +
      'FROM ' +
      '  rdb$fields f JOIN rdb$relation_fields r ' +
      '  ON f.rdb$field_name = r.rdb$field_source ' +
      'WHERE r.rdb$relation_name = :rname ' +
      '  AND r.rdb$field_name = :fname';

    q.Params.ByName('rname').AsString := ARelation;
    q.Params.ByName('fname').AsString := AField;
    q.ExecQuery;

    if ((q.FieldByName('ft').AsShort = 7) or (q.FieldByName('ft').AsShort = 8))
      and (q.FieldByName('fp').AsShort = 0)  then
      UpdateDomain(ARelation, AField, ADomain)
    else begin
      if (q.FieldByName('ft').AsShort = 27) then
        UpdateRDB(ARelation, AField, ADomain)
      else begin
        if q.FieldByName('fp').AsShort <= 15 then
        begin
          if (15 - q.FieldByName('fp').AsShort) >= (AScale - q.FieldByName('fs').AsShort) then
            UpdateDomain(ARelation, AField, ADomain)
          else
            UpdateRDB(ARelation, AField, ADomain);
        end else
        begin
          if q.FieldByName('fs').AsShort < AScale then
            UpdateRDB(ARelation, AField, ADomain);
        end;
      end;
    end;

    Tr.Commit;
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.UpdateDomain(ARelation, AField, ADomain: String);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    Log('Начата правка поля ' + ARelation + '.' + AField);

    q.SQL.Text := 'ALTER TABLE ' + ARelation + ' ALTER ' + AField + ' TYPE ' + ADomain;
    q.ExecQuery;

    Tr.Commit;
    Log('Закончена правка поля');
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.UpdateRDB(ARelation, AField, ADomain: String);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    Log('Начата правка поля ' + ARelation + '.' + AField);

    q.SQL.Text := 'UPDATE rdb$relation_fields '+
    'SET ' +
    '  rdb$field_source = :dname ' +
    'WHERE rdb$relation_name = :rname ' +
    '  AND rdb$field_name = :fname';
    q.Params.ByName('dname').AsString := ADomain;
    q.Params.ByName('rname').AsString := ARelation;
    q.Params.ByName('fname').AsString := AField;
    q.ExecQuery;

    Tr.Commit;
    Log('Закончена правка поля');
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

function Tdnmn_frmMain.ReadFromMemo(S: TStrings; out SL: TStringList): Boolean;
var
  FRelation, FField: String;
  Tr: TIBTransaction;
  q: TIBSQL;
  I: Integer;
begin
  Assert(FDatabase.Connected);

  Log('Начато считывание полей');

  SL.Assign(S);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    q.SQL.Text :=
      'SELECT rdb$relation_name, rdb$field_name, rdb$field_source ' +
      'FROM rdb$relation_fields ' +
      'WHERE rdb$relation_name = :rname ' +
      '  AND rdb$field_name = :fname';

    for I := SL.Count - 1 downto 0 do
    begin
      ParseString(SL[I], FRelation, FField);

      q.ParamByName('rname').AsString := FRelation;
      q.ParamByName('fname').AsString := FField;
      q.ExecQuery;

      if q.EOF then
        SL.Delete(I);

      q.Close;
    end;

    Tr.Commit;
    Log('Закончено считывание полей');
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;

  Result := SL.Count > 0;
end;

procedure Tdnmn_frmMain.DisableTriggers;
var
  Tr: TIBTransaction;
  q: TIBSQL;
  I: Integer;
begin
  FTriggers.Clear;
  FChecks.Clear;

  Assert(FDatabase.Connected);

  Log('Начато отключение триггеров');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    q.SQL.Text := 'SELECT rdb$trigger_name FROM rdb$triggers ' +
    'WHERE COALESCE(rdb$system_flag, 0) = 0 AND rdb$trigger_inactive = 0 ';
    q.ExecQuery;
    while not q.EOF do
    begin
      FTriggers.Add(q.FieldByName('rdb$trigger_name').AsTrimString);
      q.Next;
    end;

    FTriggers.SaveToFile(ExtractFilePath(Application.ExeName) + 'triggers_DNMN.txt');

    for I := 0 to FTriggers.Count - 1 do
    begin
      q.Close;
      q.SQL.Text := 'ALTER TRIGGER ' + FTriggers[I] + ' INACTIVE';
      q.ExecQuery;
      Log('Отключение триггера ' + FTriggers[I]);
    end;

    q.Close;
    q.SQL.Text :=
      'select trim(cc.rdb$constraint_name) as name, trg.rdb$trigger_source as source ' + #13#10 +
      ' from rdb$relation_constraints rc' + #13#10 +
      '   join rdb$check_constraints cc on rc.rdb$constraint_name = cc.rdb$constraint_name' + #13#10 +
      '   join rdb$triggers trg on cc.rdb$trigger_name = trg.rdb$trigger_name' + #13#10 +
      ' where rc.rdb$relation_name = ''BN_BANKSTATEMENTLINE''' + #13#10 +
      ' and   rc.rdb$constraint_type = ''CHECK''' + #13#10 +
      ' and   trg.rdb$trigger_type = 1';

    q.ExecQuery;
    while not q.EOF do
    begin
      FChecks.Add(q.FieldByName('name').AsString + ';' + q.FieldByName('source').AsString);
      q.Next;
    end;

    FChecks.SaveToFile(ExtractFilePath(Application.ExeName) + 'checks_DNMN.txt');

    for i := 0 to FChecks.Count - 1 do
    begin
      q.Close;
      q.SQL.Text := 'alter table bn_bankstatementline drop constraint ' + copy(FChecks[i], 1, Pos(';', FChecks[i]) - 1);
      q.ExecQuery;
      Log('Отключение проверки ' + copy(FChecks[i], 1, Pos(';', FChecks[i]) - 1));
    end;

    Tr.Commit;
    Log('Закончено отключение триггеров');
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.EnableTriggers;
var
  Tr: TIBTransaction;
  q: TIBSQL;
  I: Integer;
begin
  Assert(FDatabase.Connected);

  Log('Начато включение триггеров');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    for I := 0 to FTriggers.Count - 1 do
    begin
      q.Close;
      q.SQL.Text := 'ALTER TRIGGER ' + FTriggers[I] + ' ACTIVE';
      q.ExecQuery;
      Log('Включение триггера ' + FTriggers[I]);
    end;

    for i := 0 to FChecks.Count - 1 do
    begin
      q.Close;
      q.SQL.Text := 'alter table bn_bankstatementline add ' + copy(FChecks[i], Pos(';', FChecks[i]) + 1, Length(FChecks[i]));
      q.ExecQuery;
      Log('Восстановление ограничения ' + copy(FChecks[i], 1, Pos(';', FChecks[i]) - 1));
    end;

    Tr.Commit;
    Log('Закончено включение триггеров');
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.FieldsToDCurrency;
var
  FRelation, FField: String;
  I: Integer;
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Log('Начато преобразование денежных полей в тип DCURRENCY');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    for I := 0 to FFieldsSum.Count - 1 do
    begin
      if not ParseString(FFieldsSum[I], FRelation, FField) then
        continue;

      q.Close;
      q.SQL.Text := 'SELECT ' +
        '  f.rdb$field_type AS ft, ' +
        '  f.rdb$field_precision AS fp, ' +
        '  iif(f.rdb$field_scale < 0, -f.rdb$field_scale, f.rdb$field_scale) AS fs ' +
        'FROM ' +
        '  rdb$fields f JOIN rdb$relation_fields r ' +
        '  ON f.rdb$field_name = r.rdb$field_source ' +
        'WHERE r.rdb$relation_name = :rname ' +
        '  AND r.rdb$field_name = :fname';

      q.Params.ByName('rname').AsString := FRelation;
      q.Params.ByName('fname').AsString := FField;
      q.ExecQuery;

      if not q.EOF then
        CheckRDB(FRelation, FField, 'DCURRENCY', 4);
    end;

    Tr.Commit;
    Log('Закончено преобразование денежных полей в тип DCURRENCY');
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.FieldsToDCurrrate;
var
  FRelation, FField: String;
  I: Integer;
  IsCreate: Boolean;
  Tr: TIBTransaction;
  q, qNull: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Log('Начато преобразование денежных полей в тип DCURRRATE');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  qNull := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;
    qNull.Transaction := Tr;

    IsCreate := False;

    for I := 0 to FFieldsRate.Count - 1 do
    begin

      ParseString(FFieldsRate[I], FRelation, FField);

      q.Close;
      q.SQL.Text := 'SELECT ' +
        '  f.rdb$field_type AS ft, ' +
        '  f.rdb$field_precision AS fp, ' +
        '  iif(f.rdb$field_scale < 0, -f.rdb$field_scale, f.rdb$field_scale) AS fs ' +
        'FROM ' +
        '  rdb$fields f JOIN rdb$relation_fields r ' +
        '  ON f.rdb$field_name = r.rdb$field_source ' +
        'WHERE r.rdb$relation_name = :rname ' +
        '  AND r.rdb$field_name = :fname';

      q.Params.ByName('rname').AsString := FRelation;
      q.Params.ByName('fname').AsString := FField;
      q.ExecQuery;

      if not q.EOF then
      begin
        qNull.Close;
        qNull.SQL.Text := 'SELECT ' +
          '  f.rdb$null_flag AS fnf, ' +
          '  r.rdb$null_flag AS rnf ' +
          'FROM ' +
          '  rdb$fields f JOIN rdb$relation_fields r ' +
          '  ON f.rdb$field_name = r.rdb$field_source ' +
          'WHERE r.rdb$relation_name = :rname ' +
          '  AND r.rdb$field_name = :fname';

        qNull.Params.ByName('rname').AsString := FRelation;
        qNull.Params.ByName('fname').AsString := FField;
        qNull.ExecQuery;

        if (qNull.FieldByName('fnf').AsShort = 1) or (qNull.FieldByName('rnf').AsShort = 1) then
          CheckRDB(FRelation, FField, 'DCURRRATE', 10)
        else
        begin
          qNull.Close;
          qNull.SQL.Text := 'SELECT FIRST 1 ' +
            '  ' + FField + ' ' +
            'FROM ' +
            '  ' + FRelation + ' ' +
            'WHERE ' + FField + ' IS NULL';
          qNull.ExecQuery;

          if qNull.EOF then
            CheckRDB(FRelation, FField, 'DCURRRATE', 10)
          else
          begin
            if not IsCreate then
            begin
              CheckDomain('DCURRRATE_NULL', -10);
              IsCreate := True;

              q.Close;
              q.SQL.Text := 'SELECT ' +
                '  f.rdb$field_type AS ft, ' +
                '  f.rdb$field_precision AS fp, ' +
                '  iif(f.rdb$field_scale < 0, -f.rdb$field_scale, f.rdb$field_scale) AS fs ' +
                'FROM ' +
                '  rdb$fields f JOIN rdb$relation_fields r ' +
                '  ON f.rdb$field_name = r.rdb$field_source ' +
                'WHERE r.rdb$relation_name = :rname ' +
                '  AND r.rdb$field_name = :fname';

              q.Params.ByName('rname').AsString := FRelation;
              q.Params.ByName('fname').AsString := FField;
              q.ExecQuery;
            end;
            CheckRDB(FRelation, FField, 'DCURRRATE_NULL', 10);
          end;
        end;
      end;
    end;

    Tr.Commit;
    Log('Закончено преобразование денежных полей в тип DCURRRATE');
  finally
    qNull.Free;
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.DivideFields(SL: TStringList);
var
  FQText, FRelationOld, FRelationNew, FFieldOld, FFieldNew: String;
  I: Integer;
  ibsql: TIBSQL;
  GP_ID: Integer;

begin
  ParseString(SL[0], FRelationOld, FFieldOld);

  FQText := '';

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := FTr;
    ibsql.SQL.Text := 'select id from gd_ruid where xid = 147170231 and dbid = 1234867257';
    ibsql.ExecQuery;

    GP_ID := ibsql.FieldByName('id').AsInteger;
  finally
    ibsql.Free;
  end;

  for I := 1 to SL.Count - 1 do
  begin
    ParseString(SL[I], FRelationNew, FFieldNew);

    if FQText <> '' then
      FQText := FQText + ', ';

    if cbRoundEntrySum.Checked and (Trim(FRelationOld) = 'AC_ENTRY') then
      FQText := FQText + FFieldOld + ' = CAST(' + FFieldOld + ' / 10000 as NUMERIC(15, 2))'
    else
      FQText := FQText + FFieldOld + ' = ' + FFieldOld + ' / 10000';

    if FRelationOld <> FRelationNew then
    begin
      FQText := 'UPDATE ' + FRelationOld + ' SET ' + FQText;
      if FRelationOld = 'GD_CURRRATE' then
        FQText := FQText + ' WHERE tocurr = 200010'
      else
        if FRelationOld = 'GD_DOCUMENT' then
          FQText := FQText + ' WHERE documentdate > ''01.01.1900'' and documentdate <= ''31.12.2099'' '
        else
          if FRelationOld = 'AC_ENTRY' then
            FQText := FQText + ' WHERE accountkey <> ' + IntToStr(GP_ID);

      FQ.SQL.Text := FQText;
      FQ.ExecQuery;
      FQText := '';
    end;

    Log('Деноминировано поле ' + FRelationOld + '.' + FFieldOld);

    FRelationOld := FRelationNew;
    FFieldOld := FFieldNew;
  end;

  if FQText <> '' then
    FQText := FQText + ', ';
  FQText := FQText + FFieldOld + ' = ' + FFieldOld + ' / 10000';
  FQText := 'UPDATE ' + FRelationOld + ' SET ' + FQText;
  if FRelationOld = 'GD_CURRRATE' then
    FQText := FQText + ' WHERE tocurr = 200010'
  else
    if FRelationOld = 'GD_DOCUMENT' then
      FQText := FQText + ' WHERE documentdate > ''01.01.1900'' and documentdate <= ''31.12.2099'' '
    else
      if FRelationOld = 'AC_ENTRY' then
        FQText := FQText + ' WHERE accountkey <> ' + IntToStr(GP_ID);

  FQ.SQL.Text := FQText;
  FQ.ExecQuery;

  Log('Деноминировано поле ' + FRelationOld + '.' + FFieldOld);
end;

procedure Tdnmn_frmMain.SetToZeroDBID;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Log('Начато обнуление идентификатора базы данных');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    q.SQL.Text := 'SET GENERATOR GD_G_DBID TO 0 ';
    q.ExecQuery;

    Tr.Commit;
    Log('Закончено обнуление идентификатора базы данных');
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.DNMN;
var
  FFieldsAll: TStringList;
begin
  Log('Начата процедура деноминации БД');
  try
    try
      FDatabase.DatabaseName := Trim(edPath.Text);
      FDatabase.Params.Clear;
      FDatabase.Params.Add('user_name=' + FUserName);
      FDatabase.Params.Add('password=' + FPassword);
      FDatabase.Params.Add('lc_ctype=win1251');
      FDatabase.LoginPrompt := False;
      FDatabase.Open;

      if not CheckReg(FDatabase) then
      begin
        Log('Неверный код разблокировки программы!');
        exit;
      end;

      if MessageBox(Handle,
        'Начать процесс деноминирования базы данных?',
        'Внимание',
        MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
      begin
        Log('Прервано пользователем');
        exit;
      end;

      DisableTriggers;
      try
        CheckDomain('DCURRENCY', -4);
        CheckDomain('DCURRRATE', -10);

        if ReadFromMemo(mFieldsSum.Lines, FFieldsSum) then
          FieldsToDCurrency;

        if ReadFromMemo(mFieldsRate.Lines, FFieldsRate) then
          FieldsToDCurrrate;

        if (FFieldsSum.Count = 0) and (FFieldsRate.Count = 0) then
        begin
          Log('Процедура деноминации БД не проведена: нет полей, подлежащих деноминации');
          exit;
        end;

        if cbMakeSaldo.Checked then
          MakeSaldo;

        if not cbMeta.Checked then
        begin
          Log('Начата деноминация денежных полей');



          FFieldsAll := TStringList.Create;
          FFieldsAll.Sorted := True;
          FFieldsAll.Duplicates := dupIgnore;

          FTr := TIBTransaction.Create(nil);
          FQ := TIBSQL.Create(nil);
          try
            FTr.DefaultDatabase := FDatabase;
            FTr.StartTransaction;
            FQ.Transaction := FTr;

            FFieldsAll.AddStrings(FFieldsSum);
            FFieldsAll.AddStrings(FFieldsRate);

            if FFieldsAll.Count > 0 then
              DivideFields(FFieldsAll);

            FTr.Commit;
            Log('Закончена деноминация денежных полей');
          finally
            FQ.Free;
            if FTr.InTransaction then
              FTr.Rollback;
            FTr.Free;
            FFieldsAll.Free;
          end;
        end;

        if not cbMeta.Checked then
          CorrectEntry;

        EnableTriggers;

        if not cbMeta.Checked then
        begin
          SetToZeroDBID;
          SetDNMNinStorage;
        end;

        FDatabase.Close;
        Log('Успешно закончена процедура деноминации БД');
      finally
        if FDatabase.Connected then
        begin
          if FTriggers.Count > 0 then
            EnableTriggers;
          FDatabase.Close;
        end;
      end;
    except
      on E: Exception do
        Log('Ошибка: ' + E.Message);
    end;
  finally
    SaveLog;
    if FDatabase.Connected then
      FDatabase.Close;
  end;
end;

procedure Tdnmn_frmMain.btnBeginDNMNClick(Sender: TObject);
begin
  ParseDatabaseName(edPath.Text, FServerName, FPort, FDBName);
  FUserName := Trim(edUser.Text);
  FPassword := Trim(edPassword.Text);

  if edPath.Text = '' then
    Log('Ошибка! Выполнение процедуры деноминации БД невозможно: не указан путь к базе данных', True)
  else if edUser.Text = '' then
    Log('Ошибка! Выполнение процедуры деноминации БД невозможно: не указано имя пользователя')
  else if edPassword.Text = '' then
    Log('Ошибка! Выполнение процедуры деноминации БД невозможно: не указан пароль')
  else if (mFieldsSum.Text = '') and (mFieldsRate.Text = '') then
    Log('Ошибка! Выполнение процедуры деноминации БД невозможно: отсутствуют списки денежных полей')
  else
    DNMN;
end;

procedure Tdnmn_frmMain.btnPathClick(Sender: TObject);
var
  OD: TOpenDialog;
begin
  OD := TOpenDialog.Create(Self);
  try
    OD.Filter := 'Firebird database (*.fdb)|*.fdb';
    OD.InitialDir := ExtractFilePath(Application.ExeName);
    OD.Options := [ofFileMustExist];
    if OD.Execute then
      edPath.Text := OD.Files.Text;
  finally
    OD.Free;
  end;
end;

procedure Tdnmn_frmMain.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 2;
  PageControl1.ActivePageIndex := 3;
  PageControl1.ActivePageIndex := 0;
end;

procedure Tdnmn_frmMain.Log(const AMessage: String; const ASaveFile: Boolean = False);
begin
  mLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' ' + AMessage);
  if ASaveFile then
    SaveLog;
end;

procedure Tdnmn_frmMain.SaveLog;
var
  FN: String;
begin
  FN := ExtractFilePath(Application.ExeName) + 'log.txt';
  Log('Лог записан в файл ' + FN);
  mLog.Lines.SaveToFile(FN);
end;

procedure Tdnmn_frmMain.Button1Click(Sender: TObject);
begin
  ShellExecute(Handle,
    'open',
    'http://gsbelarus.com',
    nil,
    nil,
    SW_SHOW);
end;

procedure Tdnmn_frmMain.SetDNMNinStorage;
var
  Tr: TIBTransaction;
  q, qs: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Log('Начата проверка глобального хранилища');

  Tr := TIBTransaction.Create(nil);
  qs := TIBSQL.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    qs.Transaction := Tr;
    q.Transaction := Tr;

    qs.SQL.Text :=
      'SELECT id FROM gd_storage_data ' +
      'WHERE UPPER(name) = ''OPTIONS'' AND parent = 990000 ';
    qs.ExecQuery;

    if not qs.EOF then
    begin
      q.SQL.Text :=
        'UPDATE OR INSERT INTO gd_storage_data (parent, name, data_type, int_data, editorkey) ' +
        'VALUES (:p, ''dnmn'', ''L'', 1, (SELECT FIRST 1 contactkey FROM gd_user WHERE ibname = CURRENT_USER)) ' +
        'MATCHING(parent, name)';
      q.ParamByName('p').AsInteger := qs.FieldByName('id').AsInteger;
      q.ExecQuery;
      Log('Установлен признак "Была деноминация"');
    end else
      Log('Отсутствует раздел OPTIONS в глобальном хранилище');

    Tr.Commit;
  finally
    q.Free;
    qs.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

procedure Tdnmn_frmMain.MakeSaldo;
var
  q: TIBSQL;
  Tr: TIBTransaction;
  Text: String;
begin
  tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  q.Transaction := Tr;

  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    Text := '';
    q.SQL.Text := 'select trim(rdb$field_name) || '' '' || trim(rdb$field_source) as field_source from rdb$relation_fields ' +
       ' where rdb$relation_name = ''AC_ENTRY'' and rdb$field_name LIKE ''USR$%'' ';
    q.ExecQuery;
    while not q.EOF do
    begin
      Text := Text + ',';
      Text := Text + q.FieldByName('field_source').AsString;
      q.Next;
    end;
    Text := ' CREATE TABLE tmp_entry (accountkey INTEGER, companykey INTEGER, currkey INTEGER, saldobegin NUMERIC(15, 4), debitncu NUMERIC(15, 4), creditncu NUMERIC(15, 4)' + Text + ')';
    q.Close;

    q.SQL.Text := Text;

    try
      q.ExecQuery;
      q.Close;

      q.SQL.Text := 'GRANT ALL ON tmp_entry TO administrator';
      q.ExecQuery;

      Tr.Commit;
      Log('Создана таблица для хранения сальдо на 30.06 в ценах до деноминации');
    except
      Tr.Rollback;
    end;

    Log('Начат расчет сальдо');
    tr.StartTransaction;
    q.Close;
    q.SQL.Text :=
      'execute block' + #13#10 +
      ' as' + #13#10 +
      '   declare txt varchar(3096);' + #13#10 +
      '   declare sel_txt varchar(2048);' + #13#10 +
      '   declare accountkey integer;' + #13#10 +
      '   declare fieldname varchar(31);' + #13#10 +
      '   declare fieldname_acc varchar(31);' + #13#10 +
      '   declare tmp_txt varchar(2048);' + #13#10 +
      '   declare value_an integer;' + #13#10 +
      ' begin' + #13#10 +
      '   txt = '''';' + #13#10 +
      '   for' + #13#10 +
      '     select id from ac_account a where EXISTS (select e.id from ac_entry e WHERE e.accountkey = a.id) and a.ACCOUNTTYPE in (''A'', ''S'') ' + #13#10 +
      '     and coalesce(a.disabled, 0) = 0 and a.id <> 300003 ' + #13#10 +
      '     into :accountkey' + #13#10 +
      '   do' + #13#10 +
      '   begin' + #13#10 +
      '      sel_txt = '''';' + #13#10 +
      '      for' + #13#10 +
      '        select rdb$field_name from' + #13#10 +
      '          rdb$relation_fields where rdb$relation_name = ''AC_ACCOUNT'' and rdb$field_name like ''USR$%'' ' + #13#10 +
      '        into :fieldname_acc' + #13#10 +
      '      do' + #13#10 +
      '      begin' + #13#10 +
      '        fieldname = NULL; ' +
      '        select rdb$field_name from rdb$relation_fields ' +
      '        where rdb$relation_name = ''AC_ENTRY'' and rdb$field_name = :fieldname_acc ' +
      '        into :fieldname; ' +
      '        if (not fieldname is null) then ' +
      '        begin ' +
      '        tmp_txt = ''select '' || fieldname || '' from ac_account where id = '' || CAST(accountkey as varchar(10));' + #13#10 +
      '        execute statement tmp_txt into :value_an;' + #13#10 +
      '        if (value_an = 1) then' + #13#10 +
      '          sel_txt = sel_txt || '','' || fieldname;' + #13#10 +
      '        end ' +
      '      end' + #13#10 +
      '      txt = ''insert into tmp_entry (currkey, accountkey, companykey '' || sel_txt || '', saldobegin, debitncu, creditncu) select currkey, accountkey, companykey '' || sel_txt ||' + #13#10 +
      '        '', SUM(iif(entrydate < ''''01.01.2016'''', debitncu - creditncu, 0)), SUM(iif(entrydate >= ''''01.01.2016'''', debitncu, 0)), ' + #13#10 +
      '            SUM(iif(entrydate >= ''''01.01.2016'''', creditncu, 0))  from ac_entry where entrydate <= ''''30.06.2016'''' and accountkey = ''' + #13#10 +
      '         || CAST(accountkey as VARCHAR(10)) ||' + #13#10 +
      '        '' group by currkey, accountkey, companykey '' || sel_txt || '' HAVING SUM(iif(entrydate < ''''01.01.2016'''', debitncu - creditncu, 0)) <> 0 or ' + #13#10 +
      '         SUM(iif(entrydate >= ''''01.01.2016'''', debitncu, 0)) <> 0 or SUM(iif(entrydate >= ''''01.01.2016'''', creditncu, 0)) <> 0 '' ;' + #13#10 +
      '      execute statement txt;' + #13#10 +
      '   end' + #13#10 +
      ' end';
    q.ExecQuery;
    Tr.Commit;
    Log('Закончен расчет сальдо');

  finally
    q.Free;
    if Tr.InTransaction then Tr.Rollback;
    tr.Free;
  end;
end;

procedure Tdnmn_frmMain.CorrectEntry;
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(FDatabase.Connected);

  Log('Начата корректировка сложных проводок');

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    Tr.StartTransaction;

    q.Transaction := Tr;

    q.SQL.Text :=
      'EXECUTE BLOCK ' + #13#10 +
      'AS ' + #13#10 +
      '   DECLARE ID INTEGER; ' + #13#10 +
      '   DECLARE S1_T NUMERIC(15,4); ' + #13#10 +
      '   DECLARE S2_T NUMERIC(15,4); ' + #13#10 +
      '   DECLARE SimpleEntryID INTEGER; ' + #13#10 +
      '   DECLARE SimpleDebit NUMERIC(15,4); ' + #13#10 +
      '   DECLARE SimpleCredit NUMERIC(15,4); ' + #13#10 +
      '   DECLARE ComplexDebit NUMERIC(15,4); ' + #13#10 +
      '   DECLARE ComplexCredit NUMERIC(15,4); ' + #13#10 +
      '   DECLARE RecDebit NUMERIC(15,4); ' + #13#10 +
      '   DECLARE RecCredit NUMERIC(15,4); ' + #13#10 +
      '   BEGIN ' + #13#10 +
      '     FOR ' + #13#10 +
      '       SELECT ' + #13#10 +
      '         e.RECORDKEY AS ID, ' + #13#10 +
      '         SUM(e.DEBITNCU), ' + #13#10 +
      '         SUM(e.CREDITNCU) ' + #13#10 +
      '       FROM AC_ENTRY e ' + #13#10 +
      '       WHERE EXISTS (SELECT * FROM AC_ENTRY e1 WHERE e1.RECORDKEY = e.RECORDKEY AND e.ID <> e1.ID) ' + #13#10 +
      '       GROUP BY 1 ' + #13#10 +
      '       HAVING SUM(e.DEBITNCU) <> SUM(e.CREDITNCU) ' + #13#10 +
      '       INTO :ID, :S1_T, :S2_T ' + #13#10 +
      '     DO ' + #13#10 +
      '     BEGIN ' + #13#10 +
      '       SELECT ' + #13#10 +
      '         e.ID, ' + #13#10 +
      '         e.DEBITNCU, ' + #13#10 +
      '         e.CREDITNCU ' + #13#10 +
      '       FROM AC_ENTRY e ' + #13#10 +
      '       WHERE e.RECORDKEY = :ID ' + #13#10 +
      '       AND e.ISSIMPLE = 1 ' + #13#10 +
      '       INTO :SimpleEntryID, :SimpleDebit,  :SimpleCredit; ' + #13#10 +
      '       SELECT ' + #13#10 +
      '         SUM(e.DEBITNCU), ' + #13#10 +
      '         SUM(e.CREDITNCU) ' + #13#10 +
      '       FROM AC_ENTRY e ' + #13#10 +
      '       WHERE e.RECORDKEY = :ID ' + #13#10 +
      '       AND e.ISSIMPLE <> 1 ' + #13#10 +
      '       INTO :ComplexDebit,  :ComplexCredit; ' + #13#10 +
      '       IF ((SimpleDebit <> 0.0000) OR (ComplexCredit <> 0.0000)) THEN ' + #13#10 +
      '       BEGIN ' + #13#10 +
      '         UPDATE AC_ENTRY e ' + #13#10 +
      '         SET e.DEBITNCU = :ComplexCredit ' + #13#10 +
      '         WHERE e.ID = :SimpleEntryID; ' + #13#10 +
      '         RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', 1); ' + #13#10 +
      '         UPDATE AC_RECORD r ' + #13#10 +
      '         SET r.DEBITNCU = :ComplexCredit, ' + #13#10 +
      '             r.CREDITNCU = :ComplexCredit ' + #13#10 +
      '         WHERE r.ID = :ID; ' + #13#10 +
      '         RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', null); ' + #13#10 +
      '       END ' + #13#10 +
      '       ELSE ' + #13#10 +
      '         IF ((SimpleCredit <> 0.0000) OR (ComplexDebit <> 0.0000)) THEN ' + #13#10 +
      '         BEGIN ' + #13#10 +
      '           UPDATE AC_ENTRY e ' + #13#10 +
      '           SET e.CREDITNCU = :ComplexDebit ' + #13#10 +
      '           WHERE e.ID = :SimpleEntryID; ' + #13#10 +
      '           RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', 1); ' + #13#10 +
      '           UPDATE AC_RECORD r ' + #13#10 +
      '           SET r.DEBITNCU = :ComplexDebit, ' + #13#10 +
      '               r.CREDITNCU = :ComplexDebit ' + #13#10 +
      '           WHERE r.ID = :ID; ' + #13#10 +
      '           RDB$SET_CONTEXT(''USER_TRANSACTION'', ''AC_RECORD_UNLOCK'', null); ' + #13#10 +
      '         END ' + #13#10 +
      '     END ' + #13#10 +
      'END ';

    q.ExecQuery;

    Tr.Commit;
    Log('Закончена корректировка сложных проводок');
  finally
    q.Free;
    if Tr.InTransaction then
      Tr.Rollback;
    Tr.Free;
  end;
end;

end.
