inherited dlgInvDocumentLine: TdlgInvDocumentLine
  Left = 394
  Top = 164
  Width = 621
  Height = 463
  BorderStyle = bsSizeable
  Caption = 'Позиция складского документа'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 3
    Top = 399
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 74
    Top = 399
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 146
    Top = 399
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 460
    Top = 399
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 532
    Top = 399
    TabOrder = 2
  end
  object pnlData: TPanel [5]
    Left = 0
    Top = 0
    Width = 605
    Height = 393
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object pcMain: TPageControl
      Left = 4
      Top = 4
      Width = 597
      Height = 385
      ActivePage = tsMain
      Align = alClient
      MultiLine = True
      TabOrder = 0
      object tsAttributes: TTabSheet
        Caption = 'tsAttributes'
        TabVisible = False
        object atAttributes: TatContainer
          Left = 0
          Top = 0
          Width = 496
          Height = 356
          DataSource = dsgdcBase
          Align = alClient
          BorderStyle = bsNone
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
          OnRelationNames = atAttributesRelationNames
          OnAdjustControl = atAttributesAdjustControl
        end
      end
      object tsMain: TTabSheet
        Caption = 'Главная'
        ImageIndex = 1
        object sbMain: TScrollBox
          Left = 0
          Top = 0
          Width = 589
          Height = 357
          Align = alClient
          TabOrder = 0
        end
      end
      object TabSheet1: TTabSheet
        Caption = 'Справочники'
        ImageIndex = 2
        object pnlReferences: TPanel
          Left = 0
          Top = 0
          Width = 105
          Height = 364
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
        end
      end
    end
  end
  inherited alBase: TActionList
    Left = 570
    Top = 161
    object actGoodsRef: TAction
      Category = 'References'
      Caption = 'Справочник ТМЦ'
      OnExecute = actGoodsRefExecute
    end
    object actRemainsRef: TAction
      Category = 'References'
      Caption = 'Остатки ТМЦ'
      OnExecute = actRemainsRefExecute
    end
    object actMacro: TAction
      Category = 'References'
      Caption = 'Макрос'
      OnExecute = actMacroExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 564
    Top = 129
  end
  inherited pm_dlgG: TPopupMenu
    Left = 528
    Top = 240
  end
  inherited ibtrCommon: TIBTransaction
    Left = 550
    Top = 90
  end
end
