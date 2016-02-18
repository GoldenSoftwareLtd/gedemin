object dlgReducePayment: TdlgReducePayment
  Left = 348
  Top = 195
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Сводное поручение'
  ClientHeight = 100
  ClientWidth = 199
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 5
    Top = 5
    Width = 191
    Height = 56
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = -6
    Top = 65
    Width = 205
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object Label1: TLabel
    Left = 15
    Top = 15
    Width = 92
    Height = 13
    Caption = 'Номер поручения:'
  end
  object Label2: TLabel
    Left = 15
    Top = 39
    Width = 84
    Height = 13
    Caption = 'Дата поручения:'
  end
  object btnOk: TButton
    Left = 61
    Top = 73
    Width = 76
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'ОK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object edNumber: TEdit
    Left = 125
    Top = 10
    Width = 66
    Height = 21
    TabOrder = 0
    Text = '1'
  end
  object xdeDate: TxDateEdit
    Left = 125
    Top = 35
    Width = 66
    Height = 21
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 1
    Text = '30.09.2002'
  end
end
