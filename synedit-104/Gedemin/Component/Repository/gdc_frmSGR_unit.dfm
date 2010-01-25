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
    Top = 393
    Width = 599
  end
  inherited TBDockTop: TTBDock
    Width = 599
    inherited tbMainMenu: TTBToolbar
      DockPos = 8
      DockRow = 0
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 327
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 344
  end
  inherited TBDockRight: TTBDock
    Left = 590
    Height = 344
  end
  inherited TBDockBottom: TTBDock
    Top = 412
    Width = 599
  end
  inherited pnlWorkArea: TPanel
    Width = 581
    Height = 344
    TabOrder = 0
    inherited spChoose: TSplitter
      Top = 241
      Width = 581
    end
    inherited pnlMain: TPanel
      Width = 581
      Height = 241
      inherited pnlSearchMain: TPanel
        Height = 241
        inherited sbSearchMain: TScrollBox
          Height = 203
        end
        inherited pnlSearchMainButton: TPanel
          Top = 203
        end
      end
      object ibgrMain: TgsIBGrid
        Left = 160
        Top = 0
        Width = 421
        Height = 241
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
      Top = 245
      Width = 581
      inherited pnButtonChoose: TPanel
        Left = 476
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 476
      end
      inherited pnlChooseCaption: TPanel
        Width = 581
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
