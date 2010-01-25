object gsModem: TgsModem
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Top = 72
  Height = 479
  Width = 741
  object ModemTraceFile: TModemLogFile
    FileName = 'Trace.log'
    Title = 'VML Demo'
    Left = 172
    Top = 68
  end
  object ModemLogFile: TModemLogFile
    FileName = 'Debug.log'
    Title = 'VML Demo'
    Left = 140
    Top = 68
  end
  object ModemPort: TModemPort
    Profile = ModemProfile
    Left = 108
    Top = 68
  end
  object USRobotics: TUSRobotics
    PickPhoneCmd = 'AT#VLS=4A'
    PickPhoneAnsw = 'VCON'
    HangUpCmd = 'ATH0'
    HangUpAnsw = 'OK'
    BeepCmd = 'AT#VTS=[%d,0,%d]'
    BeepAnsw = 'OK'
    BeepTimeUnit = 100
    HardFlowCmd = 'AT'
    HardFlowAnsw = 'OK'
    SoftFlowCmd = 'AT'
    SoftFlowAnsw = 'OK'
    StartPlayCmd = 'ATE0#VTX'
    StartPlayAnsw = 'CONNECT'
    IntrPlayCmd = #16#24
    IntrPlayAnsw = 'OK|VCON'
    StopPlayCmd = #16#3
    StopPlayAnsw = 'OK|VCON'
    StartRecCmd = 'AT#VRX'
    StartRecAnsw = 'CONNECT'
    StopRecCmd = #16
    StopRecAnsw = 'OK|VCON'
    SwitchModeCmd = 'AT#CLS=%s'
    SwitchModeAnsw = 'OK'
    VoiceModeOnCmd = 'AT#CLS=8'
    VoiceModeOnAnsw = 'OK'
    VoiceModeOffCmd = 'AT#CLS=0'
    VoiceModeOffAnsw = 'OK'
    PlayDTMFCmd = 'AT#VTS=%s'
    PlayDTMFExtra = ',%s'
    PlayDTMFAnsw = 'OK'
    Left = 76
    Top = 68
  end
  object ModemProfile: TModemProfile
    Port = 4
    ModemName = 'US Robotics'
    ModemInitAnsw = 'OK'
    ModemLogging = True
    PlayMaxLen = 0
    RecCompression = 1
    RecSilenceLen = 50
    RecSilenceSens = 80
    RecDevice = 2
    RecMaxLen = 0
    BeepLength = 120
    DialMode = 'P'
    Left = 44
    Top = 68
  end
  object VoiceModem: TVoiceModem
    LogFile = ModemLogFile
    Port = ModemPort
    Profile = ModemProfile
    TraceFile = ModemTraceFile
    OnYield = VoiceModemYield
    Left = 12
    Top = 68
  end
  object ApdReceiveFax: TApdReceiveFax
    ComPort = ComPort
    StatusDisplay = ApdFaxStatus
    AbortNoConnect = True
    FaxFileExt = 'APF'
    OnFaxLog = ApdReceiveFaxFaxLog
    OnFaxFinish = ApdReceiveFaxFaxFinish
    OneFax = True
    ConstantStatus = True
    Left = 80
    Top = 16
    FakeProperty = 1
  end
  object ApdFaxStatus: TApdFaxStatus
    Position = poScreenCenter
    Ctl3D = True
    Visible = False
    Fax = ApdReceiveFax
    Caption = 'Fax Status'
    Left = 112
    Top = 16
  end
  object ApdSendFax: TApdSendFax
    FaxClass = fcUnknown
    ComPort = ComPort
    FaxFile = 'c:\default.apf'
    AbortNoConnect = True
    FaxFileExt = 'APF'
    OnFaxFinish = ApdSendFaxFaxFinish
    EnhTextEnabled = False
    EnhHeaderFont.Charset = DEFAULT_CHARSET
    EnhHeaderFont.Color = clWindowText
    EnhHeaderFont.Height = -11
    EnhHeaderFont.Name = 'MS Sans Serif'
    EnhHeaderFont.Style = []
    EnhFont.Charset = DEFAULT_CHARSET
    EnhFont.Color = clWindowText
    EnhFont.Height = -11
    EnhFont.Name = 'MS Sans Serif'
    EnhFont.Style = []
    FaxFileList.Strings = (
      'c:\default.apf')
    DialWait = 30
    DialAttempts = 1
    PhoneNumber = '80'
    Left = 144
    Top = 16
    FakeProperty = 1
  end
  object ComPort: TApdComPort
    InSize = 8192
    OutSize = 8192
    HWFlowOptions = [hwfUseRTS, hwfRequireCTS]
    TraceName = 'APRO.TRC'
    LogName = 'APRO.LOG'
    TapiMode = tmNone
    OnTriggerAvail = ComPortTriggerAvail
    OnTriggerTimer = ComPortTriggerTimer
    Left = 16
    Top = 16
  end
  object ApdModem: TApdModem
    ComPort = ComPort
    InitCmd = 'ATZ^M'
    DialCmd = 'ATDT'
    DialTerm = '^M'
    DialCancel = '^M'
    HangupCmd = '+++~~~ATH0^M'
    ConfigCmd = 'ATE1Q0X1V1^M'
    AnswerCmd = 'ATA^M'
    OkMsg = 'OK'
    ConnectMsg = 'CONNECT'
    BusyMsg = 'BUSY'
    VoiceMsg = 'VOICE'
    NoCarrierMsg = 'NO CARRIER'
    NoDialToneMsg = 'NO DIALTONE'
    ErrorMsg = 'ERROR'
    RingMsg = 'RING'
    LockDTE = True
    Left = 48
    Top = 16
  end
  object RecordTimer: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = RecordTimerTimer
    Left = 203
    Top = 69
  end
end
