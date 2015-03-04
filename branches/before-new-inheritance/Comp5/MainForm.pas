
{ version 1.15 -- finance }

unit MainForm;

interface

uses
  Windows, Messages, Classes, Controls, Forms, Buttons,
  Menus, ExtCtrls, Part;

type
  TSelectPartEvent = procedure(ASender: TObject; APartTag: Integer) of object;

const
  AM_CHANGEPART = WM_USER + 17;

type
  TMainForm = class(TForm)
  private
    FWorkArea: TPanel;
    FBack: Integer;

    OldOnShowHint: TShowHintEvent;
    OldOnActivate: TNotifyEvent;

    procedure DoOnResize(Sender: TObject);
    procedure DoOnShowHint(var HintStr: String; var CanShow: Boolean;
      var HintInfo: THintInfo);
    procedure DoOnActivate(Sender: TObject);

  protected
    procedure AMChangePart(var Message: TMessage);
      message AM_CHANGEPART;

  public
    InitialPart: Integer;

    constructor Create(AnOwner: TComponent); override;

    procedure ChangePart(ANewPartClass: TPartClass; var Reference);
    procedure SelectPart(APartTag: Integer); virtual; abstract;

    procedure Back;
  end;

var
  CurrentPart: TPart;

implementation

uses
  SysUtils;

const
  NO_INITIAL_PART = -1;

constructor TMainForm.Create(AnOwner: TComponent);
var
  I: Integer;
begin
  InitialPart := NO_INITIAL_PART; { must precede constructor }

  inherited Create(AnOwner);

  OldOnShowHint := Application.OnShowHint;
  Application.OnShowHint := DoOnShowHint;

  FWorkArea := nil;
  for I := 0 to ComponentCount - 1 do
  begin
    if CompareText(Components[I].Name, 'WorkArea') = 0 then
    begin
      FWorkArea := Components[I] as TPanel;
      FWorkArea.OnResize := DoOnResize;
      break;
    end;
  end;

  if FWorkArea = nil then
    raise Exception.Create('Component named WorkArea must exist');

  OldOnActivate := OnActivate;
  OnActivate := DoOnActivate;

  FBack := -1;
end;

procedure TMainForm.ChangePart(ANewPartClass: TPartClass; var Reference);
var
  R: TRect;
  OldCursor: HCursor;
  OldAppCursor: TCursor;
  NewPart: TPart;
begin
  if Assigned(CurrentPart) and (CurrentPart is ANewPartClass) then
  begin
    CurrentPart.Release;
    CurrentPart := nil;
    TPart(Reference) := nil;
    exit;
  end;

  NewPart := ANewPartClass.Create(FWorkArea);

  OldAppCursor := Application.MainForm.Cursor;
  Application.MainForm.Cursor := crHourGlass;
  OldCursor := SetCursor(Screen.Cursors[crHourGlass]);
  try
    if Assigned(CurrentPart) then
    begin
      if Menu <> nil then
        Menu.Unmerge(CurrentPart.Menu);
      FBack := CurrentPart.PartTag;
      CurrentPart.Release;
      CurrentPart := nil;
    end;

    if Assigned(NewPart) then
    begin
      Windows.GetClientRect(FWorkArea.Handle, R);
      SetWindowPos(NewPart.Handle, 0, 0, 0, R.Right - R.Left - 0, R.Bottom - R.Top - 0,
        SWP_NOZORDER);
      NewPart.Show;
      NewPart.SetFocus;

      if Pos(' -', Caption) <> 0 then
        Caption := Copy(Caption, 1, Pos(' -', Caption) - 1);

      if NewPart.Caption > '' then
        Caption := Caption + ' - ' + NewPart.Caption;

      if Menu <> nil then
        Menu.Merge(NewPart.Menu);

      CurrentPart := NewPart;
    end;
  finally { setcursor }
    TPart(Reference) := NewPart as TPart;

    Application.MainForm.Cursor := OldAppCursor;
    SetCursor(OldCursor);
  end;
end;

procedure TMainForm.DoOnResize(Sender: TObject);
var
  R: TRect;
begin
  if Assigned(CurrentPart) then
  begin
    Windows.GetClientRect(FWorkArea.Handle, R);
    SetWindowPos(CurrentPart.Handle, 0, 0, 0, R.Right - R.Left - 0, R.Bottom - R.Top - 0,
      SWP_NOZORDER);
  end;
end;

procedure TMainForm.DoOnShowHint(var HintStr: String; var CanShow: Boolean;
  var HintInfo: THintInfo);
var
  P: Integer;
begin
  P := Pos('\n', HintStr);
  while P <> 0 do
  begin
    Delete(HintStr, P, 2);
    Insert(#10#13, HintStr, P);
    P := Pos('\n', HintStr);
  end;

  if Assigned(OldOnShowHint) then
    OldOnShowHint(HintStr, CanShow, HintInfo);
end;

procedure TMainForm.DoOnActivate(Sender: TObject);
begin
  if Assigned(OldOnActivate) then
    OldOnActivate(Sender);

  if InitialPart <> NO_INITIAL_PART then
  begin
    SelectPart(InitialPart);
    InitialPart := NO_INITIAL_PART;
  end;
end;

procedure TMainForm.AMChangePart(var Message: TMessage);
begin
  SelectPart(Message.WParam);
end;

procedure TMainForm.Back;
begin
  if FBack <> -1 then
    SelectPart(FBack);
end;

initialization
  CurrentPart := nil;
end.

