unit Test_gdScriptFactory;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdScriptFactory, StdCtrls, rp_BaseReport_unit, gd_i_ScriptFactory, Mask, gd_ScriptFactory;

type
  TForm1 = class(TForm)
    btnExecute: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Edit4: TEdit;
    procedure btnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
//    TestInter: IgdScriptFactory;
    { Private declarations }
  public
    { Public declarations }
  end;

var Form1: TForm1;
implementation

{$R *.DFM}

procedure TForm1.btnExecuteClick(Sender: TObject);
var
  AFunction: TrpCustomFunction;
  AParamAndResult: Variant;
  str: integer;
begin                            
  AFunction := TrpCustomFunction.Create;
  str := StrToInt(Edit1.Text);
  AFunction.FunctionKey := StrToInt(Edit1.Text);
//  AFunction.ModifyDate := StrToDate(MaskEdit1.Text);
// VarArrayCreate(const Bounds: array of Integer; VarType: Integer): Variant;
  AParamAndResult := VarArrayCreate([1, 3], varVariant);
  AParamAndResult[1] := StrToInt(Edit2.Text);
  AParamAndResult[2] := Edit3.Text;
  AParamAndResult[3] := StrToInt(Edit4.Text);
  ScriptFactory.ExecuteFunction(AFunction, AParamAndResult);
end;

procedure TForm1.FormCreate(Sender: TObject);
var rr: TgbScriptFactory;
begin
  rr := TgbScriptFactory.Create(Nil);

end;

end.
