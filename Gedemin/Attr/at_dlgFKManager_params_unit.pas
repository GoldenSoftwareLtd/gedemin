// ShlTanya, 02.02.2019

unit at_dlgFKManager_params_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, xCalculatorEdit;

type
  Tat_dlgFKManager_params = class(TForm)
    Label1: TLabel;
    xceMinRecCount: TxCalculatorEdit;
    Label2: TLabel;
    xceMaxUqCount: TxCalculatorEdit;
    chbxDontProcessCyclicRef: TCheckBox;
    Label3: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  at_dlgFKManager_params: Tat_dlgFKManager_params;

implementation

{$R *.DFM}

end.
