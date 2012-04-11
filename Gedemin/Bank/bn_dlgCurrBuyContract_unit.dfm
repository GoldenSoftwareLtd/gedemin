inherited gd_dlgCurrBuyContract: Tgd_dlgCurrBuyContract
  Left = 320
  Top = 190
  ActiveControl = ddbedDocumentDate
  Caption = 'Договор на покупку валюты'
  ClientHeight = 388
  ClientWidth = 431
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 360
  end
  inherited btnNew: TButton
    Left = 85
    Top = 360
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 360
  end
  object Panel1: TPanel [3]
    Left = 0
    Top = 0
    Width = 425
    Height = 356
    BevelOuter = bvNone
    TabOrder = 5
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 425
      Height = 356
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Реквизиты'
        object Label1: TLabel
          Left = 4
          Top = 12
          Width = 81
          Height = 13
          Caption = 'Дата договора:'
        end
        object Label5: TLabel
          Left = 4
          Top = 99
          Width = 136
          Height = 13
          Caption = 'Перечислить вал. на счет:'
        end
        object Label6: TLabel
          Left = 4
          Top = 124
          Width = 43
          Height = 13
          Caption = 'в банке:'
        end
        object Label7: TLabel
          Left = 4
          Top = 149
          Width = 128
          Height = 13
          Caption = 'Контрагент-нерезидент:'
        end
        object Label9: TLabel
          Left = 4
          Top = 194
          Width = 287
          Height = 13
          Caption = 'Предмет контракта, номер контракта, дата, код ТНВД:'
        end
        object Label10: TLabel
          Left = 4
          Top = 174
          Width = 103
          Height = 13
          Caption = '% вознаграждения:'
        end
        object Label11: TLabel
          Left = 232
          Top = 13
          Width = 35
          Height = 13
          Caption = 'Номер:'
        end
        object lbBank: TLabel
          Left = 140
          Top = 124
          Width = 3
          Height = 13
        end
        object GroupBox1: TGroupBox
          Left = 5
          Top = 30
          Width = 410
          Height = 56
          TabOrder = 2
          object Label2: TLabel
            Left = 5
            Top = 11
            Width = 43
            Height = 13
            Caption = 'Валюта:'
          end
          object Label3: TLabel
            Left = 135
            Top = 11
            Width = 35
            Height = 13
            Caption = 'Сумма:'
          end
          object Label4: TLabel
            Left = 220
            Top = 11
            Width = 56
            Height = 13
            Caption = 'Макс.курс:'
          end
          object Label8: TLabel
            Left = 295
            Top = 11
            Width = 60
            Height = 13
            Caption = 'Сумма руб.:'
          end
          object iblcCurr: TgsIBLookupComboBox
            Left = 5
            Top = 30
            Width = 126
            Height = 21
            HelpContext = 1
            Database = dmDatabase.ibdbGAdmin
            Transaction = gdc_frmMDHGRAccount.SelfTransaction
            DataSource = dsgdcBase
            DataField = 'currkey'
            ListTable = 'gd_curr'
            ListField = 'SHORTNAME'
            KeyField = 'ID'
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
          end
          object dbedAmountCurr: TDBEdit
            Left = 135
            Top = 30
            Width = 79
            Height = 21
            DataField = 'amountcurr'
            DataSource = dsgdcBase
            TabOrder = 1
          end
          object dbedMaxRate: TDBEdit
            Left = 220
            Top = 30
            Width = 71
            Height = 21
            DataField = 'maxrate'
            DataSource = dsgdcBase
            TabOrder = 2
          end
          object dbedAmountNCU: TDBEdit
            Left = 295
            Top = 30
            Width = 108
            Height = 21
            DataField = 'amountncu'
            DataSource = dsgdcBase
            TabOrder = 3
          end
        end
        object ddbedDocumentDate: TxDateDBEdit
          Left = 140
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
        object iblcAccountKey: TgsIBLookupComboBox
          Left = 140
          Top = 95
          Width = 265
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = gdc_frmMDHGRAccount.SelfTransaction
          DataSource = dsgdcBase
          DataField = 'ACCOUNTKEY'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          OnChange = iblcAccountKeyChange
        end
        object iblcCorrCompKey: TgsIBLookupComboBox
          Left = 140
          Top = 145
          Width = 265
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = gdc_frmMDHGRAccount.SelfTransaction
          DataSource = dsgdcBase
          DataField = 'corrcompkey'
          ListTable = 'GD_CONTACT'
          ListField = 'NAME'
          KeyField = 'ID'
          Condition = 'contacttype in (3, 5)'
          gdClassName = 'TgdcCompany'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object dbmDestination: TDBMemo
          Left = 5
          Top = 210
          Width = 401
          Height = 112
          DataField = 'destination'
          DataSource = dsgdcBase
          TabOrder = 6
        end
        object dbedPercent: TDBEdit
          Left = 140
          Top = 170
          Width = 121
          Height = 21
          DataField = 'percent'
          DataSource = dsgdcBase
          TabOrder = 5
        end
        object dbedNumber: TDBEdit
          Left = 300
          Top = 10
          Width = 104
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
          Width = 417
          Height = 328
          DataSource = dsgdcBase
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
  inherited btnOK: TButton
    Left = 270
    Top = 360
  end
  inherited btnCancel: TButton
    Left = 350
    Top = 360
  end
  inherited alBase: TActionList
    Left = 330
    Top = 275
  end
  inherited dsgdcBase: TDataSource
    Left = 300
    Top = 275
  end
end
