inherited dlgInvPriceLine: TdlgInvPriceLine
  Caption = 'Позиция прайс-листа'
  OnCreate = nil
  PixelsPerInch = 96
  TextHeight = 13
  object TBevel [0]
    Left = 240
    Top = 144
    Width = 50
    Height = 50
  end
  object Bevel1: TBevel [1]
    Left = 0
    Top = 293
    Width = 529
    Height = 2
    Align = alTop
  end
  inherited btnAccess: TButton
    Top = 305
  end
  inherited btnNew: TButton
    Top = 305
  end
  inherited btnHelp: TButton
    Top = 305
  end
  inherited btnOK: TButton
    Top = 305
  end
  inherited btnCancel: TButton
    Top = 305
  end
  object pnlAttributes: TPanel [7]
    Left = 0
    Top = 0
    Width = 529
    Height = 293
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 5
    object atAttributes: TatContainer
      Left = 1
      Top = 1
      Width = 527
      Height = 291
      DataSource = dsgdcBase
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 0
      OnRelationNames = atAttributesRelationNames
    end
  end
end
