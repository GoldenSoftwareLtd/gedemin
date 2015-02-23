object prp_frm: Tprp_frm
  Left = 360
  Top = 248
  Width = 405
  Height = 305
  Caption = 'prp_frm'
  Color = clBtnShadow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object VLSplitter: TSplitter
    Left = 49
    Top = 9
    Width = 4
    Height = 185
    Cursor = crHSplit
    AutoSnap = False
    Color = clBtnFace
    MinSize = 50
    ParentColor = False
    Visible = False
  end
  object VRSplitter: TSplitter
    Left = 340
    Top = 9
    Width = 4
    Height = 185
    Cursor = crHSplit
    Align = alRight
    AutoSnap = False
    Color = clBtnFace
    MinSize = 50
    ParentColor = False
    Visible = False
  end
  object HSplitter: TSplitter
    Left = 0
    Top = 203
    Width = 389
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    Color = clBtnFace
    MinSize = 50
    ParentColor = False
    Visible = False
  end
  object tbdTop: TTBDock
    Left = 0
    Top = 0
    Width = 389
    Height = 9
  end
  object LeftDockPanel: TPanel
    Left = 0
    Top = 9
    Width = 49
    Height = 185
    Align = alLeft
    BevelOuter = bvNone
    DockSite = True
    TabOrder = 1
    OnDockDrop = LeftDockPanelDockDrop
    OnDockOver = LeftDockPanelDockOver
    OnGetSiteInfo = LeftDockPanelGetSiteInfo
    OnUnDock = LeftDockPanelUnDock
  end
  object RightDockPanel: TPanel
    Left = 344
    Top = 9
    Width = 45
    Height = 185
    Align = alRight
    BevelOuter = bvNone
    DockSite = True
    TabOrder = 2
    OnDockDrop = LeftDockPanelDockDrop
    OnDockOver = RightDockPanelDockOver
    OnGetSiteInfo = LeftDockPanelGetSiteInfo
    OnUnDock = LeftDockPanelUnDock
  end
  object BottomDockPanel: TPanel
    Left = 0
    Top = 207
    Width = 389
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    DockSite = True
    TabOrder = 3
    OnDockDrop = LeftDockPanelDockDrop
    OnDockOver = BottomDockPanelDockOver
    OnGetSiteInfo = LeftDockPanelGetSiteInfo
    OnResize = BottomDockPanelResize
    OnUnDock = LeftDockPanelUnDock
  end
  object tbdLeft: TTBDock
    Left = 53
    Top = 9
    Width = 9
    Height = 185
    Position = dpLeft
  end
  object tbdBottom: TTBDock
    Left = 0
    Top = 194
    Width = 389
    Height = 9
    Position = dpBottom
  end
  object tbdRight: TTBDock
    Left = 331
    Top = 9
    Width = 9
    Height = 185
    Position = dpRight
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 248
    Width = 389
    Height = 19
    Panels = <>
    SimplePanel = False
  end
end
