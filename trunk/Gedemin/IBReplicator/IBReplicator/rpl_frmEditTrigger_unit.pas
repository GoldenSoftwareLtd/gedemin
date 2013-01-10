unit rpl_frmEditTrigger_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPButton, StdCtrls, XPEdit, ExtCtrls;

type
  TfrmEditTrigger = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtName: TXPEdit;
    edtRelation: TXPEdit;
    edtType: TXPEdit;
    Bevel2: TBevel;
    memTriggerBody: TXPMemo;
    Bevel1: TBevel;
    bExit: TXPButton;
    bNext: TXPButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditTrigger: TfrmEditTrigger;

implementation

{$R *.dfm}

end.
