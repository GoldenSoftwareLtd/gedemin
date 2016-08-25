object gd_dlg_document: Tgd_dlg_document
  Left = 265
  Top = 103
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'gd_dlg_document'
  ClientHeight = 294
  ClientWidth = 458
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pcDocument: TPageControl
    Left = 0
    Top = 0
    Width = 458
    Height = 259
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = '&Реквизиты'
      object pnlMain: TPanel
        Left = 0
        Top = 0
        Width = 450
        Height = 231
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 9
          Width = 37
          Height = 13
          Caption = 'Номер:'
          Transparent = True
        end
        object Label2: TLabel
          Left = 174
          Top = 9
          Width = 29
          Height = 13
          Caption = 'Дата:'
          Transparent = True
        end
        object dbeNumber: TDBEdit
          Left = 90
          Top = 5
          Width = 71
          Height = 21
          DataField = 'NUMBER'
          DataSource = dsDocument
          TabOrder = 0
        end
        object dbeDate: TxDateDBEdit
          Left = 220
          Top = 5
          Width = 74
          Height = 21
          EditMask = '!99/99/9999;1;_'
          MaxLength = 10
          TabOrder = 1
          Kind = kDate
          DataField = 'DOCUMENTDATE'
          DataSource = dsDocument
        end
      end
    end
    object tsAttribute: TTabSheet
      Caption = '&Атрибуты'
      ImageIndex = 1
      object Splitter1: TSplitter
        Left = 0
        Top = 201
        Width = 680
        Height = 3
        Cursor = crVSplit
        Align = alTop
      end
      object atcLocal: TatContainer
        Left = 0
        Top = 0
        Width = 680
        Height = 201
        Align = alTop
        TabOrder = 0
      end
      object atcDocument: TatContainer
        Left = 0
        Top = 204
        Width = 680
        Height = 186
        DataSource = dsDocument
        Align = alClient
        TabOrder = 1
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 259
    Width = 458
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 293
      Top = 7
      Width = 75
      Height = 25
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 383
      Top = 7
      Width = 75
      Height = 25
      Action = actCancel
      Anchors = [akTop, akRight]
      Cancel = True
      ModalResult = 2
      TabOrder = 2
    end
    object Button1: TButton
      Left = 2
      Top = 7
      Width = 75
      Height = 25
      Action = actNext
      TabOrder = 0
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 44
    Top = 66
  end
  object alDocument: TActionList
    Left = 14
    Top = 66
    object actOk: TAction
      Category = 'Result'
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Category = 'Result'
      Caption = 'Отменить'
    end
    object actNext: TAction
      Category = 'Result'
      Caption = 'Следующий...'
      ShortCut = 45
      OnExecute = actNextExecute
    end
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 74
    Top = 66
  end
  object dsDocument: TDataSource
    DataSet = ibdsDocument
    Left = 104
    Top = 66
  end
  object ibdsDocument: TIBDataSet
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
      '  *'
      ''
      'FROM'
      '  GD_DOCUMENT d'
      ''
      'WHERE'
      '  d.ID = :id')
    ModifySQL.Strings = (
      'update GD_DOCUMENT'
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
    UniDirectional = True
    Left = 134
    Top = 66
  end
  object gsDocNumerator: TgsDocNumerator
    Database = dmDatabase.ibdbGAdmin
    DataSource = dsDocument
    DocumentType = -1
    Left = 74
    Top = 96
  end
end
