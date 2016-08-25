object frmAnalyze: TfrmAnalyze
  Left = 244
  Top = 103
  Width = 696
  Height = 480
  Caption = 'Аналитические поля'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 29
    ButtonHeight = 21
    ButtonWidth = 67
    Caption = 'ToolBar1'
    Flat = True
    ShowCaptions = True
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Action = actNew
    end
    object ToolButton3: TToolButton
      Left = 67
      Top = 0
      Action = actEdit
    end
    object ToolButton2: TToolButton
      Left = 134
      Top = 0
      Action = actDelete
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 29
    Width = 688
    Height = 424
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object gsibgrAnalyze: TgsIBGrid
      Left = 5
      Top = 5
      Width = 678
      Height = 414
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsAnalyzeField
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
      ColumnEditors = <>
      Aliases = <>
    end
  end
  object dsAnalyzeField: TDataSource
    DataSet = ibdsAnalyze
    Left = 104
    Top = 173
  end
  object ibdsAnalyze: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    RefreshSQL.Strings = (
      'SELECT * FROM at_relation_fields rf WHERE '
      '  rf.relationname = '#39'GD_CARDACCOUNT'#39' and '
      '  rf.fieldname = :OLD_FIELDNAME')
    SelectSQL.Strings = (
      
        'SELECT * FROM at_relation_fields rf WHERE rf.relationname = '#39'GD_' +
        'CARDACCOUNT'#39' and rf.fieldname LIKE '#39'USR$%'#39)
    Left = 136
    Top = 173
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 136
    Top = 213
  end
  object ActionList1: TActionList
    Left = 344
    Top = 157
    object actNew: TAction
      Caption = 'Добавить...'
      OnExecute = actNewExecute
    end
    object actEdit: TAction
      Caption = 'Изменить...'
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
  end
end
