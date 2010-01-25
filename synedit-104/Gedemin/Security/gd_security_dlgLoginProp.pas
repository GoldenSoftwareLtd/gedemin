
{++

  Copyright (c) 1998-2000 by Golden Software of Belarus

  Module

    boSecurity_dlgLoginProp.pas

  Abstract

    A Part of visual component for choosing user, user rights and pasword.
    Dialog window for loggin to database.

  Author

    Andrei Kireev (22-aug-99), Romanovski Denis (04.02.2000)

  Revisions history

--}


unit gd_security_dlgLoginProp;

interface

uses
  Windows, StdCtrls, Controls, Classes, Forms;

type
  TdlgSecLoginProp = class(TForm)
    lSubSystem: TLabel;
    lUser: TLabel;
    lGroups: TLabel;
    lSession: TLabel;
    lStartWork: TLabel;
    lDBVersion: TLabel;
    memoDatabaseParams: TMemo;
    lParamsInfo: TLabel;
    Button1: TButton;

  end;

var
  dlgSecLoginProp: TdlgSecLoginProp;

implementation

{$R *.DFM}

end.

