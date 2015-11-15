object dlgToNamespace: TdlgToNamespace
  Left = 707
  Top = 219
  Width = 737
  Height = 542
  Caption = 'Добавление объекта в пространство имен'
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
    Top = 112
    Width = 721
    Height = 391
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 1
    object dbgrListLink: TgsDBGrid
      Left = 8
      Top = 8
      Width = 705
      Height = 347
      Align = alClient
      DataSource = dsLink
      Options = [dgTitles, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      ParentFont = False
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
    object pnlButtons: TPanel
      Left = 8
      Top = 355
      Width = 705
      Height = 28
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
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
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 721
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lMessage: TLabel
      Left = 8
      Top = 8
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
    object Label2: TLabel
      Left = 8
      Top = 51
      Width = 43
      Height = 13
      Caption = 'Объект:'
    end
    object chbxIncludeSiblings: TCheckBox
      Left = 344
      Top = 55
      Width = 337
      Height = 17
      Caption = 'Для древовидных иерархий включать вложенные объекты'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
    end
    object chbxDontRemove: TCheckBox
      Left = 344
      Top = 39
      Width = 331
      Height = 17
      Caption = 'Не удалять объекты при удалении пространства имен'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
    end
    object chbxAlwaysOverwrite: TCheckBox
      Left = 344
      Top = 22
      Width = 233
      Height = 17
      Caption = 'Всегда перезаписывать при загрузке'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object lkupNS: TgsIBLookupComboBox
      Left = 8
      Top = 24
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
    object edObjectName: TEdit
      Left = 8
      Top = 66
      Width = 305
      Height = 21
      TabStop = False
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 2
    end
    object btnClear: TButton
      Left = 313
      Top = 23
      Width = 24
      Height = 21
      Action = actClear
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object chbxIncludeLinked: TCheckBox
      Left = 8
      Top = 95
      Width = 665
      Height = 17
      Caption = 
        'Включить связанные объекты (для объектов из других ПИ будут доба' +
        'влены ссылки)'
      TabOrder = 6
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
    object actClear: TAction
      Caption = 'X'
      Hint = 'Удалить объект из пространства имен'
      OnExecute = actClearExecute
      OnUpdate = actClearUpdate
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
end
