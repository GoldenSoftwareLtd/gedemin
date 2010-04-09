object dlgAddSimpleDoc: TdlgAddSimpleDoc
  Left = 261
  Top = 151
  ActiveControl = gstcbTransaction
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Произвольный документ'
  ClientHeight = 282
  ClientWidth = 513
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 40
    Width = 91
    Height = 13
    Caption = 'Номер документа'
  end
  object Label2: TLabel
    Left = 248
    Top = 40
    Width = 83
    Height = 13
    Caption = 'Дата документа'
  end
  object Label3: TLabel
    Left = 16
    Top = 66
    Width = 70
    Height = 13
    Caption = 'Сумма в НДЕ'
  end
  object Label5: TLabel
    Left = 16
    Top = 118
    Width = 70
    Height = 13
    Caption = 'Комментарий'
  end
  object lAmountCurr: TLabel
    Left = 248
    Top = 92
    Width = 67
    Height = 13
    Caption = 'Сумма в вал.'
  end
  object lCurr: TLabel
    Left = 248
    Top = 66
    Width = 38
    Height = 13
    Caption = 'Валюта'
  end
  object lRate: TLabel
    Left = 16
    Top = 92
    Width = 24
    Height = 13
    Caption = 'Курс'
  end
  object Label4: TLabel
    Left = 16
    Top = 14
    Width = 50
    Height = 13
    Caption = 'Операция'
  end
  object Label6: TLabel
    Left = 16
    Top = 142
    Width = 54
    Height = 13
    Caption = 'Аналитика'
  end
  object dbedDocumentNumber: TDBEdit
    Left = 119
    Top = 36
    Width = 121
    Height = 21
    DataField = 'NUMBER'
    DataSource = dsDocument
    TabOrder = 1
  end
  object xddbedDocumentDate: TxDateDBEdit
    Left = 344
    Top = 36
    Width = 73
    Height = 21
    EditMask = '!99/99/9999;1;_'
    MaxLength = 10
    TabOrder = 2
    Kind = kDate
    DataField = 'DOCUMENTDATE'
    DataSource = dsDocument
  end
  object dbedSumNDE: TDBEdit
    Left = 119
    Top = 62
    Width = 121
    Height = 21
    DataField = 'SUMNCU'
    DataSource = dsDocument
    TabOrder = 3
    OnExit = dbedSumNDEExit
  end
  object dbedDescription: TDBEdit
    Left = 119
    Top = 114
    Width = 297
    Height = 21
    DataField = 'DESCRIPTION'
    DataSource = dsDocument
    TabOrder = 7
  end
  object btnOk: TButton
    Left = 428
    Top = 10
    Width = 75
    Height = 25
    Action = actOk
    Default = True
    TabOrder = 9
  end
  object btnNext: TButton
    Left = 428
    Top = 42
    Width = 75
    Height = 25
    Action = actNext
    TabOrder = 10
  end
  object btnCancel: TButton
    Left = 428
    Top = 74
    Width = 75
    Height = 25
    Action = actCancel
    Cancel = True
    TabOrder = 11
  end
  object dbedSumCurr: TDBEdit
    Left = 344
    Top = 88
    Width = 73
    Height = 21
    DataField = 'SUMCURR'
    DataSource = dsDocument
    TabOrder = 6
    OnExit = dbedSumCurrExit
  end
  object gsiblcCurr: TgsIBLookupComboBox
    Left = 344
    Top = 62
    Width = 74
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DataSource = dsDocument
    DataField = 'CURRKEY'
    ListTable = 'GD_CURR'
    ListField = 'ShortName'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnChange = gsiblcCurrChange
  end
  object edRate: TEdit
    Left = 119
    Top = 88
    Width = 121
    Height = 21
    TabOrder = 5
    OnExit = edRateExit
  end
  object btnEntry: TButton
    Left = 428
    Top = 158
    Width = 75
    Height = 25
    Action = actEntry
    TabOrder = 12
  end
  object gstcbTransaction: TgsTransactionComboBox
    Left = 119
    Top = 9
    Width = 298
    Height = 21
    Hint = 
      'Используйте клавиши: '#13#10'     F4 - просмотр и редактирование прово' +
      'док.'
    Style = csDropDownList
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    GTransaction = gsTransaction
    DataSource = dsDocument
    DataField = 'TRTYPEKEY'
  end
  object sbAnalyze: TScrollBox
    Left = 16
    Top = 158
    Width = 401
    Height = 113
    TabOrder = 8
  end
  object ActionList1: TActionList
    Left = 440
    Top = 120
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actNext: TAction
      Caption = 'Следующий'
      ShortCut = 45
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actEntry: TAction
      Caption = 'Проводка...'
      OnExecute = actEntryExecute
      OnUpdate = actEntryUpdate
    end
    object actCurrnecyEnabled: TAction
      Caption = 'actCurrnecyEnabled'
    end
  end
  object ibdsDocument: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_document'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_document'
      '  (ID, DOCUMENTTYPEKEY, TRTYPEKEY, NUMBER, DOCUMENTDATE, '
      'DESCRIPTION, '
      '   SUMNCU, SUMCURR, SUMEQ, AFULL, ACHAG, AVIEW, CURRKEY, '
      'COMPANYKEY, CREATORKEY, '
      '   CREATIONDATE, EDITORKEY, EDITIONDATE, DISABLED, RESERVED)'
      'values'
      '  (:ID, :DOCUMENTTYPEKEY, :TRTYPEKEY, :NUMBER, :DOCUMENTDATE, '
      ':DESCRIPTION, '
      '   :SUMNCU, :SUMCURR, :SUMEQ, :AFULL, :ACHAG, :AVIEW, :CURRKEY, '
      ':COMPANYKEY, '
      
        '   :CREATORKEY, :CREATIONDATE, :EDITORKEY, :EDITIONDATE, :DISABL' +
        'ED, '
      ':RESERVED)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_document '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_document'
      '   WHERE id = :dk')
    ModifySQL.Strings = (
      'update gd_document'
      'set'
      '  ID = :ID,'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  NUMBER = :NUMBER,'
      '  DOCUMENTDATE = :DOCUMENTDATE,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  SUMNCU = :SUMNCU,'
      '  SUMCURR = :SUMCURR,'
      '  SUMEQ = :SUMEQ,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  CURRKEY = :CURRKEY,'
      '  COMPANYKEY = :COMPANYKEY,'
      '  CREATORKEY = :CREATORKEY,'
      '  CREATIONDATE = :CREATIONDATE,'
      '  EDITORKEY = :EDITORKEY,'
      '  EDITIONDATE = :EDITIONDATE,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    Left = 480
    Top = 160
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 480
    Top = 192
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 448
    Top = 160
  end
  object gsTransaction: TgsTransaction
    DocumentType = 801000
    DataSource = dsDocument
    FieldName = 'TRTYPEKEY'
    FieldKey = 'ID'
    FieldTrName = 'TRANSACTIONNAME'
    FieldDocumentKey = 'ID'
    DocumentOnly = False
    MakeDelayedEntry = False
    Left = 448
    Top = 192
  end
end
