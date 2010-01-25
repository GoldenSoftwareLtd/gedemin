object gsComboTreeBoxList: TgsComboTreeBoxList
  Left = 209
  Top = 197
  BorderStyle = bsNone
  Caption = 'gsComboTreeBoxList'
  ClientHeight = 252
  ClientWidth = 431
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object tvTree: TTreeView
    Left = 0
    Top = 0
    Width = 431
    Height = 252
    Align = alClient
    BorderStyle = bsNone
    HideSelection = False
    Indent = 19
    TabOrder = 0
    OnAdvancedCustomDrawItem = tvTreeAdvancedCustomDrawItem
    OnGetSelectedIndex = tvTreeGetSelectedIndex
    OnKeyDown = tvTreeKeyDown
  end
end
