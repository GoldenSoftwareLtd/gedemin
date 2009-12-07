object gd_dlgG: Tgd_dlgG
  Left = 374
  Top = 338
  BorderStyle = bsDialog
  Caption = '<generic dialog>'
  ClientHeight = 165
  ClientWidth = 383
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
  object btnOk: TButton
    Left = 12
    Top = 8
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 12
    Top = 32
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 12
    Top = 72
    Width = 75
    Height = 21
    Action = actHelp
    TabOrder = 2
  end
  object ActionList: TActionList
    Left = 264
    Top = 8
    object actOk: TAction
      Caption = '&Ok'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'О&тмена'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = '&Справка'
      ShortCut = 112
    end
  end
end
