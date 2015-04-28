inherited gdc_frmMDHGR: Tgdc_frmMDHGR
  Left = 458
  Top = 237
  Width = 605
  Caption = 'gdc_frmMDHGR'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Width = 597
    OnClick = sbMainClick
  end
  inherited TBDockTop: TTBDock
    Width = 597
    inherited tbMainInvariant: TTBToolbar
      Left = 327
    end
  end
  inherited TBDockRight: TTBDock
    Left = 588
  end
  inherited TBDockBottom: TTBDock
    Width = 597
  end
  inherited pnlWorkArea: TPanel
    Width = 579
    inherited sMasterDetail: TSplitter
      Width = 579
    end
    inherited spChoose: TSplitter
      Width = 579
    end
    inherited pnlMain: TPanel
      Width = 579
      object ibgrMain: TgsIBGrid
        Left = 160
        Top = 0
        Width = 419
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
      Width = 579
      inherited pnButtonChoose: TPanel
        Left = 474
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 474
      end
      inherited pnlChooseCaption: TPanel
        Width = 579
      end
    end
    inherited pnlDetail: TPanel
      Width = 579
      BevelOuter = bvNone
      inherited TBDockDetail: TTBDock
        Left = 0
        Top = 0
        Width = 579
        inherited tbDetailCustom: TTBToolbar
          Left = 275
        end
      end
      inherited pnlSearchDetail: TPanel
        Left = 0
        Top = 26
        Height = 76
        TabOrder = 2
        inherited sbSearchDetail: TScrollBox
          Height = 38
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 38
        end
      end
      object ibgrDetail: TgsIBGrid
        Left = 160
        Top = 26
        Width = 419
        Height = 76
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
