object gsDBSqueeze_DocTypesForm: TgsDBSqueeze_DocTypesForm
  Left = 1397
  Top = 18
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Выбор типов документов'
  ClientHeight = 615
  ClientWidth = 861
  Color = 12050175
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object strngrdIgnoreDocTypes: TStringGrid
    Left = 352
    Top = 34
    Width = 498
    Height = 473
    TabStop = False
    ColCount = 2
    DefaultColWidth = 390
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 50
    FixedRows = 0
    Options = [goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ScrollBars = ssVertical
    TabOrder = 3
    OnDblClick = strngrdIgnoreDocTypesDblClick
    OnDrawCell = strngrdIgnoreDocTypesDrawCell
  end
  object mIgnoreDocTypes: TMemo
    Left = 352
    Top = 517
    Width = 498
    Height = 53
    TabStop = False
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object tvDocTypes: TTreeView
    Left = 8
    Top = 18
    Width = 337
    Height = 553
    Indent = 19
    TabOrder = 2
  end
  object txt5: TStaticText
    Left = 352
    Top = 17
    Width = 392
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'Тип документа'
    Color = 671448
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindow
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 0
  end
  object txt1: TStaticText
    Left = 745
    Top = 17
    Width = 105
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'ID'
    Color = 671448
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindow
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 744
    Top = 581
    Width = 107
    Height = 25
    Caption = 'Принять'
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 636
    Top = 581
    Width = 107
    Height = 25
    Caption = 'Отмена'
    TabOrder = 5
    OnClick = btnCancelClick
  end
end
