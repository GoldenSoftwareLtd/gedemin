unit tr_dlgAccountInfo_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, Mask, xDateEdits,  FrmPlSvr;

type
  TdlgAccountInfo = class(TForm)
    Label1: TLabel;
    gsiblcAccount: TgsIBLookupComboBox;
    Label2: TLabel;
    xdeDateBegin: TxDateEdit;
    Label3: TLabel;
    xdeDateEnd: TxDateEdit;
    bOk: TButton;
    Button2: TButton;
    FormPlaceSaver: TFormPlaceSaver;
    procedure gsiblcAccountChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgAccountInfo: TdlgAccountInfo;

implementation

{$R *.DFM}

procedure TdlgAccountInfo.gsiblcAccountChange(Sender: TObject);
begin
  bOk.Enabled := gsiblcAccount.CurrentKey > '';
end;

end.
