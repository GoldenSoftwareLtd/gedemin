inherited gd_frmMDHIBF: Tgd_frmMDHIBF
  Height = 407
  Caption = 'gd_frmMDHIBF'
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter [0]
    Left = 0
    Top = 170
    Width = 638
    Height = 3
    Cursor = crVSplit
    Align = alTop
    AutoSnap = False
  end
  inherited sbMain: TStatusBar
    Top = 342
  end
  inherited pnlMain: TPanel
    Height = 170
    Align = alTop
    inherited ibgrMain: TgsIBGrid
      Height = 140
    end
    inherited cbMain: TControlBar
      inherited tbMainGrid: TToolBar
        Images = dmImages.ilToolBarSmall
      end
    end
  end
  object pnlDetails: TPanel [3]
    Left = 0
    Top = 173
    Width = 638
    Height = 169
    Align = alClient
    BevelOuter = bvLowered
    Constraints.MinHeight = 100
    Constraints.MinWidth = 200
    TabOrder = 2
    object ibgrDetails: TgsIBGrid
      Left = 1
      Top = 27
      Width = 636
      Height = 141
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsDetail
      Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
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
      ToolBar = tbDetailGrid
      ColumnEditors = <>
      Aliases = <>
    end
    object cbDetails: TControlBar
      Left = 1
      Top = 1
      Width = 636
      Height = 26
      Align = alTop
      AutoDock = False
      AutoSize = True
      BevelEdges = []
      DockSite = False
      TabOrder = 1
      object tbDetails: TToolBar
        Left = 11
        Top = 2
        Width = 166
        Height = 22
        AutoSize = True
        EdgeBorders = []
        Flat = True
        Images = dmImages.ilToolBarSmall
        TabOrder = 0
        object tbtDetailNew: TToolButton
          Left = 0
          Top = 0
          Action = actDetailNew
        end
        object tbtDetailEdit: TToolButton
          Left = 23
          Top = 0
          Action = actDetailEdit
        end
        object tbtDetailDelete: TToolButton
          Left = 46
          Top = 0
          Action = actDetailDelete
        end
        object tbtDetailDuplicate: TToolButton
          Left = 69
          Top = 0
          Action = actDetailDuplicate
        end
        object tbtDetailFilter: TToolButton
          Left = 92
          Top = 0
          Action = actDetailFilter
          DropdownMenu = pmDetailFilter
        end
        object tbtDetailPrint: TToolButton
          Left = 115
          Top = 0
          Action = actDetailPrint
          DropdownMenu = pmDetailReport
        end
      end
      object tbDetailGrid: TToolBar
        Left = 214
        Top = 2
        Width = 51
        Height = 22
        Caption = 'tbMainGrid'
        EdgeBorders = []
        Flat = True
        Images = dmImages.ilToolBarSmall
        TabOrder = 1
      end
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      Category = 'Master'
    end
    inherited actEdit: TAction
      Category = 'Master'
    end
    inherited actDelete: TAction
      Category = 'Master'
    end
    inherited actDuplicate: TAction
      Category = 'Master'
    end
    inherited actFilter: TAction
      Category = 'Master'
    end
    inherited actPrint: TAction
      Category = 'Master'
    end
    object actDetailNew: TAction
      Category = 'Details'
      Caption = 'actDetailNew'
      ImageIndex = 0
      OnUpdate = actDetailNewUpdate
    end
    object actDetailEdit: TAction
      Category = 'Details'
      Caption = 'actDetailEdit'
      ImageIndex = 1
    end
    object actDetailDelete: TAction
      Category = 'Details'
      Caption = 'actDetailDelete'
      ImageIndex = 2
    end
    object actDetailDuplicate: TAction
      Category = 'Details'
      Caption = 'actDetailDuplicate'
      ImageIndex = 3
    end
    object actDetailFilter: TAction
      Category = 'Details'
      Caption = 'actDetailFilter'
      ImageIndex = 4
      OnExecute = actDetailFilterExecute
    end
    object actDetailPrint: TAction
      Category = 'Details'
      Caption = 'actDetailPrint'
      ImageIndex = 6
      OnExecute = actDetailPrintExecute
    end
  end
  object ibdsDetails: TIBDataSet [12]
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 100
    DataSource = dsMain
    ReadTransaction = IBTransaction
    Left = 288
    Top = 112
  end
  object dsDetail: TDataSource [13]
    DataSet = ibdsDetails
    Left = 320
    Top = 112
  end
  object gsQFDetail: TgsQueryFilter [14]
    OnFilterChanged = gsQFMainFilterChanged
    RequeryParams = False
    IBDataSet = ibdsDetails
    Left = 352
    Top = 112
  end
  object pmDetailFilter: TPopupMenu [15]
    Left = 384
    Top = 112
  end
  inherited gsMainReportManager: TgsReportManager
    Left = 136
    Top = 80
  end
  object DetailReportManager: TgsReportManager
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    PopupMenu = pmDetailReport
    MenuType = mtSubMenu
    Caption = 'Печать реестра'
    GroupID = 0
    Left = 136
    Top = 216
  end
  object pmDetailReport: TPopupMenu
    Left = 166
    Top = 216
  end
end
