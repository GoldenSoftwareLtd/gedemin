
{++

  Copyright (c) 2001-2016 by Golden Software of Belarus, Ltd

  Module

    gdReportMenu.pas

  Abstract

    Gedemin project. TgdcReportMenu.

  Author

    Karpuk Alexander

  Revisions history

    1.00    15.02.02    tiptop        Initial version.

--}

unit gd_ReportMenu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, gdcDelphiObject, scrReportGroup, IBDataBase, gdcConstants, rp_ReportClient,
  gdcOLEClassList;

type
  TgdReportMenu = class(TPopupMenu)
  private
    FReportGroup: TscrReportGroup;

    procedure DoOnMenuClick(Sender: TObject);
    procedure DoOnReportListClick(Sender: TObject);
  protected
    procedure FillMenu(const Parent: TObject);

    procedure ReloadGroup;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Popup(X, Y: Integer); override;
  end;

const
  CST_ReportMENU         = 'Редактор скрипт-объектов';

procedure Register;

implementation

uses  gdcBaseInterface, evt_i_Base, gdc_createable_form, IBSQL,
  gd_SetDatabase, gd_i_ScriptFactory, gs_Exception, gd_security;

procedure Register;
begin
  RegisterComponents('gdc', [TgdReportMenu]);
end;

{ TgdReportMenu }

constructor TgdReportMenu.Create(AOwner: TComponent);
begin
  inherited;
  FReportGroup := TscrReportGroup.Create(True);
  if not (csDesigning in ComponentState) then
  begin
    if gdcBaseManager <> nil then
      FReportGroup.Transaction := gdcBaseManager.ReadTransaction;
  end;
end;

destructor TgdReportMenu.Destroy;
begin
  FReportGroup.Free;
  inherited;
end;

procedure TgdReportMenu.DoOnMenuClick(Sender: TObject);
begin
  if Assigned(ClientReport) then
  begin
    if (Owner <> nil) and (Owner is TCustomForm) then
      ClientReport.BuildReport(
        GetGdcOLEObject(Owner) as IDispatch,
        TscrReportItem((TObject(Sender) as TMenuItem).Tag).Id)
    else
      ClientReport.BuildReport( Unassigned,
        TscrReportItem((TObject(Sender) as TMenuItem).Tag).Id)
  end;
end;

procedure TgdReportMenu.DoOnReportListClick(Sender: TObject);
begin
  if Assigned(EventControl) then
    EventControl.EditObject(Owner, emReport);
end;

procedure TgdReportMenu.FillMenu(const Parent: TObject);
var
  I: Integer;
  M: TMenuItem;
  Index: Integer;
  AddCount: Integer;
begin
  Assert((Parent is TMenuItem) or (Parent is TPopUpMenu));
  Assert(FReportGroup <> nil);

  if (Parent is TMenuItem) then
  begin
    Index := (Parent as TMenuItem).Tag;
    (Parent as TMenuItem).Clear;
  end else
    Index := 0;

  AddCount := 0;
  if (FReportGroup.Count > 0) and (Index < FReportGroup.Count) then
  begin
    for I := Index to FReportGroup.Count - 1 do
    begin
      if FReportGroup.GroupItems[Index].Id = FReportGroup.GroupItems[I].Parent then
      begin
        M := TMenuItem.Create(Self);
        M.Tag := I;
        M.Name := 'G' + IntToStr(FReportGroup.GroupItems[I].Id);
        M.Caption := FReportGroup.GroupItems[I].Name;
        if (Parent is TMenuItem) then
          (Parent as TMenuItem).Add(M)
        else
          (Parent as TPopUpMenu).Items.Add(M);
        FillMenu(M);
        Inc(AddCount);
      end;
    end;
    for I := 0 to FReportGroup.GroupItems[Index].ReportList.Count - 1 do
    begin
      M := TMenuItem.Create(Self);
      M.Tag := Integer(FReportGroup.GroupItems[Index].ReportList.Report[I]);
      M.Caption := FReportGroup.GroupItems[Index].ReportList.Report[I].Name;
      M.OnClick := DoOnMenuClick;
      if (Parent is TMenuItem) then
        (Parent as TMenuItem).Add(M)
      else
        (Parent as TPopUpMenu).Items.Add(M);
      Inc(AddCount);
    end;
  end;
  if AddCount = 0 then
  begin
    M := TMenuItem.Create(Self);
    M.Name := 'N' + IntToStr(Index);
    M.Caption := 'Пусто';
    M.Enabled := False;
    if (Parent is TMenuItem) then
      (Parent as TMenuItem).Add(M)
    else
      (Parent as TPopUpMenu).Items.Add(M);
  end;
end;

procedure TgdReportMenu.Popup(X, Y: Integer);
var
  Pt: TPoint;
begin
  ReloadGroup;

  if (X = -1) and (Y = -1) then
    GetCursorPos(Pt)
  else
    Pt := Point(X, Y);

  inherited Popup(Pt.X, Pt.Y);
end;

procedure TgdReportMenu.ReloadGroup;
var
  LocId: Integer;
  F: TgdcCreateableForm;
  M: TMenuItem;
  q: TIBSQL;
  RGK: Integer;
begin
  Assert(FReportGroup <> nil);

  FReportGroup.Clear;
  Self.Items.Clear;

  if IBLogin.IsUserAdmin then
  begin
    M := TMenuItem.Create(Self);
    M.Caption := CST_ReportMENU;
    M.OnClick := DoOnReportListClick;
    Self.Items.Add(M);
  end;

  LocId := TgdcDelphiObject.AddObject(Owner);

  RGK := 0;

  if LocId > 0 then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT reportgroupkey FROM evt_object WHERE id = :id';
      q.ParamByName('id').AsInteger := LocId;
      q.ExecQuery;
      if not q.Eof then
        RGK := q.FieldByName('reportgroupkey').AsInteger;
    finally
      q.Free;
    end;
  end;

  if RGK > 0 then
    FReportGroup.Load(RGK);

  if (FReportGroup.Count > 1) or ((FReportGroup.Count = 1) and (FReportGroup[0].ReportList.Count > 0))  then
  begin
    M := TMenuItem.Create(Self);
    M.Caption := '-';
    Self.Items.Add(M);

    FillMenu(Self);
  end;
  if Owner is TgdcCreateableForm then
  begin
    F := TgdcCreateableForm(Owner);
    if F.gdcObject <> nil then
    begin
      FReportGroup.Load(F.gdcObject.GroupID);
      if (FReportGroup.Count > 1) or ((FReportGroup.Count = 1) and (FReportGroup[0].ReportList.Count > 0))  then
      begin
        M := TMenuItem.Create(Self);
        M.Caption := '-';
        Self.Items.Add(M);

        FillMenu(Self);
      end;
    end;
  end;
end;

end.

