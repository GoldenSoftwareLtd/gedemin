object dlgChooseDocumentType: TdlgChooseDocumentType
  Left = 218
  Top = 167
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор типа документа'
  ClientHeight = 185
  ClientWidth = 562
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object gsIBGrid1: TgsIBGrid
    Left = 9
    Top = 8
    Width = 457
    Height = 168
    DataSource = dsDocumentType
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
  object bOk: TButton
    Left = 480
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 480
    Top = 37
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    TabOrder = 2
    OnClick = Button2Click
  end
  object ibdsDocumentType: TIBDataSet
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT d.name, d.id FROM '
      '  gd_documenttype d JOIN gd_documenttrtype dt ON '
      '  d.id = dt.documenttypekey AND dt.trtypekey = :tk'
      'ORDER BY d.name')
    Left = 304
    Top = 88
  end
  object dsDocumentType: TDataSource
    DataSet = ibdsDocumentType
    Left = 344
    Top = 88
  end
end
