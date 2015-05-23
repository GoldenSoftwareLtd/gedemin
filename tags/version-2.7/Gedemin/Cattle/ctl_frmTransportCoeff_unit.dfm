inherited ctl_frmTransportCoeff: Tctl_frmTransportCoeff
  Left = 317
  Top = 295
  Width = 487
  Height = 317
  Caption = 'Коэффициенты транспортных расходов'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 244
    Width = 479
  end
  inherited pnlMain: TPanel
    Width = 479
    Height = 244
    inherited ibgrMain: TgsIBGrid
      Width = 477
      Height = 214
      Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    end
    inherited cbMain: TControlBar
      Width = 477
      inherited tbMain: TToolBar
        object ToolButton1: TToolButton
          Left = 283
          Top = 0
          Action = actSetup
        end
      end
    end
  end
  inherited alMain: TActionList
    Left = 170
    inherited actNew: TAction
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    inherited actEdit: TAction
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actSetup: TAction
      Caption = 'actSetup'
      ImageIndex = 8
      OnExecute = actSetupExecute
    end
  end
  inherited ibdsMain: TIBDataSet
    AfterPost = ibdsMainAfterPost
    DeleteSQL.Strings = (
      'delete from CTL_AUTOTARIFF'
      'where'
      '  CARGOCLASS = :OLD_CARGOCLASS and'
      '  DISTANCE = :OLD_DISTANCE')
    InsertSQL.Strings = (
      'insert into CTL_AUTOTARIFF'
      
        '  (CARGOCLASS, DISTANCE, TARIFF_500, TARIFF_1000, TARIFF_1500, T' +
        'ARIFF_2000, '
      '   TARIFF_5000, TARIFF_S5000, RESERVED)'
      'values'
      
        '  (:CARGOCLASS, :DISTANCE, :TARIFF_500, :TARIFF_1000, :TARIFF_15' +
        '00, :TARIFF_2000, '
      '   :TARIFF_5000, :TARIFF_S5000, :RESERVED)')
    RefreshSQL.Strings = (
      'Select '
      '  CARGOCLASS,'
      '  DISTANCE,'
      '  TARIFF_500,'
      '  TARIFF_1000,'
      '  TARIFF_1500,'
      '  TARIFF_2000,'
      '  TARIFF_5000,'
      '  TARIFF_S5000,'
      '  RESERVED'
      'from CTL_AUTOTARIFF '
      'where'
      '  CARGOCLASS = :CARGOCLASS and'
      '  DISTANCE = :DISTANCE')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      ''
      'FROM'
      '  CTL_AUTOTARIFF')
    ModifySQL.Strings = (
      'update CTL_AUTOTARIFF'
      'set'
      '  CARGOCLASS = :CARGOCLASS,'
      '  DISTANCE = :DISTANCE,'
      '  TARIFF_500 = :TARIFF_500,'
      '  TARIFF_1000 = :TARIFF_1000,'
      '  TARIFF_1500 = :TARIFF_1500,'
      '  TARIFF_2000 = :TARIFF_2000,'
      '  TARIFF_5000 = :TARIFF_5000,'
      '  TARIFF_S5000 = :TARIFF_S5000,'
      '  RESERVED = :RESERVED'
      'where'
      '  CARGOCLASS = :OLD_CARGOCLASS and'
      '  DISTANCE = :OLD_DISTANCE')
  end
end
