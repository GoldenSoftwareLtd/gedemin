inherited gdc_frmInvBaseRemains: Tgdc_frmInvBaseRemains
  Left = 644
  Top = 330
  Width = 636
  ActiveControl = ibgrDetail
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Width = 620
    OnClick = sbMainClick
  end
  inherited TBDockTop: TTBDock
    Width = 620
    inherited tbMainToolbar: TTBToolbar
      inherited tbsiMainOne: TTBSeparatorItem
        Visible = False
      end
      inherited tbsiMainTwo: TTBSeparatorItem
        Visible = False
      end
      object TBItem1: TTBItem
        Action = actOk
      end
      object TBItem2: TTBItem
        Action = actCancel
      end
    end
    inherited tbMainCustom: TTBToolbar
      Left = 547
      Visible = True
    end
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuObject: TTBSubmenuItem
        Caption = 'Остатки'
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 280
      object tbiCardInfo: TTBItem
        Action = actViewCard
      end
      object ibFullCard: TTBItem
        Action = actViewFullCard
      end
      object ibGoodInfo: TTBItem
        Action = actViewGood
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object tbAllRemainsView: TTBControlItem
        Control = cbAllRemains
      end
      object cbAllRemains: TCheckBox
        Left = 127
        Top = 2
        Width = 97
        Height = 17
        Hint = 'Позволяет просматривать нулевые и отрицательные позиции товара'
        Caption = 'Все остатки'
        TabOrder = 0
        OnClick = cbAllRemainsClick
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 514
    end
  end
  inherited TBDockRight: TTBDock
    Left = 611
  end
  inherited TBDockBottom: TTBDock
    Width = 620
  end
  inherited pnlWorkArea: TPanel
    Width = 602
    inherited spChoose: TSplitter
      Width = 602
    end
    inherited pnlMain: TPanel
      Width = 602
      object Splitter1: TSplitter [0]
        Left = 377
        Top = 0
        Width = 3
        Height = 564
        Cursor = crHSplit
      end
      object pnMain: TPanel
        Left = 160
        Top = 0
        Width = 217
        Height = 564
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'pnMain'
        TabOrder = 1
        OnResize = pnMainResize
        object tvGroup: TgsDBTreeView
          Left = 0
          Top = 0
          Width = 217
          Height = 564
          DataSource = dsDetail
          KeyField = 'ID'
          ParentField = 'PARENT'
          DisplayField = 'NAME'
          ImageField = 'CONTACTTYPE'
          ImageValueList.Strings = (
            '101=3')
          Align = alClient
          ChangeDelay = 300
          Indent = 19
          RightClickSelect = True
          SortType = stText
          TabOrder = 0
          MainFolderHead = True
          MainFolder = True
          MainFolderCaption = 'Все'
          WithCheckBox = True
        end
      end
      object pnDetail: TPanel
        Left = 380
        Top = 0
        Width = 222
        Height = 564
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnDetail'
        TabOrder = 2
        object ibgrDetail: TgsIBGrid
          Left = 0
          Top = 0
          Width = 222
          Height = 564
          HelpContext = 3
          Align = alClient
          Ctl3D = True
          DataSource = dsMain
          Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
          ParentCtl3D = False
          PopupMenu = pmMain
          ReadOnly = True
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
          Aliases = <
            item
              Alias = 'REMAINS'
              LName = 'Остаток'
            end>
        end
      end
    end
    inherited pnChoose: TPanel
      Width = 602
      inherited pnButtonChoose: TPanel
        Left = 497
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 497
      end
      inherited pnlChooseCaption: TPanel
        Width = 602
      end
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      Enabled = False
      Visible = False
    end
    inherited actEdit: TAction
      Enabled = False
      Visible = False
    end
    inherited actDelete: TAction
      Enabled = False
      Visible = False
    end
    inherited actDuplicate: TAction
      Enabled = False
      Visible = False
    end
    object actOk: TAction
      Category = 'Commands'
      Caption = 'Oк'
      ImageIndex = 14
      ShortCut = 32781
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Category = 'Commands'
      Caption = 'Отмена'
      ImageIndex = 20
      ShortCut = 27
      OnExecute = actCancelExecute
    end
    object actEditSelect: TAction
      Caption = 'Изменить запрос...'
    end
    object actViewCard: TAction
      Category = 'Commands'
      Caption = 'Карточка по ТМЦ'
      Hint = 'Карточка по ТМЦ'
      ImageIndex = 73
      OnExecute = actViewCardExecute
    end
    object actViewFullCard: TAction
      Category = 'Commands'
      Caption = 'Полная карточка ТМЦ...'
      Hint = 'Полная карточка ТМЦ...'
      ImageIndex = 74
      OnExecute = actViewFullCardExecute
    end
    object actViewGood: TAction
      Category = 'Commands'
      Caption = 'Просмотр товара'
      Hint = 'Просмотр товара'
      ImageIndex = 75
      OnExecute = actViewGoodExecute
      OnUpdate = actViewGoodUpdate
    end
  end
  inherited dsMain: TDataSource
    Left = 388
    Top = 228
  end
  object dsDetail: TDataSource
    DataSet = gdcGoodGroup
    Left = 88
    Top = 140
  end
  object gdcGoodGroup: TgdcGoodGroup
    Left = 121
    Top = 139
  end
end
