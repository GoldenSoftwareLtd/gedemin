unit gdc_frmValueSel_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, ExtCtrls, IBDatabase;

type
  TfrmValueSel = class(TForm)
    pnlValue: TPanel;
    bvlSepar: TBevel;
    iblcValue: TgsIBLookupComboBox;
    pnlButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    IBTransaction: TIBTransaction;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmValueSel: TfrmValueSel;

implementation

 uses
   gdcBaseInterface;

{$R *.DFM}

procedure TfrmValueSel.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult = idOk) and (iblcValue.CurrentKeyInt = -1) then
  begin
    raise Exception.Create('Необходимо выбрать единицу измерения.');
  end;
end;

procedure TfrmValueSel.FormCreate(Sender: TObject);
begin
  IBTransaction.DefaultDatabase := gdcBaseManager.Database;
end;

end.
