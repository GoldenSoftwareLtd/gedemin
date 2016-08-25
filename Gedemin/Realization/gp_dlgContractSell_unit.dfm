object dlg_gpContractSell: Tdlg_gpContractSell
  Left = 368
  Top = 147
  ActiveControl = gsiblcContact
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Ввод договора по клиенту'
  ClientHeight = 250
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bOk: TButton
    Left = 402
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = bOkClick
  end
  object bNext: TButton
    Left = 402
    Top = 38
    Width = 75
    Height = 25
    Caption = 'Следующий'
    TabOrder = 1
    OnClick = bNextClick
  end
  object bCancel: TButton
    Left = 402
    Top = 67
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 385
    Height = 233
    ActivePage = TabSheet1
    TabOrder = 3
    object TabSheet1: TTabSheet
      Caption = 'Основные'
      object lContact: TLabel
        Left = 7
        Top = 10
        Width = 36
        Height = 13
        Caption = 'Клиент'
      end
      object Label2: TLabel
        Left = 7
        Top = 35
        Width = 84
        Height = 13
        Caption = 'Номер договора'
      end
      object Label3: TLabel
        Left = 7
        Top = 61
        Width = 76
        Height = 13
        Caption = 'Дата договора'
      end
      object Label4: TLabel
        Left = 7
        Top = 107
        Width = 50
        Height = 13
        Caption = 'Описание'
      end
      object Label1: TLabel
        Left = 7
        Top = 86
        Width = 35
        Height = 13
        Caption = '% пени'
      end
      object gsiblcContact: TgsIBLookupComboBox
        Left = 98
        Top = 6
        Width = 273
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        DataSource = dsContract
        DataField = 'CONTACTKEY'
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        gdClassName = 'TgdcBaseContact'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object dbedNumber: TDBEdit
        Left = 98
        Top = 31
        Width = 273
        Height = 21
        DataField = 'NUMBER'
        DataSource = dsDocument
        TabOrder = 1
      end
      object xdbedDocumentDate: TxDateDBEdit
        Left = 98
        Top = 57
        Width = 273
        Height = 21
        EditMask = '!99/99/9999;1;_'
        MaxLength = 10
        TabOrder = 2
        Kind = kDate
        DataField = 'DOCUMENTDATE'
        DataSource = dsDocument
      end
      object dbmDescription: TDBMemo
        Left = 98
        Top = 107
        Width = 273
        Height = 94
        DataField = 'DESCRIPTION'
        DataSource = dsDocument
        TabOrder = 3
      end
      object dbedPercent: TDBEdit
        Left = 98
        Top = 82
        Width = 273
        Height = 21
        DataField = 'PERCENT'
        DataSource = dsContract
        TabOrder = 4
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Атрибуты'
      ImageIndex = 1
      object atContainer1: TatContainer
        Left = 0
        Top = 0
        Width = 377
        Height = 205
        DataSource = dsContract
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object ibdsContract: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_contract'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into gd_contract'
      '  (DOCUMENTKEY, CONTACTKEY, TEXTCONTRACT, RESERVED, PERCENT)'
      'values'
      
        '  (:DOCUMENTKEY, :CONTACTKEY, :TEXTCONTRACT, :RESERVED, :PERCENT' +
        ')')
    RefreshSQL.Strings = (
      'SELECT con.* FROM gd_contract con '
      'WHERE con.DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT con.* FROM gd_contract con where con.documentkey = :dk')
    ModifySQL.Strings = (
      'update gd_contract'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  CONTACTKEY = :CONTACTKEY,'
      '  TEXTCONTRACT = :TEXTCONTRACT,'
      '  RESERVED = :RESERVED,'
      '  PERCENT = :PERCENT'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    Left = 424
    Top = 88
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    DefaultAction = TACommitRetaining
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 424
    Top = 120
  end
  object dsContract: TDataSource
    DataSet = ibdsContract
    Left = 456
    Top = 88
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
      'DESCRIPTION, SUMNCU, '
      '   SUMCURR, SUMEQ, AFULL, ACHAG, AVIEW, CURRKEY, COMPANYKEY, '
      'CREATORKEY, '
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
      'Select doc.*'
      'from gd_document doc'
      'where'
      '  doc.ID = :ID')
    SelectSQL.Strings = (
      'SELECT doc.* FROM gd_document doc WHERE doc.id = :dk')
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
    Left = 424
    Top = 160
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 456
    Top = 160
  end
  object gsDocNumerator: TgsDocNumerator
    Database = dmDatabase.ibdbGAdmin
    DataSource = dsDocument
    DocumentType = 802002
    Left = 24
    Top = 104
  end
  object atSQLSetup1: TatSQLSetup
    Ignores = <>
    Left = 408
    Top = 208
  end
end
