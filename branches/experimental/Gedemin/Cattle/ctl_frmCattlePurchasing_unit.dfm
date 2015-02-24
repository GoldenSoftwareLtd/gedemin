inherited ctl_frmCattlePurchasing: Tctl_frmCattlePurchasing
  Left = 220
  Top = 139
  Width = 591
  Caption = 'Отвес-накладные на приходование мяса'
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
      Width = 581
      Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      Aliases = <
        item
          Alias = 'DEPARTMENT'
          LName = 'Подразделение'
        end
        item
          Alias = 'FACE'
          LName = 'Физ.лицо'
        end
        item
          Alias = 'SUPPLIER'
          LName = 'Поставщик'
        end
        item
          Alias = 'RECEIVING'
          LName = 'Вид поставки'
        end>
    end
    inherited cbMain: TControlBar
      Width = 581
      inherited tbMain: TToolBar
        object tbtReferences: TToolButton
          Left = 283
          Top = 0
          Action = actSetup
        end
        object ToolButton1: TToolButton
          Left = 306
          Top = 0
          Action = actRecalcWeight
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
          Alias = 'DESTINATION'
          LName = 'Назначение'
        end
        item
          Alias = 'GOODNAME'
          LName = 'Скот(мясо)'
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
    inherited actDetailNew: TAction
      OnExecute = actDetailNewExecute
    end
    inherited actDetailEdit: TAction
      OnExecute = actDetailEditExecute
    end
    inherited actDetailDelete: TAction
      OnExecute = actDetailDeleteExecute
    end
    object actSetup: TAction
      Category = 'Master'
      Caption = 'Справочники'
      ImageIndex = 8
      OnExecute = actSetupExecute
    end
    object actRecalcWeight: TAction
      Category = 'Master'
      Caption = 'actRecalcWeight'
      Hint = 'Перерасчет веса'
      ImageIndex = 15
      OnExecute = actRecalcWeightExecute
    end
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
      'insert into CTL_INVOICE'
      
        '  (DOCUMENTKEY, RECEIPTKEY, TTNNUMBER, KIND, DEPARTMENTKEY, PURC' +
        'HASEKIND, '
      
        '   SUPPLIERKEY, RECEIVINGKEY, FORCESLAUGHTER, WASTECOUNT, RESERV' +
        'ED, DELIVERYKIND, '
      '   FACEKEY)'
      'values'
      
        '  (:DOCUMENTKEY, :RECEIPTKEY, :TTNNUMBER, :KIND, :DEPARTMENTKEY,' +
        ' :PURCHASEKIND, '
      
        '   :SUPPLIERKEY, :RECEIVINGKEY, :FORCESLAUGHTER, :WASTECOUNT, :R' +
        'ESERVED, '
      '   :DELIVERYKIND, :FACEKEY)')
    RefreshSQL.Strings = (
      'SELECT '
      '  DOC.NUMBER, DOC.DOCUMENTDATE,'
      '  D.NAME AS DEPARTMENT, '
      '  S.NAME AS SUPPLIER,'
      '  F.NAME AS FACE,'
      '  R.NAME AS RECEIVING,'
      '  C.*'
      ''
      ''
      'FROM'
      '  CTL_INVOICE C'
      ''
      '    JOIN GD_DOCUMENT DOC ON'
      '      C.DOCUMENTKEY = DOC.ID'
      ''
      '    JOIN GD_CONTACT D ON'
      '      C.DEPARTMENTKEY = D.ID'
      ''
      '    JOIN GD_CONTACT S ON'
      '      C.SUPPLIERKEY = S.ID'
      ''
      '    LEFT JOIN GD_CONTACT F ON'
      '      C.FACEKEY = F.ID'
      ''
      '    JOIN CTL_REFERENCE R ON'
      '      C.RECEIVINGKEY = R.ID'
      ''
      'WHERE'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT '
      '  DOC.NUMBER, DOC.DOCUMENTDATE,'
      '  D.NAME AS DEPARTMENT, '
      '  S.NAME AS SUPPLIER,'
      '  F.NAME AS FACE,'
      '  R.NAME AS RECEIVING,'
      '  C.*'
      ''
      ''
      'FROM'
      '  CTL_INVOICE C'
      ''
      '    JOIN GD_DOCUMENT DOC ON'
      '      C.DOCUMENTKEY = DOC.ID'
      ''
      '    JOIN GD_CONTACT D ON'
      '      C.DEPARTMENTKEY = D.ID'
      ''
      '    JOIN GD_CONTACT S ON'
      '      C.SUPPLIERKEY = S.ID'
      ''
      '    LEFT JOIN GD_CONTACT F ON'
      '      C.FACEKEY = F.ID'
      ''
      '    JOIN CTL_REFERENCE R ON'
      '      C.RECEIVINGKEY = R.ID'
      ' ')
    ModifySQL.Strings = (
      'update CTL_INVOICE'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  RECEIPTKEY = :RECEIPTKEY,'
      '  TTNNUMBER = :TTNNUMBER,'
      '  KIND = :KIND,'
      '  DEPARTMENTKEY = :DEPARTMENTKEY,'
      '  PURCHASEKIND = :PURCHASEKIND,'
      '  SUPPLIERKEY = :SUPPLIERKEY,'
      '  RECEIVINGKEY = :RECEIVINGKEY,'
      '  FORCESLAUGHTER = :FORCESLAUGHTER,'
      '  WASTECOUNT = :WASTECOUNT,'
      '  RESERVED = :RESERVED,'
      '  DELIVERYKIND = :DELIVERYKIND,'
      '  FACEKEY = :FACEKEY'
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
      '   DESTKEY, AFULL, ACHAG, AVIEW, DISABLED, RESERVED)'
      'values'
      
        '  (:ID, :INVOICEKEY, :GOODKEY, :QUANTITY, :MEATWEIGHT, :LIVEWEIG' +
        'HT, :REALWEIGHT, '
      '   :DESTKEY, :AFULL, :ACHAG, :AVIEW, :DISABLED, :RESERVED)')
    RefreshSQL.Strings = (
      'SELECT '
      '  P.*,'
      '  G.NAME'
      ''
      'FROM'
      '  CTL_INVOICEPOS P'
      ''
      '    JOIN GD_GOOD G ON'
      '      P.GOODKEY = G.ID'
      ''
      '    JOIN CTL_REFERENCE R ON'
      '      P.DESTKEY = R.ID'
      ''
      'WHERE'
      '  P.ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  G.NAME AS GOODNAME,'
      '  R.NAME AS DESTINATION,'
      ''
      '  P. LIVEWEIGHT, P. MEATWEIGHT, P. REALWEIGHT, P. QUANTITY, '
      '  P. DESTKEY, P. DISABLED, P. GOODKEY, P. ID, P. INVOICEKEY, '
      '  P. ACHAG, P. AFULL, P. AVIEW, '
      '  P. RESERVED'
      ''
      'FROM'
      '  CTL_INVOICEPOS P'
      ''
      '    JOIN GD_GOOD G ON'
      '      P.GOODKEY = G.ID'
      ''
      '    JOIN CTL_REFERENCE R ON'
      '      P.DESTKEY = R.ID'
      ''
      'WHERE'
      '  P.INVOICEKEY = :DOCUMENTKEY'
      ' ')
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
      '  RESERVED = :RESERVED'
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
    MenuType = mtSeparator
    GroupID = 2000710
  end
  object spRecalcWeight: TIBStoredProc
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    StoredProcName = 'CTL_P_RECALCWEIGHT'
    Left = 288
    Top = 48
  end
  object ibsqlDest: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM '
      '  ctl_reference'
      'WHERE'
      '  parent = 2000')
    Transaction = IBTransaction
    Left = 216
    Top = 215
  end
end
