object gdcc_frmMain: Tgdcc_frmMain
  Left = 582
  Top = 261
  Width = 873
  Height = 507
  Caption = 'Gedemin Control Center'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tbDockTop: TTBDock
    Left = 0
    Top = 0
    Width = 857
    Height = 51
    object tbMenu: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'tbMenu'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 8
      FullSize = True
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object TBSubmenuItem1: TTBSubmenuItem
        Caption = '����'
        object TBItem5: TTBItem
          Action = actSaveLogToFile
        end
        object TBSeparatorItem5: TTBSeparatorItem
        end
        object TBItem1: TTBItem
          Action = actClose
        end
      end
      object TBSubmenuItem2: TTBSubmenuItem
        Caption = '��������'
        object TBItem2: TTBItem
          Action = actShowOrHide
        end
        object TBSeparatorItem6: TTBSeparatorItem
        end
        object TBItem6: TTBItem
          Action = actViewLog
        end
        object TBItem7: TTBItem
          Action = actViewProfiler
        end
        object TBSeparatorItem7: TTBSeparatorItem
        end
        object TBItem8: TTBItem
          Action = actAutoUpdate
        end
      end
      object TBItem11: TTBItem
        Action = actAbout
      end
    end
    object tbConnections: TTBToolbar
      Left = 0
      Top = 25
      Caption = 'tbConnections'
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 8
      DockRow = 1
      FullSize = True
      TabOrder = 1
    end
  end
  object pc: TPageControl
    Left = 0
    Top = 51
    Width = 857
    Height = 396
    ActivePage = tsLog
    Align = alClient
    Style = tsButtons
    TabOrder = 1
    object tsLog: TTabSheet
      Caption = 'tsLog'
      TabVisible = False
      object pnlLog: TPanel
        Left = 0
        Top = 0
        Width = 849
        Height = 386
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object SplitLog: TSplitter
          Left = 660
          Top = 25
          Width = 4
          Height = 361
          Cursor = crHSplit
          Align = alRight
        end
        object lvLog: TListView
          Left = 0
          Top = 25
          Width = 660
          Height = 361
          Align = alClient
          Columns = <
            item
              Caption = '�����'
              Width = 70
            end
            item
              Caption = '��������'
              Width = 92
            end
            item
              AutoSize = True
              Caption = '���������'
            end>
          HideSelection = False
          OwnerData = True
          ReadOnly = True
          RowSelect = True
          ParentShowHint = False
          ShowHint = False
          StateImages = il
          TabOrder = 0
          ViewStyle = vsReport
          OnData = lvLogData
          OnDataHint = lvLogDataHint
          OnResize = lvLogResize
          OnSelectItem = lvLogSelectItem
        end
        object mLog: TMemo
          Left = 664
          Top = 25
          Width = 185
          Height = 361
          Align = alRight
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 1
        end
        object tbdLog: TTBDock
          Left = 0
          Top = 0
          Width = 849
          Height = 25
          object tbCommands: TTBToolbar
            Left = 0
            Top = 0
            BorderStyle = bsNone
            Caption = 'tbCommands'
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 8
            DockRow = 2
            FullSize = True
            Images = il
            Options = [tboShowHint, tboToolbarStyle]
            TabOrder = 0
            object TBControlItem1: TTBControlItem
              Control = Label1
            end
            object TBControlItem2: TTBControlItem
              Control = edLogFilter
            end
            object TBSeparatorItem1: TTBSeparatorItem
            end
            object TBControlItem3: TTBControlItem
              Control = Label2
            end
            object TBControlItem8: TTBControlItem
              Control = cbLogSources
            end
            object TBControlItem5: TTBControlItem
              Control = chbxError
            end
            object TBSeparatorItem3: TTBSeparatorItem
            end
            object TBControlItem6: TTBControlItem
              Control = chbxWarning
            end
            object TBSeparatorItem2: TTBSeparatorItem
            end
            object TBControlItem7: TTBControlItem
              Control = chbxInfo
            end
            object TBSeparatorItem4: TTBSeparatorItem
            end
            object TBItem4: TTBItem
              Action = actClearLogFilter
            end
            object TBItem3: TTBItem
              Action = actSetLogFilter
              DisplayMode = nbdmImageAndText
            end
            object TBSeparatorItem12: TTBSeparatorItem
            end
            object TBItem12: TTBItem
              Action = actClearLogData
            end
            object Label1: TLabel
              Left = 0
              Top = 4
              Width = 51
              Height = 13
              Caption = ' ������:  '
            end
            object Label2: TLabel
              Left = 149
              Top = 4
              Width = 61
              Height = 13
              Caption = ' ��������:  '
            end
            object edLogFilter: TEdit
              Left = 51
              Top = 0
              Width = 92
              Height = 21
              TabOrder = 0
            end
            object chbxError: TCheckBox
              Left = 302
              Top = 2
              Width = 65
              Height = 17
              Alignment = taLeftJustify
              Caption = '  ������'
              Checked = True
              State = cbChecked
              TabOrder = 1
            end
            object chbxWarning: TCheckBox
              Left = 373
              Top = 2
              Width = 112
              Height = 17
              Alignment = taLeftJustify
              Caption = ' ��������������'
              Checked = True
              State = cbChecked
              TabOrder = 2
            end
            object chbxInfo: TCheckBox
              Left = 491
              Top = 2
              Width = 88
              Height = 17
              Alignment = taLeftJustify
              Caption = ' ����������'
              Checked = True
              State = cbChecked
              TabOrder = 3
            end
            object cbLogSources: TComboBox
              Left = 210
              Top = 0
              Width = 92
              Height = 21
              ItemHeight = 13
              TabOrder = 4
            end
          end
        end
      end
    end
    object tsProfiler: TTabSheet
      Caption = 'tsProfiler'
      ImageIndex = 1
      TabVisible = False
      object pnlProfiler: TPanel
        Left = 0
        Top = 0
        Width = 849
        Height = 386
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object SplitProfiler: TSplitter
          Left = 660
          Top = 25
          Width = 4
          Height = 361
          Cursor = crHSplit
          Align = alRight
        end
        object lvProfiler: TListView
          Left = 0
          Top = 25
          Width = 660
          Height = 361
          Align = alClient
          Columns = <
            item
              Caption = '��������'
              Width = 92
            end
            item
              AutoSize = True
              Caption = '������������'
            end
            item
              Alignment = taRightJustify
              Caption = 'Count'
              Width = 64
            end
            item
              Alignment = taRightJustify
              Caption = 'Avg'
              Width = 64
            end
            item
              Alignment = taRightJustify
              Caption = 'Max'
              Width = 64
            end
            item
              Alignment = taRightJustify
              Caption = 'Total'
              Width = 64
            end>
          HideSelection = False
          OwnerData = True
          ReadOnly = True
          RowSelect = True
          ParentShowHint = False
          ShowHint = False
          StateImages = il
          TabOrder = 0
          ViewStyle = vsReport
          OnColumnClick = lvProfilerColumnClick
          OnData = lvProfilerData
          OnDataHint = lvProfilerDataHint
          OnResize = lvProfilerResize
          OnSelectItem = lvProfilerSelectItem
        end
        object mProfiler: TMemo
          Left = 664
          Top = 25
          Width = 185
          Height = 361
          Align = alRight
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 1
        end
        object tbdProfiler: TTBDock
          Left = 0
          Top = 0
          Width = 849
          Height = 25
          object tbProfiler: TTBToolbar
            Left = 0
            Top = 0
            Align = alTop
            BorderStyle = bsNone
            Caption = 'tbCommands'
            DockMode = dmCannotFloatOrChangeDocks
            DockPos = 8
            DockRow = 2
            FullSize = True
            TabOrder = 0
            object TBControlItem4: TTBControlItem
              Control = Label3
            end
            object TBControlItem9: TTBControlItem
              Control = edProfilerFilter
            end
            object TBSeparatorItem8: TTBSeparatorItem
            end
            object TBControlItem10: TTBControlItem
              Control = Label4
            end
            object TBControlItem11: TTBControlItem
              Control = cbProfilerSources
            end
            object TBSeparatorItem9: TTBSeparatorItem
            end
            object TBSeparatorItem10: TTBSeparatorItem
            end
            object TBSeparatorItem11: TTBSeparatorItem
            end
            object TBItem9: TTBItem
              Action = actClearProfilerFilter
            end
            object TBItem10: TTBItem
              Action = actSetProfilerFilter
            end
            object TBSeparatorItem13: TTBSeparatorItem
            end
            object TBItem13: TTBItem
              Action = actClearProfilerData
            end
            object Label3: TLabel
              Left = 0
              Top = 4
              Width = 51
              Height = 13
              Caption = ' ������:  '
            end
            object Label4: TLabel
              Left = 149
              Top = 4
              Width = 61
              Height = 13
              Caption = ' ��������:  '
            end
            object edProfilerFilter: TEdit
              Left = 51
              Top = 0
              Width = 92
              Height = 21
              TabOrder = 0
            end
            object cbProfilerSources: TComboBox
              Left = 210
              Top = 0
              Width = 92
              Height = 21
              ItemHeight = 0
              TabOrder = 1
            end
          end
        end
      end
    end
  end
  object pnlSB: TPanel
    Left = 0
    Top = 447
    Width = 857
    Height = 21
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 2
    object sb: TStatusBar
      Left = 4
      Top = -2
      Width = 849
      Height = 19
      Panels = <
        item
          Width = 600
        end
        item
          Width = 150
        end
        item
          Width = 80
        end>
      ParentFont = True
      SimplePanel = False
      UseSystemFont = False
      OnResize = sbResize
    end
  end
  object gsTrayIcon: TgsTrayIcon
    Active = True
    ShowDesigning = False
    Icon.Data = {
      0000010001002020000100000000A80800001600000028000000200000004000
      0000010008000000000080040000000000000000000000000000000000000000
      0000000080000080000000808000800000008000800080800000C0C0C000C0DC
      C000F0CAA6000020400000206000002080000020A0000020C0000020E0000040
      0000004020000040400000406000004080000040A0000040C0000040E0000060
      0000006020000060400000606000006080000060A0000060C0000060E0000080
      0000008020000080400000806000008080000080A0000080C0000080E00000A0
      000000A0200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0
      000000C0200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0
      000000E0200000E0400000E0600000E0800000E0A00000E0C00000E0E0004000
      0000400020004000400040006000400080004000A0004000C0004000E0004020
      0000402020004020400040206000402080004020A0004020C0004020E0004040
      0000404020004040400040406000404080004040A0004040C0004040E0004060
      0000406020004060400040606000406080004060A0004060C0004060E0004080
      0000408020004080400040806000408080004080A0004080C0004080E00040A0
      000040A0200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0
      000040C0200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0
      000040E0200040E0400040E0600040E0800040E0A00040E0C00040E0E0008000
      0000800020008000400080006000800080008000A0008000C0008000E0008020
      0000802020008020400080206000802080008020A0008020C0008020E0008040
      0000804020008040400080406000804080008040A0008040C0008040E0008060
      0000806020008060400080606000806080008060A0008060C0008060E0008080
      0000808020008080400080806000808080008080A0008080C0008080E00080A0
      000080A0200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0
      000080C0200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0
      000080E0200080E0400080E0600080E0800080E0A00080E0C00080E0E000C000
      0000C0002000C0004000C0006000C0008000C000A000C000C000C000E000C020
      0000C0202000C0204000C0206000C0208000C020A000C020C000C020E000C040
      0000C0402000C0404000C0406000C0408000C040A000C040C000C040E000C060
      0000C0602000C0604000C0606000C0608000C060A000C060C000C060E000C080
      0000C0802000C0804000C0806000C0808000C080A000C080C000C080E000C0A0
      0000C0A02000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C0
      0000C0C02000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A0008080
      80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008800000000000000000000000000FC0000000000000000000000
      000000000000FC880000000000000000000000FC880000000000000000000000
      000000000000FCFC88000000000000000000FCFC880000000000000000000000
      000000000000FCFCFC8800000000000000FCFCFC880000000000000000000000
      000000000000FCFCFCFC880000000000FCFCFCFC880000000000000000000000
      000000000000FCFCFCFCFC88000000FCFCFCFCFC880000000000000000000000
      000000000000FCFCFCFCFCFC8800E8FCFCFCFCFC8800000000000000000000E8
      FCFCFCFCFCFCFCFCFCFCFCFCFF88FFE8FCFCFCFC88888888888888FC00000000
      E8FCFCFCFCFCFCFCFCFCFCFFE8FC88FFE8FCFCFCFCFCFCFCFCFCFC0000000000
      00E8FCFCFCFCFCFCFCFCFFE8FCFCFC88FFE8FCFCFCFCFCFCFCFC000000000000
      0000E8FCFCFCFCFCFCFFE8FCFCFCFCFC88FFE8FCFCFCFCFCFC00000000000000
      000000E8FCFCFCFCFFE8FCFCFCFCFCFCFC88FFE8FCFCFCFC0000000000000000
      00000000E8FCFCFFE8FCFCFFFCFFFCFFFCFC88FFE8FCFC000000000000000000
      0000000000E8FFE8FCFCFCFCFCFCFCFCFCFCFC88FFE800000000000000000000
      000000000000E8FCFCFCFCFFFCFCFCFFFCFCFCFC880000000000000000000000
      000000000088FFE8FCFCFCFCFCFCFCFCFCFCFC88FF8800000000000000000000
      00000000FCFC88FFE8FCFCFFFCFFFCFFFCFC88FFFCFC88000000000000000000
      000000FCFCFCFC88FFE8FCFCFCFCFCFCFC88FFFCFCFCFC880000000000000000
      0000FCFCFCFCFCFC88FFE8FCFCFCFCFC88FFFCFCFCFCFCFC8800000000000000
      00FCFCFCFCFCFCFCFC88FFE8FCFCFC88FFFCFCFCFCFCFCFCFC88000000000000
      FCFCFCFCFCFCFCFCFCFC88FFE8FC88FFFCFCFCFCFCFCFCFCFCFC8800000000E8
      E8E8E8E8E8E8E8FCFCFCFC88FFE8FFFCFCFCFCFCFCFCFCFCFCFCFCFC00000000
      000000000000E8FCFCFCFCFC8800E8FCFCFCFCFCFC0000000000000000000000
      000000000000E8FCFCFCFCFC000000E8FCFCFCFCFC0000000000000000000000
      000000000000E8FCFCFCFC0000000000E8FCFCFCFC0000000000000000000000
      000000000000E8FCFCFC00000000000000E8FCFCFC0000000000000000000000
      000000000000E8FCFC000000000000000000E8FCFC0000000000000000000000
      000000000000E8FC0000000000000000000000E8FC0000000000000000000000
      000000000000E800000000000000000000000000E80000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FFFFFFFFFFFFFF7FFDFFFF3FF9FFFF1FF1FFFF0FE1FFFF07C1FFFF0381FFFF01
      01FF80000003C0000007E000000FF000001FF800003FFC00007FFE0000FFFF00
      01FFFE0000FFFC00007FF800003FF000001FE000000FC000000780000003FF01
      01FFFF0381FFFF07C1FFFF0FE1FFFF1FF1FFFF3FF9FFFF7FFDFFFFFFFFFF}
    OnClick = gsTrayIconClick
    PopupMenu = pmTray
    Left = 128
    Top = 232
  end
  object pmTray: TPopupMenu
    Left = 176
    Top = 232
    object Item1: TMenuItem
      Action = actShowOrHide
    end
  end
  object al: TActionList
    Images = il
    Left = 224
    Top = 232
    object actShowOrHide: TAction
      Caption = '��������'
      OnExecute = actShowOrHideExecute
      OnUpdate = actShowOrHideUpdate
    end
    object actClose: TAction
      Caption = '�����'
      OnExecute = actCloseExecute
    end
    object actSetLogFilter: TAction
      Caption = '��������'
      ShortCut = 116
      OnExecute = actSetLogFilterExecute
      OnUpdate = actSetLogFilterUpdate
    end
    object actClearLogFilter: TAction
      Caption = '��������'
      OnExecute = actClearLogFilterExecute
      OnUpdate = actClearLogFilterUpdate
    end
    object actSaveLogToFile: TAction
      Caption = '��������� � ����...'
      ShortCut = 16467
      OnExecute = actSaveLogToFileExecute
      OnUpdate = actSaveLogToFileUpdate
    end
    object actViewLog: TAction
      Caption = '���'
      OnExecute = actViewLogExecute
      OnUpdate = actViewLogUpdate
    end
    object actViewProfiler: TAction
      Caption = '���������'
      OnExecute = actViewProfilerExecute
      OnUpdate = actViewProfilerUpdate
    end
    object actAutoUpdate: TAction
      Caption = '��������� ��� �������������'
      OnExecute = actAutoUpdateExecute
    end
    object actSetProfilerFilter: TAction
      Caption = '��������'
      Hint = '��������� ������'
      ShortCut = 116
      OnExecute = actSetProfilerFilterExecute
      OnUpdate = actSetProfilerFilterUpdate
    end
    object actClearProfilerFilter: TAction
      Caption = '��������'
      Hint = '�������� ��������� ������� � �������� ���������'
      OnExecute = actClearProfilerFilterExecute
      OnUpdate = actClearProfilerFilterUpdate
    end
    object actAbout: TAction
      Caption = '� ���������'
      OnExecute = actAboutExecute
    end
    object actClearProfilerData: TAction
      Caption = '��������'
      Hint = '�������� ������ ����������'
      OnExecute = actClearProfilerDataExecute
    end
    object actClearLogData: TAction
      Caption = '��������'
      Hint = '�������� ���'
    end
  end
  object il: TImageList
    Left = 272
    Top = 232
    Bitmap = {
      494C010103000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000B6B6B600A6A6A600A6A6A600A6A6A600000000000000
      000000000000000000000000000000000000000000000000000000000000B5B5
      B500ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
      AD00ADADAD000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C2C2C200000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000AEAEC500363695000909980007079700070797004E4E860074748700AFAF
      AF000000000000000000000000000000000000000000000000005BB8B8001039
      39000F2E2E000F2E2E000F2E2E000F2E2E000F2E2E000F2E2E000F2E2E000F2E
      2E004C5858009595950000000000000000000000000000000000000000000000
      0000000000000000000000000000CDCDCD003737370067676700000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008989
      CC000000B5000000E1000000FF000000FF000000FF000000CA000D0DAC006060
      8000AFAFAF00000000000000000000000000000000008BC5C50000D7D70000FF
      FF0000FFFF0000FFFF0024D7D7000DAFAF0017E8E80000FFFF0000FFFF0000FF
      FF00005D5D007A7A7A0000000000000000000000000000000000000000000000
      00000000000000000000C6C6C600666666007A7A7A005D5D5D00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008C8CC6000808
      D6003D3DFF004545FF000000FF000000FF000000FF007A7AFF000808F7001212
      B10061618000000000000000000000000000000000008BC5C50000D7D70000FF
      FF0000FFFF0000FFFF00639191002323230040C0C00000FFFF0000FFFF0000FF
      FF00005D5D00B5B5B50000000000000000000000000000000000000000000000
      0000848484005E5E5E006E6E6E00E5E5E500A9A9A9004B4B4B0059595900B3B3
      B300000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000004646AE001B1B
      F500D8D8FF00F0F0FF004444FF000A0AFF008484FF00F8F8FF00A2A2FF000000
      D20046468600949496000000000000000000000000000000000044AFAF0000F5
      F50000FFFF0000FFFF0010EDED0006CDCD000AF5F50000FFFF0000FFFF0000A8
      A8004B5959000000000000000000000000000000000000000000000000006969
      690090909000D0D0D000FBFBFB00FFFFFF00F5F5F500BCBCBC00737373004D4D
      4D009B9B9B000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008B8BC5000000D7000000
      FF003A3AFF00D8D8FF00F8F8FF008B8BFF00FFFFFF00BABAFF000808FF000000
      FF000000AE007A7A8C000000000000000000000000000000000088C4C40007D8
      D80000FFFF0000FFFF0000D4D400003B3B0000EBEB0000FFFF0000F0F0001178
      7800B1B1B1000000000000000000000000000000000000000000B1B1B100E2E2
      E200FBFBFB00FF8C8C00F12D2D00FF171700FF2A2A00FFCACA00EEEEEE007D7D
      7D0054545400B8B8B80000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008B8BC5000000D7000000
      FF000000FF003A3AFF00E3E3FF00FFFFFF00B1B1FF001B1BFF000000FF000000
      FF000000AE007A7A8C000000000000000000000000000000000000000000179D
      9D0000FFFF0000FFFF00005A5A0000101000009C9C0000FFFF0000D1D1005151
      51000000000000000000000000000000000000000000C5C5C500BDBDBD00FBFB
      FB00FFFFFF00FFFFFF009D919100FF000000FF808000FFFFFF00FFFFFF00EFEF
      EF004F4F4F007A7A7A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008B8BC5000000D7000000
      FF000808FF008A8AFF00F7F7FF00EEEEFF00ECECFF004C4CFF000101FF000000
      FF000000AE00838395000000000000000000000000000000000000000000B4DD
      DD0000BFBF0000FFFF00002E2E00000000000080800000FFFF0013474700A7A7
      A7000000000000000000000000000000000000000000C5C5C500D7D7D700FFFF
      FF00FFFFFF00FFFFFF009D919100FF000000FF808000FFFFFF00FFFFFF00FFFF
      FF005D5D5D007A7A7A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000B1B1D8001B1BC8000C0C
      FB009292FF00FFFFFF00B2B2FF002F2FFF00D5D5FF00FFFFFF004D4DFF000000
      EE001B1B9F00E2E2EE0000000000000000000000000000000000000000000000
      00002CB8B80000F1F100006464000013130000A3A30000CDCD00495252000000
      00000000000000000000000000000000000000000000C5C5C500D7D7D700FFFF
      FF00FFFFFF00C6C6C600E03F3F00FF1A1A00FF8D8D00FFFFFF00FFFFFF00FCFC
      FC005B5B5B008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000005151A8000F0F
      F300A3A3FF00A9A9FF001414FF000000FF003737FF00D7D7FF006161FF000000
      CB007F7FAE000000000000000000000000000000000000000000000000000000
      0000A2D1D10000CBCB0000F9F90000A5A50000FFFF0000464600C3C3C3000000
      00000000000000000000000000000000000000000000D9D9D900C7C7C700FBFB
      FB00FFFFFF00FFFFFF00DEDADA00FFA8A800FFD4D400FFFFFF00FFFFFF00CACA
      CA004A4A4A000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000DDDDEE001C1C
      B1001212F9001414FD000000FF000000FF000000FF002424FB000404E9005B5B
      BC00000000000000000000000000000000000000000000000000000000000000
      0000000000004EBABA0000EEEE0000FFFF0000A0A00046575700000000000000
      0000000000000000000000000000000000000000000000000000A8A8A800F3F3
      F300FFFFFF00FFFFFF00D6585800FF000000FF808000FFFFFF00F9F9F9008181
      8100808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E6E6
      F3004848A4001E1EC4000000DB000000DB000000DB003535B3006969B5000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008AC5C5000AD6D60000E2E2001D8F8F00C8C8C800000000000000
      000000000000000000000000000000000000000000000000000000000000A5A5
      A500BFBFBF00F8F8F800F8D2D200F8C9C900F8E1E100F8F8F800444444007272
      7200000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000B7B7DB008585C2008585C2008585C200DEDEEE00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008FC7C70077BBBB00BBDDDD0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000DFDFDF00A6A6A600A6A6A600A6A6A600A6A6A600A6A6A600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFFFFF0000FFFFFFFFFFFF0000
      FC3FE007FFBF0000F00FC003FE3F0000E0078003FC3F0000C0078003F00F0000
      C003C007E00700008003C007C00300008003E00F800300008003E00F80030000
      8003F01F80030000C007F01F80070000C00FF83FC0070000E01FF83FE00F0000
      F83FFC7FF03F0000FFFFFFFFFFFF000000000000000000000000000000000000
      000000000000}
  end
end
