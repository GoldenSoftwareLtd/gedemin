
unit boCurrency;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security, Db, IBQuery;

type
  TboCurrency = class(TComponent)
  private
  protected
  public
    // ������������� ���
    NCU: Integer;
    // ������������� �����������
    Eq: Integer;

    procedure LoadData;

    // ���� ������ ������������ ������ ������ �� ����
    function GetRate(FromCurr, ToCurr: Integer; Date: TDate): Double; overload;
    // ���� ������ ������������ ������ ������ �� ������� ����
    function GetRate(FromCurr, ToCurr: Integer): Double; overload;
    // ���� ������ ������������ NCU �� ����
    function GetRate(FromCurr: Integer; Date: TDate): Double; overload;
    // ���� ������ ������������ NCU �� ������� ����
    function GetRate(FromCurr: Integer): Double; overload;
    // ���� Eq ������������ NCU �� ����
    function GetRate(Date: TDate): Double; overload;
    // ���� Eq ������������ NCU �� ������� ����
    function GetRate: Double; overload;

    // ��������� ����� ������ ������������ ������ ������ �� ����
    function SetRate(FromCurr, ToCurr: Integer; Date: TDate; Rate: Double): Boolean; overload;
    // ��������� ����� ������ ������������ ������ ������ �� ������� ����
    function SetRate(FromCurr, ToCurr: Integer; Rate: Double): Boolean; overload;
    // ��������� ����� ������ ������������ NCU �� ����
    function SetRate(FromCurr: Integer; Date: TDate; Rate: Double): Boolean; overload;
    // ��������� ����� ������ ������������ NCU �� ������� ����
    function SetRate(FromCurr: Integer; Rate: Double): Boolean; overload;
    // ��������� ����� Eq ������������ NCU �� ����
    function SetRate(Date: TDate; Rate: Double): Boolean; overload;
    // ��������� ����� Eq ������������ NCU �� ������� ����
    function SetRate(Rate: Double): Boolean; overload;

  published
  end;

procedure Register;

implementation

uses
  IBSQL;

procedure TboCurrency.LoadData;
var
  Q: TIBQuery;
begin
  if (IBLogin <> nil) and (IBLogin.DataBase <> nil) then
  begin
    NCU := -1;
    Eq := -1;
    Q := TIBQuery.Create(Self);
    try
      Q.DataBase := IBLogin.DataBase;
      Q.SQL.Text := ' SELECT c.id, c.isncu, c.iseq FROM gd_curr c WHERE c.isncu = 1 OR c.isEq = 1';
      Q.Open;
      while not Q.Eof do
      begin
        if Q.FieldByName('isNCU').AsInteger = 1 then
          NCU := Q.FieldByName('id').AsInteger
        else
          if Q.FieldByName('isEq').AsInteger = 1 then
            Eq := Q.FieldByName('id').AsInteger;
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  end;
end;

// ��������� ����� ������ ������������ ������ ������ �� ����
function TboCurrency.SetRate(FromCurr, ToCurr: Integer; Date: TDate; Rate: Double): Boolean;
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
        Q.ParamByName('FromCurrKey').AsInteger := FromCurr;
        Q.ParamByName('ToCurrKey').AsInteger := ToCurr;

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
          Q.ParamByName('FromCurrKey').AsInteger := FromCurr;
          Q.ParamByName('ToCurrKey').AsInteger := ToCurr;

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

// ��������� ����� ������ ������������ ������ ������ �� ������� ����
function TboCurrency.SetRate(FromCurr, ToCurr: Integer; Rate: Double): Boolean;
begin
  Result := SetRate(FromCurr, ToCurr, Rate, SysUtils.Date);
end;

// ��������� ����� ������ ������������ NCU �� ����
function TboCurrency.SetRate(FromCurr: Integer; Date: TDate; Rate: Double): Boolean;
begin
  Result := SetRate(FromCurr, NCU, Date, Rate);
end;

// ��������� ����� ������ ������������ NCU �� ������� ����
function TboCurrency.SetRate(FromCurr: Integer; Rate: Double): Boolean;
begin
  Result := SetRate(FromCurr, SysUtils.Date, Rate);
end;

// ��������� ����� Eq ������������ NCU �� ����
function TboCurrency.SetRate(Date: TDate; Rate: Double): Boolean;
begin
  Result := SetRate(Eq, Date, Rate);
end;

// ��������� ����� Eq ������������ NCU �� ������� ����
function TboCurrency.SetRate(Rate: Double): Boolean;
begin
  Result := SetRate(SysUtils.Date, Rate);
end;

// ���� ������ ������������ ������ ������ �� ����
function TboCurrency.GetRate(FromCurr, ToCurr: Integer; Date: TDate): Double;
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
      Q.ParamByName('FromCurrKey').AsInteger := FromCurr;
      Q.ParamByName('ToCurrKey').AsInteger := ToCurr;
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

// ���� ������ ������������ ������ ������ �� ������� ����
function TboCurrency.GetRate(FromCurr, ToCurr: Integer): Double;
begin
  Result := GetRate(FromCurr, ToCurr, SysUtils.Date);
end;

// ���� ������ ������������ NCU �� ����
function TboCurrency.GetRate(FromCurr: Integer; Date: TDate): Double;
begin
  Result := GetRate(FromCurr, NCU, Date);
end;

// ���� ������ ������������ NCU �� ������� ����
function TboCurrency.GetRate(FromCurr: Integer): Double;
begin
  Result := GetRate(FromCurr, SysUtils.Date);
end;

// ���� Eq ������������ NCU �� ����
function TboCurrency.GetRate(Date: TDate): Double;
begin
  Result := GetRate(Eq, Date);
end;

// ���� Eq ������������ NCU �� ������� ����
function TboCurrency.GetRate: Double;
begin
  Result := GetRate(SysUtils.Date);
end;

procedure Register;
begin
  RegisterComponents('gsNV', [TboCurrency]);
end;

end.
 