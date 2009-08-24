object frmChooseAccount: TfrmChooseAccount
  Left = 244
  Top = 103
  Width = 463
  Height = 464
  Caption = 'Выбор счета'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 361
    Height = 437
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object gsibgrAccount: TgsIBGrid
      Left = 5
      Top = 5
      Width = 351
      Height = 427
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsAccount
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
      ReadOnly = True
      TabOrder = 0
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.DisplayField = 'ALIAS'
      CheckBox.FieldName = 'ID'
      CheckBox.Visible = True
      MinColWidth = 40
    end
  end
  object Panel2: TPanel
    Left = 361
    Top = 0
    Width = 94
    Height = 437
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object bCancel: TButton
      Left = 10
      Top = 37
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 0
    end
    object bOk: TButton
      Left = 10
      Top = 7
      Width = 75
      Height = 25
      Caption = 'ОК'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
  end
  object ibdsAccount: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT ID, Alias, Name FROM gd_cardaccount'
      'WHERE grade >= 2'
      'ORDER BY Alias')
    Left = 224
    Top = 104
    object ibdsAccountID: TIntegerField
      FieldName = 'ID'
      Required = True
      Visible = False
    end
    object ibdsAccountALIAS: TIBStringField
      DisplayLabel = 'Счет'
      DisplayWidth = 12
      FieldName = 'ALIAS'
    end
    object ibdsAccountNAME: TIBStringField
      DisplayLabel = 'Наименование'
      DisplayWidth = 50
      FieldName = 'NAME'
      Size = 180
    end
  end
  object dsAccount: TDataSource
    DataSet = ibdsAccount
    Left = 224
    Top = 136
  end
end
