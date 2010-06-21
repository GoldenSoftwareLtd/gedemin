unit gp_frmMakeDemand_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmSIBF_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,  ComCtrls, ToolWin, StdCtrls, ExtCtrls, Grids,
  DBGrids, gsDBGrid, gsIBGrid, JclStrings, gd_Security, gsStorage, at_Classes,
  gsDocNumerator, IBSQL, xCalc, contnrs, dmDatabase_unit, 
  gsReportManager, gdcPayment, gdc_frmPaymentDemand_unit, gdcBase, gdcConst;

type
  TfrmMakeDemand = class(Tgd_frmSIBF)
    actExecute: TAction;
    tblRun: TToolButton;
    xFoCal: TxFoCal;
    ibsqlInsert: TIBSQL;
    gsDocNumerator: TgsDocNumerator;
    ibdsDocument: TIBDataSet;
    dsDocument: TDataSource;
    sqlCompanyData: TIBSQL;
    sqlBankData: TIBSQL;
    ibsqlCompanyAccount: TIBSQL;
    IBSQLCompanyName: TIBSQL;
    ibdsDemandPayment: TIBDataSet;
    ibsqlDocRealPos: TIBSQL;
    ibsqlDocument: TIBSQL;
    ibsqlDocRealization: TIBSQL;
    ibsqlDocRealInfo: TIBSQL;
    pMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    actSelectAll: TAction;
    actDeSelect: TAction;
    ibsqlDocRealPosGroup: TIBSQL;
    ibsqlReturn: TIBSQL;
    sqlOurCompany: TIBSQL;
    sqlOurBank: TIBSQL;
    procedure actExecuteExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actDeSelectExecute(Sender: TObject);
  private
    FAccount: Integer;
    FDest: Integer;
    FDestName: String;
    FAccountName: String;
    FTransactionKey: Integer;
    FUseReturn: Boolean;
    procedure MakeTaxField(ibsqlPos: TIBSQL);
    function MakeDemandForBill(const aCodeBill: TStringList): Boolean;
    function MakeDocument(const aCodeBill: TStringList): Boolean;
    function GetFieldFromDocument(const NameField: String; CodeBill: TStringList): String;
    function GetFieldFromRealization(const NameField: String; CodeBill: TStringList): String;
    function GetFieldFromRealInfo(const NameField: String; CodeBill: TStringList): String;
    function GetFieldFromRealPos(const NameField: String; CodeBill: TStringList): String;
    function GetFieldFromRealPosGroup(const NameField: String; GroupKey: Integer;
      CodeBill: TStringList): String;
    function GetFieldFromOtherTable(const NameField, NameTable: String;
      const Code: Integer): String;  
    function MakeDocumentCode(aCodeBill: TStringList): String;
    function PrepareSQL(ibsql: TIBSQL; FirstSQL: String;
      CodeBill: TStringList; isAddTax: Boolean): String;
    function GetTaraSQL: String;
  protected
    ListDemandField: TObjectList;
    FCurPercent: Currency;
    procedure InternalOpenMain; override;

  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmMakeDemand: TfrmMakeDemand;

implementation

{$R *.DFM}

uses
  gp_dlgFormatDemand_unit, Storages;

(*

  Принцип формиирования требований
  1. Считываем все поля из Storage
  2. Заменяем переменные на соответствующие значения
     Структура переменной:
        [Русское наименование(Наименование поля%Наименование таблицы источника данных)]{Наименование поля%
        Таблица назначения}
     Если таблица источник - gd_docrealpos то значение, которое выбирается должно сумироваться по всем
     позициям конкретного документа (documentkey)
  3. Значения, которые получены сохраняются в отдельном списке
  4. Затем из списка значения добавляются в нужные таблицы.
  5. Формирование требования завершено.

*)

function ReplaceSubStr(aSource, aSourceSubStr, aDestSubStr: String): String;
var
  P: Integer;
begin
  Result := aSource;
  repeat
    P := StrIPos(aSourceSubStr, Result);
    if P > 0 then
    begin
      Delete(Result, P, Length(aSourceSubStr));
      Insert(aDestSubStr, Result, P);
    end;
  until P = 0;
end;

type
  TDemandFieldInfo = class
    FRelationName: String;
    FFieldName: String;
    FTextValue: String;
    constructor Create(const aRelationName, aFieldName, aTextValue: String);
  end;

{ TDemandFieldInfo }

constructor TDemandFieldInfo.Create(const aRelationName, aFieldName,
  aTextValue: String);
begin
  FRelationName := aRelationName;
  FFieldName := aFieldName;
  FTextValue := aTextValue;
end;

{ TdlgMakeDemand }

class function TfrmMakeDemand.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmMakeDemand) then
    frmMakeDemand := TfrmMakeDemand.Create(AnOwner);

  Result := frmMakeDemand;
end;

function TfrmMakeDemand.MakeDemandForBill(const aCodeBill: TStringList): Boolean;
var
  F: TgsStorageFolder;
  j: Integer;
  R: TatRelationField;

function FormatTextValue(aText: String; aTmpBill: TStringList): String;
var
  SourceFieldName: String;
  SourceTableName: String;
  SecondSourceFieldName: String;
  SecondSourceTableName: String;
  Value, Tmp: String;
  GroupKey: Integer;
begin
  if Pos('/*', aText) > 0 then
    aText := copy(aText, Pos('/*', aText) + 2, Pos('*/', aText) - Pos('/*', aText) - 2);
  Result := aText;
  while Pos('[', aText) > 0 do
  begin
    Tmp := copy(aText, Pos('[', aText), Pos(']', aText) - Pos('[', aText) + 1);
    SourceFieldName := copy(Tmp, Pos('(', Tmp) + 1, Pos('%', Tmp) - Pos('(', Tmp) - 1);
    SourceTableName := copy(Tmp, Pos('%', Tmp) + 1, Pos(')', Tmp) - Pos('%', Tmp) - 1);

    if Pos('/', aText) > 0 then
    begin
      Tmp := copy(aText, Pos('/', aText), Pos('\', aText) - Pos('/', aText) + 1);
      SecondSourceFieldName := copy(Tmp, Pos('/', Tmp) + 1, Pos('%', Tmp) - Pos('/', Tmp) - 1);
      SecondSourceTableName := copy(Tmp, Pos('%', Tmp) + 1, Pos('\', Tmp) - Pos('%', Tmp) - 1);
    end
    else
    begin
      SecondSourceFieldName := '';
      SecondSourceTableName := '';
    end;
    Tmp := copy(aText, Pos('[', aText), Pos(']', aText) - Pos('[', aText) + 1);

    if SourceFieldName = 'ТекДата' then
      Value := DateToStr(SysUtils.Date)
    else
      if SourceFieldName = 'Он же' then
        Value := 'Он же'
      else
        if SourceTableName = 'GD_DOCUMENT' then
          Value := GetFieldFromDocument(SourceFieldName, aTmpBill)
        else
          if SourceTableName = 'GD_DOCREALINFO' then
          begin
            Value := GetFieldFromRealInfo(SourceFieldName, aTmpBill);
            if (SecondSourceFieldName > '') and (Value > '') then
              Value := GetFieldFromOtherTable(SecondSourceFieldName,
                  SecondSourceTableName, StrToInt(Value));
          end
          else
            if SourceTableName = 'GD_DOCREALIZATION' then
            begin
              if (GetFieldFromRealization(SourceFieldName, aTmpBill) = '')
              then
              begin
                R := atDatabase.FindRelationField(SourceTableName, SourceFieldName);
                if Assigned(R) and Assigned(R.Field) and
                  (R.Field.FieldType in [ftFloat, ftCurrency, ftBCD])
                then
                  Value := '0'
                else
                  Value := '';
              end
              else
              begin
                Value := GetFieldFromRealization(SourceFieldName, aTmpBill);
                if (UpperCase(Trim(SourceFieldName)) = 'TYPETRANSPORT') and (Value > '') then
                begin
                  case Value[1] of
                  'C', 'A': Value := 'Доставлено покупателю';
                  'S': Value :=
                    Format('Вывезено транспортом покупателя по дов. № %s от %s',
                      [GetFieldFromRealInfo('warrantnumber', aTmpBill),
                       GetFieldFromRealInfo('warrantdate', aTmpBill)]);
                  end;
                end;
                if (SecondSourceFieldName > '') and (Value > '') then
                  Value := GetFieldFromOtherTable(SecondSourceFieldName,
                      SecondSourceTableName, StrToInt(Value));
              end;
            end
            else
            begin
              if Pos('''', SourceTableName) = 0 then
              begin
                if (GetFieldFromRealPos(SourceFieldName, aTmpBill) = '')
                then
                begin
                  R := atDatabase.FindRelationField(SourceTableName, SourceFieldName);
                  if Assigned(R) and Assigned(R.Field) and
                    (R.Field.FieldType in [ftFloat, ftCurrency, ftBCD])
                  then
                    Value := '0'
                  else
                    Value := '';
                end
                else
                begin
                  Value := GetFieldFromRealPos(SourceFieldName, aTmpBill);
                  if (SecondSourceFieldName > '') and (Value > '') then
                    Value := GetFieldFromOtherTable(SecondSourceFieldName,
                      SecondSourceTableName, StrToInt(Value));
                end;
              end
              else
              begin
                GroupKey :=
                  StrToInt(copy(SourceTableName, Pos('''', SourceTableName) + 1, Length(SourceTableName)));
                if (GetFieldFromRealPosGroup(SourceFieldName, GroupKey, aTmpBill) = '')
                then
                begin
                  SourceTableName := copy(SourceTableName, 1, Pos('''', SourceTableName) - 1);
                  R := atDatabase.FindRelationField(SourceTableName, SourceFieldName);
                  if Assigned(R) and Assigned(R.Field) and
                    (R.Field.FieldType in [ftFloat, ftCurrency, ftBCD])
                  then
                    Value := '0'
                  else
                    Value := '';
                end
                else
                begin
                  Value := GetFieldFromRealPosGroup(SourceFieldName, GroupKey, aTmpBill);
                  if (SecondSourceFieldName > '') and (Value > '') then
                    Value := GetFieldFromOtherTable(SecondSourceFieldName,
                      SecondSourceTableName, StrToInt(Value));
                end;
              end;
            end;
    aText := ReplaceSubStr(aText, Tmp, Value);
  end;


  try
    xFocal.Expression := aText;
    if xFocal.Value <> 0 then
      aText := FloatToStr(xFocal.Value);
  except
  end;

  Result := aText;
end;

function MakeFormatText(aText: String; aTmpBill: TStringList): String;
var
  Tmp, Value: String;
begin
  Result := aText;

  while Pos('/*', aText) > 0 do
  begin
    Tmp := copy(aText, Pos('/*', aText), Pos('*/', aText) - Pos('/*', aText) + 2);
    Value := FormatTextValue(Tmp, aTmpBill);
    aText := ReplaceSubStr(aText, Tmp, Value);
  end;
  Result := FormatTextValue(aText, aTmpBill);

end;

procedure MakeForBillText(aText: String);
var
  i: Integer;
  TmpBill: TStringList;
  PerStr, SaveStr: String;
  DestFieldName: String;
  DestTableName: String;

begin
  if Pos('{', aText) = 0 then
    Exit;

  PerStr := copy(aText, Pos('{', aText) + 1, Pos('}', aText) - Pos('{', aText) - 1);
  DestFieldName := copy(PerStr, 1, Pos('%', PerStr) - 1);
  DestTableName := copy(PerStr, Pos('%', PerStr) + 1, Length(PerStr));

  aText := copy(aText, 1, Pos('{', aText) - 1);

  if Pos('(*', aText) = 0 then
    SaveStr := MakeFormatText(aText, aCodeBill)
  else
  begin
    TmpBill := TStringList.Create;
    try
      SaveStr := '';
      while Pos('(*', aText) > 0 do
      begin

        SaveStr := SaveStr + MakeFormatText(copy(aText, 1, Pos('(*', aText) - 1), aCodeBill);
        PerStr := copy(aText, Pos('(*', aText) + 2, Pos('*)', aText) - Pos('(*', aText) - 2);
        for i:= 0 to aCodeBill.Count - 1 do
        begin
          TmpBill.Clear;
          TmpBill.Add(aCodeBill[i]);
          SaveStr := SaveStr + ' ' + MakeFormatText(PerStr, TmpBill);
        end;
        aText := copy(aText, Pos('*)', aText) + 2, Length(aText));

      end;
      SaveStr := SaveStr + MakeFormatText(aText, aCodeBill);
    finally
      TmpBill.Free;
    end;
  end;

  ListDemandField.Add(TDemandFieldInfo.Create(DestTableName, DestFieldName, SaveStr));
end;

begin
  F := GlobalStorage.OpenFolder('gp_DemandFormat');
  if Assigned(F) then
  try
    for j:= 0 to F.ValuesCount - 1 do
      MakeForBillText(F.Values[j].AsString);
  finally
    GlobalStorage.CloseFolder(F);
  end;

  Result := True;
end;

function TfrmMakeDemand.MakeDocument(const aCodeBill: TStringList): Boolean;
var
  i: Integer;
  CodeReturnBill: TStringList;
  AmountReturn: Currency;
  ReturnStr, Bills: String;

function CheckReturn(const ContactKey: Integer; const Amount: Currency): Currency;
begin
  ibsqlReturn.ParamByName('CK').AsInteger := ContactKey;
  ibsqlReturn.ExecQuery;
  try
    CodeReturnBill.Clear;
    Result := 0;
    Bills := 'по накладным: ';
    while not ibsqlReturn.EOF do
    begin
      if Result + ibsqlReturn.FieldByName('AmountNCU').AsCurrency < Amount then
      begin
        Result := Result + ibsqlReturn.FieldByName('AmountNCU').AsCurrency;
        Bills := Bills + Format('%s от %s, ',
          [ibsqlReturn.FieldByName('number').AsString,
           ibsqlReturn.FieldByName('documentdate').AsString]);
        CodeReturnBill.Add(ibsqlReturn.FieldByName('id').AsString);
      end;
      ibsqlReturn.Next;
    end;
  finally
    ibsqlReturn.Close;
  end;
end;

procedure SetTextDemandField;
begin
    with ibdsDemandPayment do
    begin
      /////////////////////////
      //  Данные по плательщику

      FieldByName('OWNTAXID').AsString :=
        sqlOurCompany.FieldByName('TAXID').AsString;
      FieldByName('OWNCOUNTRY').AsString :=
        sqlOurCompany.FieldByName('COUNTRY').AsString;
      FieldByName('OWNCOMPTEXT').AsString :=
        sqlOurCompany.FieldByName('FULLNAME').AsString;

      FieldByName('OWNBANKTEXT').AsString :=
        sqlOurBank.FieldByName('FULLNAME').AsString;
      FieldByName('OWNBANKCITY').AsString :=
        sqlOurBank.FieldByName('CITY').AsString;
      FieldByName('OWNACCOUNT').AsString :=
        FAccountName;
      FieldByName('OWNACCOUNTCODE').AsString :=
        sqlOurBank.FieldByName('BANKCODE').AsString;

      ///////////////////////
      // Данные по получателю

      sqlCompanyData.Params.ByName('ID').AsString := FieldByName('CORRCOMPANYKEY').AsString;
      sqlCompanyData.ExecQuery;
      FieldByName('CORRCOMPTEXT').AsString :=
        sqlCompanyData.FieldByName('FULLNAME').AsString;
      FieldByName('CORRTAXID').AsString :=
        sqlCompanyData.FieldByName('TAXID').AsString;

      if sqlCompanyData.FieldByName('COUNTRY').AsString > '' then
        FieldByName('CORRCOUNTRY').AsString :=
          sqlCompanyData.FieldByName('COUNTRY').AsString
      else
        FieldByName('CORRCOUNTRY').AsString := 'РБ';

      sqlCompanyData.Close;

      if (FieldByName('CARGOSENDER').AsString > '') and (FieldByName('CARGOSENDER').AsString <> 'Он же') then
      begin
        sqlCompanyData.ParamByName('ID').AsString := FieldByName('CARGOSENDER').AsString;
        sqlCompanyData.ExecQuery;

        FieldByName('CARGOSENDER').AsString := sqlCompanyData.FieldByName('FULLNAME').AsString;
        sqlCompanyData.Close;
      end;

      if (FieldByName('CARGORECIEVER').AsString > '') and (FieldByName('CARGORECIEVER').AsString <> 'Он же') then
      begin
        sqlCompanyData.ParamByName('ID').AsString := FieldByName('CARGORECIEVER').AsString;
        sqlCompanyData.ExecQuery;

        FieldByName('CARGORECIEVER').AsString := sqlCompanyData.FieldByName('FULLNAME').AsString;
        sqlCompanyData.Close;
      end;

      ibsqlCompanyAccount.ParamByName('ck').AsInteger := FieldByName('CORRCOMPANYKEY').AsInteger;
      ibsqlCompanyAccount.ExecQuery;

      FieldByName('CORRACCOUNTKEY').AsInteger :=
        ibsqlCompanyAccount.FieldByName('companyaccountkey').AsInteger;

      sqlBankData.Params.ByName('ID').AsInteger :=
        ibsqlCompanyAccount.FieldByName('companyaccountkey').AsInteger;

      sqlBankData.ExecQuery;

      FieldByName('CORRBANKTEXT').AsString :=
        sqlBankData.FieldByName('FULLNAME').AsString;
      FieldByName('CORRBANKCITY').AsString :=
        sqlBankData.FieldByName('CITY').AsString;
      FieldByName('CORRACCOUNT').AsString :=
        sqlBankData.FieldByName('ACCOUNT').AsString;
      FieldByName('CORRACCOUNTCODE').AsString :=
        sqlBankData.FieldByName('BANKCODE').AsString;

      sqlBankData.Close;
      ibsqlCompanyAccount.Close;

      FieldByName('DESTCODE').AsString := FDestName;
    end;

    with ibdsDocument do
    begin
      if ibdsDocument.FieldByName('Number').IsNull then
        ibdsDocument.FieldByName('Number').AsString := 'б/н';

      if FTransactionKey <> -1 then
        ibdsDocument.FieldByName('TRTYPEKEY').AsInteger := FTransactionKey;  

      if ibdsDocument.FieldByName('DOCUMENTDATE').IsNull then
        ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime := SysUtils.Date;

    end;

end;

begin
  Result := False;
  if ListDemandField.Count > 0 then
  begin
    if FUseReturn then
      CodeReturnBill := TStringList.Create
    else
      CodeReturnBill := nil;
    try
      ibdsDocument.Open;
      ibdsDemandPayment.Open;

      ibdsDocument.Insert;
      ibdsDocument.FieldByName('ID').AsInteger := GenUniqueID;

      ibdsDemandPayment.Insert;
      ibdsDemandPayment.FieldByName('DocumentKey').AsInteger :=
        ibdsDocument.FieldByName('ID').AsInteger;

      for i:= 0 to ListDemandField.Count - 1 do
      begin
        if TDemandFieldInfo(ListDemandField[i]).FTextValue > '' then
        begin
          if TDemandFieldInfo(ListDemandField[i]).FRelationName = 'GD_DOCUMENT' then
            ibdsDocument.FieldByName(TDemandFieldInfo(ListDemandField[i]).FFieldName).AsString :=
              TDemandFieldInfo(ListDemandField[i]).FTextValue
          else
          begin
            try
              ibdsDemandPayment.FieldByName(TDemandFieldInfo(ListDemandField[i]).FFieldName).AsString :=
                TDemandFieldInfo(ListDemandField[i]).FTextValue;
            except
            end;
          end;
        end;
      end;

      ibdsDemandPayment.FieldByName('AccountKey').AsInteger := FAccount;
      if FDest <> -1 then
        ibdsDemandPayment.FieldByName('DESTCODEKEY').AsInteger := FDest;

      SetTextDemandField;

      try
        if FUseReturn then
        begin
          AmountReturn := CheckReturn(ibdsDemandPayment.FieldByName('CORRCOMPANYKEY').AsInteger,
            ibdsDemandPayment.FieldByName('amount').AsFloat);
          if Assigned(CodeReturnBill) and (CodeReturnBill.Count > 0) then
          begin
            ReturnStr := Format(' Зачет по возвр. таре на сумму %m %s', [AmountReturn, Bills]);
            ibdsDemandPayment.FieldByName('amount').AsCurrency :=
              ibdsDemandPayment.FieldByName('amount').AsCurrency - AmountReturn;
            ibdsDemandPayment.FieldByName('destination').AsString :=
              ibdsDemandPayment.FieldByName('destination').AsString + ReturnStr;
          end;
        end;
        if ibdsDemandPayment.FieldByName('amount').AsCurrency <> 0 then
        begin
          ibdsDocument.Post;
          if FCurPercent <> 0 then
            ibdsDemandPayment.FieldByName('Percent').AsCurrency := FCurPercent;
          ibdsDemandPayment.Post;

          ibsqlInsert.Prepare;
          ibsqlInsert.ParamByName('dk').AsInteger := ibdsDocument.FieldByName('id').AsInteger;

          for i:= 0 to aCodeBill.Count - 1 do
          begin
            ibsqlInsert.ParamByName('sk').AsInteger := StrToInt(aCodeBill[i]);
            ibsqlInsert.ExecQuery;
            ibsqlInsert.Close;
          end;

          if Assigned(CodeReturnBill) then
          begin
            ibsqlInsert.ParamByName('sk').AsInteger := ibdsDocument.FieldByName('id').AsInteger;
            for i:= 0 to CodeReturnBill.Count - 1 do
            begin
              ibsqlInsert.ParamByName('dk').AsInteger := StrToInt(CodeReturnBill[i]);
              ibsqlInsert.ExecQuery;
              ibsqlInsert.Close;
            end;
          end;
        end
        else
        begin
          ibdsDemandPayment.Cancel;
          ibdsDocument.Cancel;
        end;
        Result := True;
      except
        on E: Exception do
        begin
          MessageBox(HANDLE, PChar(Format('При создании требования возникла следующая ошибка - %s',
            [E.Message])), 'Внимание', mb_Ok or mb_IconInformation);
          if ibdsDemandPayment.State in [dsEdit, dsInsert] then
            ibdsDemandPayment.Cancel;
          if ibdsDocument.State in [dsEdit, dsInsert] then
            ibdsDocument.Cancel;
        end;
      end;
    finally
      if Assigned(CodeReturnBill) then
        FreeAndNil(CodeReturnBill);
    end;
  end;
  ListDemandField.Clear;
end;

function TfrmMakeDemand.GetTaraSQL: String;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    Result := 'SELECT doc.id, doc.documentdate, doc.number ';
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_docrealposoption ';
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCREALPOS' then
      begin
        if ibsql.FieldByName('includetax').AsInteger = 0 then
        begin
          if ibsql.FieldByName('iscurrency').AsInteger = 1 then
            Result := Result + ', SUM(AmountCurr + ' + ibsql.FieldByName('fieldname').AsString +
                     ') as AmountCurr '
          else
            Result := Result + ', SUM(AmountNCU + ' + ibsql.FieldByName('fieldname').AsString +
                     ') as AmountNCU ';
        end
        else
          if ibsql.FieldByName('iscurrency').AsInteger = 1 then
            Result := Result + ', SUM(AmountCurr) as AmountCurr '
          else
            Result := Result + ', SUM(AmountNCU) as AmountNCU ';
      end;
      ibsql.Next;
    end;
    ibsql.Close;
    
  finally
    ibsql.Free;
  end;
end;

procedure TfrmMakeDemand.MakeTaxField(ibsqlPos: TIBSQL);
var
  ibsql: TIBSQL;
  S, S1: String;
begin
  if Pos('/*', ibsqlDocRealPos.SQL.Text) = 0 then exit;
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_docrealposoption';
    ibsql.ExecQuery;

    S := '';
    while not ibsql.Eof do
    begin
      if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCREALPOS' then
        S := S + Format(', SUM(%0:s) as %0:s', [ibsql.FieldByName('fieldname').AsString]);
      ibsql.Next;
    end;
    ibsql.Close;

    if S > '' then
    begin
      S1 := ibsqlPos.SQL.Text;
      S1 := copy(S1, 1, Pos('/*', S1) - 1) + S + copy(S1, Pos('*/', S1) + 2, Length(S1));
      ibsqlPos.SQL.Text := S1;
    end;

  finally
    ibsql.Free;
  end;
end;

procedure TfrmMakeDemand.actExecuteExecute(Sender: TObject);
var
  isOK: Boolean;
  SList: TStringList;
  CodeClient: Integer;
  Bookmark: TBookmark;
  isUnion: Boolean;
  S: String;
  I: Integer;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  sqlOurCompany.Params.ByName('ID').AsInteger := IBLogin.CompanyKey;;
  sqlOurCompany.ExecQuery;

  try
    FAccount := StrToInt(GlobalStorage.ReadString('gp_DemandFormat', 'OURACCOUNTKEY', ''));
  except
    FAccount := -1;
  end;
  try
    FDest := StrToInt(GlobalStorage.ReadString('gp_DemandFormat', 'DEST',
              ''));
  except
    FDest := -1;
  end;

  FAccountName := GlobalStorage.ReadString('gp_DemandFormat', 'OURACCOUNTNAME', '');
  FDestName := GlobalStorage.ReadString('gp_DemandFormat', 'DESTNAME', '');
  FTransactionKey := StrToIntDef(GlobalStorage.ReadString('gp_DemandFormat',
    'Transaction', ''), -1);

  sqlOurBank.Params.ByName('ID').AsInteger := FAccount;
  sqlOurBank.ExecQuery;

  SList := TStringList.Create;
  try
    isUnion := GlobalStorage.ReadInteger('gp_DemandFormat', 'UnionBill', 1) = 1;
    FUseReturn := GlobalStorage.ReadInteger('gp_DemandFormat', 'UseReturn', 1) = 1;

    if FUseReturn then
    begin
      ibsqlReturn.SQL.Text := GetTaraSQL +
        '  FROM gd_document doc ' +
        '  JOIN gd_docrealization docr ON doc.id = docr.documentkey ' +
        '  LEFT JOIN gd_docrealpos docp ON doc.id = docp.documentkey         ' +
        '  LEFt JOIN gd_company com ON docr.fromcontactkey = com.contactkey ' +
        'WHERE ' +
        '  not EXISTS(SELECT * FROM gd_documentlink dl WHERE dl.destdockey = doc.id)' +
        '  AND (com.headcompany IS NULL or com.headcompany <> :c) AND ' +
        '  doc.documentdate >= ''01.04.2001'' ' +
        '  AND doc.documenttypekey = 802003 AND docr.fromcontactkey = :CK  AND ' +
        '     doc.companykey = :c ' +
        '  GROUP BY doc.id, doc.documentdate, doc.number ' +
        '  ORDER BY doc.documentdate, doc.number ';
      ibsqlReturn.Prepare;
      ibsqlReturn.ParamByName('c').AsInteger := IBLogin.CompanyKey;  
    end;

    isOK := True;
    Bookmark := ibdsMain.GetBookmark;
    ibdsMain.DisableControls;
    try
      ibdsMain.First;
      CodeClient := ibdsMain.FieldByName('tocontactkey').AsInteger;      
      while not ibdsMain.EOF do
      begin
        if ibgrMain.CheckBox.CheckList.IndexOf(ibdsMain.FieldByName('documentkey').AsString) >= 0
        then
        begin
          if (CodeClient <> ibdsMain.FieldByName('tocontactkey').AsInteger) or not IsUnion then
          begin
            CodeClient := ibdsMain.FieldByName('tocontactkey').AsInteger;
            if SList.Count > 0 then
            begin
              isOk := MakeDemandForBill(SList);
              if isOk then
                isOk := MakeDocument(SList);
            end;
            SList.Clear;
            if not isOK then Break;
          end;
          SList.Add(ibdsMain.FieldByName('documentkey').AsString);
          FCurPercent := ibdsMain.FieldByName('Percent').AsCurrency;
        end;
        ibdsMain.Next;
      end;

      if SList.Count > 0 then
      begin
        isOk := MakeDemandForBill(SList);
        if isOk then
          isOk := MakeDocument(SList);
      end;

    finally
      ibdsMain.GotoBookmark(Bookmark);
      ibdsMain.FreeBookmark(Bookmark);
      ibdsMain.EnableControls;
    end;

  finally
    SList.Free;
  end;

  sqlOurCompany.Close;
  sqlOurBank.Close;

  if isOk then
    IBTransaction.Commit
  else
    IBTransaction.RollBack;

  InternalOpenMain;

  if isOk and (MessageBox(HANDLE, 'Требования успешно сформированы. Желаете их просмотреть ?',
      'Внимание', mb_YesNo or mb_IconQuestion) = idYes)
  then
  begin
    S := '(';
    for i:= 0 to ibgrMain.CheckBox.CheckList.Count - 1 do
    begin
      S := S + ibgrMain.CheckBox.CheckList[i];
      if i <> ibgrMain.CheckBox.CheckList.Count - 1 then
        S := S + ',';
    end;
    S := S + '))';
     with Tgdc_frmPaymentDemand.CreateAndAssign(Application) as Tgdc_frmPaymentDemand do
     begin
       gdcPaymentDemand.SubSet := 'All';
       Setup(nil);
       S := '      Z.ID IN (SELECT DL.destdockey FROM gd_documentlink dl WHERE ' +
        '         DL.SOURCEDOCKEY IN  ' + S;
      ibcmbAccount.CurrentKey := '';
      gdcPaymentDemand.ExtraConditions.Text := S;
//      gdcPaymentDemand.FindWhereSQL := S;
//      gdcPaymentDemand.AccountKey := -1;
      try
        gdcPaymentDemand.Open;
      except
      end;  
      //gdcPaymentDemand.Commit(ctHardReopen);
      Show;
     end;
  end;

  ibgrMain.CheckBox.Clear;
end;

procedure TfrmMakeDemand.InternalOpenMain;
begin
  InternalStartTransaction;
  //!!!
  ibdsMain.SelectSQL.Text :=
    'SELECT doc.number, doc.documentdate, docr.documentkey, docr.transsumncu, docr.transsumcurr, ' +
    'doc.currkey, docr.tocontactkey, docr.fromcontactkey, docr.fromdocumentkey, docr.rate, toc.name, ' +
    'fromc.name as fromname, docr.typetransport, doci.contractkey, con.percent FROM gd_docrealization docr '+
    'JOIN gd_document doc ON doc.id = docr.documentkey  AND doc.documenttypekey = :dt AND doc.companykey = :ck ' +
    'JOIN gd_contact toc ON docr.tocontactkey = toc.id JOIN gd_contact fromc ON docr.fromcontactkey = fromc.id ' +
    'JOIN gd_company comp ON docr.tocontactkey = comp.contactkey LEFT JOIN gd_docrealinfo doci ON docr.documentkey = doci.documentkey ' +
    'LEFT JOIN gd_contract con ON doci.contractkey = con.documentkey WHERE not comp.companyaccountkey IS NULL AND '+
    'NOT exists(SELECT sourcedockey FROM gd_documentlink dl WHERE dl.sourcedockey = docr.documentkey) AND '+
    '(docr.typetransport IS NULL or docr.typetransport <> ''C'' or NOT docr.fromdocumentkey IS NULL) ' +
    'AND (docr.isrealization = 1 or NOT docr.fromdocumentkey IS NULL)';
  //!!!
  ibdsMain.ParamByName('ck').AsInteger := IBLogin.CompanyKey;
  ibdsMain.ParamByName('dt').AsInteger := 802001; //!!!
  ibdsMain.Open;

end;

procedure TfrmMakeDemand.actEditExecute(Sender: TObject);
begin
  with TdlgFormatDemand.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;


procedure TfrmMakeDemand.FormCreate(Sender: TObject);
begin
  ListDemandField := TObjectList.Create;
  inherited;
end;

procedure TfrmMakeDemand.FormDestroy(Sender: TObject);
begin
  if Assigned(ListDemandField) then
    FreeAndNil(ListDemandField);
  inherited;
end;

procedure TfrmMakeDemand.actSelectAllExecute(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  Bookmark := ibdsMain.GetBookmark;
  ibdsMain.DisableControls;
  try
    ibgrMain.CheckBox.Clear;
    ibdsMain.First;
    while not ibdsMain.EOF do
    begin
      ibgrMain.CheckBox.AddCheck(ibdsMain.FieldByName('documentkey').AsInteger);
      ibdsMain.Next;
    end;
  finally
    ibdsMain.GotoBookmark(Bookmark);
    ibdsMain.FreeBookmark(Bookmark);
    ibdsMain.EnableControls;
  end;

end;

procedure TfrmMakeDemand.actDeSelectExecute(Sender: TObject);
begin
  ibgrMain.CheckBox.Clear;
end;

function TfrmMakeDemand.PrepareSQL(ibsql: TIBSQL; FirstSQL: String;
  CodeBill: TStringList; isAddTax: Boolean): String;
begin
  if ibsql.SQL.Text <> FirstSQL + MakeDocumentCode(CodeBill) then
  begin
    try
      ibsql.Close;
    except
    end;
    ibsql.SQL.Text := FirstSQL + MakeDocumentCode(CodeBill);
    if isAddTax then
      MakeTaxField(ibsql);
  end;
  try
    ibsql.CheckOpen;
  except
    ibsql.ExecQuery;
  end;
end;

function TfrmMakeDemand.GetFieldFromDocument(const NameField: String;
  CodeBill: TStringList): String;
begin
  PrepareSQL(ibsqlDocument, 'SELECT * FROM gd_document where id in ', CodeBill, False);
  Result := ibsqlDocument.FieldByName(NameField).AsString;
end;

function TfrmMakeDemand.GetFieldFromRealization(const NameField: String;
  CodeBill: TStringList): String;
begin
  PrepareSQL(ibsqlDocRealization, 'SELECT * FROM gd_docrealization where documentkey in ',
    CodeBill, False);
  Result := ibsqlDocRealization.FieldByName(NameField).AsString;
end;

function TfrmMakeDemand.GetFieldFromRealInfo(const NameField: String;
  CodeBill: TStringList): String;
begin
  PrepareSQL(ibsqlDocRealInfo, 'SELECT * FROM gd_docrealinfo where documentkey in ',
    CodeBill, False);
  Result := ibsqlDocRealInfo.FieldByName(NameField).AsString;
end;

function TfrmMakeDemand.GetFieldFromRealPos(const NameField: String;
 CodeBill: TStringList): String;
begin
  PrepareSQL(ibsqlDocRealPos,
    'SELECT SUM(AmountNCU) as AmountNCU, SUM(AmountCurr) as AmountCurr '
    + '/**/ FROM gd_docrealpos where documentkey in ',
    CodeBill, True);
  Result := ibsqlDocRealPos.FieldByName(NameField).AsString;
end;

function TfrmMakeDemand.GetFieldFromRealPosGroup(const NameField: String;
  GroupKey: Integer; CodeBill: TStringList): String;
begin
  PrepareSQL(ibsqlDocRealPosGroup, 'SELECT SUM(docp.AmountNCU) as AmountNCU, ' +
    ' SUM(docp.AmountCurr) as AmountCurr /**/ FROM gd_docrealpos docp JOIN ' +
    'gd_good g ON docp.GoodKey = g.id WHERE g.GroupKey = ' + IntToStr(GroupKey) +
    ' AND docp.documentkey in ', CodeBill, True);
  Result := ibsqlDocRealPosGroup.FieldByName(NameField).AsString;
end;

function TfrmMakeDemand.MakeDocumentCode(aCodeBill: TStringList): String;
var
  i: Integer;
begin
  Result := '(';
  for i:= 0 to aCodeBill.Count - 1 do
  begin
    Result := Result + aCodeBill[i];
    if i < aCodeBill.Count - 1 then
      Result := Result + ',';
  end;
  Result := Result + ')';
end;


function TfrmMakeDemand.GetFieldFromOtherTable(const NameField,
  NameTable: String; const Code: Integer): String;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := Format('SELECT %s FROM %s WHERE id = %d', [NameField, NameTable, Code]);
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      Result := ibsql.Fields[0].AsString
    else
      Result := '';
    ibsql.Close;    
  finally
    ibsql.Free;
  end;
end;

initialization
  RegisterClass(TfrmMakeDemand);

end.
