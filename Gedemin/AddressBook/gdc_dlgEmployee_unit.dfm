inherited gdc_dlgEmployee: Tgdc_dlgEmployee
  Left = 193
  Top = 173
  HelpContext = 37
  Caption = 'Сотрудник предприятия'
  ClientHeight = 373
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited pgcMain: TPageControl
    inherited tbsMain: TTabSheet
      inherited Label3: TLabel
        Left = 225
        Width = 84
        Caption = 'Подразделение:'
      end
      inherited Label63: TLabel
        Left = 3
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
      inherited Label29: TLabel
        Visible = False
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
