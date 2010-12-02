object dlgBreakPointProperty: TdlgBreakPointProperty
  Left = 676
  Top = 150
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Свойства точки останова'
  ClientHeight = 165
  ClientWidth = 279
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 279
    Height = 134
    Align = alClient
    Shape = bsFrame
  end
  object lbName: TLabel
    Left = 8
    Top = 11
    Width = 49
    Height = 13
    Caption = 'Функция:'
  end
  object lbLine: TLabel
    Left = 8
    Top = 43
    Width = 39
    Height = 13
    Caption = 'Строка:'
  end
  object lbCondition: TLabel
    Left = 8
    Top = 75
    Width = 47
    Height = 13
    Caption = 'Условие:'
  end
  object lbPassCount: TLabel
    Left = 8
    Top = 107
    Width = 85
    Height = 13
    Caption = 'Число проходов:'
  end
  object Panel1: TPanel
    Left = 0
    Top = 134
    Width = 279
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object btCancel: TButton
      Left = 204
      Top = 6
      Width = 75
      Height = 25
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 1
    end
    object btOk: TButton
      Left = 121
      Top = 6
      Width = 75
      Height = 25
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 0
    end
  end
  object cbName: TComboBox
    Left = 96
    Top = 8
    Width = 177
    Height = 21
    Enabled = False
    ItemHeight = 13
    TabOrder = 0
    Text = 'cbName'
  end
  object cbLine: TComboBox
    Left = 96
    Top = 40
    Width = 177
    Height = 21
    Enabled = False
    ItemHeight = 13
    TabOrder = 1
    Text = 'cbLine'
    OnExit = cbPassCountExit
  end
  object cbCondition: TComboBox
    Left = 96
    Top = 72
    Width = 177
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    Text = 'cbCondition'
  end
  object cbPassCount: TComboBox
    Left = 96
    Top = 104
    Width = 177
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    Text = 'cbPassCount'
    OnExit = cbPassCountExit
  end
  object ActionList: TActionList
    Top = 136
    object actOk: TAction
      Caption = 'Применить'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
  end
end
