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
    btnOK: TButton;
    btnCancel: TButton;
    procedure acOkExecute(Sender: TObject);
    procedure acOkUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
  public
    procedure FillrgObjects(ACL: TClassList);
  end;

var
  gdc_dlgQueryDescendant: Tgdc_dlgQueryDescendant;

implementation
  
{$R *.DFM}

procedure Tgdc_dlgQueryDescendant.FillrgObjects(ACL: TClassList);
var
  I: Integer;
  J: Integer;
  SL: TStringList;
  CE: TgdClassEntry;
begin
  for I := 0 to ACL.Count - 1 do
  begin
    CE := gdClassList.Find(ACL[I], '');
    if CE = nil then
      raise Exception.Create('Класс не найден.');

    rgObjects.Items.AddObject(CE.gdcClass.GetDisplayName(''), CE);

    if Height < rgObjects.Items.Count * 30 + 30 then
      Height := rgObjects.Items.Count * 30 + 30;

    SL := TStringList.Create;
    try
      CgdcBase(ACL[I]).GetSubTypeList(SL);
      for J:= 0 to SL.Count - 1 do
      begin
        CE := gdClassList.Find(ACL[I], SL.Values[SL.Names[J]]);

        if CE = nil then
          raise Exception.Create('Класс не найден.');

        rgObjects.Items.AddObject(CE.gdcClass.GetDisplayName(SL.Values[SL.Names[J]]) +
          ' (' + SL.Names[J] + ')', CE);
          
        if Height < rgObjects.Items.Count * 30 + 30 then
          Height := rgObjects.Items.Count * 30 + 30;
      end;
    finally
      SL.Free;
    end;
  end;

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

end.
