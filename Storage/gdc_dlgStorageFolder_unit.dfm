inherited gdc_dlgStorageFolder: Tgdc_dlgStorageFolder
  Left = 281
  Top = 181
  Caption = 'gdc_dlgStorageFolder'
  ClientHeight = 162
  ClientWidth = 434
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 134
  end
  inherited btnNew: TButton
    Top = 134
  end
  inherited btnHelp: TButton
    Top = 134
  end
  inherited btnOK: TButton
    Left = 280
    Top = 134
  end
  inherited btnCancel: TButton
    Top = 134
  end
  inherited pgcMain: TPageControl
    Height = 117
    inherited tbsMain: TTabSheet
      inherited dbtxtID: TDBText
        Left = 100
      end
      object Label1: TLabel
        Left = 8
        Top = 32
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object dbedName: TDBEdit
        Left = 99
        Top = 29
        Width = 302
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object btnOpenObject: TButton
        Left = 100
        Top = 56
        Width = 145
        Height = 21
        Action = actOpenObject
        TabOrder = 1
      end
    end
  end
  inherited alBase: TActionList
    Left = 318
    Top = 7
    object actOpenObject: TAction
      Caption = 'Открыть объект...'
      OnExecute = actOpenObjectExecute
      OnUpdate = actOpenObjectUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 288
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 347
    Top = 7
  end
  inherited ibtrCommon: TIBTransaction
    Top = 7
  end
end
