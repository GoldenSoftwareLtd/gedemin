inherited gdc_frmMDVTree: Tgdc_frmMDVTree
  Left = 397
  Top = 92
  Width = 812
  Height = 612
  Caption = 'gdc_frmMDVTree'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 555
    Width = 796
  end
  inherited TBDockTop: TTBDock
    Width = 796
    inherited tbMainToolbar: TTBToolbar
      Visible = False
    end
    inherited tbMainMenu: TTBToolbar
      DockPos = 136
      inherited tbsiMainMenuObject: TTBSubmenuItem
        object tbi_mm_ShowSubGroups: TTBItem [16]
          Action = actShowSubGroups
        end
        object tbi_mm_AllowDragnDrop: TTBItem [17]
          Action = actAllowDragnDrop
        end
        object tbi_mm_sep5: TTBSeparatorItem [18]
        end
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 280
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 495
  end
  inherited TBDockRight: TTBDock
    Left = 787
    Height = 495
  end
  inherited TBDockBottom: TTBDock
    Top = 546
    Width = 796
  end
  inherited pnlWorkArea: TPanel
    Width = 778
    Height = 495
    inherited sMasterDetail: TSplitter
      Left = 166
      Height = 390
    end
    inherited spChoose: TSplitter
      Top = 390
      Width = 778
    end
    inherited pnlMain: TPanel
      Width = 166
      Height = 390
      inherited pnlSearchMain: TPanel
        Height = 390
        inherited sbSearchMain: TScrollBox
          Height = 363
        end
      end
      object tvGroup: TgsDBTreeView
        Left = 160
        Top = 0
        Width = 6
        Height = 390
        DataSource = dsMain
        KeyField = 'ID'
        ParentField = 'PARENT'
        DisplayField = 'NAME'
        ImageValueList.Strings = (
          '')
        Align = alClient
        DragMode = dmAutomatic
        Indent = 19
        PopupMenu = pmMain
        RightClickSelect = True
        SortType = stText
        TabOrder = 1
        OnDblClick = tvGroupDblClick
        OnDragDrop = tvGroupDragDrop
        OnDragOver = tvGroupDragOver
        OnEnter = tvGroupEnter
        OnStartDrag = tvGroupStartDrag
        MainFolderHead = True
        MainFolder = True
        MainFolderCaption = 'Все'
        WithCheckBox = True
        OnClickedCheck = tvGroupClickedCheck
      end
    end
    inherited pnChoose: TPanel
      Top = 396
      Width = 778
      inherited pnButtonChoose: TPanel
        Left = 673
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 673
      end
      inherited pnlChooseCaption: TPanel
        Width = 778
      end
    end
    inherited pnlDetail: TPanel
      Left = 172
      Width = 606
      Height = 390
      BevelOuter = bvNone
      inherited TBDockDetail: TTBDock
        Left = 0
        Top = 0
        Width = 606
        inherited tbDetailCustom: TTBToolbar
          Left = 275
        end
      end
      inherited pnlSearchDetail: TPanel
        Left = 0
        Top = 26
        Height = 364
        TabOrder = 2
        inherited sbSearchDetail: TScrollBox
          Height = 337
        end
      end
      object ibgrDetail: TgsIBGrid
        Left = 160
        Top = 26
        Width = 446
        Height = 364
        HelpContext = 3
        Align = alClient
        BorderStyle = bsNone
        Ctl3D = True
        DataSource = dsDetail
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        ParentCtl3D = False
        PopupMenu = pmDetail
        TabOrder = 1
        OnDblClick = ibgrDetailDblClick
        OnDragDrop = ibgrDetailDragDrop
        OnDragOver = ibgrDetailDragOver
        OnEnter = ibgrDetailEnter
        OnKeyDown = ibgrDetailKeyDown
        OnMouseMove = ibgrDetailMouseMove
        OnStartDrag = ibgrDetailStartDrag
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.CheckBoxEvent = ibgrDetailClickCheck
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        OnClickCheck = ibgrDetailClickCheck
      end
    end
  end
  inherited alMain: TActionList
    inherited actFind: TAction
      Enabled = False
      Visible = False
    end
    inherited actSearchDetail: TAction [38]
    end
    inherited actSearchdetailClose: TAction [39]
    end
    inherited actDetailAddToSelected: TAction [40]
    end
    inherited actDetailRemoveFromSelected: TAction [41]
    end
    inherited actDetailOnlySelected: TAction [42]
    end
    inherited actDetailQExport: TAction [43]
    end
    object actShowSubGroups: TAction [44]
      Category = 'Main'
      Caption = 'Вложенные уровни'
      Checked = True
      OnExecute = actShowSubGroupsExecute
      OnUpdate = actShowSubGroupsUpdate
    end
    inherited actSelectAll: TAction [45]
    end
    inherited actUnSelectAll: TAction [46]
    end
    inherited actDetailToSetting: TAction [47]
    end
    inherited actDetailSaveToFile: TAction [48]
    end
    inherited actClearSelection: TAction [49]
    end
    inherited actEditInGrid: TAction [50]
    end
    inherited actDeleteChoose: TAction [51]
    end
    inherited actLinkObject: TAction [52]
    end
    inherited actDetailLoadFromFile: TAction [53]
    end
    inherited actCopySettingsFromUser: TAction [54]
    end
    inherited actDetailEditInGrid: TAction
      Visible = True
      OnExecute = actDetailEditInGridExecute
      OnUpdate = actDetailEditInGridUpdate
    end
    object actAllowDragnDrop: TAction
      Category = 'Main'
      Caption = 'Разрешить перетаскивание'
      Checked = True
      OnExecute = actAllowDragnDropExecute
    end
  end
end
