object dnmn_frmReg: Tdnmn_frmReg
  Left = 543
  Top = 292
  BorderStyle = bsDialog
  Caption = 'Код разблокировки программы'
  ClientHeight = 167
  ClientWidth = 382
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
    Left = 14
    Top = 13
    Width = 335
    Height = 13
    Caption = 'Сообщите указанное ниже название организации и контрольное '
  end
  object Label2: TLabel
    Left = 15
    Top = 30
    Width = 314
    Height = 13
    Caption = 'число по телефонам: +375-17-256 27 82, 256 27 83, 256 17 59'
  end
  object Label3: TLabel
    Left = 14
    Top = 115
    Width = 104
    Height = 13
    Caption = 'Код разблокировки:'
  end
  object edCode: TEdit
    Left = 123
    Top = 111
    Width = 150
    Height = 21
    TabOrder = 0
  end
  object Button1: TButton
    Left = 294
    Top = 135
    Width = 75
    Height = 21
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 1
  end
  object m: TMemo
    Left = 13
    Top = 56
    Width = 353
    Height = 46
    BorderStyle = bsNone
    ParentColor = True
    TabOrder = 2
  end
end
