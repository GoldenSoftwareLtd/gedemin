object dlgRemainder: TdlgRemainder
  Left = 177
  Top = 116
  ActiveControl = xddeEntryDate
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Остатки'
  ClientHeight = 354
  ClientWidth = 602
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 36
    Width = 23
    Height = 13
    Caption = 'Счет'
  end
  object Label6: TLabel
    Left = 12
    Top = 10
    Width = 26
    Height = 13
    Caption = 'Дата'
  end
  object Label4: TLabel
    Left = 268
    Top = 36
    Width = 38
    Height = 13
    Caption = 'Валюта'
  end
  object Label8: TLabel
    Left = 13
    Top = 134
    Width = 54
    Height = 13
    Caption = 'Аналитика'
  end
  object gsiblcAccount: TgsIBLookupComboBox
    Left = 112
    Top = 32
    Width = 145
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DataSource = dsEntrys
    DataField = 'ACCOUNTKEY'
    ListTable = 'GD_CARDACCOUNT'
    ListField = 'ALIAS'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnExit = gsiblcAccountExit
  end
  object xddeEntryDate: TxDateDBEdit
    Left = 112
    Top = 6
    Width = 145
    Height = 21
    EditMask = '!99/99/9999;1;_'
    MaxLength = 10
    TabOrder = 1
    Kind = kDate
    DataField = 'ENTRYDATE'
    DataSource = dsEntrys
  end
  object gbDebit: TGroupBox
    Left = 11
    Top = 56
    Width = 247
    Height = 71
    Caption = 'Сумма по дебету'
    TabOrder = 4
    object Label2: TLabel
      Left = 16
      Top = 20
      Width = 34
      Height = 13
      Caption = 'В НДЕ'
    end
    object Label3: TLabel
      Left = 16
      Top = 45
      Width = 47
      Height = 13
      Caption = 'В валюте'
    end
    object dbedDebitSumNCU: TDBEdit
      Left = 101
      Top = 16
      Width = 132
      Height = 21
      DataField = 'DEBITSUMNCU'
      DataSource = dsEntrys
      TabOrder = 0
      OnChange = dbedDebitSumNCUChange
    end
    object dbedDebitSumCurr: TDBEdit
      Left = 101
      Top = 41
      Width = 132
      Height = 21
      DataField = 'DEBITSUMCURR'
      DataSource = dsEntrys
      TabOrder = 1
      OnChange = dbedDebitSumNCUChange
    end
  end
  object gsiblcCurr: TgsIBLookupComboBox
    Left = 312
    Top = 32
    Width = 201
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DataSource = dsEntrys
    DataField = 'CURRKEY'
    ListTable = 'GD_CURR'
    ListField = 'ShortName'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object gbCredit: TGroupBox
    Left = 264
    Top = 56
    Width = 247
    Height = 71
    Caption = 'Сумма по кредиту'
    TabOrder = 5
    object Label5: TLabel
      Left = 16
      Top = 20
      Width = 34
      Height = 13
      Caption = 'В НДЕ'
    end
    object Label7: TLabel
      Left = 16
      Top = 45
      Width = 47
      Height = 13
      Caption = 'В валюте'
    end
    object dbedCreditSumNCU: TDBEdit
      Left = 101
      Top = 16
      Width = 132
      Height = 21
      DataField = 'CREDITSUMNCU'
      DataSource = dsEntrys
      TabOrder = 0
      OnChange = dbedCreditSumNCUChange
    end
    object dbedCreditSumCurr: TDBEdit
      Left = 101
      Top = 41
      Width = 132
      Height = 21
      DataField = 'CREDITSUMCURR'
      DataSource = dsEntrys
      TabOrder = 1
      OnChange = dbedCreditSumNCUChange
    end
  end
  object Button1: TButton
    Left = 522
    Top = 8
    Width = 75
    Height = 25
    Action = actOk
    Default = True
    TabOrder = 7
  end
  object Button2: TButton
    Left = 522
    Top = 36
    Width = 75
    Height = 25
    Action = actNext
    TabOrder = 8
  end
  object Button3: TButton
    Left = 522
    Top = 64
    Width = 75
    Height = 25
    Action = actCancel
    Cancel = True
    TabOrder = 9
  end
  object sbAnalyze: TScrollBox
    Left = 11
    Top = 151
    Width = 501
    Height = 190
    TabOrder = 6
  end
  object bChangeDate: TButton
    Left = 12
    Top = 5
    Width = 100
    Height = 25
    Action = actChangeDate
    TabOrder = 0
  end
  object ActionList1: TActionList
    Left = 534
    Top = 128
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actNext: TAction
      Caption = 'Следующий'
      ShortCut = 45
      OnExecute = actNextExecute
    end
    object actChangeDate: TAction
      Caption = 'Изменить дату'
      Visible = False
      OnExecute = actChangeDateExecute
    end
  end
  object ibdsEntrys: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_entrys'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_entrys'
      '  (ID, ENTRYKEY, TRTYPEKEY, ACCOUNTKEY, ACCOUNTTYPE, ENTRYDATE, '
      'DEBITSUMNCU, '
      '   DEBITSUMCURR, DEBITSUMEQ, CREDITSUMNCU, CREDITSUMCURR, '
      'CREDITSUMEQ, '
      '   CURRKEY, DOCUMENTKEY, POSITIONKEY, COMPANYKEY, DESCRIPTION, '
      'AFULL, ACHAG, '
      '   AVIEW)'
      'values'
      '  (:ID, :ENTRYKEY, :TRTYPEKEY, :ACCOUNTKEY, :ACCOUNTTYPE, '
      ':ENTRYDATE, :DEBITSUMNCU, '
      '   :DEBITSUMCURR, :DEBITSUMEQ, :CREDITSUMNCU, :CREDITSUMCURR, '
      ':CREDITSUMEQ, '
      
        '   :CURRKEY, :DOCUMENTKEY, :POSITIONKEY, :COMPANYKEY, :DESCRIPTI' +
        'ON, '
      ':AFULL, '
      '   :ACHAG, :AVIEW)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_entrys '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_entrys WHERE id = :ek')
    ModifySQL.Strings = (
      'update gd_entrys'
      'set'
      '  ID = :ID,'
      '  ENTRYKEY = :ENTRYKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  ACCOUNTKEY = :ACCOUNTKEY,'
      '  ACCOUNTTYPE = :ACCOUNTTYPE,'
      '  ENTRYDATE = :ENTRYDATE,'
      '  DEBITSUMNCU = :DEBITSUMNCU,'
      '  DEBITSUMCURR = :DEBITSUMCURR,'
      '  DEBITSUMEQ = :DEBITSUMEQ,'
      '  CREDITSUMNCU = :CREDITSUMNCU,'
      '  CREDITSUMCURR = :CREDITSUMCURR,'
      '  CREDITSUMEQ = :CREDITSUMEQ,'
      '  CURRKEY = :CURRKEY,'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  POSITIONKEY = :POSITIONKEY,'
      '  COMPANYKEY = :COMPANYKEY,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW'
      'where'
      '  ID = :OLD_ID')
    Left = 534
    Top = 168
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 534
    Top = 200
  end
  object dsEntrys: TDataSource
    DataSet = ibdsEntrys
    Left = 566
    Top = 168
  end
  object ibsqlAccount: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT * FROM gd_cardaccount WHERE id = :id')
    Transaction = IBTransaction
    Left = 565
    Top = 128
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 534
    Top = 104
  end
end
