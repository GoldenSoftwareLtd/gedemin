object dlg_gsResizer_ObjectInspector: Tdlg_gsResizer_ObjectInspector
  Left = 504
  Top = 167
  Width = 233
  Height = 445
  ActiveControl = cbObjectInspector
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Инспектор объектов'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PopupMenu = PopupMenu1
  Visible = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnHide = FormHide
  OnMouseMove = pcObjectInspectorMouseMove
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 225
    Height = 23
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    OnMouseMove = pcObjectInspectorMouseMove
    object SpeedButton1: TSpeedButton
      Left = 205
      Top = 0
      Width = 20
      Height = 21
      Anchors = [akTop, akRight]
      Flat = True
      Glyph.Data = {
        46020000424D46020000000000003600000028000000100000000B0000000100
        1800000000001002000000000000000000000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFBD8C21947B4A4A4200FF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFBD8C21947B4A4A4200FF00FFBD8C214A4200E7
        AD007B4A004A4200008CBD009CD6009CD6FF00FFFF00FFFF00FFBD8C214A4200
        6B42007342004A42006B4A21E7AD00E78C008C63006B42004A4200009CD6009C
        D6008CBDFF00FFFF00FF9C8C734A4200E78C00BD4A006B42004A42004221006B
        42006B42008C63007B7B7B00E7FF00C6F700C6F7008CBDFF00FF7B7342422100
        BD4A00BD4A006B42007B63004A42009C73008C63008C63004294BD00E7FF00CE
        FF00D6FF21ADE7008CBDFF00FF8C4A4AAD7B00946B007B4A00636B637BADA5AD
        7B00AD7B009C946B00E7FF8CE7FF42D6FF42D6FF00D6FF009CD6FF00FFFF00FF
        8C4A4A7B63007B632163CEE700BDF700CEFF63CEE742D6FF00E7FF8CE7FFADE7
        FF42D6FF42D6FF009CD6FF00FFFF00FF21ADE700CEFF00E7FF42D6FF00CEFF00
        C6F700CEFF00CEFF42D6FF00E7FF8CE7FF8CE7FF42D6FF009CD6FF00FFFF00FF
        FF00FF21ADE700CEFF00E7FF42D6FF00CEFF00BDF700CEFF00BDE742D6FF00E7
        FF8CE7FFBDEFFF21ADE7FF00FFFF00FFFF00FFFF00FF21ADE700CEFFBDEFFF00
        E7FF00CEFF21ADE7FF00FF00C6F700BDE700BDE721ADE7FF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FF00C6F700BDE700BDE721ADE7FF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FF}
      OnClick = SpeedButton1Click
    end
    object cbObjectInspector: TComboBox
      Left = 0
      Top = 0
      Width = 205
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      DropDownCount = 26
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      Sorted = True
      TabOrder = 0
      OnClick = cbObjectInspectorClick
      OnDropDown = cbObjectInspectorDropDown
    end
    object edInspector: TEdit
      Left = 0
      Top = 0
      Width = 188
      Height = 21
      TabStop = False
      Anchors = [akLeft, akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Visible = False
      OnChange = edInspectorChange
      OnClick = edInspectorClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 23
    Width = 225
    Height = 376
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    OnMouseMove = pcObjectInspectorMouseMove
    object pcObjectInspector: TPageControl
      Left = 0
      Top = 0
      Width = 225
      Height = 376
      ActivePage = tsProperies
      Align = alClient
      TabOrder = 0
      OnMouseMove = pcObjectInspectorMouseMove
      object tsProperies: TTabSheet
        Caption = 'Свойства'
      end
      object tsEvents: TTabSheet
        Caption = 'События'
        ImageIndex = 1
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 399
    Width = 225
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 44
    Top = 135
    object miStayOnTop: TMenuItem
      Caption = 'Всегда сверху'
      OnClick = miStayOnTopClick
    end
  end
end
