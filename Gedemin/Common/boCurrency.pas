// ShlTanya, 24.02.2019

unit boCurrency;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security, Db, IBQuery, gdcBaseInterface;

type
  TboCurrency = class(TComponent)
  private
  protected
  public
    // Идентификатор НДЕ
    NCU: TID;
    // Идентификатор эквивалента
    Eq: TID;

    procedure LoadData;

    // Курс валюты относительно другой валюты на дату
    function GetRate(FromCurr, ToCurr: TID; Date: TDate): Double; overload;
    // Курс валюты относительно другой валюты на текущую дату
    function GetRate(FromCurr, ToCurr: TID): Double; overload;
    // Курс валюты относительно NCU на дату
    function GetRate(FromCurr: TID; Date: TDate): Double; overload;
    // Курс валюты относительно NCU на текущую дату
    function GetRate(FromCurr: TID): Double; overload;
    // Курс Eq относительно NCU на дату
    function GetRate(Date: TDate): Double; overload;
    // Курс Eq относительно NCU на текущую дату
    function GetRate: Double; overload;

    // Установка курса валюты относительно другой валюты на дату
    function SetRate(FromCurr, ToCurr: TID; Date: TDate; Rate: Double): Boolean; overload;
    // Установка курса валюты относительно другой валюты на текущую дату
    function SetRate(FromCurr, ToCurr: TID; Rate: Double): Boolean; overload;
    // Установка курса валюты относительно NCU на дату
    function SetRate(FromCurr: TID; Date: TDate; Rate: Double): Boolean; overload;
    // Установка курса валюты относительно NCU на текущую дату
    function SetRate(FromCurr: TID; Rate: Double): Boolean; overload;
    // Установка курса Eq относительно NCU на дату
    function SetRate(Date: TDate; Rate: Double): Boolean; overload;
    // Установка курса Eq относительно NCU на текущую дату
    function SetRate(Rate: Double): Boolean; overload;

  published
  end;

procedure Register;

implementation

uses
  IBSQL;

procedure TboCurrency.LoadData;
var
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;

    q.SQL.Text := 'SELECT id FROM gd_curr WHERE isncu <> 0';
    q.ExecQuery;
    if not q.EOF then
      NCU := GetTID(q.Fields[0])
    else
      NCU := -1;

    q.Close;
    q.SQL.Text := 'SELECT id FROM gd_curr WHERE iseq <> 0';
    q.ExecQuery;
    if not q.EOF then
      Eq := GetTID(q.Fields[0])
    else
      Eq := -1;
  finally
    q.Free;
  end;
end;

// Установка курса валюты относительно другой валюты на дату
function TboCurrency.SetRate(FromCurr, ToCurr: TID; Date: TDate; Rate: Double): Boolean;
var
  Q: TIBSQL;
begin
  if (IBLogin <> nil) and (IBLogin.DataBase <> nil) then
  begin
    Q := TIBSQL.Create(Self);
    try
      Q.DataBase := IBLogin.DataBase;
      try
        Q.SQL.Text :=
          ' INSERT INTO gd_currrate(fromcurr, tocurr, fordate, coeff) VALUES( ' +
          ':fromcurrkey, :tocurrkey, :fordate, :coef)';
        Q.Prepare;
        SetTID(Q.ParamByName('FromCurrKey'), FromCurr);
        SetTID(Q.ParamByName('ToCurrKey'), ToCurr);

        Q.ParamByName('fordate').AsDateTime := Date;
        Q.ParamByName('coef').AsCurrency := Rate;

        Q.ExecQuery;
        Result := True;
      except
        try
          Q.Close;
          Q.SQL.Text :=
            ' UPDATE gd_currrate SET coeff = :coeff ' +
            ' WHERE fromcurr = :FromCurrKey AND tocurr = :ToCurrKey AND fordate = :fordate ';
          Q.Prepare;
          SetTID(Q.ParamByName('FromCurrKey'), FromCurr);
          SetTID(Q.ParamByName('ToCurrKey'), ToCurr);

          Q.ParamByName('fordate').AsDateTime := Date;
          Q.ParamByName('coef').AsCurrency := Rate;

          Q.ExecQuery;
          Result := True;
        except
          Result := False;
        end;
      end;
    finally
      Q.Free;
    end;
  end
  else
    Result := False;
end;

// Установка курса валюты относительно другой валюты на текущую дату
function TboCurrency.SetRate(FromCurr, ToCurr: TID; Rate: Double): Boolean;
begin
  Result := SetRate(FromCurr, ToCurr, Rate, SysUtils.Date);
end;

// Установка курса валюты относительно NCU на дату
function TboCurrency.SetRate(FromCurr: TID; Date: TDate; Rate: Double): Boolean;
begin
  Result := SetRate(FromCurr, NCU, Date, Rate);
end;

// Установка курса валюты относительно NCU на текущую дату
function TboCurrency.SetRate(FromCurr: TID; Rate: Double): Boolean;
begin
  Result := SetRate(FromCurr, SysUtils.Date, Rate);
end;

// Установка курса Eq относительно NCU на дату
function TboCurrency.SetRate(Date: TDate; Rate: Double): Boolean;
begin
  Result := SetRate(Eq, Date, Rate);
end;

// Установка курса Eq относительно NCU на текущую дату
function TboCurrency.SetRate(Rate: Double): Boolean;
begin
  Result := SetRate(SysUtils.Date, Rate);
end;

// Курс валюты относительно другой валюты на дату
function TboCurrency.GetRate(FromCurr, ToCurr: TID; Date: TDate): Double;
var
  Q: TIBQuery;
begin
  if (IBLogin <> nil) and (IBLogin.DataBase <> nil) then
  begin
    Q := TIBQuery.Create(Self);
    try
      Q.DataBase := IBLogin.DataBase;
      Q.SQL.Text :=
        ' SELECT crt.coeff FROM gd_currrate crt WHERE crt.fromcurr = :FromCurrKey AND crt.tocurr = :ToCurrKey AND ' +
        ' crt.fordate = (SELECT MAX(crt2.fordate) FROM gd_currrate crt2 WHERE crt2.fromcurr = :FromCurrKey AND crt2.tocurr = :ToCurrKey) ';
      SetTID(Q.ParamByName('FromCurrKey'), FromCurr);
      SetTID(Q.ParamByName('ToCurrKey'), ToCurr);
      Q.Prepare;
      Q.Open;
      if Q.RecordCount > 0 then
        Result := Q.FieldByName('coeff').AsFloat
      else
        Result := 0;
    finally
      Q.Free;
    end;
  end
  else
    Result := -1;
end;

// Курс валюты относительно другой валюты на текущую дату
function TboCurrency.GetRate(FromCurr, ToCurr: TID): Double;
begin
  Result := GetRate(FromCurr, ToCurr, SysUtils.Date);
end;

// Курс валюты относительно NCU на дату
function TboCurrency.GetRate(FromCurr: TID; Date: TDate): Double;
begin
  Result := GetRate(FromCurr, NCU, Date);
end;

// Курс валюты относительно NCU на текущую дату
function TboCurrency.GetRate(FromCurr: TID): Double;
begin
  Result := GetRate(FromCurr, SysUtils.Date);
end;

// Курс Eq относительно NCU на дату
function TboCurrency.GetRate(Date: TDate): Double;
begin
  Result := GetRate(Eq, Date);
end;

// Курс Eq относительно NCU на текущую дату
function TboCurrency.GetRate: Double;
begin
  Result := GetRate(SysUtils.Date);
end;

procedure Register;
begin
  RegisterComponents('gsNV', [TboCurrency]);
end;

end.
 