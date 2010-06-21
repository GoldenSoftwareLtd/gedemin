object gd_dlgAutoBackup: Tgd_dlgAutoBackup
  Left = 374
  Top = 310
  BorderStyle = bsDialog
  Caption = 'јрхивное копирование'
  ClientHeight = 178
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 231
    Height = 13
    Caption = '»дет создание архивной копии базы данных.'
  end
  object Label2: TLabel
    Left = 8
    Top = 23
    Width = 248
    Height = 13
    Caption = 'ѕожалуйста, дождитесь завершени€ процесса...'
  end
  object Label3: TLabel
    Left = 8
    Top = 104
    Width = 265
    Height = 70
    AutoSize = False
    Caption = 
      '¬ зависимости от размера базы данных, производительности и загру' +
      'зки сервера архивное копирование может зан€ть от нескольких секу' +
      'нд до дес€тков минут. ѕожалуйста, не выключайте и не перезагружа' +
      'йте сервер в это врем€.'
    WordWrap = True
  end
  object Animate: TAnimate
    Left = 8
    Top = 40
    Width = 272
    Height = 60
    Active = True
    CommonAVI = aviCopyFile
    StopFrame = 20
  end
end
