inherited frTaxVarEditFrame: TfrTaxVarEditFrame
  Height = 198
  Constraints.MaxHeight = 198
  Constraints.MinHeight = 198
  inherited PageControl: TPageControl
    Height = 198
    inherited tsGeneral: TTabSheet
      inherited cbName: TComboBox
        Width = 329
      end
      inherited mDescription: TMemo
        Left = 120
        Top = 96
        Width = 304
        Height = 71
      end
      inherited eLocalName: TEdit
        Width = 329
      end
      inherited BtnEdit1: TBtnEdit
        Width = 330
      end
      inherited CheckBox1: TCheckBox
        Width = 117
        Visible = False
      end
    end
  end
end
