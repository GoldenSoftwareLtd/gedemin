inherited gdc_dlgDocBranch: Tgdc_dlgDocBranch
  Left = 259
  Top = 153
  Caption = 'Ветвь типовых документов'
  ClientHeight = 224
  ClientWidth = 447
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 10
    Top = 8
    Width = 110
    Height = 13
    Caption = 'Наименование ветви:'
  end
  object Label2: TLabel [1]
    Left = 10
    Top = 48
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  object Bevel1: TBevel [2]
    Left = 5
    Top = 178
    Width = 439
    Height = 2
    Anchors = [akLeft, akRight]
  end
  object Label3: TLabel [3]
    Left = 10
    Top = 144
    Width = 50
    Height = 13
    Caption = 'Входит в:'
  end
  inherited btnAccess: TButton
    Left = 8
    Top = 193
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  inherited btnNew: TButton
    Left = 88
    Top = 193
    Anchors = [akLeft, akBottom]
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 285
    Top = 193
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 365
    Top = 193
    Anchors = [akRight, akBottom]
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 168
    Top = 193
    Anchors = [akLeft, akBottom]
    TabOrder = 7
  end
  object dbeBranch: TDBEdit [9]
    Left = 144
    Top = 8
    Width = 291
    Height = 21
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [10]
    Left = 144
    Top = 48
    Width = 291
    Height = 89
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object iblcParent: TgsIBLookupComboBox [11]
    Left = 144
    Top = 144
    Width = 291
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    DataSource = dsgdcBase
    DataField = 'PARENT'
    ListTable = 'gd_documenttype'
    ListField = 'name'
    KeyField = 'id'
    Condition = 'gd_documenttype.documenttype = '#39'B'#39
    gdClassName = 'TgdcDocumentType'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  inherited alBase: TActionList
    Left = 70
    Top = 85
  end
  inherited dsgdcBase: TDataSource
    Left = 40
    Top = 85
  end
  inherited pm_dlgG: TPopupMenu
    Left = 88
    Top = 144
  end
end
