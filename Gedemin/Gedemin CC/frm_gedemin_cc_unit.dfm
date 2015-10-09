object frm_gedemin_cc_main: Tfrm_gedemin_cc_main
  Left = 300
  Top = 200
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Гедымин Лог'
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
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 22
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1020
    Height = 40
    TabOrder = 2
  end
  object Panel2: TPanel
    Left = 0
    Top = 40
    Width = 210
    Height = 440
    TabOrder = 3
  end
  object Panel3: TPanel
    Left = 810
    Top = 40
    Width = 210
    Height = 440
    TabOrder = 4
  end
  object ClientsListBox: TListBox
    Left = 815
    Top = 50
    Width = 200
    Height = 400
    BorderStyle = bsNone
    ItemHeight = 22
    TabOrder = 1
  end
  object Panel4: TPanel
    Left = 0
    Top = 480
    Width = 1020
    Height = 40
    TabOrder = 5
  end
  object Panel5: TPanel
    Left = 210
    Top = 40
    Width = 600
    Height = 440
    TabOrder = 6
  end
  object mLog: TMemo
    Left = 220
    Top = 50
    Width = 580
    Height = 420
    BorderStyle = bsNone
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object MainMenu1: TMainMenu
    object N1111: TMenuItem
      Caption = '111'
      object N11111: TMenuItem
        Caption = '1111'
      end
    end
    object N2221: TMenuItem
      Caption = '222'
      object N22221: TMenuItem
        Caption = '2222'
      end
    end
  end
end
