object dlgThreeButton: TdlgThreeButton
  Left = 256
  Top = 185
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsDialog
  ClientHeight = 89
  ClientWidth = 406
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlText: TPanel
    Left = 0
    Top = 0
    Width = 406
    Height = 60
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 0
    object lbText: TLabel
      Left = 3
      Top = 3
      Width = 400
      Height = 54
      Align = alClient
      Alignment = taCenter
      BiDiMode = bdLeftToRight
      Caption = 
        'Label1 tyutyuir ruiyuiyuykkljhjjhjh uihiuhuihiluhuilhuilh uihiuh' +
        'iuhiuhuhiuhiuhui uihuihuihuihuihuih hhuhihihuhihuhuihiuhi uhuihu' +
        'ihiuhiuhuiuh ihiuhihihihuihih iuhihuihuihiuhuihihih'
      ParentBiDiMode = False
      Transparent = True
      Layout = tlCenter
      WordWrap = True
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 60
    Width = 406
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 20
    TabOrder = 1
    object btnFirst: TButton
      Left = 72
      Top = 1
      Width = 90
      Height = 23
      Caption = 'btnFirst'
      ModalResult = 1
      TabOrder = 0
      OnClick = btnFirstClick
    end
    object btnSecond: TButton
      Left = 182
      Top = 1
      Width = 90
      Height = 23
      Caption = 'btnSecond'
      ModalResult = 1
      TabOrder = 1
      OnClick = btnSecondClick
    end
    object btnThird: TButton
      Left = 301
      Top = 1
      Width = 90
      Height = 23
      Caption = 'btn'
      ModalResult = 1
      TabOrder = 2
      OnClick = btnThirdClick
    end
  end
end
