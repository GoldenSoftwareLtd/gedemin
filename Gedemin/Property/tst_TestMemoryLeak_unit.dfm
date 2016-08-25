object TestMemoryLeak: TTestMemoryLeak
  Left = 129
  Top = 149
  Width = 544
  Height = 375
  Caption = 'TestMemoryLeak'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 143
    Top = 13
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 143
    Top = 39
    Width = 32
    Height = 13
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 143
    Top = 65
    Width = 32
    Height = 13
    Caption = 'Label3'
  end
  object Label4: TLabel
    Left = 143
    Top = 91
    Width = 32
    Height = 13
    Caption = 'Label4'
  end
  object Label5: TLabel
    Left = 143
    Top = 117
    Width = 32
    Height = 13
    Caption = 'Label5'
  end
  object Button1: TButton
    Left = 20
    Top = 7
    Width = 111
    Height = 20
    Caption = 'ReportScriptControl'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 20
    Top = 33
    Width = 111
    Height = 20
    Caption = 'ScriptFactory'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 20
    Top = 59
    Width = 111
    Height = 20
    Caption = 'gdcInvDocument'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 20
    Top = 85
    Width = 111
    Height = 20
    Caption = 'IBDataSet'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 20
    Top = 111
    Width = 111
    Height = 20
    Caption = 'IBDataSet Create'
    TabOrder = 4
    OnClick = Button5Click
  end
  object gdcInvDocument1: TgdcInvDocument
    Transaction = IBTransaction1
    CachedUpdates = False
    ReadTransaction = IBTransaction1
    Left = 240
    Top = 72
  end
  object gdcInvDocumentLine1: TgdcInvDocumentLine
    Transaction = dmDatabase.ibtrGenUniqueID
    MasterSource = DataSource1
    MasterField = 'ID'
    DetailField = 'PARENT'
    SubSet = 'ByParent'
    CachedUpdates = False
    ReadTransaction = IBTransaction1
    Left = 272
    Top = 72
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 336
    Top = 72
  end
  object DataSource1: TDataSource
    DataSet = gdcInvDocument1
    Left = 304
    Top = 72
  end
  object ibdsDoc: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_DOCUMENT'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_DOCUMENT'
      
        '  (RESERVED, ID, PARENT, DOCUMENTTYPEKEY, TRTYPEKEY, TRANSACTION' +
        'KEY, NUMBER, '
      
        '   DOCUMENTDATE, DESCRIPTION, SUMNCU, SUMCURR, DELAYED, AFULL, A' +
        'CHAG, AVIEW, '
      
        '   CURRKEY, COMPANYKEY, CREATORKEY, CREATIONDATE, EDITORKEY, EDI' +
        'TIONDATE, '
      '   PRINTDATE, DISABLED)'
      'values'
      
        '  (:RESERVED, :ID, :PARENT, :DOCUMENTTYPEKEY, :TRTYPEKEY, :TRANS' +
        'ACTIONKEY, '
      
        '   :NUMBER, :DOCUMENTDATE, :DESCRIPTION, :SUMNCU, :SUMCURR, :DEL' +
        'AYED, :AFULL, '
      
        '   :ACHAG, :AVIEW, :CURRKEY, :COMPANYKEY, :CREATORKEY, :CREATION' +
        'DATE, :EDITORKEY, '
      '   :EDITIONDATE, :PRINTDATE, :DISABLED)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  PARENT,'
      '  DOCUMENTTYPEKEY,'
      '  TRTYPEKEY,'
      '  TRANSACTIONKEY,'
      '  NUMBER,'
      '  DOCUMENTDATE,'
      '  DESCRIPTION,'
      '  SUMNCU,'
      '  SUMCURR,'
      '  SUMEQ,'
      '  DELAYED,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  CURRKEY,'
      '  COMPANYKEY,'
      '  CREATORKEY,'
      '  CREATIONDATE,'
      '  EDITORKEY,'
      '  EDITIONDATE,'
      '  PRINTDATE,'
      '  DISABLED,'
      '  RESERVED'
      'from GD_DOCUMENT '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  Z.*, '
      'INVDOC.USR$CUSTOMERKEY, '
      'INVDOC_USR$CUSTOMERKEY.NAME AS INVDOC_USR$CUSTOMERKEY_NAME, '
      'INVDOC.USR$DELIVERYKEY, '
      
        'INVDOC_USR$DELIVERYKEY.USR$NAME AS INVDOC_USR$DELIVERYKEY_USR$NA' +
        'ME, '
      'INVDOC.USR$DEPRTKEY, '
      'INVDOC_USR$DEPRTKEY.NAME AS INVDOC_USR$DEPRTKEY_NAME, '
      'INVDOC.USR$STATE, '
      '  INVDOC.USR$TERMSUPPLY'
      ''
      'FROM '
      '  GD_DOCUMENT Z'
      'RIGHT JOIN '
      'USR$CLAIMCUST INVDOC'
      'ON '
      '(Z.ID = INVDOC.DOCUMENTKEY)'
      'LEFT JOIN '
      'GD_CONTACT INVDOC_USR$CUSTOMERKEY'
      'ON '
      'INVDOC_USR$CUSTOMERKEY.ID = INVDOC.USR$CUSTOMERKEY'
      'LEFT JOIN '
      'USR$TYPEDELIVERY INVDOC_USR$DELIVERYKEY'
      'ON '
      'INVDOC_USR$DELIVERYKEY.ID = INVDOC.USR$DELIVERYKEY'
      'LEFT JOIN '
      'GD_CONTACT INVDOC_USR$DEPRTKEY'
      'ON '
      'INVDOC_USR$DEPRTKEY.ID = INVDOC.USR$DEPRTKEY'
      ''
      'WHERE '
      '  Z.DOCUMENTTYPEKEY = 147681010'
      'AND '
      'Z.COMPANYKEY = 147000007'
      'AND '
      'G_SEC_TEST(Z.AVIEW, -1) <> 0')
    ModifySQL.Strings = (
      'update GD_DOCUMENT'
      'set'
      '  RESERVED = :RESERVED,'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  TRANSACTIONKEY = :TRANSACTIONKEY,'
      '  NUMBER = :NUMBER,'
      '  DOCUMENTDATE = :DOCUMENTDATE,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  SUMNCU = :SUMNCU,'
      '  SUMCURR = :SUMCURR,'
      '  DELAYED = :DELAYED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  CURRKEY = :CURRKEY,'
      '  COMPANYKEY = :COMPANYKEY,'
      '  CREATORKEY = :CREATORKEY,'
      '  CREATIONDATE = :CREATIONDATE,'
      '  EDITORKEY = :EDITORKEY,'
      '  EDITIONDATE = :EDITIONDATE,'
      '  PRINTDATE = :PRINTDATE,'
      '  DISABLED = :DISABLED'
      'where'
      '  ID = :OLD_ID')
    Left = 240
    Top = 104
  end
  object ibdsDocLine: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_DOCUMENT'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_DOCUMENT'
      '  (ID, PARENT, DOCUMENTTYPEKEY, '
      
        '   TRTYPEKEY, TRANSACTIONKEY, NUMBER, DOCUMENTDATE, DESCRIPTION,' +
        ' SUMNCU, '
      
        '   SUMCURR, DELAYED, AFULL, ACHAG, AVIEW, CURRKEY, COMPANYKEY, C' +
        'REATORKEY, '
      '   CREATIONDATE, EDITORKEY, EDITIONDATE, PRINTDATE)'
      'values'
      
        '  (:ID, :PARENT, :DOCUMENTTYPEKEY, :TRTYPEKEY, :TRANSACTIONKEY, ' +
        ':NUMBER, '
      
        '   :DOCUMENTDATE, :DESCRIPTION, :SUMNCU, :SUMCURR, :DELAYED, :AF' +
        'ULL, :ACHAG, '
      
        '   :AVIEW, :CURRKEY, :COMPANYKEY, :CREATORKEY, :CREATIONDATE, :E' +
        'DITORKEY, '
      '   :EDITIONDATE, :PRINTDATE)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  PARENT,'
      '  DOCUMENTTYPEKEY,'
      '  TRTYPEKEY,'
      '  TRANSACTIONKEY,'
      '  NUMBER,'
      '  DOCUMENTDATE,'
      '  DESCRIPTION,'
      '  SUMNCU,'
      '  SUMCURR,'
      '  SUMEQ,'
      '  DELAYED,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  CURRKEY,'
      '  COMPANYKEY,'
      '  CREATORKEY,'
      '  CREATIONDATE,'
      '  EDITORKEY,'
      '  EDITIONDATE,'
      '  PRINTDATE,'
      '  DISABLED,'
      '  RESERVED'
      'from GD_DOCUMENT '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  CARD.GOODKEY, '
      'CARD.USR$CLAIMKEY AS TO_USR$CLAIMKEY, '
      'CARD.USR$CUSTOMERKEY AS TO_USR$CUSTOMERKEY, '
      'CARD.USR$PRICECLAIM AS TO_USR$PRICECLAIM, '
      'CARD.USR$RECEVERKEY AS TO_USR$RECEVERKEY, '
      'V.NAME, G.NAME AS GOODNAME, '
      'G.ALIAS AS GOODALIAS, '
      'G.VALUEKEY, '
      'INVLINE.DISABLED, '
      'INVLINE.DOCUMENTKEY, '
      'INVLINE.FROMCARDKEY, '
      'INVLINE.MASTERKEY, '
      'INVLINE.QUANTITY, '
      'INVLINE.REMAINS, '
      'INVLINE.RESERVED, '
      'Z.ID, '
      'Z.PARENT, '
      'Z.DOCUMENTTYPEKEY, '
      'Z.TRTYPEKEY, '
      'Z.TRANSACTIONKEY, '
      'Z.NUMBER, '
      'Z.DOCUMENTDATE, '
      'Z.DESCRIPTION, '
      'Z.SUMNCU, '
      'Z.SUMCURR, '
      'Z.DELAYED, '
      'Z.AFULL, '
      'Z.ACHAG, '
      'Z.AVIEW, '
      'Z.CURRKEY, '
      'Z.COMPANYKEY, '
      'Z.CREATORKEY, '
      'Z.CREATIONDATE, '
      'Z.EDITORKEY, '
      'Z.EDITIONDATE, '
      'Z.PRINTDATE, '
      'Z.DISABLED, '
      'Z.RESERVED, '
      'INVLINE.USR$DELIVERYKEY, '
      
        'INVLINE_USR$DELIVERYKEY.USR$NAME AS INVLINE_USR$DELIVERYKEY_USR$' +
        'NAME, '
      'INVLINE.USR$NUMBER, '
      'INVLINE.USR$PRICE, '
      'INVLINE.USR$PRICEAVIO, '
      'INVLINE.USR$PRICEEXPRESS, '
      'INVLINE.USR$STATE, '
      'INVLINE.USR$TERMDELIVERY, '
      'G.USR$DANGER, '
      'G.USR$DEMNAME, '
      'G.USR$DRT, G.USR$FACTORY, '
      'G_USR$FACTORY.USR$NUMBER AS G_USR$FACTORY_USR$NUMBER, '
      'G.USR$GROUPPRIZNAK, '
      'G.USR$LAGORT, '
      'G.USR$LP, '
      'G.USR$MINCOUNT, '
      'G.USR$RABATTGRUPPE, '
      'G_USR$RABATTGRUPPE.USR$NUMBER AS G_USR$RABATTGRUPPE_USR$NUMBER, '
      'G.USR$REGAL, '
      'G.USR$RUSNAME, '
      'G.USR$SEARCH, '
      'G.USR$SORT, '
      'G.USR$SPARTE, '
      'G_USR$SPARTE.USR$NAME AS G_USR$SPARTE_USR$NAME, G.USR$STAND, '
      'G.USR$VP1, '
      'G.USR$VP2, '
      'G.USR$WEIGHT'
      ''
      'FROM '
      '  GD_DOCUMENT Z'
      'LEFT JOIN '
      'USR$CLAIMCUSTLINE INVLINE'
      'ON '
      '(Z.ID = INVLINE.DOCUMENTKEY)'
      'LEFT JOIN '
      'INV_CARD CARD'
      'ON (CARD.ID = INVLINE.FROMCARDKEY)'
      'LEFT JOIN '
      'GD_GOOD G'
      'ON '
      '(G.ID = CARD.GOODKEY)'
      'LEFT JOIN '
      'GD_VALUE V'
      'ON '
      '(G.VALUEKEY = V.ID)'
      'LEFT JOIN '
      'USR$TYPEDELIVERY INVLINE_USR$DELIVERYKEY'
      'ON '
      'INVLINE_USR$DELIVERYKEY.ID = INVLINE.USR$DELIVERYKEY'
      'LEFT JOIN '
      'USR$FACTORY G_USR$FACTORY'
      'ON '
      'G_USR$FACTORY.ID = G.USR$FACTORY'
      'LEFT JOIN '
      'USR$RABATTGRUPPE G_USR$RABATTGRUPPE'
      'ON '
      'G_USR$RABATTGRUPPE.ID = G.USR$RABATTGRUPPE'
      'LEFT JOIN '
      'USR$SPARTE G_USR$SPARTE'
      'ON '
      'G_USR$SPARTE.ID = G.USR$SPARTE'
      'WHERE '
      'Z.PARENT = :PARENT'
      'AND '
      'INVLINE.DOCUMENTKEY IS NOT NULL  '
      'AND '
      'G_SEC_TEST(Z.AVIEW, -1) <> 0')
    ModifySQL.Strings = (
      'update GD_DOCUMENT'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  TRANSACTIONKEY = :TRANSACTIONKEY,'
      '  NUMBER = :NUMBER,'
      '  DOCUMENTDATE = :DOCUMENTDATE,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  SUMNCU = :SUMNCU,'
      '  SUMCURR = :SUMCURR,'
      '  DELAYED = :DELAYED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  CURRKEY = :CURRKEY,'
      '  COMPANYKEY = :COMPANYKEY,'
      '  CREATORKEY = :CREATORKEY,'
      '  CREATIONDATE = :CREATIONDATE,'
      '  EDITORKEY = :EDITORKEY,'
      '  EDITIONDATE = :EDITIONDATE,'
      '  PRINTDATE = :PRINTDATE'
      'where'
      '  ID = :OLD_ID')
    Left = 272
    Top = 104
  end
end
