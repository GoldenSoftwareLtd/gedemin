object dmClientReport: TdmClientReport
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 212
  Top = 101
  Height = 613
  Width = 710
  object IBTransaction1: TIBTransaction
    Active = False
    Params.Strings = (
      'concurrency'
      'nowait')
    AutoStopAction = saNone
    Left = 40
    Top = 72
  end
  object ReportFactory1: TReportFactory
    OnReportEvent = ReportFactory1ReportEvent
    Left = 136
    Top = 16
  end
  object frOLEObject1: TfrOLEObject
    Left = 232
    Top = 264
  end
  object frBarCodeObject1: TfrBarCodeObject
    Left = 40
    Top = 208
  end
  object frChartObject1: TfrChartObject
    Left = 40
    Top = 264
  end
  object frRichObject1: TfrRichObject
    Left = 232
    Top = 152
  end
  object frRoundRectObject1: TfrRoundRectObject
    Left = 136
    Top = 264
  end
  object frCheckBoxObject1: TfrCheckBoxObject
    Left = 232
    Top = 208
  end
  object frShapeObject1: TfrShapeObject
    Left = 136
    Top = 208
  end
  object frDialogControls1: TfrDialogControls
    Left = 136
    Top = 152
  end
  object frDesigner1: TfrDesigner
    CloseQuery = False
    Left = 40
    Top = 152
  end
  object frTextExport: TfrTextExport
    ScaleX = 1
    ScaleY = 1
    Left = 40
    Top = 440
  end
  object ClientReport1: TClientReport
    OnCreateConst = gdScriptFactory1CreateConst
    OnCreateObject = ClientReport1CreateObject
    OnCreateVBClasses = gdScriptFactory1CreateVBClasses
    OnCreateGlobalObj = gdScriptFactory1CreateGlobalObj
    ReportFactory = ReportFactory1
    ShowProgress = True
    ExportType = etNone
    Left = 40
    Top = 16
  end
  object fltGlobalScript1: TfltGlobalScript
    OnCreateObject = ClientReport1CreateObject
    Left = 232
    Top = 16
  end
  object frCrossObject1: TfrCrossObject
    Left = 328
    Top = 264
  end
  object gsFunctionList1: TgsFunctionList
    Left = 136
    Top = 72
  end
  object EventControl1: TEventControl
    OnVarParamEvent = EventControl1VarParamEvent
    OnReturnVarParam = EventControl1ReturnVarParam
    Left = 232
    Top = 72
  end
  object gdScriptFactory1: TgdScriptFactory
    ShowRaise = False
    OnCreateConst = gdScriptFactory1CreateConst
    OnCreateGlobalObj = gdScriptFactory1CreateGlobalObj
    OnCreateObject = ClientReport1CreateObject
    OnCreateVBClasses = gdScriptFactory1CreateVBClasses
    OnIsCreated = gdScriptFactory1IsCreated
    Left = 328
    Top = 16
  end
  object MethodControl1: TMethodControl
    Left = 328
    Top = 72
  end
  object frOLEExcelExport: TfrOLEExcelExport
    HighQuality = False
    CellsAlign = False
    CellsBorders = False
    CellsFillColor = False
    CellsFontColor = False
    CellsFontName = False
    CellsFontSize = False
    CellsFontStyle = False
    CellsMerged = False
    CellsWrapWords = False
    ExportPictures = False
    OpenExcelAfterExport = True
    PageBreaks = False
    AsText = False
    Left = 40
    Top = 368
  end
  object frXMLExcelExport: TfrXMLExcelExport
    OpenExcelAfterExport = True
    Left = 136
    Top = 368
  end
  object frRtfAdvExport: TfrRtfAdvExport
    OpenAfterExport = True
    Wysiwyg = True
    Creator = 'FastReport http://www.fast-report.com'
    Left = 136
    Top = 440
  end
end
