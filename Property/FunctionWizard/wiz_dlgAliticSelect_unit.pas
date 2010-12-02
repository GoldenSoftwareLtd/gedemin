{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}
unit wiz_dlgAliticSelect_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls, CheckLst, contnrs;

type
  TdlgAnaliticSelect = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    clbAlalitics: TCheckListBox;
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FFields: TObjectList;
    FAnalitics: string;

    procedure UpdateAnalitcs;
    procedure InitFields;
    procedure SetAnalitics(const Value: string);
  public
    { Public declarations }
    property Analitics: string read FAnalitics write SetAnalitics;
  end;

var
  dlgAnaliticSelect: TdlgAnaliticSelect;

implementation
uses at_classes, wiz_Utils_unit;
{$R *.DFM}

procedure TdlgAnaliticSelect.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel
end;

procedure TdlgAnaliticSelect.actOkExecute(Sender: TObject);
var
  I: Integer;
begin
  ModalResult := mrOk;
  FAnalitics := '';
  for I := 0 to clbAlalitics.Items.Count - 1 do
  begin
    if clbAlalitics.Checked[i] then
    begin
      if FAnalitics > '' then FAnalitics := FAnalitics + '; ';
      FAnalitics := FAnalitics + TatRelationField(clbAlalitics.Items.Objects[i]).FieldName;
    end;
  end;
end;

procedure TdlgAnaliticSelect.FormCreate(Sender: TObject);
begin
  FFields := TObjectList.Create(False);
  InitFields;
  UpdateAnalitcs;
end;

procedure TdlgAnaliticSelect.InitFields;
var
  R: TatRelation;
  I, Index: Integer;

  function IndexOf(Relation: TatRelation; FieldName: string): integer;
  var
    I: Integer;
  begin
    Result := - 1;
    if Relation <> nil then
    begin
      for I :=  0 to Relation.RelationFields.Count - 1 do
      begin
        if Relation.RelationFields[I].FieldName = FieldName then
        begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;

begin
  FFields.Clear;
  R := atDatabase.Relations.ByRelationName('AC_ENTRY');
  if R <> nil then
    for i := 0 to R.RelationFields.Count - 1 do
      if Pos('USR$', UpperCase(R.RelationFields[I].FieldName)) = 1 then
        FFields.Add(R.RelationFields[I]);
  R := atDataBase.Relations.ByRelationName('AC_Account');
  if R <> nil then
  begin
    for I := FFields.Count - 1 downto 0 do
    begin
      Index := IndexOf(R, TatRelationField(FFields[I]).FieldName);
      if Index = - 1 then FFields.Delete(I);
    end;
  end else
    FFields.Clear;
end;

procedure TdlgAnaliticSelect.UpdateAnalitcs;
var
  I: Integer;
begin
  clbAlalitics.Items.BeginUpdate;
  try
    clbAlalitics.Items.Clear;
    for I := 0 to FFields.Count - 1 do
    begin
      clbAlalitics.Items.AddObject(TatRelationField(FFields[i]).LName,
        FFields[i]);
    end;
  finally
    clbAlalitics.Items.EndUpdate;
  end;
end;

procedure TdlgAnaliticSelect.FormDestroy(Sender: TObject);
begin
  FFields.Free;
end;

procedure TdlgAnaliticSelect.SetAnalitics(const Value: string);
var
  S: TStrings;
  I: Integer;
  Index: Integer;
  function IndexOf(FieldName: string): Integer;
  var
    I: Integer;
  begin
    Result := - 1;
    for I := 0 to clbAlalitics.Items.Count - 1 do
    begin
      if CompareText(FieldName, TatRelationField(clbAlalitics.Items.Objects[I]).FieldName) = 0 then
      begin
        Result := I;
        Break;
      end;
    end;
  end;
begin
  FAnalitics := Value;
  S := TStringList.Create;
  try
    ParseString(Value, S);
    for I := 0 to S.Count - 1 do
    begin
      Index := IndexOf(S[I]);
      if Index > -1 then
      begin
        clbAlalitics.Checked[Index] := True;
      end;
    end;
  finally
    S.free;
  end;
end;

end.
