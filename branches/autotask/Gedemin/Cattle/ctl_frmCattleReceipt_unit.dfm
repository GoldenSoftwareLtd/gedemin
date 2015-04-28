inherited ctl_frmCattleReceipt: Tctl_frmCattleReceipt
  Left = 333
  Top = 250
  Width = 591
  Caption = 'Приемная квитанция по приходованию скота'
  PixelsPerInch = 96
  TextHeight = 13
  inherited Splitter: TSplitter
    Width = 583
  end
  inherited sbMain: TStatusBar
    Width = 583
  end
  inherited pnlMain: TPanel
    Width = 583
    inherited ibgrMain: TgsIBGrid
      Top = 59
      Width = 581
      Height = 110
      Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      Aliases = <
        item
          Alias = 'DEPARMENT'
          LName = 'Подразделение'
        end
        item
          Alias = 'SUPPLIER'
          LName = 'Поставщик'
        end
        item
          Alias = 'INVOICENUMBER'
          LName = '№ накладной'
        end>
    end
    inherited cbMain: TControlBar
      Width = 581
      Height = 58
      inherited tbMain: TToolBar
        Height = 52
        inherited tbnSpace1: TToolButton
          Left = 0
          Wrap = True
        end
        inherited tbtUnDo: TToolButton
          Left = 0
          Top = 30
        end
        inherited tbnSpace5: TToolButton
          Left = 23
          Top = 30
        end
        inherited tbtFilter: TToolButton
          Left = 31
          Top = 30
        end
        inherited tbtPrint: TToolButton
          Left = 54
          Top = 30
          DropdownMenu = pmPrint
        end
        inherited tbnSpace6: TToolButton
          Left = 77
          Top = 30
        end
        inherited tbHlp: TToolButton
          Left = 83
          Top = 30
          Action = actPayments
        end
        object tbSetup: TToolButton
          Left = 106
          Top = 30
          Action = actSetup
        end
        object tbPaymentRoll: TToolButton
          Left = 129
          Top = 30
          Action = actPaymentRoll
        end
        object tbRecallReceipt: TToolButton
          Left = 152
          Top = 30
          Hint = 'Пересчитать приемные квитанции'
          Action = actRecall
        end
        object ToolButton1: TToolButton
          Left = 175
          Top = 30
          Action = actSelect
        end
      end
    end
  end
  inherited pnlDetails: TPanel
    Width = 583
    inherited ibgrDetails: TgsIBGrid
      Width = 581
      Aliases = <
        item
          Alias = 'GOODNAME'
          LName = 'Скот(мясо)'
        end
        item
          Alias = 'DESTINATION'
          LName = 'Назначение'
        end>
    end
    inherited cbDetails: TControlBar
      Width = 581
    end
  end
  inherited alMain: TActionList
    Left = 230
    Top = 80
    inherited actNew: TAction
      OnExecute = actNewExecute
    end
    inherited actEdit: TAction
      OnExecute = actEditExecute
    end
    object actSetup: TAction
      Category = 'Master'
      Caption = 'Настройка'
      Hint = 'Настройка'
      ImageIndex = 8
      OnExecute = actSetupExecute
    end
    object actPayments: TAction
      Caption = 'actPayments'
      ImageIndex = 5
      OnExecute = actPaymentsExecute
    end
    object actPaymentRoll: TAction
      Category = 'Master'
      Caption = 'Платежная ведомость'
      ImageIndex = 9
      OnExecute = actPaymentRollExecute
    end
    object actRecall: TAction
      Caption = 'actRecall'
      Hint = 'Перессчитать приемные квитанции'
      ImageIndex = 5
      OnExecute = actRecallExecute
      OnUpdate = actRecallUpdate
    end
    object actSelect: TAction
      Caption = 'Выделить за день'
      Hint = 'Выделить за день'
      ImageIndex = 14
      OnExecute = actSelectExecute
    end
  end
  inherited pmMain: TPopupMenu
    Left = 230
    Top = 110
  end
  inherited IBTransaction: TIBTransaction
    Left = 260
  end
  inherited ibdsMain: TIBDataSet
    DeleteSQL.Strings = (
      'delete from GD_DOCUMENT'
      'where'
      '  ID = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into CTL_RECEIPT'
      '  (DOCUMENTKEY, REGISTERSHEET, SUMTOTAL, SUMNCU, RESERVED)'
      'values'
      '  (:DOCUMENTKEY, :REGISTERSHEET, :SUMTOTAL, :SUMNCU, :RESERVED)')
    RefreshSQL.Strings = (
      'SELECT'
      '  D.NUMBER,'
      '  D.DOCUMENTDATE,  '
      '  R.*,'
      '  C.NAME AS SUPPLIER,'
      '  C.REGION, C.DISTRICT,'
      '  C2.NAME AS DEPARMENT,'
      '  I.DELIVERYKIND, I.PURCHASEKIND,'
      '  DI.NUMBER AS INVOICENUMBER'
      ''
      'FROM'
      '  CTL_RECEIPT R'
      ''
      '    JOIN GD_DOCUMENT D ON'
      '      R.DOCUMENTKEY = D.ID'
      ''
      '    JOIN CTL_INVOICE I ON'
      '      R.DOCUMENTKEY = I.RECEIPTKEY'
      ''
      '    JOIN GD_CONTACT C ON'
      '      I.SUPPLIERKEY = C.ID'
      '    '
      '    JOIN GD_CONTACT C2 ON'
      '      I.DEPARTMENTKEY = C2.ID'
      ''
      '    JOIN GD_DOCUMENT DI ON'
      '      I.DOCUMENTKEY = DI.ID'
      'WHERE'
      '    R.DOCUMENTKEY = :NEW_DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT'
      '  D.NUMBER,'
      '  D.DOCUMENTDATE,  '
      '  R.*,'
      '  C.NAME AS SUPPLIER,'
      '  C.REGION, C.DISTRICT,'
      '  C2.NAME AS DEPARMENT,'
      '  I.DELIVERYKIND, I.PURCHASEKIND,'
      '  DI.NUMBER AS INVOICENUMBER'
      ''
      'FROM'
      '  CTL_RECEIPT R'
      ''
      '    JOIN GD_DOCUMENT D ON'
      '      R.DOCUMENTKEY = D.ID'
      ''
      '    JOIN CTL_INVOICE I ON'
      '      R.DOCUMENTKEY = I.RECEIPTKEY'
      ''
      '    JOIN GD_CONTACT C ON'
      '      I.SUPPLIERKEY = C.ID'
      '    '
      '    JOIN GD_CONTACT C2 ON'
      '      I.DEPARTMENTKEY = C2.ID'
      ''
      '    JOIN GD_DOCUMENT DI ON'
      '      I.DOCUMENTKEY = DI.ID')
    ModifySQL.Strings = (
      'update CTL_RECEIPT'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  REGISTERSHEET = :REGISTERSHEET,'
      '  SUMTOTAL = :SUMTOTAL,'
      '  SUMNCU = :SUMNCU,'
      '  RESERVED = :RESERVED'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    Left = 290
  end
  inherited gsQFMain: TgsQueryFilter
    Left = 350
  end
  inherited ibdsDetails: TIBDataSet
    DeleteSQL.Strings = (
      'delete from CTL_INVOICEPOS'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into CTL_INVOICEPOS'
      
        '  (ID, INVOICEKEY, GOODKEY, QUANTITY, MEATWEIGHT, LIVEWEIGHT, RE' +
        'ALWEIGHT, '
      
        '   DESTKEY, AFULL, ACHAG, AVIEW, DISABLED, RESERVED, PRICEKEY, P' +
        'RICE, SUMNCU)'
      'values'
      
        '  (:ID, :INVOICEKEY, :GOODKEY, :QUANTITY, :MEATWEIGHT, :LIVEWEIG' +
        'HT, :REALWEIGHT, '
      
        '   :DESTKEY, :AFULL, :ACHAG, :AVIEW, :DISABLED, :RESERVED, :PRIC' +
        'EKEY, :PRICE, '
      '   :SUMNCU)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  INVOICEKEY,'
      '  GOODKEY,'
      '  QUANTITY,'
      '  MEATWEIGHT,'
      '  LIVEWEIGHT,'
      '  REALWEIGHT,'
      '  DESTKEY,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  DISABLED,'
      '  RESERVED,'
      '  PRICEKEY,'
      '  PRICE,'
      '  SUMNCU'
      'from CTL_INVOICEPOS '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  G.NAME AS GOODNAME, G.ALIAS,'
      '  R.NAME AS DESTINATION,'
      '  P.*'
      ''
      'FROM'
      '  CTL_INVOICE I,'
      '  CTL_INVOICEPOS P'
      ''
      '    JOIN GD_GOOD G ON'
      '      P.GOODKEY = G.ID'
      ''
      '    JOIN CTL_REFERENCE R ON'
      '      P.DESTKEY = R.ID'
      ''
      'WHERE'
      '  I.RECEIPTKEY = :DOCUMENTKEY '
      '    AND'
      '  P.INVOICEKEY = I.DOCUMENTKEY')
    ModifySQL.Strings = (
      'update CTL_INVOICEPOS'
      'set'
      '  ID = :ID,'
      '  INVOICEKEY = :INVOICEKEY,'
      '  GOODKEY = :GOODKEY,'
      '  QUANTITY = :QUANTITY,'
      '  MEATWEIGHT = :MEATWEIGHT,'
      '  LIVEWEIGHT = :LIVEWEIGHT,'
      '  REALWEIGHT = :REALWEIGHT,'
      '  DESTKEY = :DESTKEY,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED,'
      '  PRICEKEY = :PRICEKEY,'
      '  PRICE = :PRICE,'
      '  SUMNCU = :SUMNCU'
      'where'
      '  ID = :OLD_ID')
    Left = 290
    Top = 110
  end
  inherited dsDetail: TDataSource
    Top = 110
  end
  inherited gsQFDetail: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    Left = 350
    Top = 110
  end
  inherited pmDetailFilter: TPopupMenu
    Left = 380
    Top = 110
  end
  inherited pmMainFilter: TPopupMenu
    Left = 380
  end
  inherited gsMainReportManager: TgsReportManager
    PopupMenu = pmPrint
    MenuType = mtSeparator
    GroupID = 2000720
  end
  object gsReportRegistry: TgsReportRegistry
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DataSource = dsDetail
    PopupMenu = pmPrint
    MenuType = mtSubMenu
    Caption = 'Печать реестра'
    GroupID = 103000
    OnBeforePrint = gsReportRegistryBeforePrint
    Left = 200
    Top = 80
  end
  object pmPrint: TPopupMenu
    Left = 200
    Top = 110
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <
      item
        Link = ibdsDetails
        RelationName = 'GD_GOOD'
        IgnoryType = itFull
      end
      item
        Link = ibdsDetails
        RelationName = 'GD_INVOICEPOS'
        IgnoryType = itFull
      end
      item
        Link = ibdsDetails
        RelationName = 'GD_REFERENCE'
        IgnoryType = itFull
      end
      item
        Link = ibdsMain
        RelationName = 'GD_CONTACT'
        IgnoryType = itFull
      end
      item
        Link = ibdsMain
        RelationName = 'GD_INVOICE'
        IgnoryType = itFull
      end>
    Left = 410
    Top = 110
  end
  object NumberConvert: TNumberConvert
    Value = 100
    Language = lRussian
    FreeStyleDigits = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    HexPrefix = '$'
    OctPrefix = '0'
    BinPostfix = 'b'
    Left = 230
    Top = 50
  end
  object ibsqlGetInvoiceKey: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT documentkey from ctl_invoice where receiptkey = :id')
    Transaction = IBTransaction
    Left = 440
    Top = 80
  end
end
