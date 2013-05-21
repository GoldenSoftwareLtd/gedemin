object dlgCompareNSRecords: TdlgCompareNSRecords
  Left = 541
  Top = 213
  Width = 366
  Height = 400
  Caption = 'dlgCompareNSRecords'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 350
    Height = 362
    Align = alClient
    TabOrder = 0
    object lCaption: TLabel
      Left = 16
      Top = 16
      Width = 3
      Height = 13
    end
    object Button1: TButton
      Left = 24
      Top = 100
      Width = 120
      Height = 25
      Action = actDB
      TabOrder = 0
    end
    object Button2: TButton
      Left = 192
      Top = 100
      Width = 120
      Height = 25
      Action = actFromFile
      TabOrder = 1
    end
  end
  object ActionList1: TActionList
    Left = 256
    Top = 192
    object actDB: TAction
      Caption = 'Из базы'
      OnExecute = actDBExecute
    end
    object actFromFile: TAction
      Caption = 'Из файла'
      OnExecute = actFromFileExecute
    end
  end
end
