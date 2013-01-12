object dlgToNamespace: TdlgToNamespace
  Left = 492
  Top = 329
  Width = 554
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
    Left = 212
    Top = 147
    Width = 123
    Height = 13
    Caption = 'Ограничить количество:'
  end
  object lMessage: TLabel
    Left = 8
    Top = 8
    Width = 433
    Height = 33
    AutoSize = False
    Caption = 'Выберите пространство имен:'
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
  object Button1: TButton
    Left = 8
    Top = 144
    Width = 121
    Height = 25
    Action = actShowLink
    TabOrder = 1
  end
  object dbgrListLink: TgsDBGrid
    Left = 8
    Top = 180
    Width = 529
    Height = 188
    DataSource = dsMain
    ReadOnly = True
    TabOrder = 2
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
    Left = 365
    Top = 143
    Width = 73
    Height = 21
    TabOrder = 3
  end
  object cbAlwaysOverwrite: TCheckBox
    Left = 8
    Top = 75
    Width = 97
    Height = 17
    Caption = 'AlwaysOverwrite'
    TabOrder = 4
  end
  object cbDontRemove: TCheckBox
    Left = 8
    Top = 94
    Width = 97
    Height = 17
    Caption = 'DontRemove'
    TabOrder = 5
  end
  object btnOK: TBitBtn
    Left = 456
    Top = 8
    Width = 81
    Height = 25
    Action = actOK
    Caption = '&ОК'
    TabOrder = 6
  end
  object cbIncludeSiblings: TCheckBox
    Left = 8
    Top = 112
    Width = 97
    Height = 17
    Caption = 'IncludeSiblings'
    TabOrder = 7
  end
  object btnCancel: TBitBtn
    Left = 456
    Top = 40
    Width = 81
    Height = 25
    Action = actCancel
    Caption = '&Отмена'
    TabOrder = 8
  end
  object cdsLink: TClientDataSet
    Aggregates = <>
    Params = <>
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
