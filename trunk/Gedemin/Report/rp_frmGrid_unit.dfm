object frmGrid: TfrmGrid
  Left = 0
  Top = 0
  Width = 443
  Height = 277
  Align = alClient
  TabOrder = 0
  object dbgSource: TgsDBGrid
    Left = 0
    Top = 0
    Width = 443
    Height = 277
    Align = alClient
    DataSource = dsSource
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    ReadOnly = True
    RefreshType = rtNone
    TabOrder = 0
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    MinColWidth = 40
    ShowFooter = True
  end
  object dsSource: TDataSource
    OnStateChange = dsSourceStateChange
    Left = 8
    Top = 8
  end
end
