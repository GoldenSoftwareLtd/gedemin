object at_dlgLoadNamespacePackages: Tat_dlgLoadNamespacePackages
  Left = 380
  Top = 58
  Width = 575
  Height = 527
  Caption = 'at_dlgLoadNamespacePackages'
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
    Top = 57
    Width = 559
    Height = 328
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lPackages: TLabel
      Left = 8
      Top = 0
      Width = 42
      Height = 13
      Caption = 'Пакеты:'
    end
    object Label3: TLabel
      Left = 290
      Top = 0
      Width = 60
      Height = 13
      Caption = 'Обнаружен:'
    end
    object mInfo: TMemo
      Left = 290
      Top = 16
      Width = 273
      Height = 236
      TabStop = False
      Color = clWhite
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object gsTreeView: TgsTreeView
      Left = 8
      Top = 16
      Width = 273
      Height = 305
      Indent = 19
      TabOrder = 1
      OnAdvancedCustomDrawItem = gsTreeViewAdvancedCustomDrawItem
      OnClick = gsTreeViewClick
      WithCheckBox = True
    end
    object cbAlwaysOverwrite: TCheckBox
      Left = 290
      Top = 276
      Width = 199
      Height = 17
      Caption = 'Всегда перезаписывать'
      TabOrder = 2
    end
    object cbDontRemove: TCheckBox
      Left = 290
      Top = 305
      Width = 159
      Height = 17
      Caption = 'Не удалять объекты'
      TabOrder = 3
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 0
    Width = 559
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lSearch: TLabel
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
    object eSearchPath: TEdit
      Left = 8
      Top = 28
      Width = 348
      Height = 21
      TabOrder = 0
    end
    object btnBrowse: TButton
      Left = 356
      Top = 28
      Width = 24
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
    object btnSearch: TButton
      Left = 394
      Top = 28
      Width = 73
      Height = 21
      Action = actSearch
      TabOrder = 2
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 385
    Width = 559
    Height = 104
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 46
      Height = 13
      Caption = 'Легенда:'
    end
    object btnInstallPackage: TButton
      Left = 402
      Top = 72
      Width = 73
      Height = 21
      Caption = 'Установить'
      ModalResult = 1
      TabOrder = 0
    end
    object btnClose: TButton
      Left = 490
      Top = 72
      Width = 73
      Height = 21
      Cancel = True
      Caption = 'Закрыть'
      ModalResult = 2
      TabOrder = 1
    end
    object Panel2: TPanel
      Left = 8
      Top = 26
      Width = 273
      Height = 66
      Enabled = False
      TabOrder = 2
      object cbLegend: TCheckListBox
        Left = 1
        Top = 1
        Width = 271
        Height = 64
        TabStop = False
        Align = alClient
        BorderStyle = bsNone
        Color = clInfoBk
        Flat = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemHeight = 16
        Items.Strings = (
          'Пакет настроек не установлен'
          'Новая версия пакета настроек'
          'Версии пакетов совпадают'
          'Версия пакета более старая')
        ParentFont = False
        Style = lbOwnerDrawFixed
        TabOrder = 0
        OnDrawItem = cbLegendDrawItem
      end
    end
  end
  object ActionListLoad: TActionList
    Left = 144
    Top = 96
    object actSearch: TAction
      Caption = 'Искать'
      OnExecute = actSearchExecute
      OnUpdate = actSearchUpdate
    end
    object actInstallPackage: TAction
      Caption = 'Установить'
    end
  end
end
