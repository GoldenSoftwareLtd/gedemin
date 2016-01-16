object dlgToNamespace: TdlgToNamespace
  Left = 689
  Top = 280
  Width = 737
  Height = 542
  Caption = 'Добавление/перемещение/удаление объекта пространства имен'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlGrid: TPanel
    Left = 0
    Top = 208
    Width = 721
    Height = 295
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 0
    object pnlButtons: TPanel
      Left = 8
      Top = 259
      Width = 705
      Height = 28
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object pnlRightBottom: TPanel
        Left = 481
        Top = 0
        Width = 224
        Height = 28
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnOk: TButton
          Left = 68
          Top = 7
          Width = 75
          Height = 21
          Action = actOK
          Default = True
          TabOrder = 0
        end
        object btnCancel: TButton
          Left = 148
          Top = 7
          Width = 75
          Height = 21
          Cancel = True
          Caption = '&Отмена'
          ModalResult = 2
          TabOrder = 1
        end
      end
      object btnHelp: TButton
        Left = 1
        Top = 6
        Width = 75
        Height = 21
        Action = actHelp
        TabOrder = 1
      end
    end
    object pnlDependencies: TPanel
      Left = 8
      Top = 8
      Width = 705
      Height = 251
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object dbgrListLink: TgsDBGrid
        Left = 0
        Top = 0
        Width = 705
        Height = 230
        Align = alClient
        DataSource = dsLink
        Options = [dgTitles, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ParentFont = False
        PopupMenu = pm
        ReadOnly = True
        TabOrder = 0
        TableFont.Charset = DEFAULT_CHARSET
        TableFont.Color = clWindowText
        TableFont.Height = -11
        TableFont.Name = 'Tahoma'
        TableFont.Style = []
        SelectedFont.Charset = DEFAULT_CHARSET
        SelectedFont.Color = clHighlightText
        SelectedFont.Height = -11
        SelectedFont.Name = 'Tahoma'
        SelectedFont.Style = []
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = True
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.DisplayField = 'class'
        CheckBox.FieldName = 'id'
        CheckBox.Visible = False
        CheckBox.FirstColumn = True
        ScaleColumns = True
        MinColWidth = 40
        ShowTotals = False
      end
      object tsObjects: TTabSet
        Left = 0
        Top = 230
        Width = 705
        Height = 21
        Align = alBottom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        SelectedColor = clActiveCaption
        Tabs.Strings = (
          'Зависимости'
          'Дополнительные')
        TabIndex = 0
        UnselectedColor = clMenu
        OnChange = tsObjectsChange
      end
    end
  end
  object pnlObj: TPanel
    Left = 0
    Top = 0
    Width = 721
    Height = 208
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object pnlState: TPanel
      Left = 0
      Top = 0
      Width = 721
      Height = 114
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 8
      ParentColor = True
      TabOrder = 0
      object pnlInfo: TPanel
        Left = 8
        Top = 8
        Width = 705
        Height = 73
        Align = alClient
        BevelOuter = bvNone
        ParentColor = True
        TabOrder = 0
        object mInfo: TMemo
          Left = 0
          Top = 0
          Width = 705
          Height = 73
          Align = alClient
          BorderStyle = bsNone
          ParentColor = True
          ReadOnly = True
          TabOrder = 0
        end
      end
      object Panel2: TPanel
        Left = 8
        Top = 81
        Width = 705
        Height = 25
        Align = alBottom
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 1
        object rbDelete: TRadioButton
          Left = 84
          Top = 5
          Width = 66
          Height = 17
          Action = actDelete
          TabOrder = 0
        end
        object rbMove: TRadioButton
          Left = 156
          Top = 5
          Width = 87
          Height = 17
          Action = actMove
          TabOrder = 1
        end
        object rbAdd: TRadioButton
          Left = 249
          Top = 5
          Width = 119
          Height = 17
          Action = actChangeProperties
          TabOrder = 2
        end
        object rbPickOut: TRadioButton
          Left = 373
          Top = 5
          Width = 73
          Height = 17
          Action = actPickUp
          TabOrder = 3
        end
        object RadioButton1: TRadioButton
          Left = 8
          Top = 5
          Width = 73
          Height = 17
          Action = actAdd
          TabOrder = 4
        end
        object rbComplete: TRadioButton
          Left = 449
          Top = 5
          Width = 82
          Height = 17
          Action = actComplete
          TabOrder = 5
        end
      end
    end
    object pnlTop: TPanel
      Left = 0
      Top = 114
      Width = 721
      Height = 94
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object lMessage: TLabel
        Left = 8
        Top = 3
        Width = 102
        Height = 13
        Caption = 'Пространство имен:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object chbxIncludeSiblings: TCheckBox
        Left = 372
        Top = 54
        Width = 337
        Height = 17
        Caption = 'Для древовидных иерархий включать вложенные объекты'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
      end
      object chbxDontRemove: TCheckBox
        Left = 372
        Top = 38
        Width = 331
        Height = 17
        Caption = 'Не удалять объекты при удалении пространства имен'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
      object chbxAlwaysOverwrite: TCheckBox
        Left = 372
        Top = 21
        Width = 233
        Height = 17
        Caption = 'Всегда перезаписывать при загрузке'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object lkupNS: TgsIBLookupComboBox
        Left = 8
        Top = 19
        Width = 305
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = Tr
        ListTable = 'at_namespace'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcNamespace'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object chbxIncludeLinked: TCheckBox
        Left = 8
        Top = 76
        Width = 665
        Height = 17
        Action = actIncludeLinked
        TabOrder = 5
      end
      object chbxDontModify: TCheckBox
        Left = 357
        Top = 5
        Width = 337
        Height = 17
        Action = actDontModify
        TabOrder = 1
      end
    end
  end
  object dsLink: TDataSource
    Left = 304
    Top = 216
  end
  object ActionList: TActionList
    Left = 400
    Top = 216
    object actOK: TAction
      Caption = '&ОК'
      OnExecute = actOKExecute
      OnUpdate = actOKUpdate
    end
    object actAddSelected: TAction
      Caption = 'Добавить выбранный объект в ПИ...'
      OnExecute = actAddSelectedExecute
      OnUpdate = actAddSelectedUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actMove: TAction
      Caption = 'Переместить'
      OnExecute = actMoveExecute
      OnUpdate = actMoveUpdate
    end
    object actIncludeLinked: TAction
      Caption = 
        'Включить связанные объекты (для объектов из других ПИ будут доба' +
        'влены ссылки)'
      OnExecute = actIncludeLinkedExecute
    end
    object actAdd: TAction
      Caption = 'Добавить'
      OnUpdate = actAddUpdate
    end
    object actChangeProperties: TAction
      Caption = 'Изменить признаки'
    end
    object actPickUp: TAction
      Caption = 'Выделить'
    end
    object actComplete: TAction
      Caption = 'Дополнить'
    end
    object actDontModify: TAction
      Caption = 'Не изменять признаки существующих в ПИ записей'
    end
  end
  object Tr: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 184
    Top = 216
  end
  object pm: TPopupMenu
    Left = 136
    Top = 320
    object N1: TMenuItem
      Action = actAddSelected
    end
  end
end
