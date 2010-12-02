inherited gdc_dlgUserDocumentSetup: Tgdc_dlgUserDocumentSetup
  Left = 480
  Top = 223
  Caption = 'Документ пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
  end
  inherited btnNew: TButton
    Left = 77
  end
  inherited btnHelp: TButton
    Left = 149
  end
  inherited pcMain: TPageControl
    inherited tsCommon: TTabSheet
      inherited edDocumentName: TDBEdit
        Color = clWindow
        Enabled = True
      end
      inherited edDescription: TDBMemo
        Color = clWindow
        Enabled = True
      end
      inherited iblcExplorerBranch: TgsIBLookupComboBox
        Color = clWindow
        Enabled = True
      end
      inherited iblcHeaderTable: TgsIBLookupComboBox
        Color = clWindow
        Enabled = True
      end
      inherited iblcLineTable: TgsIBLookupComboBox
        Color = clWindow
        Enabled = True
      end
      inherited edEnglishName: TEdit
        Color = clWindow
        Enabled = True
      end
    end
  end
  inherited alBase: TActionList
    Left = 80
    Top = 127
    object actNewField: TAction [15]
      Category = 'Master'
      Caption = 'Добавить поле'
      ImageIndex = 0
    end
    object actEditField: TAction [16]
      Category = 'Master'
      Caption = 'Редактировать поле'
      ImageIndex = 1
    end
    object actDeleteField: TAction [17]
      Category = 'Master'
      Caption = 'Удалить поле'
      ImageIndex = 2
    end
    object actNewFieldDetail: TAction [18]
      Category = 'Detail'
      Caption = 'Добавить поле'
      ImageIndex = 0
    end
    object actEditFieldDetail: TAction [19]
      Category = 'Detail'
      Caption = 'Редактировать поле'
      ImageIndex = 1
    end
    object actDeleteFieldDetail: TAction [20]
      Category = 'Detail'
      Caption = 'Удалить поле'
      ImageIndex = 2
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 50
    Top = 127
  end
  inherited pm_dlgG: TPopupMenu
    Left = 480
    Top = 128
  end
  inherited ibtrCommon: TIBTransaction
    Left = 112
    Top = 128
  end
  inherited gdcFunctionHeader: TgdcFunction
    Left = 502
    Top = 281
  end
  inherited dsFunction: TDataSource
    Left = 470
    Top = 281
  end
end
