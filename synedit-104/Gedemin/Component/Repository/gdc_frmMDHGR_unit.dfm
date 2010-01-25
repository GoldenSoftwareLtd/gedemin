inherited gdc_frmMDHGR: Tgdc_frmMDHGR
  Left = 362
  Top = 238
  Width = 613
  Height = 484
  Caption = 'gdc_frmMDHGR'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 438
    Width = 605
    OnClick = sbMainClick
  end
  inherited TBDockTop: TTBDock
    Width = 605
    inherited tbMainInvariant: TTBToolbar
      Left = 327
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 380
  end
  inherited TBDockRight: TTBDock
    Left = 596
    Height = 380
  end
  inherited TBDockBottom: TTBDock
    Top = 429
    Width = 605
  end
  inherited pnlWorkArea: TPanel
    Width = 587
    Height = 380
    inherited sMasterDetail: TSplitter
      Width = 587
      Beveled = False
    end
    inherited spChoose: TSplitter
      Top = 277
      Width = 587
    end
    inherited pnlMain: TPanel
      Width = 587
      object ibgrMain: TgsIBGrid
        Left = 160
        Top = 0
        Width = 427
        Height = 167
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsMain
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        PopupMenu = pmMain
        ReadOnly = True
        TabOrder = 1
        OnDblClick = ibgrMainDblClick
        OnEnter = ibgrMainEnter
        OnKeyDown = ibgrMainKeyDown
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.CheckBoxEvent = ibgrMainClickCheck
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        OnClickCheck = ibgrMainClickCheck
      end
    end
    inherited pnChoose: TPanel
      Top = 281
      Width = 587
      inherited pnButtonChoose: TPanel
        Left = 482
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 482
      end
      inherited pnlChooseCaption: TPanel
        Width = 587
      end
    end
    inherited pnlDetail: TPanel
      Width = 587
      Height = 106
      BevelOuter = bvNone
      inherited TBDockDetail: TTBDock
        Left = 0
        Top = 0
        Width = 587
        inherited tbDetailCustom: TTBToolbar
          Left = 275
        end
      end
      inherited pnlSearchDetail: TPanel
        Left = 0
        Top = 26
        Height = 80
        TabOrder = 2
        inherited sbSearchDetail: TScrollBox
          Height = 42
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 42
        end
      end
      object ibgrDetail: TgsIBGrid
        Left = 160
        Top = 26
        Width = 427
        Height = 80
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsDetail
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        PopupMenu = pmDetail
        ReadOnly = True
        TabOrder = 1
        OnDblClick = ibgrDetailDblClick
        OnEnter = ibgrDetailEnter
        OnKeyDown = ibgrDetailKeyDown
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
    inherited actEditInGrid: TAction
      Visible = True
      OnExecute = actEditInGridExecute
      OnUpdate = actEditInGridUpdate
    end
    inherited actDetailEditInGrid: TAction
      Visible = True
      OnExecute = actDetailEditInGridExecute
      OnUpdate = actDetailEditInGridUpdate
    end
  end
end
