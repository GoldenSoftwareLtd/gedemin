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
    procedure edValueChange(Sender: TObject);
  private
    { Private declarations }
  public
    edValue: TCustomEdit;
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure InitParamType(Param: TIBXSQLVAR);
  end;

implementation

uses
  xDateEdits, IBHeader, xCalculatorEdit;

{$R *.DFM}

constructor TfrParamLine.Create(AnOwner: TComponent);
begin
  inherited;

end;

destructor TfrParamLine.Destroy;
begin

  inherited;
end;

procedure TfrParamLine.edValueChange(Sender: TObject);
begin
  cbNull.Checked := False;
end;

procedure TfrParamLine.InitParamType(Param: TIBXSQLVAR);
begin
  case Param.SQLType and (not 1) of
    SQL_SHORT, SQL_LONG, SQL_INT64, SQL_DOUBLE, SQL_FLOAT, SQL_D_FLOAT:
    begin
      edValue := TxCalculatorEdit.Create(Self);
      (edValue as TxCalculatorEdit).OnChange := edValueChange;
    end;
    SQL_TYPE_DATE, SQL_TYPE_TIME, SQL_TIMESTAMP:
    begin
      edValue := TxDateEdit.Create(Self);
      if Param.SQLType = SQL_TYPE_DATE then
        (edValue as TxDateEdit).Kind := kDate
      else if Param.SQLType = SQL_TYPE_TIME then
        (edValue as TxDateEdit).Kind := kTime
      else if Param.SQLType = SQL_TIMESTAMP then
        (edValue as TxDateEdit).Kind := kDateTime;
      (edValue as TxDateEdit).OnChange := edValueChange;
    end;
  else
    begin
      edValue := TEdit.Create(Self);
      edValue.Width := 321;
      (edValue as TEdit).OnChange := edValueChange;
    end;
  end;
  edValue.Parent   := Self;
  edValue.Text     := '';
  edValue.Left     := 192;
  edValue.Top      := 6;
  edValue.TabOrder := 0;
end;

end.
