object dlgColumnExpand: TdlgColumnExpand
  Left = 272
  Top = 248
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Дополнительное отображение'
  ClientHeight = 152
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 112
    Width = 320
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 59
      Top = 7
      Width = 75
      Height = 24
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
    object Button1: TButton
      Left = 148
      Top = 7
      Width = 75
      Height = 24
      Cancel = True
      Caption = 'Отменить'
      ModalResult = 2
      TabOrder = 1
    end
    object btnHelp: TButton
      Left = 236
      Top = 7
      Width = 75
      Height = 24
      Caption = 'Помощь'
      TabOrder = 2
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 112
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object Bevel1: TBevel
      Left = 10
      Top = 10
      Width = 303
      Height = 95
      Shape = bsFrame
    end
    object Label1: TLabel
      Left = 20
      Top = 20
      Width = 55
      Height = 13
      Caption = 'В колонке:'
    end
    object lblColumn: TLabel
      Left = 138
      Top = 20
      Width = 55
      Height = 13
      Caption = 'lblColumn'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold, fsUnderline]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 20
      Top = 46
      Width = 113
      Height = 13
      Caption = 'Отображать колонку:'
    end
    object cbColumn: TComboBox
      Left = 138
      Top = 42
      Width = 161
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
    end
    object cbLineCount: TCheckBox
      Left = 20
      Top = 71
      Width = 125
      Height = 17
      Caption = 'Количество строк:'
      TabOrder = 1
      OnClick = cbLineCountClick
    end
    object editColumnLineCount: TxSpinEdit
      Left = 138
      Top = 71
      Width = 61
      Height = 21
      Value = 1
      IntValue = 1
      MaxValue = 10
      MinValue = 1
      Increment = 1
      EditorEnabled = False
      SpinGap = 1
      SpinStep = 50
      DecDigits = 0
      SpinCursor = 17555
      TabOrder = 2
    end
  end
end
