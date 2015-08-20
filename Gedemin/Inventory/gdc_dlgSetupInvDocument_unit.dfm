inherited gdc_dlgSetupInvDocument: Tgdc_dlgSetupInvDocument
  Top = 190
  Caption = '��������� ��������'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pcMain: TPageControl
    ActivePage = tsIncomeMovement
    OnChange = pcMainChange
    OnChanging = pcMainChanging
    inherited tsCommon: TTabSheet
      inherited lblDocumentName: TLabel
        Top = 11
      end
      inherited Label7: TLabel
        Top = 169
      end
      inherited Label1: TLabel
        Top = 215
      end
      inherited Label2: TLabel
        Top = 238
      end
      inherited Label3: TLabel
        Width = 124
        Caption = '������������ �������:'
      end
      object lblDocument: TLabel [6]
        Left = 8
        Top = 192
        Width = 118
        Height = 13
        Caption = '�� ������� ���������:'
      end
      object lFormatDoc: TLabel [7]
        Left = 8
        Top = 146
        Width = 102
        Height = 13
        Caption = '������ ���������:'
      end
      inherited lFunction: TLabel
        Top = 261
      end
      inherited Label4: TLabel
        Top = 284
      end
      object lblNotification: TLabel [11]
        Left = 8
        Top = 344
        Width = 459
        Height = 13
        Caption = 
          '�������� (��������) ������� ����� � ������� ��������� ��� ������' +
          '��� ��� ���������.'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      inherited edDocumentName: TDBEdit
        Color = clWindow
        Enabled = True
      end
      inherited edDescription: TDBMemo
        Color = clWindow
        Enabled = True
      end
      inherited iblcExplorerBranch: TgsIBLookupComboBox
        Top = 165
        Condition = '(Classname is null) or (ClassName = '#39#39')'
        Color = clWindow
        Enabled = True
        TabOrder = 15
      end
      inherited iblcHeaderTable: TgsIBLookupComboBox
        Top = 211
        Color = clWindow
        Enabled = True
        TabOrder = 6
      end
      inherited iblcLineTable: TgsIBLookupComboBox
        Top = 234
        Color = clWindow
        Enabled = True
        TabOrder = 7
        OnChange = iblcLineTableChange
      end
      inherited edEnglishName: TEdit
        Color = 11141119
        Enabled = True
      end
      inherited dbcbIsCommon: TDBCheckBox
        Top = 306
        TabOrder = 14
        Visible = False
      end
      inherited dbeFunctionName: TDBEdit
        Top = 258
        TabOrder = 8
      end
      inherited btnConstr1: TButton
        Top = 258
        TabOrder = 9
      end
      inherited DBEdit1: TDBEdit
        Top = 282
        TabOrder = 11
      end
      inherited btnConstr2: TButton
        Top = 282
        TabOrder = 12
      end
      inherited btnDel1: TButton
        Top = 258
        TabOrder = 10
      end
      inherited btnDel2: TButton
        Top = 282
        TabOrder = 13
      end
      object cbTemplate: TComboBox
        Left = 157
        Top = 142
        Width = 352
        Height = 21
        Style = csDropDownList
        Color = 11141119
        ItemHeight = 13
        TabOrder = 4
        OnChange = cbTemplateChange
        OnClick = cbTemplateClick
        Items.Strings = (
          '������� ��������� ��������'
          '�������� � ���������� ������� ���'
          '������������������ ��������'
          '�������� ������������� ���')
      end
      object cbDocument: TComboBox
        Left = 157
        Top = 188
        Width = 352
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        OnClick = cbDocumentClick
      end
    end
    object tsFeatures: TTabSheet [1]
      Caption = '��������'
      ImageIndex = 3
      object lvFeatures: TListView
        Left = 7
        Top = 7
        Width = 224
        Height = 252
        Columns = <
          item
            AutoSize = True
            Caption = '������������ ��������'
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        SortType = stText
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = actAddFeatureExecute
      end
      object lvUsedFeatures: TListView
        Left = 283
        Top = 7
        Width = 224
        Height = 252
        Columns = <
          item
            AutoSize = True
            Caption = '��������� ��������'
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        SortType = stText
        TabOrder = 5
        ViewStyle = vsReport
        OnDblClick = actRemoveFeatureExecute
      end
      object btnAdd: TButton
        Left = 242
        Top = 69
        Width = 32
        Height = 21
        Action = actAddFeature
        TabOrder = 1
      end
      object btnRemove: TButton
        Left = 242
        Top = 142
        Width = 32
        Height = 21
        Action = actAddAllFeatures
        TabOrder = 2
      end
      object btnAddAll: TButton
        Left = 242
        Top = 105
        Width = 32
        Height = 21
        Action = actRemoveFeature
        TabOrder = 3
      end
      object btnRemoveAll: TButton
        Left = 242
        Top = 178
        Width = 32
        Height = 21
        Action = actRemoveAllFeatures
        TabOrder = 4
      end
      object rgFeatures: TRadioGroup
        Left = 8
        Top = 264
        Width = 499
        Height = 53
        ItemIndex = 0
        Items.Strings = (
          '�������� ����� ��������'
          '�������� ������������ ��������')
        TabOrder = 6
        OnClick = rgFeaturesClick
      end
      object cbIsChangeCardValue: TCheckBox
        Left = 8
        Top = 323
        Width = 329
        Height = 17
        Caption = '��������� �������� �������� ������������ ��������'
        TabOrder = 7
      end
      object cbIsAppendCardValue: TCheckBox
        Left = 8
        Top = 341
        Width = 337
        Height = 17
        Caption = '��������� ��������� �������� ������������ ��������'
        TabOrder = 8
      end
    end
    object tsIncomeMovement: TTabSheet [2]
      Caption = '������'
      ImageIndex = 4
      object Label6: TLabel
        Left = 8
        Top = 10
        Width = 127
        Height = 13
        Caption = '������ ����������� ��:'
        WordWrap = True
      end
      object lblDebitFrom: TLabel
        Left = 7
        Top = 77
        Width = 83
        Height = 13
        Caption = '���� � �������:'
      end
      object lblDebitSubFrom: TLabel
        Left = 7
        Top = 257
        Width = 83
        Height = 13
        Caption = '���� � �������:'
      end
      object lblDebitValue: TLabel
        Left = 7
        Top = 103
        Width = 90
        Height = 13
        Caption = '������ ��������:'
        WordWrap = True
      end
      object lblSubDebitValue: TLabel
        Left = 7
        Top = 284
        Width = 90
        Height = 13
        Caption = '������ ��������:'
        WordWrap = True
      end
      object cbDebitMovement: TComboBox
        Left = 140
        Top = 7
        Width = 368
        Height = 21
        Style = csDropDownList
        Color = 11141119
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbDebitMovementChange
      end
      object lvDebitMovementValues: TListView
        Left = 140
        Top = 100
        Width = 297
        Height = 77
        Columns = <
          item
            Caption = '������������'
            Width = 200
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 3
        ViewStyle = vsReport
      end
      object btnAddDebitValue: TButton
        Left = 444
        Top = 100
        Width = 64
        Height = 21
        Action = actAddDebitContact
        TabOrder = 4
      end
      object btnDeleteDebitValue: TButton
        Left = 444
        Top = 123
        Width = 64
        Height = 21
        Action = actDeleteDebitContact
        TabOrder = 5
      end
      object rgDebitFrom: TRadioGroup
        Left = 7
        Top = 29
        Width = 501
        Height = 38
        Caption = ' ������ ��: '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          '"�����" ���������'
          '������� ���������')
        TabOrder = 1
        OnClick = luCreditFromDropDown
      end
      object luDebitFrom: TComboBox
        Left = 140
        Top = 73
        Width = 368
        Height = 21
        Style = csDropDownList
        Color = 11141119
        ItemHeight = 13
        TabOrder = 2
        OnDropDown = luCreditFromDropDown
      end
      object luDebitSubFrom: TComboBox
        Left = 140
        Top = 253
        Width = 368
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 8
        OnDropDown = luCreditFromDropDown
      end
      object lvSubDebitMovementValues: TListView
        Left = 140
        Top = 280
        Width = 297
        Height = 77
        Columns = <
          item
            Caption = '������������'
            Width = 200
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 9
        ViewStyle = vsReport
      end
      object btnAddSubDebitValue: TButton
        Left = 444
        Top = 281
        Width = 64
        Height = 21
        Action = actAddSubDebitContact
        TabOrder = 10
      end
      object btnDeleteSubDebitValue: TButton
        Left = 444
        Top = 304
        Width = 64
        Height = 21
        Action = actDeleteSubDebitContact
        TabOrder = 11
      end
      object rgDebitSubFrom: TRadioGroup
        Left = 6
        Top = 209
        Width = 501
        Height = 38
        Caption = ' ����������� �� ������� ��: '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          '"�����" ���������'
          '������� ���������')
        TabOrder = 7
        OnClick = luCreditFromDropDown
      end
      object cbUseIncomeSub: TCheckBox
        Left = 6
        Top = 188
        Width = 225
        Height = 17
        Caption = '������������ ����������� �� �������:'
        TabOrder = 6
        OnClick = cbUseIncomeSubClick
      end
    end
    object tsOutlayMovement: TTabSheet [3]
      Caption = '������'
      ImageIndex = 5
      object Label8: TLabel
        Left = 7
        Top = 10
        Width = 125
        Height = 13
        Caption = '������ ����������� ��:'
        WordWrap = True
      end
      object lblCreditFrom: TLabel
        Left = 7
        Top = 77
        Width = 83
        Height = 13
        Caption = '���� � �������:'
      end
      object lblCreditSubFrom: TLabel
        Left = 7
        Top = 257
        Width = 83
        Height = 13
        Caption = '���� � �������:'
      end
      object lblCreditValue: TLabel
        Left = 7
        Top = 103
        Width = 90
        Height = 13
        Caption = '������ ��������:'
        WordWrap = True
      end
      object lblSubCreditValue: TLabel
        Left = 7
        Top = 284
        Width = 90
        Height = 13
        Caption = '������ ��������:'
        WordWrap = True
      end
      object cbCreditMovement: TComboBox
        Left = 140
        Top = 7
        Width = 368
        Height = 21
        Style = csDropDownList
        Color = 11141119
        ItemHeight = 0
        TabOrder = 0
        OnChange = cbDebitMovementChange
      end
      object lvCreditMovementValues: TListView
        Left = 140
        Top = 100
        Width = 297
        Height = 77
        Columns = <
          item
            Caption = '������������'
            Width = 200
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 3
        ViewStyle = vsReport
      end
      object btnAddCreditValue: TButton
        Left = 444
        Top = 100
        Width = 64
        Height = 21
        Action = actAddCreditContact
        TabOrder = 4
      end
      object btnDeleteCreditValue: TButton
        Left = 444
        Top = 123
        Width = 64
        Height = 21
        Action = actDeleteCreditContact
        TabOrder = 5
      end
      object rgCreditFrom: TRadioGroup
        Left = 7
        Top = 29
        Width = 501
        Height = 38
        Caption = ' ������ ��: '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          '"�����" ���������'
          '������� ���������')
        TabOrder = 1
        OnClick = luCreditFromDropDown
      end
      object luCreditFrom: TComboBox
        Left = 140
        Top = 73
        Width = 368
        Height = 21
        Style = csDropDownList
        Color = 11141119
        ItemHeight = 0
        TabOrder = 2
        OnDropDown = luCreditFromDropDown
      end
      object luCreditSubFrom: TComboBox
        Left = 140
        Top = 253
        Width = 368
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 8
        OnDropDown = luCreditFromDropDown
      end
      object lvSubCreditMovementValues: TListView
        Left = 140
        Top = 280
        Width = 297
        Height = 77
        Columns = <
          item
            Caption = '������������'
            Width = 200
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 9
        ViewStyle = vsReport
      end
      object btnAddSubCreditValue: TButton
        Left = 444
        Top = 281
        Width = 64
        Height = 21
        Action = actAddSubCreditContact
        TabOrder = 10
      end
      object btnDeleteSubCreditValue: TButton
        Left = 444
        Top = 304
        Width = 64
        Height = 21
        Action = actDeleteSubCreditContact
        TabOrder = 11
      end
      object rgCreditSubFrom: TRadioGroup
        Left = 6
        Top = 209
        Width = 501
        Height = 38
        Caption = ' ����������� �� ������� ��: '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          '"�����" ���������'
          '������� ���������')
        TabOrder = 7
        OnClick = luCreditFromDropDown
      end
      object cbUseOutlaySub: TCheckBox
        Left = 6
        Top = 188
        Width = 225
        Height = 17
        Caption = '������������ ����������� �� �������:'
        TabOrder = 6
        OnClick = cbUseIncomeSubClick
      end
    end
    object tsReferences: TTabSheet [4]
      Caption = '�����������'
      ImageIndex = 6
      object rgMovementDirection: TRadioGroup
        Left = 7
        Top = 44
        Width = 501
        Height = 38
        Caption = ' ������� ���������� �� ������  '
        Columns = 3
        ItemIndex = 0
        Items.Strings = (
          'FIFO'
          'LIFO'
          '�� ������� ���')
        TabOrder = 2
      end
      object cbRemains: TCheckBox
        Left = 7
        Top = 26
        Width = 258
        Height = 17
        Caption = '������������ ���������� �������� �� ���'
        TabOrder = 1
        OnClick = cbRemainsClick
      end
      object cbReference: TCheckBox
        Left = 7
        Top = 7
        Width = 186
        Height = 17
        Caption = '������������ ���������� ���'
        TabOrder = 0
      end
      object cbControlRemains: TCheckBox
        Left = 7
        Top = 87
        Width = 201
        Height = 17
        Caption = '������������ �������� ��������'
        TabOrder = 3
        OnClick = cbRemainsClick
      end
      object cbLiveTimeRemains: TCheckBox
        Left = 7
        Top = 107
        Width = 242
        Height = 17
        Caption = '�������� ������ �� ������� �������'
        TabOrder = 5
        OnClick = cbRemainsClick
      end
      object cbDelayedDocument: TCheckBox
        Left = 7
        Top = 127
        Width = 210
        Height = 17
        Caption = '�������� ����� ���� ����������'
        TabOrder = 6
      end
      object cbMinusRemains: TCheckBox
        Left = 276
        Top = 87
        Width = 209
        Height = 17
        Caption = '����� �� ������������� ��������'
        TabOrder = 4
        OnClick = cbMinusRemainsClick
      end
      object gbMinusFeatures: TGroupBox
        Left = 7
        Top = 167
        Width = 501
        Height = 193
        Hint = 
          '� ��������� ��� ������ �� ������������� �������� ������������ ��' +
          '���� �������� ����� ��������'
        Caption = ' �������� ��� ������ �� ������������� �������� '
        ParentShowHint = False
        ShowHint = True
        TabOrder = 9
        Visible = False
        object lvMinusFeatures: TListView
          Left = 7
          Top = 21
          Width = 224
          Height = 166
          Columns = <
            item
              AutoSize = True
              Caption = '������������ ��������'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = actAdd_MinusFeatureExecute
        end
        object btnAdd_Minus: TButton
          Left = 235
          Top = 51
          Width = 32
          Height = 21
          Action = actAdd_MinusFeature
          TabOrder = 1
        end
        object btnRemove_Minus: TButton
          Left = 235
          Top = 82
          Width = 32
          Height = 21
          Action = actRemove_MinusFeature
          TabOrder = 2
        end
        object btnAddAll_Minus: TButton
          Left = 235
          Top = 112
          Width = 32
          Height = 21
          Action = actAddAll_MinusFeature
          TabOrder = 3
        end
        object btnRemoveAll_Minus: TButton
          Left = 235
          Top = 143
          Width = 32
          Height = 21
          Action = actRemoveAll_MinusFeature
          TabOrder = 4
        end
        object lvMinusUsedFeatures: TListView
          Left = 270
          Top = 21
          Width = 224
          Height = 166
          Columns = <
            item
              AutoSize = True
              Caption = '��������� ��������'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 5
          ViewStyle = vsReport
          OnDblClick = actRemove_MinusFeatureExecute
        end
      end
      object cbIsUseCompanyKey: TCheckBox
        Left = 276
        Top = 127
        Width = 206
        Height = 17
        Caption = '����������� �� ������� ��������'
        TabOrder = 7
      end
      object cbSaveRestWindowOption: TCheckBox
        Left = 7
        Top = 147
        Width = 273
        Height = 17
        Caption = '��������� ��������� ���� ��������'
        TabOrder = 8
      end
      object cbEndMonthRemains: TCheckBox
        Left = 276
        Top = 107
        Width = 229
        Height = 17
        Caption = '�������� �������� �� ����� ������'
        TabOrder = 10
      end
      object cbWithoutSearchRemains: TCheckBox
        Left = 276
        Top = 146
        Width = 221
        Height = 17
        Caption = '�������� ��� ������ ��������'
        TabOrder = 11
        Visible = False
      end
    end
  end
  inherited alBase: TActionList
    Left = 270
    Top = 255
    object actAddFeature: TAction [10]
      Category = 'Features'
      Caption = '>'
      OnExecute = actAddFeatureExecute
      OnUpdate = actAddFeatureUpdate
    end
    object actRemoveFeature: TAction [11]
      Category = 'Features'
      Caption = '<'
      OnExecute = actRemoveFeatureExecute
      OnUpdate = actRemoveFeatureUpdate
    end
    object actAddAllFeatures: TAction [12]
      Category = 'Features'
      Caption = '>>'
      OnExecute = actAddAllFeaturesExecute
      OnUpdate = actAddAllFeaturesUpdate
    end
    object actRemoveAllFeatures: TAction [13]
      Category = 'Features'
      Caption = '<<'
      OnExecute = actRemoveAllFeaturesExecute
      OnUpdate = actRemoveAllFeaturesUpdate
    end
    object actAddDebitContact: TAction [14]
      Category = 'Income'
      Caption = '��������'
      OnExecute = actAddDebitContactExecute
      OnUpdate = actAddDebitContactUpdate
    end
    object actDeleteDebitContact: TAction [15]
      Category = 'Income'
      Caption = '�������'
      OnExecute = actDeleteDebitContactExecute
      OnUpdate = actDeleteDebitContactUpdate
    end
    object actAddCreditContact: TAction [16]
      Category = 'Outlay'
      Caption = '��������'
      OnExecute = actAddDebitContactExecute
      OnUpdate = actAddDebitContactUpdate
    end
    object actDeleteCreditContact: TAction [17]
      Category = 'Outlay'
      Caption = '�������'
      OnExecute = actDeleteDebitContactExecute
      OnUpdate = actDeleteDebitContactUpdate
    end
    object actAddSubDebitContact: TAction [18]
      Category = 'Income'
      Caption = '��������'
      OnExecute = actAddDebitContactExecute
      OnUpdate = actAddDebitContactUpdate
    end
    object actDeleteSubDebitContact: TAction [19]
      Category = 'Income'
      Caption = '�������'
      OnExecute = actDeleteDebitContactExecute
      OnUpdate = actDeleteDebitContactUpdate
    end
    object actAddSubCreditContact: TAction [20]
      Category = 'Outlay'
      Caption = '��������'
      OnExecute = actAddDebitContactExecute
      OnUpdate = actAddDebitContactUpdate
    end
    object actDeleteSubCreditContact: TAction [21]
      Category = 'Outlay'
      Caption = '�������'
      OnExecute = actDeleteDebitContactExecute
      OnUpdate = actDeleteDebitContactUpdate
    end
    object actAddAmountField: TAction [22]
      Category = 'AmountField'
      Caption = '>'
    end
    object actCreateCalcMacros: TAction [23]
      Category = 'AmountField'
      Caption = '�������'
    end
    object actViewCalcMacros: TAction [24]
      Category = 'AmountField'
      Caption = '��������'
    end
    object actDeleteCalcMacros: TAction [25]
      Category = 'AmountField'
      Caption = '�������'
    end
    object actDelAmountField: TAction [26]
      Category = 'AmountField'
      Caption = '<'
    end
    object actAdd_MinusFeature: TAction [39]
      Category = 'Features'
      Caption = '>'
      OnExecute = actAdd_MinusFeatureExecute
    end
    object actRemove_MinusFeature: TAction [40]
      Category = 'Features'
      Caption = '<'
      OnExecute = actRemove_MinusFeatureExecute
    end
    object actAddAll_MinusFeature: TAction [41]
      Category = 'Features'
      Caption = '>>'
      OnExecute = actAddAll_MinusFeatureExecute
    end
    object actRemoveAll_MinusFeature: TAction [42]
      Category = 'Features'
      Caption = '<<'
      OnExecute = actRemoveAll_MinusFeatureExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 272
    Top = 231
  end
  inherited pm_dlgG: TPopupMenu
    Left = 448
    Top = 88
  end
  inherited ibtrCommon: TIBTransaction
    Left = 296
    Top = 248
  end
  inherited gdcFunctionHeader: TgdcFunction
    Left = 334
    Top = 209
  end
  inherited dsFunction: TDataSource
    Left = 446
    Top = 41
  end
  inherited gdcFunctionLine: TgdcFunction
    Left = 488
    Top = 200
  end
  inherited DataSource1: TDataSource
    Left = 456
    Top = 200
  end
end
