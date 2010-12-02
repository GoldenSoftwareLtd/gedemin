object frReportPage: TfrReportPage
  Left = 0
  Top = 0
  Width = 443
  Height = 277
  Align = alClient
  TabOrder = 0
  object mmScript: TMemo
    Left = 0
    Top = 65
    Width = 443
    Height = 212
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New Cyr'
    Font.Style = []
    Lines.Strings = (
      'Function testfunction'
      '  BaseQuery.Clear'
      '  FQuery = BaseQuery.Add("ddd", 0)'
      '  Set SourceQuery = BaseQuery.Query(FQuery)'
      '  SourceQuery.SQL = "SELECT * FROM gd_user"'
      '  SourceQuery.Open'
      '  SourceQuery.IsResult = 1'
      ''
      '  SQuery = BaseQuery.Add("ClientDataSet", 1)'
      '  Set TargetTable = BaseQuery.Query(SQuery)'
      '  Call TargetTable.AddField("id", "ftInteger", 0, 0)'
      '  Call TargetTable.AddField("name", "ftString", 50, 0)'
      '  TargetTable.Open'
      ''
      '  SourceQuery.First'
      '  Do While not SourceQuery.Eof'
      '    TargetTable.Append'
      
        '    TargetTable.FieldByName("name").AsString = SourceQuery.Field' +
        'ByName("name").AsString'
      
        '    TargetTable.FieldByName("id").AsInteger = SourceQuery.FieldB' +
        'yName("id").AsInteger'
      '    TargetTable.Post'
      ''
      '    SourceQuery.Next'
      '  Loop'
      ''
      '  TargetTable.IsResult = 1'
      ''
      '  Set testfunction = BaseQuery'
      'End Function')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 443
    Height = 65
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object cbLanguage: TComboBox
      Left = 16
      Top = 8
      Width = 161
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      Items.Strings = (
        'VBScript'
        'JScript')
    end
    object edName: TEdit
      Left = 192
      Top = 8
      Width = 193
      Height = 21
      TabOrder = 1
      Text = 'testfunction'
    end
    object cbModule: TComboBox
      Left = 16
      Top = 32
      Width = 161
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      Items.Strings = (
        'REPORTMAIN'
        'REPORTPARAM'
        'REPORTEVENT')
    end
  end
end
