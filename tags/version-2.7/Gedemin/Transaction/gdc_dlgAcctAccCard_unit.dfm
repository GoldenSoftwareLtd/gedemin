inherited dlgAcctAccCardConfig: TdlgAcctAccCardConfig
  Left = 175
  Top = 144
  HelpContext = 162
  Caption = 'Конфигурация карты счета'
  ClientHeight = 521
  OnDockDrop = FormDockDrop
  PixelsPerInch = 96
  TextHeight = 13
  inherited PageControl: TPageControl
    Height = 521
    inherited tsGeneral: TTabSheet
      inherited lAccounts: TLabel
        Top = 27
      end
      inherited frSum: TframeSum
        Top = 284
        TabOrder = 8
      end
      inherited frQuantity: TframeQuantity
        Top = 180
        TabOrder = 7
      end
      inherited cbAccounts: TComboBox
        Top = 23
      end
      inherited cbSubAccounts: TCheckBox
        Top = 45
      end
      inherited cbIncludeInternalMovement: TCheckBox
        Top = 60
      end
      object cbGroup: TCheckBox [8]
        Left = 0
        Top = 75
        Width = 97
        Height = 14
        Caption = 'Группировать'
        TabOrder = 5
      end
      inherited Button1: TButton
        Top = 23
      end
      object gbCorrAccounts: TGroupBox [10]
        Left = 0
        Top = 90
        Width = 337
        Height = 89
        Caption = ' Корсчета '
        TabOrder = 6
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
          Width = 222
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbCorrAccountsChange
        end
        object Button2: TButton
          Left = 309
          Top = 12
          Width = 21
          Height = 21
          Action = actCorrAccounts
          TabOrder = 1
        end
        object cbCorrSubAccounts: TCheckBox
          Left = 8
          Top = 70
          Width = 121
          Height = 14
          Caption = 'Включать субсчета'
          TabOrder = 4
          OnClick = cbCorrSubAccountsClick
        end
        object rbDebit: TRadioButton
          Left = 17
          Top = 35
          Width = 113
          Height = 14
          Caption = 'Дебет'
          TabOrder = 2
        end
        object rbCredit: TRadioButton
          Left = 17
          Top = 52
          Width = 113
          Height = 14
          Caption = 'Кредит'
          TabOrder = 3
        end
      end
      inherited GroupBox1: TGroupBox
        Top = 391
        TabOrder = 9
      end
    end
    inherited tsAnalytics: TTabSheet
      inherited frAnalytics: TframeAnalyticValue
        Height = 487
        inherited sbAnaliseLines: TScrollBox
          Height = 487
        end
      end
    end
  end
  inherited alBase: TActionList
    object actCorrAccounts: TAction
      Caption = '...'
      OnExecute = actCorrAccountsExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 104
    Top = 279
  end
end
