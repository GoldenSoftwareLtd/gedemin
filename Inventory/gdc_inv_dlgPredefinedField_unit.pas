unit gdc_inv_dlgPredefinedField_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gd_createable_form;

type
  Tgdc_inv_dlgPredefinedField = class(TCreateableForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    cbPriceNCU: TCheckBox;
    cbPriceCurr: TCheckBox;
    cbVAT: TCheckBox;
    cbPriceVAT: TCheckBox;
    cbPriceVATCurr: TCheckBox;
    cbPerc: TCheckBox;
    cbOtherTax: TCheckBox;
    edOtherTax: TEdit;
    GroupBox2: TGroupBox;
    cbAmountNCU: TCheckBox;
    cbAmountCURR: TCheckBox;
    cbAmountVAT: TCheckBox;
    cbAmountVATCurr: TCheckBox;
    cbAmountWithVAT: TCheckBox;
    cbAmountWithVATCurr: TCheckBox;
    cbAmountOtherTax: TCheckBox;
    Label1: TLabel;
    edPrefix: TEdit;
    procedure cbOtherTaxClick(Sender: TObject);
  private
    function GetPrefix: String;
    { Private declarations }
  public
    { Public declarations }
    property Prefix: String read GetPrefix; 
  end;

var
  gdc_inv_dlgPredefinedField: Tgdc_inv_dlgPredefinedField;

implementation

{$R *.DFM}

procedure Tgdc_inv_dlgPredefinedField.cbOtherTaxClick(Sender: TObject);
begin
  edOtherTax.Enabled := cbOtherTax.Checked;
end;

function Tgdc_inv_dlgPredefinedField.GetPrefix: String;
begin
  if edPrefix.Text = '' then
    Result := ''
  else
    if Pos('_', edPrefix.Text) = 0 then
      Result := edPrefix.Text + '_'
    else
      Result := edPrefix.Text;
end;

end.
