object dlgFindFunction: TdlgFindFunction
  Left = 420
  Top = 257
  ActiveControl = eId
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Поиск функции'
  ClientHeight = 85
  ClientWidth = 235
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TXPBevel
    Left = 0
    Top = 0
    Width = 235
    Height = 54
    Align = alClient
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 111
    Height = 13
    Caption = 'Введите ИД функции:'
  end
  object Panel1: TPanel
    Left = 0
    Top = 54
    Width = 235
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button2: TButton
      Left = 78
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object Button1: TButton
      Left = 158
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object eId: TEdit
    Left = 8
    Top = 24
    Width = 218
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
end
