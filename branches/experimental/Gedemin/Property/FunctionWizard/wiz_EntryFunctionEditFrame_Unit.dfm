inherited frEntryFunctionEditFrame: TfrEntryFunctionEditFrame
  inherited PageControl: TPageControl
    inherited tsGeneral: TTabSheet
      inherited Label2: TLabel
        Top = 89
      end
      inherited cbName: TComboBox
        Width = 329
      end
      inherited mDescription: TMemo
        Top = 89
        Width = 329
        Height = 72
      end
      inherited eLocalName: TEdit
        Width = 329
      end
      object cbNoDeleteLastResults: TCheckBox
        Left = 4
        Top = 70
        Width = 257
        Height = 17
        Caption = 'Не удалять результаты предыдущих расчетов'
        TabOrder = 10
      end
    end
  end
  inherited SynVBScriptSyn: TSynVBScriptSyn
    Left = 204
    Top = 128
  end
end
