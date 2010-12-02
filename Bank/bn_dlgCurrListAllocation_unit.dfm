inherited gd_dlgCurrListAllocation: Tgd_dlgCurrListAllocation
  Left = 280
  Top = 263
  ActiveControl = dbedNumber
  Caption = 'Реестр распределения валюты'
  ClientHeight = 313
  ClientWidth = 448
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
  end
  inherited btnNew: TButton
    Left = 85
  end
  inherited btnOK: TButton
    Left = 285
  end
  object Panel1: TPanel [3]
    Left = 0
    Top = 0
    Width = 441
    Height = 280
    BevelOuter = bvNone
    TabOrder = 5
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 441
      Height = 280
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Реквизиты'
        object Label1: TLabel
          Left = 8
          Top = 39
          Width = 30
          Height = 13
          Caption = 'Дата:'
        end
        object Label2: TLabel
          Left = 139
          Top = 39
          Width = 43
          Height = 13
          Caption = 'Валюта:'
        end
        object Label3: TLabel
          Left = 264
          Top = 39
          Width = 35
          Height = 13
          Caption = 'Сумма:'
        end
        object Label4: TLabel
          Left = 8
          Top = 64
          Width = 43
          Height = 13
          Caption = 'На счет:'
        end
        object Label5: TLabel
          Left = 8
          Top = 89
          Width = 98
          Height = 13
          Caption = 'Дата поступления:'
        end
        object Label6: TLabel
          Left = 8
          Top = 114
          Width = 312
          Height = 13
          Caption = 'Не подлежит распределению в счет обязательной продажи:'
        end
        object Label7: TLabel
          Left = 8
          Top = 199
          Width = 178
          Height = 13
          Caption = 'Подлежит обязательной продаже:'
        end
        object Label8: TLabel
          Left = 8
          Top = 224
          Width = 255
          Height = 13
          Caption = 'Продано на бирже в счет обязательной продажи:'
        end
        object Label9: TLabel
          Left = 8
          Top = 132
          Width = 59
          Height = 13
          Caption = 'Основание:'
        end
        object Label10: TLabel
          Left = 9
          Top = 15
          Width = 35
          Height = 13
          Caption = 'Номер:'
        end
        object ddbedDocumentDate: TxDateDBEdit
          Left = 55
          Top = 35
          Width = 74
          Height = 21
          DataField = 'documentdate'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 1
        end
        object iblcCurrKey: TgsIBLookupComboBox
          Left = 185
          Top = 35
          Width = 73
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = dmDatabase.ibtrGenUniqueID
          DataSource = dsgdcBase
          DataField = 'CURRKEY'
          ListTable = 'GD_CURR'
          ListField = 'SHORTNAME'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object dbedAmountCurr: TDBEdit
          Left = 320
          Top = 35
          Width = 105
          Height = 21
          DataField = 'amountcurr'
          DataSource = dsgdcBase
          TabOrder = 3
        end
        object iblcAccountKey: TgsIBLookupComboBox
          Left = 55
          Top = 60
          Width = 368
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = dmDatabase.ibtrGenUniqueID
          DataSource = dsgdcBase
          DataField = 'ACCOUNTKEY'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object ddbedDateEnter: TxDateDBEdit
          Left = 320
          Top = 85
          Width = 104
          Height = 21
          DataField = 'dateenter'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 5
        end
        object dbedamountnotpay: TDBEdit
          Left = 320
          Top = 110
          Width = 104
          Height = 21
          DataField = 'amountnotpay'
          DataSource = dsgdcBase
          TabOrder = 6
        end
        object dbedamountpay: TDBEdit
          Left = 320
          Top = 195
          Width = 104
          Height = 21
          DataField = 'amountpay'
          DataSource = dsgdcBase
          TabOrder = 8
        end
        object dbedamountpayed: TDBEdit
          Left = 320
          Top = 220
          Width = 104
          Height = 21
          DataField = 'amountpayed'
          DataSource = dsgdcBase
          TabOrder = 9
        end
        object dbmBaseText: TDBMemo
          Left = 5
          Top = 145
          Width = 418
          Height = 46
          DataField = 'basetext'
          DataSource = dsgdcBase
          TabOrder = 7
        end
        object dbedNumber: TDBEdit
          Left = 55
          Top = 10
          Width = 74
          Height = 21
          DataField = 'number'
          DataSource = dsgdcBase
          TabOrder = 0
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Атрибуты'
        ImageIndex = 1
        object atContainer1: TatContainer
          Left = 0
          Top = 0
          Width = 433
          Height = 252
          DataSource = dsgdcBase
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
  inherited btnCancel: TButton
    Left = 365
  end
  inherited btnHelp: TButton
    Left = 165
  end
end
