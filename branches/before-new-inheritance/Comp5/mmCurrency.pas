unit mmCurrency;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, 
  dbTables, xMsgBox;

const
  DefDataBaseName = 'GBASE';
  DefCurrTableName = 'fin_curr';
  DefCurrRateTableName = 'fin_currrate';

type
  TmmCurrency = class(TComponent)
  private
    FDataBaseName: String;
    FCurrTableName: String;
    FCurrRateTableName: String;
    
  protected
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function AddCurr: Boolean;
    function EditCurr(CurrKey: Integer): Boolean;
    function DeleteCurr(CurrKey: Integer): Boolean;
    
    function AddCurrRate(FromCurr, ToCurr: Integer): Boolean;
    function EditCurrRate(FromCurr, ToCurr: Integer; Date: TDate): Boolean;
    function DeleteCurrRate(FromCurr, ToCurr: Integer; Date: TDate): Boolean;
    
  published
    property DataBaseName: String read FDataBaseName write FDataBaseName;
    property CurrTableName: String read FCurrTableName write FCurrTableName;
    property CurrRateTableName: String read FCurrRateTableName write FCurrRateTableName;
  end;
  
  ExCurrError = class(Exception);

procedure Register;

var
  mmCurr: TmmCurrency;

implementation

uses
  dlgCurr_unit, dlgCurrRate_unit;

constructor TmmCurrency.Create(AnOwner: TComponent); 
begin
  inherited Create(AnOwner);
  if Assigned(mmCurr) then
    raise ExCurrError.Create('Only one instance of TmmCurrency allowed');
  FDataBaseName := DefDataBaseName;
  FCurrTableName := DefCurrTableName;
  FCurrRateTableName := DefCurrRateTableName;
  
  mmCurr := Self;
end;

destructor TmmCurrency.Destroy; 
begin
  mmCurr := nil;
  inherited Destroy;           
end;

function TmmCurrency.AddCurr: Boolean;
var
  dlgCurr: TdlgCurr;
begin
  dlgCurr := TdlgCurr.Create(Application);
  try
    dlgCurr.tblCurr.DataBaseName := FDataBaseName;
    dlgCurr.tblCurr.TableName := FCurrTableName;
    dlgCurr.tblCurr.Open;
    dlgCurr.tblCurr.Append;
    Result := dlgCurr.ShowModal = mrOk;
  finally
    dlgCurr.Free;
  end;
end;

function TmmCurrency.EditCurr(CurrKey: Integer): Boolean;
var
  dlgCurr: TdlgCurr;
begin
  dlgCurr := TdlgCurr.Create(Application);
  try
    dlgCurr.tblCurr.DataBaseName := FDataBaseName;
    dlgCurr.tblCurr.TableName := FCurrTableName;
    dlgCurr.tblCurr.Open;
    if dlgCurr.tblCurr.FindKey([Currkey]) then
    begin
      dlgCurr.tblCurr.Edit;
      dlgCurr.cbPlace.ItemIndex := 
        dlgCurr.tblCurr.FieldByName('place').AsInteger;
      dlgCurr.mmcbDisabled.Checked := dlgCurr.tblCurr.FieldByName('disabled').AsInteger = 1;
      dlgCurr.mmcbIsncu.Checked := dlgCurr.tblCurr.FieldByName('isncu').AsInteger = 1;
      Result := dlgCurr.ShowModal = mrOk;
    end
    else
      Result := False;
  finally
    dlgCurr.Free;
  end;
end;

function TmmCurrency.DeleteCurr(CurrKey: Integer): Boolean;
var
  tblCurr: TTable;
begin
  Result := False;
  if MessageBox(Application.Handle, 'Удалить валюту?', 'Внимание!', MB_ICONQUESTION + MB_YESNO) = mrYes then
  begin
    tblCurr := TTable.Create(Self);
    try
      tblCurr.DataBaseName := FDataBaseName;
      tblCurr.TableName := FCurrTableName;
      tblCurr.Open;
      if tblCurr.FindKey([Currkey]) then
      begin
        try
          tblCurr.Delete;
          Result := True;
        except
          raise ExCurrError.Create('Валюта уже где-то используется...');
        end;
      end;
    finally
      tblCurr.Free;
    end;
  end;
end;

function TmmCurrency.AddCurrRate(FromCurr, ToCurr: Integer): Boolean;
var
  dlgCurrRate: TdlgCurrRate;
begin
  dlgCurrRate := TdlgCurrRate.Create(Application);
  try
    dlgCurrRate.tblFromCurr.DataBaseName := FDataBaseName;
    dlgCurrRate.tblToCurr.DataBaseName := FDataBaseName;
    dlgCurrRate.tblCurrRate.DataBaseName := FDataBaseName;
    dlgCurrRate.tblFromCurr.TableName := FCurrTableName;
    dlgCurrRate.tblToCurr.TableName := FCurrTableName;
    dlgCurrRate.tblCurrRate.TableName := FCurrRateTableName;
    dlgCurrRate.tblFromCurr.Open;
    dlgCurrRate.tblToCurr.Open;
    dlgCurrRate.tblCurrRate.Open;
    dlgCurrRate.tblCurrRate.Append;
    if dlgCurrRate.tblFromCurr.FindKey([FromCurr]) then 
      dlgCurrRate.tblCurrRate.FieldByName('FromCurr').AsInteger := FromCurr;
    if dlgCurrRate.tblToCurr.FindKey([ToCurr]) then 
      dlgCurrRate.tblCurrRate.FieldByName('ToCurr').AsInteger := ToCurr;
    dlgCurrRate.tblCurrRate.FieldByName('fordate').AsDateTime := Sysutils.Date;
    Result := dlgCurrRate.ShowModal = mrOk;
  finally
    dlgCurrRate.Free;
  end;
end;

function TmmCurrency.EditCurrRate(FromCurr, ToCurr: Integer; Date: TDate): Boolean;
var
  dlgCurrRate: TdlgCurrRate;
begin
  dlgCurrRate := TdlgCurrRate.Create(Application);
  try
    dlgCurrRate.tblFromCurr.DataBaseName := FDataBaseName;
    dlgCurrRate.tblToCurr.DataBaseName := FDataBaseName;
    dlgCurrRate.tblCurrRate.DataBaseName := FDataBaseName;
    dlgCurrRate.tblFromCurr.TableName := FCurrTableName;
    dlgCurrRate.tblToCurr.TableName := FCurrTableName;
    dlgCurrRate.tblCurrRate.TableName := FCurrRateTableName;
    dlgCurrRate.tblCurrRate.IndexFieldNames := 'fromcurr;tocurr;fordate';
    dlgCurrRate.tblFromCurr.Open;
    dlgCurrRate.tblToCurr.Open;
    dlgCurrRate.tblCurrRate.Open;
    if dlgCurrRate.tblCurrRate.FindKey([fromcurr, tocurr, Date]) then
    begin
      dlgCurrRate.tblCurrRate.Edit;
      Result := dlgCurrRate.ShowModal = mrOk;
    end
    else
      Result := False;
  finally
    dlgCurrRate.Free;
  end;
end;

function TmmCurrency.DeleteCurrRate(FromCurr, ToCurr: Integer; Date: TDate): Boolean;
var
  tblCurrRate: TTable;
begin
  Result := False;
  tblCurrRate := TTable.Create(Self);
  try
    tblCurrRate.DataBaseName := FDataBaseName;
    tblCurrRate.TableName := FCurrRateTableName;
    tblCurrRate.IndexFieldNames := 'fromcurr;tocurr;fordate';
    tblCurrRate.Open;
    if tblCurrRate.FindKey([fromcurr, tocurr, Date]) and
    (MessageBox(Application.Handle, 'Удалить курс?', 'Внимание!', MB_ICONQUESTION + MB_YESNO) = mrYes) then
    begin
      tblCurrRate.Delete;
      Result := True;
    end;
  finally
    tblCurrRate.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('x-Finance', [TmmCurrency]);
end;

initialization

  mmCurr := nil;

finalization

  if Assigned(mmCurr) then
  begin
    mmCurr.Free;
    mmCurr := nil;
  end;


end.
 