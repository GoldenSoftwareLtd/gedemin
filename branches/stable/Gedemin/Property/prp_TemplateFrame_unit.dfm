inherited TemplateFrame: TTemplateFrame
  inherited PageControl: TSuperPageControl
    inherited tsProperty: TSuperTabSheet
      inherited TBDock1: TTBDock
        Height = 28
        object TBToolbar1: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'TBToolbar1'
          DockMode = dmCannotFloatOrChangeDocks
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          Stretch = True
          TabOrder = 0
          object TBItem2: TTBItem
            Action = actNewTemplate
          end
          object TBItem3: TTBItem
            Action = actEditTemplate
          end
          object TBItem4: TTBItem
            Action = actDeleteTemplate
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBItem1: TTBItem
            Action = actProperty
          end
        end
      end
      inherited pMain: TPanel
        Top = 28
        Height = 222
        OnResize = pMainResize
        inherited lbName: TLabel
          Caption = 'Наименование шаблона:'
        end
        inherited lbDescription: TLabel
          Top = 56
        end
        object Label22: TLabel [2]
          Left = 8
          Top = 132
          Width = 69
          Height = 13
          Caption = 'Тип шаблона:'
        end
        object lblRUIDTemplate: TLabel [3]
          Left = 8
          Top = 36
          Width = 76
          Height = 13
          Caption = 'RUID шаблона:'
        end
        inherited dbeName: TprpDBComboBox
          Width = 288
          Style = csDropDown
          DropDownCount = 16
          OnExit = dbeNameExit
          OnDeleteRecord = dbeNameDeleteRecord
        end
        inherited dbmDescription: TDBMemo
          Top = 56
          Width = 288
          DataField = 'DESCRIPTION'
          ParentFont = False
          TabOrder = 3
        end
        object dblcbType: TDBLookupComboBox
          Left = 144
          Top = 128
          Width = 288
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          DataField = 'TEMPLATETYPE'
          DataSource = DataSource
          KeyField = 'TemplateType'
          ListField = 'DescriptionType'
          ListSource = dsTemplateType
          TabOrder = 4
          OnClick = dblcbTypeClick
        end
        object edtRUIDTemplate: TEdit
          Left = 144
          Top = 32
          Width = 211
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object pnlRUIDTemplate: TPanel
          Left = 357
          Top = 32
          Width = 75
          Height = 21
          Anchors = [akTop, akRight]
          BevelOuter = bvLowered
          TabOrder = 2
          object btnCopyRUIDTemplate: TButton
            Left = 1
            Top = 1
            Width = 73
            Height = 19
            Caption = 'Копировать'
            TabOrder = 0
            OnClick = btnCopyRUIDTemplateClick
          end
        end
        object mHint: TMemo
          Left = 144
          Top = 152
          Width = 288
          Height = 76
          TabStop = False
          Anchors = [akLeft, akTop, akRight]
          Color = clInfoBk
          Lines.Strings = (
            'Всегда указывайте префикс (пространство имен) при '
            'именовании шаблона.'
            ''
            'Например, "Склад.Торговля.Оборотная ведомость", '
            'а не "Оборотная ведомость".')
          ReadOnly = True
          TabOrder = 5
        end
      end
    end
  end
  inherited DataSource: TDataSource
    DataSet = gdcTemplate
    Left = 171
    Top = 11
  end
  inherited PopupMenu: TPopupMenu
    Left = 104
    Top = 112
  end
  inherited ActionList1: TActionList
    Left = 44
    inherited actAddToSetting: TAction
      Caption = 'Добавить шаблон в настройку ...'
    end
    object actEditTemplate: TAction
      Caption = 'Редактировать шаблон'
      Hint = 'Редактировать шаблон'
      ImageIndex = 1
      OnUpdate = actEditTemplateUpdate
    end
    object actDeleteTemplate: TAction
      Caption = 'Удалить шаблон'
      Hint = 'Удалить шаблон'
      ImageIndex = 2
      OnUpdate = actDeleteTemplateUpdate
    end
    object actNewTemplate: TAction
      Caption = 'Создать новый шаблон'
      Hint = 'Создать новый шаблон'
      ImageIndex = 0
      OnUpdate = actNewTemplateUpdate
    end
  end
  object gdcTemplate: TgdcTemplate
    AfterEdit = gdcTemplateAfterEdit
    AfterOpen = gdcTemplateAfterOpen
    MasterField = 'TEMPLATEKEY'
    DetailField = 'ID'
    SubSet = 'ByID'
    Left = 320
    Top = 24
  end
  object dsTemplate: TDataSource
    DataSet = ibqryTemplate
    Left = 280
  end
  object ibqryTemplate: TIBQuery
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reporttemplate'
      'ORDER BY '
      '  name')
    Left = 208
  end
  object dsTemplateType: TDataSource
    DataSet = cdsTemplateType
    Left = 136
    Top = 104
  end
  object cdsTemplateType: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 176
    Top = 80
    object cdsTemplateTypeTemplateType: TStringField
      FieldName = 'TemplateType'
    end
    object cdsTemplateTypeDescriptionType: TStringField
      FieldName = 'DescriptionType'
    end
  end
end
