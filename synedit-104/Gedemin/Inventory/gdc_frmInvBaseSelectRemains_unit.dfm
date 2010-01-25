inherited gdc_frmInvBaseSelectRemains: Tgdc_frmInvBaseSelectRemains
  Left = 229
  Top = 171
  Width = 783
  Height = 540
  Caption = 'gdc_frmInvBaseSelectRemains'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 494
    Width = 775
  end
  inherited TBDockTop: TTBDock
    Width = 775
    Height = 52
    inherited tbMainCustom: TTBToolbar
      Left = 739
      DockPos = 424
    end
    inherited tbMainInvariant: TTBToolbar
      inherited cbAllRemains: TCheckBox
        Top = 4
      end
    end
    inherited tbChooseMain: TTBToolbar
      DockPos = 296
      Visible = True
      object tbciBaseRemains: TTBControlItem
        Control = Panel1
      end
      object Panel1: TPanel
        Left = 23
        Top = 0
        Width = 238
        Height = 25
        BevelOuter = bvNone
        TabOrder = 0
        object RadioButton1: TRadioButton
          Left = 6
          Top = 5
          Width = 111
          Height = 17
          Caption = 'Текущие остатки'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton1Click
        end
        object RadioButton2: TRadioButton
          Left = 117
          Top = 5
          Width = 118
          Height = 17
          Caption = 'На дату документа'
          TabOrder = 1
          OnClick = RadioButton2Click
        end
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Top = 52
    Height = 433
  end
  inherited TBDockRight: TTBDock
    Left = 766
    Top = 52
    Height = 433
  end
  inherited TBDockBottom: TTBDock
    Top = 485
    Width = 775
  end
  inherited pnlWorkArea: TPanel
    Top = 52
    Width = 757
    Height = 433
    inherited spChoose: TSplitter
      Top = 330
      Width = 757
    end
    inherited pnlMain: TPanel
      Width = 757
      Height = 330
      inherited Splitter1: TSplitter
        Height = 330
      end
      inherited pnlSearchMain: TPanel
        Height = 330
        inherited sbSearchMain: TScrollBox
          Height = 292
        end
        inherited pnlSearchMainButton: TPanel
          Top = 292
        end
      end
      inherited pnMain: TPanel
        Height = 330
        inherited tvGroup: TgsDBTreeView
          Height = 330
        end
      end
      inherited pnDetail: TPanel
        Width = 377
        Height = 330
        inherited ibgrDetail: TgsIBGrid
          Width = 377
          Height = 330
          Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
          ReadOnly = False
          OnColEnter = ibgrDetailColEnter
          Aliases = <
            item
              Alias = 'REMAINS'
              LName = 'Остаток'
            end
            item
              Alias = 'CHOOSEQUANTITY'
              LName = 'Выбрать'
            end>
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 334
      Width = 757
      inherited pnButtonChoose: TPanel
        Left = 652
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 652
        Visible = True
      end
      inherited pnlChooseCaption: TPanel
        Width = 757
      end
    end
  end
  inherited alMain: TActionList
    inherited actOnlySelected: TAction
      ImageIndex = 8
    end
    inherited actSelectAll: TAction
      Visible = True
    end
    inherited actOk: TAction
      ImageIndex = 38
    end
    inherited actCancel: TAction
      ImageIndex = 39
    end
  end
  inherited gdcGoodGroup: TgdcGoodGroup
    BeforeScroll = gdcGoodGroupBeforeScroll
  end
end
