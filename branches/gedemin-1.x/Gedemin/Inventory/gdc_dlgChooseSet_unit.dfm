object dlg_ChooseSet: Tdlg_ChooseSet
  Left = 300
  Top = 137
  Width = 513
  Height = 432
  Caption = 'Выбор'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object pnlWorkArea: TPanel
    Left = 9
    Top = 26
    Width = 487
    Height = 370
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object spChoose: TSplitter
      Left = 0
      Top = 245
      Width = 487
      Height = 5
      Cursor = crVSplit
      Align = alTop
      ResizeStyle = rsUpdate
    end
    object pnlMain: TPanel
      Left = 0
      Top = 0
      Width = 487
      Height = 245
      Align = alTop
      BevelOuter = bvNone
      Constraints.MinHeight = 100
      Constraints.MinWidth = 200
      TabOrder = 0
      object dbtvMain: TgsDBTreeView
        Left = 0
        Top = 0
        Width = 487
        Height = 245
        KeyField = 'ID'
        ParentField = 'PARENT'
        DisplayField = 'NAME'
        Align = alClient
        Indent = 19
        SortType = stText
        TabOrder = 1
        Visible = False
        MainFolderHead = True
        MainFolder = False
        MainFolderCaption = 'Все'
        WithCheckBox = True
        OnClickedCheck = ibgrMainClickedCheck
      end
      object ibgrMain: TgsIBGrid
        Left = 0
        Top = 0
        Width = 487
        Height = 245
        HelpContext = 3
        Align = alClient
        DataSource = dsMain
        Options = [dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <
          item
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            Color = clWhite
            ConditionKind = ckNone
            DisplayOptions = []
            EvaluateFormula = False
            UserCondition = False
          end>
        ConditionsActive = False
        CheckBox.Visible = True
        CheckBox.AfterCheckEvent = ibgrMainClickedCheck
        CheckBox.FirstColumn = True
        ScaleColumns = True
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
        ShowFooter = True
        ShowTotals = False
        OnClickedCheck = ibgrMainClickedCheck
      end
    end
    object pnChoose: TPanel
      Left = 0
      Top = 250
      Width = 487
      Height = 120
      Align = alClient
      BevelOuter = bvNone
      Constraints.MinHeight = 120
      TabOrder = 1
      object pnButtonChoose: TPanel
        Left = 400
        Top = 18
        Width = 87
        Height = 102
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnCancelChoose: TButton
          Left = 6
          Top = 80
          Width = 75
          Height = 19
          Anchors = [akLeft, akBottom]
          Caption = 'Отмена'
          ModalResult = 2
          TabOrder = 0
        end
        object btnOkChoose: TButton
          Left = 6
          Top = 56
          Width = 75
          Height = 19
          Action = actChooseOk
          Anchors = [akLeft, akBottom]
          Default = True
          TabOrder = 1
        end
        object btnDeleteChoose: TButton
          Left = 6
          Top = 4
          Width = 75
          Height = 19
          Action = actDeleteChoose
          TabOrder = 2
        end
        object Button1: TButton
          Left = 6
          Top = 28
          Width = 75
          Height = 19
          Action = actClearChoose
          TabOrder = 3
        end
      end
      object pnlChooseCaption: TPanel
        Left = 0
        Top = 0
        Width = 487
        Height = 18
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = '  Выбранные записи:'
        ParentColor = True
        TabOrder = 1
        object Bevel1: TBevel
          Left = 0
          Top = 0
          Width = 487
          Height = 2
          Align = alTop
          Style = bsRaised
        end
      end
      object dbgrChoose: TgsDBGrid
        Left = 0
        Top = 18
        Width = 400
        Height = 102
        Align = alClient
        DataSource = dsChoose
        Options = [dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 2
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        ScaleColumns = True
        MinColWidth = 40
        ShowTotals = False
        ShowFooter = True
      end
    end
  end
  object TBDockTop: TTBDock
    Left = 0
    Top = 0
    Width = 505
    Height = 26
    object tbMainToolbar: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Панель инструментов'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 16
      DockRow = 1
      FloatingMode = fmOnTopOfAllForms
      Images = dmImages.il16x16
      ParentShowHint = False
      ProcessShortCuts = True
      ShowHint = True
      Stretch = True
      TabOrder = 0
      object tbiAuto: TTBItem
        Action = actAuto
        AutoCheck = True
        GroupIndex = 1
      end
      object tbiAsGrid: TTBItem
        Action = actAsGrid
        AutoCheck = True
        GroupIndex = 1
      end
      object tbiAsTree: TTBItem
        Action = actAsTree
        AutoCheck = True
        GroupIndex = 1
      end
      object TBSeparatorItem3: TTBSeparatorItem
      end
      object TBItem4: TTBItem
        Action = actChooseAll
      end
      object TBItem1: TTBItem
        Action = actUnChooseAll
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem3: TTBItem
        Action = actSelectAll
      end
      object TBItem2: TTBItem
        Action = actUnSelectAll
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object tbiFind: TTBItem
        Action = actFind
        Visible = False
      end
      object tbiCompanyFilter: TTBItem
        Action = actCompanyFilter
        AutoCheck = True
      end
    end
  end
  object TBDockLeft: TTBDock
    Left = 0
    Top = 26
    Width = 9
    Height = 370
    Position = dpLeft
  end
  object TBDockBottom: TTBDock
    Left = 0
    Top = 396
    Width = 505
    Height = 9
    Position = dpBottom
  end
  object TBDockRight: TTBDock
    Left = 496
    Top = 26
    Width = 9
    Height = 370
    Position = dpRight
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 100
    Top = 128
    object actFind: TAction
      Category = 'Commands'
      Caption = 'Поиск...'
      Hint = 'Поиск'
      ImageIndex = 23
      ShortCut = 16467
    end
    object actFilter: TAction
      Category = 'Commands'
      Caption = 'Фильтр'
      Hint = 'Фильтр'
      ImageIndex = 20
    end
    object actSearchMain: TAction
      Category = 'Commands'
      Caption = 'Найти'
      Hint = 'Найти'
    end
    object actSearchMainClose: TAction
      Category = 'Commands'
      Caption = 'Закрыть'
      Hint = 'Закрыть'
    end
    object actOnlySelected: TAction
      Category = 'Commands'
      Caption = 'Только отмеченные'
      Hint = 'Только отмеченные'
      ImageIndex = 6
    end
    object actAddToSelected: TAction
      Category = 'Commands'
      Caption = 'Добавить в отмеченные'
      Hint = 'Добавить в отмеченные'
      ImageIndex = 5
    end
    object actRemoveFromSelected: TAction
      Category = 'Commands'
      Caption = 'Удалить из отмеченных'
      Hint = 'Удалить из отмеченных'
    end
    object actChooseOk: TAction
      Caption = 'Ok'
      Hint = 'Выбрать записи'
      ShortCut = 27
      OnExecute = actChooseOkExecute
    end
    object actDeleteChoose: TAction
      Caption = 'Удалить'
      Hint = 'Удалить из выбранных'
      OnExecute = actDeleteChooseExecute
    end
    object actSelectAll: TAction
      Caption = 'Выделить все'
      Hint = 'Выделить со всеми вложенными'
      ImageIndex = 40
      OnExecute = actSelectAllExecute
      OnUpdate = actSelectAllUpdate
    end
    object actUnSelectAll: TAction
      Caption = 'Убрать выделение'
      Hint = 'Убрать выделение со всех вложенных'
      ImageIndex = 41
      OnExecute = actUnSelectAllExecute
      OnUpdate = actSelectAllUpdate
    end
    object actUnChooseAll: TAction
      Caption = 'Очистить'
      Hint = 'Убрать выделение со всех записей'
      ImageIndex = 39
      OnExecute = actClearChooseExecute
    end
    object actChooseAll: TAction
      Caption = 'actChooseAll'
      Hint = 'Выделить все'
      ImageIndex = 38
      OnExecute = actChooseAllExecute
    end
    object actAsTree: TAction
      Caption = 'Дерево'
      Hint = 'В виде дерева'
      ImageIndex = 142
      OnExecute = actAsTreeExecute
      OnUpdate = actAsTreeUpdate
    end
    object actAsGrid: TAction
      Caption = 'Таблица'
      Hint = 'В виде таблицы'
      ImageIndex = 210
      OnExecute = actAsGridExecute
    end
    object actAuto: TAction
      Caption = 'Автоматически'
      Checked = True
      Hint = 'Автоматически'
      ImageIndex = 224
      OnExecute = actAutoExecute
    end
    object actClearChoose: TAction
      Caption = 'Очистить'
      Hint = 'Очистить список выбранных'
      OnExecute = actClearChooseExecute
    end
    object actCompanyFilter: TAction
      Caption = 'actCompanyFilter'
      Hint = 'Для выбранной рабочей организации'
      ImageIndex = 147
      OnExecute = actCompanyFilterExecute
    end
  end
  object dsMain: TDataSource
    DataSet = ibdsMain
    Left = 92
    Top = 204
  end
  object dsChoose: TDataSource
    DataSet = cdsChoose
    Left = 153
    Top = 306
  end
  object ibdsMain: TIBDataSet
    OnFilterRecord = ibdsMainFilterRecord
    Left = 273
    Top = 106
  end
  object cdsChoose: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'name'
        DataType = ftString
        Size = 80
      end
      item
        Name = 'id'
        DataType = ftInteger
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    BeforeDelete = cdsChooseBeforeDelete
    Left = 337
    Top = 321
  end
end
