object frmAddMacroCall: TfrmAddMacroCall
  Left = 231
  Top = 117
  Width = 634
  Height = 366
  Caption = 'frmAddMacroCall'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object gdSeachParams: TGroupBox
    Left = 0
    Top = 2
    Width = 281
    Height = 199
    Caption = 'Параметры подстановки'
    TabOrder = 0
    object lblBaseClass: TLabel
      Left = 8
      Top = 66
      Width = 78
      Height = 13
      Caption = 'Базовый класс'
    end
    object lblPath: TLabel
      Left = 8
      Top = 40
      Width = 24
      Height = 13
      Caption = 'Путь'
    end
    object lblPar: TLabel
      Left = 8
      Top = 122
      Width = 59
      Height = 13
      Caption = 'Параметры'
    end
    object lblBegin: TLabel
      Left = 8
      Top = 146
      Width = 37
      Height = 13
      Caption = 'Начало'
    end
    object lblEnd: TLabel
      Left = 8
      Top = 170
      Width = 31
      Height = 13
      Caption = 'Конец'
    end
    object edBaseClass: TEdit
      Left = 92
      Top = 58
      Width = 183
      Height = 22
      AutoSize = False
      TabOrder = 1
      Text = 'Tgdc'
    end
    object edPath: TEdit
      Left = 92
      Top = 32
      Width = 183
      Height = 21
      AutoSize = False
      TabOrder = 0
      OnDblClick = edPathDblClick
    end
    object edPar: TEdit
      Left = 111
      Top = 114
      Width = 164
      Height = 21
      Hint = 'dgdfg'
      AutoSize = False
      TabOrder = 2
      Text = 'Inh_'
    end
    object edBegin: TEdit
      Left = 111
      Top = 138
      Width = 164
      Height = 21
      AutoSize = False
      TabOrder = 3
      Text = 'Inh_'
    end
    object edEnd: TEdit
      Left = 111
      Top = 162
      Width = 164
      Height = 21
      AutoSize = False
      TabOrder = 4
      Text = 'Inh_'
    end
    object cbParam: TCheckBox
      Left = 91
      Top = 115
      Width = 17
      Height = 17
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 5
    end
    object cbBegin: TCheckBox
      Left = 91
      Top = 139
      Width = 17
      Height = 17
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 6
    end
    object cbEnd: TCheckBox
      Left = 91
      Top = 163
      Width = 17
      Height = 17
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 7
    end
  end
  object pnlControlButtons: TPanel
    Left = 0
    Top = 232
    Width = 281
    Height = 107
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object btnSearchClass: TButton
      Left = 8
      Top = 8
      Width = 265
      Height = 25
      Caption = 'Создать иерархию классов'
      TabOrder = 0
      OnClick = btnSearchClassClick
    end
    object btnAddMacroCall: TButton
      Left = 8
      Top = 40
      Width = 265
      Height = 25
      Caption = 'Добавить вызовы методов'
      TabOrder = 1
      OnClick = btnAddMacroCallClick
    end
    object btnDelMacroCall: TButton
      Left = 8
      Top = 72
      Width = 265
      Height = 25
      Caption = 'Удалить вызовы методов'
      TabOrder = 2
      OnClick = btnDelMacroCallClick
    end
  end
  object PageControl1: TPageControl
    Left = 288
    Top = 7
    Width = 337
    Height = 331
    ActivePage = tsMethods
    TabOrder = 2
    object tsHierarhy: TTabSheet
      Caption = 'Иерархия'
      object lbClasses: TListBox
        Left = 0
        Top = 0
        Width = 330
        Height = 264
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        ParentShowHint = False
        PopupMenu = pmClasses
        ShowHint = True
        TabOrder = 0
        OnMouseMove = lbClassesMouseMove
      end
      object btnSaveHierarchy: TButton
        Left = 0
        Top = 274
        Width = 116
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'Сохранить иерархию'
        TabOrder = 1
        OnClick = btnSaveHierarchyClick
      end
      object edHierarchyFile: TEdit
        Left = 123
        Top = 274
        Width = 221
        Height = 25
        Anchors = [akLeft, akBottom]
        AutoSize = False
        TabOrder = 2
        Text = 'Hierarchy.txt'
      end
    end
    object tsMethods: TTabSheet
      Caption = 'Методы'
      ImageIndex = 1
      object lbMethods: TListBox
        Left = 0
        Top = 0
        Width = 329
        Height = 113
        Align = alTop
        ItemHeight = 13
        PopupMenu = ppMethods
        TabOrder = 0
      end
      object btnAddMethod: TButton
        Left = 72
        Top = 152
        Width = 75
        Height = 25
        Caption = 'Добавить'
        TabOrder = 1
        OnClick = btnAddMethodClick
      end
      object btnDelMethod: TButton
        Left = 160
        Top = 152
        Width = 75
        Height = 25
        Caption = 'Удалить'
        TabOrder = 2
        OnClick = btnDelMethodClick
      end
      object edMethod: TEdit
        Left = 0
        Top = 121
        Width = 329
        Height = 21
        PopupMenu = ppMethods
        TabOrder = 3
      end
    end
  end
  object pmClasses: TPopupMenu
    Left = 320
    Top = 64
    object DelFile: TMenuItem
      Caption = 'Удалить файл из списка'
      OnClick = DelFileClick
    end
  end
  object ppMethods: TPopupMenu
    Left = 396
    Top = 79
    object N1: TMenuItem
      Caption = 'Добавить метод'
      ShortCut = 16429
      OnClick = btnAddMethodClick
    end
    object N2: TMenuItem
      Caption = 'Удалить метод'
      ShortCut = 16430
      OnClick = btnDelMethodClick
    end
  end
end
