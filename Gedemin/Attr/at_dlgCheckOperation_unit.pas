unit at_dlgCheckOperation_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgCheckOperation = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lLoadRecords: TLabel;
    cbAlwaysOverwrite: TCheckBox;
    cbDontRemove: TCheckBox;
    Panel3: TPanel;
    lSaveRecords: TLabel;
    cbIncVersion: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
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
