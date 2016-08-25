object frmVariable: TfrmVariable
  Left = 151
  Top = 139
  Width = 544
  Height = 375
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Переменные'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 536
    Height = 348
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 161
      Top = 4
      Width = 4
      Height = 340
      Cursor = crHSplit
    end
    object Panel2: TPanel
      Left = 4
      Top = 4
      Width = 157
      Height = 340
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'Panel2'
      TabOrder = 0
      object Memo: TMemo
        Left = 0
        Top = 0
        Width = 157
        Height = 340
        Align = alClient
        BorderStyle = bsNone
        Lines.Strings = (
          'Memo')
        TabOrder = 0
      end
    end
    object Panel3: TPanel
      Left = 165
      Top = 4
      Width = 367
      Height = 340
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel2'
      TabOrder = 1
      object dbgVariable: TgsDBGrid
        Left = 0
        Top = 0
        Width = 367
        Height = 340
        Align = alClient
        Ctl3D = True
        DataSource = dsVariable
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        ParentCtl3D = False
        ScrollBars = ssHorizontal
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        MinColWidth = 40
      end
    end
  end
  object dsVariable: TDataSource
    Left = 225
    Top = 74
  end
end
