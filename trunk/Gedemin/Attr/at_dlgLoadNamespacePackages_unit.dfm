object at_dlgLoadNamespacePackages: Tat_dlgLoadNamespacePackages
  Left = 369
  Top = 90
  Width = 650
  Height = 584
  Caption = 'at_dlgLoadNamespacePackages'
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
  object Label1: TLabel
    Left = 8
    Top = 10
    Width = 82
    Height = 13
    Caption = 'Искать в папке:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 45
    Width = 634
    Height = 326
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object gsTreeView: TgsTreeView
      Left = 4
      Top = 4
      Width = 626
      Height = 318
      Align = alClient
      Indent = 19
      TabOrder = 0
      OnAdvancedCustomDrawItem = gsTreeViewAdvancedCustomDrawItem
      OnClick = gsTreeViewClick
      WithCheckBox = True
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 634
    Height = 45
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lSearch: TLabel
      Left = 9
      Top = 12
      Width = 35
      Height = 13
      Caption = 'Папка:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lPackages: TLabel
      Left = 9
      Top = 34
      Width = 43
      Height = 13
      Caption = 'Пакеты:'
    end
    object eSearchPath: TEdit
      Left = 48
      Top = 8
      Width = 348
      Height = 21
      TabOrder = 0
    end
    object btnSearch: TButton
      Left = 399
      Top = 7
      Width = 73
      Height = 21
      Action = actSearch
      TabOrder = 1
    end
    object cbInternal: TCheckBox
      Left = 399
      Top = 31
      Width = 241
      Height = 17
      Caption = 'Показывать пакеты пространств имен'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 371
    Width = 634
    Height = 175
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 2
    object mInfo: TMemo
      Left = 4
      Top = 4
      Width = 268
      Height = 167
      TabStop = False
      Align = alClient
      Color = clWhite
      ReadOnly = True
      TabOrder = 0
    end
    object pnlBottomRight: TPanel
      Left = 272
      Top = 4
      Width = 358
      Height = 167
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object btnInstallPackage: TButton
        Left = 173
        Top = 144
        Width = 81
        Height = 21
        Caption = 'Установить'
        ModalResult = 1
        TabOrder = 0
      end
      object btnClose: TButton
        Left = 261
        Top = 144
        Width = 81
        Height = 21
        Cancel = True
        Caption = 'Закрыть'
        ModalResult = 2
        TabOrder = 1
      end
      object cbAlwaysOverwrite: TCheckBox
        Left = 23
        Top = 100
        Width = 199
        Height = 17
        Caption = 'Всегда перезаписывать'
        TabOrder = 2
      end
      object cbDontRemove: TCheckBox
        Left = 23
        Top = 116
        Width = 159
        Height = 17
        Caption = 'Не удалять объекты'
        TabOrder = 3
      end
      object Panel2: TPanel
        Left = 5
        Top = 1
        Width = 273
        Height = 92
        Enabled = False
        TabOrder = 4
        object lblLegendNotInstalled: TLabel
          Left = 32
          Top = 24
          Width = 108
          Height = 13
          Caption = 'Пакет не установлен'
        end
        object lblLegendNewer: TLabel
          Left = 32
          Top = 40
          Width = 154
          Height = 13
          Caption = 'В файле новая версия пакета '
        end
        object lblLegendEqual: TLabel
          Left = 32
          Top = 56
          Width = 95
          Height = 13
          Caption = 'Версии совпадают'
        end
        object Label2: TLabel
          Left = 8
          Top = 8
          Width = 47
          Height = 13
          Caption = 'Легенда:'
        end
        object lblLegendOlder: TLabel
          Left = 32
          Top = 72
          Width = 117
          Height = 13
          Caption = 'В файле старая версия'
        end
      end
    end
  end
  object ActionListLoad: TActionList
    Left = 144
    Top = 96
    object actSearch: TAction
      Caption = 'Искать'
      OnExecute = actSearchExecute
    end
    object actInstallPackage: TAction
      Caption = 'Установить'
    end
  end
end
