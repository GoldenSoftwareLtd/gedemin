object gsdbGrid_dlgFind: TgsdbGrid_dlgFind
  Left = 379
  Top = 274
  BorderStyle = bsDialog
  Caption = 'Поиск'
  ClientHeight = 168
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 90
    Height = 13
    Caption = 'Искать значение:'
  end
  object Button1: TButton
    Left = 296
    Top = 24
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 4
  end
  object Button2: TButton
    Left = 296
    Top = 48
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 5
  end
  object cbFindText: TComboBox
    Left = 8
    Top = 24
    Width = 281
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 152
    Top = 56
    Width = 137
    Height = 49
    Caption = ' Направление поиска '
    TabOrder = 2
    object rbDown: TRadioButton
      Left = 10
      Top = 12
      Width = 57
      Height = 17
      Caption = 'Вниз'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbUp: TRadioButton
      Left = 10
      Top = 27
      Width = 57
      Height = 17
      Caption = 'Вверх'
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 56
    Width = 137
    Height = 49
    TabOrder = 1
    object chbxMatchCase: TCheckBox
      Left = 8
      Top = 10
      Width = 123
      Height = 17
      Caption = 'С учетом регистра'
      TabOrder = 0
    end
    object chbxWholeWord: TCheckBox
      Left = 8
      Top = 26
      Width = 123
      Height = 17
      Caption = 'Полное совпадение'
      TabOrder = 1
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 112
    Width = 281
    Height = 49
    Caption = ' Искать '
    TabOrder = 3
    object rbCurrent: TRadioButton
      Left = 10
      Top = 14
      Width = 201
      Height = 17
      Caption = 'От текущего положения курсора'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbBegin: TRadioButton
      Left = 10
      Top = 29
      Width = 113
      Height = 17
      Caption = 'С начала списка'
      TabOrder = 1
    end
  end
  object ActionList1: TActionList
    Left = 320
    Top = 88
    object actOk: TAction
      Caption = 'Ok'
      ShortCut = 114
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
end
