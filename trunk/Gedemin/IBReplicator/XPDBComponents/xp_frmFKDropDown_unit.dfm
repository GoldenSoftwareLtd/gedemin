inherited frmFKDropDown: TfrmFKDropDown
  Left = 507
  Top = 218
  Width = 322
  Height = 183
  Caption = 'frmFKDropDown'
  Font.Color = clCaptionText
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object pCaption: TPanel [0]
    Left = 0
    Top = 0
    Width = 314
    Height = 17
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = ' Table name'
    Color = 12558207
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clCaptionText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object Panel1: TPanel [1]
    Left = 0
    Top = 17
    Width = 314
    Height = 121
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object Grid: TxpDBGrid
      Left = 1
      Top = 1
      Width = 312
      Height = 119
      Align = alClient
      BorderStyle = bsNone
      Color = 15987699
      Ctl3D = False
      DataSource = DataSource
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      ParentCtl3D = False
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clBtnText
      TitleFont.Height = -11
      TitleFont.Name = 'MS Sans Serif'
      TitleFont.Style = []
      OnDblClick = GridDblClick
      OnKeyDown = GridKeyDown
    end
  end
  object SizePanel: TSizePanel [2]
    Left = 0
    Top = 138
    Width = 314
    Height = 18
    PanelType = ptRight
    Align = alBottom
    BevelOuter = bvNone
    ShowCloseButton = True
    TabOrder = 2
    OnButtonClick = SizePanelButtonClick
  end
  object DataSource: TDataSource [3]
    Left = 88
    Top = 24
  end
  inherited ActionList: TActionList
    Left = 120
    Top = 24
  end
end
