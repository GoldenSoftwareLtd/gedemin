inherited MacrosFrame: TMacrosFrame
  Height = 429
  HelpContext = 323
  inherited PageControl: TSuperPageControl
    Height = 429
    inherited tsProperty: TSuperTabSheet
      inherited pMain: TPanel
        Height = 374
        inherited lbName: TLabel
          Top = 58
        end
        inherited lbDescription: TLabel
          Top = 154
        end
        inherited lbOwner: TLabel
          Top = 82
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
          Caption = '������� �������:'
          Layout = tlCenter
        end
        object lMacrosName: TLabel [7]
          Left = 8
          Top = 12
          Width = 121
          Height = 13
          Caption = '������������ �������:'
        end
        object lblRUIDMacros: TLabel [8]
          Left = 8
          Top = 107
          Width = 73
          Height = 13
          Caption = 'RUID �������:'
        end
        inherited edtRUIDFunction: TEdit
          Top = 128
          Width = 183
          TabOrder = 6
        end
        object dbcbMacrosName: TDBComboBox [10]
          Left = 144
          Top = 8
          Width = 285
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
          Width = 285
          Height = 19
          Hint = '���������� ������ ��� �������� ������ ��������'
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
          Top = 54
          TabOrder = 2
        end
        inherited dbmDescription: TDBMemo
          Top = 153
          Height = 68
          TabOrder = 8
        end
        inherited dbcbLang: TDBComboBox
          Top = 224
          TabOrder = 9
        end
        inherited dbtOwner: TDBEdit
          Top = 78
          TabOrder = 3
        end
        inherited dbeLocalName: TDBEdit
          Top = 248
          TabOrder = 10
        end
        inherited pnlRUIDFunction: TPanel
          Left = 329
          Top = 128
          Width = 77
          TabOrder = 7
          inherited btnCopyRUIDFunction: TButton
            Left = 2
            Anchors = []
          end
        end
        object dbcbDisplayInMenu: TDBCheckBox
          Left = 7
          Top = 272
          Width = 230
          Height = 17
          Caption = '���������� � ���� �������� �����'
          DataField = 'DisplayInMenu'
          DataSource = dsMacros
          TabOrder = 11
          ValueChecked = '1'
          ValueUnchecked = '0'
          OnClick = dbeFunctionNameChange
        end
        object edtRUIDMacros: TEdit
          Left = 144
          Top = 103
          Width = 183
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 4
        end
        object pnlRUIDMacros: TPanel
          Left = 329
          Top = 104
          Width = 77
          Height = 21
          Anchors = [akTop, akRight]
          BevelOuter = bvLowered
          TabOrder = 5
          object btnCopyRUIDMacros: TButton
            Left = 2
            Top = 1
            Width = 73
            Height = 19
            Caption = '����������'
            TabOrder = 0
            OnClick = btnCopyRUIDMacrosClick
          end
        end
      end
    end
    inherited tsScript: TSuperTabSheet
      inherited gsFunctionSynEdit: TgsFunctionSynEdit
        Width = 430
        Height = 353
      end
    end
    inherited tsParams: TSuperTabSheet
      inherited ScrollBox: TScrollBox
        Width = 430
        Height = 330
      end
      inherited pnlCaption: TPanel
        Width = 430
      end
    end
    inherited tsDependencies: TSuperTabSheet
      inherited Splitter1: TSplitter
        Height = 406
      end
      inherited pnlDependent: TPanel
        Height = 406
        inherited lbDependent: TListBox
          Height = 389
        end
      end
      inherited pnlDependedFrom: TPanel
        Height = 406
        inherited lbDependedFrom: TListBox
          Height = 389
        end
      end
    end
  end
  inherited DataSource: TDataSource
    Top = 0
  end
  inherited PopupMenu: TPopupMenu
    Left = 296
    Top = 240
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
    Left = 216
    Top = 240
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
    Left = 168
    Top = 216
  end
  inherited pmDependent: TPopupMenu
    Left = 252
    Top = 208
  end
  inherited pmDependedFrom: TPopupMenu
    Left = 205
    Top = 208
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
