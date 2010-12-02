object dlgRecordFetch: TdlgRecordFetch
  Left = 454
  Top = 344
  BorderStyle = bsDialog
  Caption = 'Чтение данных'
  ClientHeight = 58
  ClientWidth = 248
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lblCount: TLabel
    Left = 8
    Top = 15
    Width = 233
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'lblCount'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 33
    Width = 233
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'Нажмите ESC чтобы прервать процесс.'
  end
  object btnCancel: TButton
    Left = 80
    Top = 48
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Прервать'
    Default = True
    TabOrder = 0
    Visible = False
    OnClick = btnCancelClick
  end
end
