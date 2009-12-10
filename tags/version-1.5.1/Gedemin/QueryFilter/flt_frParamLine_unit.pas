unit flt_frParamLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, IBSQL, Mask;

type
  TfrParamLine = class(TFrame)
    lblName: TLabel;
    cbNull: TCheckBox;
    Bevel1: TBevel;
    procedure cbNullClick(Sender: TObject);

  private
    function GetAsCurrency: Currency;
    function GetAsDate: TDate;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Double;
    function GetAsInteger: Integer;
    function GetAsString: String;
    function GetAsTime: TTime;
    function GetIsNull: Boolean;
    procedure SetAsCurrency(const Value: Currency);
    procedure SetAsDate(const Value: TDate);
    procedure SetAsDateTime(const Value: TDateTime);
    procedure SetAsFloat(const Value: Double);
    procedure SetAsInteger(const Value: Integer);
    procedure SetAsString(const Value: String);
    procedure SetAsTime(const Value: TTime);
    procedure SetIsNull(const Value: Boolean);

  protected
    edValue: TCustomEdit;

    procedure InitParamType(Param: TIBXSQLVAR);

  public
    constructor Create(AnOwner: TComponent; Param: TIBXSQLVAR); reintroduce;

    property IsNull: Boolean read GetIsNull write SetIsNull;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsDate: TDate read GetAsDate write SetAsDate;
    property AsTime: TTime read GetAsTime write SetAsTime;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsString: String read GetAsString write SetAsString;
  end;

implementation

uses
  xDateEdits, IBHeader, xCalculatorEdit;

{$R *.DFM}

procedure TfrParamLine.InitParamType(Param: TIBXSQLVAR);
begin
  lblName.Caption := Param.Name;

  case Param.SQLType and (not 1) of
    SQL_SHORT, SQL_LONG:
    begin
      edValue := TxCalculatorEdit.Create(Self);
      if not Param.IsNull then
        TxCalculatorEdit(edValue).Value := Param.AsInteger;
    end;

    SQL_INT64:
    begin
      edValue := TxCalculatorEdit.Create(Self);
      if not Param.IsNull then
        TxCalculatorEdit(edValue).Value := Param.AsCurrency;
    end;

    SQL_DOUBLE, SQL_FLOAT, SQL_D_FLOAT:
    begin
      edValue := TxCalculatorEdit.Create(Self);
      if not Param.IsNull then
        TxCalculatorEdit(edValue).Value := Param.AsFloat;
    end;

    SQL_TYPE_DATE:
    begin
      edValue := TxDateEdit.Create(Self);
      TxDateEdit(edValue).Kind := kDate;
      if not Param.IsNull then
        TxDateEdit(edValue).Date := Param.AsDate;
    end;

    SQL_TYPE_TIME:
    begin
      edValue := TxDateEdit.Create(Self);
      TxDateEdit(edValue).Kind := kTime;
      if not Param.IsNull then
        TxDateEdit(edValue).Time := Param.AsTime;
    end;

    SQL_TIMESTAMP:
    begin
      edValue := TxDateEdit.Create(Self);
      TxDateEdit(edValue).Kind := kDateTime;
      if not Param.IsNull then
        TxDateEdit(edValue).DateTime := Param.AsDateTime;
    end;

  else
    begin
      edValue := TEdit.Create(Self);
      edValue.Width := 321;
      if not Param.IsNull then
        edValue.Text := Param.AsString;
    end;
  end;

  edValue.Parent   := Self;
  edValue.Left     := 192;
  edValue.Top      := 6;
  edValue.TabOrder := 1;

  cbNull.Checked := Param.IsNull;
  edValue.Visible := not Param.IsNull;
end;

procedure TfrParamLine.cbNullClick(Sender: TObject);
begin
  if Assigned(edValue) then
    edValue.Visible := not cbNull.Checked;
end;

constructor TfrParamLine.Create(AnOwner: TComponent; Param: TIBXSQLVAR);
begin
  inherited Create(AnOwner);
  InitParamType(Param);  
end;

function TfrParamLine.GetAsCurrency: Currency;
begin
  Result := AsFloat;
end;

function TfrParamLine.GetAsDate: TDate;
begin
  Result := (edValue as TxDateEdit).Date;
end;

function TfrParamLine.GetAsDateTime: TDateTime;
begin
  Result := (edValue as TxDateEdit).DateTime;
end;

function TfrParamLine.GetAsFloat: Double;
begin
  Result := (edValue as TxCalculatorEdit).Value;
end;

function TfrParamLine.GetAsInteger: Integer;
begin
  Result := Trunc(AsFloat);
end;

function TfrParamLine.GetAsString: String;
begin
  Result := edValue.Text;
end;

function TfrParamLine.GetAsTime: TTime;
begin
  Result := (edValue as TxDateEdit).Time;
end;

function TfrParamLine.GetIsNull: Boolean;
begin
  Result := cbNull.Checked;
end;

procedure TfrParamLine.SetAsCurrency(const Value: Currency);
begin
  AsFloat := Value;
end;

procedure TfrParamLine.SetAsDate(const Value: TDate);
begin
  (edValue as TxDateEdit).Date := Value;
end;

procedure TfrParamLine.SetAsDateTime(const Value: TDateTime);
begin
  (edValue as TxDateEdit).DateTime := Value;
end;

procedure TfrParamLine.SetAsFloat(const Value: Double);
begin
  (edValue as TxCalculatorEdit).Value := Value;
end;

procedure TfrParamLine.SetAsInteger(const Value: Integer);
begin
  AsFloat := Value;
end;

procedure TfrParamLine.SetAsString(const Value: String);
begin
  edValue.Text := Value;
end;

procedure TfrParamLine.SetAsTime(const Value: TTime);
begin
  (edValue as TxDateEdit).Time := Value;
end;

procedure TfrParamLine.SetIsNull(const Value: Boolean);
begin
  cbNull.Checked := Value;
  edValue.Visible := not cbNull.Checked;
end;

end.
