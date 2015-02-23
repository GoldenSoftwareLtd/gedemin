inherited gdc_dlgRplDatabase: Tgdc_dlgRplDatabase
  Left = 374
  Top = 473
  Caption = 'gdc_dlgRplDatabase'
  ClientHeight = 170
  ClientWidth = 425
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 142
  end
  inherited btnNew: TButton
    Top = 142
  end
  inherited btnHelp: TButton
    Top = 142
  end
  inherited btnOK: TButton
    Left = 275
    Top = 142
  end
  inherited btnCancel: TButton
    Left = 349
    Top = 142
  end
  inherited pgcMain: TPageControl
    Width = 414
    Height = 129
    inherited tbsMain: TTabSheet
      object Label1: TLabel
        Left = 8
        Top = 33
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object Label2: TLabel
        Left = 8
        Top = 56
        Width = 134
        Height = 13
        Caption = 'Параметры подключения:'
      end
      object DBEdit1: TDBEdit
        Left = 96
        Top = 29
        Width = 305
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object DBEdit2: TDBEdit
        Left = 8
        Top = 72
        Width = 393
        Height = 21
        DataField = 'CONNECTION_DATA'
        DataSource = dsgdcBase
        TabOrder = 1
      end
    end
  end
  inherited alBase: TActionList
    Left = 278
    Top = 31
  end
  inherited dsgdcBase: TDataSource
    Left = 240
    Top = 31
  end
  inherited pm_dlgG: TPopupMenu
    Left = 312
    Top = 31
  end
  inherited ibtrCommon: TIBTransaction
    Left = 352
    Top = 31
  end
end
