object dlg_gsResizer_Components: Tdlg_gsResizer_Components
  Left = 401
  Top = 169
  Width = 193
  Height = 292
  Caption = 'Компоненты'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 265
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 85
      Height = 13
      Caption = 'Поиск по имени:'
    end
    object btnAdd: TButton
      Left = 56
      Top = 240
      Width = 75
      Height = 21
      Anchors = [akBottom]
      Caption = 'Добавить'
      Default = True
      TabOrder = 2
      OnClick = btnAddClick
    end
    object lbComponents: TListBox
      Left = 8
      Top = 48
      Width = 169
      Height = 187
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
      OnDblClick = lbComponentsDblClick
    end
    object edName: TEdit
      Left = 8
      Top = 24
      Width = 169
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edNameChange
      OnKeyPress = edNameKeyPress
    end
  end
end
