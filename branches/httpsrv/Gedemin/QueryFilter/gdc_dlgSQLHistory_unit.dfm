inherited gdc_dlgSQLHistory: Tgdc_dlgSQLHistory
  Left = 263
  Top = 293
  Caption = 'gdc_dlgSQLHistory'
  ClientHeight = 419
  ClientWidth = 573
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 392
  end
  inherited btnNew: TButton
    Left = 78
    Top = 392
  end
  inherited btnHelp: TButton
    Left = 152
    Top = 392
  end
  inherited btnOK: TButton
    Left = 427
    Top = 392
  end
  inherited btnCancel: TButton
    Left = 501
    Top = 392
  end
  inherited pgcMain: TPageControl
    Left = 5
    Width = 564
    Height = 379
    inherited tbsMain: TTabSheet
      object Label1: TLabel
        Left = 467
        Top = 8
        Width = 36
        Height = 13
        Caption = 'Метка:'
      end
      object dbmSQL: TDBMemo
        Left = 7
        Top = 30
        Width = 541
        Height = 315
        DataField = 'SQL_TEXT'
        DataSource = dsgdcBase
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object dbedBM: TDBEdit
        Left = 507
        Top = 4
        Width = 41
        Height = 21
        DataField = 'BOOKMARK'
        DataSource = dsgdcBase
        TabOrder = 1
      end
    end
    object tsParams: TTabSheet [1]
      Caption = 'Параметры'
      ImageIndex = 2
      object dbmParams: TDBMemo
        Left = 7
        Top = 8
        Width = 541
        Height = 337
        DataField = 'SQL_PARAMS'
        DataSource = dsgdcBase
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 556
        Height = 351
      end
    end
  end
end
