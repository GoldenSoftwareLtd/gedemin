inherited gdc_dlgBankCatalogueLine: Tgdc_dlgBankCatalogueLine
  Left = 325
  Top = 145
  Caption = 'Строка банковской картотеки'
  ClientHeight = 283
  ClientWidth = 333
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 181
    Width = 70
    Height = 13
    Caption = 'Организация:'
  end
  object Label2: TLabel [1]
    Left = 8
    Top = 110
    Width = 35
    Height = 13
    Caption = 'Сумма:'
  end
  object Label3: TLabel [2]
    Left = 8
    Top = 63
    Width = 79
    Height = 13
    Caption = 'Назн. платежа:'
    FocusControl = dbePaymentDest
  end
  object Label4: TLabel [3]
    Left = 8
    Top = 15
    Width = 75
    Height = 13
    Caption = 'Дата акцепта:'
  end
  object Label5: TLabel [4]
    Left = 8
    Top = 86
    Width = 29
    Height = 13
    Caption = 'Пеня:'
  end
  object Label6: TLabel [5]
    Left = 8
    Top = 134
    Width = 29
    Height = 13
    Caption = 'Счет:'
  end
  object Label7: TLabel [6]
    Left = 8
    Top = 158
    Width = 57
    Height = 13
    Caption = 'Код банка:'
  end
  object Label8: TLabel [7]
    Left = 8
    Top = 39
    Width = 93
    Height = 13
    Caption = 'Номер документа:'
  end
  object Label9: TLabel [8]
    Left = 8
    Top = 205
    Width = 71
    Height = 13
    Caption = 'Комментарий:'
  end
  object Label10: TLabel [9]
    Left = 8
    Top = 252
    Width = 124
    Height = 13
    Caption = 'Привязанный документ:'
  end
  inherited btnAccess: TButton
    Left = 240
    Top = 68
    TabOrder = 12
  end
  inherited btnNew: TButton
    Left = 240
    Top = 94
    TabOrder = 13
  end
  inherited btnOK: TButton
    Left = 240
    Top = 5
    TabOrder = 10
  end
  object dbeDocNumber: TDBEdit [13]
    Left = 104
    Top = 32
    Width = 121
    Height = 21
    DataField = 'DOCNUMBER'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object dbePaymentDest: TDBEdit [14]
    Left = 104
    Top = 56
    Width = 121
    Height = 21
    DataField = 'PAYMENTDEST'
    DataSource = dsgdcBase
    TabOrder = 2
  end
  object dbeFine: TxDBCalculatorEdit [15]
    Left = 104
    Top = 80
    Width = 121
    Height = 21
    TabOrder = 3
    DataField = 'FINE'
    DataSource = dsgdcBase
  end
  object dbeSumNCU: TxDBCalculatorEdit [16]
    Left = 104
    Top = 104
    Width = 121
    Height = 21
    TabOrder = 4
    DataField = 'SUMNCULINE'
    DataSource = dsgdcBase
  end
  object dbeAccount: TDBEdit [17]
    Left = 104
    Top = 128
    Width = 121
    Height = 21
    DataField = 'ACCOUNT'
    DataSource = dsgdcBase
    TabOrder = 5
  end
  object dbeBankCode: TDBEdit [18]
    Left = 104
    Top = 152
    Width = 121
    Height = 21
    DataField = 'BANKCODE'
    DataSource = dsgdcBase
    TabOrder = 6
  end
  object dbmComment: TDBMemo [19]
    Left = 104
    Top = 200
    Width = 217
    Height = 43
    DataField = 'COMMENT'
    DataSource = dsgdcBase
    TabOrder = 8
  end
  object ibcmbCompany: TgsIBLookupComboBox [20]
    Left = 104
    Top = 176
    Width = 217
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'COMPANYKEYLINE'
    ListTable = 'gd_contact c JOIN gd_company cp ON cp.contactkey = c.id'
    ListField = 'name'
    KeyField = 'id'
    Condition = 'contacttype=3'
    gdClassName = 'TgdcCompany'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
  end
  inherited btnCancel: TButton
    Left = 240
    Top = 31
    TabOrder = 11
  end
  inherited btnHelp: TButton
    Left = 240
    Top = 120
    TabOrder = 14
  end
  object dbeAcceptDate: TxDateDBEdit [23]
    Left = 103
    Top = 7
    Width = 122
    Height = 21
    DataField = 'ACCEPTDATE'
    DataSource = dsgdcBase
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 0
  end
  object edtDocLink: TEdit [24]
    Left = 144
    Top = 249
    Width = 177
    Height = 21
    ReadOnly = True
    TabOrder = 9
  end
  inherited alBase: TActionList
    Left = 294
    Top = 143
  end
  inherited dsgdcBase: TDataSource
    Left = 266
    Top = 143
  end
  inherited ibtrCommon: TIBTransaction
    Left = 80
    Top = 88
  end
  object ibsql: TIBSQL
    Left = 72
    Top = 114
  end
end
