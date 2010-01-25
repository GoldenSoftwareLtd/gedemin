inherited gdc_dlgAutoTransaction: Tgdc_dlgAutoTransaction
  Left = 221
  Top = 188
  BorderWidth = 5
  Caption = 'Автоматические операции'
  ClientHeight = 230
  ClientWidth = 412
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 3
    Top = 2
    Width = 85
    Height = 27
    AutoSize = False
    Caption = 'Наименование операции:'
    WordWrap = True
  end
  object Label2: TLabel [1]
    Left = 3
    Top = 37
    Width = 55
    Height = 33
    AutoSize = False
    Caption = 'Описание операции:'
    WordWrap = True
  end
  object Bevel1: TBevel [2]
    Left = -5
    Top = 198
    Width = 417
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object Label3: TLabel [3]
    Left = 3
    Top = 152
    Width = 55
    Height = 12
    AutoSize = False
    Caption = 'Входит в:'
    WordWrap = True
  end
  inherited btnAccess: TButton
    Left = 2
    Top = 208
    Anchors = [akLeft, akBottom]
  end
  inherited btnNew: TButton
    Left = 74
    Top = 208
    Anchors = [akLeft, akBottom]
  end
  inherited btnOK: TButton
    Left = 269
    Top = 208
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Left = 341
    Top = 208
    Anchors = [akRight, akBottom]
  end
  inherited btnHelp: TButton
    Left = 146
    Top = 208
    Anchors = [akLeft, akBottom]
  end
  object dbedName: TDBEdit [9]
    Left = 96
    Top = 3
    Width = 315
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 5
  end
  object dbmDescription: TDBMemo [10]
    Left = 96
    Top = 37
    Width = 315
    Height = 106
    Anchors = [akLeft, akTop, akRight]
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    TabOrder = 6
  end
  object iblcParent: TgsIBLookupComboBox [11]
    Left = 96
    Top = 152
    Width = 313
    Height = 21
    HelpContext = 1
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCommon
    DataSource = dsgdcBase
    DataField = 'PARENT'
    ListTable = 'ac_transaction'
    ListField = 'name'
    KeyField = 'ID'
    gdClassName = 'TgdcAutoTransaction'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
  end
  inherited alBase: TActionList
    Left = 134
    Top = 103
  end
  inherited dsgdcBase: TDataSource
    Left = 96
    Top = 103
  end
  inherited pm_dlgG: TPopupMenu
    Left = 168
    Top = 104
  end
  inherited ibtrCommon: TIBTransaction
    Left = 248
    Top = 96
  end
end
