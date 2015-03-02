inherited gdc_dlgUserSimpleDocument: Tgdc_dlgUserSimpleDocument
  Left = 251
  Top = 166
  Caption = 'gdc_dlgUserSimpleDocument'
  ClientHeight = 342
  ClientWidth = 519
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 2
    Top = 313
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 74
    Top = 313
    TabOrder = 5
  end
  inherited btnHelp: TButton
    Left = 146
    Top = 313
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 373
    Top = 313
    TabOrder = 2
  end
  inherited btnCancel: TButton
    Left = 445
    Top = 313
    TabOrder = 3
  end
  object atContainer: TatContainer [5]
    Left = 0
    Top = 25
    Width = 519
    Height = 278
    DataSource = dsgdcBase
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    TabOrder = 0
    OnRelationNames = atContainerRelationNames
  end
  object pnlHolding: TPanel [6]
    Left = 0
    Top = 0
    Width = 519
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblCompany: TLabel
      Left = 8
      Top = 5
      Width = 53
      Height = 13
      Caption = 'Компания:'
    end
    object iblkCompany: TgsIBLookupComboBox
      Left = 88
      Top = 2
      Width = 193
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrCommon
      DataSource = dsgdcBase
      DataField = 'companykey'
      ListTable = 'gd_contact'
      ListField = 'name'
      KeyField = 'ID'
      Condition = 
        'exists (select companykey from gd_ourcompany where companykey=gd' +
        '_contact.id)'
      gdClassName = 'TgdcOurCompany'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  inherited alBase: TActionList
    Left = 166
    Top = 119
  end
  inherited dsgdcBase: TDataSource
    Left = 72
    Top = 151
  end
  inherited pm_dlgG: TPopupMenu
    Left = 144
    Top = 128
  end
  inherited ibtrCommon: TIBTransaction
    Left = 104
    Top = 144
  end
end
