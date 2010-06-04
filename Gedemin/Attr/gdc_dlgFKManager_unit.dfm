inherited gdc_dlgFKManager: Tgdc_dlgFKManager
  Left = 350
  Top = 202
  Caption = 'gdc_dlgFKManager'
  ClientHeight = 338
  ClientWidth = 384
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 310
  end
  inherited btnNew: TButton
    Top = 310
  end
  inherited btnHelp: TButton
    Top = 310
  end
  inherited btnOK: TButton
    Left = 240
    Top = 310
    Anchors = []
  end
  inherited btnCancel: TButton
    Left = 313
    Top = 310
  end
  inherited pgcMain: TPageControl
    Width = 377
    Height = 296
    inherited tbsMain: TTabSheet
      object Label1: TLabel
        Left = 8
        Top = 37
        Width = 78
        Height = 13
        Caption = 'Внешний ключ:'
      end
      object Label2: TLabel
        Left = 8
        Top = 61
        Width = 55
        Height = 13
        Caption = 'В таблице:'
      end
      object Label3: TLabel
        Left = 8
        Top = 84
        Width = 47
        Height = 13
        Caption = 'По полю:'
      end
      object Label4: TLabel
        Left = 8
        Top = 117
        Width = 102
        Height = 13
        Caption = 'Ссылка на таблицу:'
      end
      object Label5: TLabel
        Left = 8
        Top = 141
        Width = 84
        Height = 13
        Caption = 'Ссылка на поле:'
      end
      object Label6: TLabel
        Left = 8
        Top = 164
        Width = 79
        Height = 13
        Caption = 'При изменении:'
      end
      object Label7: TLabel
        Left = 8
        Top = 188
        Width = 75
        Height = 13
        Caption = 'При удалении:'
      end
      object Label8: TLabel
        Left = 8
        Top = 220
        Width = 58
        Height = 13
        Caption = 'Состояние:'
      end
      object Label9: TLabel
        Left = 8
        Top = 244
        Width = 89
        Height = 13
        Caption = 'Конвертировать:'
      end
      object dbedConstraintName: TDBEdit
        Left = 120
        Top = 32
        Width = 241
        Height = 21
        Color = clBtnFace
        DataField = 'CONSTRAINT_NAME'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object dbedConstraintRel: TDBEdit
        Left = 120
        Top = 56
        Width = 241
        Height = 21
        Color = clBtnFace
        DataField = 'CONSTRAINT_REL'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbedConstraintField: TDBEdit
        Left = 120
        Top = 80
        Width = 241
        Height = 21
        Color = clBtnFace
        DataField = 'CONSTRAINT_FIELD'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbedRefRel: TDBEdit
        Left = 120
        Top = 112
        Width = 241
        Height = 21
        Color = clBtnFace
        DataField = 'REF_REL'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object dbedRefField: TDBEdit
        Left = 120
        Top = 136
        Width = 241
        Height = 21
        Color = clBtnFace
        DataField = 'REF_REL'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object dbedUpdateRule: TDBEdit
        Left = 120
        Top = 160
        Width = 241
        Height = 21
        Color = clBtnFace
        DataField = 'UPDATE_RULE'
        DataSource = dsgdcBase
        TabOrder = 6
      end
      object dbedDeleteRule: TDBEdit
        Left = 120
        Top = 184
        Width = 241
        Height = 21
        Color = clBtnFace
        DataField = 'DELETE_RULE'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object dbedRefState: TDBEdit
        Left = 120
        Top = 216
        Width = 241
        Height = 21
        Color = clBtnFace
        DataField = 'REF_STATE'
        DataSource = dsgdcBase
        TabOrder = 8
      end
      object dbcbRefNextState: TDBComboBox
        Left = 120
        Top = 240
        Width = 241
        Height = 21
        DataField = 'REF_NEXT_STATE'
        DataSource = dsgdcBase
        ItemHeight = 13
        Items.Strings = (
          'ORIGINAL'
          'TRIGGER')
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Left = 310
    Top = 15
  end
  inherited dsgdcBase: TDataSource
    Left = 288
    Top = 15
  end
  inherited pm_dlgG: TPopupMenu
    Left = 336
    Top = 16
  end
  inherited ibtrCommon: TIBTransaction
    Left = 264
    Top = 16
  end
end
