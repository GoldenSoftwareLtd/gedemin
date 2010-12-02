inherited gdc_dlgEmployee: Tgdc_dlgEmployee
  Left = 193
  Top = 173
  HelpContext = 37
  Caption = 'Сотрудник предприятия'
  ClientHeight = 373
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited pgcMain: TPageControl
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Width = 37
      end
      inherited Label6: TLabel
        Width = 25
      end
      inherited Label8: TLabel
        Width = 34
      end
      inherited Label9: TLabel
        Width = 50
      end
      inherited Label10: TLabel
        Width = 52
      end
      inherited Label7: TLabel
        Width = 45
      end
      inherited Label3: TLabel
        Left = 225
        Width = 83
        Caption = 'Подразделение:'
      end
      inherited Label32: TLabel
        Width = 32
      end
      inherited Label16: TLabel
        Width = 39
      end
      inherited Label21: TLabel
        Width = 58
      end
      inherited Label44: TLabel
        Width = 91
      end
      inherited Label22: TLabel
        Width = 144
      end
      inherited Label14: TLabel
        Width = 34
      end
      inherited Label17: TLabel
        Width = 36
      end
      inherited Label39: TLabel
        Width = 73
      end
      inherited Label63: TLabel
        Left = 3
      end
      inherited dbcbDisabled: TDBCheckBox
        DataSource = dsgdcBase
      end
      inherited gsibluFolder: TgsIBLookupComboBox
        Left = 224
        Condition = ''
        gdClassName = 'TgdcDepartment'
        OnCreateNewObject = gsibluFolderCreateNewObject
        OnAfterCreateDialog = gsibluFolderAfterCreateDialog
        ViewType = vtTree
        TabOrder = 8
      end
      inherited gsIBlcWCompanyKey: TgsIBLookupComboBox
        Left = 3
        TabOrder = 7
        OnChange = gsIBlcWCompanyKeyChange
      end
    end
    inherited TabSheet2: TTabSheet
      inherited Label12: TLabel
        Width = 144
      end
      inherited Label36: TLabel
        Width = 39
      end
      inherited Label40: TLabel
        Width = 46
      end
      inherited Label42: TLabel
        Width = 90
      end
      inherited Label45: TLabel
        Width = 34
      end
      inherited Label29: TLabel
        Width = 34
        Visible = False
      end
      inherited Label4: TLabel
        Width = 37
      end
      inherited Label5: TLabel
        Width = 78
      end
      inherited Label11: TLabel
        Width = 69
      end
      inherited Label23: TLabel
        Width = 56
      end
      inherited Label24: TLabel
        Width = 75
      end
      inherited Label13: TLabel
        Width = 77
      end
      inherited Label35: TLabel
        Width = 49
      end
      inherited Label2: TLabel
        Width = 29
      end
      inherited Label38: TLabel
        Width = 82
      end
      inherited Label26: TLabel
        Width = 88
      end
      inherited dbWDepartment: TDBEdit
        Visible = False
      end
    end
  end
  inherited alBase: TActionList
    inherited actMakeEmployee: TAction
      Caption = 'Физ. лицо'
    end
  end
end
