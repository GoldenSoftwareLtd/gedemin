inherited gdc_frmInvSelectedGoods: Tgdc_frmInvSelectedGoods
  Caption = 'Выбор товаров'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlWorkArea: TPanel
    inherited spChoose: TSplitter
      Visible = True
    end
    inherited pnlMain: TPanel
      object Splitter1: TSplitter [0]
        Left = 286
        Top = 0
        Width = 3
        Height = 215
        Cursor = crHSplit
      end
      object tvMain: TgsDBTreeView
        Left = 160
        Top = 0
        Width = 126
        Height = 215
        DataSource = dsGoodGroup
        KeyField = 'ID'
        ParentField = 'PARENT'
        DisplayField = 'NAME'
        ImageField = 'CONTACTTYPE'
        ImageValueList.Strings = (
          '101=3')
        Align = alLeft
        ChangeDelay = 300
        HideSelection = False
        Indent = 19
        PopupMenu = pmMain
        RightClickSelect = True
        SortType = stText
        TabOrder = 1
        MainFolderHead = True
        MainFolder = True
        MainFolderCaption = 'Все'
        WithCheckBox = True
      end
      object ibgrDetail: TgsIBGrid
        Left = 289
        Top = 0
        Width = 352
        Height = 215
        HelpContext = 3
        Align = alClient
        Ctl3D = True
        DataSource = dsMain
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        ParentCtl3D = False
        TabOrder = 2
        OnColEnter = ibgrDetailColEnter
        OnEnter = ibgrDetailEnter
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.FieldName = 'ID'
        CheckBox.Visible = True
        CheckBox.AfterCheckEvent = ibgrDetailClickedCheck
        CheckBox.FirstColumn = True
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <
          item
            Alias = 'REMAINS'
            LName = 'Остаток'
          end
          item
            Alias = 'CHOOSEQUANTITY'
            LName = 'Выбрать'
          end>
        OnClickedCheck = ibgrDetailClickedCheck
      end
    end
    inherited pnChoose: TPanel
      Visible = True
      inherited pnButtonChoose: TPanel
        BevelInner = bvLowered
        inherited btnCancelChoose: TButton
          Left = 16
          Top = 32
          Anchors = [akRight, akBottom]
        end
        inherited btnOkChoose: TButton
          Left = 16
          Top = 8
          Action = nil
          Anchors = [akRight, akBottom]
          ModalResult = 1
          OnClick = nil
        end
        inherited btnDeleteChoose: TButton
          Left = 16
          Top = 56
          Anchors = [akRight, akBottom]
        end
      end
      inherited ibgrChoose: TgsIBGrid
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
        Visible = True
        CheckBox.DisplayField = 'id'
        CheckBox.FieldName = 'id'
        CheckBox.FirstColumn = True
      end
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      Enabled = False
    end
    inherited actEdit: TAction
      Enabled = False
    end
    inherited actDelete: TAction
      Enabled = False
    end
    inherited actDuplicate: TAction
      Enabled = False
    end
  end
  inherited pmMain: TPopupMenu
    Left = 76
    Top = 100
  end
  inherited dsMain: TDataSource
    DataSet = gdcSelectedGood
    Left = 452
    Top = 172
  end
  object gdcGoodGroup: TgdcGoodGroup
    Left = 225
    Top = 193
  end
  object dsGoodGroup: TDataSource
    DataSet = gdcGoodGroup
    Left = 193
    Top = 153
  end
  object gdcSelectedGood: TgdcSelectedGood
    BeforePost = gdcSelectedGoodBeforePost
    MasterSource = dsGoodGroup
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    OnGetSelectClause = gdcSelectedGoodGetSelectClause
    Left = 448
    Top = 120
  end
end
