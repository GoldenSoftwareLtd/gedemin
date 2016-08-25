object Form1: TForm1
  Left = 279
  Top = 122
  Width = 475
  Height = 377
  Caption = 'Список складских документов'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ibMain: TgsIBGrid
    Left = 0
    Top = 0
    Width = 467
    Height = 271
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsMain
    TabOrder = 0
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    MinColWidth = 40
    ColumnEditors = <
      item
        EditorStyle = cesNone
        DropDownCount = 8
      end>
    Aliases = <>
  end
  object btnNew: TButton
    Left = 10
    Top = 284
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnNew'
    TabOrder = 1
    OnClick = btnNewClick
  end
  object btnEdit: TButton
    Left = 100
    Top = 284
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnEdit'
    TabOrder = 2
    OnClick = btnEditClick
  end
  object btnDelete: TButton
    Left = 190
    Top = 284
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnDelete'
    TabOrder = 3
    OnClick = btnDeleteClick
  end
  object btnDocument: TButton
    Left = 280
    Top = 284
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnDocument'
    TabOrder = 4
    OnClick = btnDocumentClick
  end
  object btnAttribute: TButton
    Left = 370
    Top = 284
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnAttribute'
    TabOrder = 5
    OnClick = btnAttributeClick
  end
  object btnRestart: TButton
    Left = 370
    Top = 314
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnRestart'
    TabOrder = 6
    OnClick = btnRestartClick
  end
  object btnShutdown: TButton
    Left = 280
    Top = 314
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnShutdown'
    TabOrder = 7
    OnClick = btnShutdownClick
  end
  object btnDisconnect: TButton
    Left = 190
    Top = 314
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnDisconnect'
    TabOrder = 8
    OnClick = btnDisconnectClick
  end
  object btnConnect: TButton
    Left = 100
    Top = 314
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnConnect'
    TabOrder = 9
    OnClick = btnConnectClick
  end
  object btnReopen: TButton
    Left = 10
    Top = 314
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'btnReopen'
    TabOrder = 10
    OnClick = btnReopenClick
  end
  object dsMain: TDataSource
    Left = 30
    Top = 20
  end
end
