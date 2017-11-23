object Form1: TForm1
  Left = 702
  Top = 425
  BorderStyle = bsDialog
  Caption = 'DNMN Control'
  ClientHeight = 177
  ClientWidth = 442
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
    Left = 24
    Top = 88
    Width = 103
    Height = 13
    Caption = 'Контрольное число:'
  end
  object lblCode: TLabel
    Left = 24
    Top = 120
    Width = 107
    Height = 13
    Caption = 'Код разблокировки: '
  end
  object Memo1: TMemo
    Left = 24
    Top = 16
    Width = 401
    Height = 57
    BorderStyle = bsNone
    Lines.Strings = (
      
        '1. Проверить оплату клиента. Код выдается только при отсутствии ' +
        'долга.'
      '2. Проставить в интернетовской табличке дату деноминирования.'
      '3. Если нет записи в интернетовской табличке -- внести.')
    ParentColor = True
    TabOrder = 5
  end
  object Button1: TButton
    Left = 352
    Top = 144
    Width = 75
    Height = 21
    Caption = 'Закрыть'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = Button1Click
  end
  object edKeyNumber: TEdit
    Left = 136
    Top = 84
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object edCode: TEdit
    Left = 137
    Top = 116
    Width = 121
    Height = 21
    TabOrder = 2
  end
  object Button2: TButton
    Left = 262
    Top = 83
    Width = 75
    Height = 21
    Caption = 'Код'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 23
    Top = 144
    Width = 75
    Height = 21
    Caption = 'Таблица'
    TabOrder = 3
    OnClick = Button3Click
  end
end
