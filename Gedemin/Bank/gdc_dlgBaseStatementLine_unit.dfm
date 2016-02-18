inherited gdc_dlgBaseStatementLine: Tgdc_dlgBaseStatementLine
  Left = 324
  Top = 154
  BorderWidth = 5
  Caption = 'Позиция банковской выписки'
  ClientHeight = 335
  ClientWidth = 417
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel [0]
    Left = 8
    Top = 125
    Width = 70
    Height = 13
    Caption = 'Организация:'
    FocusControl = ibcmbCompany
  end
  object Label3: TLabel [1]
    Left = 177
    Top = 52
    Width = 51
    Height = 13
    Caption = '№ док-та'
    FocusControl = edtDocNumber
  end
  object Label4: TLabel [2]
    Left = 251
    Top = 52
    Width = 24
    Height = 13
    Caption = 'Банк'
    FocusControl = dbeBank
  end
  object Label5: TLabel [3]
    Left = 304
    Top = 52
    Width = 25
    Height = 13
    Caption = 'Счет'
    FocusControl = dbeAccount
  end
  object Label6: TLabel [4]
    Left = 8
    Top = 52
    Width = 76
    Height = 13
    Caption = 'Форма расчета'
    FocusControl = edtPaymentMode
  end
  object Label7: TLabel [5]
    Left = 96
    Top = 52
    Width = 70
    Height = 13
    Caption = 'Вид операции'
    FocusControl = edtOperationType
  end
  object Label8: TLabel [6]
    Left = 8
    Top = 196
    Width = 111
    Height = 13
    Caption = 'Назначение платежа:'
    FocusControl = memComment
  end
  object Label9: TLabel [7]
    Left = 8
    Top = 173
    Width = 63
    Height = 13
    Caption = 'КредитНДЕ:'
    FocusControl = edtCSumNCU
  end
  object Label11: TLabel [8]
    Left = 8
    Top = 149
    Width = 60
    Height = 13
    Caption = 'Дебет НДЕ:'
    FocusControl = edtDSumNCU
  end
  object lbInfo: TLabel [9]
    Left = 8
    Top = 2
    Width = 37
    Height = 13
    Caption = '<Acc>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbInfo2: TLabel [10]
    Left = 8
    Top = 18
    Width = 66
    Height = 13
    Caption = '<Company>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbCurrency: TLabel [11]
    Left = 8
    Top = 34
    Width = 38
    Height = 13
    Caption = '<Curr>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel [12]
    Left = 8
    Top = 256
    Width = 115
    Height = 13
    Caption = 'Платежный документ:'
    FocusControl = edDoc
  end
  object lblAcctAccount: TLabel [13]
    Left = 8
    Top = 283
    Width = 91
    Height = 13
    Caption = 'Балансовый счет:'
  end
  object Bevel1: TBevel [14]
    Left = 0
    Top = 305
    Width = 417
    Height = 30
    Align = alBottom
    Shape = bsTopLine
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 314
    TabOrder = 14
  end
  inherited btnNew: TButton
    Left = 71
    Top = 314
    TabOrder = 13
  end
  inherited btnHelp: TButton
    Left = 142
    Top = 314
    TabOrder = 12
  end
  object ibcmbCompany: TgsIBLookupComboBox [18]
    Left = 96
    Top = 121
    Width = 318
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'COMPANYKEYLINE'
    ListTable = 'gd_contact'
    ListField = 'name'
    KeyField = 'id'
    Condition = 'contacttype in (3,5)'
    gdClassName = 'TgdcCompany'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
  end
  object edtDocNumber: TDBEdit [19]
    Left = 177
    Top = 70
    Width = 70
    Height = 21
    DataField = 'DOCNUMBER'
    DataSource = dsgdcBase
    TabOrder = 2
  end
  object edtOperationType: TDBEdit [20]
    Left = 96
    Top = 70
    Width = 77
    Height = 21
    DataField = 'OPERATIONTYPE'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object edtCSumNCU: TDBEdit [21]
    Left = 96
    Top = 169
    Width = 97
    Height = 21
    DataField = 'CSUMNCU'
    DataSource = dsgdcBase
    TabOrder = 7
  end
  object edtDSumNCU: TDBEdit [22]
    Left = 96
    Top = 145
    Width = 97
    Height = 21
    DataField = 'DSUMNCU'
    DataSource = dsgdcBase
    TabOrder = 6
  end
  object edtPaymentMode: TDBEdit [23]
    Left = 8
    Top = 70
    Width = 85
    Height = 21
    DataField = 'PAYMENTMODE'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object memComment: TDBMemo [24]
    Left = 128
    Top = 196
    Width = 286
    Height = 49
    DataField = 'COMMENT'
    DataSource = dsgdcBase
    TabOrder = 8
  end
  inherited btnOK: TButton
    Left = 277
    Top = 314
    TabOrder = 10
  end
  inherited btnCancel: TButton
    Left = 349
    Top = 314
    TabOrder = 11
  end
  object edDoc: TEdit [27]
    Left = 128
    Top = 252
    Width = 286
    Height = 21
    ReadOnly = True
    TabOrder = 9
  end
  object dbeAccount: TDBEdit [28]
    Left = 304
    Top = 70
    Width = 110
    Height = 21
    DataField = 'ACCOUNT'
    DataSource = dsgdcBase
    TabOrder = 4
  end
  object dbeBank: TDBEdit [29]
    Left = 251
    Top = 70
    Width = 49
    Height = 21
    DataField = 'BANKCODE'
    DataSource = dsgdcBase
    TabOrder = 3
  end
  object cbDontRecalc: TCheckBox [30]
    Left = 8
    Top = 96
    Width = 218
    Height = 17
    Caption = 'Не пересчитывать позиции выписки'
    TabOrder = 15
  end
  object iblkAccountKey: TgsIBLookupComboBox [31]
    Left = 128
    Top = 279
    Width = 140
    Height = 21
    HelpContext = 1
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'accountkey'
    ListTable = 'ac_account'
    ListField = 'alias'
    KeyField = 'ID'
    Condition = 'ac_account.accounttype IN ('#39'A'#39', '#39'S'#39')'
    gdClassName = 'TgdcAcctAccount'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 16
  end
  inherited alBase: TActionList
    Left = 374
    Top = 208
    object actDocLink: TAction
      Caption = 'Привязанный документ'
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 344
    Top = 208
  end
  object ibsql: TIBSQL
    Left = 144
    Top = 10
  end
end
