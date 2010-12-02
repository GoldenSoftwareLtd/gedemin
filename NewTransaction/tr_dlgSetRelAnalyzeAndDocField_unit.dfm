object dlgSetRelAnalyzeAndDocField: TdlgSetRelAnalyzeAndDocField
  Left = 194
  Top = 137
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Установка связи аналитики с полями документа'
  ClientHeight = 327
  ClientWidth = 559
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 9
    Top = 12
    Width = 54
    Height = 13
    Caption = 'Аналитика'
  end
  object Label2: TLabel
    Left = 9
    Top = 61
    Width = 26
    Height = 13
    Caption = 'Поле'
  end
  object Label3: TLabel
    Left = 8
    Top = 36
    Width = 51
    Height = 13
    Caption = 'Документ'
  end
  object Button1: TButton
    Left = 72
    Top = 86
    Width = 75
    Height = 25
    Action = actNew
    TabOrder = 4
  end
  object cbAnalyze: TComboBox
    Left = 72
    Top = 8
    Width = 393
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbAnalyzeChange
  end
  object cbDocumentField: TComboBox
    Left = 72
    Top = 57
    Width = 393
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
  end
  object Button2: TButton
    Left = 152
    Top = 86
    Width = 75
    Height = 25
    Action = actReplace
    TabOrder = 5
  end
  object Button3: TButton
    Left = 232
    Top = 86
    Width = 75
    Height = 25
    Action = actDelete
    TabOrder = 6
  end
  object Button4: TButton
    Left = 477
    Top = 8
    Width = 75
    Height = 25
    Action = actOk
    Default = True
    TabOrder = 7
  end
  object Button5: TButton
    Left = 477
    Top = 38
    Width = 75
    Height = 25
    Action = actCancel
    Cancel = True
    TabOrder = 8
  end
  object gsibgrEntryAnalyzeRel: TgsIBGrid
    Left = 9
    Top = 116
    Width = 454
    Height = 201
    DataSource = dsEntryAnalyzeRel
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
    TabOrder = 3
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
  end
  object cbDocumentType: TComboBox
    Left = 72
    Top = 32
    Width = 393
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnChange = cbAnalyzeChange
  end
  object ibdsEntryAnalyzeRel: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_entryanalyzerel'
      'where'
      '  ENTRYLINEKEY = :OLD_ENTRYLINEKEY and'
      '  ANALYZEFIELD = :OLD_ANALYZEFIELD')
    InsertSQL.Strings = (
      'insert into gd_entryanalyzerel'
      
        '  (ENTRYLINEKEY, DOCTYPEKEY, ANALYZEFIELD, DOCRELNAME, DOCFIELDN' +
        'AME)'
      'values'
      
        '  (:ENTRYLINEKEY, :DOCTYPEKEY, :ANALYZEFIELD, :DOCRELNAME, :DOCF' +
        'IELDNAME)')
    SelectSQL.Strings = (
      'SELECT * FROM gd_entryanalyzerel WHERE entrylinekey = :elk')
    ModifySQL.Strings = (
      'update gd_entryanalyzerel'
      'set'
      '  ENTRYLINEKEY = :ENTRYLINEKEY,'
      '  ANALYZEFIELD = :ANALYZEFIELD,'
      '  DOCTYPEKEY = :DOCTYPEKEY,'
      '  DOCRELNAME = :DOCRELNAME,'
      '  DOCFIELDNAME = :DOCFIELDNAME'
      'where'
      '  ENTRYLINEKEY = :OLD_ENTRYLINEKEY and'
      '  ANALYZEFIELD = :OLD_ANALYZEFIELD')
    Left = 192
    Top = 140
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 192
    Top = 172
  end
  object dsEntryAnalyzeRel: TDataSource
    DataSet = ibdsEntryAnalyzeRel
    Left = 224
    Top = 140
  end
  object ActionList1: TActionList
    Left = 352
    Top = 140
    object actNew: TAction
      Caption = 'Добавить'
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    object actReplace: TAction
      Caption = 'Заменить'
      OnExecute = actReplaceExecute
      OnUpdate = actReplaceUpdate
    end
    object actDelete: TAction
      Caption = 'Удалить'
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
end
