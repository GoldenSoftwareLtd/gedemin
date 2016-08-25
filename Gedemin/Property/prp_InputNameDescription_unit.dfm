object frmNameDescription: TfrmNameDescription
  Left = 494
  Top = 381
  BorderStyle = bsDialog
  ClientHeight = 89
  ClientWidth = 238
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 3
    Top = 8
    Width = 53
    Height = 13
    Caption = 'Название:'
  end
  object Label2: TLabel
    Left = 3
    Top = 32
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  object edtName: TEdit
    Left = 64
    Top = 5
    Width = 169
    Height = 21
    CharCase = ecLowerCase
    TabOrder = 0
  end
  object edtDesc: TEdit
    Left = 64
    Top = 32
    Width = 169
    Height = 21
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 77
    Top = 64
    Width = 75
    Height = 19
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 158
    Top = 64
    Width = 75
    Height = 19
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
  end
end
