inherited gdc_bug_dlgBugBase: Tgdc_bug_dlgBugBase
  Left = 253
  Top = 187
  Caption = 'œ‡Ï˚ÎÍ‡'
  ClientHeight = 396
  ClientWidth = 582
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 502
    Top = 175
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 502
    Top = 145
    TabOrder = 3
  end
  inherited btnOK: TButton
    Left = 502
    Top = 22
  end
  inherited btnCancel: TButton
    Left = 502
    Top = 53
  end
  inherited btnHelp: TButton
    Left = 502
    Top = 206
  end
  inherited pgcMain: TPageControl
    Width = 485
    Height = 387
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 3
        Width = 80
        Caption = '≤‰˝ÌÚ˚Ù≥Í‡Ú‡:'
      end
      inherited dbtxtID: TDBText
        Left = 88
        Width = 105
      end
      object Label2: TLabel
        Left = 3
        Top = 31
        Width = 59
        Height = 13
        Caption = 'œ‡‰Ò≥ÒÚ˝Ï‡:'
      end
      object Label3: TLabel
        Left = 3
        Top = 53
        Width = 54
        Height = 13
        Caption = '¬˝Ò≥ˇ, ‡‰:'
      end
      object Label4: TLabel
        Left = 3
        Top = 76
        Width = 51
        Height = 13
        Caption = '¬Ó·Î‡Òˆ¸:'
      end
      object Label5: TLabel
        Left = 3
        Top = 98
        Width = 24
        Height = 13
        Caption = '“˚Ô:'
      end
      object Label6: TLabel
        Left = 256
        Top = 31
        Width = 46
        Height = 13
        Caption = '◊‡ÒÚ‡Ú‡:'
      end
      object Label7: TLabel
        Left = 3
        Top = 119
        Width = 126
        Height = 13
        Caption = '¿Ô≥Ò‡Ì¸ÌÂ/ﬂÍ ‚˚ÍÎ≥Í‡ˆ¸:'
      end
      object Label9: TLabel
        Left = 256
        Top = 54
        Width = 48
        Height = 13
        Caption = '«Ì‡È¯Ó¢:'
      end
      object Label10: TLabel
        Left = 256
        Top = 76
        Width = 25
        Height = 13
        Caption = ' ‡Î≥:'
      end
      object Label11: TLabel
        Left = 256
        Top = 98
        Width = 49
        Height = 13
        Caption = '¿‰Í‡ÁÌ˚:'
      end
      object Label12: TLabel
        Left = 166
        Top = 52
        Width = 17
        Height = 13
        Caption = '‰‡:'
      end
      object Label13: TLabel
        Left = 256
        Top = 9
        Width = 29
        Height = 13
        Caption = '—Ú‡Ì:'
      end
      object DBText2: TDBText
        Left = 320
        Top = 8
        Width = 65
        Height = 17
        DataField = 'DECISION'
        DataSource = dsgdcBase
      end
      object Label1: TLabel
        Left = 3
        Top = 272
        Width = 53
        Height = 13
        Caption = ' ‡ÏÂÌÚ‡:'
      end
      object DBText1: TDBText
        Left = 168
        Top = 272
        Width = 41
        Height = 13
        AutoSize = True
        DataField = 'fixername'
        DataSource = dsgdcBase
      end
      object Label8: TLabel
        Left = 392
        Top = 76
        Width = 41
        Height = 13
        Caption = 'œ˚‡.:'
      end
      object Label14: TLabel
        Left = 112
        Top = 272
        Width = 50
        Height = 13
        Caption = '¬˚Ô‡‚≥¢:'
      end
      object Label15: TLabel
        Left = 384
        Top = 272
        Width = 25
        Height = 13
        Caption = ' ‡Î≥:'
      end
      object DBText3: TDBText
        Left = 416
        Top = 272
        Width = 41
        Height = 13
        AutoSize = True
        DataField = 'decisiondate'
        DataSource = dsgdcBase
      end
      object dbcbSubSystem: TDBComboBox
        Left = 88
        Top = 26
        Width = 153
        Height = 21
        DataField = 'SUBSYSTEM'
        DataSource = dsgdcBase
        DropDownCount = 24
        ItemHeight = 13
        TabOrder = 0
      end
      object DBEdit1: TDBEdit
        Left = 88
        Top = 49
        Width = 57
        Height = 21
        DataField = 'versionfrom'
        DataSource = dsgdcBase
        TabOrder = 1
        OnExit = DBEdit1Exit
      end
      object DBEdit2: TDBEdit
        Left = 184
        Top = 49
        Width = 57
        Height = 21
        DataField = 'versionto'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbcbBugArea: TDBComboBox
        Left = 88
        Top = 72
        Width = 153
        Height = 21
        DataField = 'BUGAREA'
        DataSource = dsgdcBase
        DropDownCount = 24
        ItemHeight = 13
        TabOrder = 3
      end
      object dbcbBugType: TDBComboBox
        Left = 88
        Top = 95
        Width = 153
        Height = 21
        Style = csDropDownList
        DataField = 'BUGTYPE'
        DataSource = dsgdcBase
        DropDownCount = 24
        ItemHeight = 13
        Items.Strings = (
          '«–¿¡≤÷‹'
          '“–›¡¿ «–¿¡≤÷‹'
          'Õ≈ƒ¿’Œœ'
          'œ¿Ã€À ¿'
          ' ¿“¿—“–Œ‘¿')
        TabOrder = 4
      end
      object dbcbBugFrequency: TDBComboBox
        Left = 320
        Top = 26
        Width = 154
        Height = 21
        Style = csDropDownList
        DataField = 'BUGFREQUENCY'
        DataSource = dsgdcBase
        DropDownCount = 24
        ItemHeight = 13
        Items.Strings = (
          'Õ≤ ŒÀ≤'
          '«–›ƒ ”'
          '◊¿—¿Ã'
          '◊¿—“¿'
          '«¿°—®ƒ€')
        TabOrder = 5
      end
      object DBEdit3: TDBEdit
        Left = 320
        Top = 72
        Width = 55
        Height = 21
        DataField = 'RAISED'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object DBMemo1: TDBMemo
        Left = 3
        Top = 136
        Width = 471
        Height = 81
        DataField = 'BUGDESCRIPTION'
        DataSource = dsgdcBase
        ScrollBars = ssVertical
        TabOrder = 10
      end
      object DBMemo2: TDBMemo
        Left = 3
        Top = 220
        Width = 471
        Height = 45
        DataField = 'BUGINSTRUCTION'
        DataSource = dsgdcBase
        ScrollBars = ssVertical
        TabOrder = 11
      end
      object iblkupFounder: TgsIBLookupComboBox
        Left = 320
        Top = 49
        Width = 154
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'founderkey'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        SortOrder = soAsc
        Condition = 'contacttype=2'
        gdClassName = 'TgdcContact'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
      end
      object iblkupResponsible: TgsIBLookupComboBox
        Left = 320
        Top = 95
        Width = 154
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'responsiblekey'
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        Condition = 'contacttype=2'
        gdClassName = 'TgdcContact'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 9
      end
      object dbcbPriority: TDBComboBox
        Left = 433
        Top = 72
        Width = 41
        Height = 21
        DataField = 'priority'
        DataSource = dsgdcBase
        DropDownCount = 24
        ItemHeight = 13
        Items.Strings = (
          '1'
          '2'
          '3'
          '4'
          '5')
        TabOrder = 8
      end
      object DBMemo3: TDBMemo
        Left = 3
        Top = 288
        Width = 471
        Height = 68
        DataField = 'fixcomment'
        DataSource = dsgdcBase
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 12
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 477
        Height = 359
      end
    end
  end
end
