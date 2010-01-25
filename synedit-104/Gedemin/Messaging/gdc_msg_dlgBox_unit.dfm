inherited gdc_msg_dlgBox: Tgdc_msg_dlgBox
  Left = 247
  Top = 194
  Caption = 'Почтовый ящик'
  ClientHeight = 214
  ClientWidth = 356
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 270
    Top = 130
    TabOrder = 5
  end
  inherited btnNew: TButton
    Left = 270
    Top = 70
    TabOrder = 3
  end
  inherited btnOK: TButton
    Top = 10
  end
  inherited btnCancel: TButton
    Left = 270
    Top = 40
  end
  inherited btnHelp: TButton
    Left = 270
    Top = 100
    TabOrder = 4
  end
  inherited pgcMain: TPageControl
    Width = 253
    Height = 203
    inherited tbsMain: TTabSheet
      object lblName: TLabel
        Left = 8
        Top = 32
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object lblBox: TLabel
        Left = 8
        Top = 80
        Width = 133
        Height = 13
        Caption = 'Входит в почтовый ящик:'
      end
      object dbedName: TDBEdit
        Left = 8
        Top = 48
        Width = 225
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object iblkupBox: TgsIBLookupComboBox
        Left = 8
        Top = 96
        Width = 225
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'PARENT'
        ListTable = 'MSG_BOX'
        ListField = 'NAME'
        KeyField = 'ID'
        gdClassName = 'TgdcMessageBox'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 245
        Height = 175
      end
    end
  end
  inherited alBase: TActionList
    Top = 175
  end
  inherited dsgdcBase: TDataSource
    Top = 175
  end
  inherited ibtrCommon: TIBTransaction
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Left = 144
    Top = 176
  end
end
