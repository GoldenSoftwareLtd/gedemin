
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    xdbase.pas

  Abstract

    TDatabase component where Connected property not stored and
    loaded as False.

  Author

    Andrei Kireev (12-Mar-98)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    12-Mar-98    andreik    Initial version.

--}

unit xDBase;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DBTables;

type
  TxDatabase = class(TDatabase)
  protected
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property Connected stored False default False;
  end;

procedure Register;

implementation

constructor TxDatabase.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Connected := False;
end;

procedure TxDatabase.Loaded;
begin
  inherited Loaded;
  Connected := False;
  if not (csDesigning in ComponentState) then
    DatabaseName := '_' + DatabaseName;
end;

procedure Register;
begin
  RegisterComponents('gsDB', [TxDatabase]);
end;

end.

