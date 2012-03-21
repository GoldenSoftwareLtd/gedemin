inherited ReportFrame: TReportFrame
  HelpContext = 325
  inherited PageControl: TSuperPageControl
    OnDrawTab = PageControlDrawTab
    OwnerDraw = True
    OnChange = PageControlChange
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
          object TBItem1: TTBItem
            Action = actProperty
          end
          object tbiChooseDocumentType: TTBItem
            Action = actChooseDocumentType
          end
        end
      end
      inherited pMain: TPanel
        Top = 28
        Height = 211
        OnResize = pMainResize
        inherited lbName: TLabel
          Width = 116
          Caption = 'Наименование отчета:'
        end
        inherited lbDescription: TLabel
          Top = 56
        end
        object Label3: TLabel [2]
          Left = 8
          Top = 125
          Width = 108
          Height = 26
          Caption = 'Частота обновления отчета (дней):'
          WordWrap = True
        end
        object lFolder: TLabel [3]
          Left = 8
          Top = 156
          Width = 110
          Height = 13
          Caption = 'Отображать в папке:'
        end
        object lblRUIDReport: TLabel [4]
          Left = 8
          Top = 36
          Width = 68
          Height = 13
          Caption = 'RUID отчета:'
        end
        inherited dbeName: TprpDBComboBox
          Width = 288
        end
        inherited dbmDescription: TDBMemo
          Top = 56
          Width = 288
          DataField = 'DESCRIPTION'
          TabOrder = 3
        end
        object dbeFrqRefresh: TDBEdit
          Left = 144
          Top = 128
          Width = 288
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          DataField = 'FRQREFRESH'
          DataSource = DataSource
          TabOrder = 4
          OnChange = dbeFunctionNameChange
        end
        object dbcbPreview: TDBCheckBox
          Left = 8
          Top = 199
          Width = 220
          Height = 17
          Caption = 'Отображать отчет перед печатью'
          DataField = 'PREVIEW'
          DataSource = DataSource
          TabOrder = 7
          ValueChecked = '1'
          ValueUnchecked = '0'
          OnClick = dbeFunctionNameChange
        end
        object dbcbSaveResult: TDBCheckBox
          Left = 8
          Top = 215
          Width = 220
          Height = 17
          Caption = 'Перестраивать отчет заново'
          DataField = 'ISREBUILD'
          DataSource = DataSource
          TabOrder = 8
          ValueChecked = '1'
          ValueUnchecked = '0'
          Visible = False
          OnClick = dbeFunctionNameChange
        end
        object dbcbIsLocalExecute: TDBCheckBox
          Left = 8
          Top = 231
          Width = 220
          Height = 17
          Caption = 'Выполнять отчет локально'
          DataField = 'ISLOCALEXECUTE'
          DataSource = DataSource
          TabOrder = 9
          ValueChecked = '1'
          ValueUnchecked = '0'
          Visible = False
          OnClick = dbeFunctionNameChange
        end
        object dbcbDisplayInMenu: TDBCheckBox
          Left = 8
          Top = 183
          Width = 233
          Height = 17
          Caption = 'Отображать в меню отчетов формы'
          DataField = 'DisplayInMenu'
          DataSource = DataSource
          TabOrder = 6
          ValueChecked = '1'
          ValueUnchecked = '0'
          OnClick = dbeFunctionNameChange
        end
        object iblFolder: TgsIBLookupComboBox
          Left = 144
          Top = 152
          Width = 288
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = Transaction
          DataSource = DataSource
          DataField = 'FOLDERKEY'
          ListTable = 'gd_command'
          ListField = 'name'
          KeyField = 'ID'
          gdClassName = 'TgdcExplorer'
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
          OnChange = iblFolderChange
        end
        object pnlRUIDReport: TPanel
          Left = 357
          Top = 32
          Width = 75
          Height = 21
          Anchors = [akTop, akRight]
          BevelOuter = bvLowered
          TabOrder = 2
          object btnCopyRUIDReport: TButton
            Left = 1
            Top = 1
            Width = 73
            Height = 19
            Caption = 'Копировать'
            TabOrder = 0
            OnClick = btnCopyRUIDReportClick
          end
        end
        object edtRUIDReport: TEdit
          Left = 144
          Top = 32
          Width = 211
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
      end
    end
    object tsMainFunction: TSuperTabSheet
      Caption = 'Основная функция'
      ImageIndex = 1
      inline MainFunctionFrame: TReportFunctionFrame
        Top = 9
        Height = 234
        PopupMenu = MainFunctionFrame.PopupMenu
        inherited PageControl: TSuperPageControl
          Height = 234
          inherited tsProperty: TSuperTabSheet
            inherited pMain: TPanel
              Height = 179
              inherited dbeName: TprpDBComboBox
                OnChange = MainFunctionFramedbeNameChange
                OnDropDown = MainFunctionFramedbeNameDropDown
                OnSelChange = MainFunctionFramedbeNameSelChange
              end
            end
          end
          inherited tsScript: TSuperTabSheet
            inherited gsFunctionSynEdit: TgsFunctionSynEdit
              Height = 218
            end
          end
          inherited tsParams: TSuperTabSheet
            inherited ScrollBox: TScrollBox
              Height = 182
            end
          end
        end
        inherited ActionList1: TActionList
          inherited actNewFunction: TAction
            OnExecute = MainFunctionFrameactNewFunctionExecute
          end
        end
        inherited gdcFunction: TgdcFunction
          MasterSource = DataSource
          MasterField = 'MainFormulaKey'
        end
        inherited SynCompletionProposal: TSynCompletionProposal
          Left = 280
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 435
        Height = 9
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
      end
    end
    object tsParamFunction: TSuperTabSheet
      Caption = 'Функция параметров'
      ImageIndex = 2
      inline ParamFunctionFrame: TReportFunctionFrame
        Top = 9
        Height = 234
        PopupMenu = ParamFunctionFrame.PopupMenu
        inherited PageControl: TSuperPageControl
          Height = 234
          inherited tsProperty: TSuperTabSheet
            inherited pMain: TPanel
              Height = 179
              inherited dbeName: TprpDBComboBox
                OnNewRecord = ParamFunctionFramedbeNameNewRecord
                OnSelChange = ParamFunctionFramedbeNameSelChange
                OnDeleteRecord = ParamFunctionFramedbeNameDeleteRecord
              end
            end
          end
        end
        inherited ActionList1: TActionList
          inherited actDeleteFunction: TAction
            OnExecute = ParamFunctionFrameactDeleteFunctionExecute
            OnUpdate = ParamFunctionFrameactDeleteFunctionUpdate
          end
          inherited actNewFunction: TAction
            OnExecute = ParamFunctionFrameactNewFunctionExecute
          end
        end
        inherited gdcFunction: TgdcFunction
          MasterSource = DataSource
          MasterField = 'ParamFormulaKey'
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 435
        Height = 9
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
      end
    end
    object tsEventFunction: TSuperTabSheet
      Caption = 'Функция событий'
      ImageIndex = 3
      inline EventFunctionFrame: TReportFunctionFrame
        Top = 9
        Height = 234
        PopupMenu = EventFunctionFrame.PopupMenu
        inherited PageControl: TSuperPageControl
          Height = 234
          inherited tsProperty: TSuperTabSheet
            inherited pMain: TPanel
              Height = 179
              inherited dbeName: TprpDBComboBox
                OnNewRecord = EventFunctionFramedbeNameNewRecord
                OnSelChange = EventFunctionFramedbeNameSelChange
                OnDeleteRecord = EventFunctionFramedbeNameDeleteRecord
              end
            end
          end
        end
        inherited ActionList1: TActionList
          inherited actDeleteFunction: TAction
            OnExecute = EventFunctionFrameactDeleteFunctionExecute
            OnUpdate = EventFunctionFrameactDeleteFunctionUpdate
          end
          inherited actNewFunction: TAction
            OnExecute = EventFunctionFrameactNewFunctionExecute
            OnUpdate = EventFunctionFrameactNewFunctionUpdate
          end
        end
        inherited gdcFunction: TgdcFunction
          MasterSource = DataSource
          MasterField = 'EventFormulaKey'
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 435
        Height = 9
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
      end
    end
    object tsTemplate: TSuperTabSheet
      Caption = 'Шаблон'
      ImageIndex = 4
      inline TemplateFrame: TTemplateFrame
        Top = 9
        Height = 234
        PopupMenu = TemplateFrame.PopupMenu
        inherited PageControl: TSuperPageControl
          Height = 234
          inherited tsProperty: TSuperTabSheet
            inherited pMain: TPanel
              Height = 179
              inherited dbeName: TprpDBComboBox
                OnChange = nil
                OnDropDown = TemplateFramedbeNameDropDown
                OnNewRecord = TemplateFramedbeNameNewRecord
                OnSelChange = TemplateFramedbeNameSelChange
              end
              inherited pnlRUIDTemplate: TPanel
                inherited btnCopyRUIDTemplate: TButton
                  OnClick = nil
                end
              end
              inherited mHint: TMemo
                Lines.Strings = ()
              end
            end
          end
        end
        inherited ActionList1: TActionList
          inherited actEditTemplate: TAction
            OnExecute = TempalteFrameactEditTemplateExecute
            OnUpdate = TemplateFrameactEditTemplateUpdate
          end
          inherited actDeleteTemplate: TAction
            OnExecute = TemplateFrameactDeleteTemplateExecute
            OnUpdate = TemplateFrameactDeleteTemplateUpdate
          end
          inherited actNewTemplate: TAction
            OnExecute = TemplateFrameactNewTemplateExecute
            OnUpdate = TemplateFrameactNewTemplateUpdate
          end
        end
        inherited gdcTemplate: TgdcTemplate
          MasterSource = DataSource
        end
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 435
        Height = 9
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
      end
    end
  end
  inherited DataSource: TDataSource
    DataSet = gdcReport
    Left = 16
    Top = 72
  end
  inherited PopupMenu: TPopupMenu
    Images = dmImages.il16x16
    Left = 48
    Top = 40
  end
  inherited ActionList1: TActionList
    Left = 104
    Top = 64
    inherited actAddToSetting: TAction
      Caption = 'Добавить отчет в настройку ...'
    end
    inherited actProperty: TAction
      OnUpdate = nil
    end
    object actChooseDocumentType: TAction
      Caption = 'Выбрать типовой документ'
      Hint = 'Выбрать типовой документ для отчета'
      ImageIndex = 139
      OnExecute = actChooseDocumentTypeExecute
    end
  end
  object pmReport: TPopupMenu
    Left = 136
    Top = 311
  end
  object gdcReport: TgdcReport
    AfterDelete = gdcReportAfterDelete
    AfterEdit = gdcReportAfterEdit
    AfterInternalDeleteRecord = gdcReportAfterInternalDeleteRecord
    SubSet = 'ByID'
    Left = 16
    Top = 40
  end
  object dsServers: TDataSource
    Left = 80
    Top = 40
  end
  object Transaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 82
    Top = 109
  end
end
