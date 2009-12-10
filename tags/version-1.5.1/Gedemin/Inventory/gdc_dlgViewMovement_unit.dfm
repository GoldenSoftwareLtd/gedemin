object gdc_dlgViewMovement: Tgdc_dlgViewMovement
  Left = 660
  Top = 386
  BorderStyle = bsDialog
  BorderWidth = 1
  Caption = 'Внимание'
  ClientHeight = 355
  ClientWidth = 610
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 321
    Width = 610
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 452
      Top = 7
      Width = 75
      Height = 21
      Action = actViewDocument
      TabOrder = 0
    end
    object Button2: TButton
      Left = 531
      Top = 7
      Width = 75
      Height = 21
      Action = actClose
      Anchors = [akTop, akRight]
      Default = True
      TabOrder = 1
    end
    object Button3: TButton
      Left = 4
      Top = 7
      Width = 125
      Height = 21
      Action = actInCardAll
      TabOrder = 2
    end
    object Button4: TButton
      Left = 132
      Top = 7
      Width = 125
      Height = 21
      Action = actInCardSingle
      TabOrder = 3
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 610
    Height = 321
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 2
    Caption = 'pnlMain'
    TabOrder = 1
    object lHeader: TLabel
      Left = 3
      Top = 3
      Width = 604
      Height = 32
      Align = alTop
      AutoSize = False
      Caption = 
        ' Удаление позиции %s невозможно, т.к. по ней имеется дальнейшее ' +
        'движение'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      WordWrap = True
    end
    object Panel2: TPanel
      Left = 3
      Top = 35
      Width = 604
      Height = 283
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Bevel1: TBevel
        Left = 0
        Top = 0
        Width = 604
        Height = 2
        Align = alTop
      end
      object ibgrMovementList: TgsIBGrid
        Left = 0
        Top = 2
        Width = 604
        Height = 281
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsMovementList
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
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
    end
  end
  object ibdsMovementList: TIBDataSet
    SelectSQL.Strings = (
      
        'select doc.parent, doc.documentdate, doc.number, c.id contactkey' +
        ', '
      
        '  doct.name as doctypename, m2.debit, m2.credit, c.name, card.fi' +
        'rstdate, '
      
        '  m1.cardkey m1_cardkey, m2.cardkey m2_cardkey, card.id cardkey,' +
        ' '
      '  m2.movementkey mkey, doc.id dockey, doct.id doctkey'
      'from'
      '  inv_movement m1'
      '  JOIN inv_movement m ON m.cardkey = m1.cardkey'
      '  LEFT JOIN inv_movement m2 ON m.movementkey = m2.movementkey'
      '  LEFT JOIN gd_contact c ON m2.contactkey = c.id'
      '  LEFT JOIN gd_document doc ON m.documentkey = doc.id'
      
        '  LEFT JOIN gd_documenttype doct ON doc.documenttypekey = doct.i' +
        'd'
      '  LEFT JOIN inv_card card ON m.CARDKEY = card.id'
      'where'
      
        '  m.contactkey = :contactkey and m.documentkey <> :documentkey a' +
        'nd '
      '  m1.debit > 0 and m.credit > 0 and'
      '  m1.documentkey = :documentkey and m1.contactkey = :contactkey')
    Left = 173
    Top = 85
  end
  object dsMovementList: TDataSource
    DataSet = ibdsMovementList
    Left = 205
    Top = 93
  end
  object ActionList1: TActionList
    Left = 317
    Top = 85
    object actViewDocument: TAction
      Caption = 'Документ'
      OnExecute = actViewDocumentExecute
    end
    object actClose: TAction
      Caption = 'Закрыть'
      OnExecute = actCloseExecute
    end
    object actInCardAll: TAction
      Caption = 'Переместить все'
      OnExecute = actInCardAllExecute
    end
    object actInCardSingle: TAction
      Caption = 'Переместить позицию'
      OnExecute = actInCardSingleExecute
    end
  end
end
