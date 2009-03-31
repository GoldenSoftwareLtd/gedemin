inherited gdc_dlgBankStatementLine: Tgdc_dlgBankStatementLine
  Left = 320
  Top = 156
  Anchors = [akLeft, akBottom]
  ClientHeight = 362
  ClientWidth = 416
  PixelsPerInch = 96
  TextHeight = 13
  inherited Label2: TLabel
    Top = 126
  end
  inherited Label3: TLabel
    Left = 176
  end
  inherited Label4: TLabel
    Left = 249
  end
  inherited Label5: TLabel
    Left = 301
  end
  inherited Label8: TLabel
    Top = 197
  end
  inherited Label9: TLabel
    Top = 174
    Width = 66
    Caption = 'Кредит НДЕ:'
  end
  object lbCCurr: TLabel [8]
    Left = 220
    Top = 174
    Width = 67
    Height = 13
    Caption = 'Кредит, вал:'
  end
  inherited Label11: TLabel
    Top = 150
  end
  object lbDCurr: TLabel [10]
    Left = 220
    Top = 150
    Width = 61
    Height = 13
    Caption = 'Дебет, вал:'
  end
  inherited Label1: TLabel
    Top = 284
  end
  object Label10: TLabel [15]
    Left = 8
    Top = 257
    Width = 54
    Height = 13
    Caption = 'Операция:'
  end
  inherited lblAcctAccount: TLabel
    Top = 311
  end
  inherited Bevel1: TBevel
    Top = 332
    Width = 416
  end
  inherited btnAccess: TButton
    Top = 341
    TabOrder = 17
  end
  inherited btnNew: TButton
    Top = 341
    TabOrder = 18
  end
  inherited btnOK: TButton
    Left = 276
    Top = 341
    TabOrder = 15
  end
  inherited ibcmbCompany: TgsIBLookupComboBox
    Top = 122
    ListTable = 'gd_contact c JOIN gd_company cp ON cp.contactkey = c.id'
    TabOrder = 6
  end
  inherited edtDocNumber: TDBEdit
    Left = 176
  end
  object edtCSumCurr: TDBEdit [23]
    Left = 309
    Top = 170
    Width = 105
    Height = 21
    DataField = 'CSUMCURR'
    DataSource = dsgdcBase
    TabOrder = 10
  end
  inherited edtOperationType: TDBEdit
    Width = 75
  end
  object edtDSumCurr: TDBEdit [25]
    Left = 309
    Top = 146
    Width = 105
    Height = 21
    DataField = 'DSUMCURR'
    DataSource = dsgdcBase
    TabOrder = 9
  end
  inherited edtCSumNCU: TDBEdit
    Top = 170
    TabOrder = 8
  end
  inherited edtDSumNCU: TDBEdit
    Top = 146
    TabOrder = 7
  end
  inherited edtPaymentMode: TDBEdit
    Width = 84
  end
  inherited memComment: TDBMemo
    Top = 197
    TabOrder = 11
  end
  inherited btnCancel: TButton
    Left = 348
    Top = 341
    TabOrder = 16
  end
  inherited btnHelp: TButton
    Top = 341
    TabOrder = 19
  end
  inherited edDoc: TEdit
    Top = 280
    TabOrder = 13
  end
  inherited dbeAccount: TDBEdit
    Left = 301
    Width = 111
  end
  object iblkTransaction: TgsIBLookupComboBox [34]
    Left = 128
    Top = 253
    Width = 286
    Height = 21
    HelpContext = 1
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'TRANSACTIONKEY'
    ListTable = 'AC_TRANSACTION'
    ListField = 'NAME'
    KeyField = 'ID'
    Condition = 
      'EXISTS (SELECT * FROM ac_trrecord WHERE ac_transaction.id = ac_t' +
      'rrecord.transactionkey and ac_trrecord.documenttypekey = 800300)'
    ItemHeight = 13
    TabOrder = 12
  end
  inherited dbeBank: TDBEdit
    Left = 249
  end
  inherited cbDontRecalc: TCheckBox
    Top = 101
    TabOrder = 5
  end
  inherited iblkAccountKey: TgsIBLookupComboBox
    Top = 307
    TabOrder = 14
  end
  inherited alBase: TActionList
    Top = 209
  end
  inherited dsgdcBase: TDataSource
    Top = 209
  end
  inherited pm_dlgG: TPopupMenu
    Top = 217
  end
  inherited ibsql: TIBSQL
    Left = 160
  end
end
