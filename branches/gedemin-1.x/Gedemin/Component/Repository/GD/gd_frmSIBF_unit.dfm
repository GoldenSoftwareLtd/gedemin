inherited gd_frmSIBF: Tgd_frmSIBF
  Left = 154
  Top = 170
  Width = 646
  Height = 402
  Caption = 'gd_frmSIBF'
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 337
    Width = 638
  end
  inherited pnlMain: TPanel
    Width = 638
    Height = 337
    object ibgrMain: TgsIBGrid [0]
      Left = 1
      Top = 29
      Width = 636
      Height = 307
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsMain
      Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 0
      OnCellClick = ibgrMainCellClick
      OnDblClick = ibgrMainDblClick
      OnKeyPress = ibgrMainKeyPress
      OnTitleClick = ibgrMainTitleClick
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
      ToolBar = tbMainGrid
      ColumnEditors = <>
      Aliases = <>
    end
    inherited cbMain: TControlBar
      Width = 636
      AutoDock = False
      TabOrder = 1
      inherited tbMain: TToolBar
        inherited tbtNew: TToolButton
          ParentShowHint = False
        end
        inherited tbtEdit: TToolButton
          ParentShowHint = False
        end
        inherited tbtDelete: TToolButton
          ParentShowHint = False
        end
        inherited tbtDuplicate: TToolButton
          ParentShowHint = False
        end
        inherited tbtFilter: TToolButton
          DropdownMenu = pmMainFilter
          ParentShowHint = False
        end
      end
      object tbMainGrid: TToolBar
        Left = 374
        Top = 2
        Width = 43
        Height = 22
        Caption = 'tbMainGrid'
        EdgeBorders = []
        Flat = True
        TabOrder = 1
      end
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      Hint = 'Создать новую запись'
    end
    inherited actEdit: TAction
      Hint = 'Изменить текущую запись'
      ShortCut = 13
    end
    inherited actDelete: TAction
      Hint = 'Удалить текущую запись'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    inherited actDuplicate: TAction
      Hint = 'Создать копию текущей записи'
      ShortCut = 32884
    end
    inherited actFilter: TAction
      Hint = 'Отфильтровать записи'
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 256
    Top = 80
  end
  object ibdsMain: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    Left = 288
    Top = 80
  end
  object dsMain: TDataSource
    DataSet = ibdsMain
    Left = 320
    Top = 80
  end
  object gsQFMain: TgsQueryFilter
    OnFilterChanged = gsQFMainFilterChanged
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsMain
    Left = 352
    Top = 80
  end
  object pmMainFilter: TPopupMenu
    Left = 384
    Top = 80
  end
  object gsMainReportManager: TgsReportManager
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    PopupMenu = pmMainReport
    MenuType = mtSubMenu
    Caption = 'Печать реестра'
    GroupID = 0
    Left = 256
    Top = 120
  end
end
