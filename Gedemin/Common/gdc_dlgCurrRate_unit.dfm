inherited gdc_dlgCurrRate: Tgdc_dlgCurrRate
  Top = 471
  HelpContext = 49
  BorderIcons = [biSystemMenu]
  BorderWidth = 5
  Caption = 'Курс обмена валюты'
  ClientHeight = 146
  ClientWidth = 476
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 6
    Top = 56
    Width = 16
    Height = 13
    Caption = 'За:'
  end
  object Label3: TLabel [1]
    Left = 6
    Top = 8
    Width = 45
    Height = 13
    Caption = 'На дату:'
  end
  object Label2: TLabel [2]
    Left = 6
    Top = 34
    Width = 128
    Height = 13
    Caption = 'Курс обмена составляет:'
  end
  object Label4: TLabel [3]
    Left = 6
    Top = 80
    Width = 114
    Height = 13
    Caption = 'Кем установлен курс: '
  end
  object Label5: TLabel [4]
    Left = 120
    Top = 100
    Width = 196
    Height = 13
    Caption = '(поле необязательно для заполнения)'
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 124
    TabOrder = 11
  end
  inherited btnNew: TButton
    Left = 71
    Top = 124
    TabOrder = 10
  end
  inherited btnHelp: TButton
    Left = 143
    Top = 124
    TabOrder = 12
  end
  inherited btnOK: TButton
    Left = 333
    Top = 124
    TabOrder = 8
  end
  inherited btnCancel: TButton
    Left = 405
    Top = 124
    TabOrder = 9
  end
  object xdbForDate: TxDateDBEdit [10]
    Left = 56
    Top = 6
    Width = 66
    Height = 21
    DataField = 'FORDATE'
    DataSource = dsgdcBase
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 0
  end
  object dbeVal: TxDBCalculatorEdit [11]
    Left = 247
    Top = 52
    Width = 74
    Height = 21
    TabOrder = 5
    DataField = 'VAL'
    DataSource = dsgdcBase
  end
  object dblcbFromCurr: TgsIBLookupComboBox [12]
    Left = 87
    Top = 52
    Width = 152
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
    TabOrder = 4
  end
  object dblcbToCurr: TgsIBLookupComboBox [13]
    Left = 323
    Top = 52
    Width = 152
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
    TabOrder = 6
  end
  object chbxTime: TCheckBox [14]
    Left = 129
    Top = 8
    Width = 57
    Height = 17
    Caption = 'Время'
    TabOrder = 1
    OnClick = chbxTimeClick
  end
  object xdeTime: TxDateEdit [15]
    Left = 184
    Top = 6
    Width = 66
    Height = 21
    Kind = kTime
    EmptyAtStart = True
    EditMask = '!99\:99\:99;1;_'
    MaxLength = 8
    TabOrder = 2
    Text = '  :  :  '
  end
  object iblkupRegulator: TgsIBLookupComboBox [16]
    Left = 120
    Top = 78
    Width = 200
    Height = 21
    HelpContext = 1
    DataSource = dsgdcBase
    DataField = 'regulatorkey'
    ListTable = 'GD_COMPANY'
    ListField = 'FULLNAME'
    KeyField = 'CONTACTKEY'
    ItemHeight = 13
    TabOrder = 7
  end
  object xdbeAmount: TxDBCalculatorEdit [17]
    Left = 33
    Top = 52
    Width = 52
    Height = 21
    TabOrder = 3
    DecDigits = 0
    DataField = 'AMOUNT'
    DataSource = dsgdcBase
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
