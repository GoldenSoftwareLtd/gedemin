// ShlTanya, 11.02.2019

unit gdc_frmNewUserDefined;

interface

uses
  gdc_createable_form, Classes;

type
  Tgdc_frmNewUserDefined = class(TgdcCreateableForm)
  public
    constructor CreateNewUser(AnOwner: TComponent; const Dummy: Integer; const ASubType: String = '');
    constructor CreateUser(AnOwner: TComponent;
      const AFormName: String; const ASubType: String = '');

    //function RUIDClassName: String; override;
  end;

  Cgdc_frmNewUserDefined = class of Tgdc_frmNewUserDefined;

implementation

uses
  SysUtils, gd_createable_form;

constructor Tgdc_frmNewUserDefined.CreateNewUser(AnOwner: TComponent;
  const Dummy: Integer; const ASubType: String = '');
begin
  if ASubType <> '' then
    FSubType := ASubType;

  if SameText(Self.ClassName, 'TgdcCreateableForm') then
  begin
    inherited CreateNewUser(AnOwner, Dummy);
  end
  else
  begin
    Include(FCreateableFormState, cfsUserCreated);
    Include(FCreateableFormState, cfsCreating);
    CreateSubtype(AnOwner, ASubtype)
  end;
  FOnDesigner := True;
  FInChoose := False;
  FgdcAttractiveObject := nil;
end;

constructor Tgdc_frmNewUserDefined.CreateUser(AnOwner: TComponent;
  const AFormName: String; const ASubType: String = '');
begin
  FSubType := ASubType;

  inherited CreateUser(AnOwner, AFormName);

  FInChoose := False;
  FgdcAttractiveObject := nil;

  CreateInherited;
  FOnDesigner := True;
end;

end.
