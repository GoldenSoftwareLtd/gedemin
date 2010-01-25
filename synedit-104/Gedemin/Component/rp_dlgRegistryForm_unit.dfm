object dlgRegistryForm: TdlgRegistryForm
  Left = 238
  Top = 168
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Шаблон'
  ClientHeight = 222
  ClientWidth = 346
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 5
    Top = 9
    Width = 79
    Height = 13
    Caption = 'Наименование:'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 190
    Width = 351
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object dbeName: TDBEdit
    Left = 90
    Top = 5
    Width = 251
    Height = 21
    DataField = 'NAME'
    DataSource = dsRegistry
    TabOrder = 0
  end
  object gbRTF: TGroupBox
    Left = 5
    Top = 30
    Width = 336
    Height = 136
    Caption = 'Шаблон'
    TabOrder = 1
    object rbFile: TRadioButton
      Left = 5
      Top = 15
      Width = 211
      Height = 17
      Caption = 'Привязка шалона к файлу'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object dbeFileName: TDBEdit
      Left = 5
      Top = 35
      Width = 326
      Height = 21
      DataField = 'FILENAME'
      DataSource = dsRegistry
      TabOrder = 1
    end
    object rbData: TRadioButton
      Left = 5
      Top = 85
      Width = 211
      Height = 17
      Caption = 'Привязка к базе данных'
      TabOrder = 3
    end
    object btnAddData: TButton
      Left = 5
      Top = 105
      Width = 106
      Height = 23
      Action = actAddData
      TabOrder = 4
    end
    object bntEditRTF: TButton
      Left = 115
      Top = 105
      Width = 106
      Height = 23
      Action = actEditRTF
      TabOrder = 5
    end
    object btnAddFile: TButton
      Left = 5
      Top = 60
      Width = 106
      Height = 23
      Action = actAddFile
      TabOrder = 2
    end
  end
  object btnAccess: TButton
    Left = 5
    Top = 196
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Доступ'
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 187
    Top = 196
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'ОK'
    Default = True
    ModalResult = 1
    TabOrder = 5
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 267
    Top = 196
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 6
  end
  object dbcbRegistry: TDBCheckBox
    Left = 5
    Top = 170
    Width = 60
    Height = 17
    Caption = 'Реестр'
    DataField = 'ISREGISTRY'
    DataSource = dsRegistry
    TabOrder = 3
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbcbIsQuick: TDBCheckBox
    Left = 67
    Top = 170
    Width = 105
    Height = 17
    Caption = 'Быстрый отчет'
    DataField = 'ISQUICK'
    DataSource = dsRegistry
    TabOrder = 4
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbcbPrintPreview: TDBCheckBox
    Left = 176
    Top = 170
    Width = 163
    Height = 17
    Caption = 'Предварительный просмотр'
    DataField = 'isPrintPreview'
    DataSource = dsRegistry
    TabOrder = 7
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object alNew: TActionList
    Left = 265
    Top = 115
    object actAddFile: TAction
      Caption = 'Путь к файлу ...'
      OnExecute = actAddFileExecute
      OnUpdate = actAddFileUpdate
    end
    object actAddData: TAction
      Caption = 'Привязать ...'
      OnExecute = actAddDataExecute
      OnUpdate = actAddDataUpdate
    end
    object actEditRTF: TAction
      Caption = 'Изменить шалон ...'
      OnExecute = actEditRTFExecute
      OnUpdate = actEditRTFUpdate
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 235
    Top = 115
  end
  object dsRegistry: TDataSource
    DataSet = qryRegistry
    Left = 295
    Top = 115
  end
  object qryRegistry: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT *'
      'FROM RP_REGISTRY  WHERE id = :id')
    UpdateObject = ibusRegistry
    Left = 325
    Top = 115
    ParamData = <
      item
        DataType = ftInteger
        Name = 'id'
        ParamType = ptUnknown
        Value = 0
      end>
  end
  object ibusRegistry: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  PARENT,'
      '  NAME,'
      '  FILENAME,'
      '  HOTKEY,'
      '  ISQUICK,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  RESERVED,'
      '  ISREGISTRY,'
      '  ISPRINTPREVIEW,'
      '  TEMPLATE'
      'from RP_REGISTRY '
      'where'
      '  ID = :ID')
    ModifySQL.Strings = (
      'update RP_REGISTRY'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  NAME = :NAME,'
      '  FILENAME = :FILENAME,'
      '  HOTKEY = :HOTKEY,'
      '  ISQUICK = :ISQUICK,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  RESERVED = :RESERVED,'
      '  ISREGISTRY = :ISREGISTRY,'
      '  TEMPLATE = :TEMPLATE,'
      '  ISPRINTPREVIEW = :ISPRINTPREVIEW'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into RP_REGISTRY'
      
        '  (ID, PARENT, NAME, FILENAME, HOTKEY, ISQUICK, AFULL, ACHAG, AV' +
        'IEW, '
      'RESERVED, '
      '   ISREGISTRY, TEMPLATE, ISPRINTPREVIEW)'
      'values'
      
        '  (:ID, :PARENT, :NAME, :FILENAME, :HOTKEY, :ISQUICK, :AFULL, :A' +
        'CHAG, '
      ':AVIEW, '
      '   :RESERVED, :ISREGISTRY, :TEMPLATE, :ISPRINTPREVIEW)')
    DeleteSQL.Strings = (
      'delete from RP_REGISTRY'
      'where'
      '  ID = :OLD_ID')
    Left = 355
    Top = 115
  end
  object OpenDialog: TOpenDialog
    Filter = '*.rtf|*.rtf'
    Left = 175
    Top = 115
  end
end
