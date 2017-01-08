inherited gdc_acct_dlgEntry: Tgdc_acct_dlgEntry
  Left = 340
  Top = 202
  Width = 749
  Height = 517
  BorderStyle = bsSizeable
  BorderWidth = 5
  Caption = 'Хозяйственная операция'
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 0
    Top = 446
  end
  inherited btnNew: TButton
    Left = 72
    Top = 446
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 446
  end
  inherited btnOK: TButton
    Left = 583
    Top = 446
  end
  inherited btnCancel: TButton
    Left = 655
    Top = 446
  end
  inherited pgcMain: TPageControl
    Left = 0
    Top = 25
    Width = 731
    Height = 414
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 4
        Top = 368
        Anchors = [akLeft, akBottom]
        Visible = False
      end
      inherited dbtxtID: TDBText
        Top = 368
        Anchors = [akLeft, akBottom]
        Visible = False
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 723
        Height = 54
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label16: TLabel
          Left = 6
          Top = 8
          Width = 30
          Height = 13
          Caption = 'Дата:'
        end
        object Label17: TLabel
          Left = 118
          Top = 8
          Width = 35
          Height = 13
          Caption = 'Номер:'
        end
        object Label18: TLabel
          Left = 6
          Top = 34
          Width = 104
          Height = 13
          Caption = 'Описание операции:'
        end
        object xDateDBEdit1: TxDateDBEdit
          Left = 41
          Top = 4
          Width = 68
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
          Left = 157
          Top = 4
          Width = 99
          Height = 21
          Ctl3D = True
          DataField = 'NUMBER'
          DataSource = dsgdcBase
          ParentCtl3D = False
          TabOrder = 1
        end
        object DBEdit2: TDBEdit
          Left = 115
          Top = 31
          Width = 594
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
        Top = 87
        Width = 723
        Height = 299
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel2'
        TabOrder = 2
        object Splitter1: TSplitter
          Left = 356
          Top = 0
          Width = 3
          Height = 299
          Cursor = crHSplit
          AutoSnap = False
        end
        object Panel3: TPanel
          Left = 0
          Top = 0
          Width = 356
          Height = 299
          Align = alLeft
          BevelOuter = bvNone
          Constraints.MinWidth = 100
          TabOrder = 0
          object Panel4: TPanel
            Left = 0
            Top = 0
            Width = 356
            Height = 21
            Align = alTop
            Alignment = taLeftJustify
            BevelOuter = bvNone
            Caption = ' Дебет '
            Color = clActiveCaption
            Ctl3D = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clCaptionText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
          end
          object TBDock1: TTBDock
            Left = 0
            Top = 21
            Width = 356
            Height = 26
            object tbDebit: TTBToolbar
              Left = 0
              Top = 0
              BorderStyle = bsNone
              Caption = 'tbDebit'
              CloseButton = False
              DockMode = dmCannotFloatOrChangeDocks
              FullSize = True
              Images = dmImages.il16x16
              TabOrder = 0
              object TBItem3: TTBItem
                Action = actNewDebit
              end
              object TBItem2: TTBItem
                Action = actDeleteDebit
              end
              object TBItem5: TTBItem
                Action = actDupDebit
              end
            end
          end
          object sboxDebit: TgdvParamScrolBox
            Left = 0
            Top = 47
            Width = 356
            Height = 252
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
          Width = 364
          Height = 299
          Align = alClient
          BevelOuter = bvNone
          Constraints.MinWidth = 100
          TabOrder = 1
          object Panel7: TPanel
            Left = 0
            Top = 0
            Width = 364
            Height = 21
            Align = alTop
            Alignment = taLeftJustify
            BevelOuter = bvNone
            Caption = ' Кредит'
            Color = clActiveCaption
            Ctl3D = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clCaptionText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentCtl3D = False
            ParentFont = False
            TabOrder = 0
          end
          object TBDock2: TTBDock
            Left = 0
            Top = 21
            Width = 364
            Height = 26
            object tbCredit: TTBToolbar
              Left = 0
              Top = 0
              BorderStyle = bsNone
              Caption = 'TBToolbar1'
              CloseButton = False
              DockMode = dmCannotFloatOrChangeDocks
              FullSize = True
              Images = dmImages.il16x16
              TabOrder = 0
              object TBItem4: TTBItem
                Action = actNewCredit
              end
              object TBItem1: TTBItem
                Action = actDeleteCredit
              end
              object TBItem6: TTBItem
                Action = actDupCredit
              end
            end
          end
          object sboxCredit: TgdvParamScrolBox
            Left = 0
            Top = 47
            Width = 364
            Height = 252
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
        Top = 54
        Width = 723
        Height = 33
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Label1: TLabel
          Left = 6
          Top = 6
          Width = 97
          Height = 13
          Caption = 'Типовая операция:'
        end
        object iblcTransaction: TgsIBLookupComboBox
          Left = 115
          Top = 3
          Width = 593
          Height = 21
          HelpContext = 1
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'TRANSACTIONKEY'
          ListTable = 'ac_transaction'
          ListField = 'name'
          KeyField = 'ID'
          Condition = 
            '(ac_transaction.AUTOTRANSACTION IS NULL OR ac_transaction.AUTOTR' +
            'ANSACTION = 0)'
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
        Width = 715
        Height = 386
      end
    end
  end
  object pnlHolding: TPanel [6]
    Left = 0
    Top = 0
    Width = 731
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 6
    object lblCompany: TLabel
      Left = 8
      Top = 5
      Width = 53
      Height = 13
      Caption = 'Компания:'
    end
    object iblkCompany: TgsIBLookupComboBox
      Left = 66
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
    object actDupDebit: TAction
      Caption = 'actDupDebit'
      ImageIndex = 3
      OnExecute = actDupDebitExecute
      OnUpdate = actDupDebitUpdate
    end
    object actDupCredit: TAction
      Caption = 'actDupCredit'
      ImageIndex = 3
      OnExecute = actDupCreditExecute
      OnUpdate = actDupCreditUpdate
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
