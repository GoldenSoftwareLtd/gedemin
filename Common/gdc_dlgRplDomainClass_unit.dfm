inherited gdc_dlgRplDomainClass: Tgdc_dlgRplDomainClass
  Left = 374
  Top = 473
  Caption = 'gdc_dlgRplDomainClass'
  ClientHeight = 276
  ClientWidth = 425
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 250
  end
  inherited btnNew: TButton
    Top = 250
  end
  inherited btnHelp: TButton
    Top = 250
  end
  inherited btnOK: TButton
    Left = 275
    Top = 250
  end
  inherited btnCancel: TButton
    Left = 349
    Top = 250
  end
  inherited pgcMain: TPageControl
    Width = 414
    Height = 236
    inherited tbsMain: TTabSheet
      object Label1: TLabel
        Left = 8
        Top = 30
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object Label2: TLabel
        Left = 8
        Top = 50
        Width = 60
        Height = 13
        Caption = 'Имя класса:'
      end
      object Label3: TLabel
        Left = 8
        Top = 89
        Width = 42
        Height = 13
        Caption = 'Подтип:'
      end
      object Label4: TLabel
        Left = 8
        Top = 129
        Width = 46
        Height = 13
        Caption = 'Таблица:'
      end
      object Label5: TLabel
        Left = 8
        Top = 168
        Width = 46
        Height = 13
        Caption = 'Условие:'
      end
      object DBEdit1: TDBEdit
        Left = 96
        Top = 25
        Width = 305
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object DBEdit2: TDBEdit
        Left = 8
        Top = 65
        Width = 393
        Height = 21
        DataField = 'CLASSNAME'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object DBEdit3: TDBEdit
        Left = 8
        Top = 105
        Width = 393
        Height = 21
        DataField = 'SUBTYPE'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object DBEdit4: TDBEdit
        Left = 8
        Top = 144
        Width = 393
        Height = 21
        DataField = 'TABLENAME'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object DBEdit5: TDBEdit
        Left = 8
        Top = 184
        Width = 393
        Height = 21
        DataField = 'CONDITION'
        DataSource = dsgdcBase
        TabOrder = 4
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
