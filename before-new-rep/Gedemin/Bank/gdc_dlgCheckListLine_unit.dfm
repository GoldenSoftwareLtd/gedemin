inherited gdc_dlgCheckListLine: Tgdc_dlgCheckListLine
  Left = 198
  Top = 195
  Caption = 'Строка реестра чеков'
  ClientHeight = 95
  ClientWidth = 323
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 11
    Top = 14
    Width = 87
    Height = 13
    Caption = 'Счет чекодателя:'
  end
  object Label2: TLabel [1]
    Left = 11
    Top = 39
    Width = 37
    Height = 13
    Caption = 'Сумма:'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 65
    Visible = False
  end
  inherited btnNew: TButton
    Left = 5
    Top = 65
  end
  inherited btnOK: TButton
    Left = 165
    Top = 65
  end
  inherited btnCancel: TButton
    Left = 245
    Top = 65
  end
  inherited btnHelp: TButton
    Left = 85
    Top = 65
  end
  object ibcmbAccount: TgsIBLookupComboBox [7]
    Left = 110
    Top = 10
    Width = 204
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'ACCOUNTKEY'
    ListTable = 'gd_companyaccount'
    ListField = 'account'
    KeyField = 'id'
    gdClassName = 'TgdcAccount'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
  end
  object dbeSumNCU: TDBEdit [8]
    Left = 110
    Top = 35
    Width = 204
    Height = 21
    DataField = 'SUMNCU'
    DataSource = dsgdcBase
    TabOrder = 6
  end
  inherited alBase: TActionList
    Left = 140
    Top = 31
  end
  inherited dsgdcBase: TDataSource
    Left = 110
    Top = 31
  end
end
