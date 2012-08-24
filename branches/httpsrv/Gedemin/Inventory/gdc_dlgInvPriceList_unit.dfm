inherited dlgInvPriceList: TdlgInvPriceList
  Left = 366
  Top = 220
  Width = 530
  Height = 441
  Caption = 'Прайс-лист'
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 87
    Top = 386
  end
  inherited btnNew: TButton
    Left = 7
    Top = 386
  end
  inherited btnOK: TButton
    Left = 367
    Top = 386
  end
  inherited btnCancel: TButton
    Left = 447
    Top = 386
  end
  inherited btnHelp: TButton
    Left = 164
    Top = 386
  end
  inherited pnlMain: TPanel
    Width = 522
    Height = 376
    inherited splMain: TSplitter
      Top = 156
      Width = 522
    end
    inherited pnlDetail: TPanel
      Top = 160
      Width = 522
      Height = 216
      inherited ibgrDetail: TgsIBGrid
        Width = 504
        Height = 181
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        OnColEnter = ibgrDetailColEnter
        OnColExit = ibgrDetailColExit
        ColumnEditors = <
          item
            Lookup.LookupListField = 'name'
            Lookup.LookupKeyField = 'id'
            Lookup.LookupTable = 'gd_good'
            Lookup.gdClassName = 'TgdcGood'
            Lookup.Distinct = False
            EditorStyle = cesLookup
            FieldName = 'GOODKEY'
            DisplayField = 'GOODNAME'
            ValueList.Strings = ()
            DropDownCount = 8
          end>
      end
      inherited tbdTop: TTBDock
        Width = 522
        inherited tbDetail: TTBToolbar
          object TBSeparatorItem3: TTBSeparatorItem
          end
          object TBItem1: TTBItem
            Action = actGoodsRef
          end
        end
      end
      inherited tbdLeft: TTBDock
        Height = 181
      end
      inherited tbdRight: TTBDock
        Left = 513
        Height = 181
      end
      inherited tbdBottom: TTBDock
        Top = 207
        Width = 522
      end
    end
    inherited pnlMaster: TPanel
      Width = 522
      Height = 156
      object atAttributes: TatContainer
        Left = 0
        Top = 0
        Width = 522
        Height = 138
        DataSource = dsgdcBase
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
        OnRelationNames = atAttributesRelationNames
      end
      object pnlInfo: TPanel
        Left = 0
        Top = 138
        Width = 522
        Height = 18
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object lblCurrencyInfo: TLabel
          Left = 5
          Top = 2
          Width = 43
          Height = 13
          Caption = 'Валюта:'
        end
        object lblCurrency: TLabel
          Left = 55
          Top = 2
          Width = 54
          Height = 13
          Caption = 'lblCurrency'
        end
      end
    end
  end
  inherited alBase: TActionList
    Left = 411
    Top = 7
    inherited actDetailMacro: TAction
      OnExecute = actDetailMacroExecute
    end
    object actGoodsRef: TAction
      Category = 'Detail'
      Caption = 'Справочник товаров'
      OnExecute = actGoodsRefExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 441
  end
  inherited dsDetail: TDataSource
    Left = 441
    Top = 36
  end
  object gdMacrosMenu: TgdMacrosMenu
    Left = 249
    Top = 111
  end
end
