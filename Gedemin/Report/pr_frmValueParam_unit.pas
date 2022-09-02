// ShlTanya, 27.02.2019

unit pr_frmValueParam_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TfrmValueParam = class(TFrame)
    lblName: TLabel;
    edValue: TEdit;
    Bevel1: TBevel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

end.
