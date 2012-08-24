object DockableForm: TDockableForm
  Left = 425
  Top = 222
  Width = 336
  Height = 234
  Caption = 'DockableForm'
  Color = clBtnFace
  Constraints.MinHeight = 10
  Constraints.MinWidth = 10
  DockSite = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDockOver = FormDockOver
  OnEndDock = FormEndDock
  OnGetSiteInfo = FormGetSiteInfo
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pCaption: TPanel
    Left = 0
    Top = 0
    Width = 328
    Height = 18
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = '  pCaption'
    Color = clInactiveCaption
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clCaptionText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Visible = False
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 152
    Top = 104
    object actDockable: TAction
      Caption = 'Может стыковаться'
      OnExecute = actDockableExecute
      OnUpdate = actDockableUpdate
    end
    object actStayOnTop: TAction
      Caption = 'Поверх окон'
      ImageIndex = 193
      OnExecute = actStayOnTopExecute
      OnUpdate = actStayOnTopUpdate
    end
  end
  object pmMain: TPopupMenu
    Images = dmImages.il16x16
    Left = 56
    Top = 112
    object miStayOnTop: TMenuItem
      Action = actStayOnTop
    end
    object miSeparator: TMenuItem
      Caption = '-'
    end
    object miDockable: TMenuItem
      Action = actDockable
    end
  end
end
