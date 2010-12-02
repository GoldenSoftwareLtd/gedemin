inherited dlgAcctGeneralLedger: TdlgAcctGeneralLedger
  Left = 317
  Top = 112
  Caption = 'Конфигурация главной книги'
  ClientHeight = 435
  PixelsPerInch = 96
  TextHeight = 13
  inherited PageControl: TPageControl
    Height = 435
    inherited tsGeneral: TTabSheet
      inherited frSum: TframeSum
        Top = 198
      end
      inherited frQuantity: TframeQuantity
        Top = 95
      end
      inherited cbAccounts: TComboBox
        TabOrder = 8
      end
      inherited cbSubAccounts: TCheckBox
        Left = 32
        Top = 40
        TabOrder = 10
        Visible = False
      end
      inherited cbIncludeInternalMovement: TCheckBox
        Top = 56
        Width = 185
        TabOrder = 1
      end
      inherited Button1: TButton
        TabOrder = 9
      end
      inherited GroupBox1: TGroupBox
        Top = 305
      end
      object cbShowDebit: TCheckBox
        Left = 187
        Top = 55
        Width = 144
        Height = 17
        Caption = 'Расшифровка по дебету'
        TabOrder = 3
      end
      object cbShowCorrSubAccounts: TCheckBox
        Left = 0
        Top = 71
        Width = 185
        Height = 17
        Caption = 'Корреспонденция с субсчетами'
        TabOrder = 2
      end
      object cbShowCredit: TCheckBox
        Left = 187
        Top = 71
        Width = 149
        Height = 17
        Caption = 'Расшифровка по кредиту'
        TabOrder = 4
      end
    end
    inherited tsAnalytics: TTabSheet
      TabVisible = False
      inherited frAnalytics: TframeAnalyticValue
        Height = 401
        inherited sbAnaliseLines: TScrollBox
          Height = 401
        end
      end
    end
  end
end
