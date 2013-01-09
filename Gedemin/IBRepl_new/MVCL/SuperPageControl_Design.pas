unit SuperPageControl_Design;

interface

uses
  DesignIntf, DesignEditors;

type

  TSuperPageEditor = class(TComponentEditor)
  protected
    procedure AddPage; virtual;
    procedure NextPage; virtual;
    procedure PrevPage; virtual;
  public
    procedure Edit; override;
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

var
  ColorDelta: Integer = 16;

procedure Register;

implementation

uses SuperPageControl, SysUtils, Forms, Dialogs, Classes, SpacePanel,
     CheckTreeView;

procedure Register;
begin
  RegisterComponents('Samples', [TSpacePanel]);
  RegisterComponents('Samples', [TCheckTreeView]);
  RegisterComponents('XPComponents', [TSuperPageControl]);
  RegisterComponentEditor(TSuperPageControl, TSuperPageEditor);
  RegisterClass(TSuperTabSheet);
end;

{ TSuperPageEditor }

procedure TSuperPageEditor.AddPage;
var
  TS: TSuperTabSheet;
  F: TCustomForm;
  C: TComponent;
//  I, J: Integer;
//  N: string;
begin
  C := Component;
  while C <> nil do
  begin
    if C is TCustomForm then Break;
    C := C.Owner;
  end;
  F := TCustomForm(C);
  if Assigned(F) then
  begin
    TS := TSuperTabSheet.Create(F);
    TS.PageControl := TSuperPageControl(Component);
    TS.Name := 'SuperTabSheet';
  end;
end;

procedure TSuperPageEditor.Edit;
begin

end;

procedure TSuperPageEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: AddPage;
    1: NextPage;
    2: PrevPage;
  end;
end;

function TSuperPageEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Добавить страницу';
    1: Result := 'Следующая страница';
    2: Result := 'Предыдущая страница';
  else
    Result := '';
  end;
end;

function TSuperPageEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

procedure TSuperPageEditor.NextPage;
begin
  TSuperPageControl(Component).SelectNextPage(True, False);
end;

procedure TSuperPageEditor.PrevPage;
begin
  TSuperPageControl(Component).SelectNextPage(False, False);
end;

end.
