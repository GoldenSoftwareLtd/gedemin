object at_dlgChoosePackage: Tat_dlgChoosePackage
  Left = 210
  Top = 188
  BorderStyle = bsDialog
  Caption = 'Выбор пакета'
  ClientHeight = 215
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object sgrPackage: TStringGrid
    Left = 8
    Top = 8
    Width = 289
    Height = 201
    ColCount = 1
    DefaultColWidth = 280
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 0
  end
  object mGSFInfo: TMemo
    Left = 304
    Top = 8
    Width = 225
    Height = 129
    TabStop = False
    Color = clBtnFace
    Lines.Strings = (
      'Name'
      'Comment'
      'Version'
      'Date')
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object BitBtn1: TBitBtn
    Left = 304
    Top = 152
    Width = 225
    Height = 25
    Caption = 'Выбрать'
    TabOrder = 2
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 304
    Top = 184
    Width = 225
    Height = 25
    Caption = 'Отмена'
    TabOrder = 3
    Kind = bkAbort
  end
end
