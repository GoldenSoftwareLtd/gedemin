object OpenDir: TOpenDir
  Left = 390
  Top = 265
  BorderStyle = bsDialog
  Caption = 'Выберите папку'
  ClientHeight = 301
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object btnOK: TButton
    Left = 280
    Top = 272
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 360
    Top = 272
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object edPath: TEdit
    Left = 8
    Top = 8
    Width = 425
    Height = 24
    TabOrder = 2
  end
  object DirectoryListBox1: TDirectoryListBox
    Left = 8
    Top = 40
    Width = 425
    Height = 225
    ItemHeight = 16
    TabOrder = 3
    OnChange = DirectoryListBox1Change
  end
  object DriveComboBox1: TDriveComboBox
    Left = 8
    Top = 272
    Width = 249
    Height = 22
    TabOrder = 4
    OnChange = DriveComboBox1Change
  end
end
