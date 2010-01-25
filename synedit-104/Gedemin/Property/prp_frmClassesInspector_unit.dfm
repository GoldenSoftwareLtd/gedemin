inherited frmClassesInspector: TfrmClassesInspector
  Left = 254
  Top = 83
  Width = 377
  Height = 374
  HelpContext = 306
  Caption = 'Инспектор классов'
  Constraints.MinHeight = 190
  Constraints.MinWidth = 190
  OldCreateOrder = True
  PopupMenu = pmMain
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  inherited pCaption: TPanel
    Width = 369
  end
  object sbCurrentNode: TStatusBar [1]
    Left = 0
    Top = 328
    Width = 369
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object pcMain: TPageControl [2]
    Left = 0
    Top = 18
    Width = 369
    Height = 310
    ActivePage = tsClasses
    Align = alClient
    TabOrder = 1
    object tsClasses: TTabSheet
      Caption = 'Классы'
      object Splitter1: TSplitter
        Left = 0
        Top = 243
        Width = 361
        Height = 3
        Cursor = crVSplit
        Align = alBottom
      end
      object tvClassesInsp: TTreeView
        Left = 0
        Top = 41
        Width = 361
        Height = 202
        Align = alClient
        Enabled = False
        Images = dmImages.imTreeView
        Indent = 19
        ReadOnly = True
        RightClickSelect = True
        TabOrder = 0
        OnAdvancedCustomDrawItem = tvClassesInspAdvancedCustomDrawItem
        OnChange = tvClassesInspChange
        OnChanging = tvClassesInspChanging
        OnCompare = tvClassesInspCompare
        OnCustomDrawItem = tvClassesInspCustomDrawItem
        OnDblClick = tvClassesInspDblClick
        OnExpanding = tvClassesInspExpanding
        OnKeyPress = tvClassesInspKeyPress
      end
      object mmDescription: TMemo
        Left = 0
        Top = 246
        Width = 361
        Height = 36
        Align = alBottom
        Lines.Strings = (
          '')
        ReadOnly = True
        TabOrder = 1
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 361
        Height = 41
        Align = alTop
        TabOrder = 2
        object btnRefresh: TSpeedButton
          Left = 2
          Top = 2
          Width = 23
          Height = 21
          Hint = 'Перестроить'
          Flat = True
          Glyph.Data = {
            36050000424D3605000000000000360400002800000010000000100000000100
            0800000000000001000000000000000000000001000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
            A6000020400000206000002080000020A0000020C0000020E000004000000040
            20000040400000406000004080000040A0000040C0000040E000006000000060
            20000060400000606000006080000060A0000060C0000060E000008000000080
            20000080400000806000008080000080A0000080C0000080E00000A0000000A0
            200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
            200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
            200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
            20004000400040006000400080004000A0004000C0004000E000402000004020
            20004020400040206000402080004020A0004020C0004020E000404000004040
            20004040400040406000404080004040A0004040C0004040E000406000004060
            20004060400040606000406080004060A0004060C0004060E000408000004080
            20004080400040806000408080004080A0004080C0004080E00040A0000040A0
            200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
            200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
            200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
            20008000400080006000800080008000A0008000C0008000E000802000008020
            20008020400080206000802080008020A0008020C0008020E000804000008040
            20008040400080406000804080008040A0008040C0008040E000806000008060
            20008060400080606000806080008060A0008060C0008060E000808000008080
            20008080400080806000808080008080A0008080C0008080E00080A0000080A0
            200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
            200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
            200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
            2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
            2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
            2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
            2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
            2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
            2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
            2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFF6F1D1D1D1D1D1D1D1D1D1D1C146FFFFF1D1E262626
            26262626261E1E1D14FFFF1D262727272727272727271E1D1CFFFF1E272727FF
            27BFBFBF2727261E1DFFFF26272727FFFFFFFFFFBF27271E1DFFFF27272727FF
            FF272727FF2727261DFFFF27272727FFFFFF2727272726261DFFFF2727272727
            27272727272726261DFFFF276F6F27272727FFFFFF2626261DFFFF276F6F6FFF
            272727FFFF2726261DFFFF6F6F6F6FBFFFFFFFFFFF2726261DFFFF6FB76F6F6F
            BFBFBF27FF2727261DFFFF6FB7B76F6F6F6F6F6F2F2727261DFFFFBF6F6F6F27
            272727272727261EB7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
          ParentShowHint = False
          ShowHint = True
          OnClick = btnRefreshClick
        end
        object btnGoBack: TSpeedButton
          Left = 299
          Top = 2
          Width = 60
          Height = 21
          Hint = 'Вернуться к предыдущему'
          Anchors = [akTop, akRight]
          Caption = 'Назад'
          Flat = True
          Glyph.Data = {
            36030000424D3603000000000000360000002800000010000000100000000100
            18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF9933000000FF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFF000000FF9933FF99330000000000000000000000000000000000000000
            00000000FFFFFFFFFFFFFFFFFFFFFFFF000000FF9933FFCC33FF9933FF9933FF
            9933FF9933FF9933FF9933FF9933FF9933000000FFFFFFFFFFFFFFFFFFFFFFFF
            FF6633FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FF99
            33000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633FFFF99FFFF99000000FF
            6633FF6633FF6633FF6633FF6633FF6633000000FFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFF6633FFFF99000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633000000FF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
          ParentShowHint = False
          ShowHint = True
          OnClick = btnGoBackClick
        end
        object cbClasses: TComboBox
          Left = 26
          Top = 2
          Width = 272
          Height = 21
          Hint = 'Список классов'
          Anchors = [akLeft, akTop, akRight]
          DropDownCount = 15
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          Sorted = True
          TabOrder = 0
          OnDblClick = cbClassesDblClick
          OnKeyDown = cbClassesKeyDown
        end
        object chkShowInherited: TCheckBox
          Left = 7
          Top = 24
          Width = 266
          Height = 15
          Caption = 'Отображать наследованные свойства и методы'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = chkShowInheritedClick
        end
      end
    end
    object tsSearch: TTabSheet
      Caption = 'Поиск'
      ImageIndex = 1
      OnShow = tsSearchShow
      object pnlSearch: TPanel
        Left = 0
        Top = 0
        Width = 361
        Height = 282
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object Splitter2: TSplitter
          Left = 1
          Top = 201
          Width = 359
          Height = 5
          Cursor = crVSplit
          Align = alTop
        end
        object pnlSearchClasses: TPanel
          Left = 1
          Top = 206
          Width = 359
          Height = 75
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object lblClasses: TLabel
            Left = 8
            Top = -1
            Width = 61
            Height = 13
            Caption = '2. Разделы:'
          end
          object lbClasses: TListBox
            Left = 8
            Top = 15
            Width = 343
            Height = 52
            Anchors = [akLeft, akTop, akRight, akBottom]
            ItemHeight = 13
            Sorted = True
            TabOrder = 0
            OnDblClick = lbClassesDblClick
          end
        end
        object pnlSearchWords: TPanel
          Left = 1
          Top = 98
          Width = 359
          Height = 103
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblWords: TLabel
            Left = 8
            Top = 0
            Width = 107
            Height = 13
            Caption = '1. Найденные слова:'
          end
          object lbWords: TListBox
            Left = 8
            Top = 16
            Width = 343
            Height = 87
            Anchors = [akLeft, akTop, akRight, akBottom]
            ItemHeight = 16
            Style = lbOwnerDrawFixed
            TabOrder = 0
            OnClick = lbWordsClick
            OnDrawItem = lbWordsDrawItem
          end
        end
        object Panel2: TPanel
          Left = 1
          Top = 1
          Width = 359
          Height = 97
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 2
          object Label1: TLabel
            Left = 8
            Top = 2
            Width = 78
            Height = 13
            Caption = 'Искомое слово:'
          end
          object edtSearch: TEdit
            Left = 8
            Top = 18
            Width = 240
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
          end
          object cbWholeWord: TCheckBox
            Left = 8
            Top = 50
            Width = 145
            Height = 17
            Caption = 'Полное совпадение'
            TabOrder = 1
          end
          object btnSearch: TButton
            Left = 170
            Top = 48
            Width = 78
            Height = 22
            Action = actSearch
            Anchors = [akTop, akRight]
            Default = True
            TabOrder = 2
          end
          object btnGo: TButton
            Left = 170
            Top = 75
            Width = 78
            Height = 21
            Action = actGotoSearch
            Anchors = [akTop, akRight]
            TabOrder = 3
          end
        end
      end
    end
  end
  inherited alMain: TActionList
    Left = 160
    Top = 296
  end
  inherited pmMain: TPopupMenu
    OnPopup = pmMain2Popup
    Left = 120
    Top = 296
    object N6: TMenuItem [0]
      Action = actCopyCurrentItem
    end
    object N1: TMenuItem [1]
      Action = actInsertCurrentItem
    end
    object N5: TMenuItem [2]
      Action = actGotoSearch
    end
    object N2: TMenuItem [3]
      Caption = '-'
    end
    inherited miDockable: TMenuItem [5]
    end
    inherited miSeparator: TMenuItem [6]
    end
    object N4: TMenuItem
      Action = actExpand
    end
    object N3: TMenuItem
      Action = actCollapse
    end
  end
  object alMain2: TActionList
    Images = dmImages.il16x16
    Left = 200
    Top = 296
    object actInsertCurrentItem: TAction
      Caption = 'Вставить в текст'
      OnExecute = actInsertCurrentItemExecute
    end
    object actCollapse: TAction
      Caption = 'Свернуть дерево'
      OnExecute = actCollapseExecute
    end
    object actExpand: TAction
      Caption = 'Развернуть дерево'
      OnExecute = actExpandExecute
    end
    object actSearch: TAction
      Caption = 'Поиск'
      OnExecute = actSearchExecute
    end
    object actGotoSearch: TAction
      Caption = 'Перейти'
      OnExecute = actGotoSearchExecute
    end
    object actAddCOMServ: TAction
      Caption = 'actAddCOMServ'
    end
    object actCopyCurrentItem: TAction
      Caption = 'Копировать'
      OnExecute = actCopyCurrentItemExecute
    end
  end
end
