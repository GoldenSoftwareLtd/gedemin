object dlgChooseDB: TdlgChooseDB
  Left = 309
  Top = 202
  BorderStyle = bsDialog
  Caption = 'Список баз данных'
  ClientHeight = 224
  ClientWidth = 419
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object clbBases: TCheckListBox
    Left = 0
    Top = 0
    Width = 419
    Height = 191
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 191
    Width = 419
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 254
      Top = 7
      Width = 77
      Height = 21
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 335
      Top = 7
      Width = 77
      Height = 21
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
