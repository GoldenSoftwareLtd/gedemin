unit gp_dlgMakeDemand_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  xCalculatorEdit, StdCtrls, DBCtrls, Mask, xDateEdits, gsIBLookupComboBox,
  ExtCtrls, ComCtrls, Buttons, dmDatabase_unit, IBDatabase, at_Classes,
  gsStorage, Db, IBCustomDataSet, IBSQL, contnrs, gsDocNumerator, xCalc,
  Grids, DBGrids, gsDBGrid, gsIBGrid, JclStrings, gd_Security, ActnList,
  ToolWin, Menus, flt_sqlFilter, IBHeader;

type
  TdlgMakeDemand = class(TForm)
    IBTransaction: TIBTransaction;
    ibsqlDocument: TIBSQL;
    ibsqlDocRealization: TIBSQL;
    ibsqlDocRealInfo: TIBSQL;
    ibsqlDocRealPos: TIBSQL;
    gsDocNumerator: TgsDocNumerator;
    ibdsDocument: TIBDataSet;
    dsDocument: TDataSource;
    xFoCal: TxFoCal;
    ibdsDemandPayment: TIBDataSet;
    sqlCompanyData: TIBSQL;
    IBSQLCompanyName: TIBSQL;
    sqlBankData: TIBSQL;
    Panel2: TPanel;
    gsibgrRealization: TgsIBGrid;
    ibdsDocRealization: TIBDataSet;
    dsDocRealization: TDataSource;
    ibsqlCompanyAccount: TIBSQL;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ActionList1: TActionList;
    actRun: TAction;
    actFormat: TAction;
    PopupMenu1: TPopupMenu;
    gsQueryFilter: TgsQueryFilter;
    ibsqlInsert: TIBSQL;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actFormatExecute(Sender: TObject);
  private
    { Private declarations }
    ListDemandField: TObjectList;
    function MakeDemandForBill(const aCodeBill, aCodeGroup: Integer): Boolean;
    procedure MakeTaxField;
    procedure Prepare;
  public
    { Public declarations }
  end;

var
  dlgMakeDemand: TdlgMakeDemand;

implementation

{$R *.DFM}

uses gp_dlgFormatDemand_unit;

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

function TdlgMakeDemand.MakeDemandForBill(const aCodeBill, aCodeGroup: Integer): Boolean;
var
  F: TgsStorageFolder;
  i: Integer;
  FDestName: String;
  FAccountName: String;
  R: TatRelationField;
  FAccount: Integer;
  FDest: Integer;

procedure MakeFormatText(aText: String);
var
  DestFieldName: String;
  DestTableName: String;
  SourceFieldName: String;
  SourceTableName: String;
  Value: String;
  Tmp: String;
begin
  if Pos('{', aText) = 0 then
    Exit;
  Tmp := copy(aText, Pos('{', aText) + 1, Pos('}', aText) - Pos('{', aText) - 1);
  DestFieldName := copy(Tmp, 1, Pos('%', Tmp) - 1);
  DestTableName := copy(Tmp, Pos('%', Tmp) + 1, Length(Tmp));

  aText := copy(aText, 1, Pos('{', aText) - 1);

  while Pos('[', aText) > 0 do
  begin
    Tmp := copy(aText, Pos('[', aText), Pos(']', aText) - Pos('[', aText) + 1);
    SourceFieldName := copy(Tmp, Pos('(', Tmp) + 1, Pos('%', Tmp) - Pos('(', Tmp) - 1);
    SourceTableName := copy(Tmp, Pos('%', Tmp) + 1, Pos(')', Tmp) - Pos('%', Tmp) - 1);
    if SourceFieldName = 'ТекДата' then
      Value := DateToStr(SysUtils.Date)
    else
      if SourceTableName = 'GD_DOCUMENT' then
      begin
        try
          ibsqlDocument.CheckOpen;
        except
          ibsqlDocument.ExecQuery;
        end;
        Value := ibsqlDocument.FieldByName(SourceFieldName).AsString;
      end
      else
        if SourceTableName = 'GD_DOCREALINFO' then
        begin
          try
            ibsqlDocRealInfo.CheckOpen;
          except
            ibsqlDocRealInfo.ExecQuery;
          end;
          Value := ibsqlDocRealInfo.FieldByName(SourceFieldName).AsString;
        end
        else
          if SourceTableName = 'GD_DOCREALIZATION' then
          begin
            try
              ibsqlDocRealization.CheckOpen;
            except
              ibsqlDocRealization.ExecQuery;
            end;
            if (ibsqlDocRealization.FieldByName(SourceFieldName).AsString = '')
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
              Value := ibsqlDocRealization.FieldByName(SourceFieldName).AsString;
          end
          else
          begin
            try
              ibsqlDocRealPos.CheckOpen;
            except
              ibsqlDocRealPos.ExecQuery;
            end;
            if (ibsqlDocRealPos.FieldByName(SourceFieldName).AsString = '')
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
              Value := ibsqlDocRealPos.FieldByName(SourceFieldName).AsString;
          end;
    aText := ReplaceSubStr(aText, Tmp, Value);
  end;

  R := atDatabase.FindRelationField(DestTableName, DestFieldName);
  if Assigned(R) and Assigned(R.Field) and not Assigned(R.References) and
     (R.Field.FieldType in [ftFloat, ftCurrency, ftBCD])
  then
  begin
    xFocal.Expression := aText;
    aText := FloatToStr(xFocal.Value);
  end;
  ListDemandField.Add(TDemandFieldInfo.Create(DestTableName, DestFieldName, aText));

end;

procedure SetTextDemandField;
begin
    with ibdsDemandPayment do
    begin
      /////////////////////////
      //  Данные по плательщику

      sqlCompanyData.Params.ByName('ID').AsInteger := IBLogin.CompanyKey;;
      sqlCompanyData.ExecQuery;

      FieldByName('OWNTAXID').AsString :=
        sqlCompanyData.FieldByName('TAXID').AsString;
      FieldByName('OWNCOUNTRY').AsString :=
        sqlCompanyData.FieldByName('COUNTRY').AsString;
      FieldByName('OWNCOMPTEXT').AsString :=
        sqlCompanyData.FieldByName('FULLNAME').AsString;

      sqlCompanyData.Close;

      sqlBankData.Params.ByName('ID').AsInteger := FAccount;
      sqlBankData.ExecQuery;
      FieldByName('OWNBANKTEXT').AsString :=
        sqlBankData.FieldByName('FULLNAME').AsString;
      FieldByName('OWNBANKCITY').AsString :=
        sqlBankData.FieldByName('CITY').AsString;
      FieldByName('OWNACCOUNT').AsString :=
        FAccountName;
      FieldByName('OWNACCOUNTCODE').AsString :=
        sqlBankData.FieldByName('BANKCODE').AsString;

      sqlBankData.Close;

      ///////////////////////
      // Данные по получателю



      sqlCompanyData.Params.ByName('ID').AsString := FieldByName('CORRCOMPANYKEY').AsString;
      sqlCompanyData.ExecQuery;
      FieldByName('CORRCOMPTEXT').AsString :=
        sqlCompanyData.FieldByName('FULLNAME').AsString;
      FieldByName('CORRTAXID').AsString :=
        sqlCompanyData.FieldByName('TAXID').AsString;
      FieldByName('CORRCOUNTRY').AsString :=
        sqlCompanyData.FieldByName('COUNTRY').AsString;

      sqlCompanyData.Close;
      if FieldByName('CARGOSENDER').AsString > '' then
      begin
        sqlCompanyData.ParamByName('ID').AsString := FieldByName('CARGOSENDER').AsString;
        sqlCompanyData.ExecQuery;

        FieldByName('CARGOSENDER').AsString := sqlCompanyData.FieldByName('FULLNAME').AsString;
        sqlCompanyData.Close;
      end;

      if FieldByName('CARGORECEIVER').AsString > '' then
      begin
        sqlCompanyData.ParamByName('ID').AsString := FieldByName('CARGORECEIVER').AsString;
        sqlCompanyData.ExecQuery;

        FieldByName('CARGORECEIVER').AsString := sqlCompanyData.FieldByName('FULLNAME').AsString;
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

      if ibdsDocument.FieldByName('DOCUMENTDATE').IsNull then
        ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime := SysUtils.Date;

    end;

end;

begin
  Result := False;
  F := GlobalStorage.OpenFolder('gp_DemandFormat');
  if Assigned(F) then
  try
    ListDemandField.Clear;

    ibsqlDocument.ParamByName('billkey').AsInteger := aCodeBill;
    ibsqlDocRealization.ParamByName('billkey').AsInteger := aCodeBill;
    ibsqlDocRealInfo.ParamByName('billkey').AsInteger := aCodeBill;
    ibsqlDocRealPos.ParamByName('billkey').AsInteger := aCodeBill;

    for i:= 0 to F.ValuesCount - 1 do
      MakeFormatText(F.Values[i].AsString);

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

    if ListDemandField.Count > 0 then
    begin
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
        ibsqlInsert.Prepare;
        ibsqlInsert.ParamByName('sk').AsInteger := aCodeBill;
        ibsqlInsert.ParamByName('dk').AsInteger := ibdsDocument.FieldByName('id').AsInteger;
        ibsqlInsert.ExecQuery;

        ibsqlInsert.Close;

        ibdsDocument.Post;
        ibdsDemandPayment.Post;


      except
        on E: Exception do
        begin
          MessageBox(HANDLE, PChar(Format('При создании требования возникла следующая ошибка - %s',
            [E.Message])), 'Внимание', mb_Ok or mb_IconInformation);
          if ibdsDemandPayment.State in [dsEdit, dsInsert] then
            ibdsDemandPayment.Cancel;
          if ibdsDocument.State in [dsEdit, dsInsert] then
            ibdsDocument.Cancel;
          exit;
        end;
      end;
    end;
  finally
    GlobalStorage.CloseFolder(F);
  end;
  Result := True;
end;

procedure TdlgMakeDemand.MakeTaxField;
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
      S := S + Format(', SUM(%0:s) as %0:s', [ibsql.FieldByName('fieldname').AsString]);
      ibsql.Next;
    end;
    ibsql.Close;
    if S > '' then
    begin
      S1 := ibsqlDocRealPos.SQL.Text;
      S1 := copy(S1, 1, Pos('/*', S1) - 1) + S + copy(S1, Pos('*/', S1) + 2, Length(S1));
      ibsqlDocRealPos.SQL.Text := S1;
    end;
  finally
    ibsql.Free;
  end;
end;

procedure TdlgMakeDemand.FormCreate(Sender: TObject);
begin
  ListDemandField := TObjectList.Create;

  Prepare;

  UserStorage.LoadComponent(gsibgrRealization, gsibgrRealization.LoadFromStream);
end;

procedure TdlgMakeDemand.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(gsibgrRealization, gsibgrRealization.LoadFromStream);

  if Assigned(ListDemandField) then
    FreeAndNil(ListDemandField);
end;

procedure TdlgMakeDemand.actRunExecute(Sender: TObject);
var
  i: Integer;
  isOK: Boolean;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  isOK := True;
  for i:= 0 to gsibgrRealization.CheckBox.CheckCount - 1 do
  begin
    isOK := MakeDemandForBill(gsibgrRealization.CheckBox.IntCheck[i], -1);
    if not isOk then Break;
  end;
  
  if isOk then
    IBTransaction.Commit
  else
    IBTransaction.RollBack;

  Prepare;  
end;

procedure TdlgMakeDemand.actFormatExecute(Sender: TObject);
begin
  with TdlgFormatDemand.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TdlgMakeDemand.Prepare;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  MakeTaxField;

  ibdsDocRealization.Open;

  ibsqlDocument.Prepare;
  ibsqlDocRealization.Prepare;
  ibsqlDocRealInfo.Prepare;
  ibsqlDocRealPos.Prepare;
end;

end.
