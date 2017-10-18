inherited gdc_attr_dlgView: Tgdc_attr_dlgView
  Left = 901
  Top = 378
  Width = 541
  HelpContext = 80
  Caption = 'Редактирование представления'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 474
  end
  inherited btnNew: TButton
    Top = 474
  end
  inherited btnHelp: TButton
    Top = 474
  end
  inherited btnOK: TButton
    Top = 474
  end
  inherited btnCancel: TButton
    Left = 448
    Top = 474
  end
  inherited pcRelation: TPageControl
    Width = 517
    Height = 470
    inherited tsCommon: TTabSheet
      Caption = 'Представление'
      inherited lblTableName: TLabel
        Width = 133
        Caption = 'Название представления:'
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
      inherited lblBranch: TLabel
        Visible = False
      end
      inherited Label5: TLabel
        Visible = False
      end
      inherited Label6: TLabel
        Visible = False
      end
      inherited iblcExplorerBranch: TgsIBLookupComboBox
        Visible = False
      end
      inherited lClass: TEdit
        Visible = False
      end
      inherited lSubType: TEdit
        Visible = False
      end
      inherited Panel8: TPanel
        Top = 394
        Width = 509
        inherited lblWarn: TLabel
          Width = 501
        end
      end
    end
    object tsView: TTabSheet [1]
      BorderWidth = 2
      Caption = 'Текст представления'
      ImageIndex = 3
      object smViewBody: TSynMemo
        Left = 0
        Top = 0
        Width = 505
        Height = 438
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
        WantTabs = True
      end
    end
    inherited tsFields: TTabSheet
      inherited ibgrTableField: TgsIBGrid
        Width = 505
        Height = 412
      end
      inherited TBDock1: TTBDock
        Width = 505
      end
    end
    inherited tsTriggers: TTabSheet
      inherited Panel1: TPanel
        Width = 505
        Height = 438
        inherited splTrigger: TSplitter
          Width = 505
        end
        inherited Panel2: TPanel
          Width = 505
          inherited ibgrTrigger: TgsIBGrid
            Width = 505
          end
          inherited TBDock2: TTBDock
            Width = 505
          end
        end
        inherited Panel3: TPanel
          Width = 505
          Height = 294
          inherited dbseTriggerBody: TDBSynEdit
            Width = 505
            Height = 267
          end
          inherited Panel6: TPanel
            Width = 505
          end
        end
      end
    end
    inherited tsIndices: TTabSheet
      TabVisible = False
    end
    inherited tsConstraints: TTabSheet
      inherited ibgrCheckConstraint: TgsIBGrid
        Width = 505
        Height = 311
      end
      inherited TBDock4: TTBDock
        Width = 505
      end
      inherited dbseConstraint: TDBSynEdit
        Top = 342
        Width = 505
      end
      inherited Panel7: TPanel
        Top = 337
        Width = 505
      end
    end
    inherited tsScript: TTabSheet
      inherited smScriptText: TSynMemo
        Width = 505
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
    end
  end
end
