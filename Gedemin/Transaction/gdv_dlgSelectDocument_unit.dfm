object dlgSelectDocument: TdlgSelectDocument
  Left = 315
  Top = 173
  Width = 710
  Height = 493
  BorderWidth = 5
  Caption = 'Выбор документа'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 216
    Top = 0
    Width = 4
    Height = 418
    Cursor = crHSplit
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 418
    Width = 684
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Button3: TButton
      Left = 3
      Top = 6
      Width = 75
      Height = 21
      Action = acthelp
      Anchors = []
      TabOrder = 0
    end
    object Panel1: TPanel
      Left = 499
      Top = 0
      Width = 185
      Height = 30
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object Button2: TButton
        Left = 20
        Top = 7
        Width = 77
        Height = 21
        Action = actOk
        Anchors = []
        Default = True
        TabOrder = 0
      end
      object Button1: TButton
        Left = 106
        Top = 7
        Width = 77
        Height = 21
        Action = actcancel
        Anchors = []
        Cancel = True
        TabOrder = 1
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 216
    Height = 418
    Align = alLeft
    BevelOuter = bvNone
    Ctl3D = True
    FullRepaint = False
    ParentCtl3D = False
    TabOrder = 0
    object tvDocumentType: TgsDBTreeView
      Left = 0
      Top = 0
      Width = 216
      Height = 418
      DataSource = dsDocumentType
      KeyField = 'ID'
      ParentField = 'PARENT'
      DisplayField = 'NAME'
      Align = alClient
      Ctl3D = True
      HideSelection = False
      Indent = 19
      ParentCtl3D = False
      ReadOnly = True
      SortType = stText
      TabOrder = 0
      MainFolderHead = True
      MainFolder = False
      MainFolderCaption = 'Все'
      WithCheckBox = False
    end
  end
  object Panel3: TPanel
    Left = 220
    Top = 0
    Width = 464
    Height = 418
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object sLine: TSplitter
      Left = 0
      Top = 247
      Width = 464
      Height = 4
      Cursor = crVSplit
      Align = alBottom
    end
    object pLine: TPanel
      Left = 0
      Top = 251
      Width = 464
      Height = 167
      Align = alBottom
      BevelOuter = bvNone
      FullRepaint = False
      TabOrder = 1
      object gDocumentLine: TgsIBGrid
        Left = 0
        Top = 20
        Width = 464
        Height = 147
        Align = alClient
        Ctl3D = True
        DataSource = dsDocumentLine
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        ParentCtl3D = False
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.FieldName = 'ID'
        CheckBox.Visible = True
        CheckBox.CheckBoxEvent = gDocumentLineClickCheck
        CheckBox.FirstColumn = True
        MinColWidth = 40
        RememberPosition = False
        SaveSettings = False
        ColumnEditors = <>
        Aliases = <>
        ShowTotals = False
        OnClickCheck = gDocumentLineClickCheck
      end
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 464
        Height = 20
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = ' Позиция документа'
        Color = clActiveCaption
        Ctl3D = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 1
      end
    end
    object Panel5: TPanel
      Left = 0
      Top = 0
      Width = 464
      Height = 247
      Align = alClient
      BevelOuter = bvNone
      FullRepaint = False
      TabOrder = 0
      object gDocument: TgsIBGrid
        Left = 0
        Top = 46
        Width = 464
        Height = 201
        Align = alClient
        Ctl3D = True
        DataSource = dsDocument
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        ParentCtl3D = False
        TabOrder = 0
        OnDblClick = gDocumentDblClick
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.FieldName = 'ID'
        CheckBox.Visible = True
        CheckBox.CheckBoxEvent = gDocumentClickCheck
        CheckBox.FirstColumn = True
        MinColWidth = 40
        RememberPosition = False
        SaveSettings = False
        ColumnEditors = <>
        Aliases = <>
        ShowTotals = False
        OnClickCheck = gDocumentClickCheck
      end
      object TBDock1: TTBDock
        Left = 0
        Top = 20
        Width = 464
        Height = 26
        object TBToolbar1: TTBToolbar
          Left = 0
          Top = 0
          BorderStyle = bsNone
          Caption = 'TBToolbar1'
          DockMode = dmCannotFloat
          FullSize = True
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object TBItem3: TTBItem
            Action = actNewDocument
          end
          object TBItem2: TTBItem
            Action = actEditDocument
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBItem1: TTBItem
            Action = actDeleteDocument
          end
          object TBSeparatorItem2: TTBSeparatorItem
          end
          object TBControlItem2: TTBControlItem
            Control = Label1
          end
          object TBControlItem1: TTBControlItem
            Control = gsPeriod
          end
          object TBItem4: TTBItem
            Action = actRun
          end
          object Label1: TLabel
            Left = 81
            Top = 4
            Width = 45
            Height = 13
            Caption = 'Период: '
          end
          object gsPeriod: TgsPeriodEdit
            Left = 126
            Top = 0
            Width = 148
            Height = 21
            TabOrder = 0
          end
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 464
        Height = 20
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = ' Документ'
        Color = clActiveCaption
        Ctl3D = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 2
      end
    end
  end
  object gdcDocumentType: TgdcBaseDocumentType
    AfterScroll = gdcDocumentTypeAfterScroll
    Left = 64
    Top = 152
  end
  object dsDocumentType: TDataSource
    DataSet = gdcDocumentType
    Left = 96
    Top = 152
  end
  object dsDocument: TDataSource
    Left = 337
    Top = 80
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 401
    Top = 136
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
    end
    object actcancel: TAction
      Caption = 'Отмена'
      OnExecute = actcancelExecute
    end
    object acthelp: TAction
      Caption = 'Справка'
      Visible = False
    end
    object actNewDocument: TAction
      Caption = 'actNewDocument'
      ImageIndex = 0
      OnExecute = actNewDocumentExecute
      OnUpdate = actNewDocumentUpdate
    end
    object actEditDocument: TAction
      Caption = 'actEditDocument'
      ImageIndex = 1
      OnExecute = actEditDocumentExecute
      OnUpdate = actNewDocumentUpdate
    end
    object actDeleteDocument: TAction
      Caption = 'actDeleteDocument'
      ImageIndex = 2
      OnExecute = actDeleteDocumentExecute
      OnUpdate = actNewDocumentUpdate
    end
    object actRun: TAction
      Hint = 'Установить ограничение'
      ImageIndex = 4
      OnExecute = actRunExecute
    end
  end
  object dsDocumentLine: TDataSource
    Left = 337
    Top = 304
  end
end
