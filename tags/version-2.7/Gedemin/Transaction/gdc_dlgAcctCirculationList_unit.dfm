inherited dlgAcctCirculationList: TdlgAcctCirculationList
  Left = 173
  Top = 167
  Caption = '������������ ��������� ���������'
  ClientHeight = 438
  PixelsPerInch = 96
  TextHeight = 13
  inherited PageControl: TPageControl
    Height = 438
    inherited tsGeneral: TTabSheet
      inherited lAccounts: TLabel
        Enabled = False
      end
      inherited frSum: TframeSum
        Top = 201
        TabOrder = 9
      end
      inherited frQuantity: TframeQuantity
        Top = 98
        TabOrder = 8
      end
      inherited cbAccounts: TComboBox
        Enabled = False
      end
      inherited cbIncludeInternalMovement: TCheckBox
        Left = 152
        Top = 48
      end
      inherited Button1: TButton
        Enabled = False
      end
      inherited GroupBox1: TGroupBox
        Top = 308
        TabOrder = 10
      end
      object cbShowCredit: TCheckBox
        Left = 152
        Top = 61
        Width = 153
        Height = 17
        Caption = '����������� �� �������'
        TabOrder = 6
      end
      object cbShowDebit: TCheckBox
        Left = 0
        Top = 61
        Width = 153
        Height = 17
        Caption = '����������� �� ������'
        TabOrder = 5
      end
      object cbShowCorrSubAccounts: TCheckBox
        Left = 0
        Top = 77
        Width = 313
        Height = 17
        Caption = '��������������� � ����������'
        TabOrder = 7
      end
      object cbSubAccountsInMain: TCheckBox
        Left = 344
        Top = 48
        Width = 177
        Height = 17
        Caption = '�������� �������� � �������'
        TabOrder = 11
        OnClick = cbSubAccountsInMainClick
      end
      object cbDisplaceSaldo: TCheckBox
        Left = 344
        Top = 64
        Width = 141
        Height = 17
        Caption = '����������� ������'
        TabOrder = 12
      end
    end
    inherited tsAnalytics: TTabSheet
      TabVisible = False
      inherited frAnalytics: TframeAnalyticValue
        Width = 522
        Height = 404
        inherited sbAnaliseLines: TScrollBox
          Width = 522
          Height = 404
        end
      end
    end
  end
end
