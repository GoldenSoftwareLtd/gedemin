inherited gdc_frmReportList: Tgdc_frmReportList
  Left = 256
  Top = 172
  HelpContext = 111
  Caption = 'Отчеты'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainToolbar: TTBToolbar
      Visible = True
    end
    inherited tbMainCustom: TTBToolbar
      Left = 488
      DockPos = 488
      object TBControlItem1: TTBControlItem
        Control = chbxUserGroup
      end
      object chbxUserGroup: TCheckBox
        Left = 0
        Top = 2
        Width = 129
        Height = 17
        Caption = 'Скрыть отчеты форм'
        TabOrder = 0
        OnClick = chbxUserGroupClick
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 360
      DockPos = 360
    end
  end
  inherited pnlWorkArea: TPanel
    inherited pnlDetail: TPanel
      inherited TBDockDetail: TTBDock
        inherited tbDetailCustom: TTBToolbar
          Left = 352
          DockPos = 352
          Visible = True
          object tbiBuild: TTBItem
            Action = actBuildReport
          end
          object tbiRebuild: TTBItem
            Action = actReBuildReport
            Visible = False
          end
          object tbiReportServer: TTBItem
            Action = actDefaultServer
            Visible = False
          end
          object tbiRefresh: TTBItem
            Action = actRefresh
          end
        end
      end
    end
  end
  inherited alMain: TActionList
    Left = 264
    inherited actPrint: TAction
      Enabled = False
      Visible = False
    end
    inherited actMacros: TAction
      Enabled = False
      Visible = False
    end
    inherited actDetailPrint: TAction
      Enabled = False
      Visible = False
    end
    object actBuildReport: TAction
      Category = 'Report'
      Caption = 'Построить отчет'
      Hint = 'Построить отчет'
      ImageIndex = 16
      OnExecute = actBuildReportExecute
      OnUpdate = actBuildReportUpdate
    end
    object actReBuildReport: TAction
      Category = 'Report'
      Caption = 'Перестроить отчет'
      Hint = 'Перестроить отчет'
      ImageIndex = 16
      OnExecute = actReBuildReportExecute
    end
    object actDefaultServer: TAction
      Category = 'Report'
      Caption = 'Сервер отчетов'
      Hint = 'Сервер отчетов'
      ImageIndex = 36
      OnExecute = actDefaultServerExecute
    end
    object actRefresh: TAction
      Category = 'Report'
      Caption = 'Обновить'
      Hint = 'Обновить'
      ImageIndex = 17
      Visible = False
      OnExecute = actRefreshExecute
    end
  end
  inherited pmMain: TPopupMenu
    Left = 156
    Top = 193
  end
  inherited dsMain: TDataSource
    DataSet = gdcReportGroup
    Left = 84
    Top = 189
  end
  inherited dsDetail: TDataSource
    DataSet = gdcReport
    Left = 360
    Top = 204
  end
  inherited pmDetail: TPopupMenu
    Left = 400
    Top = 208
  end
  object gdcReportGroup: TgdcReportGroup
    Left = 120
    Top = 192
  end
  object gdcReport: TgdcReport
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'reportgroupkey'
    SubSet = 'ByReportGroup'
    Left = 328
    Top = 200
  end
end
