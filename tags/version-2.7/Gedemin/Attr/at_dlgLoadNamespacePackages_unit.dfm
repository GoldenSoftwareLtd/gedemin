object at_dlgLoadNamespacePackages: Tat_dlgLoadNamespacePackages
  Left = 551
  Top = 244
  Width = 671
  Height = 501
  Caption = 'Зависимости файлов пространств имен'
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
    Width = 655
    Height = 311
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object dbtvFiles: TgsDBTreeView
      Left = 4
      Top = 4
      Width = 647
      Height = 303
      DataSource = ds
      KeyField = 'ID'
      ParentField = 'PARENT'
      DisplayField = 'NAME'
      Align = alClient
      Indent = 19
      TabOrder = 0
      MainFolderHead = True
      MainFolder = False
      MainFolderCaption = 'Все'
      WithCheckBox = False
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 655
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
      Top = 32
      Width = 202
      Height = 13
      Caption = 'Дерево зависимости пространств имен:'
    end
    object eSearchPath: TEdit
      Left = 48
      Top = 8
      Width = 348
      Height = 21
      TabOrder = 0
    end
    object btnSearch: TButton
      Left = 427
      Top = 7
      Width = 73
      Height = 21
      Action = actSearch
      TabOrder = 2
    end
    object btnSelectFolder: TButton
      Left = 396
      Top = 7
      Width = 25
      Height = 21
      Action = actSelectFolder
      TabOrder = 1
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 356
    Width = 655
    Height = 107
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 2
    object mInfo: TMemo
      Left = 4
      Top = 4
      Width = 647
      Height = 70
      TabStop = False
      Align = alTop
      Color = clInfoBk
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object Panel1: TPanel
      Left = 466
      Top = 74
      Width = 185
      Height = 29
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object btnClose: TButton
        Left = 102
        Top = 5
        Width = 81
        Height = 21
        Caption = 'Закрыть'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
    end
  end
  object ActionListLoad: TActionList
    Left = 144
    Top = 96
    object actSearch: TAction
      Caption = 'Искать...'
      OnExecute = actSearchExecute
      OnUpdate = actSearchUpdate
    end
    object actSelectFolder: TAction
      Caption = '...'
      OnExecute = actSelectFolderExecute
    end
  end
  object ds: TDataSource
    Left = 152
    Top = 245
  end
end
