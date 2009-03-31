object gdc_attr_dlgSetToTxt: Tgdc_attr_dlgSetToTxt
  Left = 443
  Top = 336
  BorderStyle = bsDialog
  Caption = 'Сохранение настройки'
  ClientHeight = 240
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 123
    Width = 32
    Height = 13
    Caption = 'Файл:'
  end
  object Label2: TLabel
    Left = 8
    Top = 163
    Width = 122
    Height = 13
    Caption = 'Сравнить с настройкой:'
  end
  object edFile: TEdit
    Left = 8
    Top = 139
    Width = 334
    Height = 21
    TabOrder = 6
  end
  object Button1: TButton
    Left = 341
    Top = 139
    Width = 27
    Height = 21
    Caption = '...'
    TabOrder = 7
    OnClick = Button1Click
  end
  object btnOk: TButton
    Left = 213
    Top = 208
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 10
  end
  object btnCancel: TButton
    Left = 293
    Top = 208
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 11
  end
  object chbxSaveDependencies: TCheckBox
    Left = 9
    Top = 8
    Width = 345
    Height = 17
    Caption = 'Сохранять настройки, от которых зависит данная настройка'
    TabOrder = 0
  end
  object chbxUseRUID: TCheckBox
    Left = 9
    Top = 28
    Width = 345
    Height = 17
    Caption = 'Заменять идентификаторы на РУИДы'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object chbxDontSave: TCheckBox
    Left = 9
    Top = 47
    Width = 345
    Height = 17
    Caption = 'Не сохранять незначимые поля'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object chbxDontSaveBLOB: TCheckBox
    Left = 9
    Top = 67
    Width = 345
    Height = 17
    Caption = 'Не сохранять BLOB поля'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object chbxOnlyDup: TCheckBox
    Left = 9
    Top = 86
    Width = 368
    Height = 17
    Caption = 'Сохранять только объекты, входящие в более чем одну настройку'
    TabOrder = 4
  end
  object chbxOnlyDiff: TCheckBox
    Left = 28
    Top = 103
    Width = 274
    Height = 17
    Caption = 'и только если они различаются'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object edCompare: TEdit
    Left = 8
    Top = 179
    Width = 334
    Height = 21
    TabOrder = 8
  end
  object Button2: TButton
    Left = 341
    Top = 179
    Width = 27
    Height = 21
    Caption = '...'
    TabOrder = 9
    OnClick = Button2Click
  end
  object ActionList1: TActionList
    Left = 256
    Top = 40
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
  object SD: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Any file|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 160
    Top = 64
  end
  object OD: TOpenDialog
    Filter = 'Файлы настроек|*.gsf|Все файлы|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 192
    Top = 64
  end
end
