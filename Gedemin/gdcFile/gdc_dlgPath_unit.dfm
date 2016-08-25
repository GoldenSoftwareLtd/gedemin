object gdc_dlgPath: Tgdc_dlgPath
  Left = 302
  Top = 336
  BorderStyle = bsDialog
  Caption = 'Синхронизация файлов и папок'
  ClientHeight = 134
  ClientWidth = 290
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 290
    Height = 95
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 34
      Width = 249
      Height = 17
      AutoSize = False
      Caption = 'Путь синхронизации файлов:'
    end
    object edPath: TEdit
      Left = 16
      Top = 58
      Width = 233
      Height = 21
      TabOrder = 0
      Text = 'edPath'
    end
    object btnSelectDirectory: TButton
      Left = 249
      Top = 58
      Width = 24
      Height = 22
      Action = actSelectDirectory
      TabOrder = 1
    end
    object edFullPath: TEdit
      Left = 16
      Top = 6
      Width = 233
      Height = 21
      BorderStyle = bsNone
      Color = clMenu
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
      Text = 'edFullPath'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 95
    Width = 290
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnNext: TButton
      Left = 48
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Далее'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 160
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ActionList1: TActionList
    Images = dmImages.il16x16
    Left = 256
    Top = 88
    object actSelectDirectory: TAction
      Caption = '...'
      OnExecute = actSelectDirectoryExecute
    end
  end
end
