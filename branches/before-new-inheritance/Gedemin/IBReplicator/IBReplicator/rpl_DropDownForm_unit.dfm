object DropDownForm: TDropDownForm
  Left = 276
  Top = 162
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'DropDownForm'
  ClientHeight = 165
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox: TListBox
    Left = 0
    Top = 0
    Width = 289
    Height = 165
    Align = alClient
    BevelInner = bvNone
    BorderStyle = bsNone
    Ctl3D = True
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 0
    OnKeyUp = ListBoxKeyUp
    OnMouseDown = ListBoxMouseDown
    OnMouseMove = ListBoxMouseMove
  end
end
