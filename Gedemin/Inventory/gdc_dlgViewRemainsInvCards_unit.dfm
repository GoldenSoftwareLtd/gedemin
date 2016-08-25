object gdc_dlgViewRemainsInvCards: Tgdc_dlgViewRemainsInvCards
  Left = 380
  Top = 174
  Width = 562
  Height = 310
  BorderWidth = 5
  Caption = 'Выбор остатков'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 248
    Width = 544
    Height = 25
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button2: TButton
      Left = 466
      Top = 3
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akTop, akRight]
      Default = True
      TabOrder = 0
    end
    object Button1: TButton
      Left = 389
      Top = 3
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      TabOrder = 1
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 544
    Height = 248
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    Caption = 'pnlMain'
    TabOrder = 1
    object lHeader: TLabel
      Left = 5
      Top = 5
      Width = 534
      Height = 16
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object Panel2: TPanel
      Left = 5
      Top = 21
      Width = 534
      Height = 222
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Bevel1: TBevel
        Left = 0
        Top = 0
        Width = 534
        Height = 2
        Align = alTop
      end
      object ibgrInvCardList: TgsIBGrid
        Left = 0
        Top = 2
        Width = 534
        Height = 220
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsInvCardList
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = True
        CheckBox.FirstColumn = True
        ScaleColumns = True
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
    end
  end
  object ibdsInvCardList: TIBDataSet
    SelectSQL.Strings = (
      'SELECT g.name, b.balance, c.* '
      'FROM inv_card c'
      '  JOIN inv_balance b ON c.id = b.cardkey '
      '    AND b.balance >= :count '
      '    AND b.contactkey = :contactkey'
      '    AND b.cardkey <> :cardkey'
      '  JOIN gd_good g ON g.id = c.goodkey'
      '    AND g.id = :gid')
    Left = 173
    Top = 85
  end
  object dsInvCardList: TDataSource
    DataSet = ibdsInvCardList
    Left = 269
    Top = 45
  end
  object ActionList1: TActionList
    Left = 317
    Top = 85
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
  end
end
