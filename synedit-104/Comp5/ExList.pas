
{++

  Copyright (c) 1995 by Golden Software

  Module

    exlist.pas

  Abstract

    Modified standart Delphi's TList.

  Author

    Andrei Kireev (30-Sep-95)

  Revisions history

    1.01    12-Oct-1999    andreik    Method Clear added.
    1.02    28-Oct-1999    dennis     Bugs under Delphi5 fixed.

--}

unit ExList;

interface

uses
  Classes;

type
  TForEach = procedure(P: Pointer) of object;

type
  TExList = class(TList)
  private
    FShouldDel: Boolean;

  public
    constructor Create;
    {$IFNDEF VER130} // in Delphi5 destructor automatically calls Clear
    destructor Destroy; override;
    {$ENDIF}

    function RemoveAndPack(Item: Pointer): Integer;
    procedure DeleteAndPack(Index: Integer);
    function RemoveAndFree(Item: Pointer): Integer;
    procedure DeleteAndFree(Index: Integer);
    procedure ForEach(Proc: TForEach);
    procedure Clear; override;

    property ShouldDel: Boolean read FShouldDel write FShouldDel;
  end;

implementation

{ ExList -------------------------------------------------}

constructor TExList.Create;
begin
  inherited Create;
  FShouldDel := True;
end;

{$IFNDEF VER130}
destructor TExList.Destroy;
begin
  Clear;
  inherited Destroy;
end;
{$ENDIF}

function TExList.RemoveAndPack(Item: Pointer): Integer;
begin
  Result := Remove(Item);
  Pack;
end;

procedure TExList.DeleteAndPack(Index: Integer);
begin
  Delete(Index);
  Pack;
end;

function TExList.RemoveAndFree(Item: Pointer): Integer;
begin
  Result := Remove(Item);
  TObject(Item).Free;
  Pack;
end;

procedure TExList.DeleteAndFree(Index: Integer);
var
  T: TObject;
begin
  T := Items[Index];
  Delete(Index);
  T.Free;
  Pack;
end;

procedure TExList.ForEach(Proc: TForEach);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Proc(Items[I]);
end;

procedure TExList.Clear;
var
  I: Integer;
begin
  if FShouldDel then
  begin
    for I := 0 to Count - 1 do
      if Assigned(Items[I]) then
        TObject(Items[I]).Free;
  end;

  inherited Clear;
end;

end.
