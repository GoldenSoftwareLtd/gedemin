inherited GOFrame: TGOFrame
  HelpContext = 322
  inherited PageControl: TSuperPageControl
    inherited tsProperty: TSuperTabSheet
      inherited pMain: TPanel
        inherited lbName: TLabel
          Width = 119
          Caption = 'Наименование объекта'
        end
        inherited dbcbLang: TDBComboBox
          Width = 291
        end
        inherited dbtOwner: TDBEdit
          Width = 199
        end
      end
    end
    inherited tsParams: TSuperTabSheet
      TabVisible = False
      inherited ScrollBox: TScrollBox
        Width = 435
        Height = 210
      end
      inherited pnlCaption: TPanel
        Width = 435
      end
    end
  end
end
