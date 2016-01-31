object frm_gedemin_cc_main: Tfrm_gedemin_cc_main
  Left = 348
  Top = 210
  Width = 1028
  Height = 571
  Anchors = [akLeft, akTop, akRight, akBottom]
  Caption = 'Gedemin CC'
  Color = clBtnFace
  Constraints.MinHeight = 571
  Constraints.MinWidth = 1028
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 18
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1020
    Height = 40
    Align = alTop
    TabOrder = 0
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 40
    Width = 210
    Height = 440
    Align = alLeft
    TabOrder = 1
    object sbtnLeft: TSpeedButton
      Left = 195
      Top = 0
      Width = 15
      Height = 440
      Anchors = [akTop, akRight, akBottom]
      Caption = '<'
      Flat = True
      Layout = blGlyphBottom
      Margin = 5
      Spacing = 0
      OnClick = sbtnLeftClick
    end
    object lbClients: TListBox
      Left = 15
      Top = 15
      Width = 180
      Height = 380
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      ItemHeight = 18
      PopupMenu = PopMenuLB
      TabOrder = 0
      OnMouseDown = lbClientsMouseDown
    end
    object btnDoneAll: TButton
      Left = 50
      Top = 400
      Width = 110
      Height = 30
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Отключить всех'
      TabOrder = 1
      OnClick = btnDoneAllClick
    end
  end
  object pnlRight: TPanel
    Left = 810
    Top = 40
    Width = 210
    Height = 440
    Align = alRight
    TabOrder = 2
    object sbtnRight: TSpeedButton
      Left = 0
      Top = 0
      Width = 15
      Height = 440
      Anchors = [akLeft, akTop, akBottom]
      Caption = '>'
      Flat = True
      Layout = blGlyphBottom
      Margin = 5
      Spacing = 0
      OnClick = sbtnRightClick
    end
    object PB: TProgressBar
      Left = 20
      Top = 20
      Width = 180
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      Min = 0
      Max = 100
      Smooth = True
      TabOrder = 0
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 480
    Width = 1020
    Height = 20
    Align = alBottom
    TabOrder = 3
  end
  object pnlCenter: TPanel
    Left = 210
    Top = 65
    Width = 600
    Height = 415
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 4
    object DBGr: TDBGrid
      Left = 0
      Top = 0
      Width = 600
      Height = 315
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      DataSource = DM.DS
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = RUSSIAN_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -13
      TitleFont.Name = 'Trebuchet MS'
      TitleFont.Style = []
      OnDrawColumnCell = DBGrDrawColumnCell
    end
    object mLog: TMemo
      Left = 0
      Top = 315
      Width = 600
      Height = 100
      Anchors = [akLeft, akRight, akBottom]
      BorderStyle = bsNone
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
  object pnlFilt: TPanel
    Left = 210
    Top = 40
    Width = 600
    Height = 25
    Alignment = taLeftJustify
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
  object SB: TStatusBar
    Left = 0
    Top = 500
    Width = 1020
    Height = 20
    Panels = <
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object MainMenu1: TMainMenu
    object File1: TMenuItem
      Caption = 'File'
      object OpenLog1: TMenuItem
        Caption = 'Open Log...'
        OnClick = OpenLog1Click
      end
      object SaveLog1: TMenuItem
        Caption = 'Save Log...'
        OnClick = SaveLog1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
  end
  object PopMenuLB: TPopupMenu
    AutoPopup = False
    Left = 30
    object DoneClient: TMenuItem
      Caption = 'Done'
      OnClick = DoneClientClick
    end
  end
end
