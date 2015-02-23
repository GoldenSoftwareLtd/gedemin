inherited gd_dlgCurrSellContract: Tgd_dlgCurrSellContract
  Left = 280
  Top = 263
  ActiveControl = ddbedDocumentDate
  Caption = 'Договор на продажу валюты'
  ClientHeight = 238
  ClientWidth = 404
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 210
  end
  inherited btnNew: TButton
    Left = 85
    Top = 210
  end
  inherited btnOK: TButton
    Left = 245
    Top = 210
  end
  object Panel1: TPanel [3]
    Left = 4
    Top = 3
    Width = 396
    Height = 203
    BevelOuter = bvNone
    TabOrder = 5
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 396
      Height = 203
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Реквизиты'
        object Label1: TLabel
          Left = 10
          Top = 14
          Width = 81
          Height = 13
          Caption = 'Дата договора:'
        end
        object Label5: TLabel
          Left = 10
          Top = 124
          Width = 136
          Height = 13
          Caption = 'Перечислить вал. на счет:'
        end
        object Label6: TLabel
          Left = 11
          Top = 99
          Width = 28
          Height = 13
          Caption = 'Банк:'
        end
        object Label7: TLabel
          Left = 11
          Top = 149
          Width = 119
          Height = 13
          Caption = 'Рублевый экв. на счет:'
        end
        object Label8: TLabel
          Left = 211
          Top = 14
          Width = 35
          Height = 13
          Caption = 'Номер:'
        end
        object GroupBox1: TGroupBox
          Left = 5
          Top = 30
          Width = 378
          Height = 61
          TabOrder = 2
          object Label2: TLabel
            Left = 5
            Top = 11
            Width = 114
            Height = 13
            Caption = 'Продаваемая валюта:'
          end
          object Label3: TLabel
            Left = 175
            Top = 11
            Width = 35
            Height = 13
            Caption = 'Сумма:'
          end
          object Label4: TLabel
            Left = 285
            Top = 11
            Width = 51
            Height = 13
            Caption = 'Мин.курс:'
          end
          object iblcCurr: TgsIBLookupComboBox
            Left = 5
            Top = 30
            Width = 164
            Height = 21
            Database = dmDatabase.ibdbGAdmin
            Transaction = dmDatabase.ibtrGenUniqueID
            DataSource = dsgdcBase
            DataField = 'currkey'
            ListTable = 'gd_curr'
            ListField = 'SHORTNAME'
            KeyField = 'ID'
            gdClassName = 'TgdcCurr'
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
          end
          object dbedAmount: TDBEdit
            Left = 175
            Top = 30
            Width = 103
            Height = 21
            DataField = 'amount'
            DataSource = dsgdcBase
            TabOrder = 1
          end
          object dbedMinRate: TDBEdit
            Left = 285
            Top = 30
            Width = 86
            Height = 21
            DataField = 'minrate'
            DataSource = dsgdcBase
            TabOrder = 2
          end
        end
        object ddbedDocumentDate: TxDateDBEdit
          Left = 95
          Top = 10
          Width = 108
          Height = 21
          DataField = 'documentdate'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 0
        end
        object iblcBankAccountKey: TgsIBLookupComboBox
          Left = 145
          Top = 120
          Width = 236
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = dmDatabase.ibtrGenUniqueID
          DataSource = dsgdcBase
          DataField = 'BANKACCOUNTKEY'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object iblcBankKey: TgsIBLookupComboBox
          Left = 145
          Top = 95
          Width = 236
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = dmDatabase.ibtrGenUniqueID
          DataSource = dsgdcBase
          DataField = 'bankkey'
          ListTable = 'GD_CONTACT'
          ListField = 'NAME'
          KeyField = 'ID'
          Condition = 'CONTACTTYPE = 5'
          gdClassName = 'TgdcBank'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          OnChange = iblcBankKeyChange
        end
        object iblcOwnAccountKey: TgsIBLookupComboBox
          Left = 145
          Top = 145
          Width = 236
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = dmDatabase.ibtrGenUniqueID
          DataSource = dsgdcBase
          DataField = 'OWNACCOUNTKEY'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
        end
        object dbedNumber: TDBEdit
          Left = 255
          Top = 10
          Width = 121
          Height = 21
          DataField = 'number'
          DataSource = dsgdcBase
          TabOrder = 1
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Атрибуты'
        ImageIndex = 1
        object atContainer1: TatContainer
          Left = 0
          Top = 0
          Width = 388
          Height = 175
          DataSource = dsgdcBase
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
  inherited btnCancel: TButton
    Left = 325
    Top = 210
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 210
  end
  inherited alBase: TActionList
    Left = 115
    Top = 105
  end
  inherited dsgdcBase: TDataSource
    Left = 85
    Top = 105
  end
end
