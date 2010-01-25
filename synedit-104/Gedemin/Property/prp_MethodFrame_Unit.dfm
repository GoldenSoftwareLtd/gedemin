inherited MethodFrame: TMethodFrame
  Height = 297
  HelpContext = 324
  inherited PageControl: TSuperPageControl
    Height = 297
    inherited tsProperty: TSuperTabSheet
      inherited TBDock1: TTBDock
        inherited TBToolbar1: TTBToolbar
          object TBItem2: TTBItem [0]
            Action = actDisable
          end
          object TBSeparatorItem1: TTBSeparatorItem [1]
          end
        end
      end
      inherited pMain: TPanel
        Height = 242
        TabOrder = 0
        inherited lbName: TLabel
          Top = 32
        end
        inherited lbDescription: TLabel
          Top = 104
        end
        inherited lbOwner: TLabel
          Top = 58
          Width = 100
          Caption = 'Владелец функции:'
        end
        inherited lbLanguage: TLabel
          Top = 176
        end
        inherited lLocalName: TLabel
          Top = 204
        end
        inherited lblRUIDFunction: TLabel
          Top = 83
        end
        object lMethodName: TLabel [6]
          Left = 8
          Top = 8
          Width = 117
          Height = 13
          Caption = 'Наименование метода:'
        end
        inherited dbtOwner: TDBEdit [7]
          Top = 56
          TabOrder = 2
        end
        inherited edtRUIDFunction: TEdit [8]
          Top = 80
          TabOrder = 3
        end
        inherited dbeName: TprpDBComboBox [9]
          Top = 32
          Width = 291
          TabOrder = 1
        end
        inherited dbmDescription: TDBMemo [10]
          Top = 104
          Width = 291
          TabOrder = 5
        end
        inherited dbcbLang: TDBComboBox [11]
          Top = 176
          Width = 291
          PopupMenu = nil
          TabOrder = 6
        end
        inherited dbeLocalName: TDBEdit
          Top = 200
          TabOrder = 7
        end
        inherited pnlRUIDFunction: TPanel
          Top = 80
          TabOrder = 4
        end
        object DBEdit1: TDBEdit
          Left = 144
          Top = 8
          Width = 291
          Height = 21
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
    inherited tsDependencies: TSuperTabSheet
      inherited Splitter1: TSplitter
        Height = 274
      end
      inherited pnlDependent: TPanel
        Height = 274
        inherited lbDependent: TListBox
          Height = 257
        end
      end
      inherited pnlDependedFrom: TPanel
        Height = 274
        inherited lbDependedFrom: TListBox
          Height = 257
        end
      end
    end
  end
  inherited ActionList1: TActionList
    object actDisable: TAction
      Caption = 'Подключить'
      Hint = 'Подключить/отключить метод'
      ImageIndex = 49
      OnExecute = actDisableExecute
      OnUpdate = actDisableUpdate
    end
  end
  inherited gdcFunction: TgdcFunction
    MasterSource = dsEvent
    MasterField = 'FUNCTIONKEY'
    DetailField = 'ID'
  end
  object dsEvent: TDataSource
    DataSet = gdcEvent
    Left = 296
    Top = 48
  end
  object gdcEvent: TgdcEvent
    AfterDelete = gdcEventAfterDelete
    SubSet = 'ByID'
    Left = 328
    Top = 16
  end
end
