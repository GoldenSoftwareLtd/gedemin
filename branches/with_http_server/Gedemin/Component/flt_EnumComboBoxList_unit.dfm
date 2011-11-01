object EnumComboBoxList: TEnumComboBoxList
  Left = 209
  Top = 197
  BorderStyle = bsNone
  Caption = 'EnumComboBoxList'
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
  object clbView: TListView
    Left = 0
    Top = 0
    Width = 431
    Height = 252
    Align = alClient
    BorderStyle = bsNone
    Checkboxes = True
    Columns = <
      item
      end>
    HideSelection = False
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 0
    ViewStyle = vsReport
    OnAdvancedCustomDrawItem = clbViewAdvancedCustomDrawItem
    OnResize = clbViewResize
  end
end
