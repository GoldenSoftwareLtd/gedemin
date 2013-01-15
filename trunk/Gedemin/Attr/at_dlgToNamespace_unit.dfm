object dlgToNamespace: TdlgToNamespace
  Left = 492
  Top = 329
  Width = 553
  Height = 405
  Caption = 'Добавление объекта в пространство имен'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lLimit: TLabel
    Left = 163
    Top = 147
    Width = 127
    Height = 13
    Caption = 'Ограничить количество:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lMessage: TLabel
    Left = 8
    Top = 8
    Width = 433
    Height = 33
    AutoSize = False
    Caption = 'Выберите пространство имен:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object lkup: TgsIBLookupComboBox
    Left = 8
    Top = 45
    Width = 433
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    ListTable = 'at_namespace'
    ListField = 'name'
    KeyField = 'ID'
    gdClassName = 'TgdcNamespace'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object bShowLink: TButton
    Left = 8
    Top = 144
    Width = 121
    Height = 25
    Action = actShowLink
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object dbgrListLink: TgsDBGrid
    Left = 8
    Top = 176
    Width = 529
    Height = 202
    DataSource = dsMain
    ParentFont = False
    ReadOnly = True
    TabOrder = 2
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
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.FieldName = 'id'
    CheckBox.Visible = True
    CheckBox.FirstColumn = True
    MinColWidth = 40
  end
  object eLimit: TEdit
    Left = 307
    Top = 144
    Width = 73
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object cbAlwaysOverwrite: TCheckBox
    Left = 8
    Top = 75
    Width = 113
    Height = 17
    Caption = 'AlwaysOverwrite'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object cbDontRemove: TCheckBox
    Left = 8
    Top = 94
    Width = 97
    Height = 17
    Caption = 'DontRemove'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object btnOK: TBitBtn
    Left = 456
    Top = 8
    Width = 81
    Height = 25
    Action = actOK
    Caption = '&ОК'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object cbIncludeSiblings: TCheckBox
    Left = 8
    Top = 112
    Width = 97
    Height = 17
    Caption = 'IncludeSiblings'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
  end
  object btnCancel: TBitBtn
    Left = 456
    Top = 40
    Width = 81
    Height = 25
    Action = actCancel
    Caption = '&Отмена'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
  end
  object btnDelete: TBitBtn
    Left = 360
    Top = 76
    Width = 81
    Height = 25
    Action = actClear
    Caption = 'Очистить'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
  end
  object cdsLink: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 216
    Top = 8
  end
  object dsMain: TDataSource
    DataSet = cdsLink
    Left = 184
    Top = 8
  end
  object ActionList: TActionList
    Left = 280
    Top = 8
    object actShowLink: TAction
      Caption = 'Показать связи'
      OnExecute = actShowLinkExecute
    end
    object actOK: TAction
      Caption = '&ОК'
      OnExecute = actOKExecute
    end
    object actCancel: TAction
      Caption = '&Отмена'
      OnExecute = actCancelExecute
    end
    object actClear: TAction
      Caption = 'Очистить'
      OnExecute = actClearExecute
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 248
    Top = 8
  end
end
