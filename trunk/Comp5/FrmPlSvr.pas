
{++

  Copyright (c) 1995-98 by Golden Software of Belarus

  Module

    frmplsvr.pas

  Abstract

    A Delphi component. This component is designed to store on
    the disk form's coordinates and state.

  Author

    Denis Romanovski (29-Nov-95)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    01-Dec-95    dennis,    Initial version.
                         andreik
    1.01    14-May-96    andreik    All the information stored in
                                    system registry.
    1.02    10-Jul-96    andreik    Minor change.
    1.03    27-Jul-96    andreik    Minor change.
    1.04    17-Feb-97    andreik    Minor change.
    1.05    03-Jun-98    michael    Minor Change (Add OnChanged)
    1.06    08-Sep-99    dennis     Minor change. Property OnlyForm added.
                                    It means that only form's properties stored.

--}

unit FrmPlSvr;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

const
  DefEnabled = True;
  DefOnlyForm = False;

type
  TFormPlaceSaver = class(TComponent)
  private
    FEnabled: Boolean;
    FOnlyForm: Boolean;
    FOnChanged: TNotifyEvent;

    Key: String;
    OldOnCreate: TNotifyEvent;
    OldOnDestroy: TNotifyEvent;

    procedure DoOnCreate(Sender: TObject);
    procedure DoOnDestroy(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Enabled: Boolean read FEnabled write FEnabled
      default DefEnabled;
    property OnlyForm: Boolean read FOnlyForm write FOnlyForm
      default DefOnlyForm;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  EFormPlaceSaverError = class(Exception);

procedure Register;

implementation

uses
  xAppReg;

{ TFormPlaceSaver ----------------------------------------}

constructor TFormPlaceSaver.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if not (Owner is TForm) then
    raise EFormPlaceSaverError.Create('The Owner must be TForm');

  FEnabled := DefEnabled;
  FOnlyForm := DefOnlyForm;
  Key := BuildKey(Owner);
  FOnChanged:= nil;
  { assigning events handlers in design mode
    causes loose of previous handlers }
  if not (csDesigning in ComponentState) then
  begin
    OldOnCreate := (Owner as TForm).OnCreate;
    (Owner as TForm).OnCreate := DoOnCreate;

    OldOnDestroy := (Owner as TForm).OnDestroy;
    (Owner as TForm).OnDestroy := DoOnDestroy;
  end;
end;

destructor TFormPlaceSaver.Destroy;
begin
  if (not (csDesigning in ComponentState)) and (Owner <> nil) then
  begin
    (Owner as TForm).OnCreate := OldOnCreate;
    (Owner as TForm).OnDestroy := OldOnDestroy;
  end;
  inherited Destroy;
end;

procedure TFormPlaceSaver.DoOnCreate(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(OldOnCreate) then OldOnCreate(Sender);
  if FEnabled and Assigned(AppRegistry) then
  with AppRegistry do
  begin
    ReadComponent(Key, Sender as TForm);

    if not FOnlyForm then
      for I := 0 to (Sender as TForm).ComponentCount - 1 do {!!!}
        ReadComponent(Key, (Sender as TForm).Components[I]);
  end;
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

procedure TFormPlaceSaver.DoOnDestroy(Sender: TObject);
var
  I: Integer;
begin
  if FEnabled and Assigned(AppRegistry) then
  with AppRegistry do
  begin
    WriteComponent(Key, Sender as TForm);

    if not FOnlyForm then
      for I := 0 to (Sender as TForm).ComponentCount - 1 do
        WriteComponent(Key, (Sender as TForm).Components[I]);
  end;

  if Assigned(OldOnDestroy) then OldOnDestroy(Sender);
end;

{ Registion ----------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-NonVisual', [TFormPlaceSaver]);
end;

end.

