inherited gdc_dlgFileFolder: Tgdc_dlgFileFolder
  Left = 404
  Top = 262
  Caption = 'Папка'
  ClientHeight = 167
  ClientWidth = 393
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'Tahoma'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 134
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Top = 134
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 241
    Top = 134
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 313
    Top = 134
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Top = 134
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object Panel1: TPanel [5]
    Left = 0
    Top = 0
    Width = 393
    Height = 124
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object GroupBox1: TGroupBox
      Left = 8
      Top = 8
      Width = 377
      Height = 105
      TabOrder = 0
      object Label3: TLabel
        Left = 24
        Top = 83
        Width = 75
        Height = 13
        Caption = 'Размер папки:'
      end
      object Label2: TLabel
        Left = 24
        Top = 59
        Width = 47
        Height = 13
        Caption = 'Входит в:'
      end
      object Label1: TLabel
        Left = 24
        Top = 35
        Width = 79
        Height = 13
        Caption = 'Наименование:'
      end
      object Label4: TLabel
        Left = 24
        Top = 11
        Width = 83
        Height = 13
        Caption = 'Идентификатор:'
      end
      object dbtID: TDBText
        Left = 128
        Top = 11
        Width = 65
        Height = 17
        DataField = 'id'
        DataSource = dsgdcBase
      end
      object lblDataSize: TLabel
        Left = 128
        Top = 83
        Width = 53
        Height = 13
        Caption = 'lblDataSize'
      end
      object lkParent: TgsIBLookupComboBox
        Left = 128
        Top = 59
        Width = 209
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'parent'
        ListTable = 'gd_file'
        ListField = 'name'
        KeyField = 'ID'
        Condition = 'filetype = '#39'D'#39
        gdClassName = 'TgdcFileFolder'
        ViewType = vtTree
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object dbName: TDBEdit
        Left = 128
        Top = 35
        Width = 209
        Height = 21
        DataField = 'name'
        DataSource = dsgdcBase
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Left = 358
    Top = 64
  end
  inherited dsgdcBase: TDataSource
    Left = 320
    Top = 65535
  end
  inherited pm_dlgG: TPopupMenu
    Left = 360
    Top = 32
  end
end
