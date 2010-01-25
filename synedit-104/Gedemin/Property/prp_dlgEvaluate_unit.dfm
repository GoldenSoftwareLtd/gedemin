object dlgEvaluate: TdlgEvaluate
  Left = 378
  Top = 202
  Width = 370
  Height = 235
  HelpContext = 315
  ActiveControl = cbExpression
  Caption = 'Вычислить'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbExpression: TLabel
    Left = 8
    Top = 8
    Width = 62
    Height = 13
    Caption = 'Выражение:'
  end
  object lbResult: TLabel
    Left = 8
    Top = 48
    Width = 55
    Height = 13
    Caption = 'Результат:'
  end
  object cbExpression: TComboBox
    Left = 8
    Top = 24
    Width = 347
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    Text = 'cbExpression'
    OnKeyDown = cbExpressionKeyDown
  end
  object mResult: TMemo
    Left = 8
    Top = 64
    Width = 347
    Height = 140
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 1
    OnKeyDown = mResultKeyDown
  end
end
