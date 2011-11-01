unit rp_frmParamLine_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmParamLine = class(TFrame)
    lblParamName: TLabel;
    Panel1: TPanel;
    cbType: TComboBox;
    edValue: TEdit;
  private
    { Private declarations }
  public
  end;

implementation

{$R *.DFM}

end.
