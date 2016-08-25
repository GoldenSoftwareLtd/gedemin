object dlgEventComent: TdlgEventComent
  Left = 282
  Top = 194
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Комментарий'
  ClientHeight = 59
  ClientWidth = 247
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
  object eComent: TEdit
    Left = 0
    Top = 0
    Width = 241
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object bCancel: TButton
    Left = 136
    Top = 29
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object bOk: TButton
    Left = 40
    Top = 29
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
end
