
{++

  Copyright (c) 2000-2016 by Golden Software of Belarus, Ltd

  Module

    gsSupportClasses.pas

  Abstract

    Gedemin project. Support classes for event handler (Use only in evt_Base module).

  Author

    Dubrovnik Alexander

  Revisions history

    1.00    ~12.09.03    DAlex        Initial version.

--}

unit gsSupportClasses;

interface

uses
  Windows, classes, gd_KeyAssoc;

type
  TgsBaseSupportClass = class(TComponent)
  private
    FOwnerKey: Integer;
    FStorList: TgdKeyIntAssoc;

  public
    constructor Create2(const Owner: TComponent; const StorList: TgdKeyIntAssoc); virtual;
    destructor  Destroy; override;

    class function GetOriginTypeName: String; virtual; abstract;
  end;

  TgsRect = class(TgsBaseSupportClass)
  private
    FRect: TRect;

  public
    class function GetOriginTypeName: String; override;

    property Left: Integer read FRect.Left write FRect.Left;
    property Top: Integer read FRect.Top write FRect.Top;
    property Right: Integer read FRect.Right write FRect.Right;
    property Bottom: Integer read FRect.Bottom write FRect.Bottom;
    property Rect: TRect read FRect write FRect;
  end;

  TgsPoint = class(TgsBaseSupportClass)
  private
    FPoint: TPoint;

  public
    class function GetOriginTypeName: String; override;

    property X: Integer read FPoint.X write FPoint.X;
    property Y: Integer read FPoint.Y write FPoint.Y;
    property Point: TPoint read FPoint write FPoint;
  end;

implementation

uses
  sysutils;

{ TgsBaseSupportClass }

constructor TgsBaseSupportClass.Create2(const Owner: TComponent;
  const StorList: TgdKeyIntAssoc);
begin
  if Owner = nil then raise Exception.Create('Не передан владелец.');
  if StorList = nil then raise Exception.Create('Не передан список-хранилище.');

  Create(Owner);

  FStorList := StorList;
  FOwnerKey := Integer(Owner);
end;

destructor TgsBaseSupportClass.Destroy;
var
  I: Integer;
begin
  try
    I := FStorList.IndexOf(FOwnerKey);
    if I > - 1 then FStorList.Delete(I);
  except
  end;

  inherited;

end;

{ TgsRect }

class function TgsRect.GetOriginTypeName: String;
begin
  Result := 'TRect';
end;

{ TgsPoint }

class function TgsPoint.GetOriginTypeName: String;
begin
  Result := 'TPoint';
end;

end.
