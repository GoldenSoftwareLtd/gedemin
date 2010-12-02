unit flt_QueryFilterGDC;

interface

uses
  flt_sqlFilter;

type
  TQueryFilterGDC = class(TgsQueryFilter)
  private
    procedure pmOptions(Sender: TObject);
    procedure pmAddToSetting(Sender: TObject);
  protected
    function GetFilterPath: String; override;
    function GetOwnerName: String; override;
    function CheckFilterVersion(AnFullName: String): Boolean; override;
    procedure FillPopupMenu(AnSender: TObject); override;
  end;

procedure Register;

implementation

uses
  gdcBase, gdc_createable_form, Classes, SysUtils, Forms,
  flt_sqlfilter_condition_type, Menus, gdcFilter, flt_dlgFilterList_unit,
  at_dlgToSetting_unit;

procedure Register;
begin
  RegisterComponents('gsNew', [TQueryFilterGDC]);
end;

{ TQueryFilterGDC }

function TQueryFilterGDC.CheckFilterVersion(AnFullName: String): Boolean;
begin
  Result := Pos(cFilterVersion, AnFullName) <> 1;
end;

procedure TQueryFilterGDC.FillPopupMenu(AnSender: TObject);
begin
  inherited;

  (AnSender as TPopupMenu).Items.Add(TMenuItem.Create(AnSender as TPopupMenu));
  (AnSender as TPopupMenu).Items[(AnSender as TPopupMenu).Items.Count - 1].OnClick := pmOptions;
  (AnSender as TPopupMenu).Items[(AnSender as TPopupMenu).Items.Count - 1].Name := 'pmiOptions';
  (AnSender as TPopupMenu).Items[(AnSender as TPopupMenu).Items.Count - 1].Caption := 'Свойства';

  (AnSender as TPopupMenu).Items.Add(TMenuItem.Create(AnSender as TPopupMenu));
  (AnSender as TPopupMenu).Items[(AnSender as TPopupMenu).Items.Count - 1].OnClick := pmAddToSetting;
  (AnSender as TPopupMenu).Items[(AnSender as TPopupMenu).Items.Count - 1].Name := 'pmiAddToSetting';
  (AnSender as TPopupMenu).Items[(AnSender as TPopupMenu).Items.Count - 1].Caption := 'Добавить в настройку';
end;

function TQueryFilterGDC.GetFilterPath: String;
begin
  {$IFDEF GEDEMIN}
  Result := AnsiUpperCase(Copy(cFilterVersion + 'GEDEMIN\' +
  {$ELSE}
  Result := AnsiUpperCase(Copy(ChangeFileExt(ExtractFileName(Application.ExeName), '') + '\' +
  {$ENDIF}
    FOwnerName + '\' + Name, 1, 255));
end;

function TQueryFilterGDC.GetOwnerName: String;
begin
  Result := inherited GetOwnerName;
  if (Owner <> nil) then
  begin
    if (Owner is TgdcBase) then
      Result := Owner.ClassName + TgdcBase(Owner).SubType;
    if (Owner is TgdcCreateableForm) then
      Result := Owner.ClassName + TgdcCreateableForm(Owner).SubType;
  end
end;

procedure TQueryFilterGDC.pmAddToSetting(Sender: TObject);
var
  gdcSavedFilter: TgdcSavedFilter;
begin
  if TdlgFilterList(TComponent(Sender).Owner.Owner).lvFilter.Selected = nil then
    Exit;

  gdcSavedFilter := TgdcSavedFilter.Create(nil);
  try
    gdcSavedFilter.ID := Integer(TdlgFilterList(TComponent(Sender).Owner.Owner).lvFilter.Selected.Data);
    gdcSavedFilter.SubSet := 'ByID';
    gdcSavedFilter.Open;
    AddToSetting(False, '', '', gdcSavedFilter, nil);
  finally
    gdcSavedFilter.Free;
  end;
end;

procedure TQueryFilterGDC.pmOptions(Sender: TObject);
var
  gdcSavedFilter: TgdcSavedFilter;
begin
  if TdlgFilterList(TComponent(Sender).Owner.Owner).lvFilter.Selected = nil then
    Exit;

  gdcSavedFilter := TgdcSavedFilter.Create(nil);
  try
    gdcSavedFilter.ID := Integer(TdlgFilterList(TComponent(Sender).Owner.Owner).lvFilter.Selected.Data);
    gdcSavedFilter.SubSet := 'ByID';
    gdcSavedFilter.Open;
    gdcSavedFilter.EditDialog;
  finally
    gdcSavedFilter.Free;
  end;
end;

end.
