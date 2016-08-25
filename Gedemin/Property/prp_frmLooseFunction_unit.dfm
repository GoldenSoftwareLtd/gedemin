object frmLooseFunctions: TfrmLooseFunctions
  Left = 376
  Top = 267
  Width = 527
  Height = 347
  Caption = 'Неиспользуемые cкрипт-функции'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ibgrMain: TgsIBGrid
    Left = 0
    Top = 26
    Width = 519
    Height = 265
    Align = alClient
    DataSource = dsFunction
    Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 0
    OnDblClick = ibgrMainDblClick
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
    Aliases = <>
    ShowFooter = True
    ShowTotals = False
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 291
    Width = 519
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOkChoose: TButton
      Left = 359
      Top = 6
      Width = 75
      Height = 19
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 0
    end
    object btnCancelChoose: TButton
      Left = 439
      Top = 6
      Width = 75
      Height = 19
      Action = actCancel
      Anchors = [akRight, akBottom]
      ModalResult = 2
      TabOrder = 1
    end
  end
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 519
    Height = 26
    object tb: TTBToolbar
      Left = 0
      Top = 0
      Align = alTop
      BorderStyle = bsNone
      Caption = 'tb'
      DockableTo = [dpTop]
      DockMode = dmCannotFloatOrChangeDocks
      DragHandleStyle = dhNone
      FullSize = True
      Images = dmImages.il16x16
      Options = [tboShowHint, tboToolbarStyle, tboToolbarSize]
      ParentShowHint = False
      ShowHint = True
      ShrinkMode = tbsmWrap
      Stretch = True
      TabOrder = 0
      object TBItem3: TTBItem
        Action = actRun
        Visible = False
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem1: TTBItem
        Action = actEdit
      end
      object TBItem2: TTBItem
        Action = actDelete
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object TBControlItem1: TTBControlItem
        Control = Label1
      end
      object TBControlItem2: TTBControlItem
        Control = chkEvent
      end
      object TBControlItem3: TTBControlItem
        Control = chkMethod
      end
      object TBControlItem4: TTBControlItem
        Control = chkReport
      end
      object TBControlItem5: TTBControlItem
        Control = chkOther
      end
      object TBSeparatorItem3: TTBSeparatorItem
      end
      object Label1: TLabel
        Left = 52
        Top = 4
        Width = 55
        Height = 13
        Caption = 'Показать: '
      end
      object chkEvent: TCheckBox
        Left = 107
        Top = 2
        Width = 73
        Height = 17
        Caption = 'События'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = chkEventClick
      end
      object chkMethod: TCheckBox
        Left = 180
        Top = 2
        Width = 73
        Height = 17
        Caption = 'Методы'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = chkEventClick
      end
      object chkReport: TCheckBox
        Left = 253
        Top = 2
        Width = 113
        Height = 17
        Caption = 'Функции отчетов'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = chkEventClick
      end
      object chkOther: TCheckBox
        Left = 366
        Top = 2
        Width = 81
        Height = 17
        Caption = 'Остальные'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = chkEventClick
      end
    end
  end
  object gdcFunction: TgdcFunction
    Transaction = ibtrMain
    ReadTransaction = ibtrMain
    Left = 128
    Top = 56
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 312
    Top = 128
    object actEdit: TAction
      Caption = 'Редактирование'
      Hint = 'Открыть скрипт-функцию'
      ImageIndex = 1
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actDelete: TAction
      Caption = 'Удалить'
      Hint = 'Удалить скрипт-функцию'
      ImageIndex = 2
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
    object actRun: TAction
      Caption = 'Найти'
      Hint = 'Выполнить поиск'
      ImageIndex = 73
      OnExecute = actRunExecute
      OnUpdate = actRunUpdate
    end
  end
  object dsFunction: TDataSource
    DataSet = gdcFunction
    Left = 288
    Top = 96
  end
  object ibtrMain: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 216
    Top = 128
  end
end
