object gd_frmShowSQLObjects: Tgd_frmShowSQLObjects
  Left = 257
  Top = 202
  AutoScroll = False
  Caption = 'gd_frmShowSQLObjects'
  ClientHeight = 438
  ClientWidth = 422
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 417
    Width = 422
    Height = 21
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 3
      Width = 75
      Height = 17
      Caption = 'Refresh'
      Default = True
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 422
    Height = 417
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Transactions'
      object sg: TStringGrid
        Left = 0
        Top = 0
        Width = 414
        Height = 389
        Align = alClient
        ColCount = 4
        DefaultColWidth = 100
        DefaultRowHeight = 14
        FixedCols = 0
        RowCount = 55
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'SQL Objects'
      ImageIndex = 1
      object sg2: TStringGrid
        Left = 0
        Top = 0
        Width = 414
        Height = 389
        Align = alClient
        ColCount = 6
        DefaultColWidth = 100
        DefaultRowHeight = 14
        FixedCols = 0
        RowCount = 55
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
        TabOrder = 0
      end
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 4000
    OnTimer = TimerTimer
    Left = 400
    Top = 56
  end
end
