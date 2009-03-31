object dlgToSetting: TdlgToSetting
  Left = 333
  Top = 97
  BorderStyle = bsDialog
  Caption = 'Добавить в настройку'
  ClientHeight = 330
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 72
    Width = 148
    Height = 13
    Caption = 'Объект входит в настройки:'
  end
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 349
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Для добавления в настройку, выберите настройку из выпадающего сп' +
      'иска и нажмите кнопку Добавить.'
    WordWrap = True
  end
  object Label3: TLabel
    Left = 8
    Top = 225
    Width = 350
    Height = 32
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = 
      'Для удаления объекта из настройки, установите курсор в таблице н' +
      'а настройку и нажмите кнопку Удалить.'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 0
    Top = 292
    Width = 368
    Height = 9
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object btnOk: TButton
    Left = 201
    Top = 302
    Width = 75
    Height = 21
    Action = actOk
    Anchors = [akRight, akBottom]
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 284
    Top = 302
    Width = 75
    Height = 21
    Action = actCancel
    Anchors = [akRight, akBottom]
    Cancel = True
    ModalResult = 2
    TabOrder = 5
  end
  object ibgrSetting: TgsIBGrid
    Left = 8
    Top = 88
    Width = 350
    Height = 130
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsSetting
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    ReadOnly = True
    TabOrder = 2
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    TitlesExpanding = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    ScaleColumns = True
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
    ShowTotals = False
  end
  object ibluSetting: TgsIBLookupComboBox
    Left = 8
    Top = 40
    Width = 271
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = SelfTransaction
    ListTable = 'at_setting'
    ListField = 'name'
    KeyField = 'ID'
    SortOrder = soAsc
    gdClassName = 'TgdcSetting'
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object Button1: TButton
    Left = 284
    Top = 40
    Width = 75
    Height = 21
    Action = actAddToSetting
    Anchors = [akTop, akRight]
    TabOrder = 1
  end
  object Button2: TButton
    Left = 284
    Top = 265
    Width = 75
    Height = 21
    Action = actDelFromSetting
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 3
  end
  object alToSetting: TActionList
    Images = dmImages.il16x16
    Left = 56
    Top = 96
    object actOk: TAction
      Caption = 'Ok'
      Hint = 'Сохранить изменения'
      OnExecute = actOkExecute
    end
    object actAddToSetting: TAction
      Caption = 'Добавить'
      Hint = 'Добавить в настройку'
      ImageIndex = 216
      ShortCut = 45
      OnExecute = actAddToSettingExecute
    end
    object actDelFromSetting: TAction
      Caption = 'Удалить'
      Hint = 'Удалить из настройки'
      ImageIndex = 217
      ShortCut = 16430
      OnExecute = actDelFromSettingExecute
      OnUpdate = actDelFromSettingUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      Hint = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
  object SelfTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 224
    Top = 96
  end
  object dsSetting: TDataSource
    DataSet = qrySetting
    Left = 144
    Top = 96
  end
  object qrySetting: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = SelfTransaction
    Left = 104
    Top = 96
  end
  object gdcSetting: TgdcSetting
    Left = 184
    Top = 96
  end
end
