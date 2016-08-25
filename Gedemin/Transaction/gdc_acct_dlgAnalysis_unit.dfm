inherited gdc_acct_dlgAnalysis: Tgdc_acct_dlgAnalysis
  Left = 359
  Top = 397
  HelpContext = 161
  BorderWidth = 5
  Caption = 'Добавление поля для аналитического учета'
  ClientHeight = 140
  ClientWidth = 414
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'Tahoma'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 5
    Top = 9
    Width = 120
    Height = 13
    Caption = 'Наименование домена:'
  end
  object Label2: TLabel [1]
    Left = 5
    Top = 61
    Width = 106
    Height = 13
    Caption = 'Наименование поля:'
  end
  object Label3: TLabel [2]
    Left = 5
    Top = 88
    Width = 122
    Height = 13
    Caption = 'Краткое наименование:'
  end
  object Label4: TLabel [3]
    Left = 5
    Top = 35
    Width = 119
    Height = 13
    Caption = 'Наименование поля IB:'
  end
  object Bevel1: TBevel [4]
    Left = 0
    Top = 112
    Width = 414
    Height = 28
    Align = alBottom
    Shape = bsTopLine
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 119
    Anchors = [akLeft, akBottom]
    TabOrder = 6
  end
  inherited btnNew: TButton
    Left = 72
    Top = 119
    Anchors = [akLeft, akBottom]
    TabOrder = 7
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 119
    Anchors = [akLeft, akBottom]
    TabOrder = 8
  end
  inherited btnOK: TButton
    Left = 276
    Top = 119
    Anchors = []
    TabOrder = 4
  end
  inherited btnCancel: TButton
    Left = 346
    Top = 119
    Anchors = []
    TabOrder = 5
  end
  object iblcFields: TgsIBLookupComboBox [10]
    Left = 141
    Top = 5
    Width = 271
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    Fields = 'FIELDNAME'
    ListTable = 
      'AT_FIELDS Z JOIN RDB$FIELDS R ON R.RDB$FIELD_NAME = Z.FIELDNAME ' +
      'AND R.RDB$NULL_FLAG IS NULL'
    ListField = 'LNAME'
    KeyField = 'ID'
    Condition = 
      'R.RDB$FIELD_NAME NOT LIKE '#39'RDB$%'#39' AND Z.SETTABLEKEY IS NULL AND ' +
      'Z.NUMERATION IS NULL'
    gdClassName = 'TgdcField'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object edLName: TEdit [11]
    Left = 141
    Top = 57
    Width = 271
    Height = 21
    TabOrder = 2
  end
  object edLShortName: TEdit [12]
    Left = 141
    Top = 84
    Width = 271
    Height = 21
    TabOrder = 3
  end
  object edFieldIB: TEdit [13]
    Left = 141
    Top = 31
    Width = 271
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 1
  end
  inherited alBase: TActionList
    Left = 262
    Top = 31
  end
  inherited dsgdcBase: TDataSource
    Left = 232
    Top = 31
  end
  inherited pm_dlgG: TPopupMenu
    Left = 304
    Top = 32
  end
  object gdcTable: TgdcTable
    SubSet = 'ByRelationName'
    Left = 24
    Top = 24
  end
  object gdcTableField: TgdcTableField
    MasterSource = dsMeta
    MasterField = 'ID'
    DetailField = 'RELATIONKEY'
    SubSet = 'ByRelation'
    Left = 56
    Top = 24
  end
  object dsMeta: TDataSource
    DataSet = gdcTable
    Left = 24
    Top = 56
  end
end
