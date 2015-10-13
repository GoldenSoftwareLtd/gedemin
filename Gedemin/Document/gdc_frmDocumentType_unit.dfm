inherited gdc_frmDocumentType: Tgdc_frmDocumentType
  Left = 379
  Top = 181
  Width = 795
  Height = 542
  Caption = 'Типовые документы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 484
    Width = 779
  end
  inherited TBDockTop: TTBDock
    Width = 779
    inherited tbMainToolbar: TTBToolbar
      inherited tbiNew: TTBItem
        Visible = False
      end
      object TBSubmenuItem1: TTBSubmenuItem [1]
        Action = actNew
        DropdownCombo = True
        object TBItem1: TTBItem
          Action = actNew
        end
        object TBItem2: TTBItem
          Action = actNewSub
        end
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 286
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 424
  end
  inherited TBDockRight: TTBDock
    Left = 770
    Height = 424
  end
  inherited TBDockBottom: TTBDock
    Top = 475
    Width = 779
  end
  inherited pnlWorkArea: TPanel
    Width = 761
    Height = 424
    inherited sMasterDetail: TSplitter
      Height = 319
    end
    inherited spChoose: TSplitter
      Top = 319
      Width = 761
    end
    inherited pnlMain: TPanel
      Height = 319
      inherited pnlSearchMain: TPanel
        Height = 319
        inherited sbSearchMain: TScrollBox
          Height = 292
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 319
        Images = dmImages.ilTree
        OnGetImageIndex = tvGroupGetImageIndex
      end
    end
    inherited pnChoose: TPanel
      Top = 325
      Width = 761
      inherited pnButtonChoose: TPanel
        Left = 656
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 656
      end
      inherited pnlChooseCaption: TPanel
        Width = 761
      end
    end
    inherited pnlDetail: TPanel
      Width = 589
      Height = 319
      object splDocumentOptions: TSplitter [0]
        Left = 0
        Top = 172
        Width = 589
        Height = 6
        Cursor = crVSplit
        Align = alBottom
      end
      inherited TBDockDetail: TTBDock
        Width = 589
        inherited tbDetailToolbar: TTBToolbar
          object tbsmNew: TTBSubmenuItem [0]
            Caption = 'Добавить'
            DropdownCombo = True
            Hint = 'Добавить документ'
            ImageIndex = 0
            OnClick = tbsmNewClick
            object tbiAddUserDoc: TTBItem
              Action = actAddUserDoc
            end
            object tbiAddInvDocument: TTBItem
              Action = actAddInvDocument
            end
            object tbiAddInvPriceList: TTBItem
              Action = actAddInvPriceList
            end
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 286
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 146
        inherited sbSearchDetail: TScrollBox
          Height = 119
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 429
        Height = 146
      end
      object pnlDocumentOptions: TPanel
        Left = 0
        Top = 178
        Width = 589
        Height = 141
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
        object tbdDTOptions: TTBDock
          Left = 0
          Top = 0
          Width = 589
          Height = 25
          object tbDTOptions: TTBToolbar
            Left = 0
            Top = 0
            Caption = 'tbDTOptions'
            DockMode = dmCannotFloatOrChangeDocks
            TabOrder = 0
            object TBItem6: TTBItem
              Action = actNewOption
            end
            object TBItem7: TTBItem
              Action = actEditOption
            end
            object TBItem3: TTBItem
              Action = actDeleteOption
            end
            object TBSeparatorItem2: TTBSeparatorItem
            end
            object TBItem8: TTBItem
              Action = actRefreshOption
            end
            object TBSeparatorItem3: TTBSeparatorItem
            end
            object TBItem4: TTBItem
              Action = actCommitOption
            end
            object TBItem5: TTBItem
              Action = actRollbackOption
            end
          end
        end
        object ibgrOptions: TgsIBGrid
          Left = 0
          Top = 25
          Width = 589
          Height = 116
          Align = alClient
          BorderStyle = bsNone
          DataSource = dsInvDocumentOptions
          Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
          ReadOnly = True
          TabOrder = 1
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
          ShowFooter = True
          ShowTotals = False
        end
      end
    end
  end
  inherited alMain: TActionList
    Top = 135
    object actNewSub: TAction [1]
      Category = 'Main'
      Caption = 'Добавить ветвь...'
      Hint = 'Добавить ветвь...'
      ImageIndex = 0
      OnExecute = actNewSubExecute
      OnUpdate = actNewSubUpdate
    end
    inherited actDetailNew: TAction
      Visible = False
      OnExecute = actAddUserDocExecute
    end
    object actAddUserDoc: TAction
      Category = 'Detail'
      Caption = 'Добавить документ пользователя'
      Hint = 'Добавить документ пользователя'
      ImageIndex = 0
      OnExecute = actAddUserDocExecute
      OnUpdate = actAddUserDocUpdate
    end
    object actAddInvDocument: TAction
      Category = 'Detail'
      Caption = 'Добавить складской документ'
      Hint = 'Добавить складской документ'
      ImageIndex = 0
      OnExecute = actAddInvDocumentExecute
      OnUpdate = actAddInvDocumentUpdate
    end
    object actAddInvPriceList: TAction
      Category = 'Detail'
      Caption = 'Добавить прайс-лист'
      Hint = 'Добавить прайс-лист'
      ImageIndex = 0
      OnExecute = actAddInvPriceListExecute
      OnUpdate = actAddInvPriceListUpdate
    end
    object actDeleteOption: TAction
      Category = 'Option'
      Caption = 'Удалить'
      OnExecute = actDeleteOptionExecute
      OnUpdate = actDeleteOptionUpdate
    end
    object actCommitOption: TAction
      Category = 'Option'
      Caption = 'Сохранить изменения'
      OnExecute = actCommitOptionExecute
      OnUpdate = actCommitOptionUpdate
    end
    object actRollbackOption: TAction
      Category = 'Option'
      Caption = 'Отменить изменения'
      OnExecute = actRollbackOptionExecute
      OnUpdate = actRollbackOptionUpdate
    end
    object actNewOption: TAction
      Category = 'Option'
      Caption = 'Создать'
      OnExecute = actNewOptionExecute
      OnUpdate = actNewOptionUpdate
    end
    object actEditOption: TAction
      Category = 'Option'
      Caption = 'Изменить'
      OnExecute = actEditOptionExecute
      OnUpdate = actEditOptionUpdate
    end
    object actRefreshOption: TAction
      Category = 'Option'
      Caption = 'Обновить'
      OnExecute = actRefreshOptionExecute
    end
  end
  inherited pmMain: TPopupMenu
    Left = 113
    Top = 164
  end
  inherited dsMain: TDataSource
    Top = 164
  end
  inherited dsDetail: TDataSource
    DataSet = gdcDocumentType
    Left = 398
    Top = 140
  end
  inherited pmDetail: TPopupMenu
    Left = 458
    Top = 140
  end
  object gdcDocumentType: TgdcDocumentType
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 428
    Top = 140
  end
  object gdcBaseDocumentType: TgdcBaseDocumentType
    Left = 72
    Top = 128
  end
  object dsInvDocumentOptions: TDataSource
    DataSet = ibdsDocumentOptions
    Left = 496
    Top = 289
  end
  object ibdsDocumentOptions: TIBDataSet
    Transaction = ibTr
    DeleteSQL.Strings = (
      'DELETE FROM gd_documenttype_option WHERE id = :OLD_ID')
    RefreshSQL.Strings = (
      'SELECT'
      '  o.id,'
      '  o.option_name,'
      '  COALESCE(rf.relationname || '#39'.'#39' || rf.fieldname,'
      '    c.name, IIF(o.bool_value = 0, '#39'No'#39', '#39'Yes'#39')) AS option_value,'
      '  (SELECT LIST(n.name)'
      
        '    FROM at_namespace n JOIN at_object obj ON obj.namespacekey =' +
        ' n.id'
      '      JOIN gd_ruid r ON r.xid = obj.xid AND r.dbid = obj.dbid'
      '   WHERE r.id = o.id) AS namespace'
      'FROM'
      '  gd_documenttype_option o'
      '  LEFT JOIN at_relation_fields rf ON rf.id = o.relationfieldkey'
      '  LEFT JOIN gd_contact c ON c.id = o.contactkey'
      'WHERE'
      '  o.id = :old_id')
    SelectSQL.Strings = (
      'SELECT'
      '  o.id,'
      '  o.option_name,'
      
        '  COALESCE(rf.relationname || '#39'.'#39' || rf.fieldname || '#39' - '#39' || rf' +
        '.lname ||'
      '    IIF(c.name IS NULL, '#39#39', '#39', '#39' || c.name) ||'
      '    IIF(curr.name IS NULL, '#39#39', '#39', '#39' || curr.name),'
      '    c.name, IIF(o.bool_value = 0, '#39'No'#39', '#39'Yes'#39')) AS option_value,'
      '  (SELECT LIST(n.name)'
      
        '    FROM at_namespace n JOIN at_object obj ON obj.namespacekey =' +
        ' n.id'
      '      JOIN gd_ruid r ON r.xid = obj.xid AND r.dbid = obj.dbid'
      '   WHERE r.id = o.id) AS namespace'
      'FROM'
      '  gd_documenttype_option o'
      '  LEFT JOIN at_relation_fields rf ON rf.id = o.relationfieldkey'
      '  LEFT JOIN gd_contact c ON c.id = o.contactkey'
      '  LEFT JOIN gd_curr curr ON curr.id = o.currkey'
      'WHERE'
      '  o.dtkey = :id'
      'ORDER BY'
      '  o.option_name'
      ' ')
    DataSource = dsDetail
    ReadTransaction = ibTr
    Left = 467
    Top = 289
  end
  object ibTr: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 432
    Top = 288
  end
  object gdcInvDocumentTypeOptions: TgdcInvDocumentTypeOptions
    Transaction = ibTr
    MasterSource = dsInvDocumentOptions
    MasterField = 'ID'
    DetailField = 'ID'
    SubSet = 'ByID'
    ReadTransaction = ibTr
    Left = 528
    Top = 290
  end
end
