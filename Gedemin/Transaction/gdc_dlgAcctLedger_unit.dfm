inherited dlgAcctLedgerConfig: TdlgAcctLedgerConfig
  Left = 414
  Top = 97
  HelpContext = 102
  Caption = 'Конфигурация журнал-ордера'
  ClientHeight = 554
  PixelsPerInch = 96
  TextHeight = 13
  inherited PageControl: TPageControl
    Height = 554
    inherited tsGeneral: TTabSheet
      inherited lAccounts: TLabel
        Top = 26
      end
      inherited frSum: TframeSum
        Top = 317
        TabOrder = 10
      end
      inherited frQuantity: TframeQuantity
        Top = 213
        Height = 104
        TabOrder = 9
        inherited gbGroup: TGroupBox
          Height = 104
          inherited Label12: TLabel
            Left = 289
          end
        end
      end
      inherited cbAccounts: TComboBox
        Top = 22
      end
      inherited Button1: TButton [6]
        Top = 22
      end
      inline frAnalyticsGroup: TdlgfrAcctAnalyticsGroup [7]
        Top = 92
        Width = 522
        Align = alBottom
        TabOrder = 8
        inherited gbGroup: TGroupBox
          Width = 522
          Align = alClient
          inherited Label11: TLabel
            Width = 53
          end
          inherited Label12: TLabel
            Left = 289
          end
          inherited lbAvail: TListBox
            Width = 223
          end
          inherited Button1: TButton
            Left = 289
          end
          inherited Button2: TButton
            Left = 361
          end
          inherited Button3: TButton
            Left = 241
          end
          inherited Button4: TButton
            Left = 241
          end
          inherited Button5: TButton
            Left = 241
          end
          inherited Button6: TButton
            Left = 241
          end
          inherited lbSelected: TCheckListBox
            Left = 288
            Width = 223
          end
        end
      end
      inherited GroupBox1: TGroupBox [8]
        Top = 424
        TabOrder = 11
      end
      inherited cbSubAccounts: TCheckBox [9]
        Top = 45
      end
      inherited cbIncludeInternalMovement: TCheckBox
        Left = 152
        Top = 45
        Width = 186
      end
      object cbShowDebit: TCheckBox
        Left = 0
        Top = 61
        Width = 153
        Height = 17
        Caption = 'Расшифровка по дебету'
        TabOrder = 5
      end
      object cbShowCorrSubAccounts: TCheckBox
        Left = 0
        Top = 77
        Width = 313
        Height = 17
        Caption = 'Корреспонденция с субсчетами'
        TabOrder = 7
      end
      object cbShowCredit: TCheckBox
        Left = 152
        Top = 61
        Width = 153
        Height = 17
        Caption = 'Расшифровка по кредиту'
        TabOrder = 6
      end
    end
    object tsAdditional: TTabSheet [1]
      BorderWidth = 3
      Caption = 'Дополнительно'
      ImageIndex = 2
      object gbTreeAnalytic: TGroupBox
        Left = 0
        Top = 0
        Width = 522
        Height = 204
        Align = alTop
        Caption = ' Уровни аналитики '
        TabOrder = 0
        object sbTreeAnalitic: TScrollBox
          Left = 2
          Top = 15
          Width = 518
          Height = 187
          Align = alClient
          BorderStyle = bsNone
          TabOrder = 0
        end
      end
      object gbAnalyticGroupListField: TGroupBox
        Left = 0
        Top = 204
        Width = 522
        Height = 204
        Align = alTop
        Caption = ' Поля отображений для группировки по аналитике '
        TabOrder = 1
        object sbAnalyticGroupListField: TScrollBox
          Left = 2
          Top = 15
          Width = 518
          Height = 187
          Align = alClient
          BorderStyle = bsNone
          TabOrder = 0
        end
      end
      object gbOtherParameters: TGroupBox
        Left = 0
        Top = 408
        Width = 522
        Height = 57
        Align = alTop
        Caption = ' Другие параметры '
        TabOrder = 2
        object cbEnchancedSaldo: TCheckBox
          Left = 9
          Top = 35
          Width = 148
          Height = 14
          Caption = 'Расширенное сальдо'
          TabOrder = 0
        end
        object cbSumNull: TCheckBox
          Left = 9
          Top = 19
          Width = 180
          Height = 14
          Caption = 'Подсчет итого пустых строк'
          TabOrder = 1
        end
      end
    end
    inherited tsAnalytics: TTabSheet
      inherited frAnalytics: TframeAnalyticValue
        Height = 520
        inherited sbAnaliseLines: TScrollBox
          Height = 520
        end
      end
    end
  end
  inherited alBase: TActionList
    Left = 366
    Top = 231
  end
  inherited dsgdcBase: TDataSource
    Left = 368
    Top = 287
  end
  inherited pm_dlgG: TPopupMenu
    Left = 368
    Top = 192
  end
  inherited ibtrCommon: TIBTransaction
    Left = 368
    Top = 152
  end
end
