object dlgInputLineNumber: TdlgInputLineNumber
  Left = 433
  Top = 220
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Ввод номера строки'
  ClientHeight = 67
  ClientWidth = 252
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 4
    Top = 4
    Width = 245
    Height = 35
    Anchors = [akLeft, akTop, akRight, akBottom]
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 13
    Top = 14
    Width = 140
    Height = 13
    Caption = 'Введите номер строки:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnOk: TButton
    Left = 94
    Top = 44
    Width = 75
    Height = 19
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnKeyPress = btnOkKeyPress
  end
  object btnCancel: TButton
    Left = 173
    Top = 44
    Width = 75
    Height = 19
    Anchors = [akRight, akBottom]
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
    OnKeyPress = btnOkKeyPress
  end
  object edtLine: TxCalculatorEdit
    Left = 160
    Top = 11
    Width = 81
    Height = 21
    Anchors = [akTop, akRight]
    AutoSize = False
    HideSelection = False
    TabOrder = 0
    Text = '0'
    OnKeyPress = btnOkKeyPress
    DecDigits = 0
  end
end
