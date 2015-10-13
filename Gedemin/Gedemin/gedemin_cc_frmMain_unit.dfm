object frm_gedemin_cc_main: Tfrm_gedemin_cc_main
  Left = 300
  Top = 200
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Gedemin CC'
  ClientHeight = 520
  ClientWidth = 1020
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 22
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1020
    Height = 40
    TabOrder = 0
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 40
    Width = 210
    Height = 440
    TabOrder = 1
  end
  object pnlRight: TPanel
    Left = 810
    Top = 40
    Width = 210
    Height = 440
    TabOrder = 3
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 470
    Width = 1020
    Height = 31
    Align = alBottom
    TabOrder = 4
  end
  object pnlCenter: TPanel
    Left = 210
    Top = 80
    Width = 600
    Height = 400
    TabOrder = 5
    object DBGrid1: TDBGrid
      Left = 10
      Top = 10
      Width = 580
      Height = 160
      DataSource = DM.DSrc
      TabOrder = 0
      TitleFont.Charset = RUSSIAN_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -16
      TitleFont.Name = 'Trebuchet MS'
      TitleFont.Style = []
    end
  end
  object mLog: TMemo
    Left = 220
    Top = 270
    Width = 580
    Height = 200
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 6
  end
  object lbClients: TListBox
    Left = 5
    Top = 50
    Width = 200
    Height = 420
    ItemHeight = 22
    TabOrder = 2
  end
  object pnlFilt: TPanel
    Left = 210
    Top = 40
    Width = 600
    Height = 40
    TabOrder = 7
  end
  object sb: TStatusBar
    Left = 0
    Top = 501
    Width = 1020
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object MainMenu1: TMainMenu
    object File1: TMenuItem
      Caption = 'File'
    end
  end
end
