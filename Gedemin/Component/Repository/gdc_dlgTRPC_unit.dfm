inherited gdc_dlgTRPC: Tgdc_dlgTRPC
  Left = 544
  Top = 311
  Caption = 'gdc_dlgTRPC'
  ClientHeight = 306
  ClientWidth = 431
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 4
    Top = 278
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 77
    Top = 278
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 151
    Top = 278
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 284
    Top = 278
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 358
    Top = 278
    TabOrder = 2
  end
  object pgcMain: TPageControl [5]
    Left = 4
    Top = 6
    Width = 422
    Height = 265
    ActivePage = tbsMain
    TabOrder = 0
    OnChange = pgcMainChange
    OnChanging = pgcMainChanging
    object tbsMain: TTabSheet
      Caption = 'Общие'
      object labelID: TLabel
        Left = 8
        Top = 8
        Width = 86
        Height = 13
        Caption = 'Идентификатор:'
      end
      object dbtxtID: TDBText
        Left = 96
        Top = 8
        Width = 65
        Height = 17
        DataField = 'ID'
        DataSource = dsgdcBase
        Transparent = True
      end
    end
    object tbsAttr: TTabSheet
      Caption = 'Атрибуты'
      ImageIndex = 1
      object atcMain: TatContainer
        Left = 0
        Top = 0
        Width = 414
        Height = 237
        DataSource = dsgdcBase
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
      end
    end
  end
  inherited ibtrCommon: TIBTransaction
    Left = 376
  end
end
