inherited gdc_dlgAcctSubAccount: Tgdc_dlgAcctSubAccount
  Left = 392
  Top = 145
  Caption = '�������'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pgcMain: TPageControl
    inherited tbsMain: TTabSheet
      inherited lblAlias: TLabel
        Width = 84
        Caption = '����� ��������:'
      end
      inherited lblName: TLabel
        Width = 77
        Caption = '������������:'
      end
      inherited Label2: TLabel
        Width = 76
        Caption = '������ � ����:'
      end
      object lblHint: TLabel [6]
        Left = 190
        Top = 55
        Width = 272
        Height = 13
        Caption = '������ ���������� � ������ �����. ��������: 01.02'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      inherited pAccountInfo: TPanel
        inherited GroupBox1: TGroupBox
          Caption = ' ��������� �������� '
          inherited dbcbCurrAccount: TDBCheckBox
            Width = 122
            Caption = '�������� �������'
          end
          inherited dbcbOffBalance: TDBCheckBox
            Caption = '������������ �������'
          end
        end
        inherited dbrgTypeAccount: TDBRadioGroup
          Caption = ' ��� �������� '
        end
      end
      inherited dbedAlias: TDBEdit
        Width = 65
        OnChange = dbedAliasChange
      end
    end
  end
end
