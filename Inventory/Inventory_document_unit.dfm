object frmNewDocument: TfrmNewDocument
  Left = 269
  Top = 131
  Width = 475
  Height = 322
  Caption = 'Складской документ'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 135
    Width = 467
    Height = 6
    Cursor = crVSplit
    Align = alTop
  end
  object ibMaster: TgsIBGrid
    Left = 0
    Top = 0
    Width = 467
    Height = 135
    Align = alTop
    DataSource = dsMaster
    TabOrder = 0
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
  object ibDetail: TgsIBGrid
    Left = 0
    Top = 141
    Width = 467
    Height = 88
    Align = alClient
    DataSource = dsDetail
    TabOrder = 1
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
  object Panel1: TPanel
    Left = 0
    Top = 229
    Width = 467
    Height = 66
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnAdd: TButton
      Left = 10
      Top = 7
      Width = 75
      Height = 24
      Anchors = [akLeft, akBottom]
      Caption = 'btnAdd'
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnEdit: TButton
      Left = 100
      Top = 7
      Width = 75
      Height = 24
      Anchors = [akLeft, akBottom]
      Caption = 'btnEdit'
      TabOrder = 1
      OnClick = btnEditClick
    end
    object btnDelete: TButton
      Left = 190
      Top = 7
      Width = 75
      Height = 24
      Anchors = [akLeft, akBottom]
      Caption = 'btnDelete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object btnAddDetail: TButton
      Left = 10
      Top = 39
      Width = 75
      Height = 24
      Anchors = [akLeft, akBottom]
      Caption = 'btnAddDetail'
      TabOrder = 3
      OnClick = btnAddDetailClick
    end
    object btnEditDetail: TButton
      Left = 100
      Top = 39
      Width = 75
      Height = 24
      Anchors = [akLeft, akBottom]
      Caption = 'btnAddDetail'
      TabOrder = 4
      OnClick = btnEditDetailClick
    end
    object btnDeleteDetail: TButton
      Left = 190
      Top = 39
      Width = 75
      Height = 24
      Anchors = [akLeft, akBottom]
      Caption = 'btnDeleteDetail'
      TabOrder = 5
      OnClick = btnDeleteDetailClick
    end
  end
  object dsMaster: TDataSource
    Left = 60
    Top = 60
  end
  object dsDetail: TDataSource
    Left = 90
    Top = 60
  end
end
