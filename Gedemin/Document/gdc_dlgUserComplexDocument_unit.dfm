inherited gdc_dlgUserComplexDocument: Tgdc_dlgUserComplexDocument
  Left = 363
  Top = 190
  Width = 644
  Height = 482
  Caption = 'gdc_dlgUserComplexDocument'
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 81
    Top = 418
  end
  inherited btnNew: TButton
    Left = 8
    Top = 418
  end
  inherited btnHelp: TButton
    Left = 155
    Top = 418
  end
  inherited btnOK: TButton
    Left = 479
    Top = 418
  end
  inherited btnCancel: TButton
    Left = 553
    Top = 418
  end
  inherited pnlMain: TPanel
    Width = 628
    Height = 417
    inherited splMain: TSplitter
      Width = 628
    end
    inherited pnlDetail: TPanel
      Width = 628
      Height = 261
      inherited ibgrDetail: TgsIBGrid
        Width = 610
        Height = 226
        BorderStyle = bsNone
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
      inherited tbdTop: TTBDock
        Width = 628
        inherited tbDetail: TTBToolbar
          ParentShowHint = False
          ShowHint = True
        end
      end
      inherited tbdLeft: TTBDock
        Height = 226
      end
      inherited tbdRight: TTBDock
        Left = 619
        Height = 226
      end
      inherited tbdBottom: TTBDock
        Top = 252
        Width = 628
      end
    end
    inherited pnlMaster: TPanel
      Width = 628
      object atContainer: TatContainer
        Left = 0
        Top = 25
        Width = 628
        Height = 127
        DataSource = dsgdcBase
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 1
        OnRelationNames = atContainerRelationNames
      end
      object pnlHolding: TPanel
        Left = 0
        Top = 0
        Width = 628
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblCompany: TLabel
          Left = 8
          Top = 5
          Width = 53
          Height = 13
          Caption = 'Компания:'
        end
        object iblkCompany: TgsIBLookupComboBox
          Left = 73
          Top = 2
          Width = 193
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'companykey'
          ListTable = 'gd_contact'
          ListField = 'name'
          KeyField = 'ID'
          Condition = 
            'exists (select companykey from gd_ourcompany where companykey=gd' +
            '_contact.id)'
          gdClassName = 'TgdcOurCompany'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
      end
    end
  end
  inherited alBase: TActionList
    inherited actDetailMacro: TAction
      OnExecute = actDetailMacroExecute
    end
  end
  object gdMacrosMenu: TgdMacrosMenu
    Left = 249
    Top = 111
  end
end
