object dlgDetailBill: TdlgDetailBill
  Left = 221
  Top = 103
  Width = 740
  Height = 539
  Caption = '����� �����������'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 724
    Height = 55
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 14
      Width = 99
      Height = 13
      Caption = '������� ���������'
    end
    object Label2: TLabel
      Left = 248
      Top = 14
      Width = 80
      Height = 13
      Caption = '�������������'
    end
    object Label4: TLabel
      Left = 14
      Top = 34
      Width = 647
      Height = 13
      Caption = 
        '��������: ��������� �� ������ ��������� � ������� ���������, �� ' +
        '������������� - ������������ � ���-�� '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
    end
    object gsiblcBaseDocument: TgsIBLookupComboBox
      Left = 136
      Top = 10
      Width = 105
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTransaction
      Fields = 'documentdate'
      ListTable = 'GD_V_DOCREALCENTR'
      ListField = 'NUMBER'
      KeyField = 'ID'
      CheckUserRights = False
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnExit = gsiblcBaseDocumentExit
    end
    object bMake: TButton
      Left = 583
      Top = 8
      Width = 91
      Height = 25
      Action = actMake
      TabOrder = 2
    end
    object edOtherBill: TEdit
      Left = 336
      Top = 10
      Width = 241
      Height = 21
      Hint = '�������� ������ �������������� ��������� ����� ,'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 459
    Width = 724
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Panel7: TPanel
      Left = 444
      Top = 0
      Width = 280
      Height = 42
      Align = alRight
      BevelOuter = bvNone
      Caption = 'Panel7'
      TabOrder = 0
      object bOk: TButton
        Left = 24
        Top = 8
        Width = 75
        Height = 25
        Action = actOk
        Default = True
        TabOrder = 0
      end
      object bNext: TButton
        Left = 112
        Top = 8
        Width = 75
        Height = 25
        Action = actNext
        TabOrder = 1
      end
      object bCancel: TButton
        Left = 200
        Top = 8
        Width = 75
        Height = 25
        Action = actCancel
        TabOrder = 2
      end
    end
    object bHelp: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Action = actHelp
      TabOrder = 1
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 55
    Width = 724
    Height = 404
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object Panel4: TPanel
      Left = 5
      Top = 5
      Width = 714
      Height = 101
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      object lblContact: TLabel
        Left = 10
        Top = 9
        Width = 140
        Height = 13
        Caption = '������������ �����������'
        Enabled = False
      end
      object lblNumberBill: TLabel
        Left = 10
        Top = 32
        Width = 89
        Height = 13
        Caption = '����� ���������'
        Enabled = False
      end
      object lPrice: TLabel
        Left = 10
        Top = 55
        Width = 57
        Height = 13
        Caption = '�����-����'
        Enabled = False
      end
      object lPriceField: TLabel
        Left = 472
        Top = 55
        Width = 63
        Height = 13
        Caption = '���� ������'
        Enabled = False
      end
      object lblDateDocument: TLabel
        Left = 474
        Top = 83
        Width = 3
        Height = 13
      end
      object gsiblcCompany: TgsIBLookupComboBox
        Left = 168
        Top = 5
        Width = 297
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        Fields = 'CITY'
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'CONTACTTYPE IN (2,3,4,5)'
        gdClassName = 'TgdcCompany'
        Enabled = False
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
      object edNumBill: TEdit
        Left = 168
        Top = 28
        Width = 297
        Height = 21
        Enabled = False
        TabOrder = 1
      end
      object bNew: TButton
        Left = 10
        Top = 76
        Width = 75
        Height = 25
        Action = actNew
        TabOrder = 2
      end
      object bReplace: TButton
        Left = 89
        Top = 76
        Width = 75
        Height = 25
        Action = actReplace
        TabOrder = 3
      end
      object bDel: TButton
        Left = 168
        Top = 76
        Width = 75
        Height = 25
        Action = actDelete
        TabOrder = 4
      end
      object cbCheckQuantity: TCheckBox
        Left = 248
        Top = 81
        Width = 217
        Height = 17
        Caption = '������������ �������� ����������'
        TabOrder = 5
      end
      object rgCostType: TRadioGroup
        Left = 471
        Top = 1
        Width = 199
        Height = 47
        Caption = '��� ����'
        Enabled = False
        ItemIndex = 0
        Items.Strings = (
          '�� ���������'
          '�� �����-�����')
        TabOrder = 6
      end
      object gsiblcPrice: TgsIBLookupComboBox
        Left = 168
        Top = 51
        Width = 297
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'GD_PRICE'
        ListField = 'NAME'
        KeyField = 'ID'
        Enabled = False
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
      end
      object cbPriceField: TComboBox
        Left = 544
        Top = 50
        Width = 127
        Height = 21
        Style = csDropDownList
        Enabled = False
        ItemHeight = 13
        TabOrder = 8
      end
    end
    object Panel5: TPanel
      Left = 5
      Top = 204
      Width = 714
      Height = 195
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 4
      Caption = 'Panel5'
      TabOrder = 2
      object Panel8: TPanel
        Left = 4
        Top = 133
        Width = 706
        Height = 58
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object gsdbgrAmount: TgsDBGrid
          Left = 481
          Top = 0
          Width = 225
          Height = 58
          TabStop = False
          Align = alClient
          BorderStyle = bsNone
          DataSource = dsAmount
          Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
          ReadOnly = True
          RefreshType = rtNone
          TabOrder = 0
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ShowTotals = False
          Columns = <
            item
              Expanded = False
              FieldName = 'DocRealPosKey'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'GoodKey'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'GoodName'
              Title.Caption = '������������ ���'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'QuantityBase'
              Title.Caption = '���-��'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'QuantityRest'
              Title.Caption = '�������'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity1'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity2'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity3'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity4'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity5'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity6'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity7'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity8'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity9'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity10'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity11'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity12'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity13'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity14'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity15'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity16'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity17'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity18'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity19'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity20'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity21'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity22'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity23'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity24'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity25'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity26'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity27'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity28'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity29'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity30'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity31'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity32'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity33'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity34'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity35'
              Width = -1
              Visible = False
            end>
        end
        object gsDBGrid1: TgsDBGrid
          Left = 0
          Top = 0
          Width = 481
          Height = 58
          TabStop = False
          Align = alLeft
          BorderStyle = bsNone
          DataSource = dsAmount
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
          ReadOnly = True
          RefreshType = rtNone
          TabOrder = 1
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ShowTotals = False
          Columns = <
            item
              Expanded = False
              FieldName = 'DocRealPosKey'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'GoodKey'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'GoodName'
              Title.Caption = '������������ ���'
              Width = 378
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'QuantityBase'
              Title.Caption = '���-��'
              Width = 40
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'QuantityRest'
              Title.Caption = '�������'
              Width = 48
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'Quantity1'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity2'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity3'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity4'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity5'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity6'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity7'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity8'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity9'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity10'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity11'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity12'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity13'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity14'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity15'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity16'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity17'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity18'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity19'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity20'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity21'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity22'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity23'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity24'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity25'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity26'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity27'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity28'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity29'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity30'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity31'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity32'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity33'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity34'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'Quantity35'
              Width = -1
              Visible = False
            end>
        end
      end
      object gsdbgrGoodPos: TgsDBGrid
        Left = 481
        Top = 4
        Width = 229
        Height = 129
        TabStop = False
        Align = alClient
        BorderStyle = bsNone
        Ctl3D = False
        DataSource = dsGoodPos
        Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
        ParentCtl3D = False
        PopupMenu = PopupMenu1
        RefreshType = rtNone
        TabOrder = 0
        OnCellClick = gsdbgrGoodPosCellClick
        OnColEnter = gsdbgrGoodPosColEnter
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        SaveSettings = False
        ShowTotals = False
        Columns = <
          item
            Expanded = False
            FieldName = 'MainQuantity'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DocRealPosKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'GoodKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'GoodName'
            Title.Caption = '������������ ���'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'CostNCU'
            Title.Caption = '���� � ���'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'QuantityBase'
            Title.Caption = '���-��'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'QuantityRest'
            Title.Caption = '�������'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity1'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity2'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity3'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity4'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity5'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity6'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity7'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity9'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity8'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity10'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity11'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity12'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity13'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity14'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity15'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity16'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity17'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity18'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity19'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity20'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity21'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity22'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity23'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity24'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity25'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity26'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity27'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity28'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity29'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity30'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity31'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity32'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity33'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity34'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity35'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'AmountNCU'
            Title.Caption = '����� � ���'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'ValueKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'TrTypeKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Weight'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'WeightKey'
            Width = -1
            Visible = False
          end>
      end
      object gsdbgrName: TgsDBGrid
        Left = 4
        Top = 4
        Width = 477
        Height = 129
        Align = alLeft
        BorderStyle = bsNone
        Ctl3D = False
        DataSource = dsGoodPos
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
        ParentCtl3D = False
        PopupMenu = PopupMenu1
        ReadOnly = True
        RefreshType = rtNone
        TabOrder = 1
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        SaveSettings = False
        ShowTotals = False
        Columns = <
          item
            Expanded = False
            FieldName = 'MainQuantity'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DocRealPosKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'GoodKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'GoodName'
            Title.Caption = '������������ ���'
            Width = 246
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CostNCU'
            Title.Caption = '���� � ���'
            Width = 65
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'QuantityBase'
            Title.Caption = '���-��'
            Width = 40
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'QuantityRest'
            Title.Caption = '�������'
            Width = 46
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Quantity1'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity2'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity3'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity4'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity5'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity6'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity7'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity9'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity8'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity10'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity11'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity12'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity13'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity14'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity15'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity16'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity17'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity18'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity19'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Quantity20'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'AmountNCU'
            Title.Caption = '����� � ���'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'ValueKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'TrTypeKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'Weight'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'WeightKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'NaturalLoss'
            Title.Caption = '���.�����'
            Width = 63
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'GroupKey'
            Width = -1
            Visible = False
          end>
      end
    end
    object Panel6: TPanel
      Left = 5
      Top = 106
      Width = 714
      Height = 98
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 1
      object gsdbgrContact: TgsDBGrid
        Left = 4
        Top = 4
        Width = 706
        Height = 90
        Align = alClient
        BorderStyle = bsNone
        Ctl3D = False
        DataSource = dsListContact
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
        ParentCtl3D = False
        RefreshType = rtNone
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ShowTotals = False
        Columns = <
          item
            Expanded = False
            FieldName = 'ContactKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'ContactName'
            Title.Caption = '�����������'
            Width = 364
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'DocumentKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DocumentNumber'
            Title.Caption = '����� ���������'
            Width = 124
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'FieldName'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'ContractKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'AmountBill'
            Title.Caption = '����� ���������'
            Width = 95
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ContractName'
            Title.Caption = '�������'
            Width = 124
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PriceKey'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'TypeCost'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'pricefield'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'contacttype'
            Width = -1
            Visible = False
          end>
      end
    end
  end
  object cdsListContact: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    AfterScroll = cdsListContactAfterScroll
    Left = 229
    Top = 176
  end
  object dsListContact: TDataSource
    DataSet = cdsListContact
    Left = 261
    Top = 168
  end
  object cdsGoodPos: TClientDataSet
    Aggregates = <>
    Params = <>
    BeforeInsert = cdsGoodPosBeforeInsert
    BeforePost = cdsGoodPosBeforePost
    Left = 229
    Top = 282
  end
  object dsGoodPos: TDataSource
    DataSet = cdsGoodPos
    Left = 261
    Top = 282
  end
  object ActionList1: TActionList
    Left = 197
    Top = 166
    object actNew: TAction
      Category = 'Contact'
      Caption = '��������'
      Enabled = False
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    object actReplace: TAction
      Category = 'Contact'
      Caption = '��������'
      Enabled = False
      OnExecute = actReplaceExecute
      OnUpdate = actReplaceUpdate
    end
    object actDelete: TAction
      Category = 'Contact'
      Caption = '�������'
      Enabled = False
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actOk: TAction
      Caption = 'OK'
      Enabled = False
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actNext: TAction
      Caption = '���������'
      Enabled = False
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actCancel: TAction
      Caption = '������'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = '�������'
    end
    object actMake: TAction
      Category = 'Contact'
      Caption = '������������'
      OnExecute = actMakeExecute
      OnUpdate = actMakeUpdate
    end
    object actCalcAmount: TAction
      Caption = '�������� �����'
      ShortCut = 32835
      OnExecute = actCalcAmountExecute
    end
    object actNaturalLoss: TAction
      Caption = '�������. �����'
      OnExecute = actNaturalLossExecute
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 325
    Top = 168
  end
  object ibsqlDocument: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'INSERT INTO gd_document '
      '      (id, documenttypekey, trtypekey, number, documentdate, '
      
        '       afull, achag, aview, companykey, creatorkey, creationdate' +
        ', editorkey,        editiondate, disabled, reserved) '
      'VALUES '
      
        '     (:id, :documenttypekey, :trtypekey, :number, :documentdate,' +
        '              :afull, :achag, :aview, :companykey, :creatorkey, ' +
        ':creationdate,              :editorkey, :editiondate,  :disabled' +
        ', :reserved) ')
    Transaction = IBTransaction
    Left = 309
    Top = 290
  end
  object ibsqlDocRealization: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'INSERT INTO gd_docrealization '
      
        '(documentkey, fromcontactkey, tocontactkey, fromdocumentkey, pri' +
        'cekey,  pricefield, transsumncu, transsumcurr, isrealization, ty' +
        'petransport) '
      
        'VALUES (:documentkey, :fromcontactkey, :tocontactkey, :fromdocum' +
        'entkey, :pricekey, :pricefield, :transsumncu, :transsumcurr, 1,'
      #39'C'#39')')
    Transaction = IBTransaction
    Left = 341
    Top = 290
  end
  object ibsqlDocRealPos: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    Left = 373
    Top = 290
  end
  object cdsAmount: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 229
    Top = 322
  end
  object dsAmount: TDataSource
    DataSet = cdsAmount
    Left = 261
    Top = 322
  end
  object PopupMenu1: TPopupMenu
    Left = 165
    Top = 282
    object N1: TMenuItem
      Action = actCalcAmount
    end
    object N2: TMenuItem
      Action = actNaturalLoss
    end
  end
  object FormPlaceSaver1: TFormPlaceSaver
    Left = 429
    Top = 290
  end
  object ibdsDocRealInfo: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DeleteSQL.Strings = (
      'delete from gd_docrealinfo'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into gd_docrealinfo'
      '  (DOCUMENTKEY, CARGORECEIVERKEY, CAR, CAROWNERKEY, DRIVER, '
      'LOADINGPOINT, '
      '   UNLOADINGPOINT, ROUTE, READDRESSING, HOOKED, WAYSHEETNUMBER, '
      'SURRENDERKEY, '
      '   RECEPTION, WARRANTNUMBER, WARRANTDATE, CONTRACTNUM, '
      'DATEPAYMENT, FORWARDERKEY, '
      '   TYPETRANSPORT)'
      'values'
      
        '  (:DOCUMENTKEY, :CARGORECEIVERKEY, :CAR, :CAROWNERKEY, :DRIVER,' +
        ' '
      ':LOADINGPOINT, '
      '   :UNLOADINGPOINT, :ROUTE, :READDRESSING, :HOOKED, '
      ':WAYSHEETNUMBER, :SURRENDERKEY, '
      '   :RECEPTION, :WARRANTNUMBER, :WARRANTDATE, :CONTRACTNUM, '
      ':DATEPAYMENT, '
      '   :FORWARDERKEY, :TYPETRANSPORT)')
    RefreshSQL.Strings = (
      'Select *'
      'from gd_docrealinfo '
      'where'
      '  DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT * FROM gd_docrealinfo WHERE documentkey = :dk')
    ModifySQL.Strings = (
      'update gd_docrealinfo'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  CARGORECEIVERKEY = :CARGORECEIVERKEY,'
      '  CAR = :CAR,'
      '  CAROWNERKEY = :CAROWNERKEY,'
      '  DRIVER = :DRIVER,'
      '  LOADINGPOINT = :LOADINGPOINT,'
      '  UNLOADINGPOINT = :UNLOADINGPOINT,'
      '  ROUTE = :ROUTE,'
      '  READDRESSING = :READDRESSING,'
      '  HOOKED = :HOOKED,'
      '  WAYSHEETNUMBER = :WAYSHEETNUMBER,'
      '  SURRENDERKEY = :SURRENDERKEY,'
      '  RECEPTION = :RECEPTION,'
      '  WARRANTNUMBER = :WARRANTNUMBER,'
      '  WARRANTDATE = :WARRANTDATE,'
      '  CONTRACTNUM = :CONTRACTNUM,'
      '  DATEPAYMENT = :DATEPAYMENT,'
      '  FORWARDERKEY = :FORWARDERKEY,'
      '  TYPETRANSPORT = :TYPETRANSPORT'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    ReadTransaction = IBTransaction
    Left = 341
    Top = 322
  end
  object xFoCal: TxFoCal
    Expression = '0'
    Left = 477
    Top = 293
    _variables_ = (
      'PI'
      3.14159265358979
      'E'
      2.71828182845905)
  end
  object ibsqlGroupInfo: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT gr.ID as GroupKey, gr.LB, gr.RB FROM'
      '  gd_good g JOIN gd_goodgroup gr ON g.GroupKey = gr.id and'
      '  g.ID = :ID')
    Transaction = IBTransaction
    Left = 373
    Top = 323
  end
  object dsDocReal: TDataSource
    DataSet = ibdsDocReal
    Left = 560
    Top = 320
  end
  object ibdsDocReal: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DeleteSQL.Strings = (
      'delete from GD_DOCUMENT'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_DOCUMENT'
      '  (ID, TRTYPEKEY, NUMBER, DOCUMENTDATE, CURRKEY)'
      'values'
      '  (:ID, :TRTYPEKEY, :NUMBER, :DOCUMENTDATE, :CURRKEY)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  DOCUMENTTYPEKEY,'
      '  TRTYPEKEY,'
      '  NUMBER,'
      '  DOCUMENTDATE,'
      '  DESCRIPTION,'
      '  SUMNCU,'
      '  SUMCURR,'
      '  SUMEQ,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  CURRKEY,'
      '  COMPANYKEY,'
      '  CREATORKEY,'
      '  CREATIONDATE,'
      '  EDITORKEY,'
      '  EDITIONDATE,'
      '  DISABLED,'
      '  RESERVED'
      'from GD_DOCUMENT '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      ''
      ''
      '')
    ModifySQL.Strings = (
      'update GD_DOCUMENT'
      'set'
      '  ID = :ID,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  NUMBER = :NUMBER,'
      '  DOCUMENTDATE = :DOCUMENTDATE,'
      '  CURRKEY = :CURRKEY'
      'where'
      '  ID = :OLD_ID')
    ReadTransaction = IBTransaction
    Left = 520
    Top = 328
  end
  object ibdsRealPos: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DeleteSQL.Strings = (
      'delete from GD_DOCREALPOS'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_DOCREALPOS'
      '  (ID, DOCUMENTKEY, GOODKEY, TRTYPEKEY, QUANTITY, MAINQUANTITY, '
      'AMOUNTNCU, '
      '   AMOUNTCURR, AMOUNTEQ, VALUEKEY, WEIGHTKEY, WEIGHT, PACKKEY, '
      'PACKINQUANT, '
      '   PACKQUANTITY, RESERVED)'
      'values'
      
        '  (:ID, :DOCUMENTKEY, :GOODKEY, :TRTYPEKEY, :QUANTITY, :MAINQUAN' +
        'TITY, '
      ':AMOUNTNCU, '
      '   :AMOUNTCURR, :AMOUNTEQ, :VALUEKEY, :WEIGHTKEY, :WEIGHT, '
      ':PACKKEY, :PACKINQUANT, '
      '   :PACKQUANTITY, :RESERVED)')
    ModifySQL.Strings = (
      'update GD_DOCREALPOS'
      'set'
      '  ID = :ID,'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  GOODKEY = :GOODKEY,'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  QUANTITY = :QUANTITY,'
      '  MAINQUANTITY = :MAINQUANTITY,'
      '  AMOUNTNCU = :AMOUNTNCU,'
      '  AMOUNTCURR = :AMOUNTCURR,'
      '  AMOUNTEQ = :AMOUNTEQ,'
      '  VALUEKEY = :VALUEKEY,'
      '  WEIGHTKEY = :WEIGHTKEY,'
      '  WEIGHT = :WEIGHT,'
      '  PACKKEY = :PACKKEY,'
      '  PACKINQUANT = :PACKINQUANT,'
      '  PACKQUANTITY = :PACKQUANTITY,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    DataSource = dsDocReal
    ReadTransaction = IBTransaction
    Left = 520
    Top = 296
  end
  object dsRealPos: TDataSource
    DataSet = ibdsRealPos
    Left = 597
    Top = 323
  end
end
