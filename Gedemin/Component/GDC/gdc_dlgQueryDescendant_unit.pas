// ShlTanya, 09.02.2019

unit gdc_dlgQueryDescendant_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, gdcBase, gd_ClassList, Contnrs;

type
  Tgdc_dlgQueryDescendant = class(TForm)
    rgObjects: TRadioGroup;
    ActionList: TActionList;
    acOk: TAction;
    actCancel: TAction;
    actClasses: TAction;
    pnlBtns: TPanel;
    btnClasses: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure acOkExecute(Sender: TObject);
    procedure acOkUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actClassesExecute(Sender: TObject);

  public
    procedure FillrgObjects(CE: TgdClassEntry);
  end;

var
  gdc_dlgQueryDescendant: Tgdc_dlgQueryDescendant;

implementation

{$R *.DFM}

procedure Tgdc_dlgQueryDescendant.FillrgObjects(CE: TgdClassEntry);

  procedure Iterate(CE: TgdClassEntry; ALevel: Integer);
  var
    I: Integer;
    List: TStringList;
  begin
    if CE.Hidden then
      exit;

    if not (CE as TgdBaseEntry).gdcClass.IsAbstractClass then
    begin
      rgObjects.Items.AddObject(StringOfChar(' ', ALevel) + CE.Caption, CE);
      Inc(ALevel, 4);
    end;

    if CE.Count > 0 then
    begin
      List := TStringList.Create;
      try
        for I := 0 to CE.Count - 1 do
          List.AddObject(CE.Children[I].Caption, CE.Children[I]);
        List.Sorted := true;
        for I := 0 to List.Count - 1 do
          Iterate(List.Objects[i] as TgdClassEntry, ALevel);
      finally
        List.Free;
      end;
    end;
  end;
begin
  Iterate(CE, 0);

  if (Height < rgObjects.Items.Count * 24 + 30) and (Height < 540) then
    Height := rgObjects.Items.Count * 24 + 30;

end;

procedure Tgdc_dlgQueryDescendant.acOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgdc_dlgQueryDescendant.acOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := rgObjects.ItemIndex <> -1;
end;

procedure Tgdc_dlgQueryDescendant.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgdc_dlgQueryDescendant.actClassesExecute(Sender: TObject);
var
  I: Integer;
  CE: TgdBaseEntry;
  str: string;
begin
  actClasses.Checked := not actClasses.Checked;

  for I := 0 to rgObjects.Items.Count - 1 do
  begin
    CE := rgObjects.Items.Objects[I] as TgdBaseEntry;
    if actClasses.Checked then
    begin
      str := StringReplace(rgObjects.Items[I], CE.Caption, '', []);
      rgObjects.Items[I] := str + CE.TheClass.ClassName + CE.SubType
    end
    else begin
      str := StringReplace(rgObjects.Items[I], CE.TheClass.ClassName + CE.SubType, '', []);
      rgObjects.Items[I] := str + CE.Caption;
    end;
  end;
end;

end.
