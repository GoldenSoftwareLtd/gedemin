object dlgDetailBill: TdlgDetailBill
  Left = 221
  Top = 103
  Width = 740
  Height = 539
  Caption = 'Отчет экспедитора'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
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
    Width = 732
    Height = 55
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 14
      Width = 100
      Height = 13
      Caption = 'Базовая накладная'
    end
    object Label2: TLabel
      Left = 248
      Top = 14
      Width = 80
      Height = 13
      Caption = 'Дополнительно'
    end
    object Label4: TLabel
      Left = 14
      Top = 34
      Width = 665
      Height = 13
      Caption = 
        'Внимание: накладные по отчету привязаны к базовой накладной, из ' +
        'дополнительно - наименование и кол-во '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
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
      Hint = 'Вводятся номера дополнительных накладных через ,'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 470
    Width = 732
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Panel7: TPanel
      Left = 452
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
    Width = 732
    Height = 415
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object Panel4: TPanel
      Left = 5
      Top = 5
      Width = 722
      Height = 101
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      object lblContact: TLabel
        Left = 10
        Top = 9
        Width = 144
        Height = 13
        Caption = 'Наименование организации'
        Enabled = False
      end
      object lblNumberBill: TLabel
        Left = 10
        Top = 32
        Width = 91
        Height = 13
        Caption = 'Номер накладной'
        Enabled = False
      end
      object lPrice: TLabel
        Left = 10
        Top = 55
        Width = 58
        Height = 13
        Caption = 'Прайс-лист'
        Enabled = False
      end
      object lPriceField: TLabel
        Left = 472
        Top = 55
        Width = 65
        Height = 13
        Caption = 'Поле прайса'
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
        Caption = 'Осуществлять контроль количества'
        TabOrder = 5
      end
      object rgCostType: TRadioGroup
        Left = 471
        Top = 1
        Width = 199
        Height = 47
        Caption = 'Тип цены'
        Enabled = False
        ItemIndex = 0
        Items.Strings = (
          'Из накладной'
          'По прайс-листу')
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
      Width = 722
      Height = 206
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 4
      Caption = 'Panel5'
      TabOrder = 2
      object Panel8: TPanel
        Left = 4
        Top = 144
        Width = 714
        Height = 58
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object gsdbgrAmount: TgsDBGrid
          Left = 481
          Top = 0
          Width = 233
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
              Title.Caption = 'Наименование ТМЦ'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'QuantityBase'
              Title.Caption = 'Кол-во'
              Width = -1
              Visible = False
            end
            item
              Expanded = False
              FieldName = 'QuantityRest'
              Title.Caption = 'Остаток'
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
              Title.Caption = 'Наименование ТМЦ'
              Width = 378
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'QuantityBase'
              Title.Caption = 'Кол-во'
              Width = 40
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'QuantityRest'
              Title.Caption = 'Остаток'
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
        Width = 237
        Height = 140
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
            Title.Caption = 'Наименование ТМЦ'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'CostNCU'
            Title.Caption = 'Цена в НДЕ'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'QuantityBase'
            Title.Caption = 'Кол-во'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'QuantityRest'
            Title.Caption = 'Остаток'
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
            Title.Caption = 'Сумма в НДЕ'
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
        Height = 140
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
            Title.Caption = 'Наименование ТМЦ'
            Width = 246
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CostNCU'
            Title.Caption = 'Цена в НДЕ'
            Width = 65
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'QuantityBase'
            Title.Caption = 'Кол-во'
            Width = 40
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'QuantityRest'
            Title.Caption = 'Остаток'
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
            Title.Caption = 'Сумма в НДЕ'
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
            Title.Caption = 'Ест.убыль'
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
      Width = 722
      Height = 98
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 1
      object gsdbgrContact: TgsDBGrid
        Left = 4
        Top = 4
        Width = 714
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
            Title.Caption = 'Организация'
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
            Title.Caption = 'Номер накладной'
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
            Title.Caption = 'Сумма накладной'
            Width = 95
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ContractName'
            Title.Caption = 'Договор'
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
    object cdsListContactContactKey: TIntegerField
      FieldName = 'ContactKey'
      Visible = False
    end
    object cdsListContactContactName: TStringField
      DisplayLabel = 'Организация'
      FieldName = 'ContactName'
      Size = 60
    end
    object cdsListContactDocumentKey: TIntegerField
      FieldName = 'DocumentKey'
      Visible = False
    end
    object cdsListContactDocumentNumber: TStringField
      DisplayLabel = 'Номер накладной'
      FieldName = 'DocumentNumber'
    end
    object cdsListContactFieldName: TStringField
      FieldName = 'FieldName'
      Visible = False
      Size = 31
    end
    object cdsListContactContractKey: TIntegerField
      FieldName = 'ContractKey'
      Visible = False
    end
    object cdsListContactContractName: TStringField
      DisplayLabel = 'Договор'
      DisplayWidth = 20
      FieldName = 'ContractName'
      Visible = False
      Size = 40
    end
    object cdsListContactPriceKey: TIntegerField
      FieldName = 'PriceKey'
    end
    object cdsListContactTypeCost: TIntegerField
      FieldName = 'TypeCost'
    end
    object cdsListContactpricefield: TStringField
      FieldName = 'pricefield'
      Visible = False
      Size = 31
    end
    object cdsListContactcontacttype: TIntegerField
      FieldName = 'contacttype'
      Visible = False
    end
    object cdsListContactAmountBill: TIBBCDField
      DisplayLabel = 'Сумма накладной'
      FieldName = 'AmountBill'
    end
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
    object cdsGoodPosMainQuantity: TIBBCDField
      FieldName = 'MainQuantity'
      Visible = False
    end
    object cdsGoodPosDocRealPosKey: TIntegerField
      FieldName = 'DocRealPosKey'
      Visible = False
    end
    object cdsGoodPosGoodKey: TIntegerField
      FieldName = 'GoodKey'
      Visible = False
    end
    object cdsGoodPosGoodName: TStringField
      DisplayLabel = 'Наименование ТМЦ'
      DisplayWidth = 50
      FieldName = 'GoodName'
      Size = 60
    end
    object cdsGoodPosQuantityBase: TIBBCDField
      DisplayLabel = 'Кол-во'
      DisplayWidth = 5
      FieldName = 'QuantityBase'
    end
    object cdsGoodPosQuantityRest: TIBBCDField
      DisplayLabel = 'Остаток'
      DisplayWidth = 6
      FieldName = 'QuantityRest'
    end
    object cdsGoodPosQuantity1: TIBBCDField
      FieldName = 'Quantity1'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity2: TIBBCDField
      FieldName = 'Quantity2'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity3: TIBBCDField
      FieldName = 'Quantity3'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity4: TIBBCDField
      FieldName = 'Quantity4'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity5: TIBBCDField
      FieldName = 'Quantity5'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity6: TIBBCDField
      FieldName = 'Quantity6'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity7: TIBBCDField
      FieldName = 'Quantity7'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity9: TIBBCDField
      FieldName = 'Quantity9'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity8: TIBBCDField
      FieldName = 'Quantity8'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity10: TIBBCDField
      FieldName = 'Quantity10'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity11: TIBBCDField
      FieldName = 'Quantity11'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity12: TIBBCDField
      FieldName = 'Quantity12'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity13: TIBBCDField
      FieldName = 'Quantity13'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity14: TIBBCDField
      FieldName = 'Quantity14'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity15: TIBBCDField
      FieldName = 'Quantity15'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity16: TIBBCDField
      FieldName = 'Quantity16'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity17: TIBBCDField
      FieldName = 'Quantity17'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity18: TIBBCDField
      FieldName = 'Quantity18'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity19: TIBBCDField
      FieldName = 'Quantity19'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity20: TIBBCDField
      FieldName = 'Quantity20'
      Visible = False
      OnValidate = cdsGoodPosQuantity1Validate
    end
    object cdsGoodPosQuantity21: TIBBCDField
      FieldName = 'Quantity21'
      Visible = False
    end
    object cdsGoodPosQuantity22: TIBBCDField
      FieldName = 'Quantity22'
      Visible = False
    end
    object cdsGoodPosQuantity23: TIBBCDField
      FieldName = 'Quantity23'
      Visible = False
    end
    object cdsGoodPosQuantity24: TIBBCDField
      FieldName = 'Quantity24'
      Visible = False
    end
    object cdsGoodPosQuantity25: TIBBCDField
      FieldName = 'Quantity25'
      Visible = False
    end
    object cdsGoodPosQuantity26: TIBBCDField
      FieldName = 'Quantity26'
      Visible = False
    end
    object cdsGoodPosQuantity27: TIBBCDField
      FieldName = 'Quantity27'
      Visible = False
    end
    object cdsGoodPosQuantity28: TIBBCDField
      FieldName = 'Quantity28'
      Visible = False
    end
    object cdsGoodPosQuantity29: TIBBCDField
      FieldName = 'Quantity29'
      Visible = False
    end
    object cdsGoodPosQuantity30: TIBBCDField
      FieldName = 'Quantity30'
      Visible = False
    end
    object cdsGoodPosQuantity31: TIBBCDField
      FieldName = 'Quantity31'
      Visible = False
    end
    object cdsGoodPosQuantity32: TIBBCDField
      FieldName = 'Quantity32'
      Visible = False
    end
    object cdsGoodPosQuantity33: TIBBCDField
      FieldName = 'Quantity33'
      Visible = False
    end
    object cdsGoodPosQuantity34: TIBBCDField
      FieldName = 'Quantity34'
      Visible = False
    end
    object cdsGoodPosQuantity35: TIBBCDField
      FieldName = 'Quantity35'
      Visible = False
    end
    object cdsGoodPosAmountNCU: TCurrencyField
      DisplayLabel = 'Сумма в НДЕ'
      FieldName = 'AmountNCU'
    end
    object cdsGoodPosCostNCU: TCurrencyField
      DisplayLabel = 'Цена в НДЕ'
      FieldName = 'CostNCU'
    end
    object cdsGoodPosValueKey: TIntegerField
      FieldName = 'ValueKey'
      Visible = False
    end
    object cdsGoodPosTrTypeKey: TIntegerField
      FieldName = 'TrTypeKey'
      Visible = False
    end
    object cdsGoodPosWeight: TIBBCDField
      FieldName = 'Weight'
      Visible = False
    end
    object cdsGoodPosWeightKey: TIntegerField
      FieldName = 'WeightKey'
      Visible = False
    end
    object cdsGoodPosCostNCU1: TIBBCDField
      FieldName = 'CostNCU1'
      Visible = False
    end
    object cdsGoodPosCostNCU2: TIBBCDField
      FieldName = 'CostNCU2'
      Visible = False
    end
    object cdsGoodPosCostNCU3: TIBBCDField
      FieldName = 'CostNCU3'
      Visible = False
    end
    object cdsGoodPosCostNCU4: TIBBCDField
      FieldName = 'CostNCU4'
      Visible = False
    end
    object cdsGoodPosCostNCU5: TIBBCDField
      FieldName = 'CostNCU5'
      Visible = False
    end
    object cdsGoodPosCostNCU6: TIBBCDField
      FieldName = 'CostNCU6'
      Visible = False
    end
    object cdsGoodPosCostNCU7: TIBBCDField
      FieldName = 'CostNCU7'
      Visible = False
    end
    object cdsGoodPosCostNCU8: TIBBCDField
      FieldName = 'CostNCU8'
      Visible = False
    end
    object cdsGoodPosCostNCU9: TIBBCDField
      FieldName = 'CostNCU9'
      Visible = False
    end
    object cdsGoodPosCostNCU10: TIBBCDField
      FieldName = 'CostNCU10'
      Visible = False
    end
    object cdsGoodPosCostNCU11: TIBBCDField
      FieldName = 'CostNCU11'
      Visible = False
    end
    object cdsGoodPosCostNCU12: TIBBCDField
      FieldName = 'CostNCU12'
      Visible = False
    end
    object cdsGoodPosCostNCU13: TIBBCDField
      FieldName = 'CostNCU13'
      Visible = False
    end
    object cdsGoodPosCostNCU14: TIBBCDField
      FieldName = 'CostNCU14'
      Visible = False
    end
    object cdsGoodPosCostNCU15: TIBBCDField
      FieldName = 'CostNCU15'
      Visible = False
    end
    object cdsGoodPosCostNCU16: TIBBCDField
      FieldName = 'CostNCU16'
      Visible = False
    end
    object cdsGoodPosCostNCU17: TIBBCDField
      FieldName = 'CostNCU17'
      Visible = False
    end
    object cdsGoodPosCostNCU18: TIBBCDField
      FieldName = 'CostNCU18'
      Visible = False
    end
    object cdsGoodPosCostNCU19: TIBBCDField
      FieldName = 'CostNCU19'
      Visible = False
    end
    object cdsGoodPosCostNCU20: TIBBCDField
      FieldName = 'CostNCU20'
      Visible = False
    end
    object cdsGoodPosCostNCU21: TIBBCDField
      FieldName = 'CostNCU21'
      Visible = False
    end
    object cdsGoodPosCostNCU22: TIBBCDField
      FieldName = 'CostNCU22'
      Visible = False
    end
    object cdsGoodPosCostNCU23: TIBBCDField
      FieldName = 'CostNCU23'
      Visible = False
    end
    object cdsGoodPosCostNCU24: TIBBCDField
      FieldName = 'CostNCU24'
      Visible = False
    end
    object cdsGoodPosCostNCU25: TIBBCDField
      FieldName = 'CostNCU25'
      Visible = False
    end
    object cdsGoodPosCostNCU26: TIBBCDField
      FieldName = 'CostNCU26'
      Visible = False
    end
    object cdsGoodPosCostNCU27: TIBBCDField
      FieldName = 'CostNCU27'
      Visible = False
    end
    object cdsGoodPosCostNCU28: TIBBCDField
      FieldName = 'CostNCU28'
      Visible = False
    end
    object cdsGoodPosCostNCU29: TIBBCDField
      FieldName = 'CostNCU29'
      Visible = False
    end
    object cdsGoodPosCostNCU30: TIBBCDField
      FieldName = 'CostNCU30'
      Visible = False
    end
    object cdsGoodPosCostNCU32: TIBBCDField
      FieldName = 'CostNCU32'
      Visible = False
    end
    object cdsGoodPosCostNCU31: TIBBCDField
      FieldName = 'CostNCU31'
      Visible = False
    end
    object cdsGoodPosCostNCU34: TIBBCDField
      FieldName = 'CostNCU34'
      Visible = False
    end
    object cdsGoodPosCostNCU33: TIBBCDField
      FieldName = 'CostNCU33'
      Visible = False
    end
    object cdsGoodPosCostNCU35: TIBBCDField
      FieldName = 'CostNCU35'
      Visible = False
    end
    object cdsGoodPosNaturalLoss: TIBBCDField
      DisplayLabel = 'Ест.убыль'
      FieldName = 'NaturalLoss'
      Visible = False
    end
    object cdsGoodPosGroupKey: TIntegerField
      FieldName = 'GroupKey'
      Visible = False
    end
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
      Caption = 'Добавить'
      Enabled = False
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    object actReplace: TAction
      Category = 'Contact'
      Caption = 'Изменить'
      Enabled = False
      OnExecute = actReplaceExecute
      OnUpdate = actReplaceUpdate
    end
    object actDelete: TAction
      Category = 'Contact'
      Caption = 'Удалить'
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
      Caption = 'Следующий'
      Enabled = False
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
    end
    object actMake: TAction
      Category = 'Contact'
      Caption = 'Сформировать'
      OnExecute = actMakeExecute
      OnUpdate = actMakeUpdate
    end
    object actCalcAmount: TAction
      Caption = 'Показать итого'
      ShortCut = 32835
      OnExecute = actCalcAmountExecute
    end
    object actNaturalLoss: TAction
      Caption = 'Естеств. убыль'
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
    object IntegerField1: TIntegerField
      FieldName = 'DocRealPosKey'
      Visible = False
    end
    object IntegerField2: TIntegerField
      FieldName = 'GoodKey'
      Visible = False
    end
    object StringField1: TStringField
      DisplayLabel = 'Наименование ТМЦ'
      DisplayWidth = 70
      FieldName = 'GoodName'
      Size = 60
    end
    object IBBCDField1: TIBBCDField
      DisplayLabel = 'Кол-во'
      DisplayWidth = 5
      FieldName = 'QuantityBase'
    end
    object IBBCDField2: TIBBCDField
      DisplayLabel = 'Остаток'
      DisplayWidth = 6
      FieldName = 'QuantityRest'
    end
    object IBBCDField3: TIBBCDField
      FieldName = 'Quantity1'
      Visible = False
    end
    object IBBCDField4: TIBBCDField
      FieldName = 'Quantity2'
      Visible = False
    end
    object IBBCDField5: TIBBCDField
      FieldName = 'Quantity3'
      Visible = False
    end
    object IBBCDField6: TIBBCDField
      FieldName = 'Quantity4'
      Visible = False
    end
    object IBBCDField7: TIBBCDField
      FieldName = 'Quantity5'
      Visible = False
    end
    object IBBCDField8: TIBBCDField
      FieldName = 'Quantity6'
      Visible = False
    end
    object IBBCDField9: TIBBCDField
      FieldName = 'Quantity7'
      Visible = False
    end
    object IBBCDField10: TIBBCDField
      FieldName = 'Quantity8'
      Visible = False
    end
    object IBBCDField11: TIBBCDField
      FieldName = 'Quantity9'
      Visible = False
    end
    object IBBCDField12: TIBBCDField
      FieldName = 'Quantity10'
      Visible = False
    end
    object IBBCDField13: TIBBCDField
      FieldName = 'Quantity11'
      Visible = False
    end
    object IBBCDField14: TIBBCDField
      FieldName = 'Quantity12'
      Visible = False
    end
    object IBBCDField15: TIBBCDField
      FieldName = 'Quantity13'
      Visible = False
    end
    object IBBCDField16: TIBBCDField
      FieldName = 'Quantity14'
      Visible = False
    end
    object IBBCDField17: TIBBCDField
      FieldName = 'Quantity15'
      Visible = False
    end
    object IBBCDField18: TIBBCDField
      FieldName = 'Quantity16'
      Visible = False
    end
    object IBBCDField19: TIBBCDField
      FieldName = 'Quantity17'
      Visible = False
    end
    object IBBCDField20: TIBBCDField
      FieldName = 'Quantity18'
      Visible = False
    end
    object IBBCDField21: TIBBCDField
      FieldName = 'Quantity19'
      Visible = False
    end
    object IBBCDField22: TIBBCDField
      FieldName = 'Quantity20'
      Visible = False
    end
    object cdsAmountQuantity21: TIBBCDField
      FieldName = 'Quantity21'
      Visible = False
    end
    object cdsAmountQuantity22: TIBBCDField
      FieldName = 'Quantity22'
      Visible = False
    end
    object cdsAmountQuantity23: TIBBCDField
      FieldName = 'Quantity23'
      Visible = False
    end
    object cdsAmountQuantity24: TIBBCDField
      FieldName = 'Quantity24'
      Visible = False
    end
    object cdsAmountQuantity25: TIBBCDField
      FieldName = 'Quantity25'
      Visible = False
    end
    object cdsAmountQuantity26: TIBBCDField
      FieldName = 'Quantity26'
      Visible = False
    end
    object cdsAmountQuantity27: TIBBCDField
      FieldName = 'Quantity27'
      Visible = False
    end
    object cdsAmountQuantity28: TIBBCDField
      FieldName = 'Quantity28'
      Visible = False
    end
    object cdsAmountQuantity29: TIBBCDField
      FieldName = 'Quantity29'
      Visible = False
    end
    object cdsAmountQuantity30: TIBBCDField
      FieldName = 'Quantity30'
      Visible = False
    end
    object cdsAmountQuantity31: TIBBCDField
      FieldName = 'Quantity31'
      Visible = False
    end
    object cdsAmountQuantity32: TIBBCDField
      FieldName = 'Quantity32'
      Visible = False
    end
    object cdsAmountQuantity33: TIBBCDField
      FieldName = 'Quantity33'
      Visible = False
    end
    object cdsAmountQuantity34: TIBBCDField
      FieldName = 'Quantity34'
      Visible = False
    end
    object cdsAmountQuantity35: TIBBCDField
      FieldName = 'Quantity35'
      Visible = False
    end
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
    BufferChunks = 100
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
    BufferChunks = 100
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
    BufferChunks = 100
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
