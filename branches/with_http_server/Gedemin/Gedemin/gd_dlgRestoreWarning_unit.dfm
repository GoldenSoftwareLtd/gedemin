object gd_dlgRestoreWarning: Tgd_dlgRestoreWarning
  Left = 793
  Top = 526
  BorderStyle = bsDialog
  Caption = 'Внимание'
  ClientHeight = 141
  ClientWidth = 351
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl: TLabel
    Left = 10
    Top = 122
    Width = 3
    Height = 13
  end
  object Memo: TMemo
    Left = 8
    Top = 8
    Width = 337
    Height = 81
    TabStop = False
    BorderStyle = bsNone
    Lines.Strings = (
      'Не удается открыть файл базы данных для конфигурирования.'
      'Если вы используете сервер классической архитектуры,'
      'дождитесь окончания процесса восстановления.'
      ''
      'Для отмены конфигурирования файла базы данных нажмите '
      'Отмена. ')
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 139
    Top = 96
    Width = 75
    Height = 21
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 264
    Top = 80
  end
end
