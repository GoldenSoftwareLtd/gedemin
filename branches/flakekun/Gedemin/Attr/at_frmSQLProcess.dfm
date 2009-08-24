object frmSQLProcess: TfrmSQLProcess
  Left = 315
  Top = 235
  Width = 565
  Height = 398
  HelpContext = 25
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Выполнение SQL команд'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 557
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object tbProcessSQL: TTBToolbar
      Left = 7
      Top = 5
      Width = 166
      Height = 22
      Caption = 'tbProcessSQL'
      Images = dmImages.il16x16
      TabOrder = 0
      object tbiSaveToFile: TTBItem
        Action = actSaveToFile
        DisplayMode = nbdmImageAndText
        ShortCut = 16467
      end
      object tbiClose: TTBItem
        Action = actClose
        Caption = 'Закрыть   '
        DisplayMode = nbdmImageAndText
      end
    end
  end
  object stbSQLProcess: TStatusBar
    Left = 0
    Top = 352
    Width = 557
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object pb: TProgressBar
    Left = 0
    Top = 336
    Width = 557
    Height = 16
    Align = alBottom
    Min = 0
    Max = 100
    TabOrder = 2
  end
  object Panel1: TPanel
    Left = 0
    Top = 334
    Width = 557
    Height = 2
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
  end
  object SQLText: TMemo
    Left = 0
    Top = 33
    Width = 557
    Height = 301
    Align = alClient
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
    WantReturns = False
    WordWrap = False
  end
  object alSQLProcess: TActionList
    Images = dmImages.il16x16
    Left = 480
    Top = 112
    object actSaveToFile: TAction
      Caption = 'Сохранить'
      Hint = 'Сохранить лог в файл'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
    end
    object actClose: TAction
      Caption = '   Закрыть   '
      ImageIndex = 125
      OnExecute = actCloseExecute
    end
  end
end
