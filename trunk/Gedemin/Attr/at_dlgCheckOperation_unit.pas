unit at_dlgCheckOperation_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgCheckOperation = class(TForm)
    pnlWorkArea: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    lLoadRecords: TLabel;
    cbAlwaysOverwrite: TCheckBox;
    cbDontRemove: TCheckBox;
    Memo1: TMemo;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Memo2: TMemo;
    lSaveRecords: TLabel;
    cbIncVersion: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgCheckOperation: TdlgCheckOperation;

implementation

{$R *.DFM}

end.
