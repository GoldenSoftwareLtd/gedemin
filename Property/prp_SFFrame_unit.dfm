inherited SFFrame: TSFFrame
  HelpContext = 326
  inherited PageControl: TSuperPageControl
    inherited tsProperty: TSuperTabSheet
      object Label1: TLabel [0]
        Left = 8
        Top = 72
        Width = 43
        Height = 13
        Caption = 'Модуль:'
      end
      object DBText1: TDBText [1]
        Left = 144
        Top = 72
        Width = 241
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        DataField = 'MODULE'
        DataSource = DataSource
      end
    end
  end
  inherited PopupMenu: TPopupMenu
    Left = 232
  end
  inherited ActionList1: TActionList
    Left = 100
    Top = 131
  end
  inherited SynCompletionProposal: TSynCompletionProposal
    Left = 264
  end
end
