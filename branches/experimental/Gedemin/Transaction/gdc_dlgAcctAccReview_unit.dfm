inherited dlgAcctAccReviewConfig: TdlgAcctAccReviewConfig
  Left = 256
  Top = 175
  Caption = 'Конфигурация анализа счета'
  ClientHeight = 460
  OnDockDrop = FormDockDrop
  PixelsPerInch = 96
  TextHeight = 13
  inherited PageControl: TPageControl
    Height = 460
    inherited tsGeneral: TTabSheet
      inherited frSum: TframeSum
        Top = 236
      end
      inherited frQuantity: TframeQuantity
        Top = 133
      end
      inherited dbeName: TDBEdit
        Width = 433
      end
      inherited cbAccounts: TComboBox
        Width = 411
      end
      inherited cbIncludeInternalMovement: TCheckBox
        Left = 152
        Top = 48
        Width = 193
      end
      inherited Button1: TButton
        Left = 500
      end
      inherited GroupBox1: TGroupBox
        Top = 343
        Height = 83
        inherited lShowInFolder: TLabel
          Top = 34
        end
        inherited lImage: TLabel
          Top = 58
        end
        inherited dbcShowInExplorer: TDBCheckBox
          Top = 14
        end
        inherited iblFolder: TgsIBLookupComboBox
          Top = 30
        end
        inherited cbImage: TDBComboBox
          Top = 53
        end
        inherited cbExtendedFields: TCheckBox
          Left = 352
          Top = 38
          Width = 129
          Visible = False
        end
      end
      object gbCorrAccounts: TGroupBox
        Left = 0
        Top = 63
        Width = 522
        Height = 70
        Align = alBottom
        Caption = ' Корсчета '
        TabOrder = 8
        object Label1: TLabel
          Left = 8
          Top = 16
          Width = 52
          Height = 13
          Caption = 'Корсчета:'
        end
        object cbCorrAccounts: TComboBox
          Left = 88
          Top = 12
          Width = 404
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbCorrAccountsChange
        end
        object btnCorrAccounts: TButton
          Left = 494
          Top = 12
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 1
          OnClick = btnCorrAccountsClick
        end
        object rbDebit: TRadioButton
          Left = 20
          Top = 35
          Width = 77
          Height = 14
          Caption = 'Дебет'
          TabOrder = 2
        end
        object rbCredit: TRadioButton
          Left = 100
          Top = 36
          Width = 113
          Height = 14
          Caption = 'Кредит'
          TabOrder = 3
        end
        object cbShowCorrSubAccounts: TCheckBox
          Left = 8
          Top = 49
          Width = 185
          Height = 17
          Caption = 'Включать субсчета'
          TabOrder = 4
        end
      end
    end
    inherited tsAnalytics: TTabSheet
      inherited frAnalytics: TframeAnalyticValue
        Height = 451
        inherited sbAnaliseLines: TScrollBox
          Height = 451
        end
      end
    end
  end
end
