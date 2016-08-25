object dlg_InputDateRemains: Tdlg_InputDateRemains
  Left = 400
  Top = 386
  BorderStyle = bsDialog
  Caption = '¬вод даты'
  ClientHeight = 72
  ClientWidth = 413
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
    Left = 8
    Top = 11
    Width = 264
    Height = 13
    Caption = '”кажите дату на которую будут построены остатки: '
    WordWrap = True
  end
  object xdeDateRemains: TxDateEdit
    Left = 280
    Top = 8
    Width = 121
    Height = 21
    Kind = kDate
    EditMask = '!99\.99\.9999;1;_'
    MaxLength = 10
    TabOrder = 0
    Text = '23.02.2006'
  end
  object Button1: TButton
    Left = 247
    Top = 38
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 327
    Top = 38
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'ќтмена'
    ModalResult = 2
    TabOrder = 2
  end
end
