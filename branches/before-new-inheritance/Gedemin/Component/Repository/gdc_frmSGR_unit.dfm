inherited gdc_frmSGR: Tgdc_frmSGR
  Left = 258
  Top = 218
  Width = 607
  Height = 448
  Caption = 'gdc_frmSGR'
  Font.Charset = DEFAULT_CHARSET
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 382
    Width = 591
  end
  inherited TBDockTop: TTBDock
    Width = 591
    inherited tbMainMenu: TTBToolbar
      DockPos = 8
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 327
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 331
  end
  inherited TBDockRight: TTBDock
    Left = 582
    Height = 331
  end
  inherited TBDockBottom: TTBDock
    Top = 401
    Width = 591
  end
  inherited pnlWorkArea: TPanel
    Width = 573
    Height = 331
    TabOrder = 0
    inherited spChoose: TSplitter
      Top = 228
      Width = 573
    end
    inherited pnlMain: TPanel
      Width = 573
      Height = 228
      inherited pnlSearchMain: TPanel
        Height = 228
        inherited sbSearchMain: TScrollBox
          Height = 190
        end
        inherited pnlSearchMainButton: TPanel
          Top = 190
        end
      end
      object ibgrMain: TgsIBGrid
        Left = 160
        Top = 0
        Width = 413
        Height = 228
        HelpContext = 3
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsMain
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        PopupMenu = pmMain
        ReadOnly = True
        TabOrder = 1
        OnDblClick = ibgrMainDblClick
        OnDragDrop = ibgrMainDragDrop
        OnDragOver = ibgrMainDragOver
        OnKeyDown = ibgrMainKeyDown
        OnMouseMove = ibgrMainMouseMove
        OnStartDrag = ibgrMainStartDrag
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.FieldName = 'id'
        CheckBox.Visible = True
        CheckBox.CheckBoxEvent = ibgrMainClickCheck
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        OnClickCheck = ibgrMainClickCheck
      end
    end
    inherited pnChoose: TPanel
      Top = 232
      Width = 573
      inherited pnButtonChoose: TPanel
        Left = 468
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 468
      end
      inherited pnlChooseCaption: TPanel
        Width = 573
      end
    end
  end
  inherited alMain: TActionList
    Top = 136
    inherited actEditInGrid: TAction
      Visible = True
      OnExecute = actEditInGridExecute
      OnUpdate = actEditInGridUpdate
    end
  end
end
