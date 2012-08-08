inherited gdc_dlgExplorer: Tgdc_dlgExplorer
  Left = 390
  Top = 275
  HelpContext = 110
  ActiveControl = dbeName
  Caption = 'Исследователь'
  ClientHeight = 353
  ClientWidth = 372
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 37
    Width = 77
    Height = 13
    Caption = 'Наименование:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel [1]
    Left = 8
    Top = 61
    Width = 83
    Height = 13
    Caption = 'Входит в папку:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel [2]
    Left = 106
    Top = 120
    Width = 256
    Height = 2
    Shape = bsTopLine
  end
  object Bevel2: TBevel [3]
    Left = 106
    Top = 144
    Width = 256
    Height = 2
    Shape = bsTopLine
  end
  object Bevel3: TBevel [4]
    Left = 106
    Top = 208
    Width = 256
    Height = 2
    Shape = bsTopLine
  end
  object Label3: TLabel [5]
    Left = 32
    Top = 156
    Width = 70
    Height = 13
    Caption = 'Бизнес-класс:'
  end
  object Label4: TLabel [6]
    Left = 32
    Top = 180
    Width = 42
    Height = 13
    Caption = 'Подтип:'
  end
  object Label5: TLabel [7]
    Left = 32
    Top = 220
    Width = 89
    Height = 13
    Caption = 'Скрипт-функция:'
  end
  object Label6: TLabel [8]
    Left = 8
    Top = 12
    Width = 86
    Height = 13
    Caption = 'Идентификатор:'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object DBText1: TDBText [9]
    Left = 125
    Top = 12
    Width = 41
    Height = 13
    AutoSize = True
    DataField = 'ID'
    DataSource = dsgdcBase
  end
  object Label7: TLabel [10]
    Left = 8
    Top = 86
    Width = 76
    Height = 13
    Caption = 'Пиктограммка:'
  end
  object Bevel4: TBevel [11]
    Left = 106
    Top = 248
    Width = 256
    Height = 2
    Shape = bsTopLine
  end
  object Bevel5: TBevel [12]
    Left = 106
    Top = 287
    Width = 256
    Height = 2
    Shape = bsTopLine
  end
  inherited btnAccess: TButton
    Left = 6
    Top = 327
    TabOrder = 11
  end
  inherited btnNew: TButton
    Left = 78
    Top = 327
    TabOrder = 12
  end
  inherited btnHelp: TButton
    Left = 150
    Top = 327
    TabOrder = 13
  end
  inherited btnOK: TButton
    Left = 226
    Top = 327
    TabOrder = 9
  end
  inherited btnCancel: TButton
    Left = 297
    Top = 327
    TabOrder = 10
  end
  object dbeName: TDBEdit [18]
    Left = 125
    Top = 32
    Width = 241
    Height = 21
    DataField = 'name'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object ibcmbBranch: TgsIBLookupComboBox [19]
    Left = 125
    Top = 56
    Width = 241
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'parent'
    ListTable = 'GD_COMMAND'
    ListField = 'NAME'
    KeyField = 'ID'
    SortOrder = soAsc
    gdClassName = 'TgdcExplorer'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object iblkupFunction: TgsIBLookupComboBox [20]
    Left = 125
    Top = 216
    Width = 241
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    ListTable = 'GD_FUNCTION'
    ListField = 'NAME'
    KeyField = 'ID'
    SortOrder = soAsc
    Condition = '(module='#39'UNKNOWN'#39' OR module='#39'MACROS'#39') AND modulecode=1010001'
    gdClassName = 'TgdcFunction'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
  end
  object rbFolder: TRadioButton [21]
    Left = 8
    Top = 112
    Width = 65
    Height = 17
    Caption = 'Папка'
    TabOrder = 3
    OnClick = rbFolderClick
  end
  object rbClass: TRadioButton [22]
    Left = 8
    Top = 136
    Width = 89
    Height = 17
    Caption = 'Бизнес-класс'
    TabOrder = 4
    OnClick = rbFolderClick
  end
  object rbFunction: TRadioButton [23]
    Left = 8
    Top = 200
    Width = 73
    Height = 17
    Caption = 'Функция'
    TabOrder = 7
    OnClick = rbFolderClick
  end
  object cbClasses: TComboBox [24]
    Left = 125
    Top = 152
    Width = 241
    Height = 21
    Style = csDropDownList
    DropDownCount = 16
    ItemHeight = 13
    Sorted = True
    TabOrder = 5
    OnChange = cbClassesChange
  end
  object cbSubTypes: TComboBox [25]
    Left = 125
    Top = 176
    Width = 241
    Height = 21
    DropDownCount = 16
    ItemHeight = 13
    Sorted = True
    TabOrder = 6
  end
  object cbImages: TComboBox [26]
    Left = 125
    Top = 80
    Width = 52
    Height = 21
    Style = csOwnerDrawVariable
    DropDownCount = 12
    ItemHeight = 15
    TabOrder = 2
    OnDrawItem = cbImagesDrawItem
    OnMeasureItem = cbImagesMeasureItem
  end
  object rbForm: TRadioButton [27]
    Left = 8
    Top = 240
    Width = 73
    Height = 17
    Caption = 'Форма'
    TabOrder = 14
    OnClick = rbFolderClick
  end
  object edFormClass: TEdit [28]
    Left = 125
    Top = 256
    Width = 241
    Height = 21
    TabOrder = 15
  end
  object rbReport: TRadioButton [29]
    Left = 8
    Top = 278
    Width = 65
    Height = 17
    Caption = 'Отчет'
    TabOrder = 16
    OnClick = rbFolderClick
  end
  object iblkupReport: TgsIBLookupComboBox [30]
    Left = 125
    Top = 296
    Width = 241
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    ListTable = 'rp_reportlist'
    ListField = 'NAME'
    KeyField = 'ID'
    SortOrder = soAsc
    gdClassName = 'TgdcReport'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 17
  end
  inherited alBase: TActionList
    Left = 446
    Top = 167
  end
  inherited dsgdcBase: TDataSource
    Left = 432
    Top = 127
  end
  inherited pm_dlgG: TPopupMenu
    Left = 440
    Top = 88
  end
  inherited ibtrCommon: TIBTransaction
    Left = 392
    Top = 0
  end
end
