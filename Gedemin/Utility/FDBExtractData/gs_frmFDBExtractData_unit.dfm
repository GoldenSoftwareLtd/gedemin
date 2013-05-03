object gs_frmFDBExtractData: Tgs_frmFDBExtractData
  Left = 299
  Top = 139
  Width = 307
  Height = 232
  Caption = 'ExtractData'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 291
    Height = 194
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lDatabase: TLabel
      Left = 8
      Top = 8
      Width = 52
      Height = 13
      Caption = 'Database: '
    end
    object sbSelectDB: TSpeedButton
      Left = 257
      Top = 3
      Width = 23
      Height = 21
      Action = actSeletDB
      Caption = '...'
    end
    object lUser: TLabel
      Left = 8
      Top = 36
      Width = 28
      Height = 13
      Caption = 'User: '
    end
    object lPassword: TLabel
      Left = 8
      Top = 65
      Width = 52
      Height = 13
      Caption = 'Password: '
    end
    object Label1: TLabel
      Left = 8
      Top = 104
      Width = 97
      Height = 13
      Caption = 'Сохранить в файл: '
    end
    object sbSelectOutPutFile: TSpeedButton
      Left = 258
      Top = 128
      Width = 23
      Height = 22
      Action = actSelectOutPutFile
      Caption = '...'
    end
    object eDatabase: TEdit
      Left = 64
      Top = 3
      Width = 193
      Height = 21
      TabOrder = 0
    end
    object eUser: TEdit
      Left = 64
      Top = 32
      Width = 217
      Height = 21
      TabOrder = 1
    end
    object ePassword: TEdit
      Left = 64
      Top = 61
      Width = 217
      Height = 21
      PasswordChar = '*'
      TabOrder = 2
    end
    object eSave: TEdit
      Left = 8
      Top = 128
      Width = 250
      Height = 21
      TabOrder = 3
    end
    object btnExtract: TButton
      Left = 168
      Top = 160
      Width = 115
      Height = 25
      Action = actExtract
      TabOrder = 4
    end
  end
  object ActionList: TActionList
    Left = 160
    Top = 88
    object actSeletDB: TAction
      Caption = 'actSeletDB'
      OnExecute = actSeletDBExecute
    end
    object actSelectOutPutFile: TAction
      OnExecute = actSelectOutPutFileExecute
    end
    object actExtract: TAction
      Caption = 'Извлечь данные'
      OnExecute = actExtractExecute
    end
  end
end
