inherited gdc_dlgTaxName: Tgdc_dlgTaxName
  Left = 338
  Top = 169
  HelpContext = 12
  BorderWidth = 5
  Caption = 'Отчет бухгалтерии'
  ClientHeight = 103
  ClientWidth = 377
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 0
    Top = 74
    Width = 377
    Height = 2
    Align = alTop
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 81
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 72
    Top = 81
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 237
    Top = 81
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 309
    Top = 81
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 81
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object Panel1: TPanel [6]
    Left = 0
    Top = 0
    Width = 377
    Height = 74
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object lblTaxName: TLabel
      Left = 4
      Top = 5
      Width = 138
      Height = 13
      Caption = 'Наименование бух.отчета:'
    end
    object lAutoTransaction: TLabel
      Left = 4
      Top = 30
      Width = 131
      Height = 13
      Caption = 'Хозяйственная операция:'
    end
    object Label3: TLabel
      Left = 4
      Top = 52
      Width = 67
      Height = 13
      Caption = 'План счетов:'
    end
    object dbeTaxName: TDBEdit
      Left = 156
      Top = 1
      Width = 220
      Height = 21
      DataField = 'name'
      DataSource = dsgdcBase
      TabOrder = 0
    end
    object iblAutoTransaction: TgsIBLookupComboBox
      Left = 156
      Top = 24
      Width = 220
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTransaction
      DataSource = dsgdcBase
      DataField = 'TRANSACTIONKEY'
      ListTable = 'ac_transaction'
      ListField = 'name'
      KeyField = 'ID'
      gdClassName = 'TgdcAutoTransaction'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object iblcAccountChart: TgsIBLookupComboBox
      Left = 156
      Top = 48
      Width = 220
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      DataSource = dsgdcBase
      DataField = 'accountkey'
      ListTable = 'ac_account'
      ListField = 'alias'
      KeyField = 'ID'
      SortOrder = soAsc
      Condition = 
        'accounttype = '#39'C'#39' and EXISTS (SELECT * FROM ac_companyaccount c ' +
        'WHERE c.accountkey = ac_account.id)'
      gdClassName = 'TgdcAcctChart'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
  end
  inherited alBase: TActionList
    Left = 62
    Top = 65535
  end
  inherited dsgdcBase: TDataSource
    Left = 24
    Top = 65535
  end
  inherited pm_dlgG: TPopupMenu
    Left = 96
    Top = 0
  end
  object IBTransaction: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 128
  end
end
