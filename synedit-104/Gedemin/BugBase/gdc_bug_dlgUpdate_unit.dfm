inherited gdc_bug_dlgUpdate: Tgdc_bug_dlgUpdate
  Left = 479
  Top = 119
  Caption = '—Ú‡ÚÛÒ Á‡Ô≥ÒÛ'
  ClientWidth = 420
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 322
    Top = 149
    TabOrder = 4
    Visible = False
  end
  inherited btnNew: TButton
    Left = 322
    Top = 173
    TabOrder = 5
    Visible = False
  end
  inherited btnOK: TButton
    Left = 8
    Top = 281
  end
  inherited btnCancel: TButton
    Left = 88
    Top = 281
  end
  inherited btnHelp: TButton
    Left = 342
    Top = 281
    TabOrder = 3
  end
  inherited pgcMain: TPageControl
    Left = 8
    Width = 401
    inherited tbsMain: TTabSheet
      object Label1: TLabel
        Left = 8
        Top = 31
        Width = 30
        Height = 13
        Caption = 'ƒ‡Ú‡:'
      end
      object Label2: TLabel
        Left = 128
        Top = 31
        Width = 50
        Height = 13
        Caption = '¬˚Ô‡‚≥¢:'
      end
      object Label4: TLabel
        Left = 8
        Top = 120
        Width = 53
        Height = 13
        Caption = ' ‡ÏÂÌÚ‡:'
      end
      object xDateDBEdit1: TxDateDBEdit
        Left = 40
        Top = 28
        Width = 73
        Height = 21
        DataField = 'decisiondate'
        DataSource = dsgdcBase
        Kind = kDate
        CurrentDateTimeAtStart = True
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 0
      end
      object iblkupFixer: TgsIBLookupComboBox
        Left = 180
        Top = 28
        Width = 205
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'fixerkey'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        Condition = 'contacttype=2'
        gdClassName = 'TgdcContact'
        Distinct = False
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object DBRadioGroup1: TDBRadioGroup
        Left = 8
        Top = 56
        Width = 377
        Height = 57
        Caption = ' —Ú‡Ì '
        Columns = 3
        DataField = 'decision'
        DataSource = dsgdcBase
        Items.Strings = (
          '¿ƒ –€“¿'
          '«–Œ¡À≈Õ¿'
          '—¿—“¿–›À¿'
          '¿ƒ’≤À≈Õ¿                     '
          '◊¿—“ Œ¬¿'
          '¬€ƒ¿À≈Õ¿')
        TabOrder = 2
      end
      object DBMemo1: TDBMemo
        Left = 8
        Top = 136
        Width = 377
        Height = 97
        DataField = 'FIXcomment'
        DataSource = dsgdcBase
        TabOrder = 3
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 393
      end
    end
  end
  inherited alBase: TActionList
    Top = 135
  end
  inherited dsgdcBase: TDataSource
    Left = 88
    Top = 135
  end
  inherited pm_dlgG: TPopupMenu
    Left = 368
    Top = 56
  end
  inherited ibtrCommon: TIBTransaction
    Left = 240
    Top = 32
  end
end
