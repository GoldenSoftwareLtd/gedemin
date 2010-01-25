inherited ReportFunctionFrame: TReportFunctionFrame
  inherited PageControl: TSuperPageControl
    inherited tsProperty: TSuperTabSheet
      inherited TBDock1: TTBDock
        inherited TBToolbar1: TTBToolbar
          object TBItem3: TTBItem [0]
            Action = actNewFunction
          end
          object TBItem2: TTBItem [1]
            Action = actDeleteFunction
          end
          object TBSeparatorItem1: TTBSeparatorItem [2]
          end
        end
      end
      inherited pMain: TPanel
        inherited edtRUIDFunction: TEdit
          Width = 209
        end
        inherited dbeName: TprpDBComboBox
          Width = 286
          Style = csDropDown
        end
        inherited dbmDescription: TDBMemo
          Width = 286
        end
        inherited dbcbLang: TDBComboBox
          Width = 286
        end
        inherited dbtOwner: TDBEdit
          Width = 286
        end
        inherited dbeLocalName: TDBEdit
          Width = 285
        end
        inherited pnlRUIDFunction: TPanel
          Left = 355
        end
      end
    end
    inherited tsDependencies: TSuperTabSheet
      inherited Splitter1: TSplitter
        Height = 133
      end
      object Splitter2: TSplitter [1]
        Left = 0
        Top = 133
        Width = 443
        Height = 3
        Cursor = crVSplit
        Align = alBottom
      end
      inherited pnlDependent: TPanel
        Height = 133
        inherited lbDependent: TListBox
          Height = 116
        end
      end
      inherited pnlDependedFrom: TPanel
        Height = 133
        inherited lbDependedFrom: TListBox
          Height = 116
        end
      end
      object pnlReport: TPanel
        Left = 0
        Top = 136
        Width = 443
        Height = 118
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 443
          Height = 25
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          BorderStyle = bsSingle
          Caption = 'Используется в отчетах:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
        end
        object lbReport: TListBox
          Left = 0
          Top = 25
          Width = 443
          Height = 93
          Align = alClient
          ItemHeight = 13
          TabOrder = 1
          OnDblClick = lbReportDblClick
        end
      end
    end
  end
  inherited DataSource: TDataSource
    Left = 256
  end
  inherited PopupMenu: TPopupMenu
    Left = 288
  end
  inherited ActionList1: TActionList
    Left = 256
    Top = 40
    inherited actAddToSetting: TAction
      Caption = 'Добавить функцию в настройку ...'
    end
    object actDeleteFunction: TAction
      Caption = 'Удалить функцию'
      Hint = 'Удалить функцию'
      ImageIndex = 2
      OnUpdate = actDeleteFunctionUpdate
    end
    object actNewFunction: TAction
      Caption = 'Новая функция'
      Hint = 'Новая функция'
      ImageIndex = 0
      OnUpdate = actNewFunctionUpdate
    end
    object actRefreshReport: TAction
      Caption = 'Обновить'
      ShortCut = 116
      OnExecute = actRefreshReportExecute
    end
  end
  inherited gdcFunction: TgdcFunction
    DetailField = 'Id'
    Left = 328
  end
  inherited gdcDelphiObject: TgdcDelphiObject
    Left = 352
    Top = 32
  end
  inherited dsDelpthiObject: TDataSource
    Left = 288
  end
  inherited SynCompletionProposal: TSynCompletionProposal
    Left = 288
    Top = 136
  end
  inherited pmDependent: TPopupMenu
    Top = 200
  end
  inherited pmDependedFrom: TPopupMenu
    Top = 200
  end
  object pmReport: TPopupMenu
    Left = 136
    Top = 311
  end
end
