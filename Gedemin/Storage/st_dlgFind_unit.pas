// ShlTanya, 12.03.2019

unit st_dlgFind_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, gd_createable_form, Mask, xDateEdits,
  ExtCtrls;

type
  Tst_dlgFind = class(TCreateableForm)
    Label1: TLabel;
    edFindText: TEdit;
    gbView: TGroupBox;
    cbFolder: TCheckBox;
    cbValue: TCheckBox;
    cbData: TCheckBox;
    btnFind: TButton;
    btnClose: TButton;
    xdeFrom: TxDateEdit;
    xdeTo: TxDateEdit;
    cbDate: TCheckBox;
    Label2: TLabel;
    rgSetting: TRadioGroup;
    procedure cbDateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  st_dlgFind: Tst_dlgFind;

implementation

{$R *.DFM}

procedure Tst_dlgFind.cbDateClick(Sender: TObject);
begin
  xdeFrom.Enabled := cbDate.Checked;
  xdeTo.Enabled := cbDate.Checked;
end;

procedure Tst_dlgFind.FormCreate(Sender: TObject);
begin
  xdeFrom.Enabled := cbDate.Checked;
  xdeTo.Enabled := cbDate.Checked;
end;

end.
