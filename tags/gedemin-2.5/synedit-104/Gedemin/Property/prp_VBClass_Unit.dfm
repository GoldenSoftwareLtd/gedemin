inherited VBClassFrame: TVBClassFrame
  HelpContext = 327
  inherited PageControl: TSuperPageControl
    inherited tsProperty: TSuperTabSheet
      inherited pMain: TPanel
        inherited lbName: TLabel
          Width = 114
          Caption = 'Наименование класса:'
        end
        inherited lbOwner: TLabel
          Width = 90
          Caption = 'Владелец класса:'
        end
        inherited dbtOwner: TDBEdit
          Width = 292
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
  inherited DataSource: TDataSource
    Left = 267
    Top = 147
  end
  inherited PopupMenu: TPopupMenu
    Left = 328
    Top = 152
  end
  inherited ActionList1: TActionList
    Left = 220
    Top = 163
  end
  inherited gdcFunction: TgdcFunction
    Left = 296
    Top = 152
  end
  inherited gdcDelphiObject: TgdcDelphiObject
    Left = 296
    Top = 184
  end
  inherited dsDelpthiObject: TDataSource
    Left = 264
    Top = 184
  end
end
