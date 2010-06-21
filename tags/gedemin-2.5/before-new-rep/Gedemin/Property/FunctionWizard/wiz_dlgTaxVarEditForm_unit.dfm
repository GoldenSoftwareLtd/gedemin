inherited dlgTaxVarEditForm: TdlgTaxVarEditForm
  Left = 290
  Top = 168
  Caption = 'Свойства переменной налога'
  ClientHeight = 231
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Top = 201
  end
  inherited PageControl: TPageControl
    Height = 201
    inherited tsGeneral: TTabSheet
      inherited Label2: TLabel
        Top = 80
      end
      inherited mDescription: TMemo
        Top = 80
      end
      inherited CheckBox1: TCheckBox
        Top = 112
        Visible = False
      end
    end
  end
end
