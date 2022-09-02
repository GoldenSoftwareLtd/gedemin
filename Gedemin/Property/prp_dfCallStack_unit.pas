// ShlTanya, 25.02.2019, #4135

unit prp_dfCallStack_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, prp_Messages, prp_DOCKFORM_unit, Menus, ActnList, ExtCtrls,
  gdcBaseInterface;

type
  TdfCallStack = class(TDockableForm)
    lvCallStack: TListView;
    procedure lvCallStackDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    function AddListItem(Id: TID; Line: Integer; Caption: String): TListItem;
    procedure DeleteItem(LI: TListItem);
  protected  
    procedure VisibleChanging; override;
  public
    { Public declarations }
    procedure UpdateCallStackList;
    procedure ClearCallStackList;
  end;

var
  dfCallStack: TdfCallStack;

implementation
uses obj_i_Debugger, prp_frmGedeminProperty_Unit;
{$R *.DFM}

{ TdfCallStack }

function TdfCallStack.AddListItem(Id: TID; Line: Integer;
  Caption: String): TListItem;
var
  LI: TListItem;
  EM: TCallStackMessageItem;
begin
  LI := lvCallStack.Items.Add;
  EM := TCallStackMessageItem.Create;
  LI.Data := EM;
  EM.FunctionKey := ID;
  EM.Line := Line;
  LI.Caption := Caption;
  Result := LI;
end;

procedure TdfCallStack.ClearCallStackList;
var
  I: Integer;
begin
  CheckHandle(Self);
  for I := lvCallStack.Items.Count -1 downto 0 do
    DeleteItem(lvCallStack.Items[I]);
end;

procedure TdfCallStack.UpdateCallStackList;
var
  S: TStrings;
  I: Integer;
  L: TList;
begin
  lvCallStack.Items.BeginUpdate;
  try
    ClearCallStackList;
    if (Debugger <> nil) and (Debugger.IsPaused) then
    begin
      S := TStringList.Create;
      try
        Debugger.GetCallStack(S, L);
        if S.Count  > 0 then
        begin
          for I := S.Count - 1 downto 0 do
            //cEmptyContext, потому что в obj_Debugger так
            AddListItem(GetTID(L[I], cEmptyContext), Integer(S.Objects[I]), S[I]);
        end;
      finally
        S.Free;
      end
    end else
      AddListItem(0, 0, 'Process is not accessible');
  finally
    lvCallStack.Items.EndUpdate;
  end;
end;

procedure TdfCallStack.lvCallStackDblClick(Sender: TObject);
begin
  if Assigned(lvCallStack.Selected) and
    Assigned(lvCallStack.Selected.Data) and
    (TCustomMessageItem(lvCallStack.Selected.Data).FunctionKey > 0) then
  begin
    TfrmGedeminProperty(DockForm).FindAndEdit(
      TCustomMessageItem(lvCallStack.Selected.Data).FunctionKey,
      TCustomMessageItem(lvCallStack.Selected.Data).Line + 1, 0,
      True);
  end;
end;

procedure TdfCallStack.DeleteItem(LI: TListItem);
begin
  if LI <> nil then
  begin
    if LI.Data <> nil then TCallStackMessageItem(LI.Data).Free;
    LI.Delete;
  end;
end;

procedure TdfCallStack.FormDestroy(Sender: TObject);
begin
  ClearCallStackList;
  inherited;
end;

procedure TdfCallStack.VisibleChanging;
begin
  inherited;
  if not Visible then
    UpdateCallStackList;
end;

end.
