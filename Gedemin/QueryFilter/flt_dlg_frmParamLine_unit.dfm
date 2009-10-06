object dlg_frmParamLine: Tdlg_frmParamLine
  Left = 0
  Top = 0
  Width = 373
  Height = 26
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  TabOrder = 0
  OnResize = FrameResize
  object lblName: TLabel
    Left = 8
    Top = 7
    Width = 38
    Height = 13
    Caption = 'lblName'
    ParentShowHint = False
    PopupMenu = pmWhatIsIt
    ShowHint = True
    Transparent = True
  end
  object Bevel1: TBevel
    Left = 0
    Top = 24
    Width = 373
    Height = 2
    Align = alBottom
    Shape = bsBottomLine
  end
  object pmWhatIsIt: TPopupMenu
    Left = 72
    Top = 8
    object N1: TMenuItem
      Caption = 'Что это?'
      OnClick = N1Click
    end
  end
end
