object frXLSExportForm: TfrXLSExportForm
  Left = 271
  Top = 118
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'XLS export'
  ClientHeight = 97
  ClientWidth = 272
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cbOpen: TCheckBox
    Left = 16
    Top = 32
    Width = 193
    Height = 17
    Caption = 'Open Excel after export is done'
    TabOrder = 0
  end
  object Button1: TButton
    Left = 59
    Top = 65
    Width = 75
    Height = 25
    HelpContext = 40
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 139
    Top = 65
    Width = 75
    Height = 25
    HelpContext = 50
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object cbOnSheets: TCheckBox
    Left = 16
    Top = 8
    Width = 237
    Height = 17
    Caption = 'Create separate sheet for each report page'
    TabOrder = 3
  end
end
