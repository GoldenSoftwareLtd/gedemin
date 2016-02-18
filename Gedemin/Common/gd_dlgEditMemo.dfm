object dlgEditMemo: TdlgEditMemo
  Left = 247
  Top = 155
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Редактирование'
  ClientHeight = 285
  ClientWidth = 388
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 302
    Top = 0
    Width = 86
    Height = 285
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TButton
      Left = 3
      Top = 5
      Width = 75
      Height = 23
      Caption = 'ОК'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 3
      Top = 31
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'Отменить'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 302
    Height = 285
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    Caption = 'Panel2'
    TabOrder = 1
    object Memo: TMemo
      Left = 6
      Top = 6
      Width = 290
      Height = 273
      Align = alClient
      Lines.Strings = (
        'Memo')
      TabOrder = 0
    end
  end
end
