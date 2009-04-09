object frm_SettingView: Tfrm_SettingView
  Left = 316
  Top = 135
  Width = 795
  Height = 556
  Caption = 'Просмотр настройки'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 787
    Height = 493
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object splLeft: TSplitter
      Left = 283
      Top = 0
      Width = 3
      Height = 493
      Cursor = crHSplit
    end
    object pnlPositionText: TPanel
      Left = 286
      Top = 0
      Width = 501
      Height = 493
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object mPositionText: TMemo
        Left = 0
        Top = 0
        Width = 501
        Height = 493
        Align = alClient
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        WantReturns = False
      end
    end
    object pnlLeft: TPanel
      Left = 0
      Top = 0
      Width = 283
      Height = 493
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object splInfo: TSplitter
        Left = 0
        Top = 63
        Width = 283
        Height = 3
        Cursor = crVSplit
        Align = alTop
      end
      object pnlPositions: TPanel
        Left = 0
        Top = 66
        Width = 283
        Height = 427
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object lbPositions: TListBox
          Left = 0
          Top = 23
          Width = 283
          Height = 404
          Align = alClient
          ItemHeight = 13
          Sorted = True
          TabOrder = 0
          OnClick = lbPositionsClick
        end
        object pnlPositionsCaption: TPanel
          Left = 0
          Top = 0
          Width = 283
          Height = 23
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblPositions: TLabel
            Left = 7
            Top = 4
            Width = 103
            Height = 13
            Caption = 'Позиции настройки:'
          end
        end
      end
      object pnlSettingInfo: TPanel
        Left = 0
        Top = 0
        Width = 283
        Height = 63
        Align = alTop
        TabOrder = 0
        object mSettingInfo: TMemo
          Left = 1
          Top = 24
          Width = 281
          Height = 38
          Align = alClient
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          WantReturns = False
        end
        object pnlSettingInfoCaption: TPanel
          Left = 1
          Top = 1
          Width = 281
          Height = 23
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblSettingInfo: TLabel
            Left = 7
            Top = 4
            Width = 107
            Height = 13
            Caption = 'Свойства настройки:'
          end
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 493
    Width = 787
    Height = 32
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    object pnlButtons: TPanel
      Left = 616
      Top = 1
      Width = 170
      Height = 30
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnClose: TButton
        Left = 78
        Top = 4
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Закрыть'
        Default = True
        TabOrder = 0
        OnClick = btnCloseClick
      end
    end
  end
end
