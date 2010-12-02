
unit gsImportExport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDataBase, IBCustomDataSet, DB;

type
  TgsImportExport = class(TComponent)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FDirectoryStatement: String;
    FDirectoryPayment: String;
    FDivideEnter: Boolean;
    FExtensionStatemet: String;
    FExtensionPayment: String;
    FTemplatePayment: String;
    FTemplateStatement: String;
    FIsLoaded: Boolean;
    FToday: Boolean;
    FPaymentData: String;
    FPaymentDate: TDate;
    FTempPayment: TStringList;
    FCountPayment: Integer;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
    procedure LoadParams;
    procedure SaveParams;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function ImportStatement(const FileName: String; const Date: TDate): Boolean; overload;
    procedure ImportStatement; overload;
    procedure ExportPayment(const ID: Integer);
    procedure Options;
    procedure ClearPayment;
    procedure AddPayment(Q: TIBDataSet);
    procedure SavePayment;

    property DirectoryStatement: String read FDirectoryStatement write
      FDirectoryStatement;
    property DirectoryPayment: String read FDirectoryPayment write
      FDirectoryPayment;
    property TemplateStatement: String read FTemplateStatement write FTemplateStatement;
    property TemplatePayment: String read FTemplatePayment write FTemplatePayment;
    property DivideEnter: Boolean read FDivideEnter write FDivideEnter;
    property Today: Boolean read FToday write FToday;
    property ExtensionStatemet: String read FExtensionStatemet write FExtensionStatemet;
    property ExtensionPayment: String read FExtensionPayment write FExtensionPayment;
    property PaymentDate: TDate read FPaymentDate write FPaymentDate;

  published
    property DataBase: TIBDataBase read FDataBase write SetDataBase;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;

  EgsImportExport = class(Exception);

procedure Register;

implementation

uses
  IBSQL, jclFileUtils, dp_dlgImportExportOptions_unit, Storages,
  Ternaries, dp_dlgImportPeriod_unit, gd_security, gd_setdatabase,
  gd_security_OperationConst, gd_resourcestring, dmDatabase_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  DivVal = ';';
  DivLen = '/';

constructor TgsImportExport.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FIsLoaded := False;
  FToday := True;
  FPaymentDate := SysUtils.Date;
  FTempPayment := TStringList.Create;
  FCountPayment := 0;
end;

destructor TgsImportExport.Destroy;
begin
  FTempPayment.Free;

  inherited Destroy;
end;

procedure TgsImportExport.ClearPayment;
begin
  FPaymentData := '';
  FTempPayment.Clear;
  FCountPayment := 0;
end;

procedure TgsImportExport.AddPayment(Q: TIBDataSet);

  function MakeTemplate: Boolean;
  var
    S, TmpS, NewElement: String;
    L: Integer;

  begin
    Result := True;
    FTempPayment.LoadFromFile(FTemplatePayment);
    S := FTempPayment.Text;
    FTempPayment.Clear;
    while Pos(DivVal, S) <> 0 do
    begin
      TmpS := Copy(S, 0, Pos(DivVal, S) - 1);
      S := Copy(S, Pos(DivVal, S) + 1, Length(S));
      if Pos(DivLen, TmpS) = 0 then
      begin
        Result := False;
        exit;
      end;
      try
        L := StrToInt(Copy(TmpS, Pos(DivLen, Tmps) + 1, Length(Tmps)));
        NewElement := Copy(TmpS, 0, Pos(DivLen, Tmps) - 1);
        FTempPayment.AddObject(NewElement, Pointer(L));
      except
        Result := False;
        exit;
      end;
    end;
  end;

  procedure AddPayment;
  var
    I, L, K: Integer;
    F: TField;
    S: String;

  begin
    for I := 0 to FTempPayment.Count - 1 do
    begin
      F := Q.FindField(FTempPayment[I]);
      if F <> nil then
        S := F.AsString
      else
        S := '';

      if FTempPayment[I] = 'ISO' then
        S := 'BYB';

      if FTempPayment[I] = 'OWNBANKTEXT' then
        S := S + ' ' + Q.FieldByName('OWNBANKCITY').AsString;

      if FTempPayment[I] = 'CORRBANKTEXT' then
        S := S + ' ' + Q.FieldByName('CORRBANKCITY').AsString;

      if FTempPayment[I] = 'DESTINATION' then
      begin
        S := StringReplace(S, #13, ' ', [rfReplaceAll]);
        S := StringReplace(S, #10, ' ', [rfReplaceAll]);
      end;

      L := Integer(FTempPayment.Objects[I]);

      if Length(S) > L then
        S := Copy(S, 0, L)
      else
        for K := Length(S) to L - 1 do
          if (FTempPayment[I] = 'OWNACCOUNTCODE') or (FTempPayment[I] = 'CORRACCOUNTCODE')
             or (FTempPayment[I] = 'OPER') then
            S := ' ' + S
          else
            S := S + ' ';

      FPaymentData := FPaymentData + S;
    end;

    if FDivideEnter then
      FPaymentData := FPaymentData + #13#10;
  end;

begin
  Assert(Q <> nil);
  LoadParams;

  if not FileExists(FTemplatePayment) then
  begin
    MessageBox(Application.Handle,
      'Невозможно открыть файл-шаблон. Произведите настройку экспорта платежей.',
      'Внимание',
      MB_OK or MB_ICONHAND);
    exit;
  end;

  if Q.RecordCount > 0 then
  begin
    if FTempPayment.Count = 0 then
      MakeTemplate;

    AddPayment;
    Inc(FCountPayment);
  end;
end;

procedure TgsImportExport.SavePayment;
var
  L: TStringList;
  FileName, S: String;
  Year, Month, Day: Word;
  I: Integer;
  P: PChar;

begin
  if FPaymentData > '' then
  begin
    L := TStringList.Create;
    try
      L.Text := FPaymentData;
      L.Insert(0, IntToStr(L.Count));
      DecodeDate(FPaymentDate, Year, Month, Day);
      FileName := FDirectoryPayment + '\TA';
      if Day > 9 then
        FileName := FileName + IntToStr(Day)
      else
        FileName := FileName + '0' + IntToStr(Day);

      if Month > 9 then
        FileName := FileName + IntToStr(Month)
      else
        FileName := FileName + '0' + IntToStr(Month);

      I := 0;

      P := StrNew(PChar(L.Text));
      try
        AnsiToOem(P, P);
        L.Text := StrPas(P);
      finally
        StrDispose(P);
      end;

      while True do
      begin
        if I > 9 then
          S := IntToStr(I)
        else
          S := '0' + IntToStr(I);

        if not FileExists(FileName + S + '.txt') then
        begin
          L.SaveToFile(FileName + S + '.txt');
          break;
        end;

        Inc(I);
      end;

      MessageBox(Application.Handle,
        PChar('Сформирована пачка ' + IntToStr(FCountPayment) + ' платежных требований ' + #10#13 +
        FileName + S + '.txt'),
        'Внимание',
        MB_OK or MB_ICONHAND);

    finally
      L.Free;
    end;
  end;
end;


procedure TgsImportExport.Options;
begin
  LoadParams;
  with TdlgImportExportOptions.Create(Self) do
  try
    edDirectoryPayment.Text := FDirectoryPayment;
    edDirectoryStatement.Text := FDirectoryStatement;
    edTemplatePayment.Text := FTemplatePayment;
    edTemplateStatement.Text := FTemplateStatement;
    edExtensionPayment.Text := FExtensionPayment;
    edExtensionStatement.Text := FExtensionStatemet;
    cbDivideEnter.Checked := FDivideEnter;
    cbToday.Checked := FToday;
    if ShowModal = mrOk then
    begin
      FDirectoryPayment := edDirectoryPayment.Text;
      FDirectoryStatement := edDirectoryStatement.Text;
      FTemplatePayment := edTemplatePayment.Text;
      FTemplateStatement := edTemplateStatement.Text;
      FExtensionPayment := edExtensionPayment.Text;
      FExtensionStatemet := edExtensionStatement.Text;
      FDivideEnter := cbDivideEnter.Checked;
      FToday := cbToday.Checked;
      SaveParams;
    end;
  finally
    Free;
  end;
end;

procedure TgsImportExport.ExportPayment(const ID: Integer);
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');
end;

procedure TgsImportExport.ImportStatement;
var
  Files: TStringList;
  I: Integer;
  FName: String;
  D: TDate;

  function GetFileName(Date: TDate): String;
  var
    Year, Month, Day: Word;
  begin
    DecodeDate(Date, Year, Month, Day);
    Result := IntToStr(Day);
    if Day < 10 then
      Result := '0' + Result;

    if Month < 10 then
      Result := Result + '0' + IntToStr(Month)
    else
      Result := Result + IntToStr(Month);

    Result := FDirectoryStatement + '\' + Result + IntToStr(Year) + '.' + FExtensionStatemet;
  end;

  function GetDate(DateStr: String): TDate;
  begin
    try
      DateStr := ExtractFileName(DateStr);
      Result := StrToDate(Copy(DateStr, 1, 2) + '.' + Copy(DateStr, 3, 2) +
        '.' + Copy(DateStr, 5, 4));
    except
      Result := -1;
    end;
  end;

begin
  LoadParams;
  Files := TStringList.Create;
  try
    if not AdvBuildFileList(IncludeTrailingBackslash(FDirectoryStatement) + '*.' +
      FExtensionStatemet, faAnyFile, Files, amSuperSetOf, [flFullNames]) then
    begin
      MessageBox(Application.Handle,
        'Ошибка в указании пути. Процесс прекращен.',
        'Внимание!',
        MB_OK or MB_ICONEXCLAMATION);
      exit;
    end;

   if Files.Count = 0 then
   begin
      MessageBox(Application.Handle,
        'В данном директории отсутвуют файлы.',
        'Внимание!',
        MB_OK or MB_ICONEXCLAMATION);
      exit;
   end;

   if FToday then
   begin
     FName := GetFileName(SysUtils.Date);
     if Files.IndexOf(FName) = -1 then
     begin
       MessageBox(Application.Handle,
         'На сегодняшний день выписка отсутвует.',
         'Внимание!',
         MB_OK or MB_ICONEXCLAMATION);
       exit;
     end
     else
     begin
       if ImportStatement(FName, SysUtils.Date) then
         FTransaction.CommitRetaining
       else
         FTransaction.RollbackRetaining;
     end;
   end
   else
     with TdlgImportPeriod.Create(Self) do
     try
       if ShowModal = mrOk then
       begin
         for I := 0 to Files.Count - 1 do
         begin
           D := GetDate(Files[I]);
           if (D <> -1) and (D >= Int(dtpStart.Date)) and (D <= Int(dtpEnd.Date)) then
             if ImportStatement(Files[I], D) then
               FTransaction.CommitRetaining
             else
               FTransaction.RollbackRetaining;
         end;
       end;
     finally
       Free;
     end;

  finally
    Files.Free;
  end;
end;

function TgsImportExport.ImportStatement(const FileName: String; const Date: TDate): Boolean;
var
  ibsql: TIBSQL;
  TemplateList, DataList: TStringList;
  LenTemp: Integer;

  function MakeTemplate: Boolean;
  var
    S, TmpS, NewElement: String;
    L: Integer;

  begin
    LenTemp := 0;
    Result := True;
    TemplateList.LoadFromFile(FTemplateStatement);
    S := TemplateList.Text;
    TemplateList.Clear;
    while Pos(DivVal, S) <> 0 do
    begin
      TmpS := Copy(S, 0, Pos(DivVal, S) - 1);
      S := Copy(S, Pos(DivVal, S) + 1, Length(S));
      if Pos(DivLen, TmpS) = 0 then
      begin
        Result := False;
        exit;
      end;
      try
        L := StrToInt(Copy(TmpS, Pos(DivLen, Tmps) + 1, Length(Tmps)));
        LenTemp := LenTemp + L;
        NewElement := Copy(TmpS, 0, Pos(DivLen, Tmps) - 1);
        TemplateList.AddObject(NewElement, Pointer(L));
      except
        Result := False;
        exit;
      end;
    end;
  end;

  function TestVariables: Boolean;

    function TestVariable(const Variable: String): Boolean;
    begin
      Result := TemplateList.IndexOf(Variable) <> -1;
      if not Result then
        MessageBox(Application.Handle,
          PChar('В шаблоне отсутствует переменная ' + Variable),
          PChar(sAttention),
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end;

  begin
    Result := TestVariable('DATE') and
              TestVariable('DOCNUMBER') and
              TestVariable('ACCOUNT') and
              TestVariable('CORRACCOUNT') and
              TestVariable('DEBET') and
              TestVariable('CREDIT');
  end;

  procedure MakeStatement;
  var
    S, TmpS: String;
    I, Key, K: Integer;
    NewList: TStringList;
    AccountList: TStringList;
    TemList: TStringList;

    function GetBSKey(const Account: String): Integer;
    begin
      Result := AccountList.IndexOf(Account);
      if Result <> -1 then
        Result := Integer(AccountList.Objects[Result]);
    end;

    function MakeNewStatement(const Account: String): Integer;
    var
      A: Integer;
    begin
      ibsql.Close;
      ibsql.sql.Text := Format(
        ' SELECT id FROM gd_companyaccount ' +
        ' WHERE companykey = %d and account = ' + Account, [IBLogin.CompanyKey]);
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
        Result := ibsql.FieldByName('id').AsInteger
      else
        Result := -1;

      A := Result;
      if Result <> -1 then
      begin
        ibsql.Close;
        ibsql.sql.Text := Format(
          ' SELECT d.id FROM bn_bankstatement bs, gd_document d where bs.accountkey = %d and ' +
          ' bs.documentkey = d.id ' +
          ' and d.documentdate = :documentdate',
          [Result]);

        ibsql.Prepare;
        ibsql.ParamByName('documentdate').AsDateTime := Date;
        ibsql.ExecQuery;

        if (ibsql.RecordCount = 1) then
          if (MessageBox(Application.Handle,
             PChar('Выписка на ' + DateToStr(Date) + ' уже существует. Удалить ее?'),
             'Внимание', MB_YESNO or MB_ICONQUESTION) <> mrYes) then
          begin
            Result := -1;
            AccountList.AddObject(Account, Pointer(0));
            exit;
          end
          else
          begin
            Result := ibsql.FieldByName('id').AsInteger;
            ibsql.Close;
            ibsql.sql.Text := Format(
              ' DELETE FROM GD_DOCUMENT WHERE ID = %d', [Result]);
            ibsql.ExecQuery;
          end;

        Result := GetUniqueKey(FDatabase, FTransaction);

        ibsql.Close;
        ibsql.sql.Text := Format(
          ' INSERT INTO gd_document(id, number, documentdate, editiondate, creationdate, ' +
          ' editorkey, creatorkey, companykey, documenttypekey) ' +
          ' VALUES(%d, ''б/н'', :date1, :date2, :date3, %d, %d, %d, %d)' ,
          [Result, IBLogin.ContactKey, IBLogin.ContactKey, IBLogin.CompanyKey, BN_DOC_BANKSTATEMENT]);

        ibsql.Prepare;

        ibsql.ParamByName('Date1').AsDateTime := Date;
        ibsql.ParamByName('Date2').AsDateTime := SysUtils.Date;
        ibsql.ParamByName('Date3').AsDateTime := SysUtils.Date;

        ibsql.ExecQuery;

        ibsql.Close;
        ibsql.sql.Text := Format(
          ' INSERT INTO bn_bankstatement(documentkey, accountkey) ' +
          ' VALUES(%d, %d)' ,
          [Result, A]);
        ibsql.ExecQuery;
      end;

      AccountList.AddObject(Account, Pointer(Result));
    end;

    function GetValue(const Variable: String): String;
    var
      V: Integer;
    begin
      V := TemplateList.IndexOf(Variable);
      if (V <> -1) and (V < NewList.Count) then
        Result := NewList[V];
    end;

    procedure InsertLine;
    var
      Comp, CompKey, Sum, SumValue, CorrAccount, BankCode, Number, ISO,
      DocNumber, DocNumberField, DocNumberKey: String;
      CKey, BSKey: Integer;
      SValue, SCurrValue, Rate: Double;
    begin
      CorrAccount := GetValue('CORRACCOUNT');
      BankCode := GetValue('MFO');
      BankCode := Copy(BankCode, Length(BankCode) - 2, Length(BankCode));
      Number := GetValue('DOCNUMBER');
      Number := Copy(Number, Length(Number) - 2, 3);
      ibsql.Close;
      ibsql.SQL.Text :=
        ' SELECT companykey FROM gd_companyaccount ac, gd_bank b WHERE ' +
        '  ac.bankkey = b.bankkey AND ac.account = ''' + CorrAccount +
        '''  and b.bankcode = ''' + BankCode + '''';
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        Comp := ', COMPANYKEY';
        CompKey := ', ' + ibsql.FieldByName('companykey').AsString;
        CKey := ibsql.FieldByName('companykey').AsInteger;
      end
      else
        CKey := -1;

      ISO := GetValue('ISO');
      if ISO > '' then
      begin
        ibsql.Close;
        ibsql.SQL.Text := 'SELECT * FROM gd_curr WHERE ISO = ''' + ISO + '''';
        ibsql.ExecQuery;

        if (ibsql.RecordCount = 0) or (ibsql.FieldByName('isncu').AsInteger = 1) then
          ISO := '';
      end;

      try
        Rate := StrToFloat(GetValue('RATE'));
      except
        Rate := 0;
      end;

      DocNumber := GetValue('DOCNUMBER');
      DocNumberField := '';
      DocNumberKey := '';

      SCurrValue := 0;
      SumValue := GetValue('DEBET');
      try
        SValue := StrToFloat(SumValue);
        if SValue = 0 then
          raise EgsImportExport.Create('0');

        if ISO > '' then
        begin
          SCurrValue := SValue;
          SValue := SCurrValue * Rate;
        end;

        Sum := 'DSUMNCU, DSUMCURR';
      except
        SumValue := GetValue('Credit');
        try
          SValue := StrToFloat(SumValue);
          if SValue = 0 then
            raise EgsImportExport.Create('0');

          if ISO > '' then
          begin
            SCurrValue := SValue;
            SValue := SCurrValue * Rate;
          end;

          Sum := 'CSUMNCU, CSUMCURR';

          try
            ibsql.Close;
            ibsql.SQL.Text := Format(
              ' select ID FROM GD_DOCUMENT D, bn_demandpayment P ' +
              ' WHERE D.NUMBER = %s AND D.DOCUMENTTYPEKEY = 800100 ' +
              ' AND P.OWNTAXID = %s AND P.CORRTAXID = %s AND P.AMOUNT = :amount ',
              [DocNumber, GetValue('ACCOUNT'), GetValue('CORRACCOUNT')]);
            ibsql.Prepare;
            ibsql.ParamByName('amount').AsCurrency := SValue;

            ibsql.ExecQuery;

            if ibsql.RecordCount > 0 then
            begin
              DocNumberField := ', DOCUMENTKEY';
              DocNumberKey := ', ' + ibsql.FieldByName('ID').AsString;
            end;
          except
          end;

        except
          SumValue := '0';
          SValue := 0;
        end
      end;

      SumValue := FloatToStr(SValue) + ', ' + FloatToStr(SCurrValue);

      BSKey := GetUniqueKey(FDatabase, FTransaction);
      ibsql.Close;
      ibsql.SQL.Text := Format(
        ' INSERT INTO bn_bankstatementline(ID, BANKSTATEMENTKEY, ' + Sum + ', ' +
        ' ACCOUNT, BANKCODE, DOCNUMBER, OPERATIONTYPE, COMMENT' + DocNumberField + Comp +
        ') VALUES(%d, %d, ' + SumValue + ', ''' + CorrAccount + ''', ''' + BankCode +
        ''', ''' + DocNumber + ''', ''' + Trim(GetValue('OPERATION')) + ''', ''' +
        Trim(GetValue('COMMENT')) + '''' + DocNumberKey + CompKey +')',
        [BSKey, Key]
        );
      ibsql.ExecQuery;

      // Поиск документа
      if (CKey <> -1) and (SValue <> 0) then
      begin
        ibsql.Close;
        ibsql.SQL.Text :=
          ' SELECT t.documentkey FROM GD_DOCUMENT D, dp_transfer t ' +
          ' WHERE d.id = t.inventorykey and t.companykey = ' +
          IntToStr(Ckey) + ' and d.number LIKE ''%' +
          Number + ''' and (d.disabled IS NULL OR d.disabled = 0)';
        ibsql.ExecQuery;

        while not ibsql.Eof do ibsql.Next;

        if ibsql.RecordCount > 0 then
          if ibsql.RecordCount > 1 then
            MessageBox(Application.Handle, PChar('Дублирование актов № док.' + DocNumber +
              ' р/с: ' + CorrAccount + ' код:' + BankCode), 'Внимание!', MB_OK or MB_ICONEXCLAMATION)
          else
          begin
            CKey := ibsql.FieldByName('documentkey').AsInteger;

            ibsql.Close;
            ibsql.SQL.Text := Format(
              ' INSERT INTO BN_BSLineDocument(BSLINEKEY, DOCUMENTKEY, SUMNCU) ' +
              ' VALUES(%d, %d, :sumncu) ',
              [BSKey, Ckey]
              );
            ibsql.Prepare;
            ibsql.ParamByName('sumncu').AsCurrency := SValue;
            ibsql.ExecQuery;
          end;
      end;
    end;

  begin
    TemList := TStringList.Create;
    try
      if TemplateList.Count <> 0 then
      begin
        TemList.LoadFromFile(FileName);
        DataList.Clear;
        for K := 0 to TemList.Count - 1 do
        begin
          S := TemList[K];
          for I := 0 to TemplateList.Count - 1 do
          begin
            if S > '' then
            begin
              TmpS := Copy(S, 0, Integer(TemplateList.Objects[I]));
              if (TmpS > '') and (TmpS[1] <> Chr(VK_RETURN)) then
                DataList.Add(TmpS);
              S := Copy(S, Integer(TemplateList.Objects[I]) + 1, Length(S));
            end
            else
              DataList.Add('');
          end;

{          I := 0;
          while S > '' do
          begin
            TmpS := Copy(S, 0, Integer(TemplateList.Objects[I]));
            if (TmpS > '') and (TmpS[1] <> Chr(VK_RETURN)) then
              DataList.Add(TmpS);
            S := Copy(S, Integer(TemplateList.Objects[I]) + 1, Length(S));
            Inc(I);
            if I = TemplateList.Count then
              I := 0;}
          end;
        end;
    finally
      TemList.Free;
    end;

    NewList := TStringList.Create;
    AccountList := TStringList.Create;
    try
      while True do
      begin
        NewList.Clear;
        for I := 0 to TemplateList.Count - 1 do
        begin
          if DataList.Count = 0 then
          begin
            Result := True;
            exit;
          end;
          NewList.Add(DataList[0]);
          DataList.Delete(0);
        end;

        if NewList.Count = TemplateList.Count then
        begin
          S := GetValue('ACCOUNT');
          Key := GetBSKey(S);
          if Key <> 0 then
          begin
            if Key = -1 then
              Key := MakeNewStatement(S);

            if Key <> -1 then
              InsertLine;
          end;
        end;
      end;
    finally
      AccountList.Free;
      NewList.Free;
    end;
  end;

begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');
  Result := False;

  LoadParams;
  if not FileExists(FileName) then
  begin
    MessageBox(Application.Handle,
      'Невозможно открыть файл с выпиской для импорта в систему. Произведите настройку импорта.',
      'Внимание',
      MB_OK or MB_ICONHAND);
    exit;
  end;

  if not FileExists(FTemplateStatement) then
  begin
    MessageBox(Application.Handle,
      'Невозможно открыть файл-шаблон. Произведите настройку импорта.',
      'Внимание',
      MB_OK or MB_ICONHAND);
    exit;
  end;

  try
    TemplateList := TStringList.Create;
    DataList := TStringList.Create;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.DataBase := FDataBase;
      ibsql.Transaction := FTransaction;
      if not MakeTemplate then
      begin
        MessageBox(Application.Handle,
          'Ошибка в шаблоне',
          PChar(sAttention),
          MB_OK or MB_ICONHAND);
        exit;
      end;

      if not TestVariables then
        exit;

      MakeStatement;

    Result := True;
    finally
      ibsql.Free;
      TemplateList.Free;
      DataList.Free;
    end;
  except
    raise;
  end;
end;

procedure TgsImportExport.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
  end;
end;

procedure TgsImportExport.LoadParams;
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');
  Assert(GlobalStorage <> nil, 'Не подключены настройки');

  if not FIsLoaded then
  begin
    with UserStorage.OpenFolder('DepartmentImport') do
    begin
      FDirectoryPayment := ReadString('DirectoryPayment', '');
      FDirectoryStatement := ReadString('DirectoryStatement', '');
      FTemplatePayment := ReadString('TemplatePayment', '');
      FTemplateStatement := ReadString('TemplateStatement', '');
      FExtensionPayment := ReadString('ExtensionPayment', 'txt');
      FExtensionStatemet := ReadString('ExtensionStatemet', 'out');
      FDivideEnter := ReadInteger('DivideEnter', 1) = 1;
      FToday := ReadInteger('Today', 1) = 1;
    end;
    FIsLoaded := True;
  end;
end;

procedure TgsImportExport.SaveParams;
begin
  Assert(FDataBase <> nil, 'Не подключен DataBase.');
  Assert(FTransaction <> nil, 'Не подключен Transaction.');
  Assert(GlobalStorage <> nil, 'Не подключений настройки');

  with UserStorage.OpenFolder('DepartmentImport') do
  begin
    WriteString('DirectoryPayment', FDirectoryPayment);
    WriteString('DirectoryStatement', FDirectoryStatement);
    WriteString('TemplatePayment', FTemplatePayment);
    WriteString('TemplateStatement', FTemplateStatement);
    WriteString('ExtensionPayment', FExtensionPayment);
    WriteString('ExtensionStatemet', FExtensionStatemet);
    WriteInteger('DivideEnter', Ternary(FDivideEnter, 1, 0));
    WriteInteger('Today', Ternary(FToday, 1, 0));
  end;
end;

procedure TgsImportExport.SetTransaction(const Value: TIBTransaction);
begin
  if FTransaction <> Value then
  begin
    if FTransaction <> nil then
      FTransaction.RemoveFreeNotification(Self);
    FTransaction := Value;
    if FTransaction <> nil then
      FTransaction.FreeNotification(Self);
  end;
end;

procedure TgsImportExport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = FDatabase then
      FDatabase := nil;

    if AComponent = FTransaction then
      FTransaction := nil;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNV', [TgsImportExport]);
end;

end.
