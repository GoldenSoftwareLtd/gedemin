object dlgChooseAnalyze: TdlgChooseAnalyze
  Left = 244
  Top = 106
  Width = 451
  Height = 488
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object gsIBGrid1: TgsIBGrid
    Left = 8
    Top = 9
    Width = 345
    Height = 442
    DataSource = dsAnalyze
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 0
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    MinColWidth = 40
  end
  object Button1: TButton
    Left = 360
    Top = 9
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 360
    Top = 39
    Width = 75
    Height = 25
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object ibdsAnalyze: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    Left = 248
    Top = 136
  end
  object dsAnalyze: TDataSource
    DataSet = ibdsAnalyze
    Left = 280
    Top = 136
  end
end
