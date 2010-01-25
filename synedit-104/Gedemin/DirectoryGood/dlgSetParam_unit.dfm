object dlgSetParam: TdlgSetParam
  Left = 292
  Top = 169
  ActiveControl = edName
  BorderStyle = bsDialog
  Caption = 'Параметры'
  ClientHeight = 101
  ClientWidth = 277
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 76
    Height = 13
    Caption = 'Наименование'
  end
  object lblTNVD: TLabel
    Left = 8
    Top = 34
    Width = 50
    Height = 13
    Caption = 'Описание'
    WordWrap = True
  end
  object btnOk: TButton
    Left = 114
    Top = 64
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 196
    Top = 64
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
  end
  object edName: TEdit
    Left = 112
    Top = 8
    Width = 157
    Height = 21
    TabOrder = 0
  end
  object edDescription: TEdit
    Left = 112
    Top = 33
    Width = 157
    Height = 21
    TabOrder = 1
  end
end
