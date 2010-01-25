inherited gdc_dlgInvRemainsOption: Tgdc_dlgInvRemainsOption
  Left = 181
  Top = 122
  Caption = 'Настройка остатков'
  ClientHeight = 306
  ClientWidth = 487
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 281
    Anchors = [akLeft, akBottom]
  end
  inherited btnNew: TButton
    Top = 281
    Anchors = [akLeft, akBottom]
  end
  inherited btnHelp: TButton
    Top = 281
    Anchors = [akLeft, akBottom]
  end
  inherited btnOK: TButton
    Left = 339
    Top = 280
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Left = 411
    Top = 280
    Anchors = [akRight, akBottom]
  end
  object pcMain: TPageControl [5]
    Left = 0
    Top = 0
    Width = 487
    Height = 267
    ActivePage = tsCommon
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
    object tsCommon: TTabSheet
      Caption = 'Основные'
      object Label1: TLabel
        Left = 8
        Top = 13
        Width = 76
        Height = 13
        Caption = 'Наименование'
      end
      object Label2: TLabel
        Left = 8
        Top = 39
        Width = 119
        Height = 13
        Caption = 'Ветка в исследователе'
      end
      object dbedName: TDBEdit
        Left = 136
        Top = 9
        Width = 241
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object gsIBLookupComboBox1: TgsIBLookupComboBox
        Left = 136
        Top = 35
        Width = 241
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'BRANCHKEY'
        ListTable = 'GD_COMMAND'
        ListField = 'NAME'
        KeyField = 'ID'
        ItemHeight = 13
        TabOrder = 1
      end
      object DBCheckBox1: TDBCheckBox
        Left = 8
        Top = 64
        Width = 233
        Height = 17
        Caption = 'Ограничение на рабочую компанию'
        DataField = 'USECOMPANYKEY'
        DataSource = dsgdcBase
        TabOrder = 2
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
    end
    object tsViewFeatures: TTabSheet
      Caption = 'Отображаемые признаки'
      ImageIndex = 1
      object pcViewFeatures: TPageControl
        Left = 0
        Top = 0
        Width = 479
        Height = 239
        ActivePage = tsViewGood
        Align = alClient
        TabOrder = 0
        object tsViewCard: TTabSheet
          Caption = 'Карточки'
          object lvFeatures: TListView
            Left = 7
            Top = 7
            Width = 193
            Height = 191
            Columns = <
              item
                AutoSize = True
                Caption = 'Существующие признаки'
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            SortType = stText
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = actAddViewFeaturesExecute
          end
          object btnAdd: TButton
            Left = 211
            Top = 23
            Width = 48
            Height = 25
            Action = actAddViewFeatures
            TabOrder = 1
          end
          object btnAddAll: TButton
            Left = 211
            Top = 63
            Width = 48
            Height = 25
            Action = actDelViewFeatures
            TabOrder = 2
          end
          object btnRemove: TButton
            Left = 211
            Top = 103
            Width = 48
            Height = 25
            Action = actAddAllViewFeatures
            TabOrder = 3
          end
          object btnRemoveAll: TButton
            Left = 211
            Top = 143
            Width = 48
            Height = 25
            Action = actDelAllViewFeatures
            TabOrder = 4
          end
          object lvUsedFeatures: TListView
            Left = 270
            Top = 7
            Width = 193
            Height = 191
            Columns = <
              item
                AutoSize = True
                Caption = 'Выбранные признаки'
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            SortType = stText
            TabOrder = 5
            ViewStyle = vsReport
            OnDblClick = actDelViewFeaturesExecute
          end
        end
        object tsViewGood: TTabSheet
          Caption = 'Товара'
          ImageIndex = 1
          object lvGoodFeatures: TListView
            Left = 7
            Top = 7
            Width = 193
            Height = 191
            Columns = <
              item
                AutoSize = True
                Caption = 'Существующие признаки'
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            SortType = stText
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = actAddGoodViewFeaturesExecute
          end
          object Button5: TButton
            Left = 211
            Top = 23
            Width = 48
            Height = 25
            Action = actAddGoodViewFeatures
            TabOrder = 1
          end
          object Button6: TButton
            Left = 211
            Top = 63
            Width = 48
            Height = 25
            Action = actDelGoodViewFeatures
            TabOrder = 2
          end
          object Button7: TButton
            Left = 211
            Top = 103
            Width = 48
            Height = 25
            Action = actAddAllGoodViewFeatures
            TabOrder = 3
          end
          object Button8: TButton
            Left = 211
            Top = 143
            Width = 48
            Height = 25
            Action = actDelAllGoodViewFeatures
            TabOrder = 4
          end
          object lvUsedGoodFeatures: TListView
            Left = 270
            Top = 7
            Width = 193
            Height = 191
            Columns = <
              item
                AutoSize = True
                Caption = 'Выбранные признаки'
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            SortType = stText
            TabOrder = 5
            ViewStyle = vsReport
            OnDblClick = actDelGoodViewFeaturesExecute
          end
        end
      end
    end
    object tsSumFeatures: TTabSheet
      Caption = 'Поля для суммирования'
      ImageIndex = 2
      object pcSumFeatures: TPageControl
        Left = 0
        Top = 0
        Width = 479
        Height = 239
        ActivePage = TabSheet2
        Align = alClient
        TabOrder = 0
        object TabSheet1: TTabSheet
          Caption = 'Карточки'
          object lvSumFeatures: TListView
            Left = 7
            Top = 7
            Width = 193
            Height = 192
            Columns = <
              item
                AutoSize = True
                Caption = 'Существующие признаки'
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            SortType = stText
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = actAddSumFeaturesExecute
          end
          object Button1: TButton
            Left = 211
            Top = 23
            Width = 48
            Height = 25
            Action = actAddSumFeatures
            TabOrder = 1
          end
          object Button2: TButton
            Left = 211
            Top = 63
            Width = 48
            Height = 25
            Action = actDelSumFeatures
            TabOrder = 2
          end
          object Button3: TButton
            Left = 211
            Top = 103
            Width = 48
            Height = 25
            Action = actAddAllSumFeatures
            TabOrder = 3
          end
          object Button4: TButton
            Left = 211
            Top = 143
            Width = 48
            Height = 25
            Action = actDelAllSumFeatures
            TabOrder = 4
          end
          object lvUsedSumFeatures: TListView
            Left = 270
            Top = 7
            Width = 193
            Height = 192
            Columns = <
              item
                AutoSize = True
                Caption = 'Выбранные признаки'
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            SortType = stText
            TabOrder = 5
            ViewStyle = vsReport
            OnDblClick = actDelSumFeaturesExecute
          end
        end
        object TabSheet2: TTabSheet
          Caption = 'Товара'
          ImageIndex = 1
          object lvGoodSumFeatures: TListView
            Left = 7
            Top = 7
            Width = 193
            Height = 192
            Columns = <
              item
                AutoSize = True
                Caption = 'Существующие признаки'
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            SortType = stText
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = actAddGoodSumFeaturesExecute
          end
          object Button9: TButton
            Left = 211
            Top = 23
            Width = 48
            Height = 25
            Action = actAddGoodSumFeatures
            TabOrder = 1
          end
          object Button10: TButton
            Left = 211
            Top = 63
            Width = 48
            Height = 25
            Action = actDelGoodSumFeatures
            TabOrder = 2
          end
          object Button11: TButton
            Left = 211
            Top = 103
            Width = 48
            Height = 25
            Action = actAddAllGoodSumFeatures
            TabOrder = 3
          end
          object Button12: TButton
            Left = 211
            Top = 143
            Width = 48
            Height = 25
            Action = actDelAllGoodSumFeatures
            TabOrder = 4
          end
          object lvUsedGoodSumFeatures: TListView
            Left = 270
            Top = 7
            Width = 193
            Height = 192
            Columns = <
              item
                AutoSize = True
                Caption = 'Выбранные признаки'
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            SortType = stText
            TabOrder = 5
            ViewStyle = vsReport
            OnDblClick = actDelGoodSumFeaturesExecute
          end
        end
      end
    end
  end
  inherited alBase: TActionList
    Top = 143
    object actAddViewFeatures: TAction
      Category = 'ViewFeatures'
      Caption = '>'
      OnExecute = actAddViewFeaturesExecute
    end
    object actDelViewFeatures: TAction
      Category = 'ViewFeatures'
      Caption = '<'
      OnExecute = actDelViewFeaturesExecute
    end
    object actAddAllViewFeatures: TAction
      Category = 'ViewFeatures'
      Caption = '>>'
      OnExecute = actAddAllViewFeaturesExecute
    end
    object actDelAllViewFeatures: TAction
      Category = 'ViewFeatures'
      Caption = '<<'
      OnExecute = actDelAllViewFeaturesExecute
    end
    object actAddSumFeatures: TAction
      Category = 'SumFeatures'
      Caption = '>'
      OnExecute = actAddSumFeaturesExecute
    end
    object actDelSumFeatures: TAction
      Category = 'SumFeatures'
      Caption = '<'
      OnExecute = actDelSumFeaturesExecute
    end
    object actAddAllSumFeatures: TAction
      Category = 'SumFeatures'
      Caption = '>>'
      OnExecute = actAddAllSumFeaturesExecute
    end
    object actDelAllSumFeatures: TAction
      Category = 'SumFeatures'
      Caption = '<<'
      OnExecute = actDelAllSumFeaturesExecute
    end
    object actAddGoodViewFeatures: TAction
      Category = 'ViewFeatures'
      Caption = '>'
      OnExecute = actAddGoodViewFeaturesExecute
    end
    object actDelGoodViewFeatures: TAction
      Category = 'ViewFeatures'
      Caption = '<'
      OnExecute = actDelGoodViewFeaturesExecute
    end
    object actAddAllGoodViewFeatures: TAction
      Category = 'ViewFeatures'
      Caption = '>>'
      OnExecute = actAddAllGoodViewFeaturesExecute
    end
    object actDelAllGoodViewFeatures: TAction
      Category = 'ViewFeatures'
      Caption = '<<'
      OnExecute = actDelAllGoodViewFeaturesExecute
    end
    object actAddGoodSumFeatures: TAction
      Category = 'SumFeatures'
      Caption = '>'
      OnExecute = actAddGoodSumFeaturesExecute
    end
    object actDelGoodSumFeatures: TAction
      Category = 'SumFeatures'
      Caption = '<'
      OnExecute = actDelGoodSumFeaturesExecute
    end
    object actAddAllGoodSumFeatures: TAction
      Category = 'SumFeatures'
      Caption = '>>'
      OnExecute = actAddAllGoodSumFeaturesExecute
    end
    object actDelAllGoodSumFeatures: TAction
      Category = 'SumFeatures'
      Caption = '<<'
      OnExecute = actDelAllGoodSumFeaturesExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Top = 143
  end
  inherited pm_dlgG: TPopupMenu
    Top = 144
  end
  inherited ibtrCommon: TIBTransaction
    Top = 144
  end
end
