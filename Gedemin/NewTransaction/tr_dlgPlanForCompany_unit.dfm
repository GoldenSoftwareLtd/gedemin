object dlgPlanForCompany: TdlgPlanForCompany
  Left = 244
  Top = 103
  Width = 696
  Height = 480
  Caption = 'Установка плана счетов для рабочих организаций'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 121
    Width = 688
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 688
    Height = 121
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object Label1: TLabel
      Left = 5
      Top = 5
      Width = 678
      Height = 13
      Align = alTop
      Caption = 'Список рабочих организаций'
    end
    object gsibgrOurCompany: TgsIBGrid
      Left = 5
      Top = 18
      Width = 678
      Height = 98
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsOurCompany
      TabOrder = 0
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.Visible = False
      MinColWidth = 40
      Columns = <
        item
          Alignment = taLeftJustify
          Expanded = False
          FieldName = 'FULLNAME'
          Title.Caption = 'Наименование организации'
          Width = 1084
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'COMPANYKEY'
          Title.Caption = 'COMPANYKEY'
          Width = -1
          Visible = False
        end>
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 416
    Width = 688
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object bHelp: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Action = actHelp
      TabOrder = 0
    end
    object Panel8: TPanel
      Left = 519
      Top = 0
      Width = 169
      Height = 37
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object bOk: TButton
        Left = 5
        Top = 8
        Width = 75
        Height = 25
        Action = actOk
        Default = True
        TabOrder = 0
      end
      object bCancel: TButton
        Left = 88
        Top = 8
        Width = 75
        Height = 25
        Action = actCancel
        TabOrder = 1
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 124
    Width = 688
    Height = 292
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 265
      Top = 0
      Width = 3
      Height = 292
      Cursor = crHSplit
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 265
      Height = 292
      Align = alLeft
      BevelInner = bvLowered
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      object Label2: TLabel
        Left = 5
        Top = 5
        Width = 255
        Height = 13
        Align = alTop
        Caption = 'Список доступных планов счетов'
      end
      object gsibgrListCard: TgsIBGrid
        Left = 5
        Top = 18
        Width = 255
        Height = 269
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsListCard
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        MinColWidth = 40
        Columns = <
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ID'
            Title.Caption = 'ID'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'PARENT'
            Title.Caption = 'PARENT'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'LB'
            Title.Caption = 'LB'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'RB'
            Title.Caption = 'RB'
            Width = -1
            Visible = False
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'ALIAS'
            Title.Caption = 'Наименование'
            Width = 124
            Visible = True
          end
          item
            Alignment = taLeftJustify
            Expanded = False
            FieldName = 'NAME'
            Title.Caption = 'Расшифровка'
            Width = 364
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'TYPEACCOUNT'
            Title.Caption = 'TYPEACCOUNT'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'GRADE'
            Title.Caption = 'GRADE'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ACTIVECARD'
            Title.Caption = 'ACTIVECARD'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'MULTYCURR'
            Title.Caption = 'MULTYCURR'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'OFFBALANCE'
            Title.Caption = 'OFFBALANCE'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'MAINANALYZE'
            Title.Caption = 'MAINANALYZE'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'DISABLED'
            Title.Caption = 'DISABLED'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'AFULL'
            Title.Caption = 'AFULL'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ACHAG'
            Title.Caption = 'ACHAG'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'AVIEW'
            Title.Caption = 'AVIEW'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'RESERVED'
            Title.Caption = 'RESERVED'
            Width = -1
            Visible = False
          end>
      end
    end
    object Panel5: TPanel
      Left = 268
      Top = 0
      Width = 420
      Height = 292
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 73
        Height = 292
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object Button1: TButton
          Left = 8
          Top = 22
          Width = 59
          Height = 25
          Action = actAddOne
          TabOrder = 0
        end
        object Button2: TButton
          Left = 8
          Top = 50
          Width = 59
          Height = 25
          Action = actAddAll
          TabOrder = 1
        end
        object Button3: TButton
          Left = 8
          Top = 89
          Width = 59
          Height = 25
          Action = actDelOne
          TabOrder = 2
        end
        object Button4: TButton
          Left = 8
          Top = 117
          Width = 59
          Height = 25
          Action = actDelAll
          TabOrder = 3
        end
      end
      object Panel7: TPanel
        Left = 73
        Top = 0
        Width = 347
        Height = 292
        Align = alClient
        BevelInner = bvLowered
        BevelOuter = bvNone
        BorderWidth = 4
        TabOrder = 1
        object Label3: TLabel
          Left = 5
          Top = 5
          Width = 337
          Height = 13
          Align = alTop
          Caption = 'Список планов счетов для текущей организации'
        end
        object gsibCardCompany: TgsIBGrid
          Left = 5
          Top = 18
          Width = 337
          Height = 269
          Align = alClient
          BorderStyle = bsNone
          DataSource = dsCardCompany
          TabOrder = 0
          OnDblClick = gsibCardCompanyDblClick
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          MinColWidth = 40
          Columns = <
            item
              Alignment = taRightJustify
              Expanded = False
              FieldName = 'ACTIVECARD'
              Title.Caption = 'Активный'
              Width = 54
              Visible = True
            end
            item
              Alignment = taLeftJustify
              Expanded = False
              FieldName = 'ALIAS'
              Title.Caption = 'Наименование'
              Width = 80
              Visible = True
            end
            item
              Alignment = taLeftJustify
              Expanded = False
              FieldName = 'NAME'
              Title.Caption = 'Описание'
              Width = 1084
              Visible = True
            end
            item
              Alignment = taRightJustify
              Expanded = False
              FieldName = 'CARDACCOUNTKEY'
              Title.Caption = 'CARDACCOUNTKEY'
              Width = -1
              Visible = False
            end
            item
              Alignment = taRightJustify
              Expanded = False
              FieldName = 'OURCOMPANYKEY'
              Title.Caption = 'OURCOMPANYKEY'
              Width = -1
              Visible = False
            end>
        end
      end
    end
  end
  object ibdsOurCompany: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    AfterScroll = ibdsOurCompanyAfterScroll
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT'
      '  c.FullName, '
      '  o.CompanyKey'
      'FROM'
      '  gd_ourcompany o JOIN gd_company c ON'
      '     o.companykey = c.contactkey'
      'ORDER BY c.FullName')
    Left = 224
    Top = 64
    object ibdsOurCompanyFULLNAME: TIBStringField
      DisplayLabel = 'Наименование организации'
      FieldName = 'FULLNAME'
      Size = 180
    end
    object ibdsOurCompanyCOMPANYKEY: TIntegerField
      FieldName = 'COMPANYKEY'
      Required = True
      Visible = False
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 264
    Top = 64
  end
  object dsOurCompany: TDataSource
    DataSet = ibdsOurCompany
    Left = 192
    Top = 64
  end
  object ibdsListCard: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT * FROM '
      '  gd_cardaccount'
      'WHERE '
      '  grade = 0 and'
      '  not (id IN '
      '  (SELECT cardaccountkey FROM gd_cardcompany WHERE '
      '   ourcompanykey = :oc))'
      'ORDER BY alias')
    Left = 204
    Top = 212
    object ibdsListCardID: TIntegerField
      FieldName = 'ID'
      Required = True
    end
    object ibdsListCardPARENT: TIntegerField
      FieldName = 'PARENT'
    end
    object ibdsListCardLB: TIntegerField
      FieldName = 'LB'
      Required = True
    end
    object ibdsListCardRB: TIntegerField
      FieldName = 'RB'
      Required = True
    end
    object ibdsListCardALIAS: TIBStringField
      DisplayLabel = 'Наименование'
      FieldName = 'ALIAS'
    end
    object ibdsListCardNAME: TIBStringField
      DisplayLabel = 'Расшифровка'
      DisplayWidth = 60
      FieldName = 'NAME'
      Size = 180
    end
    object ibdsListCardTYPEACCOUNT: TIntegerField
      FieldName = 'TYPEACCOUNT'
    end
    object ibdsListCardGRADE: TIntegerField
      FieldName = 'GRADE'
    end
    object ibdsListCardACTIVECARD: TSmallintField
      FieldName = 'ACTIVECARD'
    end
    object ibdsListCardMULTYCURR: TSmallintField
      FieldName = 'MULTYCURR'
    end
    object ibdsListCardOFFBALANCE: TSmallintField
      FieldName = 'OFFBALANCE'
    end
    object ibdsListCardMAINANALYZE: TIntegerField
      FieldName = 'MAINANALYZE'
    end
    object ibdsListCardDISABLED: TSmallintField
      FieldName = 'DISABLED'
    end
    object ibdsListCardAFULL: TIntegerField
      FieldName = 'AFULL'
      Required = True
    end
    object ibdsListCardACHAG: TIntegerField
      FieldName = 'ACHAG'
      Required = True
    end
    object ibdsListCardAVIEW: TIntegerField
      FieldName = 'AVIEW'
      Required = True
    end
    object ibdsListCardRESERVED: TIntegerField
      FieldName = 'RESERVED'
    end
  end
  object dsListCard: TDataSource
    DataSet = ibdsListCard
    Left = 176
    Top = 212
  end
  object ibdsCardCompany: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_cardcompany'
      'where'
      '  CARDACCOUNTKEY = :OLD_CARDACCOUNTKEY and'
      '  OURCOMPANYKEY = :OLD_OURCOMPANYKEY')
    InsertSQL.Strings = (
      'insert into gd_cardcompany'
      '  (CARDACCOUNTKEY, OURCOMPANYKEY, ACTIVECARD)'
      'values'
      '  (:CARDACCOUNTKEY, :OURCOMPANYKEY, :ACTIVECARD)')
    RefreshSQL.Strings = (
      'SELECT   '
      '   a.Alias,'
      '   a.Name,'
      '   c.*'
      'FROM'
      '  gd_cardcompany c JOIN gd_cardaccount a '
      '     ON  c.cardaccountkey = a.id'
      'where'
      '  CARDACCOUNTKEY = :CARDACCOUNTKEY and'
      '  OURCOMPANYKEY = :OURCOMPANYKEY')
    SelectSQL.Strings = (
      'SELECT   '
      '   a.Alias,'
      '   a.Name,'
      '   c.*'
      'FROM'
      '  gd_cardcompany c JOIN gd_cardaccount a '
      '     ON  c.cardaccountkey = a.id and c.ourcompanykey = :ock'
      'ORDER BY '
      '   c.ActiveCard DESC, a.Alias ASC'
      '    ')
    ModifySQL.Strings = (
      'update gd_cardcompany'
      'set'
      '  CARDACCOUNTKEY = :CARDACCOUNTKEY,'
      '  OURCOMPANYKEY = :OURCOMPANYKEY,'
      '  ACTIVECARD = :ACTIVECARD'
      'where'
      '  CARDACCOUNTKEY = :OLD_CARDACCOUNTKEY and'
      '  OURCOMPANYKEY = :OLD_OURCOMPANYKEY')
    Left = 416
    Top = 188
    object ibdsCardCompanyACTIVECARD: TSmallintField
      DisplayLabel = 'Активный'
      DisplayWidth = 8
      FieldName = 'ACTIVECARD'
      Visible = False
      OnGetText = ibdsCardCompanyACTIVECARDGetText
    end
    object ibdsCardCompanyALIAS: TIBStringField
      DisplayLabel = 'Наименование'
      DisplayWidth = 10
      FieldName = 'ALIAS'
    end
    object ibdsCardCompanyNAME: TIBStringField
      DisplayLabel = 'Описание'
      FieldName = 'NAME'
      Size = 180
    end
    object ibdsCardCompanyCARDACCOUNTKEY: TIntegerField
      FieldName = 'CARDACCOUNTKEY'
      Required = True
      Visible = False
    end
    object ibdsCardCompanyOURCOMPANYKEY: TIntegerField
      FieldName = 'OURCOMPANYKEY'
      Required = True
    end
  end
  object dsCardCompany: TDataSource
    DataSet = ibdsCardCompany
    Left = 389
    Top = 188
  end
  object ActionList1: TActionList
    Left = 485
    Top = 292
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
    end
    object actAddOne: TAction
      Category = 'Card'
      Caption = '>'
      OnExecute = actAddOneExecute
      OnUpdate = actAddOneUpdate
    end
    object actAddAll: TAction
      Category = 'Card'
      Caption = '>>'
      OnExecute = actAddAllExecute
      OnUpdate = actAddOneUpdate
    end
    object actDelOne: TAction
      Category = 'Card'
      Caption = '<'
      OnExecute = actDelOneExecute
      OnUpdate = actDelOneUpdate
    end
    object actDelAll: TAction
      Category = 'Card'
      Caption = '<<'
      OnExecute = actDelAllExecute
    end
  end
  object ibsqlAddToOurCompany: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      
        'INSERT INTO gd_cardcompany (cardaccountkey, ourcompanykey, activ' +
        'ecard) VALUES (:cak, :ck, :ac)')
    Transaction = IBTransaction
    Left = 421
    Top = 228
  end
end
