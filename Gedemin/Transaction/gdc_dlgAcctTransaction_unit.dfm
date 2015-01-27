inherited gdc_dlgAcctTransaction: Tgdc_dlgAcctTransaction
  Left = 369
  Top = 253
  ActiveControl = dbedName
  BorderIcons = [biSystemMenu]
  Caption = 'Типовая операция'
  ClientHeight = 282
  ClientWidth = 420
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 11
    Top = 10
    Width = 85
    Height = 27
    AutoSize = False
    Caption = 'Наименование операции:'
    WordWrap = True
  end
  object Label2: TLabel [1]
    Left = 11
    Top = 40
    Width = 55
    Height = 33
    AutoSize = False
    Caption = 'Описание операции:'
    WordWrap = True
  end
  object Label3: TLabel [2]
    Left = 11
    Top = 144
    Width = 70
    Height = 37
    AutoSize = False
    Caption = 'Операция только для компании:'
    WordWrap = True
  end
  object Bevel1: TBevel [3]
    Left = 1
    Top = 246
    Width = 420
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object Label4: TLabel [4]
    Left = 11
    Top = 121
    Width = 50
    Height = 13
    Caption = 'Входит в:'
  end
  inherited btnAccess: TButton
    Top = 255
    TabOrder = 7
  end
  inherited btnNew: TButton
    Left = 85
    Top = 255
    TabOrder = 8
  end
  inherited btnHelp: TButton
    Left = 160
    Top = 255
    TabOrder = 9
  end
  inherited btnOK: TButton
    Left = 267
    Top = 255
    TabOrder = 5
  end
  inherited btnCancel: TButton
    Left = 342
    Top = 255
    TabOrder = 6
  end
  object dbedName: TDBEdit [10]
    Left = 105
    Top = 11
    Width = 306
    Height = 21
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [11]
    Left = 105
    Top = 40
    Width = 306
    Height = 73
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object gsibluCompany: TgsIBLookupComboBox [12]
    Left = 105
    Top = 145
    Width = 306
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'COMPANYKEY'
    ListTable = 
      'gd_contact JOIN gd_ourcompany ourc ON gd_contact.id = ourc.compa' +
      'nykey'
    ListField = 'name'
    KeyField = 'id'
    gdClassName = 'TgdcOurCompany'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object iblcParent: TgsIBLookupComboBox [13]
    Left = 105
    Top = 117
    Width = 306
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'PARENT'
    ListTable = 'ac_transaction'
    ListField = 'name'
    KeyField = 'ID'
    Condition = 
      '(ac_transaction.AUTOTRANSACTION IS NULL OR ac_transaction.AUTOTR' +
      'ANSACTION = 0)'
    gdClassName = 'TgdcAcctTransaction'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  object btnAdd: TButton [14]
    Left = 105
    Top = 217
    Width = 184
    Height = 21
    Action = actAddTypeEntry
    TabOrder = 4
  end
  object dbcbIsInternal: TDBCheckBox [15]
    Left = 104
    Top = 168
    Width = 137
    Height = 17
    Hint = 
      'Проводки по данной операции не отражаются в оборотах в оборотной' +
      ' ведомости'
    Caption = 'Внутренняя операция'
    DataField = 'ISINTERNAL'
    DataSource = dsgdcBase
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbcbIsDisabled: TDBCheckBox [16]
    Left = 104
    Top = 192
    Width = 185
    Height = 17
    Caption = 'Типовая операция отключена'
    DataField = 'DISABLED'
    DataSource = dsgdcBase
    TabOrder = 11
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  inherited alBase: TActionList
    Left = 380
    Top = 149
    object actAddTypeEntry: TAction
      Caption = 'Добавить типовую проводку...'
      OnExecute = actAddTypeEntryExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 350
    Top = 149
  end
  inherited pm_dlgG: TPopupMenu
    Top = 104
  end
  inherited ibtrCommon: TIBTransaction
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Left = 320
    Top = 157
  end
  object gdcAcctTransactionEntry: TgdcAcctTransactionEntry
    MasterSource = dsgdcBase
    MasterField = 'ID'
    DetailField = 'TransactionKey'
    SubSet = 'ByTransaction'
    Left = 373
    Top = 188
  end
end
