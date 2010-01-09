inherited MacrosFrame: TMacrosFrame
  HelpContext = 323
  inherited PageControl: TSuperPageControl
    inherited tsProperty: TSuperTabSheet
      inherited pMain: TPanel
        inherited lbName: TLabel
          Top = 59
        end
        inherited lbDescription: TLabel
          Top = 152
        end
        inherited lbOwner: TLabel
          Top = 84
        end
        inherited lbLanguage: TLabel
          Top = 228
        end
        inherited lLocalName: TLabel
          Top = 252
        end
        inherited lblRUIDFunction: TLabel
          Top = 131
        end
        object lblHotKey: TLabel [6]
          Left = 8
          Top = 35
          Width = 93
          Height = 13
          Caption = 'Горячая клавиша:'
          Layout = tlCenter
        end
        object lMacrosName: TLabel [7]
          Left = 8
          Top = 12
          Width = 121
          Height = 13
          Caption = 'Наименование макроса:'
        end
        object lblRUIDMacros: TLabel [8]
          Left = 8
          Top = 107
          Width = 73
          Height = 13
          Caption = 'RUID макроса:'
        end
        inherited edtRUIDFunction: TEdit
          Top = 128
          TabOrder = 6
        end
        object dbcbMacrosName: TDBComboBox [10]
          Left = 144
          Top = 8
          Width = 292
          Height = 21
          Style = csSimple
          Anchors = [akLeft, akTop, akRight]
          DataField = 'Name'
          DataSource = dsMacros
          ItemHeight = 13
          TabOrder = 0
          OnChange = dbeFunctionNameChange
        end
        object hkMacros: THotKey [11]
          Left = 144
          Top = 32
          Width = 292
          Height = 19
          Hint = 'Назначение клавиш для бастрого вызова макросов'
          Anchors = [akLeft, akTop, akRight]
          HotKey = 0
          InvalidKeys = []
          Modifiers = []
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnMouseDown = hkMacrosMouseDown
        end
        inherited dbeName: TprpDBComboBox
          Top = 55
          TabOrder = 2
        end
        inherited dbmDescription: TDBMemo
          Top = 152
          TabOrder = 8
        end
        inherited dbcbLang: TDBComboBox
          Top = 224
          TabOrder = 9
        end
        inherited dbtOwner: TDBEdit
          Top = 80
          Width = 292
          TabOrder = 3
        end
        inherited dbeLocalName: TDBEdit
          Top = 248
          TabOrder = 10
        end
        inherited pnlRUIDFunction: TPanel
          Top = 128
          TabOrder = 7
        end
        object dbcbDisplayInMenu: TDBCheckBox
          Left = 8
          Top = 272
          Width = 230
          Height = 17
          Caption = 'Отображать в меню макросов формы'
          DataField = 'DisplayInMenu'
          DataSource = dsMacros
          TabOrder = 11
          ValueChecked = '1'
          ValueUnchecked = '0'
          OnClick = dbeFunctionNameChange
        end
        object edtRUIDMacros: TEdit
          Left = 144
          Top = 104
          Width = 215
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 4
        end
        object pnlRUIDMacros: TPanel
          Left = 361
          Top = 104
          Width = 75
          Height = 21
          Anchors = [akTop, akRight]
          BevelOuter = bvLowered
          TabOrder = 5
          object btnCopyRUIDMacros: TButton
            Left = 1
            Top = 1
            Width = 73
            Height = 19
            Caption = 'Копировать'
            TabOrder = 0
            OnClick = btnCopyRUIDMacrosClick
          end
        end
      end
    end
  end
  inherited DataSource: TDataSource
    Top = 0
  end
  inherited PopupMenu: TPopupMenu
    Left = 72
    Top = 144
  end
  inherited ActionList1: TActionList
    Left = 72
    Top = 112
  end
  inherited gdcFunction: TgdcFunction
    MasterSource = dsMacros
    MasterField = 'FUNCTIONKEY'
    DetailField = 'ID'
  end
  inherited gdcDelphiObject: TgdcDelphiObject
    Top = 32
  end
  inherited dsDelpthiObject: TDataSource
    Top = 32
  end
  inherited SynCompletionProposal: TSynCompletionProposal
    Left = 40
    Top = 144
  end
  inherited ReplaceDialog: TReplaceDialog
    Left = 40
    Top = 112
  end
  inherited OpenDialog: TOpenDialog
    Left = 40
    Top = 48
  end
  inherited SaveDialog: TSaveDialog
    Left = 72
    Top = 48
  end
  inherited SynExporterRTF1: TSynExporterRTF
    Left = 40
    Top = 176
  end
  object gdcMacros: TgdcMacros
    AfterEdit = gdcMacrosAfterEdit
    SubSet = 'ByID'
    Left = 336
    Top = 64
  end
  object dsMacros: TDataSource
    DataSet = gdcMacros
    Left = 304
    Top = 64
  end
  object dsServers: TDataSource
    Left = 72
    Top = 79
  end
end
