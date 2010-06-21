object frmParamLine: TfrmParamLine
  Left = 0
  Top = 0
  Width = 394
  Height = 39
  Align = alTop
  TabOrder = 0
  object lblParamName: TLabel
    Left = 8
    Top = 11
    Width = 68
    Height = 13
    Caption = 'lblParamName'
  end
  object Panel1: TPanel
    Left = 127
    Top = 0
    Width = 267
    Height = 39
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object cbType: TComboBox
      Left = 155
      Top = 8
      Width = 102
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      Items.Strings = (
        'Простой'
        'Массив')
    end
    object edValue: TEdit
      Left = 8
      Top = 8
      Width = 137
      Height = 21
      TabOrder = 1
    end
  end
end
