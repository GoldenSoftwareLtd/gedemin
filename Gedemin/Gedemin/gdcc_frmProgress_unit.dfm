object gdcc_frmProgress: Tgdcc_frmProgress
  Left = 560
  Top = 349
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'gdcc_frmProgress'
  ClientHeight = 179
  ClientWidth = 417
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
  object lblName: TLabel
    Left = 16
    Top = 16
    Width = 73
    Height = 13
    Caption = 'Наименование'
  end
  object Label2: TLabel
    Left = 16
    Top = 40
    Width = 50
    Height = 13
    Caption = 'Начато в:'
  end
  object Label3: TLabel
    Left = 16
    Top = 59
    Width = 43
    Height = 13
    Caption = 'Прошло:'
  end
  object Label4: TLabel
    Left = 16
    Top = 78
    Width = 60
    Height = 13
    Caption = 'Выполнено:'
  end
  object lblEstimFinishCapt: TLabel
    Left = 200
    Top = 40
    Width = 135
    Height = 13
    Caption = 'Ожидается завершение в:'
  end
  object lblEstimLeftCapt: TLabel
    Left = 200
    Top = 59
    Width = 137
    Height = 13
    Caption = 'Приблизительно осталось:'
  end
  object lblStep: TLabel
    Left = 16
    Top = 128
    Width = 385
    Height = 13
    AutoSize = False
    Caption = 'lblStep'
  end
  object lblStarted: TLabel
    Left = 96
    Top = 40
    Width = 44
    Height = 13
    Caption = '12:00:00'
  end
  object lblElapsed: TLabel
    Left = 96
    Top = 59
    Width = 44
    Height = 13
    Caption = '12:00:00'
  end
  object lblEstimLeft: TLabel
    Left = 352
    Top = 59
    Width = 44
    Height = 13
    Caption = '12:00:00'
  end
  object lblEstimFinish: TLabel
    Left = 352
    Top = 40
    Width = 44
    Height = 13
    Caption = '12:00:00'
  end
  object lblDone: TLabel
    Left = 96
    Top = 78
    Width = 23
    Height = 13
    Caption = '75%'
  end
  object pb: TProgressBar
    Left = 16
    Top = 104
    Width = 385
    Height = 17
    Min = 0
    Max = 100
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 326
    Top = 147
    Width = 75
    Height = 21
    Action = actCancel
    TabOrder = 0
  end
  object al: TActionList
    Left = 256
    Top = 8
    object actCancel: TAction
      Caption = 'Остановить'
      OnExecute = actCancelExecute
      OnUpdate = actCancelUpdate
    end
    object actClose: TAction
      Caption = 'Закрыть'
      OnExecute = actCloseExecute
    end
  end
  object Timer: TTimer
    Interval = 2000
    OnTimer = TimerTimer
    Left = 176
    Top = 8
  end
end
