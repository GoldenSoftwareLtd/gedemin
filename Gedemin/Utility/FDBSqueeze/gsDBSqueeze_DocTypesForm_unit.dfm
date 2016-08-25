object gsDBSqueeze_DocTypesForm: TgsDBSqueeze_DocTypesForm
  Left = 545
  Top = 299
  Action = actSelectAll
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Выбор типов документов'
  ClientHeight = 599
  ClientWidth = 790
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClick = actSelectAllExecute
  PixelsPerInch = 96
  TextHeight = 13
  object strngrdDocTypes: TStringGrid
    Left = 281
    Top = 26
    Width = 498
    Height = 474
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
    OnDblClick = strngrdDocTypesDblClick
    OnDrawCell = strngrdDocTypesDrawCell
  end
  object mDocTypes: TMemo
    Left = 281
    Top = 509
    Width = 498
    Height = 53
    TabStop = False
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object tvDocTypes: TTreeView
    Left = 9
    Top = 10
    Width = 262
    Height = 553
    HideSelection = False
    HotTrack = True
    Indent = 19
    ReadOnly = True
    TabOrder = 2
    ToolTips = False
    OnClick = tvDocTypesClick
    OnCustomDrawItem = tvDocTypesCustomDrawItem
  end
  object txt5: TStaticText
    Left = 281
    Top = 9
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
    Left = 674
    Top = 9
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
    Left = 673
    Top = 570
    Width = 107
    Height = 21
    Caption = 'Принять'
    TabOrder = 6
    TabStop = False
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 562
    Top = 570
    Width = 107
    Height = 21
    Caption = 'Отмена'
    TabOrder = 5
    TabStop = False
    OnClick = btnCancelClick
  end
  object actList: TActionList
    Left = 8
    Top = 576
    object actSelectAll: TAction
      Caption = 'actSelectAll'
      ShortCut = 16449
      OnExecute = actSelectAllExecute
    end
  end
end
