inherited gdc_dlgPaymentOrder: Tgdc_dlgPaymentOrder
  Left = 215
  Top = 202
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    TabOrder = 3
  end
  inherited btnNew: TButton
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 373
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 453
    TabOrder = 2
  end
  inherited btnHelp: TButton
    TabOrder = 5
  end
  inherited PageControl1: TPageControl
    Height = 441
    TabOrder = 0
    inherited tsMain: TTabSheet
      inherited pnlMain: TPanel
        Height = 413
        inherited Bevel1: TBevel
          Height = 131
        end
        inherited Bevel3: TBevel
          Top = 170
        end
        inherited Label17: TLabel
          Top = 277
        end
        inherited Label1: TLabel
          Left = 15
        end
        inherited Label12: TLabel
          Left = 15
          Top = 95
        end
        inherited Label10: TLabel
          Top = 178
        end
        inherited Label16: TLabel
          Top = 178
        end
        inherited Label6: TLabel
          Top = 203
        end
        inherited Label7: TLabel
          Top = 203
        end
        inherited Label11: TLabel
          Top = 178
        end
        inherited Label18: TLabel
          Left = 15
          Top = 45
        end
        inherited Label5: TLabel
          Left = 15
          Top = 70
        end
        inherited Label20: TLabel
          Top = 389
        end
        inherited Label8: TLabel
          Top = 365
        end
        object Label13: TLabel [18]
          Left = 211
          Top = 119
          Width = 60
          Height = 13
          Caption = 'Доп. сумма:'
          Transparent = True
        end
        object Label9: TLabel [19]
          Left = 15
          Top = 120
          Width = 54
          Height = 13
          Caption = 'Доп. счет:'
          Transparent = True
        end
        object Label21: TLabel [20]
          Left = 15
          Top = 145
          Width = 179
          Height = 13
          Caption = 'Корреспондент банка получателя:'
        end
        object Label19: TLabel [21]
          Left = 7
          Top = 231
          Width = 72
          Height = 29
          AutoSize = False
          Caption = 'Дата товара, услуги:'
          Transparent = True
          WordWrap = True
        end
        object Label14: TLabel [22]
          Left = 192
          Top = 231
          Width = 61
          Height = 26
          AutoSize = False
          Caption = 'Уточнение платежа:'
          Transparent = True
          WordWrap = True
        end
        object Label15: TLabel [23]
          Left = 8
          Top = 389
          Width = 80
          Height = 13
          Caption = 'Вид поручения:'
        end
        inherited dbeCorrAccount: TgsIBLookupComboBox
          OnCreateNewObject = dbeCorrAccountCreateNewObject
        end
        inherited dbePaymentDestination: TDBMemo
          Top = 260
          Height = 96
          TabOrder = 18
        end
        inherited dbeOper: TDBEdit
          Top = 174
          TabOrder = 11
        end
        inherited dbeQueue: TDBEdit
          Top = 174
          TabOrder = 13
        end
        inherited dbeDest: TgsIBLookupComboBox
          Top = 199
          TabOrder = 14
        end
        inherited dbeTerm: TxDateDBEdit
          Top = 199
          TabOrder = 15
        end
        inherited dbeOperKind: TDBEdit
          Top = 174
          TabOrder = 12
        end
        inherited cmbExpense: TComboBox
          Left = 290
          Top = 385
          Width = 226
          TabOrder = 21
        end
        inherited gsTransactionComboBox: TgsTransactionComboBox
          Top = 360
          Width = 425
          TabOrder = 19
        end
        object dbeSecondAccount: TDBEdit
          Left = 90
          Top = 115
          Width = 112
          Height = 21
          DataField = 'CORRSECACC'
          DataSource = dsgdcBase
          TabOrder = 8
        end
        object dbeSecondAmount: TxDBCalculatorEdit
          Left = 280
          Top = 115
          Width = 112
          Height = 21
          TabOrder = 9
          DecDigits = 0
          DataField = 'SECONDAMOUNT'
          DataSource = dsgdcBase
        end
        object dbeMidCorrBank: TDBEdit
          Left = 195
          Top = 140
          Width = 312
          Height = 21
          DataField = 'MIDCORRBANKTEXT'
          DataSource = dsgdcBase
          TabOrder = 10
        end
        object dbeReceive: TDBEdit
          Left = 90
          Top = 234
          Width = 76
          Height = 21
          DataField = 'ENTERDATE'
          DataSource = dsgdcBase
          TabOrder = 16
        end
        object dbcSpecification: TDBComboBox
          Left = 275
          Top = 234
          Width = 239
          Height = 21
          DataField = 'SPECIFICATION'
          DataSource = dsgdcBase
          ItemHeight = 13
          Items.Strings = (
            'Срочный платеж'
            'В счет неотложных нужд'
            'В счет бесспорного удержания'
            'В счет прожиточного минимума'
            '')
          TabOrder = 17
        end
        object cmbKind: TComboBox
          Left = 90
          Top = 385
          Width = 73
          Height = 21
          ItemHeight = 13
          TabOrder = 20
          Items.Strings = (
            'Обычное'
            'Срочное')
        end
      end
    end
    inherited tsAttribute: TTabSheet
      inherited atContainer: TatContainer
        Height = 413
      end
    end
  end
  inherited alBase: TActionList
    Left = 476
  end
  inherited dsgdcBase: TDataSource
    Left = 446
  end
end
