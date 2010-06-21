object at_dlgLoadPackages: Tat_dlgLoadPackages
  Left = 292
  Top = 197
  HelpContext = 128
  BorderStyle = bsDialog
  Caption = 'Установка пакетов настроек'
  ClientHeight = 361
  ClientWidth = 550
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 550
    Height = 361
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 36
      Width = 43
      Height = 13
      Caption = 'Пакеты:'
    end
    object Label2: TLabel
      Left = 8
      Top = 10
      Width = 82
      Height = 13
      Caption = 'Искать в папке:'
    end
    object Label3: TLabel
      Left = 272
      Top = 36
      Width = 62
      Height = 13
      Caption = 'Обнаружен:'
    end
    object Label4: TLabel
      Left = 272
      Top = 180
      Width = 64
      Height = 13
      Caption = 'Установлен:'
    end
    object Label5: TLabel
      Left = 8
      Top = 271
      Width = 47
      Height = 13
      Caption = 'Легенда:'
    end
    object btnSearch: TButton
      Left = 471
      Top = 8
      Width = 73
      Height = 21
      Action = actSearchGSF
      TabOrder = 2
    end
    object clbPackages: TCheckListBox
      Left = 8
      Top = 52
      Width = 257
      Height = 217
      OnClickCheck = clbPackagesClickCheck
      Flat = False
      ItemHeight = 16
      PopupMenu = pmSelect
      Sorted = True
      Style = lbOwnerDrawFixed
      TabOrder = 3
      OnClick = clbPackagesClick
      OnDrawItem = clbPackagesDrawItem
    end
    object pEmpty: TPanel
      Left = 8
      Top = 52
      Width = 257
      Height = 217
      BevelOuter = bvLowered
      TabOrder = 9
      object lInfo: TLabel
        Left = 2
        Top = 8
        Width = 243
        Height = 13
        AutoSize = False
        Caption = 'Нажмите '#39'Искать'#39' для поиска пакетов настроек'
      end
    end
    object eSearchPath: TEdit
      Left = 96
      Top = 8
      Width = 348
      Height = 21
      TabOrder = 0
      Text = 'eSearchPath'
    end
    object btnBrowse: TButton
      Left = 443
      Top = 8
      Width = 24
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
    object btnClose: TButton
      Left = 471
      Top = 332
      Width = 73
      Height = 21
      Cancel = True
      Caption = 'Закрыть'
      ModalResult = 1
      TabOrder = 5
    end
    object mExistSettInfo: TMemo
      Left = 272
      Top = 196
      Width = 273
      Height = 73
      TabStop = False
      Color = clBtnFace
      ScrollBars = ssVertical
      TabOrder = 10
    end
    object btnInstallPackage: TButton
      Left = 393
      Top = 332
      Width = 73
      Height = 21
      Action = actInstallPackage
      TabOrder = 4
    end
    object mGSFInfo: TMemo
      Left = 272
      Top = 52
      Width = 273
      Height = 125
      TabStop = False
      Color = clBtnFace
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 11
    end
    object Panel2: TPanel
      Left = 8
      Top = 287
      Width = 257
      Height = 66
      Caption = 'Panel2'
      Enabled = False
      TabOrder = 12
      object cbLegend: TCheckListBox
        Left = 1
        Top = 1
        Width = 255
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
    object cbYesToAll: TCheckBox
      Left = 272
      Top = 285
      Width = 185
      Height = 17
      Caption = 'Обновлять данные без запроса'
      Checked = True
      State = cbChecked
      TabOrder = 7
    end
    object chbxFullPackInfo: TCheckBox
      Left = 443
      Top = 35
      Width = 101
      Height = 17
      Action = actShowFullPackInfo
      TabOrder = 8
    end
    object btnHelp: TButton
      Left = 273
      Top = 332
      Width = 73
      Height = 21
      Action = actHelp
      TabOrder = 6
    end
  end
  object ActionList1: TActionList
    Images = dmImages.il16x16
    Left = 472
    Top = 72
    object actSearchGSF: TAction
      Caption = 'Искать'
      Hint = 'Поиск пакетов по указанному пути'
      ShortCut = 13
      OnExecute = actSearchGSFExecute
    end
    object actInstallPackage: TAction
      Caption = 'Установить'
      Hint = 'Установка пакета в систему'
      OnExecute = actInstallPackageExecute
      OnUpdate = actInstallPackageUpdate
    end
    object actShowFullPackInfo: TAction
      Caption = 'Дополнительно'
      OnExecute = actShowFullPackInfoExecute
      OnUpdate = actShowFullPackInfoUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
    object actSetParams: TAction
      Caption = 'Параметры...'
      OnExecute = actSetParamsExecute
    end
  end
  object pmSelect: TPopupMenu
    Images = dmImages.il16x16
    Left = 136
    Top = 104
    object choose1: TMenuItem
      Caption = 'Выделить'
      ImageIndex = 28
      object miNotInstalled: TMenuItem
        Caption = 'Неустановленные'
        OnClick = miNotInstalledClick
      end
      object miNewer: TMenuItem
        Caption = 'Новые'
        OnClick = miNewerClick
      end
      object miEqual: TMenuItem
        Caption = 'Совпадающие'
        Enabled = False
        OnClick = miEqualClick
      end
    end
    object miInvert: TMenuItem
      Caption = 'Инвертировать'
      OnClick = miInvertClick
    end
    object miClear: TMenuItem
      Caption = 'Снять выделение'
      OnClick = miClearClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miOnlyNewer: TMenuItem
      Caption = 'Устанавливать совпадающие'
      OnClick = miOnlyNewerClick
    end
  end
end
