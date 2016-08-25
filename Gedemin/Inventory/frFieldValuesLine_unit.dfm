object frFieldValuesLine: TfrFieldValuesLine
  Left = 0
  Top = 0
  Width = 514
  Height = 23
  VertScrollBar.Visible = False
  Anchors = [akLeft, akTop, akRight]
  AutoScroll = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  OnResize = FrameResize
  object lblName: TLabel
    Left = 5
    Top = 5
    Width = 38
    Height = 13
    Caption = 'lblName'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    Transparent = True
  end
  object btnSelect: TSpeedButton
    Left = 480
    Top = 1
    Width = 19
    Height = 20
    Anchors = [akTop, akRight]
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FF185294185A9C185A9C185A9C185AA518
      5AA5185A9C185A9C18529418529418528C184A84FF00FFFF00FFFF00FF185AA5
      186BBD1873CE1873CE1873CE1873CE1873CE1873CE1873CE1873CE186BC6186B
      BD185AA5104A7BFF00FFFF00FF1863AD1873CE187BDE187BDE187BE71884E718
      8CF7188CF7188CF7188CF7187BDE186BC61863AD18528CFF00FFFF00FF186BC6
      187BDE188CFF84C6FF84C6FF1884EF84C6FF84C6FF188CF784C6FF84C6FF1873
      CE186BBD185294FF00FFFF00FF1873CE1884E7188CFFFFFFFFFFFFFF188CFFFF
      FFFFFFFFFF188CF7FFFFFFFFFFFF1873D6186BC6185A9CFF00FFFF00FF187BDE
      188CF7188CFF188CFF188CFF188CFF188CFF188CFF188CF7188CF71884E71873
      D61873CE185AA5FF00FFFF00FF1884E7188CFF188CFF188CFF188CFF188CF718
      8CF7188CFF188CFF1884EF187BDE1873CE1873CE1863ADFF00FFFF00FF1884EF
      188CFF188CFF188CFF188CF7188CF7188CF7188CF7188CFF1884EF1873D61873
      CE1873CE1863ADFF00FFFF00FF188CFF2194FF2194FF188CFF188CFF188CF718
      84F71884EF1884EF1884EF1873D61873CE1873CE1863ADFF00FFFF00FF188CFF
      39A5FF39A5FF2194FF1894FF188CFF188CFF1884EF1884E7187BDE187BDE187B
      DE1873CE1863ADFF00FFFF00FF2194FF52ADFF4AADFF299CFF2194FF2194FF18
      94FF188CF71884EF1884E7187BDE187BDE1873CE1863ADFF00FFFF00FF39A5FF
      6BBDFF52ADFF39A5FF319CFF299CFF299CFF2194FF188CFF1884F71884EF187B
      DE1873CE1863ADFF00FFFF00FF4AADFF84C6FF6BBDFF52ADFF4AADFF39A5FF31
      9CFF299CFF2194FF1894FF188CF71884EF1873CE185A9CFF00FFFF00FFFF00FF
      4AADFF319CFF2194FF188CFF188CFF188CF7188CF71884EF1884E7187BDE1873
      CE186BBDFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
    Margin = 0
    Visible = False
    OnClick = btnSelectClick
  end
  object btnType: TSpeedButton
    Tag = 1
    Left = 51
    Top = 3
    Width = 17
    Height = 17
    Flat = True
    Glyph.Data = {
      96000000424D9600000000000000760000002800000008000000080000000100
      0400000000002000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
      8888800000088888888888888888800000088888888888888888}
    Margin = 3
    OnClick = btnTypeClick
  end
  object lbl: TLabel
    Left = 456
    Top = 5
    Width = 12
    Height = 13
    Caption = ' è '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object cmbValue: TgsIBLookupComboBox
    Left = 184
    Top = 1
    Width = 49
    Height = 21
    HelpContext = 1
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 1
    Visible = False
  end
  object xdeStart: TxDateEdit
    Left = 327
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
    TabOrder = 2
    Text = '  .  .    '
    Visible = False
  end
  object edtValue: TEdit
    Left = 128
    Top = 1
    Width = 49
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
  object xceStart: TxCalculatorEdit
    Left = 240
    Top = 1
    Width = 41
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Visible = False
  end
  object lbValue: TListBox
    Left = 80
    Top = 1
    Width = 41
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 4
    Visible = False
  end
  object xceFinish: TxCalculatorEdit
    Left = 282
    Top = 1
    Width = 41
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    Visible = False
  end
  object xdeFinish: TxDateEdit
    Left = 391
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
    TabOrder = 6
    Text = '  .  .    '
    Visible = False
  end
end
