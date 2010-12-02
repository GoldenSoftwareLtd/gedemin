inherited gd_dlgCurrConvContract: Tgd_dlgCurrConvContract
  Left = 280
  Top = 263
  Caption = 'Контракт на конверсию валюты'
  ClientHeight = 247
  ClientWidth = 448
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 220
  end
  inherited btnNew: TButton
    Left = 85
    Top = 220
  end
  inherited btnOK: TButton
    Left = 285
    Top = 220
  end
  object Panel1: TPanel [3]
    Left = 0
    Top = 0
    Width = 441
    Height = 216
    BevelOuter = bvNone
    TabOrder = 5
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 441
      Height = 216
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Реквизиты'
        object Label1: TLabel
          Left = 19
          Top = 14
          Width = 30
          Height = 13
          Caption = 'Дата:'
        end
        object Label5: TLabel
          Left = 157
          Top = 14
          Width = 35
          Height = 13
          Caption = 'Номер:'
        end
        object GroupBox1: TGroupBox
          Left = 10
          Top = 30
          Width = 417
          Height = 69
          Caption = 'Списать валюту'
          TabOrder = 2
          object Label2: TLabel
            Left = 9
            Top = 19
            Width = 43
            Height = 13
            Caption = 'Валюта:'
          end
          object Label3: TLabel
            Left = 143
            Top = 19
            Width = 35
            Height = 13
            Caption = 'Сумма:'
          end
          object Label4: TLabel
            Left = 9
            Top = 45
            Width = 49
            Height = 13
            Caption = 'Со счета:'
          end
          object iblcFromCurrKey: TgsIBLookupComboBox
            Left = 60
            Top = 15
            Width = 78
            Height = 21
            Database = dmDatabase.ibdbGAdmin
            Transaction = dmDatabase.ibtrGenUniqueID
            DataSource = dsgdcBase
            DataField = 'FROMCURRKEY'
            ListTable = 'GD_CURR'
            ListField = 'SHORTNAME'
            KeyField = 'ID'
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
          end
          object dbedFromAmountCurr: TDBEdit
            Left = 190
            Top = 15
            Width = 103
            Height = 21
            DataField = 'fromamountcurr'
            DataSource = dsgdcBase
            TabOrder = 1
          end
          object iblcFromAccountKey: TgsIBLookupComboBox
            Left = 60
            Top = 40
            Width = 351
            Height = 21
            Database = dmDatabase.ibdbGAdmin
            Transaction = dmDatabase.ibtrGenUniqueID
            DataSource = dsgdcBase
            DataField = 'FROMACCOUNTKEY'
            ListTable = 'GD_COMPANYACCOUNT'
            ListField = 'ACCOUNT'
            KeyField = 'ID'
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
          end
        end
        object ddbedDocumentDate: TxDateDBEdit
          Left = 70
          Top = 10
          Width = 79
          Height = 21
          DataField = 'documentdate'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 0
        end
        object dbedNumber: TDBEdit
          Left = 200
          Top = 10
          Width = 104
          Height = 21
          DataField = 'number'
          DataSource = dsgdcBase
          TabOrder = 1
        end
        object GroupBox2: TGroupBox
          Left = 10
          Top = 105
          Width = 417
          Height = 69
          Caption = 'Зачислить'
          TabOrder = 3
          object Label6: TLabel
            Left = 9
            Top = 19
            Width = 43
            Height = 13
            Caption = 'Валюта:'
          end
          object Label7: TLabel
            Left = 143
            Top = 19
            Width = 35
            Height = 13
            Caption = 'Сумма:'
          end
          object Label8: TLabel
            Left = 9
            Top = 44
            Width = 43
            Height = 13
            Caption = 'На счет:'
          end
          object iblcToCurrKey: TgsIBLookupComboBox
            Left = 60
            Top = 15
            Width = 78
            Height = 21
            Database = dmDatabase.ibdbGAdmin
            Transaction = dmDatabase.ibtrGenUniqueID
            DataSource = dsgdcBase
            DataField = 'TOCURRKEY'
            ListTable = 'GD_CURR'
            ListField = 'SHORTNAME'
            KeyField = 'ID'
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
          end
          object dbedtoamountcurr: TDBEdit
            Left = 190
            Top = 15
            Width = 104
            Height = 21
            DataField = 'toamountcurr'
            DataSource = dsgdcBase
            TabOrder = 1
          end
          object iblctoaccountkey: TgsIBLookupComboBox
            Left = 60
            Top = 40
            Width = 353
            Height = 21
            Database = dmDatabase.ibdbGAdmin
            Transaction = dmDatabase.ibtrGenUniqueID
            DataSource = dsgdcBase
            DataField = 'TOACCOUNTKEY'
            ListTable = 'GD_COMPANYACCOUNT'
            ListField = 'ACCOUNT'
            KeyField = 'ID'
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Атрибуты'
        ImageIndex = 1
        object atContainer1: TatContainer
          Left = 0
          Top = 0
          Width = 433
          Height = 188
          DataSource = dsgdcBase
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
  inherited btnCancel: TButton
    Left = 365
    Top = 220
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 220
  end
  inherited alBase: TActionList
    Left = 395
    Top = 5
  end
  inherited dsgdcBase: TDataSource
    Left = 365
    Top = 5
  end
end
