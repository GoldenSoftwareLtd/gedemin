{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynMacroRecorder.pas, released 2001-10-17.

Author of this file is Flávio Etrusco.
Portions created by Flávio Etrusco are Copyright 2001 Flávio Etrusco.
All Rights Reserved.

Contributors to the SynEdit project are listed in the Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynMacroRecorder.pas,v 1.3 2001/10/21 21:11:23 jrx Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}

unit SynMacroRecorder;

{$I SynEdit.inc}

interface

uses
  Classes, SynEdit, SynEditKeyCmds, StdCtrls, Controls, Windows, Messages,
  Graphics, Menus, SynEditPlugins;

{$IFDEF SYN_COMPILER_3_UP}
resourcestring
{$ELSE}
const
{$ENDIF}
  sNotRecording = 'Not recording';
  sNotStopped = 'Not stopped';

type
  TSynMacroState = (msStopped, msRecording, msPlaying, msPaused);

  TSynMacroEvent = class(TObject)
  protected
    fID: integer;
    fKey: char;
    fData: pointer;
  public
    constructor Create(aID: integer; aKey: char; aData: pointer); virtual;
    property ID: integer read fID;
    property Key: char read fKey;
    property Data: pointer read fData;
    procedure LoadFromStream(aStream: TStream); virtual;
    procedure SaveToStream(aStream: TStream); virtual;
  end;

  TCustomSynMacroRecorder = class(TAbstractSynHookerPlugin)
  private
    fShortCuts: array [0..1] of TShortCut;
    function GetEvent(aIndex: integer): TSynMacroEvent;
    function GetEventCount: integer;
  protected
    fOnChange: TNotifyEvent;
    fCurrentEditor: TCustomSynEdit;
    fState: TSynMacroState;
    fEvents: TList;
    fCommandIDs: array [0..1] of integer;
    procedure SetShortCut(const Index: Integer; const Value: TShortCut);
    function GetIsEmpty: boolean;
    procedure Changed;
    procedure Error(const aMsg: String);
    procedure DoAddEditor(aEditor: TCustomSynEdit); override;
    procedure DoRemoveEditor(aEditor: TCustomSynEdit); override;
    procedure OnCommand(Sender: TObject; AfterProcessing: boolean;
      var Handled: boolean; var Command: TSynEditorCommand; var aChar: char;
      Data: pointer; HandlerData: pointer); override;
    property EventCount: integer read GetEventCount;
    property Events[aIndex: integer]: TSynMacroEvent read GetEvent;
    function CreateMacroEvent(aCommandID: integer): TSynMacroEvent; virtual;
    procedure PlaybackEvent(aEditor: TCustomSynEdit; aEvent: TSynMacroEvent); virtual;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddEditor(aEditor: TCustomSynEdit);
    procedure RecordMacro(aEditor: TCustomSynEdit);
    procedure PlaybackMacro(aEditor: TCustomSynEdit);
    procedure Stop;
    procedure Pause;
    procedure Resume;
    property IsEmpty: boolean read GetIsEmpty;
    property State: TSynMacroState read fState;
    procedure Clear;
    procedure LoadMacro(aStream: TStream);
    procedure SaveMacro(aStream: TStream);
    property RecordShortCut: TShortCut index 0 read fShortCuts[0] write SetShortCut;
    property PlaybackShortCut: TShortCut index 1 read fShortCuts[1] write SetShortCut;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynMacroRecorder = class(TCustomSynMacroRecorder)
  published
    property RecordShortCut;
    property PlaybackShortCut;
    property OnChange;
  end;

implementation

uses
  SynEditMiscProcs, SynEditTypes, SysUtils, Forms;

{ TSynMacroEvent }

constructor TSynMacroEvent.Create(aID: integer; aKey: char; aData: pointer);
begin
  fID := aID;
  fKey := aKey;
  fData := aData;
end;

procedure TSynMacroEvent.LoadFromStream(aStream: TStream);
begin
  {don't read ID!}
  aStream.Read(fKey, SizeOf(fKey));
end;

procedure TSynMacroEvent.SaveToStream(aStream: TStream);
begin
  aStream.Write(fID, SizeOf(fID));
  aStream.Write(fKey, SizeOf(fKey));
end;

{ TCustomSynMacroRecorder }

procedure TCustomSynMacroRecorder.AddEditor(aEditor: TCustomSynEdit);
begin
  inherited AddEditor(aEditor);
end;

procedure TCustomSynMacroRecorder.Changed;
begin
  if Assigned(OnChange) then
    OnChange( Self );
end;

procedure TCustomSynMacroRecorder.Clear;
var
  I: Integer;
  Obj: TObject;
begin
  if Assigned(fEvents) then
  begin
    for I := fEvents.Count-1 downto 0 do
    begin
      Obj := fEvents[I];
      fEvents.Delete(I);
      Obj.Free;
    end;
    FreeAndNil( fEvents );
  end;
end;

constructor TCustomSynMacroRecorder.Create(aOwner: TComponent);
begin
  inherited;
  fCommandIDs[0] := NewPluginCommand;
  fCommandIDs[1] := NewPluginCommand;
  fShortCuts[0] := Menus.ShortCut( Ord('R'), [ssCtrl, ssShift] );
  fShortCuts[1] := Menus.ShortCut( Ord('P'), [ssCtrl, ssShift] );
end;

function TCustomSynMacroRecorder.CreateMacroEvent(aCommandID: integer): TSynMacroEvent;
{may be used to handle more complex SynEditCommands}
begin
  Result := TSynMacroEvent.Create( aCommandID, #0, nil );
end;

destructor TCustomSynMacroRecorder.Destroy;
begin
  Clear;
  inherited;
end;

procedure TCustomSynMacroRecorder.DoAddEditor(aEditor: TCustomSynEdit);
begin
  HookEditor(aEditor, fCommandIDs[0], 0, fShortCuts[0]);
  HookEditor(aEditor, fCommandIDs[1], 0, fShortCuts[1]);
end;

procedure TCustomSynMacroRecorder.DoRemoveEditor(aEditor: TCustomSynEdit);
begin
  UnHookEditor(aEditor, fCommandIDs[0], fShortCuts[0]);
  UnHookEditor(aEditor, fCommandIDs[1], fShortCuts[1]);
end;

procedure TCustomSynMacroRecorder.Error(const aMsg: String);
begin
  raise Exception.Create(aMsg);
end;

function TCustomSynMacroRecorder.GetEvent(aIndex: integer): TSynMacroEvent;
begin
  Result := TSynMacroEvent( fEvents[aIndex] );
end;

function TCustomSynMacroRecorder.GetEventCount: integer;
begin
  if fEvents = nil then
    Result := 0
  else
    Result := fEvents.Count;
end;

function TCustomSynMacroRecorder.GetIsEmpty: boolean;
begin
  Result := (fEvents = nil) or (fEvents.Count = 0);
end;

procedure TCustomSynMacroRecorder.LoadMacro(aStream: TStream);
var
  iCommand: integer;
  iEvent: TSynMacroEvent;
begin
  Stop;
  Clear;
  fEvents := TList.Create;
  //aStream.Seek( 0, soFromBeginning );
  while aStream.Position < aStream.Size do
  begin
    aStream.Read( iCommand, SizeOf(iCommand) );
    iEvent := CreateMacroEvent( iCommand );
    iEvent.LoadFromStream( aStream );
    fEvents.Add( iEvent );
  end;
end;

procedure TCustomSynMacroRecorder.OnCommand(Sender: TObject;
  AfterProcessing: boolean; var Handled: boolean;
  var Command: TSynEditorCommand; var aChar: char; Data,
  HandlerData: pointer);
begin
  if AfterProcessing then
  begin
    if fCurrentEditor <> Sender then
      Exit;
    if State = msRecording then
      if (Data = nil) then
      begin
        fEvents.Add( TSynMacroEvent.Create( Command, aChar, nil ) );
        Changed;
      {$IFDEF Debug}
      end
      else
      begin
        AllocConsole;
        WriteLn( 'ID:', Command, '   Char:', aChar, '   Data:', integer(Data) );
      {$ENDIF}
      end;
    (*
    case Command of
      ecChar, ecCopy, ecCut, ecPaste, ecUndo, ec:

    end;
    *)
  end
  else
    {not AfterProcessing}
    case State of
      msStopped:
        if Command = fCommandIDs[0] then
        begin
          RecordMacro( TCustomSynEdit( Sender ) );
          Handled := True;
        end
        else
          if Command = fCommandIDs[1] then
          begin
            PlaybackMacro( TCustomSynEdit( Sender ) );
            Handled := True;
          end;
      msPlaying:
        ;
      msPaused:
        if Command = fCommandIDs[1] then
        begin
          Resume;
          Handled := True;
        end;
      msRecording:
        if Command = fCommandIDs[1] then
        begin
          Pause;
          Handled := True;
        end
        else
          if Command = fCommandIDs[0] then
          begin
            Stop;
            Handled := True;
          end;
    end;
end;

procedure TCustomSynMacroRecorder.Pause;
begin
  if State <> msRecording then
    Error( sNotRecording );
  fState := msPaused;
  Changed;
end;

procedure TCustomSynMacroRecorder.PlaybackEvent(aEditor: TCustomSynEdit;
  aEvent: TSynMacroEvent);
begin
  aEditor.CommandProcessor( aEvent.ID, aEvent.Key, nil );
end;

procedure TCustomSynMacroRecorder.PlaybackMacro(aEditor: TCustomSynEdit);
var
  cEvent: integer;
begin
  if State <> msStopped then
    Error( sNotStopped );
  if (State <> msStopped) or (fEvents = nil) or (fEvents.Count < 1) then
    Exit;
  fState := msPlaying;
  try
    for cEvent := 0 to fEvents.Count -1 do
      PlaybackEvent( aEditor, Events[cEvent] );
  finally
    fState := msStopped;
  end;
end;

procedure TCustomSynMacroRecorder.RecordMacro(aEditor: TCustomSynEdit);
begin
  Assert( fState = msStopped );
  if fState <> msStopped then
    Exit;
  Clear;
  fEvents := TList.Create;
  fState := msRecording;
  fCurrentEditor := aEditor;
  Changed;
end;

procedure TCustomSynMacroRecorder.Resume;
begin
  Assert( State = msPaused );
  if fState = msPaused then
    fState := msRecording;
  Changed;
end;

procedure TCustomSynMacroRecorder.SaveMacro(aStream: TStream);
var
  cEvent: integer;
begin
  for cEvent := 0 to EventCount -1 do
    Events[ cEvent ].SaveToStream( aStream );
end;

procedure TCustomSynMacroRecorder.SetShortCut(const Index: Integer;
  const Value: TShortCut);
var
  cEditor: integer;
begin
  if fShortCuts[Index] <> Value then
  begin
    if Assigned(fEditors) then
      if Value <> 0 then
      begin
        for cEditor := 0 to fEditors.Count -1 do
          HookEditor( Editors[cEditor], fCommandIDs[Index], fShortCuts[Index], Value );
      end else
      begin
        for cEditor := 0 to fEditors.Count -1 do
          UnHookEditor( Editors[cEditor], fCommandIDs[Index], fShortCuts[Index] );
      end;
    fShortCuts[Index] := Value;
  end;
end;

procedure TCustomSynMacroRecorder.Stop;
begin
  if fState = msStopped then
    Exit;
  fState := msStopped;
  fCurrentEditor := nil;
  if fEvents.Count = 0 then
    FreeAndNil( fEvents );
  Changed;
end;

end.

