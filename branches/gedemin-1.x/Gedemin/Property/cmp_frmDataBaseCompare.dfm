object DataBaseCompare: TDataBaseCompare
  Left = 1405
  Top = 25
  Width = 1097
  Height = 732
  Caption = '��������� ��� ������'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnMain: TPanel
    Left = 0
    Top = 0
    Width = 1089
    Height = 705
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnTop: TPanel
      Left = 0
      Top = 0
      Width = 1089
      Height = 171
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object gbExternalConnection: TGroupBox
        Left = 4
        Top = 3
        Width = 365
        Height = 110
        Caption = '��������� ����������'
        TabOrder = 0
        object lbExtUserName: TLabel
          Left = 8
          Top = 53
          Width = 76
          Height = 13
          Caption = '������������:'
        end
        object lbExtPassword: TLabel
          Left = 8
          Top = 80
          Width = 41
          Height = 13
          Caption = '������:'
        end
        object lbExServer: TLabel
          Left = 192
          Top = 53
          Width = 40
          Height = 13
          Caption = '������:'
        end
        object edExtDatabaseName: TEdit
          Left = 8
          Top = 21
          Width = 321
          Height = 21
          TabOrder = 0
        end
        object btnExtOpen: TButton
          Left = 336
          Top = 21
          Width = 20
          Height = 20
          Caption = '...'
          TabOrder = 1
          OnClick = btnExtOpenClick
        end
        object edExtUserName: TEdit
          Left = 88
          Top = 49
          Width = 89
          Height = 21
          TabOrder = 2
          Text = 'SYSDBA'
        end
        object edExtPassword: TEdit
          Left = 88
          Top = 76
          Width = 89
          Height = 21
          PasswordChar = '*'
          TabOrder = 3
          Text = 'masterkey'
        end
        object edExtServerName: TEdit
          Left = 240
          Top = 49
          Width = 89
          Height = 21
          TabOrder = 4
        end
      end
      object btnCompareDB: TButton
        Left = 120
        Top = 127
        Width = 75
        Height = 25
        Action = actCompareDB
        TabOrder = 1
      end
      object gbViewItems: TGroupBox
        Left = 4
        Top = 116
        Width = 106
        Height = 43
        Caption = '����������'
        TabOrder = 2
        object pnViewItems: TPanel
          Left = 2
          Top = 15
          Width = 102
          Height = 26
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object TBToolbar1: TTBToolbar
            Left = 5
            Top = 0
            Width = 92
            Height = 22
            Caption = 'TBToolbar1'
            Images = dmImages.il16x16
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            object tbOnlyFirstDBItems: TTBItem
              Caption = '�������, ������� ���� ������ � ������� ��'
              Hint = '�������, ������� ���� ������ � ������� ��'
              ImageIndex = 156
              OnClick = acRefreshExecute
            end
            object tbEquivItems: TTBItem
              Caption = '���������� �������'
              Hint = '���������� �������'
              ImageIndex = 214
              OnClick = acRefreshExecute
            end
            object tbDiffItems: TTBItem
              Caption = '������� � ���������'
              Hint = '������� � ���������'
              ImageIndex = 121
              OnClick = acRefreshExecute
            end
            object tbOnlyExtDBItems: TTBItem
              Caption = '�������, ������� ���� ������ � ������������ ��'
              Hint = '�������, ������� ���� ������ � ������������ ��'
              ImageIndex = 157
              OnClick = acRefreshExecute
            end
          end
        end
      end
      object gbSearchOptions: TGroupBox
        Left = 392
        Top = 3
        Width = 401
        Height = 164
        Caption = '������� ��� ���������'
        TabOrder = 3
        object cbVBClass: TCheckBox
          Left = 6
          Top = 13
          Width = 97
          Height = 17
          Caption = 'VB ������'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object cbGO: TCheckBox
          Left = 6
          Top = 29
          Width = 153
          Height = 18
          Caption = '���������� VB-�������'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object cbConst: TCheckBox
          Left = 6
          Top = 46
          Width = 145
          Height = 17
          Caption = '���������'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object cbMacros: TCheckBox
          Left = 6
          Top = 62
          Width = 97
          Height = 17
          Caption = '�������'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object cbSF: TCheckBox
          Left = 6
          Top = 79
          Width = 123
          Height = 17
          Caption = '������-�������'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object cbReport: TCheckBox
          Left = 6
          Top = 95
          Width = 97
          Height = 17
          Caption = '������'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object cbMethod: TCheckBox
          Left = 6
          Top = 111
          Width = 97
          Height = 17
          Caption = '������'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
        object cbEvents: TCheckBox
          Left = 6
          Top = 128
          Width = 97
          Height = 17
          Caption = '�������'
          Checked = True
          State = cbChecked
          TabOrder = 7
        end
        object cbEntry: TCheckBox
          Left = 6
          Top = 144
          Width = 97
          Height = 17
          Caption = '��������'
          Checked = True
          State = cbChecked
          TabOrder = 8
        end
        object cbTrigger: TCheckBox
          Left = 168
          Top = 13
          Width = 97
          Height = 17
          Caption = '��������'
          Checked = True
          State = cbChecked
          TabOrder = 9
        end
        object cbView: TCheckBox
          Left = 168
          Top = 29
          Width = 97
          Height = 17
          Caption = '�������������'
          Checked = True
          State = cbChecked
          TabOrder = 10
        end
        object cbSP: TCheckBox
          Left = 168
          Top = 46
          Width = 137
          Height = 17
          Caption = '�������� ���������'
          Checked = True
          State = cbChecked
          TabOrder = 11
        end
        object cbTable: TCheckBox
          Left = 168
          Top = 63
          Width = 97
          Height = 17
          Caption = '�������'
          Checked = True
          State = cbChecked
          TabOrder = 12
        end
      end
      object btnCompareSetting: TButton
        Left = 232
        Top = 127
        Width = 137
        Height = 25
        Caption = '�������� � ����������'
        TabOrder = 4
        OnClick = btnCompareSettingClick
      end
    end
    object pnBottom: TPanel
      Left = 0
      Top = 171
      Width = 1089
      Height = 534
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object sbDBCompare: TStatusBar
        Left = 0
        Top = 515
        Width = 1089
        Height = 19
        Panels = <
          item
            Width = 540
          end
          item
            Alignment = taRightJustify
            BiDiMode = bdLeftToRight
            ParentBiDiMode = False
            Width = 50
          end>
        SimplePanel = False
      end
      object SuperPageControl1: TSuperPageControl
        Left = 0
        Top = 0
        Width = 1089
        Height = 515
        BorderStyle = bsNone
        TabsVisible = True
        ActivePage = SuperTabSheet1
        Align = alClient
        TabHeight = 23
        TabOrder = 1
        object SuperTabSheet1: TSuperTabSheet
          Caption = '������� � �������'
          object lvMacros: TgsListView
            Left = 0
            Top = 0
            Width = 1089
            Height = 492
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = '������������'
              end
              item
                AutoSize = True
                Caption = '�������'
              end
              item
                Caption = '���� ���������'
                Width = 115
              end
              item
                Alignment = taCenter
                AutoSize = True
                Caption = '������'
                MaxWidth = 48
                MinWidth = 48
              end
              item
                AutoSize = True
                Caption = '������������'
              end
              item
                AutoSize = True
                Caption = '�������'
              end
              item
                Caption = '���� ���������'
                Width = 115
              end>
            GridLines = True
            ReadOnly = True
            RowSelect = True
            SmallImages = dmImages.il16x16
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = actMacrosDblClickExecute
          end
        end
        object SuperTabSheet2: TSuperTabSheet
          Caption = '����������'
          object lvMetaData: TgsListView
            Left = 0
            Top = 0
            Width = 1089
            Height = 492
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = '���'
              end
              item
                AutoSize = True
                Caption = '������������'
              end
              item
                Caption = '���� ���������'
                Width = 115
              end
              item
                AutoSize = True
                Caption = '������'
                MaxWidth = 48
                MinWidth = 48
              end
              item
                AutoSize = True
                Caption = '���'
              end
              item
                AutoSize = True
                Caption = '������������'
              end
              item
                Caption = '���� ���������'
                Width = 115
              end>
            GridLines = True
            ReadOnly = True
            RowSelect = True
            PopupMenu = pmMetaData
            SmallImages = dmImages.il16x16
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = lvMetaDataDblClick
          end
        end
      end
    end
  end
  object odExternalDB: TOpenDialog
    Filter = 'Interbase database|*.gdb;*.fdb|All|*.*'
    Left = 496
    Top = 248
  end
  object ibExtDataBase: TIBDatabase
    AllowStreamedConnected = False
    Left = 528
    Top = 248
  end
  object alCompareDB: TActionList
    Images = dmImages.il16x16
    Left = 559
    Top = 248
    object actCompareDB: TAction
      Caption = '��������'
      Hint = '��������'
      OnExecute = actCompareDBExecute
      OnUpdate = actCompareDBUpdate
    end
    object acRefresh: TAction
      Caption = 'acRefresh'
      OnExecute = acRefreshExecute
    end
    object actMacrosDblClick: TAction
      Caption = 'actMacrosDblClick'
      OnExecute = actMacrosDblClickExecute
    end
    object actAddPos: TAction
      Caption = '�������� � ��������� ...'
      Hint = '�������� � ���������'
      ImageIndex = 81
      OnExecute = actAddPosExecute
      OnUpdate = actAddPosUpdate
    end
  end
  object DSMacros: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 464
    Top = 248
  end
  object DSMetaData: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 464
    Top = 280
  end
  object pmMetaData: TPopupMenu
    Images = dmImages.il16x16
    Left = 376
    Top = 250
    object N1: TMenuItem
      Action = actAddPos
    end
  end
end
