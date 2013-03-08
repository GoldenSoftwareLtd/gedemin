inherited ctl_frmReferences: Tctl_frmReferences
  Left = 241
  Top = 184
  Width = 486
  Height = 366
  Caption = 'Справочники учета поступления скота'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 301
    Width = 478
  end
  inherited pnlMain: TPanel
    Width = 478
    Height = 301
    inherited cbMain: TControlBar
      Width = 476
      AutoSize = False
      BevelEdges = []
      inherited tbMain: TToolBar
        AutoSize = False
        inherited tbtFilter: TToolButton
          DropdownMenu = pmFilterDeliveri
        end
      end
    end
    object pcReferences: TPageControl
      Left = 1
      Top = 29
      Width = 476
      Height = 271
      ActivePage = tsDestinationKind
      Align = alClient
      MultiLine = True
      TabOrder = 1
      OnChange = pcReferencesChange
      object tsDeliveryKind: TTabSheet
        Caption = 'Вид поставки'
        object ibgrdDeliveryKind: TgsIBGrid
          Left = 0
          Top = 0
          Width = 468
          Height = 243
          Align = alClient
          BorderStyle = bsNone
          DataSource = dsDelivery
          Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgCancelOnExit]
          TabOrder = 0
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          TitlesExpanding = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
        end
      end
      object tsDestinationKind: TTabSheet
        Caption = 'Вид назначения'
        ImageIndex = 1
        object ibgrdDestinationKind: TgsIBGrid
          Left = 0
          Top = 0
          Width = 468
          Height = 243
          Align = alClient
          BorderStyle = bsNone
          DataSource = dsDestination
          Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgCancelOnExit]
          TabOrder = 0
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          TitlesExpanding = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
        end
      end
    end
  end
  inherited alMain: TActionList
    Left = 100
    Top = 110
    inherited actNew: TAction
      Caption = 'Добавить'
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    inherited actEdit: TAction
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    inherited actDelete: TAction
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    inherited actPrint: TAction
      OnExecute = nil
    end
  end
  inherited pmMain: TPopupMenu
    Left = 211
    Top = 110
  end
  object ibtrReference: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 70
    Top = 140
  end
  object ibsqlDelete: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'DELETE FROM'
      '  CTL_REFERENCE'
      ''
      'WHERE'
      '  ID = :ID')
    Transaction = ibtrReference
    Left = 100
    Top = 140
  end
  object ibdsDelivery: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrReference
    AfterOpen = ibdsDeliveryAfterOpen
    AfterPost = ibdsDeliveryAfterPost
    BeforePost = ibdsDeliveryBeforePost
    OnPostError = ibdsDeliveryPostError
    BufferChunks = 1000
    DeleteSQL.Strings = (
      'delete from CTL_REFERENCE'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into CTL_REFERENCE'
      '  (NAME, ALIAS, ID, PARENT, AFULL, ACHAG, AVIEW)'
      'values'
      '  (:NAME, :ALIAS, :ID, :PARENT, :AFULL, :ACHAG, :AVIEW)')
    RefreshSQL.Strings = (
      'Select '
      '  R.ID,'
      '  R.PARENT,'
      '  R.NAME,'
      '  R.ALIAS,'
      '  R.AFULL,'
      '  R.ACHAG,'
      '  R.AVIEW,'
      '  R.DISABLED,'
      '  R.RESERVED'
      'from CTL_REFERENCE R'
      'where'
      '  R.ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  R.NAME, R.ALIAS, R.ID, R.PARENT, R.AFULL, R.ACHAG, R.AVIEW'
      ''
      'FROM'
      '  CTL_REFERENCE R'
      ''
      'WHERE'
      '  R.PARENT = :ID')
    ModifySQL.Strings = (
      'update CTL_REFERENCE'
      'set'
      '  NAME = :NAME,'
      '  ALIAS = :ALIAS,'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = ibtrReference
    Left = 240
    Top = 110
  end
  object dsDelivery: TDataSource
    DataSet = ibdsDelivery
    Left = 240
    Top = 140
  end
  object dsDestination: TDataSource
    DataSet = ibdsDestination
    Left = 270
    Top = 140
  end
  object ibdsDestination: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrReference
    AfterOpen = ibdsDestinationAfterOpen
    AfterPost = ibdsDestinationAfterPost
    BeforePost = ibdsDestinationBeforePost
    OnPostError = ibdsDestinationPostError
    BufferChunks = 1000
    DeleteSQL.Strings = (
      'delete from CTL_REFERENCE'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into CTL_REFERENCE'
      '  (NAME, ALIAS, ID, PARENT, AFULL, ACHAG, AVIEW)'
      'values'
      '  (:NAME, :ALIAS, :ID, :PARENT, :AFULL, :ACHAG, :AVIEW)')
    RefreshSQL.Strings = (
      'Select '
      '  R.ID,'
      '  R.PARENT,'
      '  R.NAME,'
      '  R.ALIAS,'
      '  R.AFULL,'
      '  R.ACHAG,'
      '  R.AVIEW,'
      '  R.DISABLED,'
      '  R.RESERVED'
      'from CTL_REFERENCE R'
      'where'
      '  R.ID = :ID')
    SelectSQL.Strings = (
      'SELECT '
      '  R.NAME, R.ALIAS, R.ID, R.PARENT, R.AFULL, R.ACHAG, R.AVIEW'
      ''
      'FROM'
      '  CTL_REFERENCE R'
      ''
      'WHERE'
      '  R.PARENT = :ID')
    ModifySQL.Strings = (
      'update CTL_REFERENCE'
      'set'
      '  NAME = :NAME,'
      '  ALIAS = :ALIAS,'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = ibtrReference
    Left = 270
    Top = 110
  end
  object pmFilterDeliveri: TPopupMenu
    Left = 305
    Top = 140
  end
  object gsQueryFilterDeliveri: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsDelivery
    Left = 335
    Top = 140
  end
  object pmFileterDestination: TPopupMenu
    Left = 305
    Top = 190
  end
  object gsQueryFilterDestination: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsDestination
    Left = 335
    Top = 190
  end
end
