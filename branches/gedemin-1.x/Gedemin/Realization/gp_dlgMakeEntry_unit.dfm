object dlgMakeEntry: TdlgMakeEntry
  Left = 274
  Top = 195
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Формирование проводок'
  ClientHeight = 179
  ClientWidth = 341
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 12
    Width = 64
    Height = 13
    Caption = 'Дата начала'
  end
  object Label2: TLabel
    Left = 168
    Top = 12
    Width = 82
    Height = 13
    Caption = 'Дата окончания'
  end
  object Label3: TLabel
    Left = 17
    Top = 136
    Width = 95
    Height = 13
    Caption = 'Обработка данных'
  end
  object xdeDateBegin: TxDateEdit
    Left = 88
    Top = 8
    Width = 65
    Height = 21
    EditMask = '!99/99/9999;1;_'
    MaxLength = 10
    TabOrder = 0
    Text = '11.03.2001'
    Kind = kDate
  end
  object xdeDateEnd: TxDateEdit
    Left = 260
    Top = 8
    Width = 65
    Height = 21
    EditMask = '!99/99/9999;1;_'
    MaxLength = 10
    TabOrder = 1
    Text = '11.03.2001'
    Kind = kDate
  end
  object cbUseOnlyNew: TCheckBox
    Left = 16
    Top = 36
    Width = 177
    Height = 17
    Caption = 'Формировать только новые'
    TabOrder = 2
  end
  object bOk: TButton
    Left = 81
    Top = 107
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = bOkClick
  end
  object bCancel: TButton
    Left = 185
    Top = 107
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object rgTransaction: TRadioGroup
    Left = 16
    Top = 56
    Width = 305
    Height = 41
    Caption = 'Операции'
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      'По документу'
      'По позиции'
      'Все')
    TabOrder = 5
  end
  object ProgressBar: TProgressBar
    Left = 17
    Top = 152
    Width = 313
    Height = 16
    Max = 100
    TabOrder = 6
  end
  object cbCheckTransaction: TCheckBox
    Left = 197
    Top = 36
    Width = 129
    Height = 17
    Caption = 'Проверять операцию'
    TabOrder = 7
  end
  object gsTransaction: TgsTransaction
    DocumentType = 802001
    DataSource = dsRealPos
    FieldName = 'TRTYPEKEY'
    FieldKey = 'ID'
    FieldTrName = 'TRANSACTIONNAME'
    FieldDocumentKey = 'DOCUMENTKEY'
    BeginTransactionType = btManual
    DocumentOnly = False
    MakeDelayedEntry = False
    Left = 136
    Top = 56
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 136
    Top = 88
  end
  object ibdsRealPos: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_DOCREALPOS'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_DOCREALPOS'
      '  (ID, DOCUMENTKEY, GOODKEY, TRTYPEKEY, QUANTITY, MAINQUANTITY, '
      'AMOUNTNCU, '
      '   AMOUNTCURR, AMOUNTEQ, VALUEKEY, WEIGHTKEY, WEIGHT, PACKKEY, '
      'PACKINQUANT, '
      '   PACKQUANTITY, RESERVED)'
      'values'
      
        '  (:ID, :DOCUMENTKEY, :GOODKEY, :TRTYPEKEY, :QUANTITY, :MAINQUAN' +
        'TITY, '
      ':AMOUNTNCU, '
      '   :AMOUNTCURR, :AMOUNTEQ, :VALUEKEY, :WEIGHTKEY, :WEIGHT, '
      ':PACKKEY, :PACKINQUANT, '
      '   :PACKQUANTITY, :RESERVED)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  DOCUMENTKEY,'
      '  GOODKEY,'
      '  TRTYPEKEY,'
      '  QUANTITY,'
      '  MAINQUANTITY,'
      '  AMOUNTNCU,'
      '  AMOUNTCURR,'
      '  AMOUNTEQ,'
      '  VALUEKEY,'
      '  WEIGHTKEY,'
      '  WEIGHT,'
      '  PACKKEY,'
      '  PACKINQUANT,'
      '  PACKQUANTITY,'
      '  RESERVED,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW'
      'from GD_DOCREALPOS '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  docp.id,'
      '  docp.documentkey,'
      '  docp.goodkey,'
      '  docp.trtypekey,'
      '  docp.quantity,'
      '  docp.mainquantity,'
      '  docp.amountncu,'
      '  docp.amountcurr,'
      '  docp.amounteq,'
      '  docp.valuekey,'
      '  docp.weightkey,'
      '  docp.weight,'
      '  docp.packkey,'
      '  docp.packinquant,'
      '  docp.packquantity,'
      '  docp.reserved'
      'FROM'
      '  GD_DOCREALPOS docp '
      'WHERE'
      ' docp.documentkey = :ID')
    ModifySQL.Strings = (
      'update GD_DOCREALPOS'
      'set'
      '  ID = :ID,'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  GOODKEY = :GOODKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  QUANTITY = :QUANTITY,'
      '  MAINQUANTITY = :MAINQUANTITY,'
      '  AMOUNTNCU = :AMOUNTNCU,'
      '  AMOUNTCURR = :AMOUNTCURR,'
      '  AMOUNTEQ = :AMOUNTEQ,'
      '  VALUEKEY = :VALUEKEY,'
      '  WEIGHTKEY = :WEIGHTKEY,'
      '  WEIGHT = :WEIGHT,'
      '  PACKKEY = :PACKKEY,'
      '  PACKINQUANT = :PACKINQUANT,'
      '  PACKQUANTITY = :PACKQUANTITY,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    DataSource = dsDocReal
    Left = 168
    Top = 88
  end
  object dsRealPos: TDataSource
    DataSet = ibdsRealPos
    Left = 168
    Top = 56
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 80
    Top = 56
  end
  object ibdsDocReal: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_DOCUMENT'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_DOCUMENT'
      '  (ID, TRTYPEKEY, NUMBER, DOCUMENTDATE, CURRKEY)'
      'values'
      '  (:ID, :TRTYPEKEY, :NUMBER, :DOCUMENTDATE, :CURRKEY)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  DOCUMENTTYPEKEY,'
      '  TRTYPEKEY,'
      '  NUMBER,'
      '  DOCUMENTDATE,'
      '  DESCRIPTION,'
      '  SUMNCU,'
      '  SUMCURR,'
      '  SUMEQ,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  CURRKEY,'
      '  COMPANYKEY,'
      '  CREATORKEY,'
      '  CREATIONDATE,'
      '  EDITORKEY,'
      '  EDITIONDATE,'
      '  DISABLED,'
      '  RESERVED'
      'from GD_DOCUMENT '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  docr.*,'
      '  doc.*,'
      '  doci.*'
      'FROM'
      ' GD_DOCREALIZATION docr  '
      'JOIN'
      '  GD_DOCUMENT doc ON docr.documentkey = doc.id'
      'JOIN GD_DOCREALINFO doci ON'
      '  docr.documentkey = doci.documentkey'
      'WHERE'
      '  doc.documentdate >= :DateBegin and'
      '  doc.documentdate <= :DateEnd and'
      '  doc.documenttypekey = :dt'
      ''
      ''
      '')
    ModifySQL.Strings = (
      'update GD_DOCUMENT'
      'set'
      '  ID = :ID,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  NUMBER = :NUMBER,'
      '  DOCUMENTDATE = :DOCUMENTDATE,'
      '  CURRKEY = :CURRKEY'
      'where'
      '  ID = :OLD_ID')
    Left = 168
    Top = 120
  end
  object dsDocReal: TDataSource
    DataSet = ibdsDocReal
    Left = 138
    Top = 120
  end
  object ibsqlRecordCount: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT COUNT(*) FROM '
      '  gd_document d '
      'WHERE'
      '  d.documenttypekey = 802001 and'
      '  d.documentdate >= :DateBegin and'
      '  d.documentdate <= :DateEnd')
    Transaction = IBTransaction
    Left = 168
    Top = 152
  end
end
