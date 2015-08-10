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
  TextHeight = 14
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 261
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    object Label1: TLabel
      Left = 9
      Top = 9
      Width = 83
      Height = 14
      Caption = 'Поиск по имени:'
    end
    object btnAdd: TButton
      Left = 60
      Top = 258
      Width = 81
      Height = 23
      Anchors = [akBottom]
      Caption = 'Добавить'
      Default = True
      TabOrder = 2
      OnClick = btnAddClick
    end
    object lbComponents: TListBox
      Left = 9
      Top = 52
      Width = 182
      Height = 201
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 14
      Sorted = True
      TabOrder = 1
      OnDblClick = lbComponentsDblClick
    end
    object edName: TEdit
      Left = 9
      Top = 26
      Width = 182
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edNameChange
      OnKeyPress = edNameKeyPress
    end
  end
end
