inherited gdc_dlgNamespacePos: Tgdc_dlgNamespacePos
  Left = 397
  Top = 433
  Caption = 'Свойства'
  ClientHeight = 388
  ClientWidth = 522
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 8
    Top = 360
  end
  inherited btnNew: TButton
    Left = 80
    Top = 360
  end
  inherited btnHelp: TButton
    Left = 152
    Top = 360
  end
  inherited btnOK: TButton
    Left = 372
    Top = 358
  end
  inherited btnCancel: TButton
    Left = 444
    Top = 358
  end
  object Panel1: TPanel [5]
    Left = 0
    Top = 0
    Width = 522
    Height = 113
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 5
    object lName: TLabel
      Left = 8
      Top = 10
      Width = 77
      Height = 13
      Caption = 'Наименование:'
    end
    object dbtxtName: TDBText
      Left = 117
      Top = 10
      Width = 53
      Height = 13
      AutoSize = True
      DataField = 'objectname'
      DataSource = dsgdcBase
    end
    object Label1: TLabel
      Left = 8
      Top = 32
      Width = 102
      Height = 13
      Caption = 'Пространство имен:'
    end
    object dbchbxalwaysoverwrite: TDBCheckBox
      Left = 8
      Top = 56
      Width = 217
      Height = 17
      Caption = 'Всегда перезаписывать при загрузке'
      DataField = 'alwaysoverwrite'
      DataSource = dsgdcBase
      TabOrder = 1
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object dbchbxdontremove: TDBCheckBox
      Left = 8
      Top = 75
      Width = 257
      Height = 17
      Caption = 'Не удалять при удалении пространства имен'
      DataField = 'dontremove'
      DataSource = dsgdcBase
      TabOrder = 2
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object dbchbxincludesiblings: TDBCheckBox
      Left = 8
      Top = 93
      Width = 329
      Height = 17
      Caption = 'Для древовидных иерархий включать вложенные объекты'
      DataField = 'includesiblings'
      DataSource = dsgdcBase
      TabOrder = 3
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object iblkupNamespace: TgsIBLookupComboBox
      Left = 115
      Top = 28
      Width = 238
      Height = 21
      HelpContext = 1
      Transaction = ibtrCommon
      DataSource = dsgdcBase
      DataField = 'NAMESPACEKEY'
      ListTable = 'at_namespace'
      ListField = 'name'
      KeyField = 'id'
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object gsIBGrid1: TgsIBGrid [6]
    Left = 8
    Top = 114
    Width = 505
    Height = 239
    DataSource = dsNSDependent
    Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 6
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
  end
  inherited alBase: TActionList
    Left = 454
    Top = 7
  end
  inherited dsgdcBase: TDataSource
    Left = 360
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 392
    Top = 8
  end
  inherited ibtrCommon: TIBTransaction
    Left = 424
    Top = 8
  end
  object gdcNSDependent: TgdcNamespaceObject
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'headobjectkey'
    SubSet = 'ByHeadObject'
    Left = 376
    Top = 272
  end
  object dsNSDependent: TDataSource
    DataSet = gdcNSDependent
    Left = 408
    Top = 272
  end
end
