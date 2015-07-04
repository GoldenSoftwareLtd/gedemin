object dlgScriptError: TdlgScriptError
  Left = 159
  Top = 209
  BorderStyle = bsDialog
  Caption = 'Ошибка скрипт-функции'
  ClientHeight = 140
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 80
    Top = 0
    Width = 296
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Вовремя выполнения скрипт-функции произошла ошибка:'
  end
  object btOk: TButton
    Left = 118
    Top = 112
    Width = 73
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object btEdit: TButton
    Left = 206
    Top = 112
    Width = 169
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Редактировать скрипт >>'
    ModalResult = 6
    TabOrder = 1
  end
  object stError: TStaticText
    Left = 8
    Top = 24
    Width = 423
    Height = 79
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoSize = False
    Caption = 'stError'
    TabOrder = 2
  end
end
