object frmEventLog: TfrmEventLog
  Left = 246
  Top = 175
  Width = 327
  Height = 188
  Caption = 'Журнал событий'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object mEventLog: TMemo
    Left = 0
    Top = 0
    Width = 319
    Height = 161
    Align = alClient
    PopupMenu = pmEventLog
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object pmEventLog: TPopupMenu
    Left = 88
    Top = 32
    object N1: TMenuItem
      Action = actClearEventLog
    end
    object N2: TMenuItem
      Action = actAddComent
    end
    object N3: TMenuItem
      Action = actSaveEventToLog
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N5: TMenuItem
      Action = actProperty
    end
  end
  object alEventLog: TActionList
    Left = 136
    Top = 32
    object actAddComent: TAction
      Caption = 'Добавить комментарий...'
      OnExecute = actAddComentExecute
    end
    object actSaveEventToLog: TAction
      Caption = 'Сохранить в файл...'
      OnExecute = actSaveEventToLogExecute
    end
    object actClearEventLog: TAction
      Caption = 'Очистить список'
      OnExecute = actClearEventLogExecute
    end
    object actProperty: TAction
      Caption = 'Настройки'
      OnExecute = actPropertyExecute
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = '*.log'
    Filter = '|*.log|Все файлы|*.*'
    FilterIndex = 0
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 176
    Top = 32
  end
end
