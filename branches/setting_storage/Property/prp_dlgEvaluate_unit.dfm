object dlgEvaluate: TdlgEvaluate
  Left = 378
  Top = 202
  Width = 446
  Height = 295
  HelpContext = 315
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
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lbExpression: TLabel
      Left = 8
      Top = 2
      Width = 62
      Height = 13
      Caption = 'Выражение:'
    end
    object cbExpression: TComboBox
      Left = 8
      Top = 18
      Width = 414
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 0
      Text = 'cbExpression'
      OnKeyDown = cbExpressionKeyDown
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 41
    Width = 430
    Height = 216
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlTop'
    TabOrder = 1
    object lbResult: TLabel
      Left = 8
      Top = 4
      Width = 55
      Height = 13
      Caption = 'Результат:'
    end
    object mResult: TMemo
      Left = 8
      Top = 22
      Width = 414
      Height = 187
      Anchors = [akLeft, akTop, akRight, akBottom]
      ScrollBars = ssVertical
      TabOrder = 0
      OnKeyDown = mResultKeyDown
    end
  end
end
