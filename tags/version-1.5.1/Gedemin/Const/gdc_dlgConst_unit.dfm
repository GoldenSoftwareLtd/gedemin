inherited gdc_dlgConst: Tgdc_dlgConst
  Left = 348
  Top = 236
  HelpContext = 129
  Caption = 'Константа'
  ClientHeight = 207
  ClientWidth = 441
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 365
    Top = 95
  end
  inherited btnNew: TButton
    Left = 365
    Top = 138
  end
  inherited btnOK: TButton
    Left = 365
    Top = 10
  end
  inherited btnCancel: TButton
    Left = 365
    Top = 53
  end
  inherited btnHelp: TButton
    Left = 365
    Top = 180
  end
  inherited pgcMain: TPageControl
    Left = 6
    Top = 8
    Width = 349
    Height = 193
    inherited tbsMain: TTabSheet
      inherited dbtxtID: TDBText
        Left = 104
      end
      object Label1: TLabel
        Left = 8
        Top = 33
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object Label2: TLabel
        Left = 8
        Top = 58
        Width = 53
        Height = 13
        Caption = 'Описание:'
      end
      object Label3: TLabel
        Left = 8
        Top = 134
        Width = 64
        Height = 13
        Caption = 'Тип данных:'
      end
      object dbeName: TDBEdit
        Left = 104
        Top = 29
        Width = 225
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbeComment: TDBEdit
        Left = 104
        Top = 54
        Width = 225
        Height = 21
        DataField = 'COMMENT'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object cbisPeriod: TCheckBox
        Left = 104
        Top = 79
        Width = 306
        Height = 17
        Caption = 'Периодическая'
        TabOrder = 2
      end
      object cbisUser: TCheckBox
        Left = 104
        Top = 94
        Width = 306
        Height = 17
        Caption = 'Привязана к пользователю'
        TabOrder = 3
      end
      object cbisCompany: TCheckBox
        Left = 104
        Top = 110
        Width = 306
        Height = 17
        Caption = 'Привязана к организации'
        TabOrder = 4
      end
      object rgDataType: TRadioGroup
        Left = 104
        Top = 127
        Width = 225
        Height = 33
        Columns = 3
        ItemIndex = 0
        Items.Strings = (
          'Строка'
          'Число'
          'Дата')
        TabOrder = 5
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 341
        Height = 135
      end
    end
  end
  inherited alBase: TActionList
    Left = 286
    Top = 39
  end
  inherited dsgdcBase: TDataSource
    Left = 256
    Top = 39
  end
  inherited pm_dlgG: TPopupMenu
    Left = 184
    Top = 40
  end
  inherited ibtrCommon: TIBTransaction
    Left = 224
    Top = 40
  end
end
