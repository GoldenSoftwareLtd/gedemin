object dlgEvaluate: TdlgEvaluate
  Left = 581
  Top = 257
  Width = 354
  Height = 329
  HelpContext = 315
  Caption = 'Вычислить'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 338
    Height = 290
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Panel2: TPanel
      Left = 0
      Top = 48
      Width = 338
      Height = 242
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 8
      TabOrder = 0
      object lbResult: TLabel
        Left = 8
        Top = 8
        Width = 322
        Height = 14
        Align = alTop
        Caption = 'Результат:'
      end
      object mResult: TMemo
        Left = 8
        Top = 22
        Width = 322
        Height = 212
        Align = alClient
        ScrollBars = ssVertical
        TabOrder = 0
        OnKeyDown = mResultKeyDown
      end
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 338
      Height = 48
      Align = alTop
      Anchors = []
      BevelOuter = bvNone
      TabOrder = 1
      object lbExpression: TLabel
        Left = 9
        Top = 7
        Width = 62
        Height = 14
        Caption = 'Выражение:'
      end
      object cbExpression: TComboBox
        Left = 9
        Top = 24
        Width = 322
        Height = 22
        Anchors = [akLeft, akRight]
        ItemHeight = 14
        TabOrder = 0
        Text = 'cbExpression'
        OnKeyDown = cbExpressionKeyDown
      end
    end
  end
end
