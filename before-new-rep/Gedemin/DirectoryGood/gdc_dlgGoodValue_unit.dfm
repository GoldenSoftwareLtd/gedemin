inherited gdc_dlgGoodValue: Tgdc_dlgGoodValue
  Left = 357
  Top = 215
  HelpContext = 41
  Caption = 'Единица измерения'
  ClientHeight = 128
  ClientWidth = 327
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 9
    Width = 77
    Height = 13
    Caption = 'Наименование:'
  end
  object Label2: TLabel [1]
    Left = 8
    Top = 34
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  object Label3: TLabel [2]
    Left = 8
    Top = 59
    Width = 26
    Height = 13
    Caption = 'ТМЦ:'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 100
    TabOrder = 5
    Visible = False
  end
  inherited btnNew: TButton
    Left = 9
    Top = 100
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 178
    Top = 100
    TabOrder = 7
  end
  inherited btnCancel: TButton
    Left = 253
    Top = 100
    TabOrder = 8
  end
  inherited btnHelp: TButton
    Left = 84
    Top = 100
  end
  object dbeName: TDBEdit [8]
    Left = 110
    Top = 5
    Width = 211
    Height = 21
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbedDescription: TDBEdit [9]
    Left = 110
    Top = 30
    Width = 211
    Height = 21
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object gsIBLookupComboBox1: TgsIBLookupComboBox [10]
    Left = 110
    Top = 55
    Width = 211
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGenUniqueID
    DataSource = dsgdcBase
    DataField = 'GOODKEY'
    ListTable = 'GD_GOOD'
    ListField = 'NAME'
    KeyField = 'ID'
    gdClassName = 'TgdcGood'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  object DBCheckBox1: TDBCheckBox [11]
    Left = 110
    Top = 80
    Width = 165
    Height = 17
    Caption = 'Используется для упаковки'
    DataField = 'ISPACK'
    DataSource = dsgdcBase
    TabOrder = 3
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  inherited alBase: TActionList
    Left = 60
    Top = 30
  end
  inherited dsgdcBase: TDataSource
    Left = 30
    Top = 30
  end
end
