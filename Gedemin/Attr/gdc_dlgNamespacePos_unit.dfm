inherited gdc_dlgNamespacePos: Tgdc_dlgNamespacePos
  Left = 397
  Top = 433
  Caption = 'Свойства'
  ClientHeight = 408
  ClientWidth = 522
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 380
  end
  inherited btnNew: TButton
    Top = 380
  end
  inherited btnHelp: TButton
    Top = 380
  end
  inherited btnOK: TButton
    Left = 370
    Top = 378
  end
  inherited btnCancel: TButton
    Left = 442
    Top = 378
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
      Left = 8
      Top = 24
      Width = 313
      Height = 17
      DataField = 'objectname'
      DataSource = dsgdcBase
    end
    object dbchbxalwaysoverwrite: TDBCheckBox
      Left = 8
      Top = 42
      Width = 217
      Height = 17
      Caption = 'Всегда перезаписывать при загрузке'
      DataField = 'alwaysoverwrite'
      DataSource = dsgdcBase
      TabOrder = 0
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object dbchbxdontremove: TDBCheckBox
      Left = 8
      Top = 66
      Width = 257
      Height = 17
      Caption = 'Не удалять при удалении пространства имен'
      DataField = 'dontremove'
      DataSource = dsgdcBase
      TabOrder = 1
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object dbchbxincludesiblings: TDBCheckBox
      Left = 8
      Top = 90
      Width = 329
      Height = 17
      Caption = 'Для древовидных иерархий включать вложенные объекты'
      DataField = 'includesiblings'
      DataSource = dsgdcBase
      TabOrder = 2
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
  end
  object gsIBGrid1: TgsIBGrid [6]
    Left = 8
    Top = 120
    Width = 505
    Height = 233
    DataSource = dsNSDependent
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
    Left = 408
    Top = 272
  end
end
