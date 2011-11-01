inherited gd_dlgCurrCommissSell: Tgd_dlgCurrCommissSell
  Left = 287
  Top = 248
  ActiveControl = dbedNumber
  Caption = 'Поручение на продажу валюты'
  ClientHeight = 313
  ClientWidth = 405
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
  end
  inherited btnNew: TButton
    Left = 85
  end
  inherited btnOK: TButton
    Left = 245
  end
  object Panel1: TPanel [3]
    Left = 0
    Top = 0
    Width = 401
    Height = 281
    BevelOuter = bvNone
    TabOrder = 5
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 401
      Height = 281
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Реквизиты'
        object Label1: TLabel
          Left = 6
          Top = 9
          Width = 92
          Height = 13
          Caption = 'Номер поручения:'
        end
        object Label2: TLabel
          Left = 6
          Top = 34
          Width = 87
          Height = 13
          Caption = 'Дата поручения:'
        end
        object Label3: TLabel
          Left = 6
          Top = 59
          Width = 110
          Height = 13
          Caption = 'Наименование банка:'
        end
        object Label4: TLabel
          Left = 6
          Top = 84
          Width = 100
          Height = 13
          Caption = '% от общей суммы:'
        end
        object Label5: TLabel
          Left = 6
          Top = 109
          Width = 49
          Height = 13
          Caption = 'Со счета:'
        end
        object Label6: TLabel
          Left = 6
          Top = 134
          Width = 91
          Height = 13
          Caption = 'В течении (дней):'
        end
        object Label7: TLabel
          Left = 6
          Top = 159
          Width = 103
          Height = 13
          Caption = '% вознаграждения:'
        end
        object Label8: TLabel
          Left = 6
          Top = 184
          Width = 124
          Height = 13
          Caption = 'Сумму в руб. зачислить:'
        end
        object Label9: TLabel
          Left = 6
          Top = 209
          Width = 124
          Height = 13
          Caption = 'Сумму в вал. зачислить:'
        end
        object Label10: TLabel
          Left = 6
          Top = 234
          Width = 132
          Height = 13
          Caption = 'Поручение действует до:'
        end
        object dbedNumber: TDBEdit
          Left = 145
          Top = 5
          Width = 237
          Height = 21
          DataField = 'NUMBER'
          DataSource = dsgdcBase
          TabOrder = 0
        end
        object ddbedDocumentDate: TxDateDBEdit
          Left = 145
          Top = 30
          Width = 237
          Height = 21
          DataField = 'documentdate'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 1
        end
        object iblcBank: TgsIBLookupComboBox
          Left = 145
          Top = 55
          Width = 237
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = dmDatabase.ibtrGenUniqueID
          DataSource = dsgdcBase
          DataField = 'BANKKEY'
          ListTable = 'GD_CONTACT'
          ListField = 'NAME'
          KeyField = 'ID'
          Condition = 'contacttype = 5'
          gdClassName = 'TgdcBank'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnChange = iblcBankChange
        end
        object dbedPercent: TDBEdit
          Left = 145
          Top = 80
          Width = 237
          Height = 21
          DataField = 'PERCENT'
          DataSource = dsgdcBase
          TabOrder = 3
        end
        object iblcAccountKey: TgsIBLookupComboBox
          Left = 145
          Top = 105
          Width = 237
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
        object dbedTimeInt: TDBEdit
          Left = 145
          Top = 130
          Width = 237
          Height = 21
          DataField = 'timeint'
          DataSource = dsgdcBase
          TabOrder = 5
        end
        object dbedComPercent: TDBEdit
          Left = 145
          Top = 155
          Width = 237
          Height = 21
          DataField = 'compercent'
          DataSource = dsgdcBase
          TabOrder = 6
        end
        object iblcToAccountKey: TgsIBLookupComboBox
          Left = 145
          Top = 180
          Width = 237
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = dmDatabase.ibtrGenUniqueID
          DataSource = dsgdcBase
          DataField = 'ToAccountKey'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 7
        end
        object iblcToCurrAccountKey: TgsIBLookupComboBox
          Left = 145
          Top = 205
          Width = 237
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = dmDatabase.ibtrGenUniqueID
          DataSource = dsgdcBase
          DataField = 'TOCURRACCOUNTKEY'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 8
        end
        object ddbedDateValid: TxDateDBEdit
          Left = 145
          Top = 230
          Width = 237
          Height = 21
          DataField = 'DATEVALID'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 9
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Атрибуты'
        ImageIndex = 1
        object atContainer1: TatContainer
          Left = 0
          Top = 0
          Width = 393
          Height = 253
          DataSource = dsgdcBase
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
  inherited btnCancel: TButton
    Left = 325
  end
  inherited btnHelp: TButton
    Left = 165
  end
  inherited alBase: TActionList
    Left = 355
    Top = 0
  end
  inherited dsgdcBase: TDataSource
    Left = 325
    Top = 0
  end
end
