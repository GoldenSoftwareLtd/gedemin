object dlgChooseDocument: TdlgChooseDocument
  Left = 244
  Top = 106
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор документов в операцию'
  ClientHeight = 403
  ClientWidth = 395
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object gsibgrDocumentType: TgsIBGrid
    Left = 8
    Top = 16
    Width = 289
    Height = 373
    DataSource = dsDocumentType
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.DisplayField = 'NAME'
    CheckBox.FieldName = 'ID'
    CheckBox.Visible = True
    CheckBox.FirstColumn = False
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
    Columns = <
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'ID'
        Title.Caption = 'ID'
        Width = -1
        Visible = False
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'PARENT'
        Title.Caption = 'PARENT'
        Width = -1
        Visible = False
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'LB'
        Title.Caption = 'LB'
        Width = -1
        Visible = False
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'RB'
        Title.Caption = 'RB'
        Width = -1
        Visible = False
      end
      item
        Alignment = taLeftJustify
        Expanded = False
        FieldName = 'NAME'
        Title.Caption = 'Наименование'
        Width = 270
        Visible = True
      end
      item
        Alignment = taLeftJustify
        Expanded = False
        FieldName = 'DESCRIPTION'
        Title.Caption = 'DESCRIPTION'
        Width = -1
        Visible = False
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'AFULL'
        Title.Caption = 'AFULL'
        Width = -1
        Visible = False
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'ACHAG'
        Title.Caption = 'ACHAG'
        Width = -1
        Visible = False
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'AVIEW'
        Title.Caption = 'AVIEW'
        Width = -1
        Visible = False
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'DISABLED'
        Title.Caption = 'DISABLED'
        Width = -1
        Visible = False
      end
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'RESERVED'
        Title.Caption = 'RESERVED'
        Width = -1
        Visible = False
      end>
  end
  object bOk: TButton
    Left = 309
    Top = 16
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 310
    Top = 47
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object ibdsDocumentType: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGenUniqueID
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT * FROM gd_documenttype')
    Left = 136
    Top = 56
    object ibdsDocumentTypeID: TIntegerField
      FieldName = 'ID'
      Required = True
      Visible = False
    end
    object ibdsDocumentTypePARENT: TIntegerField
      FieldName = 'PARENT'
      Visible = False
    end
    object ibdsDocumentTypeLB: TIntegerField
      FieldName = 'LB'
      Required = True
      Visible = False
    end
    object ibdsDocumentTypeRB: TIntegerField
      FieldName = 'RB'
      Required = True
      Visible = False
    end
    object ibdsDocumentTypeNAME: TIBStringField
      DisplayLabel = 'Наименование'
      FieldName = 'NAME'
      Required = True
      Size = 60
    end
    object ibdsDocumentTypeDESCRIPTION: TIBStringField
      FieldName = 'DESCRIPTION'
      Visible = False
      Size = 180
    end
    object ibdsDocumentTypeAFULL: TIntegerField
      FieldName = 'AFULL'
      Required = True
      Visible = False
    end
    object ibdsDocumentTypeACHAG: TIntegerField
      FieldName = 'ACHAG'
      Required = True
      Visible = False
    end
    object ibdsDocumentTypeAVIEW: TIntegerField
      FieldName = 'AVIEW'
      Required = True
      Visible = False
    end
    object ibdsDocumentTypeDISABLED: TSmallintField
      FieldName = 'DISABLED'
      Visible = False
    end
    object ibdsDocumentTypeRESERVED: TIntegerField
      FieldName = 'RESERVED'
      Visible = False
    end
  end
  object dsDocumentType: TDataSource
    DataSet = ibdsDocumentType
    Left = 168
    Top = 56
  end
end
