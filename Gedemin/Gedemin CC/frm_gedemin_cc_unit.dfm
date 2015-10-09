object frm_gedemin_cc_main: Tfrm_gedemin_cc_main
  Left = 300
  Top = 200
  Width = 1028
  Height = 571
  Caption = 'Гедымин Лог'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 22
  object mLog: TMemo
    Left = 20
    Top = 20
    Width = 800
    Height = 500
    BorderStyle = bsNone
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object btSave: TButton
    Left = 840
    Top = 460
    Width = 160
    Height = 40
    Caption = 'Сохранить'
    TabOrder = 1
    OnClick = btSaveClick
  end
  object ClientsListBox: TListBox
    Left = 840
    Top = 20
    Width = 160
    Height = 160
    BorderStyle = bsNone
    ItemHeight = 22
    TabOrder = 2
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Left = 970
    Top = 500
  end
end
