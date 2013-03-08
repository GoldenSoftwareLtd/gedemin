object ctl_dlgPaymentRoll: Tctl_dlgPaymentRoll
  Left = 256
  Top = 113
  Width = 467
  Height = 357
  BorderIcons = [biSystemMenu]
  Caption = 'Формирование платежной ведомости'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnMakePaymentRoll: TButton
    Left = 110
    Top = 298
    Width = 88
    Height = 24
    Action = actMakePaymentRoll
    Anchors = [akRight, akBottom]
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 360
    Top = 298
    Width = 88
    Height = 24
    Action = actCancel
    Anchors = [akRight, akBottom]
    ModalResult = 2
    TabOrder = 1
  end
  object ibgrdReceipts: TgsIBGrid
    Left = 11
    Top = 10
    Width = 437
    Height = 272
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsReceipts
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection]
    PopupMenu = pmMain
    TabOrder = 2
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.DisplayField = 'DOCUMENTDATE'
    CheckBox.FieldName = 'DOCUMENTKEY'
    CheckBox.Visible = True
    MinColWidth = 40
    Aliases = <
      item
        Alias = 'SUPPLIER'
        LName = 'Поставщик'
      end
      item
        Alias = 'FACE'
        LName = 'Физ. лицо'
      end>
  end
  object btnFilter: TButton
    Left = 12
    Top = 298
    Width = 88
    Height = 24
    Action = actFilter
    TabOrder = 3
  end
  object alPaymentRoll: TActionList
    Left = 30
    Top = 50
    object actMakePaymentRoll: TAction
      Caption = 'Печать'
      OnExecute = actMakePaymentRollExecute
    end
    object actCancel: TAction
      Caption = 'Закрыть'
      OnExecute = actCancelExecute
    end
    object actFilter: TAction
      Caption = 'Фильтр'
      OnExecute = actFilterExecute
    end
    object actChooseAll: TAction
      Caption = 'Выбрать все'
      OnExecute = actChooseAllExecute
    end
    object actChooseClear: TAction
      Caption = 'Отменить выбор'
      OnExecute = actChooseClearExecute
    end
  end
  object ibtrReceipts: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 60
    Top = 50
  end
  object ibdsReceipts: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrReceipts
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT'
      '  D.DOCUMENTDATE,'
      '  D.NUMBER,'
      '  D.ID,'
      '  C.NAME AS SUPPLIER,'
      '  F.NAME AS FACE,'
      '  R.*,'
      '  I.*,'
      '  DI.DOCUMENTDATE AS INVOICEDATE,'
      '  DI.NUMBER AS INVOICENUMBER'
      ''
      'FROM'
      '  CTL_RECEIPT R'
      ''
      '    JOIN GD_DOCUMENT D ON'
      '      R.DOCUMENTKEY = D.ID'
      ''
      '    JOIN CTL_INVOICE I ON'
      '      I.RECEIPTKEY = R.DOCUMENTKEY'
      ''
      '    JOIN GD_DOCUMENT DI ON'
      '      I.DOCUMENTKEY = DI.ID'
      ''
      '    JOIN GD_CONTACT C ON'
      '      C.ID = I.SUPPLIERKEY'
      ''
      '    JOIN GD_CONTACT F ON'
      '      F.ID = I.FACEKEY')
    Left = 90
    Top = 50
  end
  object dsReceipts: TDataSource
    DataSet = ibdsReceipts
    Left = 90
    Top = 80
  end
  object pmFilter: TPopupMenu
    Left = 10
    Top = 270
  end
  object qfReceipts: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    IBDataSet = ibdsReceipts
    Left = 270
    Top = 50
  end
  object pmPrint: TPopupMenu
    Left = 110
    Top = 270
  end
  object FormPlaceSaver: TFormPlaceSaver
    OnlyForm = True
    Left = 300
    Top = 50
  end
  object gsMainReportManager: TgsReportManager
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = ibtrReceipts
    PopupMenu = pmPrint
    MenuType = mtSeparator
    Caption = 'Печать платежной ведомости'
    GroupID = 2000301
    Left = 270
    Top = 20
  end
  object pmMain: TPopupMenu
    Left = 136
    Top = 176
  end
end
