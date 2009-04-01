inherited gdc_frmExplorer: Tgdc_frmExplorer
  Left = -1
  Top = 104
  Width = 297
  Height = 746
  HelpContext = 332
  Caption = 'Исследователь'
  Constraints.MinWidth = 0
  OnCanResize = FormCanResize
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 691
    Width = 289
    Visible = False
  end
  inherited TBDockTop: TTBDock
    Width = 289
    inherited tbMainToolbar: TTBToolbar
      inherited tbsiMainOneAndHalf: TTBSeparatorItem
        Visible = False
      end
    end
    inherited tbMainCustom: TTBToolbar
      Left = 187
      DockPos = 192
      object tbiOpenExp: TTBItem
        Action = actShow
      end
      object tbiCreateObjExp: TTBItem
        Action = actCreateNewObject
      end
      object TBItem1: TTBItem
        Action = actShowRecent
      end
      object TBItem2: TTBItem
        Action = actSecurity
      end
    end
    inherited tbMainMenu: TTBToolbar
      DockPos = -8
      Visible = False
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 120
      DockPos = 120
    end
    inherited tbChooseMain: TTBToolbar
      Left = 154
      DockPos = 168
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 642
  end
  inherited TBDockRight: TTBDock
    Left = 280
    Height = 642
  end
  inherited TBDockBottom: TTBDock
    Top = 710
    Width = 289
  end
  inherited pnlWorkArea: TPanel
    Width = 271
    Height = 642
    inherited spChoose: TSplitter
      Top = 539
      Width = 271
    end
    inherited pnlMain: TPanel
      Width = 271
      Height = 539
      Constraints.MinWidth = 0
      inherited pnlSearchMain: TPanel
        Width = 78
        Height = 539
        inherited sbSearchMain: TScrollBox
          Width = 78
          Height = 501
        end
        inherited pnlSearchMainButton: TPanel
          Top = 501
          Width = 78
        end
      end
      object Panel1: TPanel
        Left = 78
        Top = 0
        Width = 193
        Height = 539
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object spl: TSplitter
          Left = 0
          Top = 163
          Width = 193
          Height = 2
          Cursor = crVSplit
          Align = alTop
        end
        object dbtvExplorer: TgsDBTreeView
          Left = 0
          Top = 165
          Width = 193
          Height = 374
          DataSource = dsMain
          KeyField = 'ID'
          ParentField = 'PARENT'
          DisplayField = 'NAME'
          ImageField = 'imgindex'
          OnFilterRecord = dbtvExplorerFilterRecord
          OnPostProcess = dbtvExplorerPostProcess
          Align = alClient
          HideSelection = False
          Images = dmImages.ilTree
          Indent = 19
          PopupMenu = pmMain
          ReadOnly = True
          RightClickSelect = True
          SortType = stText
          TabOrder = 0
          OnAdvancedCustomDrawItem = dbtvExplorerAdvancedCustomDrawItem
          OnClick = dbtvExplorerClick
          OnDblClick = dbtvExplorerDblClick
          OnExpanded = dbtvExplorerExpanded
          MainFolderHead = True
          MainFolder = False
          MainFolderCaption = 'Все'
          TopKey = 710000
          WithCheckBox = False
        end
        object pnlTop: TPanel
          Left = 0
          Top = 0
          Width = 193
          Height = 163
          Align = alTop
          BevelOuter = bvNone
          Caption = 'pnlTop'
          TabOrder = 1
          object lb: TListBox
            Left = 0
            Top = 0
            Width = 193
            Height = 163
            Hint = 'Список последних вызовов'
            Align = alClient
            Constraints.MinHeight = 1
            ItemHeight = 13
            PopupMenu = pmLB
            Sorted = True
            TabOrder = 0
            OnClick = lbClick
            OnDblClick = lbDblClick
          end
          object pcSecurity: TPageControl
            Left = 0
            Top = 0
            Width = 193
            Height = 163
            ActivePage = tsGroup
            Align = alClient
            TabOrder = 1
            Visible = False
            OnChange = pcSecurityChange
            object tsGroup: TTabSheet
              Caption = 'Группа'
              object Label1: TLabel
                Left = 3
                Top = -2
                Width = 172
                Height = 13
                Caption = 'Выберите группу пользователей:'
              end
              object Label2: TLabel
                Left = 4
                Top = 36
                Width = 182
                Height = 25
                AutoSize = False
                Caption = 'Установить уровень доступа для выбранного элемента:'
                WordWrap = True
              end
              object iblkupGroup: TgsIBLookupComboBox
                Left = 3
                Top = 14
                Width = 181
                Height = 21
                HelpContext = 1
                ListTable = 'gd_usergroup'
                ListField = 'name'
                KeyField = 'ID'
                gdClassName = 'TgdcUserGroup'
                ItemHeight = 13
                ParentShowHint = False
                ShowHint = True
                TabOrder = 0
                OnChange = iblkupGroupChange
              end
              object Panel2: TPanel
                Left = 0
                Top = 63
                Width = 185
                Height = 15
                BevelOuter = bvNone
                TabOrder = 1
                object Label3: TLabel
                  Left = 4
                  Top = 0
                  Width = 52
                  Height = 13
                  Caption = 'Просмотр:'
                end
                object rbVY: TRadioButton
                  Left = 100
                  Top = -1
                  Width = 41
                  Height = 17
                  Caption = 'Да'
                  Checked = True
                  TabOrder = 0
                  TabStop = True
                end
                object rbVN: TRadioButton
                  Left = 145
                  Top = -1
                  Width = 41
                  Height = 17
                  Caption = 'Нет'
                  TabOrder = 1
                  OnClick = rbVNClick
                end
              end
              object Panel3: TPanel
                Left = 0
                Top = 79
                Width = 185
                Height = 15
                BevelOuter = bvNone
                TabOrder = 2
                object Label4: TLabel
                  Left = 4
                  Top = 0
                  Width = 58
                  Height = 13
                  Caption = 'Изменение:'
                end
                object rbCY: TRadioButton
                  Left = 100
                  Top = -1
                  Width = 41
                  Height = 17
                  Caption = 'Да'
                  Checked = True
                  TabOrder = 0
                  TabStop = True
                  OnClick = rbCYClick
                end
                object rbCN: TRadioButton
                  Left = 145
                  Top = -1
                  Width = 41
                  Height = 17
                  Caption = 'Нет'
                  TabOrder = 1
                  OnClick = rbCNClick
                end
              end
              object Panel4: TPanel
                Left = 0
                Top = 95
                Width = 185
                Height = 15
                BevelOuter = bvNone
                TabOrder = 3
                object Label5: TLabel
                  Left = 4
                  Top = 0
                  Width = 82
                  Height = 13
                  Caption = 'Полный доступ:'
                end
                object rbFY: TRadioButton
                  Left = 100
                  Top = -1
                  Width = 41
                  Height = 17
                  Caption = 'Да'
                  Checked = True
                  TabOrder = 0
                  TabStop = True
                  OnClick = rbFYClick
                end
                object rbFN: TRadioButton
                  Left = 145
                  Top = -1
                  Width = 41
                  Height = 17
                  Caption = 'Нет'
                  TabOrder = 1
                end
              end
              object Button1: TButton
                Left = 108
                Top = 113
                Width = 75
                Height = 19
                Action = actSetAccess
                TabOrder = 4
              end
              object chbxUpdateChildren: TCheckBox
                Left = 4
                Top = 114
                Width = 97
                Height = 17
                Caption = 'С подуровнями'
                Checked = True
                State = cbChecked
                TabOrder = 5
              end
            end
            object tsUser: TTabSheet
              Caption = 'Пользователь'
              ImageIndex = 1
              object Label6: TLabel
                Left = 3
                Top = -2
                Width = 128
                Height = 13
                Caption = 'Выберите пользователя:'
              end
              object lblGroups: TLabel
                Left = 4
                Top = 39
                Width = 181
                Height = 90
                AutoSize = False
                WordWrap = True
              end
              object iblkupUser: TgsIBLookupComboBox
                Left = 3
                Top = 14
                Width = 181
                Height = 21
                HelpContext = 1
                ListTable = 'gd_user'
                ListField = 'name'
                KeyField = 'ID'
                gdClassName = 'TgdcUser'
                ItemHeight = 0
                ParentShowHint = False
                ShowHint = True
                TabOrder = 0
                OnChange = iblkupUserChange
              end
            end
            object tsCommand: TTabSheet
              Caption = 'Текущий'
              ImageIndex = 3
              object Panel5: TPanel
                Left = 0
                Top = 82
                Width = 185
                Height = 53
                Align = alBottom
                BevelOuter = bvLowered
                TabOrder = 0
                object Label14: TLabel
                  Left = 5
                  Top = 2
                  Width = 169
                  Height = 26
                  AutoSize = False
                  Caption = 'Скопировать права от текущего элемента для:'
                  WordWrap = True
                end
                object btnDistrChild: TButton
                  Left = 4
                  Top = 31
                  Width = 85
                  Height = 19
                  Action = actDistrChild
                  TabOrder = 0
                end
                object btnDistrAll: TButton
                  Left = 94
                  Top = 31
                  Width = 85
                  Height = 19
                  Action = actDistrAll
                  TabOrder = 1
                end
              end
              object Panel6: TPanel
                Left = 0
                Top = 0
                Width = 185
                Height = 82
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 1
                object lblClass: TLabel
                  Left = 0
                  Top = 0
                  Width = 185
                  Height = 17
                  Align = alTop
                  AutoSize = False
                  Caption = 'Тип:'
                end
                object mRights: TMemo
                  Left = 0
                  Top = 17
                  Width = 185
                  Height = 65
                  TabStop = False
                  Align = alClient
                  BorderStyle = bsNone
                  Color = clInfoBk
                  Font.Charset = RUSSIAN_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -9
                  Font.Name = 'Tahoma'
                  Font.Style = []
                  Lines.Strings = (
                    '1'
                    '2'
                    '3')
                  ParentFont = False
                  ReadOnly = True
                  TabOrder = 0
                end
              end
            end
            object tsHelp: TTabSheet
              Caption = '?'
              ImageIndex = 2
              object Label7: TLabel
                Left = 3
                Top = 18
                Width = 82
                Height = 13
                Caption = 'Полный доступ:'
              end
              object Label8: TLabel
                Left = 3
                Top = 34
                Width = 117
                Height = 13
                Caption = 'Просмотр и изменение:'
              end
              object Label9: TLabel
                Left = 3
                Top = 49
                Width = 90
                Height = 13
                Caption = 'Только просмотр:'
              end
              object Label10: TLabel
                Left = 3
                Top = 65
                Width = 68
                Height = 13
                Caption = 'Нет доступа:'
              end
              object Label11: TLabel
                Left = 3
                Top = 85
                Width = 183
                Height = 41
                AutoSize = False
                Caption = 
                  'Полный доступ позволяет просматривать, изменять, удалять и назна' +
                  'чать права.'
                WordWrap = True
              end
              object Label12: TLabel
                Left = 3
                Top = 1
                Width = 47
                Height = 13
                Caption = 'Легенда:'
              end
              object ListBox1: TListBox
                Left = 124
                Top = 17
                Width = 41
                Height = 69
                TabStop = False
                BorderStyle = bsNone
                Color = clBtnFace
                ItemHeight = 16
                Items.Strings = (
                  '0'
                  '1'
                  '2'
                  '3')
                Style = lbOwnerDrawFixed
                TabOrder = 0
                OnDrawItem = ListBox1DrawItem
              end
            end
          end
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 543
      Width = 271
      inherited pnButtonChoose: TPanel
        Left = 166
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 166
      end
      inherited pnlChooseCaption: TPanel
        Width = 271
      end
    end
  end
  inherited alMain: TActionList
    Left = 36
    inherited actNew: TAction
      Visible = False
    end
    inherited actEdit: TAction
      Visible = False
    end
    inherited actDuplicate: TAction
      Visible = False
    end
    inherited actHlp: TAction
      Visible = False
    end
    inherited actPrint: TAction
      Visible = False
    end
    inherited actCommit: TAction
      Visible = False
    end
    inherited actFind: TAction
      Visible = False
    end
    inherited actMainReduction: TAction
      Visible = False
    end
    inherited actFilter: TAction
      Visible = False
    end
    inherited actOnlySelected: TAction
      Visible = False
    end
    inherited actAddToSelected: TAction
      Visible = False
    end
    inherited actRemoveFromSelected: TAction
      Visible = False
    end
    object actShow: TAction [26]
      Caption = 'Открыть'
      Hint = 'Открыть'
      ImageIndex = 53
      ShortCut = 13
      OnExecute = actShowExecute
      OnUpdate = actShowUpdate
    end
    object actCreateNewObject: TAction [27]
      Caption = 'Создать объект...'
      Hint = 'Создать объект'
      ImageIndex = 0
      OnExecute = actCreateNewObjectExecute
      OnUpdate = actCreateNewObjectUpdate
    end
    object actShowRecent: TAction
      Caption = 'Последние'
      Hint = 'Показать последние'
      ImageIndex = 84
      OnExecute = actShowRecentExecute
      OnUpdate = actShowRecentUpdate
    end
    object actSecurity: TAction
      Caption = 'Права доступа'
      ImageIndex = 155
      OnExecute = actSecurityExecute
      OnUpdate = actSecurityUpdate
    end
    object actSetAccess: TAction
      Caption = 'Установить'
      OnExecute = actSetAccessExecute
      OnUpdate = actSetAccessUpdate
    end
    object actDistrChild: TAction
      Caption = 'Вложенных'
      OnExecute = actDistrChildExecute
      OnUpdate = actDistrChildUpdate
    end
    object actDistrAll: TAction
      Caption = 'Всех'
      OnExecute = actDistrAllExecute
      OnUpdate = actDistrAllUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Images = dmImages.il16x16
    Left = 44
    Top = 220
    object N1: TMenuItem [0]
      Action = actShow
    end
    object nactCreateNewObject1: TMenuItem [1]
      Action = actCreateNewObject
    end
    object N2: TMenuItem [2]
      Caption = '-'
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcExplorer
    OnDataChange = dsMainDataChange
    Left = 28
    Top = 196
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Left = 25
    Top = 63
  end
  inherited dsChoose: TDataSource
    Left = 97
  end
  object gdcExplorer: TgdcExplorer
    SubSet = 'ByExplorer'
    Left = 49
    Top = 121
  end
  object pmLB: TPopupMenu
    Left = 17
    Top = 105
    object N4: TMenuItem
      Caption = 'Удалить'
      OnClick = N4Click
    end
    object N3: TMenuItem
      Caption = 'Удалить все'
      OnClick = N3Click
    end
  end
  object il: TImageList
    Height = 9
    Width = 9
    Left = 81
    Top = 337
    Bitmap = {
      494C010102000400040009000900FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000240000000900000001002000000000001005
      0000000000000000000000000000000000000000000000000000000000000000
      0000000080000000000000000000000000000000000000000000000000000000
      0000000000000080000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000080000040C00000008000000000000000
      0000000000000000000000000000000000000080000000C00000008000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000080000040
      C0000040C0000040C00000008000000000000000000000000000000000000080
      000000C0000000C0000000C00000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000080000040C0000040C0000000FF000040C0000040C0000000
      800000000000000000000080000000C0000000C0000000E0400000C0000000C0
      0000008000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000040C0000040C0000000
      80000040C0000000FF000040C0000040C0000000800000E0400000C0000000C0
      00000080000000C0000000E0400000C0000000C0000000800000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000040C0000040C000000080000040C0000040C0000000
      8000000000000000000000E0400000C0000000C000000080000000C0000000C0
      0000008000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000040
      C0000040C0000040C000000080000000000000000000000000000000000000E0
      400000C0000000C0000000C00000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000040C00000008000000000000000
      00000000000000000000000000000000000000E0400000C00000008000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000000000000000000000000000000000000000000000000000
      00000000000000E0400000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000424D3E000000000000003E00000028000000240000000900000001000100
      00000000480000000000000000000000000000000000000000000000FFFFFF00
      F7FBC00000000000E3F1C00000000000C1E0C0000000000080C0400000000000
      000000000000000080C0400000000000C1E0C00000000000E3F1C00000000000
      F7FBC0000000000000000000000000000000000000000000000000000000}
  end
end
