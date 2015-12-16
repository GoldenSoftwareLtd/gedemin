inherited gdc_dlgAcctSubAccount: Tgdc_dlgAcctSubAccount
  Left = 392
  Top = 145
  Caption = 'Субсчет'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pgcMain: TPageControl
    inherited tbsMain: TTabSheet
      inherited lblAlias: TLabel
        Width = 84
        Caption = 'Номер субсчета:'
      end
      inherited lblName: TLabel
        Width = 77
        Caption = 'Наименование:'
      end
      inherited Label2: TLabel
        Width = 76
        Caption = 'Входит в счет:'
      end
      object lblHint: TLabel [6]
        Left = 190
        Top = 55
        Width = 272
        Height = 13
        Caption = 'Должен начинаться с номера счета. Например: 01.02'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      inherited pAccountInfo: TPanel
        inherited GroupBox1: TGroupBox
          Caption = ' Параметры субсчета '
          inherited dbcbCurrAccount: TDBCheckBox
            Width = 122
            Caption = 'Валютный субсчет'
          end
          inherited dbcbOffBalance: TDBCheckBox
            Caption = 'Забалансовый субсчет'
          end
        end
        inherited dbrgTypeAccount: TDBRadioGroup
          Caption = ' Тип субсчета '
        end
      end
      inherited dbedAlias: TDBEdit
        Width = 65
        OnChange = dbedAliasChange
      end
      inherited gsiblcGroupAccount: TgsIBLookupComboBox
        Condition = 'accounttype in ('#39'A'#39', '#39'S'#39')'
        gdClassName = 'TgdcAcctBase'
      end
    end
  end
end
