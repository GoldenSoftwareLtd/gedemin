inherited gdc_frmInvViewRemains: Tgdc_frmInvViewRemains
  Left = 416
  Top = 105
  Width = 864
  Height = 665
  ActiveControl = nil
  Caption = 'Остатки'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 619
    Width = 856
  end
  inherited TBDockTop: TTBDock
    Width = 856
    Height = 101
    inherited tbMainToolbar: TTBToolbar
      object TBSubmenuItem1: TTBSubmenuItem [18]
        Caption = 'Настройка остатков'
        DropdownCombo = True
        Hint = 'Выбор полей для отображения в остатках'
        ImageIndex = 36
        object TBItem3: TTBItem
          Action = actOptions
          Caption = 'Карточка'
        end
        object TBItem5: TTBItem
          Action = actGoodOptions
        end
      end
      object TBSubmenuItem2: TTBSubmenuItem [19]
        Caption = 'Суммирование по полям'
        DropdownCombo = True
        Hint = 'Выбор полей по которым необходимо суммирование'
        ImageIndex = 209
        object TBItem4: TTBItem
          Action = actSumFields
        end
        object TBItem6: TTBItem
          Action = actGoodSumFields
        end
      end
      inherited TBItem1: TTBItem
        Visible = False
      end
      inherited TBItem2: TTBItem
        Visible = False
      end
    end
    inherited tbMainCustom: TTBToolbar
      Left = 0
      Top = 49
      AutoResize = False
      DockPos = 312
      DockRow = 2
      object TBControlItem1: TTBControlItem
        Control = Label1
      end
      object TBControlItem2: TTBControlItem
        Control = gsiblcCompany
      end
      object TBControlItem3: TTBControlItem
        Control = lDate
      end
      object TBControlItem4: TTBControlItem
        Control = deDateRemains
      end
      object TBControlItem5: TTBControlItem
        Control = SpeedButton1
      end
      object TBControlItem6: TTBControlItem
        Control = cbCurrentRemains
      end
      object Label1: TLabel
        Left = 0
        Top = 4
        Width = 130
        Height = 13
        Caption = 'Клиент (подразделение) '
      end
      object lDate: TLabel
        Left = 311
        Top = 4
        Width = 35
        Height = 13
        Caption = ' Дата  '
      end
      object SpeedButton1: TSpeedButton
        Left = 420
        Top = 0
        Width = 23
        Height = 22
        Action = actExecRemains
        Flat = True
        Glyph.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000FF00FF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FFFFFF0052AD
          FF0018529400185A9C00185A9C00185A9C00185AA500185AA500185A9C00185A
          9C00185294001852940018528C00184A84004AADFF00FFFFFF00FFFFFF00185A
          A500186BBD001873CE001873CE001873CE001873CE001873CE001873CE001873
          CE001873CE00186BC600186BBD00185AA500104A7B00FFFFFF00FFFFFF001863
          AD001873CE00187BDE00187BDE00187BE7001884E700188CF700188CF700188C
          F700188CF700187BDE00186BC6001863AD0018528C00FFFFFF00FFFFFF00186B
          C600187BDE001884EF001884EF001884EF0084C6FF00188CF700188CF700188C
          F700188CF7001884E7001873CE00186BBD0018529400FFFFFF00FFFFFF001873
          CE001884E700188CF700188CFF0084C6FF00FFFFFF0084C6FF00188CF700188C
          F700188CF7001884E7001873D600186BC600185A9C00FFFFFF00FFFFFF00187B
          DE00188CF700188CFF0084C6FF00FFFFFF0084C6FF00FFFFFF0084C6FF00188C
          F700188CF7001884E7001873D6001873CE00185AA500FFFFFF00FFFFFF001884
          E700188CFF0084C6FF00FFFFFF0084C6FF00188CF700188CF700FFFFFF0084C6
          FF001884EF00187BDE001873CE001873CE001863AD00FFFFFF00FFFFFF001884
          EF00188CFF00188CFF0084C6FF00188CF700188CF700188CF700188CF700FFFF
          FF0084C6FF001873D6001873CE001873CE001863AD00FFFFFF00FFFFFF00188C
          FF002194FF002194FF00188CFF00188CFF00188CF7001884F7001884EF001884
          EF00FFFFFF0084C6FF001873CE001873CE001863AD00FFFFFF00FFFFFF00188C
          FF0039A5FF0039A5FF002194FF001894FF00188CFF00188CFF001884EF001884
          E700187BDE00FFFFFF0084C6FF001873CE001863AD00FFFFFF00FFFFFF002194
          FF0052ADFF004AADFF00299CFF002194FF002194FF001894FF00188CF7001884
          EF001884E700187BDE00FFFFFF001873CE001863AD00FFFFFF00FFFFFF0039A5
          FF006BBDFF0052ADFF0039A5FF00319CFF00299CFF00299CFF002194FF00188C
          FF001884F7001884EF00187BDE001873CE001863AD00FFFFFF00FFFFFF004AAD
          FF0084C6FF006BBDFF0052ADFF004AADFF0039A5FF00319CFF00299CFF002194
          FF001894FF00188CF7001884EF001873CE00185A9C00FFFFFF00FFFFFF00ADDE
          FF004AADFF00319CFF002194FF00188CFF00188CFF00188CF700188CF7001884
          EF001884E700187BDE001873CE00186BBD0063B5FF00FFFFFF00FF00FF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00}
      end
      object gsiblcCompany: TgsIBLookupComboBox
        Left = 130
        Top = 0
        Width = 181
        Height = 21
        HelpContext = 1
        Transaction = ibtrCommon
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        gdClassName = 'TgdcBaseContact'
        ItemHeight = 13
        TabOrder = 0
        OnChange = gsiblcCompanyChange
      end
      object deDateRemains: TxDateEdit
        Left = 346
        Top = 0
        Width = 74
        Height = 21
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 1
        Text = '30.09.2002'
      end
      object cbCurrentRemains: TCheckBox
        Left = 443
        Top = 2
        Width = 126
        Height = 17
        Caption = 'Текущие остатки'
        TabOrder = 2
        OnClick = cbCurrentRemainsClick
      end
    end
    inherited tbMainInvariant: TTBToolbar
      inherited tbiCommit: TTBItem
        Caption = 'Перечитать'
        Hint = 'Перечитать'
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 0
      Top = 75
      DockPos = -2
      DockRow = 3
    end
  end
  inherited TBDockLeft: TTBDock
    Top = 101
    Height = 509
  end
  inherited TBDockRight: TTBDock
    Left = 847
    Top = 101
    Height = 509
  end
  inherited TBDockBottom: TTBDock
    Top = 610
    Width = 856
  end
  inherited pnlWorkArea: TPanel
    Top = 101
    Width = 838
    Height = 509
    inherited spChoose: TSplitter
      Top = 406
      Width = 838
    end
    inherited pnlMain: TPanel
      Width = 838
      Height = 406
      inherited Splitter1: TSplitter
        Height = 406
      end
      inherited pnlSearchMain: TPanel
        Height = 406
        inherited sbSearchMain: TScrollBox
          Height = 368
        end
        inherited pnlSearchMainButton: TPanel
          Top = 368
        end
      end
      inherited pnMain: TPanel
        Height = 406
        inherited tvGroup: TgsDBTreeView
          Height = 406
        end
      end
      inherited pnDetail: TPanel
        Width = 458
        Height = 406
        Caption = 'Для отображения остатков нажмите кнопку "Перестроить" (F5)'
        Font.Height = -13
        Font.Style = [fsBold]
        ParentFont = False
        inherited ibgrDetail: TgsIBGrid
          Width = 458
          Height = 406
          Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
          ParentFont = False
          Visible = False
          TableFont.Height = -13
          TableFont.Style = [fsBold]
          SelectedFont.Height = -13
          SelectedFont.Style = [fsBold]
          TitleFont.Height = -13
          TitleFont.Style = [fsBold]
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 410
      Width = 838
      inherited pnButtonChoose: TPanel
        Left = 733
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 733
      end
      inherited pnlChooseCaption: TPanel
        Width = 838
      end
    end
  end
  inherited alMain: TActionList
    inherited actMainReduction: TAction
      Visible = False
    end
    object actExecRemains: TAction
      Category = 'Commands'
      Hint = 'Перестроить'
      ImageIndex = 38
      ShortCut = 116
      OnExecute = actExecRemainsExecute
      OnUpdate = actExecRemainsUpdate
    end
    object actOptions: TAction
      Category = 'Commands'
      Caption = 'Катрочка'
      Hint = 'Выбор полей карточки товара для отображения в остатках'
      ImageIndex = 73
      OnExecute = actOptionsExecute
    end
    object actSumFields: TAction
      Category = 'Commands'
      Caption = 'Карточка'
      Hint = 'Выбор полей карточки товара по которым необходимо суммирование'
      ImageIndex = 73
      OnExecute = actSumFieldsExecute
    end
    object actGoodOptions: TAction
      Category = 'Commands'
      Caption = 'Товар'
      Hint = 'Выбор полей справочника товаров для отображения в остатках'
      ImageIndex = 176
      OnExecute = actGoodOptionsExecute
    end
    object actGoodSumFields: TAction
      Category = 'Commands'
      Caption = 'Товар'
      Hint = 
        'Выбор полей справочника товаров по которым необходимо суммирован' +
        'ие'
      ImageIndex = 176
      OnExecute = actGoodSumFieldsExecute
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcInvRemains
  end
  object gdcInvRemains: TgdcInvRemains
    AfterOpen = gdcInvRemainsAfterOpen
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByGroupKey,ByHolding'
    CachedUpdates = True
    Left = 320
    Top = 184
  end
  object gdcTable: TgdcTable
    SubSet = 'ByRelationName'
    Left = 209
    Top = 165
  end
  object gdcChooseTableField: TgdcTableField
    SubSet = 'OnlySelected'
    Left = 209
    Top = 205
  end
  object dsTable: TDataSource
    DataSet = gdcTable
    Left = 241
    Top = 205
  end
  object ibtrCommon: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 440
    Top = 216
  end
end
