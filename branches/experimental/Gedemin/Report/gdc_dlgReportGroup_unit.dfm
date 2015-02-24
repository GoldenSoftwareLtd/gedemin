inherited gdc_dlgReportGroup: Tgdc_dlgReportGroup
  Left = 157
  Top = 182
  Caption = 'Папка отчетов'
  ClientHeight = 214
  ClientWidth = 420
  PixelsPerInch = 120
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 189
  end
  inherited btnNew: TButton
    Top = 189
  end
  inherited btnOK: TButton
    Left = 273
    Top = 189
  end
  inherited btnCancel: TButton
    Left = 345
    Top = 189
  end
  inherited btnHelp: TButton
    Top = 189
  end
  inherited pgcMain: TPageControl
    Width = 413
    Height = 171
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 9
        Top = 5
      end
      inherited dbtxtID: TDBText
        Left = 153
        Top = 5
      end
      object Label1: TLabel
        Left = 9
        Top = 27
        Width = 106
        Height = 13
        Caption = 'Наименование папки'
      end
      object Label2: TLabel
        Left = 9
        Top = 51
        Width = 49
        Height = 13
        Caption = 'Описание'
      end
      object Label3: TLabel
        Left = 9
        Top = 115
        Width = 79
        Height = 13
        Caption = 'Входит в папку'
      end
      object DBEdit1: TDBEdit
        Left = 152
        Top = 24
        Width = 249
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object DBMemo1: TDBMemo
        Left = 152
        Top = 48
        Width = 249
        Height = 61
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object gsIBLookupComboBox1: TgsIBLookupComboBox
        Left = 152
        Top = 112
        Width = 249
        Height = 21
        DataSource = dsgdcBase
        DataField = 'PARENT'
        ListTable = 'RP_REPORTGROUP'
        ListField = 'NAME'
        KeyField = 'ID'
        ItemHeight = 13
        TabOrder = 2
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 405
        Height = 143
      end
    end
  end
  inherited alBase: TActionList
    Left = 110
    Top = 7
  end
  inherited dsgdcBase: TDataSource
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 144
    Top = 8
  end
  inherited ibtrCommon: TIBTransaction
    Left = 176
    Top = 8
  end
end
