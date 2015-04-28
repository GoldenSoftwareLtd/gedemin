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
    Top = 483
    Width = 767
  end
  inherited TBDockTop: TTBDock
    Width = 767
    Height = 54
    inherited tbMainCustom: TTBToolbar
      Left = 734
      DockPos = 424
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 252
      inherited cbAllRemains: TCheckBox
        Left = 218
        Top = 25
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 480
      DockPos = 296
      Visible = True
      object tbciBaseRemains: TTBControlItem
        Control = Panel1
      end
      object Panel1: TPanel
        Left = 6
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
    Top = 54
    Height = 420
  end
  inherited TBDockRight: TTBDock
    Left = 758
    Top = 54
    Height = 420
  end
  inherited TBDockBottom: TTBDock
    Top = 474
    Width = 767
  end
  inherited pnlWorkArea: TPanel
    Top = 54
    Width = 749
    Height = 420
    inherited spChoose: TSplitter
      Top = 317
      Width = 749
    end
    inherited pnlMain: TPanel
      Width = 749
      Height = 317
      inherited Splitter1: TSplitter
        Height = 317
      end
      inherited pnlSearchMain: TPanel
        Height = 317
        inherited sbSearchMain: TScrollBox
          Height = 290
        end
      end
      inherited pnMain: TPanel
        Height = 317
        inherited tvGroup: TgsDBTreeView
          Height = 317
        end
      end
      inherited pnDetail: TPanel
        Width = 369
        Height = 317
        inherited ibgrDetail: TgsIBGrid
          Width = 369
          Height = 317
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
      Top = 321
      Width = 749
      inherited pnButtonChoose: TPanel
        Left = 644
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 644
        Visible = True
      end
      inherited pnlChooseCaption: TPanel
        Width = 749
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
