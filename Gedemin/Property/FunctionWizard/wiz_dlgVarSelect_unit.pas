// ShlTanya, 09.03.2019

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
unit wiz_dlgVarSelect_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, wiz_FunctionBlock_unit;

type
  TdlgVarSelect = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    lbVars: TListBox;
    mDescription: TMemo;
    Panel6: TPanel;
    Button1: TButton;
    Button2: TButton;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure lbVarsDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbVarsClick(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
  private
    FVarsList: TStrings;
    FVarName: string;
    procedure SetVarsList(const Value: TStrings);
    procedure SetVarName(const Value: string);
  public
    { Public declarations }
    property VarsList: TStrings read FVarsList write SetVarsList;

    property VarName: string read FVarName write SetVarName;
  end;

var
  dlgVarSelect: TdlgVarSelect;

implementation

{$R *.DFM}

procedure TdlgVarSelect.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgVarSelect.actOkExecute(Sender: TObject);
begin
  if lbVars.ItemIndex > - 1 then
  begin
    ModalResult := mrOk;
    FVarName := lbVars.Items[lbVars.ItemIndex];
  end else
    ModalResult := mrNone
end;

procedure TdlgVarSelect.lbVarsDblClick(Sender: TObject);
begin
  actOk.Execute;
end;

procedure TdlgVarSelect.SetVarsList(const Value: TStrings);
var
  I: Integer;
begin
  if Value <> nil then
  begin
    FVarsList.Assign(Value);
    lbVars.Items.Clear;
    for I := 0 to FVarsList.Count - 1 do
    begin
      lbVars.Items.Add(FvarsList.Names[I]);
    end;
  end;
end;

procedure TdlgVarSelect.FormCreate(Sender: TObject);
var
  Strings: TStrings;
begin
  FVarsList := TStringList.Create;
  Strings := TStringList.Create;
  try
    wiz_FunctionBlock_unit.VarsList(Strings);
    SetVarsList(Strings);
  finally
    Strings.Free;
  end;
end;

procedure TdlgVarSelect.FormDestroy(Sender: TObject);
begin
  FVarsList.Free;
end;

procedure TdlgVarSelect.lbVarsClick(Sender: TObject);
begin
  mDescription.Lines.BeginUpdate;
  try
    mDescription.Lines.Clear;
    if lbVars.ItemIndex > - 1 then
      mDescription.Lines.Text :=
        FVarsList.Values[FVarsList.Names[lbVars.ItemIndex]];
  finally
    mDescription.Lines.EndUpdate;
  end;
end;

procedure TdlgVarSelect.actOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbVars.ItemIndex > -1 ;
end;

procedure TdlgVarSelect.SetVarName(const Value: string);
begin
  FVarName := Value;
end;

end.
