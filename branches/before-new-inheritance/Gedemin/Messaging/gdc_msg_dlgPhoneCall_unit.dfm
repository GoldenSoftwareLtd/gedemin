inherited gdc_msg_dlgPhoneCall: Tgdc_msg_dlgPhoneCall
  Left = 327
  Top = 176
  Caption = 'Телефонный звонок'
  ClientHeight = 345
  ClientWidth = 497
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 421
    Top = 89
    Anchors = [akTop, akRight]
  end
  inherited btnNew: TButton
    Left = 421
    Top = 113
    Anchors = [akTop, akRight]
  end
  inherited btnOK: TButton
    Left = 421
    Top = 25
    Anchors = [akTop, akRight]
  end
  inherited btnCancel: TButton
    Left = 421
    Top = 49
    Anchors = [akTop, akRight]
  end
  inherited btnHelp: TButton
    Left = 421
    Top = 153
    Anchors = [akTop, akRight]
  end
  inherited pgcMain: TPageControl
    Left = 5
    Width = 407
    Height = 331
    Anchors = [akLeft, akTop, akRight, akBottom]
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 4
        Width = 40
        Caption = 'Ид-тор:'
      end
      inherited dbtxtID: TDBText
        Left = 54
      end
      object Label1: TLabel
        Left = 4
        Top = 31
        Width = 44
        Height = 13
        Caption = 'От кого:'
      end
      object Label2: TLabel
        Left = 4
        Top = 78
        Width = 28
        Height = 13
        Caption = 'Тема:'
      end
      object Label3: TLabel
        Left = 4
        Top = 101
        Width = 35
        Height = 13
        Caption = 'Начат:'
      end
      object Label4: TLabel
        Left = 224
        Top = 101
        Width = 48
        Height = 13
        Caption = 'Окончен:'
      end
      object Label5: TLabel
        Left = 4
        Top = 124
        Width = 35
        Height = 13
        Caption = 'Папка:'
      end
      object Label6: TLabel
        Left = 4
        Top = 54
        Width = 29
        Height = 13
        Caption = 'Кому:'
      end
      object lbPhone: TLabel
        Left = 256
        Top = 31
        Width = 3
        Height = 13
      end
      object lkFrom: TgsIBLookupComboBox
        Left = 54
        Top = 24
        Width = 195
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'FROMCONTACTKEY'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        Condition = 'contacttype in (2,3)'
        gdClassName = 'TgdcBaseContact'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = lkFromChange
      end
      object dbedSubject: TDBEdit
        Left = 54
        Top = 72
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DataField = 'SUBJECT'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbreBody: TDBRichEdit
        Left = 4
        Top = 144
        Width = 390
        Height = 155
        Anchors = [akLeft, akTop, akRight, akBottom]
        DataField = 'BODY'
        DataSource = dsgdcBase
        PlainText = True
        TabOrder = 4
      end
      object xDateDBEdit1: TxDateDBEdit
        Left = 54
        Top = 96
        Width = 113
        Height = 21
        DataField = 'MSGSTART'
        DataSource = dsgdcBase
        EditMask = '!99/99/9999 99:99:99;1;_'
        MaxLength = 19
        TabOrder = 5
      end
      object xDateDBEdit2: TxDateDBEdit
        Left = 280
        Top = 96
        Width = 113
        Height = 21
        DataField = 'MSGEND'
        DataSource = dsgdcBase
        EditMask = '!99/99/9999 99:99:99;1;_'
        MaxLength = 19
        TabOrder = 6
      end
      object lkFolder: TgsIBLookupComboBox
        Left = 54
        Top = 120
        Width = 340
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'BOXKEY'
        ListTable = 'msg_box'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        gdClassName = 'TgdcMessageBox'
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      object lkTo: TgsIBLookupComboBox
        Left = 54
        Top = 48
        Width = 195
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'TOCONTACTKEY'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        Condition = 'contacttype=2'
        gdClassName = 'TgdcContact'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
    end
    object tsAttachment: TTabSheet [1]
      Caption = 'Прикрепления'
      ImageIndex = 3
      object gsIBGrid1: TgsIBGrid
        Left = 4
        Top = 32
        Width = 390
        Height = 266
        HelpContext = 3
        DataSource = dsAttachment
        TabOrder = 0
        OnDblClick = gsIBGrid1DblClick
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
      object Button1: TButton
        Left = 4
        Top = 4
        Width = 101
        Height = 21
        Caption = 'Добавить новое'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Button2: TButton
        Left = 112
        Top = 4
        Width = 97
        Height = 21
        Caption = 'Открыть'
        TabOrder = 2
        OnClick = Button2Click
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 399
        Height = 303
      end
    end
  end
  inherited ibtrCommon: TIBTransaction
    Left = 352
    Top = 208
  end
  object gdcAttachment: TgdcAttachment
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'messagekey'
    SubSet = 'ByMessage'
    CachedUpdates = True
    Left = 417
    Top = 198
  end
  object dsAttachment: TDataSource
    DataSet = gdcAttachment
    Left = 449
    Top = 198
  end
end
