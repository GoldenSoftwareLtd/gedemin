inherited frmGedeminProperty: TfrmGedeminProperty
  Left = 342
  Top = 231
  Width = 850
  Height = 401
  HelpContext = 300
  Caption = '�������� ������-��������'
  Font.Name = 'Tahoma'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  inherited VLSplitter: TSplitter
    Left = 17
    Top = 78
    Height = 236
  end
  inherited VRSplitter: TSplitter
    Left = 817
    Top = 78
    Height = 236
  end
  inherited HSplitter: TSplitter
    Top = 323
    Width = 834
  end
  inherited tbdTop: TTBDock
    Width = 834
    Height = 78
    BoundLines = [blBottom]
    object tbtMenu: TTBToolbar
      Left = 0
      Top = 0
      Caption = '����'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 152
      DockRow = 1
      FullSize = True
      MenuBar = True
      ParentShowHint = False
      ProcessShortCuts = True
      ShowHint = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object TBSubmenuItem5: TTBSubmenuItem
        Caption = '&������'
        HelpContext = 310
        object TBItem30: TTBItem
          Action = actPost
          ImageIndex = 9
          Images = imFunction
        end
        object TBItem28: TTBItem
          Action = actSaveAll
          ImageIndex = 202
        end
        object TBItem27: TTBItem
          Action = actCancel
          ImageIndex = 19
          Images = dmImages.il16x16
        end
        object TBSeparatorItem8: TTBSeparatorItem
        end
        object TBItem49: TTBItem
          Action = actSaveToFile
          Images = dmImages.il16x16
        end
        object TBItem50: TTBItem
          Action = actLoadFromFile
          Images = dmImages.il16x16
        end
        object TBSeparatorItem13: TTBSeparatorItem
        end
        object TBItem55: TTBItem
          Action = actCopy
          Images = dmImages.il16x16
        end
        object TBItem54: TTBItem
          Action = actCut
          Images = dmImages.il16x16
        end
        object TBItem53: TTBItem
          Action = actPaste
          Images = dmImages.il16x16
        end
        object TBSeparatorItem16: TTBSeparatorItem
        end
        object TBItem52: TTBItem
          Action = actCopySQL
          ImageIndex = 19
          Images = imFunction
        end
        object TBItem56: TTBItem
          Action = actPasteSQL
          ImageIndex = 20
          Images = imFunction
        end
        object TBSeparatorItem15: TTBSeparatorItem
        end
        object TBItem32: TTBItem
          Action = actClose
          Images = dmImages.il16x16
        end
        object TBItem33: TTBItem
          Action = actCloseAll
        end
        object TBSubmenuItem7: TTBSubmenuItem
          Caption = '�������'
          OnPopup = TBSubmenuItem7Popup
        end
      end
      object TBSubmenuItem2: TTBSubmenuItem
        Caption = '&�����'
        HelpContext = 311
        object TBItem22: TTBItem
          Action = actFind
          Images = dmImages.il16x16
        end
        object TBItem3: TTBItem
          Action = actFindInDB
          Images = dmImages.il16x16
        end
        object TBSeparatorItem7: TTBSeparatorItem
        end
        object TBItem25: TTBItem
          Action = actReplace
          Images = dmImages.il16x16
        end
        object TBSeparatorItem20: TTBSeparatorItem
        end
        object TBItem64: TTBItem
          Action = actFindDelEventsSF
          Images = dmImages.il16x16
        end
        object TBSeparatorItem21: TTBSeparatorItem
        end
        object TBItem65: TTBItem
          Action = actGoToLineNumber
          Images = dmImages.il16x16
        end
      end
      object TBSubmenuItem3: TTBSubmenuItem
        Caption = '&����������'
        HelpContext = 312
        object TBItem48: TTBItem
          Action = actCompaleProject
          Caption = '������������� ������'
        end
        object TBSeparatorItem12: TTBSeparatorItem
        end
        object TBItem37: TTBItem
          Action = actBuildReport
          ImageIndex = 16
          Images = dmImages.il16x16
        end
        object TBSeparatorItem10: TTBSeparatorItem
        end
        object TBItem41: TTBItem
          Action = actDebugRun
          Images = imglActions
        end
        object TBItem34: TTBItem
          Action = actPrepare
          Images = imglActions
        end
        object TBSeparatorItem3: TTBSeparatorItem
        end
        object TBItem40: TTBItem
          Action = actDebugPause
          Images = imglActions
        end
        object TBItem39: TTBItem
          Action = actDebugStepIn
          Images = imglActions
        end
        object TBItem38: TTBItem
          Action = actDebugStepOver
          Images = imglActions
        end
        object TBItem6: TTBItem
          Action = actDebugGotoCursor
          Images = imglActions
        end
        object TBItem26: TTBItem
          Action = actGotoOnExecute
          Images = imglActions
        end
        object TBItem35: TTBItem
          Action = actProgramReset
          Images = imglActions
        end
        object TBSeparatorItem19: TTBSeparatorItem
        end
        object TBItem31: TTBItem
          Action = actToggleBreakpoint
          Images = imglActions
        end
        object TBSeparatorItem1: TTBSeparatorItem
        end
        object TBItem7: TTBItem
          Action = actEvaluate
          Images = imglActions
        end
        object TBItem8: TTBItem
          Action = actAddWatch
          ImageIndex = 39
          Images = dmImages.ilTree
        end
        object TBSeparatorItem17: TTBSeparatorItem
        end
        object TBItem58: TTBItem
          Action = actTypeInformation
        end
      end
      object TBSubmenuItem4: TTBSubmenuItem
        Caption = '������'
        HelpContext = 313
        object TBItem9: TTBItem
          Action = actSettings
          Images = dmImages.il16x16
        end
        object TBItem11: TTBItem
          Action = actEditorSet
          Images = dmImages.il16x16
        end
        object TBItem63: TTBItem
          Action = actCodeTemplates
          Images = dmImages.il16x16
        end
        object TBSeparatorItem14: TTBSeparatorItem
        end
        object TBItem51: TTBItem
          Action = actSQLEditor
          Images = dmImages.il16x16
        end
      end
      object TBSubmenuItem1: TTBSubmenuItem
        Caption = '&����'
        HelpContext = 314
        object TBItem2: TTBItem
          Action = actShowTree
        end
        object TBItem44: TTBItem
          Action = actShowRuntime
        end
        object TBItem47: TTBItem
          Action = actShowClassesInsp
        end
        object TBItem1: TTBItem
          Action = actShowMessages
        end
        object TBItem42: TTBItem
          Action = actShowCallStack
        end
        object TBItem45: TTBItem
          Action = actShowWatchList
        end
        object TBItem46: TTBItem
          Action = actShowBreakPoints
        end
      end
      object TBSubmenuItem6: TTBSubmenuItem
        Caption = '�������'
        object TBItem62: TTBItem
          Action = actVBScripthelp
          Images = dmImages.il16x16
        end
        object TBItem61: TTBItem
          Action = actFastReportHelp
          Images = dmImages.il16x16
        end
        object TBItem60: TTBItem
          Action = actPGHelp
          Images = dmImages.il16x16
        end
        object TBSeparatorItem18: TTBSeparatorItem
        end
        object TBItem57: TTBItem
          Action = actHelp
          Images = dmImages.il16x16
        end
      end
    end
    object tbtTree: TTBToolbar
      Left = 0
      Top = 25
      Caption = '������ ������������'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 0
      DockRow = 1
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 1
      object TBItem5: TTBItem
        Action = actPost
        Caption = '���������'
        ImageIndex = 9
        Images = imFunction
      end
      object TBItem4: TTBItem
        Action = actCancel
        Caption = '����� ���������'
        ImageIndex = 19
        Images = dmImages.il16x16
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object TBItem10: TTBItem
        Action = actSQLEditor
        Caption = 'SQL ��������'
      end
    end
    object tbtSpeedButtons: TTBToolbar
      Left = 0
      Top = 51
      Caption = 'tbtSpeedButtons'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 0
      DockRow = 2
      FullSize = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object TBToolbar5: TTBToolbar
      Left = 85
      Top = 25
      Caption = '������ ������������'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 56
      DockRow = 1
      Images = imglActions
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 3
      object TBItem36: TTBItem
        Action = actBuildReport
        ImageIndex = 16
        Images = dmImages.il16x16
      end
      object TBSeparatorItem9: TTBSeparatorItem
      end
      object TBItem23: TTBItem
        Action = actDebugRun
      end
      object TBItem24: TTBItem
        Action = actDebugPause
      end
      object TBSeparatorItem11: TTBSeparatorItem
      end
      object TBItem17: TTBItem
        Action = actDebugStepIn
      end
      object TBItem29: TTBItem
        Action = actDebugStepOver
      end
    end
    object TBToolbar1: TTBToolbar
      Left = 222
      Top = 25
      Caption = '������ ������������'
      CloseButton = False
      DockMode = dmCannotFloat
      DockPos = 80
      DockRow = 1
      Images = dmImages.il16x16
      ParentShowHint = False
      ShowHint = True
      Stretch = True
      TabOrder = 4
      object TBItem18: TTBItem
        Action = actSaveToFile
        Images = dmImages.il16x16
      end
      object TBItem19: TTBItem
        Action = actLoadFromFile
      end
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object TBItem16: TTBItem
        Action = actFind
      end
      object TBItem15: TTBItem
        Action = actReplace
      end
      object TBItem59: TTBItem
        Action = actFindInDB
      end
      object TBSeparatorItem5: TTBSeparatorItem
      end
      object TBItem14: TTBItem
        Action = actCopy
      end
      object TBItem13: TTBItem
        Action = actCut
        Images = dmImages.il16x16
      end
      object TBItem12: TTBItem
        Action = actPaste
      end
      object TBSeparatorItem6: TTBSeparatorItem
      end
      object TBItem20: TTBItem
        Action = actCopySQL
        ImageIndex = 19
        Images = imFunction
      end
      object TBItem21: TTBItem
        Action = actPasteSQL
        ImageIndex = 20
        Images = imFunction
      end
    end
    object TBToolbar2: TTBToolbar
      Left = 480
      Top = 25
      Caption = 'TBToolbar2'
      DockMode = dmCannotFloat
      DockPos = 456
      DockRow = 1
      TabOrder = 5
      object TBItem43: TTBItem
        Caption = '1'
        OnClick = TBItem43Click
      end
    end
    object tbGetRUID: TTBToolbar
      Left = 508
      Top = 25
      Caption = 'tbGetRUID'
      DockPos = 465
      DockRow = 1
      Images = dmImages.il16x16
      TabOrder = 6
      object TBControlItem1: TTBControlItem
        Control = lblRuidID
      end
      object TBControlItem4: TTBControlItem
        Control = tbeRuidID
      end
      object TBControlItem2: TTBControlItem
        Control = lblRuid
      end
      object TBControlItem5: TTBControlItem
        Control = tbeRuid
      end
      object tbiGetRUID: TTBItem
        Action = actGetRUID
      end
      object lblRuidID: TLabel
        Left = 0
        Top = 4
        Width = 15
        Height = 13
        Caption = 'ID:'
      end
      object lblRuid: TLabel
        Left = 80
        Top = 4
        Width = 32
        Height = 13
        Caption = ' RUID:'
      end
      object tbeRuidID: TEdit
        Left = 15
        Top = 0
        Width = 65
        Height = 21
        TabOrder = 0
      end
      object tbeRuid: TEdit
        Left = 112
        Top = 0
        Width = 125
        Height = 21
        TabOrder = 1
      end
    end
  end
  inherited LeftDockPanel: TPanel
    Top = 78
    Width = 17
    Height = 236
  end
  inherited RightDockPanel: TPanel
    Left = 821
    Top = 78
    Width = 13
    Height = 236
  end
  inherited BottomDockPanel: TPanel
    Top = 327
    Width = 834
    Height = 17
  end
  inherited tbdLeft: TTBDock
    Left = 21
    Top = 78
    Height = 236
  end
  inherited tbdBottom: TTBDock
    Top = 314
    Width = 834
  end
  inherited tbdRight: TTBDock
    Left = 808
    Top = 78
    Height = 236
  end
  inherited StatusBar: TStatusBar
    Top = 344
    Width = 834
    Panels = <
      item
        Alignment = taCenter
        Width = 70
      end
      item
        Style = psOwnerDraw
        Width = 50
      end>
    OnDrawPanel = StatusBarDrawPanel
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 80
    Top = 152
    object actShowTree: TAction
      Category = 'View'
      Caption = '���������'
      Hint = '�������� ������'
      ShortCut = 49236
      OnExecute = actShowTreeExecute
      OnUpdate = actShowTreeUpdate
    end
    object actShowMessages: TAction
      Category = 'View'
      Caption = '���������'
      Hint = '�������� ���� ���������'
      ShortCut = 49229
      OnExecute = actShowMessagesExecute
      OnUpdate = actShowMessagesUpdate
    end
    object actPost: TAction
      Caption = '&���������'
      Hint = '��������� ��������� � ����'
      OnExecute = actPostExecute
      OnUpdate = actPostUpdate
    end
    object actCancel: TAction
      Caption = '&����� ���������'
      Hint = '����� ���������'
      OnExecute = actCancelExecute
      OnUpdate = actPostUpdate
    end
    object actShowWatchList: TAction
      Category = 'View'
      Caption = '������ ����������'
      Hint = '������ ����������'
      ShortCut = 49239
      OnExecute = actShowWatchListExecute
      OnUpdate = actShowWatchListUpdate
    end
    object actFindSfById: TAction
      Category = 'Find'
      Caption = '&����� &������� �� ID'
      Hint = '����� ������� �� ID'
      OnExecute = actFindSfByIdExecute
    end
    object actSettings: TAction
      Category = 'Settings'
      Caption = '�����...'
      Hint = '�����'
      ImageIndex = 30
      OnExecute = actSettingsExecute
    end
    object actFindInDB: TAction
      Category = 'Find'
      Caption = '����� � &���� ������...'
      Hint = '����� � ���� ������'
      ImageIndex = 259
      OnExecute = actFindInDBExecute
    end
    object actSQLEditor: TAction
      Caption = '&SQL ��������'
      Hint = 'SQL ��������'
      ImageIndex = 108
      OnExecute = actSQLEditorExecute
    end
    object actEditorSet: TAction
      Category = 'Settings'
      Caption = '��������� ���������...'
      Hint = '��������� ���������'
      ImageIndex = 28
      OnExecute = actEditorSetExecute
    end
    object actLoadFromFile: TAction
      Category = 'Script'
      Caption = '��������� ������ �� �����...'
      Hint = '��������� ������-������ �� �����'
      ImageIndex = 27
      OnExecute = actLoadFromFileExecute
      OnUpdate = actLoadFromFileUpdate
    end
    object actSaveToFile: TAction
      Category = 'Script'
      Caption = '��������� ������ � ����...'
      Hint = '��������� ������-������ � ����'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
      OnUpdate = actSaveToFileUpdate
    end
    object actFind: TAction
      Category = 'Find'
      Caption = '&�����...'
      Hint = '�����'
      ImageIndex = 23
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
    object actReplace: TAction
      Category = 'Find'
      Caption = '&������...'
      Hint = '������'
      ImageIndex = 22
      OnExecute = actReplaceExecute
      OnUpdate = actFindUpdate
    end
    object actCopy: TAction
      Category = 'Script'
      Caption = '����������'
      Hint = '����������'
      ImageIndex = 10
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object actCut: TAction
      Category = 'Script'
      Caption = '��������'
      Hint = '��������'
      ImageIndex = 9
      OnExecute = actCutExecute
      OnUpdate = actCutUpdate
    end
    object actPaste: TAction
      Category = 'Script'
      Caption = '��������'
      Hint = '��������'
      ImageIndex = 8
      OnExecute = actPasteExecute
      OnUpdate = actPasteUpdate
    end
    object actCopySQL: TAction
      Category = 'Script'
      Caption = '���������� SQL'
      Hint = '���������� SQL'
      OnExecute = actCopySQLExecute
      OnUpdate = actCopySQLUpdate
    end
    object actPasteSQL: TAction
      Category = 'Script'
      Caption = '�������� SQL'
      Hint = '�������� SQL'
      ImageIndex = -2
      OnExecute = actPasteSQLExecute
      OnUpdate = actPasteSQLUpdate
    end
    object actSaveAll: TAction
      Caption = '��������� &���'
      Hint = '��������� ��� ��������� �������'
      OnExecute = actSaveAllExecute
      OnUpdate = actSaveAllUpdate
    end
    object actClose: TAction
      Caption = '&�������'
      Hint = '������� ������������� ������'
      ShortCut = 49267
      OnExecute = actCloseExecute
      OnUpdate = actCloseUpdate
    end
    object actCloseAll: TAction
      Caption = '�&������ ���'
      Hint = '������� ��� �������'
      OnExecute = actCloseAllExecute
      OnUpdate = actCloseAllUpdate
    end
    object actShowCallStack: TAction
      Category = 'View'
      Caption = '���� �������'
      Hint = '���� �������'
      ShortCut = 49235
      OnExecute = actShowCallStackExecute
      OnUpdate = actShowCallStackUpdate
    end
    object actShowRuntime: TAction
      Category = 'View'
      Caption = '����� ����������'
      Hint = '����� ����������'
      ShortCut = 49234
      OnExecute = actShowRuntimeExecute
    end
    object actShowClassesInsp: TAction
      Category = 'View'
      Caption = '��������� �������'
      Hint = '��������� �������'
      ShortCut = 49225
      OnExecute = actShowClassesInspExecute
    end
    object actGotoNext: TAction
      Caption = 'actGotoNext'
      OnExecute = actGotoNextExecute
    end
    object actGotoPrev: TAction
      Caption = 'actGotoPrev'
      OnExecute = actGotoPrevExecute
    end
    object actShowBreakPoints: TAction
      Category = 'View'
      Caption = '����� ���������'
      Hint = '����� ���������'
      ShortCut = 49218
      OnExecute = actShowBreakPointsExecute
    end
    object actHelp: TAction
      Category = 'Help'
      Caption = '�������'
      ImageIndex = 13
      OnExecute = actHelpExecute
    end
    object actTypeInformation: TAction
      Caption = '���������� � ����'
      ImageIndex = 142
      OnExecute = actTypeInformationExecute
    end
    object actVBScripthelp: TAction
      Category = 'Help'
      Caption = '������� �� VBScript'
      ImageIndex = 13
      OnExecute = actVBScripthelpExecute
    end
    object actFastReportHelp: TAction
      Category = 'Help'
      Caption = '������� �� FastReport'
      ImageIndex = 13
      OnExecute = actFastReportHelpExecute
    end
    object actPGHelp: TAction
      Category = 'Help'
      Caption = '����������� �����������'
      ImageIndex = 13
      OnExecute = actPGHelpExecute
    end
    object actCodeTemplates: TAction
      Category = 'Settings'
      Caption = '������� ����'
      ImageIndex = 120
      OnExecute = actCodeTemplatesExecute
    end
    object actFindDelEventsSF: TAction
      Category = 'Find'
      Caption = '����� &�������������� �������...'
      Hint = '����� �������������� �������...'
      ImageIndex = 24
      OnExecute = actFindDelEventsSFExecute
    end
    object actGoToLineNumber: TAction
      Category = 'Find'
      Caption = '������� �� &������...'
      Hint = '������� �� ������...'
      ImageIndex = 140
      OnExecute = actGoToLineNumberExecute
      OnUpdate = actGoToLineNumberUpdate
    end
    object actGetRUID: TAction
      Caption = '�������� RUID'
      ImageIndex = 143
      OnExecute = actGetRUIDExecute
    end
  end
  object imFunction: TImageList
    Left = 48
    Top = 200
    Bitmap = {
      494C010118001D00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000008000000001002000000000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      8000008080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000008000000080000000800000008000
      0000800000008000000080000000800000000000000000808000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000800000008000
      0000800000008000000080000000800000000000000000000000000000000000
      0000800000000000000000000000800000000000000000000000800000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000808000000000000000
      000000FFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000000000000000000000
      0000800000000000000000000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000080808000008080008080
      8000008080008080800080000000FFFFFF000000000000000000000000000000
      00000000000000000000FFFFFF00800000000000000000808000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF0000000000000000000000
      00000000000000000000FFFFFF00800000000000000000000000000000000000
      0000800000000000000000000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000000808000808080000080
      8000808080000080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000808000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000000000000000000000
      0000000000008000000080000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000080808000008080008080
      8000008080008080800080000000FFFFFF00000000000000000000000000FFFF
      FF0080000000800000008000000080000000000000000080800000000000FFFF
      FF000000000000000000FFFFFF00FFFFFF000000000000000000000000000000
      000000000000FFFFFF0080808000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF0000000000000000000000
      00000000000000000000FFFFFF00800000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000800000008000
      0000000000000000000000000000000000000000000000808000808080000080
      8000808080000080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080000000FFFFFF008000000000000000000000000080800000000000FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000080808000000000000000000000000000FFFFFF000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000000000000000
      0000000000000000000000000000000000000000000080808000008080008080
      8000008080008080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00800000008000000000000000000000000000000000808000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000008080800080808000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF000000000000000000FFFF
      FF00800000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000808000808080000080
      8000808080000080800080000000800000008000000080000000800000008000
      0000800000000000000000000000000000000000000000808000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000808080008080800000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080000000FFFFFF0080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000008080008080
      8000008080008080800000808000808080000080800080808000008080008080
      8000008080000000000000000000000000000000000000808000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000808080000080800000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00800000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000808000808080000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080000000000000000000000000000000000000808000FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000FFFFFF000000
      000000000000FFFFFF0000000000800000008000000080000000800000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000808080000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000008080000000000000000000000000000000000000808000FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000080800000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000808000808080000080
      80000000000000FFFF00000000000000000000FFFF0000000000808080000080
      8000808080000000000000000000000000000000000000808000FFFFFF000000
      000080808000000000000000000000000000000000000000000080808000FFFF
      FF000000000000808000000000000000FF000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      00008080800000000000FFFFFF00FFFFFF00FFFFFF0000000000808080000000
      000000808000000000000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      8000008080008080800080808000808080008080800080808000008080000080
      8000000000000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C080600080404000804040008040400080404000804040008040
      4000804040008040400080404000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0806000FFFFFF00F0FBFF00F0FBFF00F0FBFF00F0FBFF00F0CA
      A600F0FBFF00F0CAA60080404000000000000000000000000000000000000000
      000000000000BFBFBF00BFBFBF007F7F7F007F7F7F007F7F7F00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BFBFBF00BFBFBF007F7F7F007F7F7F007F7F7F00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0806000F0FBFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA6008040400000000000000000000000000000000000BFBF
      BF00BFBFBF007F7F7F000000000000000000000000007F7F7F007F7F7F007F7F
      7F0000000000000000000000000000000000000000000000000000000000BFBF
      BF00BFBFBF007F7F7F000000000000000000000000007F7F7F007F7F7F007F7F
      7F00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0806000F0FBFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA60080404000000000000000000000000000BFBFBF00BFBF
      BF0000000000FFFFFF000000FF00FFFFFF000000FF00FFFFFF00000000007F7F
      7F007F7F7F000000000000000000000000000000000000000000BFBFBF00BFBF
      BF0000000000FFFFFF0000FF0000FFFFFF0000FF0000FFFFFF00000000007F7F
      7F007F7F7F000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      00000000000000000000000000000000000000000000C0806000804040008040
      400080404000C0806000FFFFFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA60080604000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00007F7F7F000000000000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00007F7F7F000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0FB
      FF00F0FBFF00C0806000FFFFFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA600806040000000000000000000BFBFBF007F7F7F00FFFF
      FF0000000000000000000000FF0000008000000080000000000000000000FFFF
      FF007F7F7F007F7F7F00000000000000000000000000BFBFBF007F7F7F00FFFF
      FF00000000000000000000FF000000800000008000000000000000000000FFFF
      FF007F7F7F007F7F7F0000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      00000000000000000000000000000000000000000000C0806000F0FBFF00F0CA
      A600F0CAA600C0806000FFFFFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA600806060000000000000000000BFBFBF00000000000000
      FF00000000000000FF00000080000000FF000000800000008000000000000000
      FF00000000007F7F7F00000000000000000000000000BFBFBF000000000000FF
      00000000000000FF00000080000000FF000000800000008000000000000000FF
      0000000000007F7F7F0000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      00000000000000000000000000000000000000000000C0806000F0FBFF00F0CA
      A600F0CAA600C0806000FFFFFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600FFFFFF0000000000806060000000000000000000FFFFFF0000000000FFFF
      FF00000000000000FF000000FF000000FF000000FF000000800000000000FFFF
      FF00000000007F7F7F00000000000000000000000000FFFFFF0000000000FFFF
      FF000000000000FF000000FF000000FF000000FF00000080000000000000FFFF
      FF00000000007F7F7F0000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0CA
      A600F0CAA600C0806000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000C0C0A000A4A0A000806060000000000000000000FFFFFF00000000000000
      FF0000000000FFFFFF000000FF000000FF00000080000000FF00000000000000
      FF0000000000BFBFBF00000000000000000000000000FFFFFF000000000000FF
      000000000000FFFFFF0000FF000000FF00000080000000FF00000000000000FF
      000000000000BFBFBF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0CA
      A600F0CAA600C0806000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C080
      6000C0806000C0806000C08060000000000000000000FFFFFF007F7F7F00FFFF
      FF000000000000000000FFFFFF00FFFFFF000000FF000000000000000000FFFF
      FF007F7F7F00BFBFBF00000000000000000000000000FFFFFF007F7F7F00FFFF
      FF000000000000000000FFFFFF00FFFFFF0000FF00000000000000000000FFFF
      FF007F7F7F00BFBFBF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0CA
      A600F0CAA600C0806000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C080
      6000C0A06000C080600000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000BFBFBF000000000000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0CA
      A600F0CAA600C0806000C0806000C0806000C0806000C0806000C0806000C080
      6000C06060000000000000000000000000000000000000000000FFFFFF00BFBF
      BF0000000000FFFFFF000000FF00FFFFFF000000FF00FFFFFF0000000000BFBF
      BF00BFBFBF000000000000000000000000000000000000000000FFFFFF00BFBF
      BF0000000000FFFFFF0000FF0000FFFFFF0000FF0000FFFFFF0000000000BFBF
      BF00BFBFBF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000C0C0A000A4A0A000806060000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00BFBFBF007F7F7F000000000000000000000000007F7F7F00BFBFBF00BFBF
      BF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00BFBFBF007F7F7F000000000000000000000000007F7F7F00BFBFBF00BFBF
      BF00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C0806000C0806000C0806000C08060000000
      00000000000000000000000000000000FF000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00BFBFBF00BFBFBF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00BFBFBF00BFBFBF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C0806000C0A06000C0806000000000000000
      000000000000000000000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000C0806000C080
      6000C0806000C0806000C0806000C0806000C060600000000000000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      0000840000000000000000000000000000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00848400008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      000000FFFF008484000084000000000000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000840000008400
      00008400000000FFFF0084840000840000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008400000000FF
      FF0000FFFF0000FFFF0000FFFF00848400000000000000000000000000000000
      00008400000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00848400008400000084000000840000000000000084000000840000000000
      0000000000008400000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF008484000084000000000000000000000084000000840000008400
      0000840000008400000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084000000840000008400
      000000FFFF0000FFFF0084840000840000000000000000000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008400000000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00848400000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008400000000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000840000008400
      0000840000008400000084000000840000008400000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008484840000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000084848400FFFF0000000000000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000FFFF00008484
      8400000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000084848400FFFF0000000000000000000084848400000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008400
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF000000000000FFFF0000848484000000
      000000000000000000000000000000000000000000007B7B7B000000FF000000
      FF0000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000840000008400000084000000000000000000000000000000000000008400
      0000848484000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      000000000000848484000000000000000000FFFF000000000000000000000000
      0000000000000000000000000000000000007B7B7B000000FF00000000000000
      00000000000000000000000000000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400FFFF00000000
      0000FFFF00000000000000000000848484008484840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000008400000000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000008484840084848400000000000000
      000084848400FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000000000000000000000000000008400
      0000848484000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000FFFF0000FFFF00000000000000
      00000000000000000000000000000000000084848400FFFF0000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008400000084000000840000008484
      8400000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000000000FFFFFF000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000084848400FFFF00000000
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B7B7B000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000000000FFFFFF00FFFFFF000000000000FFFF000000
      000000000000000000000000000000000000000000008484840000000000FFFF
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007B7B
      7B000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000000000000000000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000A5736B0073424200734242007342420073424200734242007342
      420073424200734242007342420000000000000000000000000000000000188C
      CE00188CCE008C5A5A008C5A5A008C5A5A008C5A5A008C5A5A008C5A5A008C5A
      5A008C5A5A008C5A5A008C5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      000000000000A5736B00FFFFE700F7EFDE00F7EFD600F7EFD600F7EFD600F7E7
      CE00F7EFD600EFDEC60073424200000000000000000000000000188CCE0073C6
      EF0063C6EF00BDB5AD00FFE7D600FFEFDE00F7EFD600F7EFD600F7EFD600F7E7
      D600F7E7CE00F7E7CE008C5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      000000000000A5736B00F7EFDE00F7DEBD00F7D6BD00F7D6BD00EFD6B500EFD6
      B500EFDEBD00E7D6BD00734242000000000000000000188CCE008CE7F7007BEF
      FF0073EFFF00BDB5AD00F7DECE00F7DEC600F7D6B500F7D6B500F7D6B500F7D6
      AD00EFD6B500EFDEC6008C5A5A000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000A5736B00FFEFDE00FFC69400FFC69400FFC69400FFC69400FFC6
      9400FFC69400E7D6BD00734242000000000000000000188CCE008CE7F7007BE7
      FF006BE7FF00BDB5AD00F7E7D600F7DEC600F7D6AD00F7D6AD00F7D6AD00F7CE
      A500F7D6B500EFDEC6008C5A5A000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00734242007342
      420073424200A5736B00FFF7E700F7DEBD00F7D6B500F7D6B500F7D6B500F7D6
      AD00F7DEC600E7D6C60084524A000000000000000000188CCE0094E7F7008CEF
      FF007BEFFF00BDB5AD00F7E7DE00F7DEC600F7D6B500F7D6B500F7D6B500F7D6
      AD00F7D6B500EFDECE008C5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000A5736B00FFFFE700F7EF
      DE00F7EFD600A5736B00FFF7EF00FFDEBD00FFDEBD00FFDEB500F7D6B500F7D6
      B500F7DEC600E7D6C60084524A000000000000000000188CCE00A5E7F7009CEF
      FF008CEFFF00BDB5AD00FFEFE700FFE7D600FFDEC600F7DEC600F7DEBD00F7DE
      BD00F7DEC600EFE7D6008C5A5A00000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00F7EFDE00F7DE
      BD00F7D6BD00A5736B00FFFFF700FFC69400FFC69400FFC69400FFC69400FFC6
      9400FFC69400EFDECE008C5A5A000000000000000000188CCE00ADE7F700ADF7
      FF009CF7FF00BDB5AD00FFF7EF00FFE7C600FFD6AD00FFD6AD00FFD6AD00FFCE
      A500F7DEBD00F7EFDE008C5A5A00000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000000000000000000000000000A5736B00FFEFDE00FFC6
      9400FFC69400A5736B00FFFFFF00FFE7CE00FFE7C600FFDEC600FFDEC600FFE7
      C600FFF7DE00E7D6CE008C5A5A000000000000000000188CCE00B5EFF700BDF7
      FF00ADF7FF00BDB5AD00FFF7F700FFF7EF00FFEFDE00FFEFDE00FFE7D600FFEF
      DE00F7EFDE00E7DED6008C5A5A00000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000000000000000000000000000A5736B00FFF7E700F7DE
      BD00F7D6B500A5736B00FFFFFF00FFFFFF00FFFFFF00FFFFF700FFFFF700E7D6
      D600C6B5AD00A59494009C635A000000000000000000188CCE00C6EFF700D6FF
      FF00BDF7FF00BDB5AD00FFF7F700FFFFFF00FFFFFF00FFFFF700FFFFF700EFE7
      DE00C6ADA500B59C8C008C5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000000000000000000000000000A5736B00FFF7EF00FFDE
      BD00FFDEBD00A5736B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00A573
      6B00A5736B00A5736B00A5736B000000000000000000188CCE00C6EFF700E7FF
      FF00D6FFFF00BDB5AD00FFFFF700FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6BD
      B500D6945200F77B42000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00FFFFF700FFC6
      9400FFC69400A5736B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00A573
      6B00E7A55200B5735A00000000000000000000000000188CCE00CEEFF700F7FF
      FF00E7FFFF00BDB5AD00FFEFE700FFF7EF00FFF7EF00FFEFEF00FFF7EF00DEB5
      A500B59C6B00188CCE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000000000000000000000000000A5736B00FFFFFF00FFE7
      CE00FFE7C600A5736B00A5736B00A5736B00A5736B00A5736B00A5736B00A573
      6B00AD6B6B0000000000000000000000000000000000188CCE00D6EFF700FFFF
      FF00F7FFFF00BDB5AD00BDB5AD00BDB5AD00BDB5AD00BDB5AD00BDB5AD00BDB5
      AD006BB5CE00188CCE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00FFFFFF00FFFF
      FF00FFFFFF00FFFFF700FFFFF700E7D6D600C6B5AD00A59494009C635A000000
      00000000000000000000000000000000000000000000188CCE00D6EFF700F7F7
      F7009CB5BD0094B5BD0094B5BD0094B5BD008CB5BD008CB5BD009CC6CE00D6FF
      FF006BCEF700188CCE0000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00A5736B00A5736B00A5736B00A5736B000000
      00000000000000000000000000000000000000000000188CCE00DEF7FF00D6BD
      B500AD8C8400C6B5AD00C6B5AD00C6B5AD00C6B5AD00C6ADA500A5847B00DEE7
      DE007BD6F700188CCE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000A5736B00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00A5736B00E7A55200B5735A00000000000000
      0000000000000000000000000000000000000000000000000000188CCE00A5C6
      DE007B848C00DECEC600FFF7F700F7F7F700F7F7F700C6B5AD006B848C0073C6
      E700188CCE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00A5736B00A573
      6B00A5736B00A5736B00A5736B00A5736B00AD6B6B0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000188C
      CE00188CCE008C7B6B008C7B6B008C7B6B008C7B6B008C7B6B00188CCE00188C
      CE00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400000000000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00840000008400000084000000840000008400
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF000000
      0000008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000FFFF00FFFF
      FF00000000000084840000848400008484000084840000848400008484000084
      8400008484000084840000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00840000008400000084000000840000008400
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF000000000000848400008484000084840000848400008484000084
      8400008484000084840000848400000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00FFFFFF0000FFFF0000FFFF00000000008484
      8400000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000084840000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00840000008400000084000000840000008400
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000000000000000
      0000000000000000000000FFFF00FFFFFF0000FFFF0000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF00FFFFFF0000FFFF00000000008484
      8400000000000000000000000000000000000000000000FFFF00000000000000
      000084848400FFFFFF0000FFFF00840000008400000084000000840000008400
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000008484000000000000000000000000000000000000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF000000
      0000848484000000000000000000000000000000000084848400000000000000
      00008484840000FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      0000FFFFFF0000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0084848400FFFFFF00FFFFFF00840000008400000084000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000848484000000
      0000000000000000000000000000000000000000000084848400848484008484
      8400FFFFFF0000FFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484
      8400FFFFFF008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000008484
      8400000000000000000000000000000000000000000000FFFF00FFFFFF008484
      840000FFFF00FFFFFF008484840000FFFF00FFFFFF00FFFFFF00FFFFFF008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF000000
      00008484840000000000000000000000000000000000000000008484840000FF
      FF008484840000FFFF00000000008484840000FFFF0084848400848484008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000FFFF00FFFFFF00FFFFFF0000FFFF00FFFF
      FF0000000000848484000000000000000000000000008484840000FFFF00FFFF
      FF00848484000000000000000000000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF00FFFF
      FF008484840000FFFF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000800000000100010000000000000400000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000E001FFFFFFFFFFFFDC01FFFFF9FFFC00
      BDFDFE00F6CF8000B5FDFE00F6B70000BDFDFE00F6B70000BC798000F8B70000
      ACF98000FE8F0001A4058000FE3F000384098000FF7F000384138001FE3F0003
      84138003FEBF000387FB8007FC9F0FC38FEB807FFDDF000397CA80FFFDDF8007
      D45481FFFDDFF87FE008FFFFFFFFFFFFFFFFFFFFFEFFF801F83FF83FFEFFF801
      E00FE00FFC7FF801C007C007FC7FF80180038003F83F800180038003F83F8001
      00010001F01F800100010001F01F800500010001E00F801100010001E00F8001
      00010001FC7F800380038003FC7F800780038003FC7F811FC007C007FC7F801E
      E00FE00FFC7F803CF83FF83FFC7F8078FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFE7E7FF3FFFFFFFFFE3FFFC3FFCFFFFFFE1E7F03FFC3FFFFF
      C0E7C000FC0FFFFFC0F700000003FFFFE09BC0000000EFFFE183F03F0003C7FF
      80C7FC3FFC0F83FF80FFFF3FFC3FFFFFC07FFFFFFCFFFFFFC01FFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3FFFFFFFFFFFFF
      FE2FF9FFFFFFFE3FF80FF0FFFFFFFC1FF807F0FFFFFFFC1FF287E07FFFFFFE7F
      F807C07FFFCFFC3FC28F843FE1E7FC3F800F1E3FE7F7FC3F941FFE1FEBF7FC1F
      003FFF1FFCE7F00F14FFFF8FFF0FE00795FFFFC7FFFFE00781FFFFE3FFFFE007
      C3FFFFF8FFFFF00FFFFFFFFFFFFFF81FFFFFFFFFF801E001FFFF0001F801C001
      07C10001F801800107C1FFFFF801800107C107C180018001010107C180018001
      0001010180018001020100018001800102010201800180018003020180018003
      C107800380038003C107C10780078003E38FC107801F8003E38FE38F801F8003
      E38FE38F803FC007FFFFE38F807FE00FFFFFFFFFF9FFF001800FC001F8FFF001
      80078001FC7FF00180038001FC3FF00180018001F01FF00180008001F00FF001
      80008001F80FF001800F8001F81FF001800F8001C00FB001800F8001C007B001
      C7F88001E00FE001FFFC8001E01F8003FFBA8001F00F8007FFC78001F007C20F
      FFFF8001F803877FFFFFFFFFF80383FF00000000000000000000000000000000
      000000000000}
  end
  object imglActions: TImageList
    Left = 96
    Top = 216
    Bitmap = {
      494C010112001300040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000005000000001002000000000000050
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000000000C0C0C0000000000000000000C0C0C000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000000000C0C0C0000000000000000000C0C0C000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000080808000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000000000C0C0C0000000000000000000C0C0C000000000000000
      0000C0C0C000C0C0C00000000000000000000000000080808000000000008080
      8000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000000000C0C0C0000000000000000000C0C0C000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0008000
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0008000
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0008000
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0008000
      0000800000008000000080000000800000008000000080000000800000008000
      000080000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000800000008000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000800000008000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000808080008080800080808000808080008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000800000008000000080000000800000008000
      0000808080000000000000000000000000000000000000000000000000000000
      0000800000008000000080000000800000008000000080000000800000008080
      8000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000808080008080
      8000808080008080800000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000800000008000
      0000800000008000000080808000000000000000000080000000800000008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C0C0C0000000000000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000000000000000000000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00808080000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000800000008000000080000000800000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000080000000800000008000000080000000800000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000FFFFFF000000000000000000FFFFFF008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF000000000000000000FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      8000800000008080800000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000000000000000000000000000080000000808080008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000FF000000FF000000FF000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C0C0C00080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000000000008000000080000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000080808000FFFFFF0080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF000000000000000000C0C0C000808080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      800000000000000000000000FF00000000008000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C00000FF0000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      8000000000000000FF000000FF000000FF008000000080000000000000000000
      000080808000FFFFFF0080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      800000000000000000000000FF00000000008000000080000000800000000000
      000080808000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FF000000FFFFFF00FFFFFF00FF000000FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      800000000000000000000000FF00000000008000000080000000800000000000
      000080808000FF000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FF0000000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FF000000FFFFFF00FFFFFF00FF000000FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0C00000FF
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      8000000000000000000000000000000000008000000080000000000000000000
      000080808000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FF000000FFFFFF00FFFFFF00FF000000FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      800000000000000000000000FF00000000008000000000000000000000000000
      000080808000FFFFFF0080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000000000008000000080000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C00000FF0000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      800000000000000000000000FF00000000000000000000000000000000000000
      000080808000FFFFFF0080808000808080008080800080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C0C0C000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000C0C0C000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000008000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF00000000000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF00000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000800000008000000080000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      8000000080000000000000000000FFFFFF00FFFFFF008080800000008000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080008000
      0000800000008000000080000000800000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      80000000800080808000FFFFFF00FFFFFF00808080000000800080808000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000080008080800080808000FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00000080000000800080808000FFFFFF000000800000008000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FF000000FF00000000008000000080008080800080808000808080000000
      0000000000008000000000008000808080000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF008080800000008000000080000000800000008000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000000080000000800080808000808080000000
      000000000000800000000000800080808000000000000000000000000000FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF000000000000008000000080000000800000000000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000080000000800000008000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000000080000000800080808000808080000000
      0000000080000000800080808000000000000000000000000000FFFFFF00FFFF
      FF000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF00000000008080
      80000000800000008000000080000000800080808000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000008000000080000000800000008000000080000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00808080000000800000008000808080008080
      8000000080000000800000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF00000080000000
      800000008000808080000000000000008000000080008080800000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF0000000000800000008000000080000000
      8000000080008000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF00000080000000800080808000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800000008000000080000000
      8000808080008000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF000000000000008000000080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FF000000FF00
      0000FF000000FFFFFF0080808000808080000000800000008000000080000000
      8000808080008000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF00000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000800000008000FFFFFF00FFFFFF00808080000000
      8000000080008080800080808000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000008000000000000000000000000000
      0000000000000000000080000000808080000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008080
      8000000080000000800080808000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080000000800000008000
      0000800000008000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000800000008000808080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008000
      0000FF0000000000000080000000FF00000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080008000
      0000800000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF0080808000FF00
      00008000000000000000FF0000008000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008000
      0000FF0000000000000080000000FF00000080808000FFFFFF00FFFFFF00FFFF
      FF00FF000000FF000000FF000000FF000000FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FF000000FF000000FF000000FF000000FFFFFF00FFFFFF0080808000FF00
      00008000000000000000FF0000008000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008000
      0000FF0000000000000080000000FF00000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000080000000000000000000000000000000000000008000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF0080808000FF00
      00008000000000000000FF0000008000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000008000000080000000800000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008000
      0000FF0000000000000080000000FF00000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000008000000080000000800000008000
      0000800000008000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FF000000FF00
      0000FF000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000008000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FF000000FF00
      0000FF000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000000000000000000000000000000000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000080808000800000008000
      0000800000008000000080000000800000008000000080000000800000008000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000500000000100010000000000800200000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF000000008001F80300000000
      8001973B000000008001B10B000000008001B52B000000008001A00300000000
      80018FE7000000008001FFFF000000008001FFFF000000008001FFFF00000000
      8001FFE7000000008001FFE7000000008001FF81000000008001FF8100000000
      8001FFE700000000FFFFFFE700000000FC07F80FFFFFFFFFF807F00FE1C3000F
      F807F00FC183000FF807F00FC183000FF807F00FC183000FF807F00FC183000F
      F807F00FC183000FF80FF01FC183000FFF7FFFFBC183001FFE3FFFF1C183001F
      FC1FFFE0C183000FFFFFFFFFC1830007FEFF7FFBC1830013FFFFFFFFC183003F
      FDFFDFEFC183007F6FFFFB7FC387FFFFFFFFFFFFE00FFFFFFFFFF9FFEFEFF000
      8001F8FFEFE8F0008001F87FE92FF0008001F83FEEED70008001F81FEEE83000
      8001F80FEEED10008001F807EEED10008001F807EEEF30008001F80FEEED7000
      8001F81FE92FF0008001F83F6FEDF0008001F87F200FF0008001F8FF1FFDF001
      8001F9FF3FFFF003FFFFFFFF7FFFF007FFFFFFFFFFFFFFFF001FFFFFEFFFE7CF
      001BF807E403CFE70011F807E403CFE70000F003C001CFE7001BE003C001CFE7
      0018E00380019EF30018C0030001CC67001180030001C827000388030001CEE7
      0003F8038003CEE70003F803C007E6CF0003F807C00FFEFF0001F80FC03F7CFF
      0001FC1FE0FF01FF0018FE7FF3FFFFFFFFFFFFFFFFFFFFFF001FFFFFFFFF001F
      001BF27FFE73001F0011E73FFCF900040000E73FFCF90004001BE73FFCF90004
      001BE73FFCF90004001BCF9BF9FC0004001BE731ECF90004001BE720E4F90004
      001BE73B00F9001F001BE73BE4F9001F001BF27BEE73001F001BFFFBFFFF001F
      001FBFF3FFFF001F001F8007FFFF001F00000000000000000000000000000000
      000000000000}
  end
  object actlDebug: TActionList
    Images = imglActions
    Left = 112
    Top = 152
    object actDebugRun: TAction
      Category = 'Debug'
      Caption = '&���������'
      Hint = '������ �������'
      ImageIndex = 9
      ShortCut = 120
      OnExecute = actDebugRunExecute
      OnUpdate = actDebugRunUpdate
    end
    object actDebugStepIn: TAction
      Category = 'Debug'
      Caption = '��� &�'
      Hint = '������� � ���������'
      ImageIndex = 12
      ShortCut = 118
      OnExecute = actDebugStepInExecute
      OnUpdate = actDebugRunUpdate
    end
    object actDebugStepOver: TAction
      Category = 'Debug'
      Caption = '��� &�����'
      Hint = '��������� ��� ��������� � ���������'
      ImageIndex = 13
      ShortCut = 119
      OnExecute = actDebugStepOverExecute
      OnUpdate = actDebugRunUpdate
    end
    object actDebugGotoCursor: TAction
      Category = 'Debug'
      Caption = '������� � &�������'
      Hint = '��������� �� �������� ��������� �������'
      ImageIndex = 10
      ShortCut = 115
      OnExecute = actDebugGotoCursorExecute
      OnUpdate = actDebugStepInUpdate
    end
    object actDebugPause: TAction
      Category = 'Debug'
      Caption = '&�����'
      Hint = '�����'
      ImageIndex = 14
      OnExecute = actDebugPauseExecute
      OnUpdate = actDebugPauseUpdate
    end
    object actProgramReset: TAction
      Category = 'Debug'
      Caption = '&����� ���������'
      Hint = '����� ���������'
      ImageIndex = 8
      ShortCut = 16497
      OnExecute = actProgramResetExecute
      OnUpdate = actProgramResetUpdate
    end
    object actToggleBreakpoint: TAction
      Category = 'Debug'
      Caption = '&����������/����� ����� ��������'
      Hint = '����������/����� ����� ��������'
      ImageIndex = 5
      ShortCut = 116
      OnExecute = actToggleBreakpointExecute
      OnUpdate = actToggleBreakpointUpdate
    end
    object actEvaluate: TAction
      Caption = '&���������...'
      Hint = '��������� ���������'
      ImageIndex = 16
      ShortCut = 16499
      OnExecute = actEvaluateExecute
      OnUpdate = actEvaluateUpdate
    end
    object actPrepare: TAction
      Category = 'Debug'
      Caption = '�������� ����������'
      Hint = '�������� ����������'
      ImageIndex = 15
      OnExecute = actPrepareExecute
      OnUpdate = actPrepareUpdate
    end
    object actGotoOnExecute: TAction
      Category = 'Debug'
      Caption = '������� �� ����������� �&�����'
      Hint = '������� �� ����������� ������'
      ImageIndex = 11
      OnExecute = actGotoOnExecuteExecute
      OnUpdate = actGotoOnExecuteUpdate
    end
    object actBuildReport: TAction
      Caption = '��������� &�����'
      Hint = '��������� �����'
      ShortCut = 49272
      OnExecute = actBuildReportExecute
      OnUpdate = actBuildReportUpdate
    end
    object actAddWatch: TAction
      Caption = '�������� � �������� �&���������'
      ShortCut = 16500
      OnExecute = actAddWatchExecute
    end
    object actCompaleProject: TAction
      Caption = 'actCompaleProject'
      OnExecute = actCompaleProjectExecute
      OnUpdate = actCompaleProjectUpdate
    end
    object actTypeInfo: TAction
      Category = 'Debug'
      Caption = 'actTypeInfo'
    end
  end
  object SynVBScriptSyn: TSynVBScriptSyn
    DefaultFilter = 'VBScript files (*.vbs)|*.vbs'
    CommentAttri.Foreground = clRed
    NumberAttri.Style = [fsUnderline]
    StringAttri.Foreground = clBlue
    Left = 144
    Top = 200
  end
end
