object gd_frmFeedback: Tgd_frmFeedback
  Left = 531
  Top = 319
  BorderStyle = bsDialog
  Caption = 'Форма обратной связи'
  ClientHeight = 171
  ClientWidth = 441
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
  object Label3: TLabel
    Left = 56
    Top = 80
    Width = 177
    Height = 19
    Caption = 'Спасибо, все хорошо'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = Label3Click
  end
  object Label4: TLabel
    Left = 56
    Top = 108
    Width = 255
    Height = 19
    Caption = 'Есть вопрос или предложение'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = Label4Click
  end
  object Label5: TLabel
    Left = 56
    Top = 136
    Width = 337
    Height = 19
    Caption = 'Есть проблема или обнаружена ошибка'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = Label5Click
  end
  object RadioButton1: TRadioButton
    Left = 24
    Top = 82
    Width = 17
    Height = 20
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = RadioButton1Click
  end
  object RadioButton2: TRadioButton
    Left = 24
    Top = 110
    Width = 17
    Height = 17
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = RadioButton2Click
  end
  object RadioButton3: TRadioButton
    Left = 24
    Top = 138
    Width = 17
    Height = 17
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = RadioButton3Click
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 441
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    Color = clWindow
    TabOrder = 3
    object Label1: TLabel
      Left = 17
      Top = 10
      Width = 405
      Height = 23
      Caption = 'Пожалуйста, оцените работу программы'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 17
      Top = 36
      Width = 254
      Height = 23
      Caption = 'Нам важно Ваше мнение!'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object al: TActionList
    Left = 304
    Top = 88
  end
end
