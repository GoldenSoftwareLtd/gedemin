
unit gd_frmnotebook;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gd_createable_form, Storages;

type
  TfrmNotebook = class(TCreateableForm)
    memo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmNotebook: TfrmNotebook;

implementation

{$R *.DFM}

uses
  gsDesktopManager, dmDatabase_unit, gsStorage;

class function TfrmNotebook.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmNotebook) then
    frmNotebook := Self.Create(AnOwner);
  Result := frmNotebook;
end;

procedure TfrmNotebook.FormCreate(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder('\memo\text', False);
  try
    if Assigned(F) then
      memo.lines.text := F.ReadString('memo');
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure TfrmNotebook.FormDestroy(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder('\memo\text', True);
  try
    if Assigned(F) then
      F.WriteString('memo', memo.lines.text);
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

initialization
  RegisterClass(TfrmNotebook);
end.
