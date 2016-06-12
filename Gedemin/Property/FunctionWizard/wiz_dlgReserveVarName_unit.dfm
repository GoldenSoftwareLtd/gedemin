object dlgReserveVarName: TdlgReserveVarName
  Left = 344
  Top = 204
  Width = 293
  Height = 83
  BorderWidth = 5
  Caption = 'Имя переменной'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 4
    Width = 86
    Height = 13
    Caption = 'Имя переменной:'
  end
  object Panel1: TPanel
    Left = 0
    Top = 21
    Width = 275
    Height = 21
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 200
      Top = 0
      Width = 75
      Height = 21
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
    object Button2: TButton
      Left = 120
      Top = 0
      Width = 75
      Height = 21
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
  end
  object Edit1: TEdit
    Left = 96
    Top = 0
    Width = 177
    Height = 21
    TabOrder = 0
  end
end
