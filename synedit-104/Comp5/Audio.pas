// TAudio component for accessing Wavform DEVICES

Unit Audio;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Forms, Classes, mmSystem, syncobjs,dialogs;

const
   DefaultAudioDeviceID = Wave_MAPPER;
   No_Buffers = 4;
   ChannelsDefault = 1;
   BPSDefault = 16;
   SPSDefault = 8000;
   NoSamplesDefault = 8192;
   DefaultMixerDeviceID = 0;

type
  TNotifyAudioRecordEvent = procedure(Sender: TObject; LP,RP: Pointer; BufferSize: Word) of object;
  TNotifyBufferPlayedEvent = procedure(Sender: TObject) of object;
  TNotifyPlayedEvent = procedure(Sender: TObject) of object;
  TNotifyMixerChange = procedure(Sender:TObject;Destination,Source: Word) of object;

  EWaveErr = class(Exception);

  TAudio = class;

  ValuesArray = array [0..1] of integer;
  PMixDetails = ^TMixDetails;
  TMixDetails = record
                 Destination,Source : Word;
                 Name : string;
                 VolControlID,MuteControlID, MeterControlID : dword;
                 Left, Right, Meter : Word;
                 CtrlType : Word;
                 Mute, Mono, Speakers, Available : boolean;
                 Next:PMixDetails;
                end;

  TMixerSettings = class(TPersistent)
  private
    FAudio              : TAudio;
    MixerHandle         : HMIXER;
    MixerStart          : PMixDetails;
    MixerCallbackHandle : HWND;
    FList               : TStrings;
    procedure InitiateControlDetails(var details:TMixerControlDetails;
              ControlID,Channels:dword; pvalues:pointer);
    function GetMixerSettings(MixerDeviceID:integer):boolean;
    procedure MixerCallBack(var Msg:TMessage);
  public
    function GetName(Dest,Source:Word):string;
    procedure SetControl(Dest,Source:Word; LeftVolume,RightVolume:Word; Mute:boolean);
    procedure GetControl(Dest,Source:Word; var LeftVolume,RightVolume:Word; var Mute:boolean; var CtrlType:byte);
    function GetMeter(Dest,Source:Word; var LeftVolume,RightVolume:longint):boolean;
    function GetSources(Dest:Word):TStrings;
    function GetDestinations:TStrings;
    procedure Query(var Product,Formats:string);
  end;

  TAudioSettings = class(TPersistent)
  private
    FAudio               : TAudio;
    pWavHeader           : array [0..No_Buffers-1] of PWaveHDR;
    pWavBuffer           : array [0..No_Buffers-1] of pointer;
    pWavHeader1           : array [0..No_Buffers-1] of PWaveHDR;
    pWavBuffer1           : array [0..No_Buffers-1] of pointer;
    pExtraBuffer         : array [0..No_Buffers-1] of pointer;  {Used to carry Right samples during Split channels}
    ForwardIndex         : Integer;
    ReturnIndex          : Integer;
    ForwardIndex1         : Integer;
    ReturnIndex1          : Integer;
    ActiveBuffers        : Integer;
    DeviceOpen           : Boolean;
//    DeviceOpen1           : Boolean;
    FNoSamples           : Word;
    WavFmt               : tWaveFormatEx;
    WavBufSize           : Word;
    FSplit               : Boolean;
    FileHMM              : hmmio; //mmio-File handle
    ckriff,ckdata        : tmmckinfo;//riff and data chunks info for mmio-file
    procedure SetChannels(Value:Word);
    procedure SetBPS(Value:Word);
    procedure SetSPS(Value:dWord);
    procedure SetSplit(Value:Boolean);
    procedure InitWavHeaders;
    procedure InitWavHeaders1;
    procedure AllocateMemory;
    procedure AllocateMemory1;
    procedure FreeMemory;
    procedure FreeMemory1;
  public
    Active               : Boolean;
    Active1               : Boolean;
    EndBufEv             : TEvent;
    EndWorkEv            : TEvent;
    EndBufEv1             : TEvent;
    EndWorkEv1            : TEvent;
  published
    property BitsPerSample: word read Wavfmt.wBitsPerSample write SetBPS default BPSDefault;
    property Channels: word read Wavfmt.nChannels write SetChannels default ChannelsDefault;
    property SampleRate: dWord read Wavfmt.nSamplesPerSec write SetSPS default SPSDefault;
    property SplitChannels: Boolean read FSplit write SetSplit default false;
  end;

  PRecorder = ^TRecorder;
  TRecorder = class(TAudioSettings)
  private
    WavIn                    : HWaveIN;
    FPause                   : Boolean;
    FTrigLevel               : Word;
    FTriggered               : Boolean;
    AddNextInBufferHandle    : hWnd;
    lstream,rstream          : TmemoryStream;
    procedure AddNextInBuffer2(var Msg: TMessage);
    function AddNextInBuffer: Boolean;
    procedure SetTrigLevel(Value:Word);
    function TestTrigger(StartPtr:pointer; Size:Word):boolean;
    procedure Split(var LP,RP:pointer; var Size:Word);
    procedure GetError(iErr : Integer; Additional:string);
    procedure SetNoSamples(Value:Word);
    procedure Open;
    procedure Close;
    procedure CallBack(uMsg1,dwInstance,dwParam1,dwParam2 : DWORD);  stdcall;
  public
    procedure Start(LP,RP:TmemoryStream);
    procedure Stop;
    procedure Pause;
    procedure Restart;
    procedure RecordToFile(FileName,comment:string; LP,RP:TmemoryStream);
  published
    property NoSamples: Word read FNoSamples write SetNoSamples default NoSamplesDefault;
    property TrigLevel: Word read FTrigLevel write SetTrigLevel default 128;
    property Triggered: Boolean read FTriggered write FTriggered default true;
  end;

  PPlayer = ^TPlayer;
  TPlayer = class(TAudioSettings)
  private
    WavOut                : HWaveIN;
    FNoOfRepeats           : Word;
    ReadPlayStreamPos      : LongInt;
    PlayStream             : TStream;
    FinishedPlaying         : boolean;
    AddNextOutBufferHandle  : hWnd;
    CloseHandle             : hWnd;
    procedure AddNextOutBuffer2(var Msg: TMessage);
    procedure Close2(var Msg: TMessage);
    procedure Open;
    procedure GetError(iErr : Integer; Additional:string);
    function AddNextOutBuffer:longint;
    procedure CallBack(uMsg,dwInstance,dwParam1,dwParam2 : DWORD);  stdcall;
  public
    procedure SetVolume(LeftVolume,RightVolume:Word);
    procedure GetVolume(var LeftVolume,RightVolume:Word);
    procedure Play(LP,RP:TStream; NoOfRepeats:Word);
    procedure Stop;
    procedure Pause;
    procedure Reset;
    procedure Restart;
    procedure BreakLoop;
    procedure FileOpen(FileName:string);
    procedure FileClose;
    procedure FileLoad(FileName:string; LP,RP:TmemoryStream);
    procedure FilePlay(FileName:string; NoOfRepeats:Word);
  published
  end;

  TAudio = class(TComponent)
  private
    FDeviceID            : Integer;
    FSepCtrl             : Boolean;
    FOnAudioRecord       : TNotifyAudioRecordEvent;
    FRecorder            : TRecorder;
    FOnBufferPlayed      : TNotifyBufferPlayedEvent;
    FOnPlayed            : TNotifyPlayedEvent;
    FPlayer              : TPlayer;
    FMixerDeviceID       : Integer;
    FOnMixerChange       : TNotifyMixerChange;
    procedure SetDeviceID(Value:Integer);
    procedure SetMixerDeviceID(Value:Integer);
   public
    Mixer                : TMixerSettings;
    MixerPresent         : boolean;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Query(var Product,Formats:string);
  published
    property AudioDeviceID: Integer read FDeviceID write SetDeviceID default DefaultAudioDeviceID;
    property MixerDeviceID: Integer read FMixerDeviceID write SetMixerDeviceID default DefaultMixerDeviceID;
    property SeparateCtrls: Boolean read FSepCtrl write FSepCtrl default false;
    property Player: TPlayer read FPlayer write FPlayer;
    property Recorder: TRecorder read FRecorder write FRecorder;
    property OnRecord: TNotifyAudioRecordEvent read FOnAudioRecord write FOnAudioRecord;
    property OnBufferPlayed: TNotifyBufferPlayedEvent read FOnBufferPlayed write FOnBufferPlayed;
    property OnPlayed: TNotifyPlayedEvent read FOnPlayed write FOnPlayed;
    property OnMixerChange:TNotifyMixerChange read FOnMixerChange write FOnMixerChange;
  end;
  procedure Register;

implementation
const
fourcc_wave=$45564157; fourcc_fmt=$20746d66;  fourcc_isft=$54465349;
fourcc_data=$61746164; fourcc_info=$4f464e49;
recerr='File recording error';

{------------- Internal/Private routines -------------------------------}
procedure TAudioSettings.InitWavHeaders;
var i : Integer;
begin
  for i:=0 to No_Buffers-1 do begin
    pWavHeader[i]^.lpData:=pWavBuffer[i];
    pWavHeader[i]^.dwBufferLength:=WavBufSize;
    pWavHeader[i]^.dwBytesRecorded:=0;
    pWavHeader[i]^.dwUser:=0;
    pWavHeader[i]^.dwFlags:=0;
    pWavHeader[i]^.dwLoops:=0;
    pWavHeader[i]^.lpNext:=nil;
    pWavHeader[i]^.reserved:=0;
  end;
end;

procedure TAudioSettings.InitWavHeaders1;
var i : Integer;
begin
  for i:=0 to No_Buffers-1 do begin
    pWavHeader1[i]^.lpData:=pWavBuffer1[i];
    pWavHeader1[i]^.dwBufferLength:=WavBufSize;
    pWavHeader1[i]^.dwBytesRecorded:=0;
    pWavHeader1[i]^.dwUser:=0;
    pWavHeader1[i]^.dwFlags:=0;
    pWavHeader1[i]^.dwLoops:=0;
    pWavHeader1[i]^.lpNext:=nil;
    pWavHeader1[i]^.reserved:=0;
  end;
end;

procedure TAudioSettings.AllocateMemory;
var  i : Integer;
begin
    with WavFmt do begin
      if ((nChannels<>1)and(nChannels<>2))or((wBitsPerSample<>8)and(wBitsPerSample<>16)) then
         raise EWaveErr.create('Bad wav-format');
      cbSize:=0;
      wFormatTag:=Wave_FORMAT_PCM;
      nBlockAlign:=nChannels*wBitsPerSample div 8;
      nAvgBytesPerSec:=nSamplesPerSec*nBlockAlign;
      WavBufSize:=FNoSamples*nBlockAlign;
      SetSplit(FSplit);
    end;
    for i:=0 to No_Buffers-1 do begin
      pWavHeader[i]:=nil;
      try
        GetMem(pWavHeader[i],sizeof(TWaveHDR));
      except raise EWaveErr.create('Not enough memory to allocate WaveHeader'); end;
      pWavBuffer[i]:=nil;
      pExtraBuffer[i]:=nil;
      try
        GetMem(pWavBuffer[i],WavBufSize);
        GetMem(pExtraBuffer[i],(WavBufSize div 2));
      except raise EWaveErr.create('Not enough memory to allocate Wave Buffer'); end;
      pWavHeader[i]^.lpData:=pWavBuffer[i];
    end;

end;

procedure TAudioSettings.AllocateMemory1;
var  i : Integer;
begin
    with WavFmt do begin
      if ((nChannels<>1)and(nChannels<>2))or((wBitsPerSample<>8)and(wBitsPerSample<>16)) then
         raise EWaveErr.create('Bad wav-format');
      cbSize:=0;
      wFormatTag:=Wave_FORMAT_PCM;
      nBlockAlign:=nChannels*wBitsPerSample div 8;
      nAvgBytesPerSec:=nSamplesPerSec*nBlockAlign;
      WavBufSize:=FNoSamples*nBlockAlign;
      SetSplit(FSplit);
    end;
    for i:=0 to No_Buffers-1 do begin
      pWavHeader1[i]:=nil;
      try
        GetMem(pWavHeader1[i],sizeof(TWaveHDR));
      except raise EWaveErr.create('Not enough memory to allocate WaveHeader'); end;
      pWavBuffer1[i]:=nil;
      //pExtraBuffer[i]:=nil;
      try
        GetMem(pWavBuffer1[i],WavBufSize);
        //GetMem(pExtraBuffer[i],(WavBufSize div 2));
      except raise EWaveErr.create('Not enough memory to allocate Wave Buffer'); end;
      pWavHeader1[i]^.lpData:=pWavBuffer1[i];
    end;
end;

procedure TAudioSettings.FreeMemory;
var i : Integer;
begin
  for i:=0 to No_Buffers-1 do begin
    if (pWavBuffer[i]<>nil) then FreeMem(pWavBuffer[i]);
    pWavBuffer[i]:=nil;
    if (pExtraBuffer[i]<>nil) then FreeMem(pExtraBuffer[i]);
    pExtraBuffer[i]:=nil;
    if (pWavHeader[i]<>nil) then FreeMem(pWavHeader[i]);
    pWavHeader[i]:=nil;
  end;
end;

procedure TAudioSettings.FreeMemory1;
var i : Integer;
begin
  for i:=0 to No_Buffers-1 do begin
    if (pWavBuffer1[i]<>nil) then FreeMem(pWavBuffer1[i]);
    pWavBuffer1[i]:=nil;
    if (pWavHeader1[i]<>nil) then FreeMem(pWavHeader1[i]);
    pWavHeader1[i]:=nil;
  end;
end;


function TRecorder.TestTrigger(StartPtr:pointer; Size:Word):boolean;
var i : longint;
    j :boolean;
    k : Word;
begin
  if not(FTriggered) and (Size>0) then begin
    j:=FTriggered;
    i:=Size;
    k:=FTrigLevel;
    if Wavfmt.wBitsPerSample=8 then begin
asm
    mov eax,StartPtr
    mov ecx,i
    mov edx,0
@trig8:
    mov dl,[eax]
    cmp dx,k
    jge @out8
    add eax,1
    pop ecx
    loop @trig8
    jmp @out88
@out8:
    mov j,1
@out88:
end;
    end else begin
asm
    mov eax,StartPtr
    mov ecx,i
    shr ecx,1
    mov edx,0
@trig16:
    mov dx,[eax]
    cmp dx,k
    jge @out16
    add eax,2
    loop @trig16
    jmp @out16a
@out16:
    mov j,1
@out16a:
end;
    end;
    FTriggered:=j;
  end;
  Result:=FTriggered;
end;

procedure TRecorder.Split(var LP,RP:pointer; var Size:Word);
var i : longint;
    lb,rb,pb : ^byte;
begin
 if (Size>0) then begin
  Size:=Size div 2;
  lb:=LP; rb:=RP;
  pb:=LP;
  i:=Size;
  if WavFmt.wBitsPerSample=8 then begin
asm
    mov eax,lb
    mov ecx,i
    mov edx,rb
@split8:
    push ecx
    mov ecx,pb
    mov cx,[ecx]
    mov [eax],cl
    mov [edx],ch
    add dword ptr [pb],2
    add eax,1
    add edx,1
    pop ecx
    loop @split8
end;
  end else begin
asm
    mov eax,lb
    mov ecx,i
    shr ecx,1
    mov edx,rb
@split16:
    push ecx
    mov ecx,pb
    mov ecx,[ecx]
    mov [eax],cx
    shr ecx,16
    mov [edx],cx
    add dword ptr [pb],4
    add eax,2
    add edx,2
    pop ecx
    loop @split16
end;
  end;
 end;
end;

procedure TRecorder.AddNextInBuffer2(var Msg: TMessage);
begin if (Msg.Msg=wim_DATA) and DeviceOpen then AddNextInBuffer; end;

function TRecorder.AddNextInBuffer: Boolean;
var iErr : Integer;
begin
   iErr:=WaveInAddBuffer(WavIn, pWavheader1[ForwardIndex1], sizeof(TWaveHDR));
   if (iErr<>0) then begin
       Stop;
       GetError(iErr,'Error adding input buffer');
       Result:=false;
       Exit;
   end;
   ForwardIndex1:=(ForwardIndex1+1) mod No_Buffers;
   Result:=true;
end;

procedure TRecorder.GetError(iErr : Integer; Additional:string);
var ErrorText : string;
    pError : PChar;
begin
  GetMem(pError,256);
  WaveInGetErrorText(iErr,pError,255);
  ErrorText:=StrPas(pError);
  FreeMem(pError,256);
  if length(ErrorText)=0 then raise EWaveErr.create(Additional)
  else raise EWaveErr.create(Additional+' '+ErrorText);
end;

procedure TPlayer.AddNextOutBuffer2(var Msg: TMessage);
begin if (Msg.Msg=wom_DONE) and DeviceOpen then AddNextOutBuffer; end;

function TPlayer.AddNextOutBuffer:longint;
var  iErr:integer;   WritePos:Longint;
begin
 { if (ActiveBuffers = 0) and (PlayStream.Position > 12000) then
  begin
    stop;
    exit;
  end;   {}
FinishedPlaying:=false; Result:=0;
if (PlayStream<>nil) then
 begin
 WritePos:=PlayStream.Position; PlayStream.Position:=ReadPlayStreamPos;
 Result:=PlayStream.Read(pWavheader[ForwardIndex]^.lpData^,WavBufSize);
 if (Result=0) and (FNoOfRepeats>0) then
  begin
  dec(FNoOfRepeats,1);  PlayStream.Position:=0;
  Result:=PlayStream.Read(pWavheader[ForwardIndex]^.lpData^,WavBufSize);
  end;
 ReadPlayStreamPos:=PlayStream.Position; PlayStream.Position:=WritePos;
 if Result=0 then begin  PlayStream.Free; PlayStream:=nil; exit; end;
 end;
if FileHMM<>0 then
 begin
 if ReadPlayStreamPos>ckdata.cksize-1 then
  if FNoOfRepeats>0 then
   begin
   dec(FNoOfRepeats,1); ReadPlayStreamPos:=0;
   mmioseek(FileHMM,ckdata.dwDataOffset,seek_set);
   end
                    else begin FileClose; exit; end;
 if ckdata.cksize-ReadPlayStreamPos>WavBufSize then WritePos:=WavBufSize
                                               else WritePos:=ckdata.cksize-ReadPlayStreamPos;
 Result:=mmioread(FileHMM,pWavheader[ForwardIndex]^.lpData,WritePos);
 if Result<>WritePos then  begin FileClose;
  raise EWaveErr.create('Error wav-file reading'); end;
 ReadPlayStreamPos:=ReadPlayStreamPos+Result;
 end;
if Result>0 then
 begin
 pWavheader[ForwardIndex]^.dwBufferLength:=Result;
 pWavheader[ForwardIndex]^.dwFlags:=0;
 pWavheader[ForwardIndex]^.dwLoops:=0;
 iErr:=WaveOutPrepareHeader(WavOut,pWavHeader[ForwardIndex],sizeof(TWaveHDR));
 if iErr<>0 then
 GetError(iErr,'');
 iErr:=WaveOutWrite(WavOut, pWavheader[ForwardIndex], sizeof(TWaveHDR));
 if iErr<>0 then
 GetError(iErr,'');
 ForwardIndex:=(ForwardIndex+1) mod No_Buffers; inc(ActiveBuffers);
 end;
end;

procedure TPlayer.GetError(iErr : Integer; Additional:string);
var ErrorText : string;
    pError : PChar;
begin
  GetMem(pError,256);
  WaveOutGetErrorText(iErr,pError,255);
  ErrorText:=StrPas(pError);
  FreeMem(pError,256);
  if length(ErrorText)=0 then raise EWaveErr.create(Additional)
  else raise EWaveErr.create(Additional+' '+ErrorText);
end;

procedure TMixerSettings.InitiateControlDetails(var details:TMixerControlDetails;
              ControlID,Channels:dword; pvalues:pointer);
begin
 details.cbStruct := sizeof (details);
 details.dwControlID := ControlID;
 details.cChannels := Channels;
 details.cMultipleItems := 0;
 details.cbDetails := sizeof (integer);
 details.paDetails := pvalues;
end;

procedure TMixerSettings.SetControl(Dest,Source:Word; LeftVolume,RightVolume:Word; Mute:boolean);
var P:PMixDetails;
    err : integer;
    values : ValuesArray;
    details : TMixerControlDetails;
begin
  P:=MixerStart;
  while (P<>nil) do begin
    if ((P^.Destination=Dest) and (P^.Source=Source)) then begin
      if P^.VolControlID<65535 then begin
        if P^.Mono then begin
          InitiateControlDetails(details,P^.VolControlID,1,@values);
        end else begin
          InitiateControlDetails(details,P^.VolControlID,2,@values);
        end;
        values[0]:= LeftVolume;
        values[1]:= RightVolume;
        err := mixerSetControlDetails (MixerHandle, @details, MIXER_SETCONTROLDETAILSF_VALUE);
        if err<>MMSYSERR_NOERROR then raise EWaveErr.create('Volume SetControlError in Mixer');
      end;
      if P^.MuteControlID<65535 then begin
        InitiateControlDetails(details,P^.MuteControlID,1,@values);
        if Mute then values[0]:= 1
        else values[0]:=0;
        err := mixerSetControlDetails (MixerHandle, @details, MIXER_SETCONTROLDETAILSF_VALUE);
        if err<>MMSYSERR_NOERROR then raise EWaveErr.create('Mute SetControlError in Mixer');
      end;
      Exit;
    end;
    P:=P^.Next;
  end;
end;

procedure TMixerSettings.GetControl(Dest,Source:Word; var LeftVolume,RightVolume:Word;
                                   var Mute:boolean; var CtrlType:byte);
var P:PMixDetails;
    err : integer;
    values : ValuesArray;
    details : TMixerControlDetails;
begin
  P:=MixerStart;
  while (P<>nil) do begin
    if ((P^.Destination=Dest) and (P^.Source=Source)) then begin
      CtrlType:=byte(P^.CtrlType);
      if P^.Mono then InitiateControlDetails(details,P^.VolControlID,1,@values)
      else InitiateControlDetails(details,P^.VolControlID,2,@values);
      err := mixerGetControlDetails (MixerHandle, @details, MIXER_GETCONTROLDETAILSF_VALUE);
      if err<>MMSYSERR_NOERROR then raise EWaveErr.create('Volume GetControlError in Mixer');
      LeftVolume:=values[0];
      if P^.Mono then RightVolume:=LeftVolume
      else RightVolume:=values[1];
       InitiateControlDetails(details,P^.MuteControlID,1,@values);
      err := mixerGetControlDetails (MixerHandle, @details, MIXER_GETCONTROLDETAILSF_VALUE);
      if err<>MMSYSERR_NOERROR then raise EWaveErr.create('Mute GetControlError in Mixer');
      if values[0]=0 then Mute:=false
      else Mute:=true;
      Exit;
    end;
    P:=P^.Next;
  end;
end;

function TMixerSettings.GetMeter(Dest,Source:Word; var LeftVolume,RightVolume:longint):boolean;
var P:PMixDetails;
    err : integer;
    values, val2: PMIXERCONTROLDETAILSSIGNED;
    details : TMixerControlDetails;
begin
  Result:=false;  P:=MixerStart;
  while (P<>nil) do begin
    if ((P^.Destination=Dest) and (P^.Source=Source) and (P^.Meter>0)) then begin
      GetMem(values, 2*SizeOf(TMIXERCONTROLDETAILSSIGNED));
      InitiateControlDetails(details,P^.MeterControlID,P^.Meter,values);
      err := mixerGetControlDetails (MixerHandle, @details, MIXER_GETCONTROLDETAILSF_VALUE);
      if err<>MMSYSERR_NOERROR then exit;
      val2:=values;
      LeftVolume:=val2^.lValue;
      if P^.Meter=1 then RightVolume:=LeftVolume
      else begin
        inc(val2);
        RightVolume:=val2^.lValue;
      end;
      Result:=true;
      FreeMem(values, 2*SizeOf(TMIXERCONTROLDETAILSSIGNED));
      Exit;
    end;
    P:=P^.Next;
  end;
end;

function TMixerSettings.GetName(Dest,Source:Word):string;
var P:PMixDetails;
begin
  Result:='';   P:=MixerStart;
  while (P<>nil) do begin
    if ((P^.Destination=Dest) and (P^.Source=Source)) then begin
      Result:=P^.Name;
      Exit;
    end;
    P:=P^.Next;
  end;
end;

function TMixerSettings.GetSources(Dest:Word):TStrings;
var P:PMixDetails;
begin
  P:=MixerStart;  FList.Clear;
  while P<>nil do begin
    if (P^.Destination=Dest) then begin
      if P^.Available then FList.Insert(P^.Source,P^.Name)
      else FList.Insert(P^.Source,'');
    end;
    P:=P^.Next;
  end;
  Result:=FList;
end;

function TMixerSettings.GetDestinations:TStrings;
var P:PMixDetails;
begin
  P:=MixerStart; FList.Clear;
  while P<>nil do begin
    if (P^.Source=0) then FList.Insert(P^.Destination,P^.Name);
    P:=P^.Next;
  end;
  Result:=FList;
end;

procedure TMixerSettings.Query(var Product,Formats:string);
var PMix : PMixDetails;
    i : integer;
begin
  Product:=''; Formats:='';
  if (mixerGetNumDevs=0) then begin
    Formats:='Mixer not present';
  end else begin
    PMix:=MixerStart;
    if PMix<>nil then Product:=PMix.Name;
    Formats:='Mixer devices present: '+IntToStr(mixerGetNumDevs)+'. DeviceID '+
             IntToStr(FAudio.FMixerDeviceID)+' has:';
    i:=0; PMix:=PMix^.Next;
    while PMix<>nil do begin
      if (PMix.Destination=i) then begin
        Formats:=Formats+#13#10+PMix.Name+': ';
        i:=i+1;
      end else begin
        Formats:=Formats+PMix.Name+', ';
      end;
      PMix:=PMix^.Next;
    end;
  end;
end;

procedure TMixerSettings.MixerCallBack(var Msg:TMessage);
var P : PMixDetails;
    Found : boolean;
begin
{  if (Msg.Msg = MM_MIXM_CONTROL_CHANGE) then begin
    if (Assigned(FAudio.OnMixerChange)) then begin
      FAudio.OnMixerChange(Self,word(Msg.wParam),word(Msg.lParam));
      Found:=false;
      P:=MixerStart;
      while (P<>nil) and not(Found) do begin
        if (P^.VolControlID=Msg.lParam) or (P^.MuteControlID=Msg.lParam) then begin
          Found:=true;
          FAudio.OnMixerChange(Self,P^.Destination,P^.Source);
        end;
        P:=P^.Next;
      end;
    end;
  end; {}
end;

function TMixerSettings.GetMixerSettings(MixerDeviceID:integer):boolean;
var j, k, err : Integer;
    caps : TMixerCaps;
    lineInfo, connectionInfo : TMixerLine;
    mixerLineControls : TMixerLineControls;
    PMix : PMixDetails;
    Data : ValuesArray;
    speakers : boolean;

procedure UpdateLinkedList(Update:Word; var P:PMixDetails; Destination, Source : Word; Name : string;
                           ControlID : dword; Data : ValuesArray; Mono, Speakers:boolean);
var   TempDest,TempSource : word;
begin
 case Update of
  0 : begin
        new(P);
        P^.Next:=nil; P^.Available:=false; P^.Mono:=false;
        P^.Destination:=65535;
        P^.Source:=65535;
        P^.Name:=Name;
        P^.Speakers:=Speakers;
        P^.VolControlID:=65535; P^.Left:=0; P^.Right:=0;
        P^.MuteControlID:=65535; P^.Mute:=false;
        P^.MeterControlID:=65535; P^.Meter:=0;
        P^.CtrlType:=0;
      end;
  1 : begin
        TempDest:=P^.Destination; TempSource:=P^.Source;
        new(P^.Next); P:=P^.Next;
        P^.Next:=nil; P^.Available:=false; P^.Mono:=false;
        if (Destination<>TempDest) then begin
          TempDest:=Destination;
          TempSource:=0;
        end else TempSource:=(TempSource+1) mod 65536;
        P^.Destination:=TempDest; P^.Source:=TempSource;
        P^.Name:=Name;
        P^.Speakers:=Speakers;
        P^.VolControlID:=65535; P^.Left:=0; P^.Right:=0;
        P^.MuteControlID:=65535; P^.Mute:=false;
        P^.MeterControlID:=65535; P^.Meter:=0;
        P^.CtrlType:=128;
      end;
  2 : begin
       if P^.MuteControlID=65535 then begin
         P^.MuteControlID:=ControlID;
         if Data[0]=0 then P^.Mute:=false
         else P^.Mute:=true;
         P^.Available:=true;
         P^.CtrlType:=(P^.CtrlType and 127);
       end;
      end;
  3 : begin
       P^.VolControlID:=ControlID;
       P^.Left:=Data[0];
       if Mono then begin
         P^.Mono:=true;
         P^.CtrlType:=P^.CtrlType+64;
       end else P^.Right:=Data[1];
       P^.Available:=true;
      end;
  4 : begin
       P^.MeterControlID:=ControlID;
       if Mono then P^.Meter:=1
       else P^.Meter:=2;
      end;
 end;
end;

function GetControl(MixLine:TMixerLine; speakers:boolean):boolean;
var err,j:integer;
  p, controls : PMixerControl;
  details : TMixerControlDetails;
  values : ValuesArray;
begin
   UpdateLinkedList(1,PMix,word(MixLine.dwDestination),word(MixLine.dwSource),
      StrPas(MixLine.szName),word(MixLine.dwComponentType),Data,false,speakers);
   mixerLineControls.cbStruct := sizeof (mixerLineControls);
   mixerLineControls.dwLineID := MixLine.dwLineID;
   mixerLineControls.cControls := MixLine.cControls;
   mixerLineControls.cbmxctrl := sizeof (TMixerControl);
   if MixLine.cControls>0 then begin
     GetMem (controls, sizeof (TMixerControl) * MixLine.cControls);
     mixerLineControls.pamxctrl := controls;
     err:=mixerGetLineControls (MixerHandle, @mixerLineControls, MIXER_GETLINECONTROLSF_ALL);
     if  err=MMSYSERR_NOERROR then begin
       p := controls;
       for j := 0 to mixerLineControls.cControls - 1 do begin
         if (p^.dwControlType=MIXERCONTROL_CONTROLTYPE_VOLUME) then begin
            InitiateControlDetails(details,p^.dwControlID,MixLine.cChannels,@values);
            if mixerGetControlDetails (MixerHandle, @details, MIXER_GETCONTROLDETAILSF_VALUE) = MMSYSERR_NOERROR then
              UpdateLinkedList(3,PMix,0,0,'',details.dwControlID,values,(MixLine.cChannels=1),speakers);
         end else begin
           if (p^.dwControlType=MIXERCONTROL_CONTROLTYPE_MUTE) then begin
            InitiateControlDetails(details,p^.dwControlID,1,@values);
            if mixerGetControlDetails (MixerHandle, @details, MIXER_GETCONTROLDETAILSF_VALUE) = MMSYSERR_NOERROR then
              UpdateLinkedList(2,PMix,0,0,'',details.dwControlID,values,false,speakers);
           end else begin
              if (p^.dwControlType=MIXERCONTROL_CONTROLTYPE_PEAKMETER) then begin
                InitiateControlDetails(details,p^.dwControlID,MixLine.cChannels,@values);
                if mixerGetControlDetails (MixerHandle, @details, MIXER_GETCONTROLDETAILSF_VALUE) = MMSYSERR_NOERROR then
                  UpdateLinkedList(4,PMix,0,0,'',details.dwControlID,values,(MixLine.cChannels=1),speakers);
              end;
           end;
         end;
         Inc (p);
       end;
       Result:=true;
     end else Result:=false;
     FreeMem (controls);
   end else Result:=true;
end;

begin
  Result:=false; MixerStart:=nil;
{  if mixerGetNumDevs=0 then exit
                       else begin
{
    If mixerOpen (@FMixerHandle,Value,XWndHandle,0,CALLBACK_WINDOW OR MIXER_OBJECTF_MIXER)=MMSYSERR_NOERROR then
}
 {   MixerGetDevCaps (MixerDeviceID, @caps, sizeof (caps));
    err:= mixerOpen (@MixerHandle, MixerDeviceID, MixerCallbackHandle, 0, CALLBACK_WINDOW OR MIXER_OBJECTF_MIXER);
{    err:= mixerOpen (@MixerHandle, MixerDeviceID, 0, 0, MIXER_OBJECTF_MIXER);  }
 {   if err = MMSYSERR_NOERROR then begin
      UpdateLinkedList(0,MixerStart,word(-1),word(-2),StrPas(caps.szPname),0,Data,false,false);
      PMix:=MixerStart;
        for j := 0 to caps.cDestinations - 1 do begin
          lineInfo.cbStruct := sizeof (lineInfo);
          lineInfo.dwDestination := j;
          Result:=false;
          err:=mixerGetLineInfo (MixerHandle, @lineInfo, MIXER_GETLINEINFOF_DESTINATION);
          if err = MMSYSERR_NOERROR then begin
            speakers:=(lineInfo.dwComponentType=MIXERLINE_COMPONENTTYPE_DST_SPEAKERS);
            GetControl(lineInfo,speakers);
            for k := 0 to lineInfo.cConnections - 1 do begin
              connectionInfo.cbStruct := sizeof (connectionInfo);
              connectionInfo.dwDestination := j;
              connectionInfo.dwSource := k;
              Result:=false;
              err:=mixerGetLineInfo (MixerHandle, @connectionInfo, MIXER_GETLINEINFOF_SOURCE);
              if err = MMSYSERR_NOERROR then GetControl(connectionInfo,speakers)
              else exit;
            end;
            Result:=true;
          end else exit;
        end;
    end;
  end;
}end;

{------------- Public methods ---------------------------------------}
constructor TAudio.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
FDeviceID:=DefaultAudioDeviceID; FSepCtrl:=false;
FPlayer:=TPlayer.Create; FRecorder:=TRecorder.Create;
with FPlayer do
 begin
 FAudio:=Self; Active:=false; FNoSamples:=NoSamplesDefault;
 EndBufEv:=tevent.Create(nil,false,true,'PlayEndBuf');
 EndWorkEv:=tevent.Create(nil,false,true,'PlayEndWork');
 WavFmt.wBitsPerSample:=BPSDefault;
 WavFmt.nChannels:=ChannelsDefault;
 WavFmt.nSamplesPerSec:=SPSDefault;
 PlayStream:=nil; ActiveBuffers:=0;
 AddNextOutBufferHandle:=AllocateHWnd(AddNextOutBuffer2);
 CloseHandle:=AllocateHWnd(Close2);
 if (WaveOutGetNumDevs>0) then AllocateMemory;
 end;
with FRecorder do
 begin
 FAudio:=Self; Active1:=false; FNoSamples:=NoSamplesDefault;
 EndBufEv1:=tevent.Create(nil,false,true,'RecEndBuf');
 EndWorkEv1:=tevent.Create(nil,false,true,'RecEndWork');
 WavFmt.wBitsPerSample:=BPSDefault;
 WavFmt.nChannels:=ChannelsDefault;
 WavFmt.nSamplesPerSec:=SPSDefault;
 AddNextInBufferHandle:= AllocateHWnd(AddNextInBuffer2);
 FileHMM:=0; lstream:=nil; rstream:=nil;
 if (WaveInGetNumDevs>0) then AllocateMemory1;
 end;
FMixerDeviceID:=DefaultMixerDeviceID;
Mixer:=TMixerSettings.Create;
with Mixer do
 begin
 FAudio:=Self; FList:=TStringList.Create;
 MixerCallbackHandle:=AllocateHWnd(MixerCallback);
 MixerPresent:=GetMixerSettings(FMixerDeviceID);
 end;
end;

destructor TAudio.Destroy;
var P1,P2 :PMixDetails;
begin
   FPlayer.Stop;
   FRecorder.Stop;
   Mixer.FList.Free;
   if Mixer.MixerStart<>nil then mixerClose(Mixer.MixerHandle);
   P1:=Mixer.MixerStart;
   while P1<>nil do begin
     P2:=P1.Next;
     Dispose(P1);
     P1:=P2;
   end;
  with Mixer do if MixerCallbackHandle<>0 then
   begin DeAllocateHwnd(MixerCallbackHandle); MixerCallbackHandle:=0; end;
  with FRecorder do begin
   if (FileHMM<>0) then
    begin
    mmioAscend(FileHMM,@ckriff,0); mmioAscend(FileHMM,@ckdata,0);
    if mmioclose(FileHMM,0)<>MMSYSERR_NOERROR then
     begin FileHMM:=0; raise EWaveErr.create(recerr); end;
    FileHMM:=0;
    end;
   Close;
   if AddNextInBufferHandle<>0 then
    begin DeallocateHwnd(AddNextInBufferHandle); AddNextInBufferHandle:=0; end;
   FreeMemory1;   EndBufEv1.Free;   EndWorkEv1.Free;   Free;
  end;
  with FPlayer do
   begin
   if AddNextOutBufferHandle<>0 then
    begin DeallocateHwnd(AddNextOutBufferHandle); AddNextOutBufferHandle:=0; end;
   if CloseHandle<>0 then begin DeallocateHWnd(CloseHandle); CloseHandle:=0; end;
   FreeMemory;  EndBufEv.Free;   EndWorkEv.Free;   Free;
   end;
  inherited Destroy;
end;

procedure TAudio.Query(var Product,Formats:string);
var Caps : PWaveOutCaps;
    i1,i2,j1,j2 : Word;
    iErr : Integer; isExcept:boolean;
begin
  Product:=''; Formats:='';
  if (WaveInGetNumDevs<=FDeviceID) or (WaveOutGetNumDevs<=FDeviceID) then
    raise EWaveErr.create('No Waveform device available')
   else begin
    GetMem(Caps,SizeOf(TWaveOutCaps));
    iErr:=WaveOutGetDevCaps(FDeviceID,Caps,SizeOf(TWaveOutCaps));
    if (iErr<>0) then begin
      FPlayer.GetError(iErr,'');
      Exit;
    end else begin
      Product:=StrPas(Caps^.szPname);
      Formats:='';
      if ((Caps^.dwFormats and Wave_FORMAT_1M08)>0) then Formats:='11.025';
      if ((Caps^.dwFormats and Wave_FORMAT_2M08)>0) then Formats:=Formats+'/22.05';
      if ((Caps^.dwFormats and Wave_FORMAT_1M08)>0) then Formats:=Formats+'/44.1';
      Formats:=Formats+' kHz, ';
      if ((Caps^.dwFormats and Wave_FORMAT_1M08)>0) then Formats:=Formats+'Mono';
      if ((Caps^.dwFormats and Wave_FORMAT_1S08)>0) then Formats:=Formats+'/Stereo';
      if ((Caps^.dwFormats and Wave_FORMAT_1M08)>0) then Formats:=Formats+', 8';
      if ((Caps^.dwFormats and Wave_FORMAT_1M16)>0) then Formats:=Formats+'/16';
      Formats:=Formats+'-bit, Playback Controls: ';
      if ((Caps^.dwSupport and WaveCAPS_LRVOLUME)>0) then Formats:=Formats+'Separate L/R Volume'
      else if ((Caps^.dwSupport and WaveCAPS_VOLUME)>0) then Formats:=Formats+'Volume';
      FPlayer.GetVolume(i1,i2);
      FPlayer.SetVolume((i1+10) mod 65535,(i2+10) mod 65535);
      FPlayer.GetVolume(j1,j2);
      FPlayer.SetVolume(i1,i2);
      if not((j1=((i1+10) mod 65535)) and (j2=((i2+10) mod 65535))) then
        Formats:=Formats+' (not controllable with this DeviceID driver)';
      if ((Caps^.dwSupport and WaveCAPS_PITCH)>0) then Formats:=Formats+', Pitch';
      if ((Caps^.dwSupport and WaveCAPS_PLAYBACKRATE)>0) then Formats:=Formats+', Rate';
      if ((Caps^.dwSupport and WaveCAPS_SYNC)>0) then Formats:=Formats+', Synchronous Device';
      FRecorder.FPause:=true;  FRecorder.Close;
      isExcept:=false;
      try FPlayer.Open; FRecorder.Open;
      except on EWaveErr do       begin Formats:='Half-duplex support, '+Formats; isExcept:=true; end; end;      if not(isExcept) then if (FPlayer.DeviceOpen and FRecorder.DeviceOpen) then        Formats:='Full-duplex support, '+Formats                                                                             else
        Formats:='Half-duplex support, '+Formats;
      FRecorder.Close;
      FRecorder.FPause:=false;
    end;
    if Caps<>nil then FreeMem(Caps,SizeOf(TWaveOutCaps));
  end;
end;

{ Callback routine used for CALLBACK_FUNCTION in WavInOpen    }
procedure TRecorder.CallBack(uMsg1,dwInstance,dwParam1,dwParam2 : DWORD);  stdcall;
var LP,RP:pointer;
    Size:Word;
    RecPtr : PRecorder;
begin
  RecPtr := Pointer(dwInstance);
  with RecPtr^ do begin
   case uMsg1 of
    wim_OPEN  : Active1:=true;
    wim_CLOSE : begin Active1:=false; EndWorkEv1.SetEvent; end;
    wim_DATA  : begin
                  if Active1 then begin
                    LP:=pWavBuffer1[ReturnIndex1 Mod No_Buffers];
               //     RP:=pExtraBuffer[ReturnIndex Mod No_Buffers];
                    Size:=pWavHeader1[ReturnIndex1 Mod No_Buffers]^.dwBytesRecorded;
                    if (not(FPause) and TestTrigger(LP,Size)) then begin
                           if FileHMM<>0 then
   if mmiowrite(FileHMM,lp,Size)<>Size then
    begin mmioclose(FileHMM,0); FileHMM:=0; raise EWaveErr.create(recerr); end;
   EndBufEv1.SetEvent;
 //  if fsplit then Split(LP,RP,Size) else
 rp:=nil;
   if Assigned(FAudio.FOnAudioRecord) then FAudio.FOnAudioRecord(Self,LP,RP,Size);
   if lstream<>nil then
    begin lstream.Write(lp^,Size); if rstream<>nil then rstream.Write(lp^,Size); end;
                    end;
                    if (Size>0) then begin
                         PostMessage(AddNextInBufferHandle,wim_DATA,0,0);
                         ReturnIndex1:=(ReturnIndex1+1) mod No_Buffers;
                    end;
                  end;
                end;
   end;
  end;
end;

procedure TRecorder.Open;
var  iErr, i : Integer;
begin
  if not(DeviceOpen) then begin
    ForwardIndex1:=0;
    ReturnIndex1:=0;
    iErr:=WaveInOpen(@WavIn,FAudio.FDeviceID, @WavFmt,dword(@TRecorder.CallBack),
                     dword(@FAudio.FRecorder), CALLBACK_FUNCTION+Wave_ALLOWSYNC);
    if (iErr<>0) then begin
      Close;
      GetError(iErr,'Could not open the input device for recording: ');
      Exit;
    end;
    DeviceOpen:=true;
    InitWavHeaders1;
    for i:=0 to No_Buffers-1 do begin
     iErr:=WaveInPrepareHeader(WavIn, pWavHeader1[i], sizeof(TWaveHDR));
       if (iErr<>0) then begin
           Close;
           GetError(iErr,'Error preparing header for recording: ');
           Exit;
       end;
    end;
    if not(AddNextInBuffer) then raise EWaveErr.create('Error adding next input buffer');
  end;
end;

procedure TRecorder.Close;
var iErr,i : Integer;
begin
  if not(DeviceOpen) then Exit;
  if (WaveInReset(WavIn)<>0) then raise EWaveErr.create('Error in WaveInReset');
  for i:=0 to No_Buffers-1 do begin
     iErr:=WaveInUnprepareHeader(WavIn, pWavHeader1[i], sizeof(TWaveHDR));
     if (iErr<>0) then begin
       GetError(iErr,'Error in WaveInUnprepareHeader');
       Exit;
     end;
  end;
  if (WaveInClose(WavIn)<>0) then raise EWaveErr.create('Error closing input device');
  DeviceOpen:=false;
end;

procedure TRecorder.Start(LP,RP:TmemoryStream);
var  iErr, i : Integer;
begin
Open;
iErr:=WaveInStart(WavIn);
if (iErr<>0) then begin Close;
 GetError(iErr,'Error starting Wave record: '); Exit; end;
for i:=1 to No_Buffers-1 do
 if not(AddNextInBuffer) then raise EWaveErr.create('Error adding next input buffer');
EndBufEv1.resetevent;
if lp<>nil then begin lstream:=lp; rstream:=rp; end
           else begin lstream:=nil; rstream:=nil; end;
end;

procedure TRecorder.Stop;
begin
  Active1:=false; Close;
  if FileHMM<>0 then
    begin
    mmioAscend(FileHMM,@ckriff,0); mmioAscend(FileHMM,@ckdata,0);
    if mmioclose(FileHMM,0)<>MMSYSERR_NOERROR then
     begin FileHMM:=0; raise EWaveErr.create(recerr); end;
    FileHMM:=0;
    end;
end;

procedure TRecorder.Pause;
begin if DeviceOpen then FPause:=true; end;

procedure TRecorder.Restart;
begin if DeviceOpen then FPause:=false; end;

procedure TRecorder.RecordToFile(FileName,comment:string; LP,RP:TmemoryStream);
var ff:string; i:longint; ck:tmmckinfo;  bytes:byte; pb1,pb2:^byte;
begin
if FileName<>'' then with WavFmt do
 begin
 ff:=FileName+#0;  FileHMM:=mmioopen(@ff[1],nil,mmio_create or mmio_readwrite);
 if FileHMM=0 then raise EWaveErr.create('File opening error!');
 ckriff.fcctype:=fourcc_Wave;
 if mmiocreatechunk(FileHMM,@ckriff,mmio_createriff)<>MMSYSERR_NOERROR then
  begin mmioclose(FileHMM,0); FileHMM:=0; raise EWaveErr.create(recerr); end;
 if comment<>'' then
  begin
  ck.fcctype:=fourcc_info;  mmiocreatechunk(FileHMM,@ck,mmio_createlist);
  ckdata.ckid:=fourcc_isft; mmiocreatechunk(FileHMM,@ckdata,0);
  mmiowrite(FileHMM,@comment[1],length(comment));
  mmioAscend(FileHMM,@ckdata,0); mmioAscend(FileHMM,@ck,0);
  end;
 ckdata.cksize:=16; ckdata.ckid:=fourcc_fmt; mmiocreatechunk(FileHMM,@ckdata,0);
 mmiowrite(FileHMM,pchar(@WavFmt),ckdata.cksize);
 ckdata.ckid:=fourcc_data; mmiocreatechunk(FileHMM,@ckdata,0);
 if lp<>nil then
  begin
  if not(FSplit) then
   begin
   if mmiowrite(FileHMM,lp.memory,lp.Size)<>lp.Size then
    begin mmioclose(FileHMM,0); FileHMM:=0; raise EWaveErr.create(recerr);end;
   end
                 else // split channels
   begin
   bytes:=WavFmt.wBitsPerSample div 8; GetMem(pb1,WavBufSize); pb2:=pb1;
   lp.Position:=0; rp.Position:=0;
   for i:=1 to lp.size div bytes do
    begin
    lp.read(pb2^,bytes); inc(pb2,bytes);  rp.read(pb2^,bytes); inc(pb2,bytes);
    if ((i mod (WavBufSize div (2*bytes)))=0)or(i=lp.size div bytes) then
     begin
     if mmiowrite(FileHMM,pchar(pb1),dword(pb2)-dword(pb1))<>dword(pb2)-dword(pb1) then
      begin mmioclose(FileHMM,0); FileHMM:=0; freemem(pb1); raise EWaveErr.create(recerr); end;
     pb2:=pb1;
     end;
    end;
   freemem(pb1);
   end;
  mmioAscend(FileHMM,@ckriff,0); mmioAscend(FileHMM,@ckdata,0);
  if mmioclose(FileHMM,0)<>MMSYSERR_NOERROR then
   begin FileHMM:=0; raise EWaveErr.create(recerr); end;
  FileHMM:=0;
  end;// if lp<>nil then
 end; // if FileName<>'' then
end;

{ Callback routine used for CALLBACK_FUNCTION in WavOutOpen   }
procedure TPlayer.CallBack(uMsg,dwInstance,dwParam1,dwParam2 : DWORD);  stdcall;
var PlayPtr : PPlayer;
begin
  PlayPtr := Pointer(dwInstance);
  with PlayPtr^ do begin
   case uMsg of
    wom_OPEN  : Active:=true;
    wom_CLOSE : if Active then
                 begin
                 Active:=false; EndWorkEv.SetEvent;
                // if Assigned(FAudio.FOnPlayed) then FAudio.FOnPlayed(Self);
                 end;
    wom_DONE  : if Active then begin
                  if (ForwardIndex=ReturnIndex) then begin
               //  EWaveErr.create(inttostr(ForwardIndex)+' '+inttostr(ReturnIndex));
                    if not(FinishedPlaying) then begin
                      FinishedPlaying:=true;
                      PostMessage(CloseHandle,mm_wom_CLOSE,0,0);
                    end;
                  end else begin
                    EndBufEv.SetEvent;
                    if Assigned(FAudio.FOnBufferPlayed) then FAudio.FOnBufferPlayed(Self);
                    PostMessage(AddNextOutBufferHandle,wom_DONE,0,0);
                    ReturnIndex:=(ReturnIndex+1) mod No_Buffers;
                    dec(ActiveBuffers);
                  end;
                end;
   end;
  end;
end;

procedure TPlayer.Open;
var iErr : Integer;
begin
  if not(DeviceOpen) then begin
    ForwardIndex:=0;   ActiveBuffers:=0;
    ReturnIndex:=1;  { necessary since ForwardIndex always is one more than being sent  }
    iErr:=WaveOutOpen(@WavOut,FAudio.FDeviceID, @WavFmt,dword(@TPlayer.CallBack),
                      dword(@FAudio.FPlayer), CALLBACK_FUNCTION+Wave_ALLOWSYNC);
    if (iErr<>0) then
    GetError(iErr,'Could not open the output device for playing: ');
    DeviceOpen:=true; InitWavHeaders;
  end;
end;

procedure TPlayer.Play(LP,RP:TStream; NoOfRepeats:Word);
var i:longint; bytes:byte; pb1,pb2:^byte; nrep:dword;
begin
Open;
if (LP<>nil)and(LP.Size>0)and((PlayStream=nil)or(PlayStream is TMemoryStream)) then
 begin
 if PlayStream=nil then
  begin PlayStream:=TMemoryStream.Create; FNoOfRepeats:=NoOfRepeats; ReadPlayStreamPos:=0; end
                   else PlayStream.Position:=PlayStream.Size;
 nrep:=NoOfRepeats+1;
  repeat
  if not(FSplit) then
   begin LP.Position:=0;  PlayStream.CopyFrom(LP,LP.Size); end
                 else // split channels
   begin
   bytes:=WavFmt.wBitsPerSample div 8; GetMem(pb1,WavBufSize); pb2:=pb1;
   lp.Position:=0; rp.Position:=0;
   for i:=1 to lp.size div bytes do
    begin
    lp.read(pb2^,bytes); inc(pb2,bytes);  rp.read(pb2^,bytes); inc(pb2,bytes);
    if ((i mod (WavBufSize div (2*bytes)))=0)or(i=lp.size div bytes) then
     begin PlayStream.Write(pb1^,dword(pb2)-dword(pb1)); pb2:=pb1; end;
    end;
   freemem(pb1);
   end;
  dec(nrep)
  until (nrep=0) or (PlayStream.Size>No_Buffers*WavBufSize);
 if ReadPlayStreamPos=0 then for i:=1 to No_Buffers-2 do AddNextOutBuffer;
 end;
end;

procedure TPlayer.Close2(var Msg: TMessage);
var iErr, i : Integer;
begin
  if not(DeviceOpen) then exit;
  for i:=0 to No_Buffers-1 do begin
     iErr:=WaveOutUnPrepareHeader(WavOut, pWavHeader[i], sizeof(TWaveHDR));
     if (iErr<>0) then
     GetError(iErr,'Error unpreparing header for playing: ');
  end;
  iErr:=WaveOutClose(WavOut);
  if (iErr<>0) then
  GetError(iErr,'Error closing output device: ');
  DeviceOpen:=false;
end;

procedure TPlayer.Stop;
begin
if not(DeviceOpen) then exit;
if PlayStream<>nil then
 begin PlayStream.Free; PlayStream:=nil; ForwardIndex:=ReturnIndex; end;
if FileHMM<>0 then FileClose;
if not(FinishedPlaying) then
 if (WaveOutReset(WavOut)<>0) then raise EWaveErr.create('Error in WavOutReset');
end;

procedure TPlayer.Pause;
begin  if DeviceOpen then WaveOutPause(WavOut); end;

procedure TPlayer.Restart;
begin  if DeviceOpen then WaveOutRestart(WavOut); end;

procedure TPlayer.Reset;
begin if DeviceOpen then WaveOutReset(WavOut); end;

procedure TPlayer.BreakLoop;
begin if DeviceOpen then WaveOutBreakLoop(WavOut); end;

procedure TPlayer.FileOpen(FileName:string);
var ff:string;
  procedure err; begin FileClose; raise EWaveErr.create('Error in wav-file format'); end;
begin
ff:=FileName+#0; FileHMM:=mmioopen(@ff[1],nil,mmio_read or mmio_allocbuf);
if FileHMM=0 then raise EWaveErr.create('File opening error!');
ckriff.fcctype:=fourcc_wave;
if mmiodescend(FileHMM,@ckriff,nil,mmio_findriff)<>MMSYSERR_NOERROR then err;
ckdata.ckid:=fourcc_fmt;
if mmiodescend(FileHMM,@ckdata,@ckriff,mmio_findchunk)<>MMSYSERR_NOERROR then err;
if mmioread(FileHMM,@WavFmt,sizeof(WavFmt)-sizeof(word))<>sizeof(WavFmt)-sizeof(word) then err;
if WavFmt.wFormatTag<>Wave_FORMAT_PCM then err;
FreeMemory; try AllocateMemory; except on EWaveErr do err; end;
mmioascend(FileHMM,@ckdata,0);ckdata.ckid:=fourcc_data;
if mmiodescend(FileHMM,@ckdata,@ckriff,mmio_findchunk)<>MMSYSERR_NOERROR then err;
mmioseek(FileHMM,ckdata.dwDataOffset,seek_set); ReadPlayStreamPos:=0;
end;

procedure TPlayer.FileClose;
begin mmioclose(FileHMM,0); FileHMM:=0; end;

procedure TPlayer.FileLoad(FileName:string; LP,RP:TmemoryStream);
var i,nn:longint; pb1,pb2:^byte; bytes:byte;
  procedure err; begin FileClose; raise EWaveErr.create('Error wav-file reading'); end;
begin
FileOpen(filename);
if FSplit then
 begin
 lp.setsize((ckdata.cksize) div 2); rp.setsize(lp.size); lp.Position:=0; rp.Position:=0;
 bytes:=WavFmt.wBitsPerSample div 8; GetMem(pb1,WavBufSize);
 while ReadPlayStreamPos<=ckdata.cksize-1 do
  begin
  if ckdata.cksize-ReadPlayStreamPos>WavBufSize then i:=WavBufSize
                                                else i:=ckdata.cksize-ReadPlayStreamPos;
  nn:=mmioread(FileHMM,pchar(pb1),i); if nn<>i then err;
  pb2:=pb1; ReadPlayStreamPos:=ReadPlayStreamPos+nn;
  for i:=1 to nn div (bytes*2) do
   begin lp.write(pb2^,bytes); inc(pb2,bytes); rp.write(pb2^,bytes); inc(pb2,bytes); end;
  end;
 end
          else //no splitting channels
 begin
 lp.setsize(ckdata.cksize);
 nn:=mmioread(FileHMM,lp.memory,lp.size); if nn<>ckdata.cksize then err;
 end;
FileClose;
end;

procedure TPlayer.FilePlay(FileName:string; NoOfRepeats:Word);
var i : integer;
begin
FileOpen(filename); FNoOfRepeats:=NoOfRepeats;
try Open except on EWaveErr do begin FileClose; raise; end; end;
for i:=1 to (No_Buffers-ActiveBuffers) do AddNextOutBuffer;
end;

{------------- Property Controls ------------------------------------}

procedure TAudioSettings.SetChannels(Value:word);
begin
  if FAudio.FSepCtrl then begin
    if WavFmt.nChannels<>Value then
     begin WavFmt.nChannels:=Value;  FreeMemory;   AllocateMemory;  end;
  end else begin
    if FAudio.Player.WavFmt.nChannels<>Value then
     begin
     FAudio.Player.WavFmt.nChannels:=Value;
     FAudio.Player.FreeMemory;   FAudio.Player.AllocateMemory;
     end;
    if FAudio.Recorder.WavFmt.nChannels<>Value then
     begin
     FAudio.Recorder.WavFmt.nChannels:=Value;
     FAudio.Recorder.FreeMemory1; FAudio.Recorder.AllocateMemory1;
     end;
  end;
end;

procedure TAudioSettings.SetBPS(Value:word);
begin
  if FAudio.FSepCtrl then begin
    if WavFmt.wBitsPerSample<>Value then
     begin  WavFmt.wBitsPerSample:=Value; FreeMemory; AllocateMemory; end;
  end else begin
    if FAudio.Player.WavFmt.wBitsPerSample<>Value then
     begin
     FAudio.Player.WavFmt.wBitsPerSample:=Value;
     FAudio.Player.FreeMemory; FAudio.Player.AllocateMemory;
     end;
    if FAudio.Recorder.WavFmt.wBitsPerSample<>Value then
     begin
     FAudio.Recorder.WavFmt.wBitsPerSample:=Value;
     FAudio.Recorder.FreeMemory1;  FAudio.Recorder.AllocateMemory1;
     end;
  end;
end;

procedure TAudioSettings.SetSPS(Value:dWord);
begin
  if FAudio.FSepCtrl then begin
    if WavFmt.nSamplesPerSec<>Value then
     begin WavFmt.nSamplesPerSec:=Value; FreeMemory; AllocateMemory; end;
  end else begin
    if FAudio.Player.WavFmt.nSamplesPerSec<>Value then
     begin
     FAudio.Player.WavFmt.nSamplesPerSec:=Value;
     FAudio.Player.FreeMemory; FAudio.Player.AllocateMemory;
     end;
    if FAudio.Recorder.WavFmt.nSamplesPerSec<>Value then
     begin
     FAudio.Recorder.WavFmt.nSamplesPerSec:=Value;
     FAudio.Recorder.FreeMemory1; FAudio.Recorder.AllocateMemory1;
     end;
  end;
end;

procedure TAudioSettings.SetSplit(Value:Boolean);
begin
if FAudio.FSepCtrl then
 if WavFmt.nChannels=1 then FSplit:=false else FSplit:=Value
                   else
 begin
 if FAudio.Player.WavFmt.nChannels=1 then FAudio.Player.FSplit:=false
                                     else FAudio.Player.FSplit:=Value;
 if FAudio.Recorder.WavFmt.nChannels=1 then FAudio.Recorder.FSplit:=false
                                       else FAudio.Recorder.FSplit:=Value;
 end;
end;

procedure TRecorder.SetNoSamples(Value:Word);
begin
  if FAudio.Player.FNoSamples<>Value then begin
      FAudio.Player.FNoSamples:=Value;
      FAudio.Player.FreeMemory;  FAudio.Player.AllocateMemory;
  end;
  if FAudio.Recorder.FNoSamples<>Value then begin
      FAudio.Recorder.FNoSamples:=Value;
      FAudio.Recorder.FreeMemory1;  FAudio.Recorder.AllocateMemory1;
  end;
end;

procedure TRecorder.SetTrigLevel(Value:Word);
begin if FTrigLevel<>Value then FTrigLevel:=Value; end;

procedure TPlayer.GetVolume(var LeftVolume,RightVolume:Word);
var iErr : Integer;  Vol : LongInt;
begin
iErr:=WaveOutGetVolume(FAudio.FDeviceID,@Vol);
if (iErr<>0) then
GetError(iErr,'');
LeftVolume:=Word(Vol and $FFFF);  RightVolume:=Word(Vol shr 16);
end;

procedure TPlayer.SetVolume(LeftVolume,RightVolume:Word);
var iErr : Integer; Vol : longint;
begin
  Vol:=RightVolume;  Vol:=(Vol shl 16)+LeftVolume;
  iErr:=WaveOutSetVolume(FAudio.FDeviceID,Vol);
  if (iErr<>0) then
  GetError(iErr,'');
end;

procedure TAudio.SetDeviceID(Value:Integer);
begin
  if FDeviceID<>Value then begin
    if Value>9 then FDeviceID:=Wave_MAPPER
    else FDeviceID:=Value;
    FRecorder.FreeMemory1;    FRecorder.AllocateMemory1;
    FPlayer.FreeMemory;      FPlayer.AllocateMemory;
  end;
end;

procedure TAudio.SetMixerDeviceID(Value:Integer);
begin
if FMixerDeviceID<>Value then
 begin FMixerDeviceID:=Value; MixerPresent:=Mixer.GetMixerSettings(FMixerDeviceID); end;
end;

procedure Register;
begin RegisterComponents('samples', [TAudio]); end;

end.

