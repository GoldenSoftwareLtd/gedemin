// ShlTanya, 17.02.2019

unit gsDocNumerator;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDataBase, DB, IBSQL, gdcBaseInterface;

type
  TgsDocNumerator = class;

  TgsDataLinkDocNumerator = class(TDataLink)
  private
    FgsDocNumerator: TgsDocNumerator;

  protected
    procedure EditingChanged; override;
    procedure ActiveChanged; override;

  public
    constructor Create(AgsDocNumerator: TgsDocNumerator);
  end;

  TgsDocNumerator = class(TComponent)
  private
    FDatabase: TIBDataBase;
    FDocumentType: TID;
    FDataLink: TgsDataLinkDocNumerator;
    FLastNumber: Integer;
    FAddNumber: Integer;
    OldBeforeCancel: TDataSetNotifyEvent;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetDataSource(const Value: TDataSource);
    function GetDataSource: TDataSource;
    procedure EditingChanged;
    procedure ActiveChanged;
    procedure SetValues;
    procedure EditValues;
    procedure DoBeforeCancel(DataSet: TDataSet);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function GetNewNumber: String;

  published
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DocumentType: TID read FDocumentType write FDocumentType;
  end;

var
  MonthNames: array[1..12] of String = (
    '€нварь',
    'февраль',
    'март',
    'апрель',
    'май',
    'июнь',
    'июль',
    'август',
    'сент€брь',
    'окт€брь',
    'но€брь',
    'декабрь'
  );


procedure Register;

implementation

{TgsDataLinkDocNumerator ----------------------------------}

uses
  gd_security;

procedure TgsDataLinkDocNumerator.EditingChanged;
begin
  if Assigned(FgsDocNumerator) then
    FgsDocNumerator.EditingChanged;
end;

procedure TgsDataLinkDocNumerator.ActiveChanged;
begin
  if Assigned(FgsDocNumerator) then
    FgsDocNumerator.ActiveChanged;
end;


constructor TgsDataLinkDocNumerator.Create(AgsDocNumerator: TgsDocNumerator);
begin
  inherited Create;
  FgsDocNumerator := AgsDocNumerator;
  VisualControl := False;
end;

{TgsDocNumerator -----------------------------------------}

constructor TgsDocNumerator.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FDataLink := TgsDataLinkDocNumerator.Create(Self);
  FDataBase := nil;
  FDocumentType := 0;
  FLastNumber := 0;
end;

destructor TgsDocNumerator.Destroy;
begin
  FDataLink.Free;
  inherited Destroy;
end;

procedure TgsDocNumerator.Loaded;
begin
  inherited;
  if (not (csDesigning in ComponentState)) and (FDataLink.DataSet <> nil) then
  begin
    OldBeforeCancel := FDataLink.DataSet.BeforeCancel;
    FDataLink.DataSet.BeforeCancel := DoBeforeCancel;
  end;
end;



procedure TgsDocNumerator.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = FDatabase then
      FDatabase := nil
  end;
end;

function TgsDocNumerator.GetNewNumber: String;
var
  ibsql: TIBSQL;
  Transaction: TIBTransaction;
  Mask: String;
  Year, Month, Day: Word;
  C: array [0..255] of Char;
  I: DWord;
  S: String;
  F: Integer;

  function GetNumber: String;

    procedure StrReplace(var Source: String; const SubStr, ToStr: String);
    var
      K: Integer;
    begin
      if Pos(SubStr, ToStr) = 0 then
        while True do
        begin
          K := Pos(SubStr, Source);
          if K = 0 then
            exit;
          Delete(Source, K, Length(SubStr));
          Insert(ToStr, Source, K);
        end;
    end;

  begin
    if Mask = '' then
      Result := IntToStr(FLastNumber)
    else
    begin
      S := Mask;
      StrReplace(S, '"NUMBER"', IntToStr(FLastNumber));

      DecodeDate(SysUtils.Date, Year, Month, Day);
      StrReplace(S, '"DAY"', IntToStr(Day));
      StrReplace(S, '"MONTH"', IntToStr(Month));
      StrReplace(S, '"YEAR"', IntToStr(Year));
      StrReplace(S, '"MONTHSTR"', MonthNames[Month]);
      StrReplace(S, '"YEAR"', IntToStr(Year));
      I := MAX_COMPUTERNAME_LENGTH + 1;
      GetComputerName(@C, I);
      StrReplace(S, '"COMPUTER"', StrPas(C));
      StrReplace(S, '"OPERATOR"', IBLogin.UserName);
      Result := S;
    end;
  end;

begin
  Assert(FDataBase <> nil);
  Assert(FDocumentType <> 0);
  Assert(FDataLink.DataSet.FindField('NUMBER') <> nil);
  Assert(IBLogin <> nil);

  F := 5;
  repeat
    ibsql := TIBSQL.Create(Self);
    Transaction := TIBTransaction.Create(Self);
    try
      Transaction.DefaultDatabase := FDataBase;
      ibsql.DataBase := FDataBase;
      ibsql.Transaction := Transaction;
      Transaction.StartTransaction;

      try
        ibsql.SQL.Text := Format(
          ' SELECT * FROM GD_LASTNUMBER WHERE documenttypekey = %d AND ' +
          ' ourcompanykey = %d ', [TID264(FDocumentType), TID264(IBLogin.CompanyKey)]);
        ibsql.ExecQuery;

        if ibsql.RecordCount > 0 then
        begin
          if ibsql.FieldByName('disabled').AsInteger <> 1 then
          begin
            FLastNumber := ibsql.FieldByName('lastnumber').AsInteger;
            FAddNumber := ibsql.FieldByName('addnumber').AsInteger;
            Mask := ibsql.FieldByName('mask').AsString;
            try
              ibsql.Close;
              ibsql.SQL.Text := Format(
                ' UPDATE GD_LASTNUMBER SET lastnumber = %d WHERE ' +
                ' documenttypekey = %d AND ourcompanykey = %d ',
                [FLastNumber + FAddNumber, TID264(FDocumentType), TID264(IBLogin.CompanyKey)]);
              ibsql.ExecQuery;
              Result := GetNumber;
              FLastNumber := FLastNumber + FAddNumber;
            except
              FLastNumber := 0;
            end;
          end;
        end
        else
        begin
          try
            ibsql.Close;
            ibsql.SQL.Text := Format(
              ' INSERT INTO GD_LASTNUMBER(documenttypekey, ourcompanykey, ' +
              ' lastnumber, addnumber, disabled) VALUES (%d, %d, 2, 1, 0) ',
              [TID264(FDocumentType), TID264(IBLogin.CompanyKey)]);
            ibsql.ExecQuery;
            Result := '1';
            FAddNumber := 1;
            FLastNumber := 2;
          except
            FLastNumber := 0;
          end;
        end;

        Transaction.Commit;
        F := 0;
      except
        Transaction.Rollback;
        Dec(F);
        Sleep(1000);
      end;

    finally
      ibsql.Free;
      Transaction.Free;
    end;
  until F = 0;
end;

procedure TgsDocNumerator.SetValues;
begin
  Assert(FDataBase <> nil);
  Assert(FDocumentType <> 0);
  Assert(FDataLink.DataSet.FindField('NUMBER') <> nil);
  Assert(IBLogin <> nil);

  FDataLink.DataSet.FieldByName('NUMBER').AsString := GetNewNumber;
  SetTID(FDataLink.DataSet.FieldByName('DocumentTypeKey'), FDocumentType);

  FDataLink.DataSet.FieldByName('documentdate').AsDateTime :=
    SysUtils.Date;

  FDataLink.DataSet.FieldByName('afull').AsInteger := -1;
  FDataLink.DataSet.FieldByName('achag').AsInteger := -1;
  FDataLink.DataSet.FieldByName('aview').AsInteger := -1;

  SetTID(FDataLink.DataSet.FieldByName('creatorkey'), IBLogin.ContactKey);
  FDataLink.DataSet.FieldByName('creationdate').AsDateTime :=
    SysUtils.Date;
  SetTID(FDataLink.DataSet.FieldByName('editorkey'), IBLogin.ContactKey);
  FDataLink.DataSet.FieldByName('editiondate').AsDateTime :=
    SysUtils.Date;
  FDataLink.DataSet.FieldByName('disabled').AsInteger := 0;
  SetTID(FDataLink.DataSet.FieldByName('companykey'), IBLogin.CompanyKey);
end;

procedure TgsDocNumerator.EditValues;
begin
  Assert(FDataBase <> nil);
  Assert(FDocumentType <> 0);
  Assert(FDataLink.DataSet.FindField('NUMBER') <> nil);
  Assert(IBLogin <> nil);

  SetTID(FDataLink.DataSet.FieldByName('editorkey'), IBLogin.ContactKey);
  FDataLink.DataSet.FieldByName('editiondate').AsDateTime :=
    SysUtils.Date;
end;

procedure TgsDocNumerator.DoBeforeCancel(DataSet: TDataSet);
var
  ibsql: TIBSQL;
  Transaction: TIBTransaction;

begin
  if Assigned(OldBeforeCancel) then
    OldBeforeCancel(DataSet);

  Assert(FDataBase <> nil);
  Assert(FDocumentType <> 0);
  Assert(FDataLink.DataSet.FindField('NUMBER') <> nil);
  Assert(IBLogin <> nil);

  if FLastNumber <> 0 then
  begin
    ibsql := TIBSQL.Create(Self);
    Transaction := TIBTransaction.Create(Self);
    try
      Transaction.DefaultDatabase := FDataBase;
      ibsql.DataBase := FDataBase;
      ibsql.Transaction := Transaction;
      Transaction.StartTransaction;

      ibsql.SQL.Text := Format(
        ' SELECT * FROM GD_LASTNUMBER WHERE documenttypekey = %d AND ' +
        ' ourcompanykey = %d ', [TID264(FDocumentType), TID264(IBLogin.CompanyKey)]);
      ibsql.ExecQuery;

      if (ibsql.RecordCount > 0) and
         (ibsql.FieldByName('lastnumber').AsInteger = FLastNumber) then
      begin
        ibsql.Close;
        ibsql.SQL.Text := Format(
          ' UPDATE GD_LASTNUMBER SET lastnumber = %d WHERE ' +
          ' documenttypekey = %d AND ourcompanykey = %d ',
          [FLastNumber - FAddNumber, TID264(FDocumentType), TID264(IBLogin.CompanyKey)]);
        ibsql.ExecQuery;
        Transaction.Commit;
        FLastNumber := 0;
      end;
    finally
      ibsql.Free;
      Transaction.Free;
    end;
  end;
end;

procedure TgsDocNumerator.ActiveChanged;
begin
{  if FDataLink.Active and FDataLink.DataSet.Active and
    not Assigned(OldBeforeCancel) then
  begin
    OldBeforeCancel := FDataLink.DataSet.BeforeCancel;
    FDataLink.DataSet.BeforeCancel := DoBeforeCancel;
  end;}
end;

procedure TgsDocNumerator.EditingChanged;
begin
  FLastNumber := 0;

  if FDataLink.DataSet.State in [dsInsert] then
    SetValues;

  if FDataLink.DataSet.State in [dsEdit] then
    EditValues;
end;

procedure TgsDocNumerator.SetDataSource(const Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TgsDocNumerator.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TgsDocNumerator.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if Assigned(FDatabase) then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsDocNumerator]);
end;

end.

