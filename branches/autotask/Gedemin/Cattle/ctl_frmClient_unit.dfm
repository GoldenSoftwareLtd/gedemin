inherited ctl_frmClient: Tctl_frmClient
  Left = 203
  Top = 166
  Height = 364
  Caption = 'Поставщики мяса и скота'
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 299
  end
  inherited pnlMain: TPanel
    Height = 299
    object Splitter1: TSplitter [0]
      Left = 211
      Top = 29
      Width = 6
      Height = 269
      Cursor = crHSplit
    end
    inherited cbMain: TControlBar
      inherited tbMain: TToolBar
        inherited tbtFilter: TToolButton
          DropdownMenu = pmFilter
        end
        object ToolButton1: TToolButton
          Left = 283
          Top = 0
          Action = actSetup
        end
      end
    end
    object tvClient: TgsIBLargeTreeView
      Left = 1
      Top = 29
      Width = 210
      Height = 269
      IDField = 'ID'
      ParentField = 'PARENT'
      LBField = 'LB'
      RBField = 'RB'
      LBRBMode = True
      ListField = 'NAME'
      OrderByField = 'NAME'
      RelationName = 'GD_CONTACT'
      TopBranchID = 'NULL'
      Condition = 'contacttype = 0'
      Database = dmDatabase.ibdbGAdmin
      AutoLoad = True
      StopOnCount = 150
      ShowTopBranch = False
      TopBranchText = 'Все'
      CheckBoxes = False
      Align = alLeft
      BorderStyle = bsNone
      HideSelection = False
      Indent = 19
      TabOrder = 1
      OnChange = tvClientChange
    end
    object ibgrdClient: TgsIBCtrlGrid
      Left = 217
      Top = 29
      Width = 327
      Height = 269
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsClient
      Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgCancelOnExit, dgMultiSelect]
      TabOrder = 2
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.Visible = False
      CheckBox.FirstColumn = False
      MinColWidth = 40
      ColumnEditors = <>
      Aliases = <
        item
          Alias = 'NAME'
          LName = 'Поставщик'
        end>
    end
  end
  inherited alMain: TActionList
    Left = 160
    Top = 40
    object actSetup: TAction
      Caption = 'actSetup'
      ImageIndex = 8
      OnExecute = actSetupExecute
    end
  end
  inherited pmMainReport: TPopupMenu
    Left = 160
    Top = 100
  end
  object ibdsClient: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrClient
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = True
    DeleteSQL.Strings = (
      'delete from GD_CONTACT'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_CONTACT'
      
        '  (ID, LB, RB, PARENT, CONTACTTYPE, NAME, ADDRESS, DISTRICT, CIT' +
        'Y, REGION, '
      
        '   ZIP, COUNTRY, NOTE, EXTERNALKEY, EMAIL, URL, POBOX, PHONE, FA' +
        'X, AFULL, '
      '   ACHAG, AVIEW, DISABLED, RESERVED)'
      'values'
      
        '  (:ID, :LB, :RB, :PARENT, :CONTACTTYPE, :NAME, :ADDRESS, :DISTR' +
        'ICT, :CITY, '
      
        '   :REGION, :ZIP, :COUNTRY, :NOTE, :EXTERNALKEY, :EMAIL, :URL, :' +
        'POBOX, '
      '   :PHONE, :FAX, :AFULL, :ACHAG, :AVIEW, :DISABLED, :RESERVED)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  LB,'
      '  RB,'
      '  PARENT,'
      '  CONTACTTYPE,'
      '  NAME,'
      '  ADDRESS,'
      '  DISTRICT,'
      '  CITY,'
      '  REGION,'
      '  ZIP,'
      '  COUNTRY,'
      '  NOTE,'
      '  EXTERNALKEY,'
      '  EMAIL,'
      '  URL,'
      '  POBOX,'
      '  PHONE,'
      '  FAX,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  DISABLED,'
      '  RESERVED'
      'from GD_CONTACT '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  C.NAME, C.ADDRESS, '
      '  C.ID, C.PARENT'
      ''
      'FROM'
      '  GD_CONTACT C'
      '    LEFT JOIN'
      '      GD_CONTACTPROPS P'
      '    ON'
      '      C.ID = P.CONTACTKEY'
      ''
      'WHERE'
      '  C.LB >= :LB'
      '    AND'
      '  C.RB <= :RB')
    ModifySQL.Strings = (
      'update GD_CONTACT'
      'set'
      '  ID = :ID,'
      '  LB = :LB,'
      '  RB = :RB,'
      '  PARENT = :PARENT,'
      '  CONTACTTYPE = :CONTACTTYPE,'
      '  NAME = :NAME,'
      '  ADDRESS = :ADDRESS,'
      '  DISTRICT = :DISTRICT,'
      '  CITY = :CITY,'
      '  REGION = :REGION,'
      '  ZIP = :ZIP,'
      '  COUNTRY = :COUNTRY,'
      '  NOTE = :NOTE,'
      '  EXTERNALKEY = :EXTERNALKEY,'
      '  EMAIL = :EMAIL,'
      '  URL = :URL,'
      '  POBOX = :POBOX,'
      '  PHONE = :PHONE,'
      '  FAX = :FAX,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    Left = 290
    Top = 80
  end
  object dsClient: TDataSource
    DataSet = ibdsClient
    Left = 320
    Top = 80
  end
  object ibdsClientData: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrClient
    ForcedRefresh = True
    AfterEdit = ibdsClientDataAfterEdit
    AfterInsert = ibdsClientDataAfterInsert
    AfterPost = ibdsClientDataAfterPost
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_CONTACTPROPS'
      'where'
      '  CONTACTKEY = :OLD_CONTACTKEY')
    InsertSQL.Strings = (
      'insert into GD_CONTACTPROPS'
      '  (CONTACTKEY, RESERVED)'
      'values'
      '  (:CONTACTKEY, :RESERVED)')
    RefreshSQL.Strings = (
      'Select '
      '  CONTACTKEY,'
      '  RESERVED'
      'from GD_CONTACTPROPS '
      'where'
      '  CONTACTKEY = :CONTACTKEY')
    SelectSQL.Strings = (
      'SELECT '
      '  P.*'
      ''
      'FROM'
      '  GD_CONTACTPROPS P'
      ''
      'WHERE'
      '  P.CONTACTKEY = :ID')
    ModifySQL.Strings = (
      'update GD_CONTACTPROPS'
      'set'
      '  CONTACTKEY = :CONTACTKEY,'
      '  RESERVED = :RESERVED'
      'where'
      '  CONTACTKEY = :OLD_CONTACTKEY')
    DataSource = dsClient
    Left = 290
    Top = 110
  end
  object dsClientData: TDataSource
    DataSet = ibdsClientData
    Left = 320
    Top = 110
  end
  object ibtrClient: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 260
    Top = 80
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <
      item
        Link = ibdsClient
        RelationName = 'GD_CONTACT'
        IgnoryType = itFull
      end>
    Left = 160
    Top = 70
  end
  object pmFilter: TPopupMenu
    Left = 290
    Top = 145
  end
  object gsQueryFilter: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsClient
    Left = 320
    Top = 145
  end
  object gsReportManager: TgsReportManager
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = ibtrClient
    PopupMenu = pmMainReport
    MenuType = mtSeparator
    Caption = 'Печать реестра'
    GroupID = 2000510
    Left = 125
    Top = 105
  end
end
