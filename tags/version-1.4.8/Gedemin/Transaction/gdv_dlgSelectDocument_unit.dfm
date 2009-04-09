object dlgSelectDocument: TdlgSelectDocument
  Left = 241
  Top = 183
  Width = 693
  Height = 493
  BorderWidth = 5
  Caption = 'Выбор документа'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
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
    Width = 3
    Height = 426
    Cursor = crHSplit
  end
  object Panel1: TPanel
    Left = 0
    Top = 426
    Width = 675
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 675
      Height = 3
      Align = alTop
      Shape = bsTopLine
    end
    object Button1: TButton
      Left = 598
      Top = 9
      Width = 77
      Height = 21
      Action = actcancel
      Anchors = [akTop, akRight]
      Cancel = True
      TabOrder = 0
    end
    object Button2: TButton
      Left = 518
      Top = 9
      Width = 77
      Height = 21
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      TabOrder = 1
    end
    object Button3: TButton
      Left = 0
      Top = 9
      Width = 75
      Height = 21
      Action = acthelp
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 216
    Height = 426
    Align = alLeft
    BevelOuter = bvLowered
    Ctl3D = True
    FullRepaint = False
    ParentCtl3D = False
    TabOrder = 1
    object tvDocumentType: TgsDBTreeView
      Left = 1
      Top = 1
      Width = 214
      Height = 424
      DataSource = dsDocumentType
      KeyField = 'ID'
      ParentField = 'PARENT'
      DisplayField = 'NAME'
      Align = alClient
      BorderStyle = bsNone
      Ctl3D = True
      HideSelection = False
      Indent = 19
      ParentCtl3D = False
      SortType = stText
      TabOrder = 0
      MainFolderHead = True
      MainFolder = False
      MainFolderCaption = 'Все'
      WithCheckBox = False
    end
  end
  object Panel3: TPanel
    Left = 219
    Top = 0
    Width = 456
    Height = 426
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object sLine: TSplitter
      Left = 0
      Top = 256
      Width = 456
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object pLine: TPanel
      Left = 0
      Top = 259
      Width = 456
      Height = 167
      Align = alBottom
      BevelOuter = bvNone
      FullRepaint = False
      TabOrder = 0
      object gDocumentLine: TgsIBGrid
        Left = 0
        Top = 16
        Width = 456
        Height = 151
        Align = alClient
        BorderStyle = bsNone
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
        Width = 456
        Height = 16
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Caption = ' Позиция документа'
        Color = clWindow
        Ctl3D = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 1
      end
    end
    object Panel5: TPanel
      Left = 0
      Top = 0
      Width = 456
      Height = 256
      Align = alClient
      BevelOuter = bvNone
      FullRepaint = False
      TabOrder = 1
      object gDocument: TgsIBGrid
        Left = 0
        Top = 42
        Width = 456
        Height = 214
        Align = alClient
        BorderStyle = bsNone
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
        Top = 16
        Width = 456
        Height = 26
        object TBToolbar1: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'TBToolbar1'
          DockMode = dmCannotFloat
          FullSize = True
          Images = dmImages.il16x16
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
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 456
        Height = 16
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Caption = ' Документ'
        Color = clWindow
        Ctl3D = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
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
  end
  object dsDocumentLine: TDataSource
    Left = 337
    Top = 304
  end
end
