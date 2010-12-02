object gdc_dlgGood: Tgdc_dlgGood
  ActiveControl = nil
  PixelsPerInch = 96
  TextHeight = 13
  object btnAccess: TButton
  end
  object btnNew: TButton
  end
  object btnOK: TButton
  end
  object btnCancel: TButton
  end
  object btnHelp: TButton
  end
  object pgcMain: TPageControl
    object tbsMain: TTabSheet
      object labelID: TLabel
      end
      object dbtxtID: TDBText
      end
      object Label1: TLabel
      end
      object Label2: TLabel
      end
      object Label3: TLabel
      end
      object Label4: TLabel
      end
      object Label7: TLabel
      end
      object Label6: TLabel
      end
      object Label8: TLabel
      end
      object Label9: TLabel
      end
      object Label5: TLabel
      end
      object usrg_Label1: TLabel
        Tag = 0
        Left = 322
        Top = 85
        Width = 62
        Height = 13
        Cursor = crDefault
        Hint = ''
        Align = alNone
        Alignment = taLeftJustify
        AutoSize = True
        Caption = 'Ставка НДС'
        Constraints.MaxHeight = 0
        Constraints.MaxWidth = 0
        Constraints.MinHeight = 0
        Constraints.MinWidth = 0
        DragCursor = crDrag
        DragKind = dkDrag
        DragMode = dmManual
        Enabled = True
        FocusControl = nil
        ParentBiDiMode = True
        ParentColor = True
        ParentFont = True
        ParentShowHint = True
        PopupMenu = nil
        ShowAccelChar = True
        Transparent = False
        Layout = tlTop
        Visible = True
        WordWrap = False
      end
      object dbeName: TDBEdit
      end
      object dbmDescription: TDBMemo
        TabOrder = 5
      end
      object dbeBarCode: TDBEdit
        TabOrder = 6
      end
      object dbeAlias: TDBEdit
        TabOrder = 7
      end
      object dblcbTNVD: TgsIBLookupComboBox
        TabOrder = 8
      end
      object dbcbSet: TDBCheckBox
        TabOrder = 10
      end
      object dblcbValue: TgsIBLookupComboBox
      end
      object dbcbDisabled: TDBCheckBox
        TabOrder = 11
      end
      object dbedShortName: TDBEdit
        TabOrder = 4
      end
      object gdiblGoodGroup: TgsIBLookupComboBox
        Width = 175
      end
      object dbrgDiscipline: TDBRadioGroup
        Items.Strings = (
          'FIFO'
          'LIFO')
        TabOrder = 9
        Values.Strings = (
          'F'
          'L')
      end
      object usrg_Edit1: TEdit
        Tag = 0
        Left = 388
        Top = 81
        Width = 98
        Height = 21
        Cursor = crDefault
        Hint = ''
        TabStop = True
        AutoSelect = True
        AutoSize = True
        BorderStyle = bsSingle
        CharCase = ecNormal
        Color = clWindow
        Constraints.MaxHeight = 0
        Constraints.MaxWidth = 0
        Constraints.MinHeight = 0
        Constraints.MinWidth = 0
        DragCursor = crDrag
        DragKind = dkDrag
        DragMode = dmManual
        Enabled = True
        HideSelection = True
        ImeMode = imDontCare
        ImeName = ''
        MaxLength = 0
        OEMConvert = False
        ParentBiDiMode = True
        ParentColor = False
        ParentCtl3D = True
        ParentFont = True
        ParentShowHint = True
        PasswordChar = #0
        PopupMenu = nil
        ReadOnly = False
        TabOrder = 3
        Text = ''
        Visible = True
      end
    end
    object tshBarCode: TTabSheet
      object Panel2: TPanel
        object btnNewBarCode: TButton
        end
        object btnEditBarCode: TButton
        end
        object btnDelBarCode: TButton
        end
        object gdibgrBarCode: TgsIBGrid
          Expands = <>
          Conditions = <>
          ColumnEditors = <>
          Aliases = <>
          Columns = <
            item
              Expanded = False
              FieldName = 'ID'
              Title.Caption = '"ID"'
              Width = 8
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'GOODKEY'
              Title.Caption = '"GOODKEY"'
              Width = 8
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'BARCODE'
              Title.Caption = '"BARCODE"'
              Width = 8
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'DESCRIPTION'
              Title.Caption = '"DESCRIPTION"'
              Width = 8
              Visible = True
            end>
        end
      end
    end
    object set_tsh_GD_GOODPRMETAL: TTabSheet
      object set_frm_GD_GOODPRMETAL: Tgdc_framSetControl
      end
    end
    object set_tsh_GD_GOODSET: TTabSheet
      object set_frm_GD_GOODSET: Tgdc_framSetControl
      end
    end
    object set_tsh_GD_GOODTAX: TTabSheet
      object set_frm_GD_GOODTAX: Tgdc_framSetControl
      end
    end
    object set_tsh_GD_GOODVALUE: TTabSheet
      object set_frm_GD_GOODVALUE: Tgdc_framSetControl
      end
    end
    object tbsAttr: TTabSheet
      object atcMain: TatContainer
      end
    end
  end
  object alBase: TActionList
    Left = 273
    Top = 290
    object actNew: TAction
    end
    object actHelp: TAction
    end
    object actSecurity: TAction
    end
    object actOk: TAction
    end
    object actNextRecord: TAction
    end
    object actCancel: TAction
    end
    object actPrevRecord: TAction
    end
    object actApply: TAction
    end
    object actFirstRecord: TAction
    end
    object actLastRecord: TAction
    end
    object actProperty: TAction
    end
    object actNewBarCode: TAction
    end
    object actEditBarCode: TAction
    end
    object actDelBarcode: TAction
    end
  end
  object dsgdcBase: TDataSource
    Left = 243
    Top = 290
  end
  object pm_dlgG: TPopupMenu
    Left = 304
    Top = 288
    object N2: TMenuItem
    end
    object N3: TMenuItem
    end
    object C1: TMenuItem
    end
    object N1: TMenuItem
    end
    object actFirstRecord1: TMenuItem
    end
    object actLastRecord1: TMenuItem
    end
    object N4: TMenuItem
    end
    object N5: TMenuItem
    end
    object N6: TMenuItem
    end
    object N7: TMenuItem
    end
  end
  object ibtrCommon: TIBTransaction
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 344
    Top = 288
  end
  object gdcGoodBarCode: TgdcGoodBarCode
    Left = 409
    Top = 290
  end
  object dsBarCode: TDataSource
    Left = 379
    Top = 290
  end
end
