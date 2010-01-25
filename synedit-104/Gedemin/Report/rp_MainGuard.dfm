object ReportGuard: TReportGuard
  OldCreateOrder = False
  DisplayName = 'Gedemin Report Guardian'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Left = 187
  Top = 201
  Height = 480
  Width = 696
  object Timer1: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = Timer1Timer
    Left = 32
    Top = 24
  end
end
