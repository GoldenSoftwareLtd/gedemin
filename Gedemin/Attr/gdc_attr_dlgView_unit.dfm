inherited gdc_attr_dlgView: Tgdc_attr_dlgView
  Left = 628
  Top = 305
  Width = 534
  HelpContext = 80
  Caption = 'Редактирование представления'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 474
    TabOrder = 3
  end
  inherited btnNew: TButton
    Top = 474
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Top = 474
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 367
    Top = 474
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 441
    Top = 474
    TabOrder = 2
  end
  inherited pcRelation: TPageControl
    Width = 510
    Height = 470
    TabOrder = 0
    OnChange = pcRelationChange
    inherited tsCommon: TTabSheet
      Caption = 'Представление'
      inherited lblTableName: TLabel
        Width = 251
        Caption = 'Название представления (на английском языке):'
      end
      inherited lblLName: TLabel
        Width = 219
        Caption = 'Локализованное название представления:'
      end
      inherited lblLShortName: TLabel
        Width = 178
        Caption = 'Краткое название представления:'
      end
      inherited lblDescription: TLabel
        Width = 134
        Caption = 'Описание представления:'
      end
      inherited dbedRelationName: TDBEdit
        Left = 264
        Width = 237
      end
      inherited dbedLRelationName: TDBEdit
        Left = 264
        Width = 237
      end
      inherited dbeShortRelationName: TDBEdit
        Left = 264
        Width = 237
      end
      inherited dbeRelationDescription: TDBMemo
        Left = 264
        Width = 237
      end
      inherited ibcmbReference: TgsIBLookupComboBox
        Left = 264
        Width = 237
      end
      inherited iblcExplorerBranch: TgsIBLookupComboBox
        Left = 264
        Width = 237
      end
      inherited dbeExtendedFields: TDBEdit
        Left = 264
        Width = 237
      end
      inherited dbeListField: TDBEdit
        Left = 264
        Width = 237
      end
      inherited lClass: TEdit
        Left = 264
      end
      inherited lSubType: TEdit
        Left = 264
      end
    end
    object tsView: TTabSheet [1]
      BorderWidth = 2
      Caption = 'Текст представления'
      ImageIndex = 3
      object smViewBody: TSynMemo
        Left = 0
        Top = 0
        Width = 498
        Height = 397
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 0
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = SynSQLSyn
        Keystrokes = <
          item
            Command = ecUp
            ShortCut = 38
          end
          item
            Command = ecSelUp
            ShortCut = 8230
          end
          item
            Command = ecScrollUp
            ShortCut = 16422
          end
          item
            Command = ecDown
            ShortCut = 40
          end
          item
            Command = ecSelDown
            ShortCut = 8232
          end
          item
            Command = ecScrollDown
            ShortCut = 16424
          end
          item
            Command = ecLeft
            ShortCut = 37
          end
          item
            Command = ecSelLeft
            ShortCut = 8229
          end
          item
            Command = ecWordLeft
            ShortCut = 16421
          end
          item
            Command = ecSelWordLeft
            ShortCut = 24613
          end
          item
            Command = ecRight
            ShortCut = 39
          end
          item
            Command = ecSelRight
            ShortCut = 8231
          end
          item
            Command = ecWordRight
            ShortCut = 16423
          end
          item
            Command = ecSelWordRight
            ShortCut = 24615
          end
          item
            Command = ecPageDown
            ShortCut = 34
          end
          item
            Command = ecSelPageDown
            ShortCut = 8226
          end
          item
            Command = ecPageBottom
            ShortCut = 16418
          end
          item
            Command = ecSelPageBottom
            ShortCut = 24610
          end
          item
            Command = ecPageUp
            ShortCut = 33
          end
          item
            Command = ecSelPageUp
            ShortCut = 8225
          end
          item
            Command = ecPageTop
            ShortCut = 16417
          end
          item
            Command = ecSelPageTop
            ShortCut = 24609
          end
          item
            Command = ecLineStart
            ShortCut = 36
          end
          item
            Command = ecSelLineStart
            ShortCut = 8228
          end
          item
            Command = ecEditorTop
            ShortCut = 16420
          end
          item
            Command = ecSelEditorTop
            ShortCut = 24612
          end
          item
            Command = ecLineEnd
            ShortCut = 35
          end
          item
            Command = ecSelLineEnd
            ShortCut = 8227
          end
          item
            Command = ecEditorBottom
            ShortCut = 16419
          end
          item
            Command = ecSelEditorBottom
            ShortCut = 24611
          end
          item
            Command = ecToggleMode
            ShortCut = 45
          end
          item
            Command = ecCopy
            ShortCut = 16429
          end
          item
            Command = ecPaste
            ShortCut = 8237
          end
          item
            Command = ecDeleteChar
            ShortCut = 46
          end
          item
            Command = ecCut
            ShortCut = 8238
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8200
          end
          item
            Command = ecDeleteLastWord
            ShortCut = 16392
          end
          item
            Command = ecUndo
            ShortCut = 32776
          end
          item
            Command = ecRedo
            ShortCut = 40968
          end
          item
            Command = ecLineBreak
            ShortCut = 13
          end
          item
            Command = ecSelectAll
            ShortCut = 16449
          end
          item
            Command = ecCopy
            ShortCut = 16451
          end
          item
            Command = ecBlockIndent
            ShortCut = 24649
          end
          item
            Command = ecLineBreak
            ShortCut = 16461
          end
          item
            Command = ecInsertLine
            ShortCut = 16462
          end
          item
            Command = ecDeleteWord
            ShortCut = 16468
          end
          item
            Command = ecBlockUnindent
            ShortCut = 24661
          end
          item
            Command = ecPaste
            ShortCut = 16470
          end
          item
            Command = ecCut
            ShortCut = 16472
          end
          item
            Command = ecDeleteLine
            ShortCut = 16473
          end
          item
            Command = ecDeleteEOL
            ShortCut = 24665
          end
          item
            Command = ecUndo
            ShortCut = 16474
          end
          item
            Command = ecRedo
            ShortCut = 24666
          end
          item
            Command = ecGotoMarker0
            ShortCut = 16432
          end
          item
            Command = ecGotoMarker1
            ShortCut = 16433
          end
          item
            Command = ecGotoMarker2
            ShortCut = 16434
          end
          item
            Command = ecGotoMarker3
            ShortCut = 16435
          end
          item
            Command = ecGotoMarker4
            ShortCut = 16436
          end
          item
            Command = ecGotoMarker5
            ShortCut = 16437
          end
          item
            Command = ecGotoMarker6
            ShortCut = 16438
          end
          item
            Command = ecGotoMarker7
            ShortCut = 16439
          end
          item
            Command = ecGotoMarker8
            ShortCut = 16440
          end
          item
            Command = ecGotoMarker9
            ShortCut = 16441
          end
          item
            Command = ecSetMarker0
            ShortCut = 24624
          end
          item
            Command = ecSetMarker1
            ShortCut = 24625
          end
          item
            Command = ecSetMarker2
            ShortCut = 24626
          end
          item
            Command = ecSetMarker3
            ShortCut = 24627
          end
          item
            Command = ecSetMarker4
            ShortCut = 24628
          end
          item
            Command = ecSetMarker5
            ShortCut = 24629
          end
          item
            Command = ecSetMarker6
            ShortCut = 24630
          end
          item
            Command = ecSetMarker7
            ShortCut = 24631
          end
          item
            Command = ecSetMarker8
            ShortCut = 24632
          end
          item
            Command = ecSetMarker9
            ShortCut = 24633
          end
          item
            Command = ecNormalSelect
            ShortCut = 24654
          end
          item
            Command = ecColumnSelect
            ShortCut = 24643
          end
          item
            Command = ecLineSelect
            ShortCut = 24652
          end
          item
            Command = ecTab
            ShortCut = 9
          end
          item
            Command = ecShiftTab
            ShortCut = 8201
          end
          item
            Command = ecMatchBracket
            ShortCut = 24642
          end>
      end
      object Panel4: TPanel
        Left = 0
        Top = 397
        Width = 498
        Height = 41
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object Panel5: TPanel
          Left = 392
          Top = 0
          Width = 106
          Height = 41
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 0
          object btnCreateView: TButton
            Left = 19
            Top = 14
            Width = 75
            Height = 21
            Action = actCreateView
            Anchors = [akRight, akBottom]
            TabOrder = 0
          end
        end
      end
    end
    inherited tsFields: TTabSheet
      inherited ibgrRelationFields: TgsIBGrid
        Height = 412
      end
    end
    inherited tsTrigger: TTabSheet
      inherited Panel1: TPanel
        Width = 498
        Height = 438
        inherited Splitter1: TSplitter
          Width = 498
        end
        inherited Panel2: TPanel
          Width = 498
          inherited tvTriggers: TTreeView
            Width = 498
          end
        end
        inherited Panel3: TPanel
          Width = 498
          Height = 321
          inherited smTriggerBody: TSynMemo
            Height = 295
          end
        end
      end
    end
    inherited tsIndices: TTabSheet
      TabVisible = False
    end
    inherited tsConstraints: TTabSheet
      inherited ibgrConstraints: TgsIBGrid
        Height = 412
      end
    end
    inherited tsScript: TTabSheet
      inherited smScriptText: TSynMemo
        Height = 438
      end
    end
  end
  inherited alBase: TActionList
    inherited actNewField: TAction
      Visible = False
    end
    inherited actDeleteField: TAction
      Visible = False
    end
    object actCreateView: TAction
      Caption = 'Создать'
      ImageIndex = 34
      OnExecute = actCreateViewExecute
      OnUpdate = actCreateViewUpdate
    end
  end
end
