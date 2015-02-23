object frameFormViewLine: TframeFormViewLine
  Left = 0
  Top = 0
  Width = 443
  Height = 31
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Align = alTop
  AutoScroll = False
  Constraints.MinWidth = 300
  TabOrder = 0
  object lFieldName: TLabel
    Left = 6
    Top = 4
    Width = 63
    Height = 13
    Caption = 'lFieldName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object cbNull: TXPCheckBox
    Left = 120
    Top = 2
    Width = 57
    Alignment = taLeft
    Caption = 'NULL'
    Checked = False
    OnClick = cbNullClick
  end
end
