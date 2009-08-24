inherited EventFrame: TEventFrame
  HelpContext = 321
  inherited PageControl: TSuperPageControl
    inherited tsProperty: TSuperTabSheet
      inherited TBDock1: TTBDock
        inherited TBToolbar1: TTBToolbar
          object TBItem4: TTBItem [0]
            Action = actNewFunction
          end
          object TBItem3: TTBItem [1]
            Action = actDeleteFunction
          end
          object TBItem2: TTBItem [2]
            Action = actDisable
          end
          object TBSeparatorItem1: TTBSeparatorItem [3]
          end
        end
      end
      inherited pMain: TPanel
        TabOrder = 0
        inherited lbName: TLabel
          Top = 32
        end
        inherited lbDescription: TLabel
          Top = 104
        end
        inherited lbOwner: TLabel
          Top = 56
          Width = 100
          Caption = 'Владелец функции:'
        end
        inherited lbLanguage: TLabel
          Top = 176
        end
        inherited lLocalName: TLabel
          Top = 203
        end
        inherited lblRUIDFunction: TLabel
          Top = 84
        end
        object lEventName: TLabel [6]
          Left = 8
          Top = 8
          Width = 123
          Height = 13
          Caption = 'Наименование события:'
        end
        inherited dbtOwner: TDBEdit [7]
          Top = 56
          Width = 281
          TabOrder = 2
        end
        inherited edtRUIDFunction: TEdit [8]
          Top = 80
          Width = 205
          TabOrder = 3
        end
        inherited dbeName: TprpDBComboBox [9]
          Top = 32
          Width = 281
          Style = csDropDown
          TabOrder = 1
          OnSelChange = dbeNameSelChange
        end
        inherited dbmDescription: TDBMemo [10]
          Top = 104
          Width = 281
          TabOrder = 5
        end
        inherited dbcbLang: TDBComboBox [11]
          Top = 176
          Width = 281
          TabOrder = 6
          OnChange = dbeFunctionNameChange
        end
        inherited dbeLocalName: TDBEdit
          Top = 200
          Width = 281
          TabOrder = 7
        end
        inherited pnlRUIDFunction: TPanel
          Left = 351
          Top = 80
          TabOrder = 4
        end
        object dbtEventName: TDBEdit
          Left = 144
          Top = 8
          Width = 281
          Height = 21
          Hint = 'Наименование события'
          Anchors = [akLeft, akTop, akRight]
          Color = clBtnFace
          DataField = 'EventName'
          DataSource = dsEvent
          PopupMenu = PopupMenu
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
    inherited tsParams: TSuperTabSheet
      TabVisible = False
      inherited ScrollBox: TScrollBox
        Width = 437
        Height = 212
      end
      inherited pnlCaption: TPanel
        Width = 437
      end
    end
  end
  inherited DataSource: TDataSource
    Left = 280
    Top = 160
  end
  inherited PopupMenu: TPopupMenu
    Left = 296
    Top = 32
  end
  inherited ActionList1: TActionList
    Left = 328
    Top = 32
    object actDisable: TAction
      Caption = 'Подключить'
      Hint = 'Подключить/откльчить метод'
      ImageIndex = 49
      OnExecute = actDisableExecute
      OnUpdate = actDisableUpdate
    end
    object actNewFunction: TAction
      Caption = 'Создать новую функцию'
      Hint = 'Создать новую функцию'
      ImageIndex = 0
      OnExecute = actNewFunctionExecute
      OnUpdate = actNewFunctionUpdate
    end
    object actDeleteFunction: TAction
      Caption = 'Удалить функцию'
      Hint = 'Удалить функцию'
      ImageIndex = 2
      OnExecute = actDeleteFunctionExecute
      OnUpdate = actDeleteFunctionUpdate
    end
  end
  inherited gdcFunction: TgdcFunction
    MasterSource = dsEvent
    MasterField = 'FUNCTIONKEY'
    DetailField = 'ID'
    Left = 280
    Top = 192
  end
  inherited gdcDelphiObject: TgdcDelphiObject
    Left = 248
    Top = 192
  end
  inherited dsDelpthiObject: TDataSource
    Left = 216
    Top = 160
  end
  inherited SynCompletionProposal: TSynCompletionProposal
    Left = 264
    Top = 32
  end
  inherited ReplaceDialog: TReplaceDialog
    Left = 216
    Top = 32
  end
  inherited OpenDialog: TOpenDialog
    Left = 360
    Top = 32
  end
  inherited SaveDialog: TSaveDialog
    Left = 400
    Top = 40
  end
  object gdcEvent: TgdcEvent
    AfterDelete = gdcEventAfterDelete
    SubSet = 'ByID'
    Left = 248
    Top = 160
  end
  object dsEvent: TDataSource
    DataSet = gdcEvent
    Left = 216
    Top = 192
  end
end
