inherited gdc_dlgAcctAccount: Tgdc_dlgAcctAccount
  Left = 403
  Top = 190
  HelpContext = 112
  PixelsPerInch = 96
  TextHeight = 13
  inherited pgcMain: TPageControl
    ActivePage = TabSheet1
    inherited tbsMain: TTabSheet
      inherited pAccountInfo: TPanel
        inherited GroupBox1: TGroupBox
          Top = -1
        end
        inherited dbrgTypeAccount: TDBRadioGroup
          Top = -1
          TabStop = True
        end
        inherited gsiblcGroupAccount: TgsIBLookupComboBox
          ListField = 'NAME'
          SortOrder = soAsc
          Condition = 'ac_account.ACCOUNTTYPE = '#39'F'#39
        end
      end
      inherited gsibRelationFields: TgsIBLookupComboBox
        ItemHeight = 0
      end
    end
  end
end
