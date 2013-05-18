object frAcctQuantityLine: TfrAcctQuantityLine
  Left = 0
  Top = 0
  Width = 435
  Height = 23
  Align = alTop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object lName: TLabel
    Left = 4
    Top = 5
    Width = 29
    Height = 13
    Caption = 'lName'
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
  object eCalc: TxCalculatorEdit
    Left = 88
    Top = 1
    Width = 233
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    OnChange = eCalcChange
  end
end
