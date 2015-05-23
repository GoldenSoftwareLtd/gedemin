inherited gdc_dlgAttrUserDefinedTree: Tgdc_dlgAttrUserDefinedTree
  Left = 482
  Top = 446
  HorzScrollBar.Range = 0
  VertScrollBar.Range = 0
  AutoScroll = False
  Caption = 'gdc_dlgAttrUserDefinedTree'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    TabOrder = 3
  end
  inherited btnNew: TButton
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 328
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 402
    TabOrder = 2
  end
  inherited pnlMain: TPanel
    Height = 278
    object lblParent: TLabel [0]
      Left = 5
      Top = 9
      Width = 50
      Height = 13
      Caption = '¬ходит в:'
    end
    inherited atAttributes: TatContainer
      Top = 27
      Width = 476
      Height = 241
      Align = alNone
      TabOrder = 1
    end
    object gsiblkupParent: TgsIBLookupComboBox
      Left = 68
      Top = 5
      Width = 207
      Height = 21
      HelpContext = 1
      Transaction = ibtrCommon
      DataSource = dsgdcBase
      DataField = 'PARENT'
      ItemHeight = 13
      TabOrder = 0
    end
  end
  inherited alBase: TActionList
    Top = 71
  end
  inherited dsgdcBase: TDataSource
    Top = 63
  end
end
