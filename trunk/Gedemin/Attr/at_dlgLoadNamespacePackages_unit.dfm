object at_dlgLoadNamespacePackages: Tat_dlgLoadNamespacePackages
  Left = 373
  Top = 131
  Width = 670
  Height = 584
  Caption = 'Загрузка пространств имен'
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
  object pnlTree: TPanel
    Left = 0
    Top = 45
    Width = 654
    Height = 326
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object gsTreeView: TgsTreeView
      Left = 4
      Top = 4
      Width = 646
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
    Width = 654
    Height = 45
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lSearch: TLabel
      Left = 5
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
      Left = 5
      Top = 31
      Width = 102
      Height = 13
      Caption = 'Пространства имен:'
    end
    object eSearchPath: TEdit
      Left = 48
      Top = 8
      Width = 348
      Height = 21
      TabOrder = 0
    end
    object btnSearch: TButton
      Left = 398
      Top = 7
      Width = 73
      Height = 21
      Action = actSearch
      TabOrder = 1
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 371
    Width = 654
    Height = 175
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 2
    object mInfo: TMemo
      Left = 4
      Top = 4
      Width = 415
      Height = 167
      TabStop = False
      Align = alClient
      Color = clWhite
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object pnlBottomRight: TPanel
      Left = 419
      Top = 4
      Width = 231
      Height = 167
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object btnInstallPackage: TButton
        Left = 60
        Top = 144
        Width = 81
        Height = 21
        Caption = 'ОК'
        ModalResult = 1
        TabOrder = 3
      end
      object btnClose: TButton
        Left = 148
        Top = 144
        Width = 81
        Height = 21
        Cancel = True
        Caption = 'Закрыть'
        ModalResult = 2
        TabOrder = 4
      end
      object cbAlwaysOverwrite: TCheckBox
        Left = 17
        Top = 93
        Width = 199
        Height = 17
        Caption = 'Всегда перезаписывать'
        TabOrder = 1
      end
      object cbDontRemove: TCheckBox
        Left = 17
        Top = 109
        Width = 159
        Height = 17
        Caption = 'Не удалять объекты'
        TabOrder = 2
      end
      object GroupBox1: TGroupBox
        Left = 7
        Top = 0
        Width = 224
        Height = 89
        Caption = ' Легенда '
        TabOrder = 0
        object lblLegendNotInstalled: TLabel
          Left = 11
          Top = 16
          Width = 125
          Height = 13
          Caption = 'Пакет не установлен'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblLegendNewer: TLabel
          Left = 11
          Top = 32
          Width = 175
          Height = 13
          Caption = 'В файле новая версия пакета '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblLegendEqual: TLabel
          Left = 11
          Top = 48
          Width = 95
          Height = 13
          Caption = 'Версии совпадают'
        end
        object lblLegendOlder: TLabel
          Left = 11
          Top = 64
          Width = 117
          Height = 13
          Caption = 'В файле старая версия'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
    end
  end
  object ActionListLoad: TActionList
    Left = 144
    Top = 96
    object actSearch: TAction
      Caption = 'Искать...'
      OnExecute = actSearchExecute
    end
    object actInstallPackage: TAction
      Caption = 'Установить'
    end
  end
end
