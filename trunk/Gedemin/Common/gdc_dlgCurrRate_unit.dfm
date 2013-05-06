inherited gdc_dlgCurrRate: Tgdc_dlgCurrRate
  Left = 637
  Top = 471
  HelpContext = 49
  BorderIcons = [biSystemMenu]
  BorderWidth = 5
  Caption = 'Курс обмена валюты'
  ClientHeight = 106
  ClientWidth = 471
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 2
    Top = 53
    Width = 44
    Height = 13
    Caption = 'За один:'
  end
  object Label3: TLabel [1]
    Left = 2
    Top = 8
    Width = 45
    Height = 13
    Caption = 'На дату:'
  end
  object Label2: TLabel [2]
    Left = 2
    Top = 30
    Width = 128
    Height = 13
    Caption = 'Курс обмена составляет:'
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 84
    TabOrder = 7
  end
  inherited btnNew: TButton
    Left = 71
    Top = 84
    TabOrder = 6
  end
  inherited btnHelp: TButton
    Left = 143
    Top = 84
    TabOrder = 8
  end
  inherited btnOK: TButton
    Left = 331
    Top = 84
    TabOrder = 4
  end
  inherited btnCancel: TButton
    Left = 403
    Top = 84
    TabOrder = 5
  end
  object xdbForDate: TxDateDBEdit [8]
    Left = 52
    Top = 4
    Width = 66
    Height = 21
    DataField = 'FORDATE'
    DataSource = dsgdcBase
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 0
  end
  object dbeCoeff: TxDBCalculatorEdit [9]
    Left = 225
    Top = 49
    Width = 74
    Height = 21
    TabOrder = 2
    DataField = 'COEFF'
    DataSource = dsgdcBase
  end
  object dblcbFromCurr: TgsIBLookupComboBox [10]
    Left = 52
    Top = 49
    Width = 168
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
  object dblcbToCurr: TgsIBLookupComboBox [11]
    Left = 304
    Top = 49
    Width = 168
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
    TabOrder = 3
  end
  inherited alBase: TActionList
    Left = 433
    Top = 7
  end
  inherited dsgdcBase: TDataSource
    Left = 339
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 400
    Top = 8
  end
  inherited ibtrCommon: TIBTransaction
    Left = 368
    Top = 8
  end
end
