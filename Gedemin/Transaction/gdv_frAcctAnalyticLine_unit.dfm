object frAcctAnalyticLine: TfrAcctAnalyticLine
  Left = 0
  Top = 0
  Width = 514
  Height = 28
  Anchors = [akLeft, akTop, akRight]
  AutoScroll = False
  TabOrder = 0
  object lAnaliticName: TLabel
    Left = 20
    Top = 5
    Width = 63
    Height = 13
    Caption = 'lAnaliticName'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = True
  end
  object chkNull: TCheckBox
    Left = 2
    Top = 3
    Width = 15
    Height = 17
    Caption = 'не существует'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = chkNullClick
  end
  object xdeDateTime: TxDateEdit
    Left = 247
    Top = 1
    Width = 60
    Height = 21
    Kind = kDate
    Anchors = [akLeft, akTop, akRight]
    EditMask = '!99\.99\.9999;1;_'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxLength = 10
    ParentFont = False
    TabOrder = 1
    Text = '  .  .    '
    Visible = False
  end
  object eAnalitic: TEdit
    Left = 120
    Top = 1
    Width = 118
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Visible = False
  end
end
