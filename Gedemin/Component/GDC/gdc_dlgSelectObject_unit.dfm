object gdc_dlgSelectObject: Tgdc_dlgSelectObject
  Left = 416
  Top = 346
  HelpContext = 62
  BorderStyle = bsDialog
  Caption = 'Выбор объекта'
  ClientHeight = 83
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lMessage: TLabel
    Left = 8
    Top = 16
    Width = 249
    Height = 33
    AutoSize = False
    Caption = 'Выберите объект из списка:'
    WordWrap = True
  end
  object btnOk: TButton
    Left = 272
    Top = 8
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 272
    Top = 32
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 2
  end
  object lkup: TgsIBLookupComboBox
    Left = 8
    Top = 56
    Width = 249
    Height = 21
    HelpContext = 1
    Transaction = IBTransaction
    ItemHeight = 13
    TabOrder = 0
  end
  object btnHelp: TButton
    Left = 272
    Top = 56
    Width = 75
    Height = 21
    Action = actHelp
    TabOrder = 3
  end
  object ActionList: TActionList
    Left = 320
    Top = 32
    object actOk: TAction
      Caption = '&Готово'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = '&Отмена'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = '&Справка'
      ShortCut = 112
      OnExecute = actHelpExecute
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 288
    Top = 32
  end
end
