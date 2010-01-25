inherited gdc_acct_dlgEntry: Tgdc_acct_dlgEntry
  Left = 302
  Top = 132
  Width = 750
  Height = 556
  BorderStyle = bsSizeable
  BorderWidth = 5
  Caption = 'Хозяйственная операция'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 0
    Top = 498
    Anchors = [akLeft, akBottom]
  end
  inherited btnNew: TButton
    Left = 72
    Top = 498
    Anchors = [akLeft, akBottom]
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 498
    Anchors = [akLeft, akBottom]
  end
  inherited btnOK: TButton
    Left = 592
    Top = 498
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Left = 664
    Top = 498
    Anchors = [akRight, akBottom]
  end
  inherited pgcMain: TPageControl
    Left = 0
    Top = 25
    Width = 732
    Height = 464
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 4
        Top = 418
        Width = 83
        Anchors = [akLeft, akBottom]
        Visible = False
      end
      inherited dbtxtID: TDBText
        Top = 418
        Anchors = [akLeft, akBottom]
        Visible = False
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 724
        Height = 69
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label16: TLabel
          Left = 6
          Top = 8
          Width = 26
          Height = 13
          Caption = 'Дата'
        end
        object Label17: TLabel
          Left = 334
          Top = 8
          Width = 34
          Height = 13
          Caption = 'Номер'
        end
        object Label18: TLabel
          Left = 6
          Top = 28
          Width = 101
          Height = 13
          Caption = 'Описание операции'
        end
        object xDateDBEdit1: TxDateDBEdit
          Left = 53
          Top = 4
          Width = 276
          Height = 21
          DataField = 'RECORDDATE'
          DataSource = dsgdcBase
          Kind = kDate
          Ctl3D = True
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          ParentCtl3D = False
          TabOrder = 0
        end
        object DBEdit1: TDBEdit
          Left = 382
          Top = 4
          Width = 291
          Height = 21
          Ctl3D = True
          DataField = 'NUMBER'
          DataSource = dsgdcBase
          ParentCtl3D = False
          TabOrder = 1
        end
        object DBEdit2: TDBEdit
          Left = 6
          Top = 43
          Width = 667
          Height = 21
          Ctl3D = True
          DataField = 'DESCRIPTION'
          DataSource = dsgdcBase
          ParentCtl3D = False
          TabOrder = 2
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 97
        Width = 724
        Height = 339
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel2'
        TabOrder = 2
        object Splitter1: TSplitter
          Left = 356
          Top = 0
          Width = 3
          Height = 339
          Cursor = crHSplit
          AutoSnap = False
        end
        object Panel3: TPanel
          Left = 0
          Top = 0
          Width = 356
          Height = 339
          Align = alLeft
          BevelOuter = bvNone
          Constraints.MinWidth = 100
          TabOrder = 0
          object Panel4: TPanel
            Left = 0
            Top = 0
            Width = 356
            Height = 17
            Align = alTop
            Alignment = taLeftJustify
            BevelOuter = bvNone
            BorderStyle = bsSingle
            Caption = ' Дебет '
            Color = clWhite
            Ctl3D = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
          end
          object TBDock1: TTBDock
            Left = 0
            Top = 17
            Width = 356
            Height = 26
            object TBToolbar1: TTBToolbar
              Left = 0
              Top = 0
              Caption = 'TBToolbar1'
              DockMode = dmCannotFloat
              FullSize = True
              Images = dmImages.il16x16
              TabOrder = 0
              object TBItem3: TTBItem
                Action = actNewDebit
              end
              object TBItem2: TTBItem
                Action = actDeleteDebit
              end
            end
          end
          object sboxDebit: TgdvParamScrolBox
            Left = 0
            Top = 43
            Width = 356
            Height = 296
            HorzScrollBar.Visible = False
            VertScrollBar.Increment = 31
            VertScrollBar.Style = ssFlat
            Align = alClient
            BorderStyle = bsNone
            Color = 15329769
            ParentColor = False
            TabOrder = 2
          end
        end
        object Panel6: TPanel
          Left = 359
          Top = 0
          Width = 365
          Height = 339
          Align = alClient
          BevelOuter = bvNone
          Constraints.MinWidth = 100
          TabOrder = 1
          object Panel7: TPanel
            Left = 0
            Top = 0
            Width = 365
            Height = 17
            Align = alTop
            Alignment = taLeftJustify
            BevelOuter = bvNone
            BorderStyle = bsSingle
            Caption = ' Кредит'
            Color = clWhite
            Ctl3D = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMenuText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
          end
          object TBDock2: TTBDock
            Left = 0
            Top = 17
            Width = 365
            Height = 26
            object TBToolbar2: TTBToolbar
              Left = 0
              Top = 0
              Caption = 'TBToolbar1'
              FullSize = True
              Images = dmImages.il16x16
              TabOrder = 0
              object TBItem4: TTBItem
                Action = actNewCredit
              end
              object TBItem1: TTBItem
                Action = actDeleteCredit
              end
            end
          end
          object sboxCredit: TgdvParamScrolBox
            Left = 0
            Top = 43
            Width = 365
            Height = 296
            HorzScrollBar.Style = ssFlat
            HorzScrollBar.Visible = False
            VertScrollBar.Style = ssFlat
            Align = alClient
            BorderStyle = bsNone
            Color = 15329769
            ParentColor = False
            TabOrder = 2
          end
        end
      end
      object pTransaction: TPanel
        Left = 0
        Top = 69
        Width = 724
        Height = 28
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Label1: TLabel
          Left = 6
          Top = 6
          Width = 94
          Height = 13
          Caption = 'Типовая операция'
        end
        object iblcTransaction: TgsIBLookupComboBox
          Left = 112
          Top = 2
          Width = 561
          Height = 21
          HelpContext = 1
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'TRANSACTIONKEY'
          ListTable = 'ac_transaction'
          ListField = 'name'
          KeyField = 'ID'
          gdClassName = 'TgdcAcctTransaction'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 679
        Height = 461
      end
    end
  end
  object pnlHolding: TPanel [6]
    Left = 0
    Top = 0
    Width = 732
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 6
    object lblCompany: TLabel
      Left = 8
      Top = 5
      Width = 54
      Height = 13
      Caption = 'Компания:'
    end
    object iblkCompany: TgsIBLookupComboBox
      Left = 88
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
  inherited alBase: TActionList
    Left = 382
    Top = 297
    object actNewDebit: TAction
      Caption = 'actNewDebit'
      ImageIndex = 0
      OnExecute = actNewDebitExecute
    end
    object actDeleteDebit: TAction
      Caption = 'actDeleteDebit'
      ImageIndex = 2
      OnExecute = actDeleteDebitExecute
      OnUpdate = actDeleteDebitUpdate
    end
    object actNewCredit: TAction
      Caption = 'actNewCredit'
      ImageIndex = 0
      OnExecute = actNewCreditExecute
    end
    object actDeleteCredit: TAction
      Caption = 'actDeleteCredit'
      ImageIndex = 2
      OnExecute = actDeleteCreditExecute
      OnUpdate = actDeleteCreditUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 360
    Top = 273
  end
  inherited pm_dlgG: TPopupMenu
    Left = 424
    Top = 274
  end
  inherited ibtrCommon: TIBTransaction
    Left = 472
    Top = 250
  end
  object dsDebitLine: TDataSource
    Left = 392
    Top = 186
  end
  object dsCreditLine: TDataSource
    Left = 328
    Top = 184
  end
end
