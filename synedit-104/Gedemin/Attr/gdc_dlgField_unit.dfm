inherited gdc_dlgField: Tgdc_dlgField
  Left = 207
  Top = 42
  HelpContext = 82
  ActiveControl = dbedTypeName
  BorderIcons = [biSystemMenu]
  Caption = '�������������� ���� ����'
  ClientHeight = 483
  ClientWidth = 567
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 456
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 85
    Top = 456
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 405
    Top = 456
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 485
    Top = 456
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 456
    TabOrder = 3
  end
  object pnlMain: TPanel [5]
    Left = 0
    Top = 0
    Width = 561
    Height = 448
    BevelOuter = bvNone
    TabOrder = 0
    object pcFieldType: TPageControl
      Left = 0
      Top = 0
      Width = 561
      Height = 448
      ActivePage = tsMain
      Align = alClient
      TabOrder = 0
      OnChange = pcFieldTypeChange
      object tsMain: TTabSheet
        Caption = '�����'
        object lblIBType: TLabel
          Left = 12
          Top = 56
          Width = 224
          Height = 13
          Caption = '�������� ���� ���� (�� ���������� �����):'
        end
        object lblName: TLabel
          Left = 12
          Top = 107
          Width = 192
          Height = 13
          Caption = '�������������� �������� ���� ����:'
        end
        object Label2: TLabel
          Left = 12
          Top = 184
          Width = 202
          Height = 13
          Caption = '�������� ���� (�������������� ����):'
        end
        object Label8: TLabel
          Left = 12
          Top = 10
          Width = 529
          Height = 17
          AutoSize = False
          Caption = '  ����� ��������'
          Color = clBlack
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindow
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Layout = tlCenter
        end
        object dbedName: TDBEdit
          Left = 280
          Top = 103
          Width = 261
          Height = 21
          DataField = 'LNAME'
          DataSource = dsgdcBase
          TabOrder = 1
        end
        object dbedTypeName: TDBEdit
          Left = 280
          Top = 53
          Width = 261
          Height = 21
          CharCase = ecUpperCase
          DataField = 'FIELDNAME'
          DataSource = dsgdcBase
          MaxLength = 31
          TabOrder = 0
          OnEnter = dbedTypeNameEnter
          OnKeyDown = dbedTypeNameKeyDown
          OnKeyPress = dbedTypeNameKeyPress
        end
        object dbedDecription: TDBMemo
          Left = 280
          Top = 160
          Width = 261
          Height = 61
          DataField = 'DESCRIPTION'
          DataSource = dsgdcBase
          TabOrder = 2
        end
      end
      object tsType: TTabSheet
        Caption = '��� ������'
        ImageIndex = 1
        object Label9: TLabel
          Left = 12
          Top = 10
          Width = 529
          Height = 17
          AutoSize = False
          Caption = '  ��� ������'
          Color = clBlack
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindow
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Layout = tlCenter
        end
        object Label10: TLabel
          Left = 12
          Top = 285
          Width = 529
          Height = 17
          AutoSize = False
          Caption = '  �������� ����������� ����'
          Color = clBlack
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindow
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Layout = tlCenter
        end
        object lblCharacterSet: TLabel
          Left = 13
          Top = 249
          Width = 137
          Height = 13
          Caption = '��������� (Character set):'
        end
        object lblCollation: TLabel
          Left = 276
          Top = 249
          Width = 97
          Height = 13
          Caption = '�������� (Collate):'
        end
        object lblOtherLanguage: TLabel
          Left = 12
          Top = 224
          Width = 529
          Height = 17
          AutoSize = False
          Color = clBlack
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindow
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
        end
        object pcDataType: TPageControl
          Left = 8
          Top = 31
          Width = 534
          Height = 183
          ActivePage = tsString
          HotTrack = True
          MultiLine = True
          RaggedRight = True
          Style = tsFlatButtons
          TabOrder = 0
          OnChange = pcDataTypeChange
          OnChanging = pcDataTypeChanging
          object tsString: TTabSheet
            Caption = '���������'
            object pnlString: TPanel
              Left = 0
              Top = 0
              Width = 526
              Height = 152
              Align = alClient
              BevelInner = bvLowered
              TabOrder = 0
              object Label1: TLabel
                Left = 200
                Top = 16
                Width = 74
                Height = 13
                Caption = '����� ������:'
              end
              object rgString: TRadioGroup
                Left = 12
                Top = 8
                Width = 171
                Height = 98
                Caption = ' ������:'
                Items.Strings = (
                  '- ���������� �����'
                  '- ���������� �����')
                TabOrder = 0
              end
              object edStringLength: TEdit
                Left = 280
                Top = 13
                Width = 61
                Height = 21
                TabOrder = 1
                Text = 'edStringLength'
              end
            end
          end
          object tsNumeric: TTabSheet
            Caption = '��������'
            ImageIndex = 1
            object pnlNumeric: TPanel
              Left = 0
              Top = 0
              Width = 526
              Height = 152
              Align = alClient
              BevelInner = bvLowered
              TabOrder = 0
              object rgNumeric: TRadioGroup
                Left = 12
                Top = 8
                Width = 229
                Height = 98
                Caption = ' �����: '
                Items.Strings = (
                  '- ����� ����� (�������)'
                  '- ����� ����� (��������)'
                  '- ������� ����� ������������� �����'
                  '- ������� ����� � ��������� �������')
                TabOrder = 0
                OnClick = rgNumericClick
              end
              object gbPrecision: TGroupBox
                Left = 248
                Top = 8
                Width = 263
                Height = 98
                Caption = ' ��������� ����� � ������: '
                TabOrder = 1
                object lblPrecision: TLabel
                  Left = 17
                  Top = 21
                  Width = 99
                  Height = 13
                  Caption = '���-�� ���� �����:'
                end
                object lblScale: TLabel
                  Left = 17
                  Top = 47
                  Width = 149
                  Height = 13
                  Caption = '���������� ���� ��� �����:'
                end
                object edPrecision: TEdit
                  Left = 182
                  Top = 17
                  Width = 76
                  Height = 21
                  TabOrder = 0
                  Text = 'edPrecision'
                end
                object edScale: TEdit
                  Left = 182
                  Top = 44
                  Width = 76
                  Height = 21
                  TabOrder = 1
                  Text = 'edScale'
                end
              end
            end
          end
          object tsTime: TTabSheet
            Caption = '���������'
            ImageIndex = 2
            object pnlTime: TPanel
              Left = 0
              Top = 0
              Width = 526
              Height = 152
              Align = alClient
              BevelInner = bvLowered
              TabOrder = 0
              object rgData: TRadioGroup
                Left = 12
                Top = 8
                Width = 171
                Height = 98
                Caption = ' ��������� ��� ��������: '
                Items.Strings = (
                  '- ������ �����'
                  '- ������ ����'
                  '- ����� � ����')
                TabOrder = 0
              end
            end
          end
          object tsBlob: TTabSheet
            Caption = '��������'
            ImageIndex = 5
            object pnlBlob: TPanel
              Left = 0
              Top = 0
              Width = 526
              Height = 152
              Align = alClient
              BevelInner = bvLowered
              TabOrder = 0
              object lblSubType: TLabel
                Left = 198
                Top = 89
                Width = 69
                Height = 13
                Caption = '������ ����:'
              end
              object lblSegmentSize: TLabel
                Left = 359
                Top = 89
                Width = 88
                Height = 13
                Caption = '������ ��������:'
              end
              object rgBlobType: TRadioGroup
                Left = 12
                Top = 8
                Width = 171
                Height = 98
                Caption = ' �������� ����: '
                Items.Strings = (
                  '- ���������� ����'
                  '- ������������� ����')
                TabOrder = 0
                OnClick = rgBlobTypeClick
              end
              object edSubType: TEdit
                Left = 271
                Top = 85
                Width = 58
                Height = 21
                TabOrder = 2
                Text = 'edSubType'
              end
              object edSegmentSize: TEdit
                Left = 452
                Top = 85
                Width = 58
                Height = 21
                TabOrder = 3
                Text = 'edSegmentSize'
              end
              object memoBlobInfo: TMemo
                Left = 200
                Top = 12
                Width = 311
                Height = 54
                TabStop = False
                BorderStyle = bsNone
                Lines.Strings = (
                  '�������� ���� - ���� ��� ������������� ������� � ����. '
                  '��������� ��� - �������� ������ �������� ������. '
                  '������������ ��� - ����������� ������, ����� � �.�.')
                ParentColor = True
                TabOrder = 1
              end
            end
          end
          object tsReference: TTabSheet
            Caption = '������'
            ImageIndex = 3
            object pnlReference: TPanel
              Left = 0
              Top = 0
              Width = 526
              Height = 152
              Align = alClient
              BevelInner = bvLowered
              TabOrder = 0
              object Label3: TLabel
                Left = 12
                Top = 10
                Width = 102
                Height = 13
                Caption = '������ �� �������:'
              end
              object lblRefListField: TLabel
                Left = 262
                Top = 10
                Width = 169
                Height = 13
                Caption = '���� ������� ��� �����������:'
              end
              object Label4: TLabel
                Left = 12
                Top = 50
                Width = 137
                Height = 31
                AutoSize = False
                Caption = '������� ������ �������� �� ����� SQL:'
                WordWrap = True
              end
              object luRefRelation: TgsIBLookupComboBox
                Left = 12
                Top = 24
                Width = 239
                Height = 21
                HelpContext = 1
                Database = dmDatabase.ibdbGAdmin
                Transaction = ibtrCommon
                Fields = 'relationname'
                ListTable = 'at_relations'
                ListField = 'lname'
                KeyField = 'id'
                SortOrder = soAsc
                gdClassName = 'TgdcTable'
                ItemHeight = 0
                ParentShowHint = False
                ShowHint = True
                TabOrder = 0
                OnChange = luRefRelationChange
              end
              object luRefListField: TgsIBLookupComboBox
                Left = 262
                Top = 24
                Width = 239
                Height = 21
                HelpContext = 1
                Database = dmDatabase.ibdbGAdmin
                Transaction = ibtrCommon
                Fields = 'fieldname'
                ListTable = 'at_relation_fields'
                ListField = 'lname'
                KeyField = 'id'
                SortOrder = soAsc
                Condition = 'RELATIONKEY = -1'
                gdClassName = 'TgdcTableField'
                OnCreateNewObject = luRefListFieldCreateNewObject
                ItemHeight = 0
                ParentShowHint = False
                ShowHint = True
                TabOrder = 1
              end
              object memRefCondition: TDBMemo
                Left = 162
                Top = 50
                Width = 339
                Height = 33
                DataField = 'REFCONDITION'
                DataSource = dsgdcBase
                TabOrder = 2
              end
            end
          end
          object tsSet: TTabSheet
            Caption = '���������'
            ImageIndex = 4
            object pnlSet: TPanel
              Left = 0
              Top = 0
              Width = 526
              Height = 152
              Align = alClient
              BevelInner = bvLowered
              TabOrder = 0
              object Label16: TLabel
                Left = 12
                Top = 10
                Width = 102
                Height = 13
                Caption = '������ �� �������:'
              end
              object Label17: TLabel
                Left = 262
                Top = 10
                Width = 169
                Height = 13
                Caption = '���� ������� ��� �����������:'
              end
              object Label19: TLabel
                Left = 202
                Top = 92
                Width = 63
                Height = 13
                Caption = '����� ����:'
              end
              object Label5: TLabel
                Left = 12
                Top = 50
                Width = 137
                Height = 31
                AutoSize = False
                Caption = '������� ������ �������� �� ����� SQL:'
                WordWrap = True
              end
              object luSetRelation: TgsIBLookupComboBox
                Left = 12
                Top = 24
                Width = 239
                Height = 21
                HelpContext = 1
                Database = dmDatabase.ibdbGAdmin
                Transaction = ibtrCommon
                DataField = 'settablekey'
                Fields = 'relationname'
                ListTable = 'at_relations'
                ListField = 'lname'
                KeyField = 'id'
                SortOrder = soAsc
                gdClassName = 'TgdcTable'
                ItemHeight = 0
                ParentShowHint = False
                ShowHint = True
                TabOrder = 0
                OnChange = luSetRelationChange
              end
              object luSetListField: TgsIBLookupComboBox
                Left = 262
                Top = 24
                Width = 239
                Height = 21
                HelpContext = 1
                Database = dmDatabase.ibdbGAdmin
                Transaction = ibtrCommon
                DataField = 'setlistfieldkey'
                Fields = 'fieldname'
                ListTable = 'at_relation_fields'
                ListField = 'lname'
                KeyField = 'id'
                SortOrder = soAsc
                Condition = 'RELATIONKEY = -1'
                gdClassName = 'TgdcTableField'
                OnCreateNewObject = luSetListFieldCreateNewObject
                ItemHeight = 0
                ParentShowHint = False
                ShowHint = True
                TabOrder = 1
              end
              object cbCreateTextField: TCheckBox
                Left = 12
                Top = 91
                Width = 177
                Height = 17
                Caption = '��������� � ��������� �����'
                TabOrder = 2
                OnClick = cbCreateTextFieldClick
              end
              object edSetFieldLength: TEdit
                Left = 272
                Top = 89
                Width = 71
                Height = 21
                TabOrder = 3
                Text = 'edSetFieldLength'
              end
              object memSetCondition: TDBMemo
                Left = 162
                Top = 50
                Width = 339
                Height = 33
                DataField = 'SETCONDITION'
                DataSource = dsgdcBase
                TabOrder = 4
              end
            end
          end
          object tsEnumeration: TTabSheet
            Caption = '������������'
            ImageIndex = 6
            object Panel1: TPanel
              Left = 0
              Top = 0
              Width = 526
              Height = 152
              Align = alClient
              BevelInner = bvLowered
              TabOrder = 0
              object Label6: TLabel
                Left = 8
                Top = 8
                Width = 86
                Height = 13
                Caption = '������ ��������'
              end
              object lValNum: TLabel
                Left = 286
                Top = 22
                Width = 48
                Height = 13
                Caption = '��������'
              end
              object Label11: TLabel
                Left = 286
                Top = 62
                Width = 73
                Height = 13
                Caption = '������������'
              end
              object lvNumeration: TListView
                Left = 8
                Top = 24
                Width = 273
                Height = 118
                Columns = <
                  item
                    Caption = '��������'
                    Width = 60
                  end
                  item
                    Caption = '������������'
                    Width = 235
                  end>
                HideSelection = False
                TabOrder = 0
                ViewStyle = vsReport
                OnSelectItem = lvNumerationSelectItem
              end
              object edValueNumeration: TEdit
                Left = 286
                Top = 38
                Width = 233
                Height = 21
                MaxLength = 1
                TabOrder = 1
              end
              object edNameNumeration: TEdit
                Left = 286
                Top = 78
                Width = 233
                Height = 21
                TabOrder = 2
              end
              object bAddNumeration: TButton
                Left = 286
                Top = 105
                Width = 75
                Height = 25
                Action = acAddNumeration
                TabOrder = 3
              end
              object bDelNumeration: TButton
                Left = 366
                Top = 105
                Width = 75
                Height = 25
                Action = acDeleteNumeration
                TabOrder = 4
              end
              object Button1: TButton
                Left = 446
                Top = 105
                Width = 75
                Height = 25
                Action = actReplaceNum
                TabOrder = 5
              end
            end
          end
        end
        object cbAlwaysNotNull: TCheckBox
          Left = 15
          Top = 306
          Width = 256
          Height = 17
          Caption = '���� ����������� ������ ���� ���������'
          TabOrder = 4
        end
        object cbDefaultValue: TCheckBox
          Left = 14
          Top = 332
          Width = 149
          Height = 17
          Caption = '�������� �� ���������'
          TabOrder = 5
          OnClick = cbDefaultValueClick
        end
        object edDefaultValue: TEdit
          Left = 220
          Top = 330
          Width = 321
          Height = 21
          TabOrder = 6
          Text = 'edDefaultValue'
        end
        object cbConstraints: TCheckBox
          Left = 14
          Top = 361
          Width = 149
          Height = 17
          Caption = '�����������'
          TabOrder = 7
          OnClick = cbConstraintsClick
        end
        object edConstraints: TEdit
          Left = 220
          Top = 359
          Width = 321
          Height = 21
          TabOrder = 8
          Text = 'edConstraints'
        end
        object cbOtherLanguage: TCheckBox
          Left = 12
          Top = 224
          Width = 248
          Height = 17
          Alignment = taLeftJustify
          Caption = ' ���������� ��������� �����'
          Color = clBlack
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindow
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          OnClick = cbOtherLanguageClick
        end
        object cbCharacterSet: TComboBox
          Left = 159
          Top = 246
          Width = 103
          Height = 21
          ItemHeight = 13
          TabOrder = 2
          Items.Strings = (
            'WIN1251')
        end
        object cbCollation: TComboBox
          Left = 392
          Top = 246
          Width = 103
          Height = 21
          ItemHeight = 13
          TabOrder = 3
          Items.Strings = (
            'PXW_CYRL')
        end
      end
      object tsVisualSettings: TTabSheet
        Caption = '����������'
        ImageIndex = 2
        object Label13: TLabel
          Left = 12
          Top = 10
          Width = 529
          Height = 17
          AutoSize = False
          Caption = '  ���������� ���������'
          Color = clBlack
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindow
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
          Layout = tlCenter
        end
        object Label14: TLabel
          Left = 12
          Top = 37
          Width = 163
          Height = 13
          Caption = '������ ���� ��� �����������:'
        end
        object lblFormat: TLabel
          Left = 12
          Top = 115
          Width = 84
          Height = 13
          Caption = '������ ������:'
        end
        object lblBusinessClass: TLabel
          Left = 12
          Top = 141
          Width = 70
          Height = 13
          Caption = '������-�����:'
        end
        object lblClassSubType: TLabel
          Left = 12
          Top = 167
          Width = 79
          Height = 13
          Caption = '������ ������:'
        end
        object dbrgAligment: TDBRadioGroup
          Left = 12
          Top = 190
          Width = 529
          Height = 61
          Caption = ' ������������: '
          Columns = 3
          DataField = 'ALIGNMENT'
          DataSource = dsgdcBase
          Items.Strings = (
            '�� ������ ����'
            '�� ������� ����'
            '�� ������')
          TabOrder = 4
          Values.Strings = (
            'L'
            'R'
            'C')
        end
        object dbedColWidth: TDBEdit
          Left = 312
          Top = 34
          Width = 109
          Height = 21
          DataField = 'COLWIDTH'
          DataSource = dsgdcBase
          TabOrder = 0
        end
        object dbcbVisible: TDBCheckBox
          Left = 12
          Top = 63
          Width = 409
          Height = 17
          Alignment = taLeftJustify
          Caption = '���� �������� ������� �� ���������'
          DataField = 'VISIBLE'
          DataSource = dsgdcBase
          TabOrder = 1
          ValueChecked = '1'
          ValueUnchecked = '0'
        end
        object dbedFormat: TDBEdit
          Left = 262
          Top = 108
          Width = 158
          Height = 21
          DataField = 'FORMAT'
          DataSource = dsgdcBase
          TabOrder = 3
        end
        object rgAutoUpdate: TRadioGroup
          Left = 12
          Top = 262
          Width = 529
          Height = 91
          Caption = 
            ' �������������� ���������� ���������� �������� �����, ��������� ' +
            '� ������ ����� ����: '
          ItemIndex = 2
          Items.Strings = (
            '�������� ��������� �� ���� �����'
            
              '�������� ��������� � �����, ��� ��������� ��������� � ����������' +
              '� ���� ����'
            '�� ��������� ���������')
          TabOrder = 5
        end
        object dbcbReadOnly: TDBCheckBox
          Left = 12
          Top = 89
          Width = 409
          Height = 17
          Alignment = taLeftJustify
          Caption = '��������� �������������� ����'
          DataField = 'READONLY'
          DataSource = dsgdcBase
          TabOrder = 2
          ValueChecked = '1'
          ValueUnchecked = '0'
        end
        object comboBusinessClass: TComboBox
          Left = 150
          Top = 135
          Width = 271
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 6
          OnChange = comboBusinessClassChange
          OnClick = comboBusinessClassClick
        end
        object comboClassSubType: TComboBox
          Left = 150
          Top = 163
          Width = 271
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 7
        end
      end
    end
  end
  inherited alBase: TActionList
    object acAddNumeration: TAction
      Category = 'Numeartion'
      Caption = '��������'
      OnExecute = acAddNumerationExecute
      OnUpdate = acAddNumerationUpdate
    end
    object acDeleteNumeration: TAction
      Category = 'Numeartion'
      Caption = '�������'
      OnExecute = acDeleteNumerationExecute
      OnUpdate = acDeleteNumerationUpdate
    end
    object actReplaceNum: TAction
      Category = 'Numeartion'
      Caption = '��������'
      OnExecute = actReplaceNumExecute
      OnUpdate = actReplaceNumUpdate
    end
  end
end
