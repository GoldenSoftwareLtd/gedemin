inherited gdc_dlgFKManager: Tgdc_dlgFKManager
  Left = 350
  Top = 202
  Caption = 'gdc_dlgFKManager'
  ClientHeight = 431
  ClientWidth = 372
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 406
  end
  inherited btnNew: TButton
    Top = 406
  end
  inherited btnHelp: TButton
    Top = 406
  end
  inherited btnOK: TButton
    Left = 227
    Top = 406
    Anchors = []
  end
  inherited btnCancel: TButton
    Left = 300
    Top = 406
  end
  inherited pgcMain: TPageControl
    Width = 363
    Height = 394
    inherited tbsMain: TTabSheet
      inherited dbtxtID: TDBText
        Left = 116
      end
      object Label1: TLabel
        Left = 8
        Top = 32
        Width = 78
        Height = 13
        Caption = 'Внешний ключ:'
      end
      object Label2: TLabel
        Left = 8
        Top = 56
        Width = 55
        Height = 13
        Caption = 'В таблице:'
      end
      object Label3: TLabel
        Left = 8
        Top = 79
        Width = 47
        Height = 13
        Caption = 'По полю:'
      end
      object Label4: TLabel
        Left = 8
        Top = 112
        Width = 102
        Height = 13
        Caption = 'Ссылка на таблицу:'
      end
      object Label5: TLabel
        Left = 8
        Top = 136
        Width = 84
        Height = 13
        Caption = 'Ссылка на поле:'
      end
      object Label6: TLabel
        Left = 8
        Top = 159
        Width = 79
        Height = 13
        Caption = 'При изменении:'
      end
      object Label7: TLabel
        Left = 8
        Top = 183
        Width = 75
        Height = 13
        Caption = 'При удалении:'
      end
      object Label8: TLabel
        Left = 8
        Top = 215
        Width = 104
        Height = 13
        Caption = 'Текущее состояние:'
      end
      object Label9: TLabel
        Left = 8
        Top = 239
        Width = 89
        Height = 13
        Caption = 'Конвертировать:'
      end
      object dbedConstraintName: TDBEdit
        Left = 114
        Top = 27
        Width = 232
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'CONSTRAINT_NAME'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbedConstraintRel: TDBEdit
        Left = 114
        Top = 51
        Width = 232
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'CONSTRAINT_REL'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbedConstraintField: TDBEdit
        Left = 114
        Top = 75
        Width = 232
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'CONSTRAINT_FIELD'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object dbedRefRel: TDBEdit
        Left = 114
        Top = 107
        Width = 232
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'REF_REL'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object dbedRefField: TDBEdit
        Left = 114
        Top = 131
        Width = 232
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'REF_FIELD'
        DataSource = dsgdcBase
        TabOrder = 6
      end
      object dbedUpdateRule: TDBEdit
        Left = 114
        Top = 155
        Width = 232
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'UPDATE_RULE'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object dbedDeleteRule: TDBEdit
        Left = 114
        Top = 179
        Width = 232
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'DELETE_RULE'
        DataSource = dsgdcBase
        TabOrder = 8
      end
      object dbedRefState: TDBEdit
        Left = 114
        Top = 211
        Width = 232
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'REF_STATE'
        DataSource = dsgdcBase
        TabOrder = 9
      end
      object dbcbRefNextState: TDBComboBox
        Left = 114
        Top = 235
        Width = 232
        Height = 21
        DataField = 'REF_NEXT_STATE'
        DataSource = dsgdcBase
        ItemHeight = 13
        Items.Strings = (
          'ORIGINAL'
          'TRIGGER')
        TabOrder = 0
      end
      object gbStat: TGroupBox
        Left = 7
        Top = 256
        Width = 340
        Height = 108
        Caption = ' Статистика '
        TabOrder = 1
        object Label10: TLabel
          Left = 241
          Top = 62
          Width = 4
          Height = 13
          Caption = ':'
        end
        object DBText1: TDBText
          Left = 250
          Top = 19
          Width = 63
          Height = 17
          DataField = 'CONSTRAINT_REC_COUNT'
          DataSource = dsgdcBase
        end
        object Label12: TLabel
          Left = 241
          Top = 40
          Width = 4
          Height = 13
          Caption = ':'
        end
        object DBText3: TDBText
          Left = 250
          Top = 62
          Width = 63
          Height = 17
          DataField = 'REF_REC_COUNT'
          DataSource = dsgdcBase
        end
        object Label11: TLabel
          Left = 241
          Top = 19
          Width = 4
          Height = 13
          Caption = ':'
        end
        object DBText2: TDBText
          Left = 250
          Top = 40
          Width = 63
          Height = 17
          DataField = 'CONSTRAINT_UQ_COUNT'
          DataSource = dsgdcBase
        end
        object btnUq: TButton
          Left = 8
          Top = 37
          Width = 228
          Height = 21
          Action = actShowValues
          TabOrder = 1
        end
        object btnConstr: TButton
          Left = 8
          Top = 15
          Width = 228
          Height = 21
          Action = actShowConstraintRel
          TabOrder = 0
        end
        object btnRef: TButton
          Left = 8
          Top = 59
          Width = 228
          Height = 21
          Action = actShowRefRel
          TabOrder = 2
        end
        object btnActiveValues: TButton
          Left = 8
          Top = 81
          Width = 228
          Height = 21
          Action = actShowActiveValues
          TabOrder = 3
        end
      end
    end
  end
  inherited alBase: TActionList
    Left = 310
    Top = 15
    object actShowValues: TAction
      Caption = 'Уникальных значений во внешнем ключе'
      OnExecute = actShowValuesExecute
    end
    object actShowConstraintRel: TAction
      Caption = 'Записей во внешнем ключе'
      OnExecute = actShowConstraintRelExecute
    end
    object actShowRefRel: TAction
      Caption = 'Записей в таблице справочнике'
      OnExecute = actShowRefRelExecute
    end
    object actShowActiveValues: TAction
      Caption = 'Показать текущие значения'
      OnExecute = actShowActiveValuesExecute
      OnUpdate = actShowActiveValuesUpdate
    end
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
