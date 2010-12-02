inherited gdc_dlgCurrRate: Tgdc_dlgCurrRate
  Left = 364
  Top = 315
  HelpContext = 49
  BorderIcons = [biSystemMenu]
  BorderWidth = 5
  Caption = 'Курс валюты'
  ClientHeight = 128
  ClientWidth = 356
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 0
    Top = 30
    Width = 93
    Height = 13
    Caption = 'Из какой валюты:'
  end
  object Label3: TLabel [1]
    Left = 0
    Top = 4
    Width = 81
    Height = 13
    Caption = 'На какую дату:'
  end
  object Label4: TLabel [2]
    Left = 0
    Top = 55
    Width = 88
    Height = 13
    Caption = 'В какую валюту:'
  end
  object Label5: TLabel [3]
    Left = 0
    Top = 79
    Width = 74
    Height = 13
    Caption = 'Коэффициент:'
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 106
    TabOrder = 7
  end
  inherited btnNew: TButton
    Left = 71
    Top = 106
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 216
    Top = 106
    TabOrder = 4
  end
  inherited btnCancel: TButton
    Left = 288
    Top = 106
    TabOrder = 5
  end
  inherited btnHelp: TButton
    Left = 143
    Top = 106
    TabOrder = 8
  end
  object xdbForDate: TxDateDBEdit [9]
    Left = 103
    Top = 0
    Width = 253
    Height = 21
    DataField = 'FORDATE'
    DataSource = dsgdcBase
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 0
  end
  object dbeCoeff: TxDBCalculatorEdit [10]
    Left = 103
    Top = 75
    Width = 253
    Height = 21
    TabOrder = 3
    DataField = 'COEFF'
    DataSource = dsgdcBase
  end
  object dblcbFromCurr: TgsIBLookupComboBox [11]
    Left = 103
    Top = 25
    Width = 253
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'FROMCURR'
    ListTable = 'gd_curr'
    ListField = 'Name'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object dblcbToCurr: TgsIBLookupComboBox [12]
    Left = 103
    Top = 50
    Width = 253
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'ToCurr'
    ListTable = 'gd_curr'
    ListField = 'Name'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  inherited alBase: TActionList
    Left = 185
    Top = 15
  end
  inherited dsgdcBase: TDataSource
    Left = 155
    Top = 15
  end
  inherited pm_dlgG: TPopupMenu
    Left = 256
    Top = 40
  end
end
