object gd_DatabasesListDlg: Tgd_DatabasesListDlg
  Left = 582
  Top = 424
  BorderStyle = bsDialog
  Caption = 'База данных'
  ClientHeight = 115
  ClientWidth = 384
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
    Left = 11
    Top = 11
    Width = 77
    Height = 13
    Caption = 'Наименование:'
  end
  object Label2: TLabel
    Left = 11
    Top = 38
    Width = 69
    Height = 13
    Caption = 'Сервер/порт:'
  end
  object Label4: TLabel
    Left = 11
    Top = 65
    Width = 58
    Height = 13
    Caption = 'Имя файла:'
  end
  object Label3: TLabel
    Left = 224
    Top = 40
    Width = 3
    Height = 13
  end
  object edName: TEdit
    Left = 94
    Top = 8
    Width = 281
    Height = 21
    TabOrder = 0
  end
  object edServer: TEdit
    Left = 94
    Top = 34
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object edFileName: TEdit
    Left = 94
    Top = 60
    Width = 261
    Height = 21
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 221
    Top = 88
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 301
    Top = 88
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 5
  end
  object btnSelectFile: TButton
    Left = 355
    Top = 60
    Width = 21
    Height = 21
    Caption = '...'
    TabOrder = 3
    OnClick = btnSelectFileClick
  end
  object ActionList: TActionList
    Left = 304
    Top = 32
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'fdb'
    Filter = 'Базы данных Firebird|*.fdb|Все файлы|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Title = 'Выбрать файл базы данных'
    Left = 176
    Top = 40
  end
end
