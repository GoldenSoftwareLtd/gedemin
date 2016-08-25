object gd_dlgDesktopName: Tgd_dlgDesktopName
  Left = 384
  Top = 305
  BorderStyle = bsDialog
  Caption = 'Сохранение рабочего стола'
  ClientHeight = 101
  ClientWidth = 253
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 178
    Height = 13
    Caption = '&Выберите имя для рабочего стола:'
    FocusControl = cb
  end
  object cb: TComboBox
    Left = 16
    Top = 32
    Width = 225
    Height = 21
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
    Text = 'cb'
  end
  object btnOk: TButton
    Left = 80
    Top = 64
    Width = 75
    Height = 25
    Caption = '&Ok'
    Default = True
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 165
    Top = 64
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'О&тмена'
    ModalResult = 2
    TabOrder = 2
  end
end
