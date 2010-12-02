inherited gdc_dlgAcctFolder: Tgdc_dlgAcctFolder
  Left = 363
  Top = 288
  HelpContext = 118
  Caption = 'Раздел плана счетов'
  ClientHeight = 112
  ClientWidth = 407
  PixelsPerInch = 96
  TextHeight = 13
  object lblAlias: TLabel [0]
    Left = 8
    Top = 34
    Width = 122
    Height = 13
    Caption = 'Краткое наименование:'
  end
  object lblName: TLabel [1]
    Left = 8
    Top = 9
    Width = 77
    Height = 13
    Caption = 'Наименование:'
  end
  object Label2: TLabel [2]
    Left = 8
    Top = 59
    Width = 89
    Height = 13
    Caption = 'Входит в раздел:'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 85
    TabOrder = 5
  end
  inherited btnNew: TButton
    Left = 80
    Top = 85
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 257
    Top = 85
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 332
    Top = 85
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 156
    Top = 85
    TabOrder = 7
  end
  object dbedAlias: TDBEdit [8]
    Left = 135
    Top = 30
    Width = 111
    Height = 21
    DataField = 'ALIAS'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object dbedName: TDBEdit [9]
    Left = 135
    Top = 5
    Width = 265
    Height = 21
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object gsiblcGroupAccount: TgsIBLookupComboBox [10]
    Left = 135
    Top = 55
    Width = 266
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGenUniqueID
    DataSource = dsgdcBase
    DataField = 'PARENT'
    ListTable = 'ac_account'
    ListField = 'alias'
    KeyField = 'ID'
    Condition = 
      'ACCOUNTTYPE in ('#39'F'#39', '#39'C'#39') AND exists (SELECT lb FROM ac_account ' +
      'c1 JOIN ac_companyaccount cc ON c1.ID = cc.accountkey  WHERE LB ' +
      '>= c1.lb AND rb <= c1.rb AND cc.companykey IN (<HOLDINGLIST/>) )'
    gdClassName = 'TgdcAcctBase'
    ViewType = vtTree
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  inherited alBase: TActionList
    Left = 70
    Top = 75
  end
  inherited dsgdcBase: TDataSource
    Left = 40
    Top = 75
  end
end
