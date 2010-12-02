{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is ArrayList.pas.                                                              }
{                                                                                                  }
{ The Initial Developer of the Original Code is Jean-Philippe BEMPEL aka RDM. Portions created by  }
{ Jean-Philippe BEMPEL are Copyright (C) Jean-Philippe BEMPEL (rdm_30 att yahoo dott com)          }
{ All rights reserved.                                                                             }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ The Delphi Container Library                                                                     }
{                                                                                                  }
{**************************************************************************************************}

// Last modified: $Date: 2007-08-06 21:39:21 +0200 (lun., 06 août 2007) $

unit JclArrayLists;

{$I jcl.inc}

interface

uses
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  Classes,
  JclBase, JclAbstractContainers, JclContainerIntf;

type
  TJclIntfArrayList = class(TJclAbstractContainer, IJclIntfCollection,
      IJclIntfList, IJclIntfArray, IJclIntfCloneable)
  private
    FElementData: TDynIInterfaceArray;
    FSize: Integer;
    FCapacity: Integer;
    procedure SetCapacity(ACapacity: Integer);
  protected
    procedure Grow; virtual;
    { IJclIntfCollection }
    function Add(const AInterface: IInterface): Boolean; overload;
    function AddAll(const ACollection: IJclIntfCollection): Boolean; overload;
    procedure Clear;
    function Contains(const AInterface: IInterface): Boolean;
    function ContainsAll(const ACollection: IJclIntfCollection): Boolean;
    function Equals(const ACollection: IJclIntfCollection): Boolean;
    function First: IJclIntfIterator;
    function IsEmpty: Boolean;
    function Last: IJclIntfIterator;
    function Remove(const AInterface: IInterface): Boolean; overload;
    function RemoveAll(const ACollection: IJclIntfCollection): Boolean;
    function RetainAll(const ACollection: IJclIntfCollection): Boolean;
    function Size: Integer;
    { IJclIntfList }
    procedure Insert(Index: Integer; const AInterface: IInterface); overload;
    function InsertAll(Index: Integer; const ACollection: IJclIntfCollection): Boolean; overload;
    function GetObject(Index: Integer): IInterface;
    function IndexOf(const AInterface: IInterface): Integer;
    function LastIndexOf(const AInterface: IInterface): Integer;
    function Remove(Index: Integer): IInterface; overload;
    procedure SetObject(Index: Integer; const AInterface: IInterface);
    function SubList(First, Count: Integer): IJclIntfList;
    { IJclIntfCloneable }
    function Clone: IInterface;
  public
    constructor Create(ACapacity: Integer = DefaultContainerCapacity); overload;
    constructor Create(const ACollection: IJclIntfCollection); overload;
    destructor Destroy; override;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  //Daniele Teti 02/03/2005
  TJclStrArrayList = class(TJclStrCollection, IJclStrList, IJclStrArray, IJclCloneable)
  private
    FCapacity: Integer;
    FElementData: TDynStringArray;
    FSize: Integer;
    procedure SetCapacity(ACapacity: Integer);
  protected
    procedure Grow; virtual;
    { IJclStrCollection }
    function Add(const AString: string): Boolean; overload; override;
    function AddAll(const ACollection: IJclStrCollection): Boolean; overload; override;
    procedure Clear; override;
    function Contains(const AString: string): Boolean; override;
    function ContainsAll(const ACollection: IJclStrCollection): Boolean; override;
    function Equals(const ACollection: IJclStrCollection): Boolean; override;
    function First: IJclStrIterator; override;
    function IsEmpty: Boolean; override;
    function Last: IJclStrIterator; override;
    function Remove(const AString: string): Boolean; overload; override;
    function RemoveAll(const ACollection: IJclStrCollection): Boolean; override;
    function RetainAll(const ACollection: IJclStrCollection): Boolean; override;
    function Size: Integer; override;
    { IJclStrList }
    procedure Insert(Index: Integer; const AString: string); overload;
    function InsertAll(Index: Integer; const ACollection: IJclStrCollection): Boolean; overload;
    function GetString(Index: Integer): string;
    function IndexOf(const AString: string): Integer;
    function LastIndexOf(const AString: string): Integer;
    function Remove(Index: Integer): string; overload;
    procedure SetString(Index: Integer; const AString: string);
    function SubList(First, Count: Integer): IJclStrList;
  public
    constructor Create(ACapacity: Integer = DefaultContainerCapacity); overload;
    constructor Create(const ACollection: IJclStrCollection); overload;
    destructor Destroy; override;
    { IJclCloneable }
    function Clone: TObject;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  TJclArrayList = class(TJclAbstractContainer, IJclCollection, IJclList,
      IJclArray, IJclCloneable)
  private
    FCapacity: Integer;
    FElementData: TDynObjectArray;
    FOwnsObjects: Boolean;
    FSize: Integer;
    procedure SetCapacity(ACapacity: Integer);
  protected
    procedure Grow; virtual;
    procedure FreeObject(var AObject: TObject);
    { IJclCollection }
    function Add(AObject: TObject): Boolean; overload;
    function AddAll(const ACollection: IJclCollection): Boolean; overload;
    procedure Clear;
    function Contains(AObject: TObject): Boolean;
    function ContainsAll(const ACollection: IJclCollection): Boolean;
    function Equals(const ACollection: IJclCollection): Boolean;
    function First: IJclIterator;
    function IsEmpty: Boolean;
    function Last: IJclIterator;
    function Remove(AObject: TObject): Boolean; overload;
    function RemoveAll(const ACollection: IJclCollection): Boolean;
    function RetainAll(const ACollection: IJclCollection): Boolean;
    function Size: Integer;
    { IJclList }
    procedure Insert(Index: Integer; AObject: TObject); overload;
    function InsertAll(Index: Integer; const ACollection: IJclCollection): Boolean; overload;
    function GetObject(Index: Integer): TObject;
    function IndexOf(AObject: TObject): Integer;
    function LastIndexOf(AObject: TObject): Integer;
    function Remove(Index: Integer): TObject; overload;
    procedure SetObject(Index: Integer; AObject: TObject);
    function SubList(First, Count: Integer): IJclList;
    { IJclCloneable }
    function Clone: TObject;
  public
    constructor Create(ACapacity: Integer = DefaultContainerCapacity; AOwnsObjects: Boolean = True); overload;
    constructor Create(const ACollection: IJclCollection; AOwnsObjects: Boolean = True); overload;
    destructor Destroy; override;
    property Capacity: Integer read FCapacity write SetCapacity;
    property OwnsObjects: Boolean read FOwnsObjects;
  end;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net:443/svnroot/jcl/tags/JCL-1.101-Build2725/jcl/source/common/JclArrayLists.pas $';
    Revision: '$Revision: 2105 $';
    Date: '$Date: 2007-08-06 21:39:21 +0200 (lun., 06 août 2007) $';
    LogPath: 'JCL\source\common'
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  SysUtils,
  JclResources;

//=== { TIntfItr } ===========================================================

type
  TIntfItr = class(TJclAbstractContainer, IJclIntfIterator)
  private
    FCursor: Integer;
    FOwnList: TJclIntfArrayList;
    //FLastRet: Integer;
    FSize: Integer;
  protected
    { IJclIntfIterator}
    procedure Add(const AInterface: IInterface);
    function GetObject: IInterface;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: IInterface;
    function NextIndex: Integer;
    function Previous: IInterface;
    function PreviousIndex: Integer;
    procedure Remove;
    procedure SetObject(const AInterface: IInterface);
  public
    constructor Create(AOwnList: TJclIntfArrayList);
    {$IFNDEF CLR}
    destructor Destroy; override;
    {$ENDIF ~CLR}
  end;

constructor TIntfItr.Create(AOwnList: TJclIntfArrayList);
begin
  inherited Create;
  FCursor := 0;
  FOwnList := AOwnList;
  {$IFNDEF CLR}
  FOwnList._AddRef; // Add a ref because FOwnList is not an interface !
  {$ENDIF ~CLR}
  //FLastRet := -1;
  FSize := FOwnList.Size;
end;

{$IFNDEF CLR}
destructor TIntfItr.Destroy;
begin
  FOwnList._Release;
  inherited Destroy;
end;
{$ENDIF ~CLR}

procedure TIntfItr.Add(const AInterface: IInterface);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  // inlined FOwnList.Add
  if FOwnList.FSize = FOwnList.Capacity then
    FOwnList.Grow;
  if FOwnList.FSize <> FCursor then
    MoveArray(FOwnList.FElementData, FCursor, FCursor + 1, FOwnList.FSize - FCursor);
  FOwnList.FElementData[FCursor] := AInterface;
  Inc(FOwnList.FSize);

  Inc(FSize);
  Inc(FCursor);
  //FLastRet := -1;
end;

function TIntfItr.GetObject: IInterface;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := FOwnList.FElementData[FCursor];
end;

function TIntfItr.HasNext: Boolean;
begin
  Result := FCursor < FSize;
end;

function TIntfItr.HasPrevious: Boolean;
begin
  Result := FCursor > 0;
end;

function TIntfItr.Next: IInterface;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := FOwnList.FElementData[FCursor];
  //FLastRet := FCursor;
  Inc(FCursor);
end;

function TIntfItr.NextIndex: Integer;
begin
  Result := FCursor;
end;

function TIntfItr.Previous: IInterface;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Dec(FCursor);
  //FLastRet := FCursor;
  Result := FOwnList.FElementData[FCursor];
end;

function TIntfItr.PreviousIndex: Integer;
begin
  Result := FCursor - 1;
end;

procedure TIntfItr.Remove;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  with FOwnList do
  begin
    FElementData[FCursor] := nil; // Force Release
    if FSize <> FCursor then
      MoveArray(FElementData, FCursor + 1, FCursor, FSize - FCursor);
  end;
  Dec(FOwnList.FSize);
  Dec(FSize);
end;

procedure TIntfItr.SetObject(const AInterface: IInterface);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {
  if FLastRet = -1 then
    raise EJclIllegalState.Create(SIllegalState);
  }
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  FOwnList.FElementData[FCursor] := AInterface;
end;

//=== { TStrItr } ============================================================

type
  TStrItr = class(TJclAbstractContainer, IJclStrIterator)
  private
    FCursor: Integer;
    FOwnList: TJclStrArrayList;
    //FLastRet: Integer;
    FSize: Integer;
  protected
    { IJclStrIterator}
    procedure Add(const AString: string);
    function GetString: string;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: string;
    function NextIndex: Integer;
    function Previous: string;
    function PreviousIndex: Integer;
    procedure Remove;
    procedure SetString(const AString: string);
  public
    constructor Create(AOwnList: TJclStrArrayList);
    {$IFNDEF CLR}
    destructor Destroy; override;
    {$ENDIF ~CLR}
  end;

constructor TStrItr.Create(AOwnList: TJclStrArrayList);
begin
  inherited Create;
  FCursor := 0;
  FOwnList := AOwnList;
  {$IFNDEF CLR}
  FOwnList._AddRef; // Add a ref because FOwnList is not an interface !
  {$ENDIF ~CLR}
  //FLastRet := -1;
  FSize := FOwnList.Size;
end;

{$IFNDEF CLR}
destructor TStrItr.Destroy;
begin
  FOwnList._Release;
  inherited Destroy;
end;
{$ENDIF ~CLR}

procedure TStrItr.Add(const AString: string);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  // inlined FOwnList.Add
  if FOwnList.FSize = FOwnList.Capacity then
    FOwnList.Grow;
  if FOwnList.FSize <> FCursor then
    MoveArray(FOwnList.FElementData, FCursor, FCursor + 1, FOwnList.FSize - FCursor);
  FOwnList.FElementData[FCursor] := AString;
  Inc(FOwnList.FSize);

  Inc(FSize);
  Inc(FCursor);
  //FLastRet := -1;
end;

function TStrItr.GetString: string;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := FOwnList.FElementData[FCursor];
end;

function TStrItr.HasNext: Boolean;
begin
  Result := FCursor < FSize;
end;

function TStrItr.HasPrevious: Boolean;
begin
  Result := FCursor > 0;
end;

function TStrItr.Next: string;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := FOwnList.FElementData[FCursor];
  //FLastRet := FCursor;
  Inc(FCursor);
end;

function TStrItr.NextIndex: Integer;
begin
  Result := FCursor;
end;

function TStrItr.Previous: string;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Dec(FCursor);
  //FLastRet := FCursor;
  Result := FOwnList.FElementData[FCursor];
end;

function TStrItr.PreviousIndex: Integer;
begin
  Result := FCursor - 1;
end;

procedure TStrItr.Remove;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  with FOwnList do
  begin
    FElementData[FCursor] := ''; // Force Release
    if FSize <> FCursor then
      MoveArray(FElementData, FCursor + 1, FCursor, FSize - FCursor);
  end;
  Dec(FOwnList.FSize);
  Dec(FSize);
end;

procedure TStrItr.SetString(const AString: string);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {
  if FLastRet = -1 then
    raise EJclIllegalState.Create(SIllegalState);
  }
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  FOwnList.FElementData[FCursor] := AString;
end;

//=== { TItr } ===============================================================

type
  TItr = class(TJclAbstractContainer, IJclIterator)
  private
    FCursor: Integer;
    FOwnList: TJclArrayList;
    //FLastRet: Integer;
    FSize: Integer;
  protected
    { IJclIterator}
    procedure Add(AObject: TObject);
    function GetObject: TObject;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: TObject;
    function NextIndex: Integer;
    function Previous: TObject;
    function PreviousIndex: Integer;
    procedure Remove;
    procedure SetObject(AObject: TObject);
  public
    constructor Create(AOwnList: TJclArrayList);
    {$IFNDEF CLR}
    destructor Destroy; override;
    {$ENDIF ~CLR}
  end;

constructor TItr.Create(AOwnList: TJclArrayList);
begin
  inherited Create;
  FCursor := 0;
  FOwnList := AOwnList;
  {$IFNDEF CLR}
  FOwnList._AddRef; // Add a ref because FOwnList is not an interface !
  {$ENDIF ~CLR}
  //FLastRet := -1;
  FSize := FOwnList.Size;
end;

{$IFNDEF CLR}
destructor TItr.Destroy;
begin
  FOwnList._Release;
  inherited Destroy;
end;
{$ENDIF ~CLR}

procedure TItr.Add(AObject: TObject);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  // inlined FOwnList.Add
  if FOwnList.FSize = FOwnList.Capacity then
    FOwnList.Grow;
  if FOwnList.FSize <> FCursor then
    MoveArray(FOwnList.FElementData, FCursor, FCursor + 1, FOwnList.FSize - FCursor);
  FOwnList.FElementData[FCursor] := AObject;
  Inc(FOwnList.FSize);

  Inc(FSize);
  Inc(FCursor);
  //FLastRet := -1;
end;

function TItr.GetObject: TObject;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := FOwnList.FElementData[FCursor];
end;

function TItr.HasNext: Boolean;
begin
  Result := FCursor <> FSize;
end;

function TItr.HasPrevious: Boolean;
begin
  Result := FCursor > 0;
end;

function TItr.Next: TObject;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := FOwnList.FElementData[FCursor];
  //FLastRet := FCursor;
  Inc(FCursor);
end;

function TItr.NextIndex: Integer;
begin
  Result := FCursor;
end;

function TItr.Previous: TObject;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Dec(FCursor);
  //FLastRet := FCursor;
  Result := FOwnList.FElementData[FCursor];
end;

function TItr.PreviousIndex: Integer;
begin
  Result := FCursor - 1;
end;

procedure TItr.Remove;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  with FOwnList do
  begin
    FreeObject(FElementData[FCursor]);
    if FSize <> FCursor then
      MoveArray(FElementData, FCursor + 1, FCursor, FSize - FCursor);
  end;
  Dec(FOwnList.FSize);
  Dec(FSize);
end;

procedure TItr.SetObject(AObject: TObject);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  FOwnList.FElementData[FCursor] := AObject;
end;

//=== { TJclIntfArrayList } ==================================================

constructor TJclIntfArrayList.Create(ACapacity: Integer = DefaultContainerCapacity);
begin
  inherited Create;
  FSize := 0;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElementData, FCapacity);
end;

constructor TJclIntfArrayList.Create(const ACollection: IJclIntfCollection);
begin
  // (rom) disabled because the following Create already calls inherited
  // inherited Create;
  if ACollection = nil then
    {$IFDEF CLR}
    raise EJclIllegalArgumentError.Create(RsENoCollection);
    {$ELSE}
    raise EJclIllegalArgumentError.CreateRes(@RsENoCollection);
    {$ENDIF CLR}
  Create(ACollection.Size);
  AddAll(ACollection);
end;

destructor TJclIntfArrayList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TJclIntfArrayList.Insert(Index: Integer; const AInterface: IInterface);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index > FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  if FSize = Capacity then
    Grow;
  if FSize <> Index then
    MoveArray(FElementData, Index, Index + 1, FSize - Index);
  FElementData[Index] := AInterface;
  Inc(FSize);
end;

function TJclIntfArrayList.InsertAll(Index: Integer; const ACollection: IJclIntfCollection): Boolean;
var
  It: IJclIntfIterator;
  Size: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  if ACollection = nil then
    Exit;
  Size := ACollection.Size;
  if FSize + Size >= Capacity then
    Capacity := FSize + Size;
  if Size <> 0 then
    MoveArray(FElementData, Index, Index + Size, Size);
  It := ACollection.First;
  Result := It.HasNext;
  while It.HasNext do
  begin
    FElementData[Index] := It.Next;
    Inc(Index);
  end;
end;

function TJclIntfArrayList.Add(const AInterface: IInterface): Boolean;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if FSize = Capacity then
    Grow;
  {$IFNDEF CLR}
  FillChar(FElementData[FSize], SizeOf(IInterface), 0);
  {$ENDIF ~CLR}
  FElementData[FSize] := AInterface;
  Inc(FSize);
  Result := True;
end;

function TJclIntfArrayList.AddAll(const ACollection: IJclIntfCollection): Boolean;
var
  It: IJclIntfIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
  begin
    // (rom) inlining Add() gives about 5 percent performance increase
    if FSize = Capacity then
      Grow;
    {$IFNDEF CLR}
    FillChar(FElementData[FSize], SizeOf(IInterface), 0);
    {$ENDIF ~CLR}
    FElementData[FSize] := It.Next;
    Inc(FSize);
  end;
  Result := True;
end;

procedure TJclIntfArrayList.Clear;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  for I := 0 to FSize - 1 do
    FElementData[I] := nil;
  FSize := 0;
end;

function TJclIntfArrayList.Clone: IInterface;
var
  NewList: IJclIntfList;
begin
  NewList := TJclIntfArrayList.Create(Capacity);
  NewList.AddAll(Self);
  Result := NewList;
end;

function TJclIntfArrayList.Contains(const AInterface: IInterface): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if AInterface = nil then
    Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AInterface then
    begin
      Result := True;
      Break;
    end;
end;

function TJclIntfArrayList.ContainsAll(const ACollection: IJclIntfCollection): Boolean;
var
  It: IJclIntfIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
  Result := contains(It.Next);
end;

function TJclIntfArrayList.Equals(const ACollection: IJclIntfCollection): Boolean;
var
  I: Integer;
  It: IJclIntfIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  for I := 0 to FSize - 1 do
    if FElementData[I] <> It.Next then
      Exit;
  Result := True;
end;

function TJclIntfArrayList.GetObject(Index: Integer): IInterface;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    Result := nil
  else
    Result := FElementData[Index];
end;

procedure TJclIntfArrayList.SetCapacity(ACapacity: Integer);
begin
  if ACapacity >= FSize then
  begin
    SetLength(FElementData, ACapacity);
    FCapacity := ACapacity;
  end
  else
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
end;

procedure TJclIntfArrayList.Grow;
begin
  if Capacity > 64 then
    Capacity := Capacity + Capacity div 4
  else
  if FCapacity = 0 then
    FCapacity := 64
  else
    Capacity := Capacity * 4;
end;

function TJclIntfArrayList.IndexOf(const AInterface: IInterface): Integer;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := -1;
  if AInterface = nil then
    Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AInterface then
    begin
      Result := I;
      Break;
    end;
end;

function TJclIntfArrayList.First: IJclIntfIterator;
begin
  Result := TIntfItr.Create(Self);
end;

function TJclIntfArrayList.IsEmpty: Boolean;
begin
  Result := FSize = 0;
end;

function TJclIntfArrayList.Last: IJclIntfIterator;
var
  NewIterator: TIntfItr;
begin
  NewIterator := TIntfItr.Create(Self);
  NewIterator.FCursor := NewIterator.FOwnList.FSize;
  NewIterator.FSize := NewIterator.FOwnList.FSize;
  Result := NewIterator;
end;

function TJclIntfArrayList.LastIndexOf(const AInterface: IInterface): Integer;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := -1;
  if AInterface = nil then
    Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AInterface then
    begin
      Result := I;
      Break;
    end;
end;

function TJclIntfArrayList.Remove(const AInterface: IInterface): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if AInterface = nil then
    Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AInterface then // Removes all AInterface
    begin
      FElementData[I] := nil; // Force Release
      if FSize <> I then
        MoveArray(FElementData, I + 1, I, FSize - I);
      Dec(FSize);
      Result := True;
    end;
end;

function TJclIntfArrayList.Remove(Index: Integer): IInterface;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  Result := FElementData[Index];
  FElementData[Index] := nil;
  if FSize <> Index then
    MoveArray(FElementData, Index + 1, Index, FSize - Index);
  Dec(FSize);
end;

function TJclIntfArrayList.RemoveAll(const ACollection: IJclIntfCollection): Boolean;
var
  It: IJclIntfIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Result := Remove(It.Next) and Result;
end;

function TJclIntfArrayList.RetainAll(const ACollection: IJclIntfCollection): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  for I := FSize - 1 downto 0 do
    if not ACollection.Contains(FElementData[I]) then
      Remove(I);
end;

procedure TJclIntfArrayList.SetObject(Index: Integer; const AInterface: IInterface);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  FElementData[Index] := AInterface;
end;

function TJclIntfArrayList.Size: Integer;
begin
  Result := FSize;
end;

function TJclIntfArrayList.SubList(First, Count: Integer): IJclIntfList;
var
  I: Integer;
  Last: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Last := First + Count - 1;
  if Last >= FSize then
    Last := FSize - 1;
  Result := TJclIntfArrayList.Create(Count);
  for I := First to Last do
    Result.Add(FElementData[I]);
end;

//=== { TJclStrArrayList } ===================================================

constructor TJclStrArrayList.Create(ACapacity: Integer = DefaultContainerCapacity);
begin
  inherited Create;
  FSize := 0;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElementData, FCapacity);
end;

constructor TJclStrArrayList.Create(const ACollection: IJclStrCollection);
begin
  // (rom) disabled because the following Create already calls inherited
  // inherited Create;
  if ACollection = nil then
    {$IFDEF CLR}
    raise EJclIllegalArgumentError.Create(RsENoCollection);
    {$ELSE}
    raise EJclIllegalArgumentError.CreateRes(@RsENoCollection);
    {$ENDIF CLR}
  Create(ACollection.Size);
  AddAll(ACollection);
end;

destructor TJclStrArrayList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TJclStrArrayList.Insert(Index: Integer; const AString: string);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index > FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  if FSize = Capacity then
    Grow;
  if FSize <> Index then
    MoveArray(FElementData, Index, Index + 1, FSize - Index);
  FElementData[Index] := AString;
  Inc(FSize);
end;

function TJclStrArrayList.InsertAll(Index: Integer;
  const ACollection: IJclStrCollection): Boolean;
var
  It: IJclStrIterator;
  Size: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;

  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}

  if ACollection = nil then
    Exit;
  Size := ACollection.Size;
  if FSize + Size >= Capacity then
  begin
    Capacity := FSize + Size;
    FSize := Capacity;
  end;
  if Size <> 0 then
    MoveArray(FElementData, Index, Index + Size, Size);
  It := ACollection.First;
  Result := It.HasNext;
  while It.HasNext do
  begin
    FElementData[Index] := It.Next;
    Inc(Index);
  end;
end;

function TJclStrArrayList.Add(const AString: string): Boolean;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if FSize = Capacity then
    Grow;
  {$IFNDEF CLR}
  FillChar(FElementData[FSize], SizeOf(string), 0);
  {$ENDIF ~CLR}
  FElementData[FSize] := AString;
  Inc(FSize);
  Result := True;
end;

function TJclStrArrayList.AddAll(const ACollection: IJclStrCollection): Boolean;
var
  It: IJclStrIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
  begin
    // (rom) inlining Add() gives about 5 percent performance increase
    // without THREADSAFE and about 30 percent with THREADSAFE
    if FSize = Capacity then
      Grow;
    {$IFNDEF CLR}
    FillChar(FElementData[FSize], SizeOf(string), 0);
    {$ENDIF ~CLR}
    FElementData[FSize] := It.Next;
    Inc(FSize);
  end;
  Result := True;
end;

procedure TJclStrArrayList.Clear;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  for I := 0 to FSize - 1 do
    FElementData[I] := '';
  FSize := 0;
end;

function TJclStrArrayList.Clone: TObject;
var
  NewList: TJclStrArrayList;
begin
  NewList := TJclStrArrayList.Create(Capacity);
  NewList.AddAll(Self);
  Result := NewList;
end;

function TJclStrArrayList.Contains(const AString: string): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if AString = '' then
    Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AString then
    begin
      Result := True;
      Break;
    end;
end;

function TJclStrArrayList.ContainsAll(const ACollection: IJclStrCollection): Boolean;
var
  It: IJclStrIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
    Result := Contains(It.Next);
end;

function TJclStrArrayList.Equals(const ACollection: IJclStrCollection): Boolean;
var
  I: Integer;
  It: IJclStrIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  for I := 0 to FSize - 1 do
    if FElementData[I] <> It.Next then
      Exit;
  Result := True;
end;

function TJclStrArrayList.First: IJclStrIterator;
begin
  Result := TStrItr.Create(Self);
end;

function TJclStrArrayList.GetString(Index: Integer): string;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    Result := ''
  else
    Result := FElementData[Index];
end;

procedure TJclStrArrayList.SetCapacity(ACapacity: Integer);
begin
  if ACapacity >= FSize then
  begin
    SetLength(FElementData, ACapacity);
    FCapacity := ACapacity;
  end
  else
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
end;

procedure TJclStrArrayList.Grow;
begin
  if Capacity > 64 then
    Capacity := Capacity + Capacity div 4
  else
  if FCapacity = 0 then
    FCapacity := 64
  else
    Capacity := Capacity * 4;
end;

function TJclStrArrayList.IndexOf(const AString: string): Integer;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := -1;
  if AString = '' then
    Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AString then
    begin
      Result := I;
      Break;
    end;
end;

function TJclStrArrayList.IsEmpty: Boolean;
begin
  Result := FSize = 0;
end;

function TJclStrArrayList.Last: IJclStrIterator;
var
  NewIterator: TStrItr;
begin
  NewIterator := TStrItr.Create(Self);
  NewIterator.FCursor := NewIterator.FOwnList.FSize;
  NewIterator.FSize := NewIterator.FOwnList.FSize;
  Result := NewIterator;
end;

function TJclStrArrayList.LastIndexOf(const AString: string): Integer;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := -1;
  if AString = '' then
    Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AString then
    begin
      Result := I;
      Break;
    end;
end;

function TJclStrArrayList.Remove(const AString: string): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if AString = '' then
    Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AString then // Removes all AString
    begin
      FElementData[I] := ''; // Force Release
      if FSize <> I then
        MoveArray(FElementData, I + 1, I, FSize - I);
      Dec(FSize);
      Result := True;
    end;
end;

function TJclStrArrayList.Remove(Index: Integer): string;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  Result := FElementData[Index];
  FElementData[Index] := '';
  if FSize <> Index then
    MoveArray(FElementData, Index + 1, Index, FSize - Index);
  Dec(FSize);
end;

function TJclStrArrayList.RemoveAll(const ACollection: IJclStrCollection): Boolean;
var
  It: IJclStrIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Result := Remove(It.Next) and Result;
end;

function TJclStrArrayList.RetainAll(const ACollection: IJclStrCollection): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  for I := FSize - 1 downto 0 do
    if not ACollection.Contains(FElementData[I]) then
      Remove(I);
end;

procedure TJclStrArrayList.SetString(Index: Integer; const AString: string);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  FElementData[Index] := AString
end;

function TJclStrArrayList.Size: Integer;
begin
  Result := FSize;
end;

function TJclStrArrayList.SubList(First, Count: Integer): IJclStrList;
var
  I: Integer;
  Last: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Last := First + Count - 1;
  if Last >= FSize then
    Last := FSize - 1;
  Result := TJclStrArrayList.Create(Count);
  for I := First to Last do
    Result.Add(FElementData[I]);
end;

//=== { TJclArrayList } ======================================================

constructor TJclArrayList.Create(ACapacity: Integer = DefaultContainerCapacity;
  AOwnsObjects: Boolean = True);
begin
  inherited Create;
  FSize := 0;
  FOwnsObjects := AOwnsObjects;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElementData, FCapacity);
end;

constructor TJclArrayList.Create(const ACollection: IJclCollection;
  AOwnsObjects: Boolean = True);
begin
  // (rom) disabled because the following Create already calls inherited
  // inherited Create;
  if ACollection = nil then
    {$IFDEF CLR}
    raise EJclIllegalArgumentError.Create(RsENoCollection);
    {$ELSE}
    raise EJclIllegalArgumentError.CreateRes(@RsENoCollection);
    {$ENDIF CLR}
  Create(ACollection.Size, AOwnsObjects);
  AddAll(ACollection);
end;

destructor TJclArrayList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TJclArrayList.Insert(Index: Integer; AObject: TObject);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index > FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  if FSize = Capacity then
    Grow;
  if FSize <> Index then
    MoveArray(FElementData, Index, Index + 1, FSize - Index);
  FElementData[Index] := AObject;
  Inc(FSize);
end;

function TJclArrayList.InsertAll(Index: Integer;
  const ACollection: IJclCollection): Boolean;
var
  It: IJclIterator;
  Size: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  if ACollection = nil then
    Exit;
  Size := ACollection.Size;
  if FSize + Size >= Capacity then
    Capacity := FSize + Size;
  if Size <> 0 then
    MoveArray(FElementData, Index, Index + Size, Size);
  It := ACollection.First;
  Result := It.HasNext;
  while It.HasNext do
  begin
    FElementData[Index] := It.Next;
    Inc(Index);
  end;
end;

function TJclArrayList.Add(AObject: TObject): Boolean;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if FSize = Capacity then
    Grow;
  FElementData[FSize] := AObject;
  Inc(FSize);
  Result := True;
end;

function TJclArrayList.AddAll(const ACollection: IJclCollection): Boolean;
var
  It: IJclIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
  begin
    // (rom) inlining Add() gives about 5 percent performance increase
    if FSize = Capacity then
      Grow;
    FElementData[FSize] := It.Next;
    Inc(FSize);
  end;
  Result := True;
end;

procedure TJclArrayList.Clear;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  for I := 0 to FSize - 1 do
    FreeObject(FElementData[I]);
  FSize := 0;
end;

function TJclArrayList.Clone: TObject;
var
  NewList: TJclArrayList;
begin
  NewList := TJclArrayList.Create(Capacity, False); // Only one can have FOwnsObject = True
  NewList.AddAll(Self);
  Result := NewList;
end;

function TJclArrayList.Contains(AObject: TObject): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if AObject = nil then
    Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AObject then
    begin
      Result := True;
      Break;
    end;
end;

function TJclArrayList.ContainsAll(const ACollection: IJclCollection): Boolean;
var
  It: IJclIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
  Result := contains(It.Next);
end;

function TJclArrayList.Equals(const ACollection: IJclCollection): Boolean;
var
  I: Integer;
  It: IJclIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  for I := 0 to FSize - 1 do
    if FElementData[I] <> It.Next then
      Exit;
  Result := True;
end;

procedure TJclArrayList.FreeObject(var AObject: TObject);
begin
  if FOwnsObjects then
  begin
    AObject.Free;
    AObject := nil;
  end;
end;

function TJclArrayList.GetObject(Index: Integer): TObject;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    Result := nil
  else
    Result := FElementData[Index];
end;

procedure TJclArrayList.SetCapacity(ACapacity: Integer);
begin
  if ACapacity >= FSize then
  begin
    SetLength(FElementData, ACapacity);
    FCapacity := ACapacity;
  end
  else
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
end;

procedure TJclArrayList.Grow;
begin
  if Capacity > 64 then
    Capacity := Capacity + Capacity div 4
  else
  if FCapacity = 0 then
    FCapacity := 64
  else
    Capacity := Capacity * 4;
end;

function TJclArrayList.IndexOf(AObject: TObject): Integer;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := -1;
  if AObject = nil then
    Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AObject then
    begin
      Result := I;
      Break;
    end;
end;

function TJclArrayList.First: IJclIterator;
begin
  Result := TItr.Create(Self);
end;

function TJclArrayList.IsEmpty: Boolean;
begin
  Result := FSize = 0;
end;

function TJclArrayList.Last: IJclIterator;
var
  NewIterator: TItr;
begin
  NewIterator := TItr.Create(Self);
  NewIterator.FCursor := NewIterator.FOwnList.FSize;
  NewIterator.FSize := NewIterator.FOwnList.FSize;
  Result := NewIterator;
end;

function TJclArrayList.LastIndexOf(AObject: TObject): Integer;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := -1;
  if AObject = nil then
    Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AObject then
    begin
      Result := I;
      Break;
    end;
end;

function TJclArrayList.Remove(AObject: TObject): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if AObject = nil then
    Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AObject then // Removes all AObject
    begin
      FreeObject(FElementData[I]);
      if FSize <> I then
        MoveArray(FElementData, I + 1, I, FSize - I);
      Dec(FSize);
      Result := True;
    end;
end;

function TJclArrayList.Remove(Index: Integer): TObject;
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  Result := nil;
  FreeObject(FElementData[Index]);
  if FSize <> Index then
    MoveArray(FElementData, Index + 1, Index, FSize - Index);
  Dec(FSize);
end;

function TJclArrayList.RemoveAll(const ACollection: IJclCollection): Boolean;
var
  It: IJclIterator;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Result := Remove(It.Next) and Result;
end;

function TJclArrayList.RetainAll(const ACollection: IJclCollection): Boolean;
var
  I: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Result := False;
  if ACollection = nil then
    Exit;
  for I := FSize - 1 to 0 do
    if not ACollection.Contains(FElementData[I]) then
      Remove(I);
end;

procedure TJclArrayList.SetObject(Index: Integer; AObject: TObject);
{$IFDEF THREADSAFE}
var
  CS: IInterface;
{$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  if (Index < 0) or (Index >= FSize) then
    {$IFDEF CLR}
    raise EJclOutOfBoundsError.Create(RsEOutOfBounds);
    {$ELSE}
    raise EJclOutOfBoundsError.CreateRes(@RsEOutOfBounds);
    {$ENDIF CLR}
  FElementData[Index] := AObject;
end;

function TJclArrayList.Size: Integer;
begin
  Result := FSize;
end;

function TJclArrayList.SubList(First, Count: Integer): IJclList;
var
  I: Integer;
  Last: Integer;
  {$IFDEF THREADSAFE}
  CS: IInterface;
  {$ENDIF THREADSAFE}
begin
  {$IFDEF THREADSAFE}
  CS := EnterCriticalSection;
  {$ENDIF THREADSAFE}
  Last := First + Count - 1;
  if Last >= FSize then
    Last := FSize - 1;
  Result := TJclArrayList.Create(Count, FOwnsObjects);
  for I := First to Last do
    Result.Add(FElementData[I]);
end;

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.

