inherited ctl_ChooseCattleBranch: Tctl_ChooseCattleBranch
  Left = 226
  Top = 142
  Caption = 'Ветка скота в справочнике товаров'
  ClientHeight = 259
  ClientWidth = 369
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnOk: TButton
    Left = 288
    Anchors = [akTop, akRight]
  end
  inherited btnCancel: TButton
    Left = 288
    Anchors = [akTop, akRight]
  end
  inherited btnHelp: TButton
    Left = 288
    Anchors = [akTop, akRight]
  end
  object lvGood: TgsIBLargeTreeView [3]
    Left = 10
    Top = 8
    Width = 273
    Height = 241
    IDField = 'ID'
    ParentField = 'PARENT'
    LBField = 'LB'
    RBField = 'RB'
    LBRBMode = False
    ListField = 'NAME'
    OrderByField = 'NAME'
    RelationName = 'GD_GOODGROUP'
    TopBranchID = 'NULL'
    Database = dmDatabase.ibdbGAdmin
    AutoLoad = True
    StopOnCount = 150
    ShowTopBranch = False
    TopBranchText = 'Все'
    CheckBoxes = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Indent = 19
    TabOrder = 3
  end
  inherited ActionList: TActionList
    Left = 294
    Top = 108
    inherited actOk: TAction
      OnUpdate = actOkUpdate
    end
  end
end
