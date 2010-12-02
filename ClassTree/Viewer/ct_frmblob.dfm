object frmBlob: TfrmBlob
  Left = 289
  Top = 182
  Width = 696
  Height = 480
  Caption = 'frmBlob'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object dbmemo: TDBMemo
    Left = 0
    Top = 0
    Width = 688
    Height = 453
    Align = alClient
    DataSource = dsMemo
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object dsMemo: TDataSource
    Left = 104
    Top = 32
  end
end
