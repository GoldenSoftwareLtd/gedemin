
{******************************************}
{                                          }
{     FastReport v2.5 - DB components      }
{          Lookup field definition         }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DBNewLookup;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB;

type
  TfrDBLookupFieldForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    NameE: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    TypeCB: TComboBox;
    SizeE: TEdit;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lFieldCB: TComboBox;
    lDatasetCB: TComboBox;
    lKeyCB: TComboBox;
    lResultCB: TComboBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
    procedure lDatasetCBChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FLookup: TDataset;
    procedure Localize;
  public
    { Public declarations }
    Dataset: TDataset;
  end;

implementation

uses FR_DBUtils, FR_Const, FR_Utils {$IFDEF Delphi2}, DBTables {$ENDIF};


{$R *.DFM}

procedure TfrDBLookupFieldForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to 9 do
    TypeCB.Items.Add(frLoadStr(SFieldType1 + i));
  TypeCB.ItemIndex := 0;
  Dataset.GetFieldNames(lFieldCB.Items);
  frGetComponents(DataSet.Owner, TDataSet, lDataSetCB.Items, DataSet);
end;

procedure TfrDBLookupFieldForm.Button1Click(Sender: TObject);
var
  Field: TField;
begin
  ModalResult := mrOk;
  Field := FieldClasses[TypeCB.ItemIndex].Create(Dataset);
  with Field do
  begin
    if Field is TStringField then
      try
        Size := StrToInt(SizeE.Text);
      except
        ModalResult := mrNone;
        MessageBox(0, PChar(frLoadStr(SFieldSizeError)), PChar(frLoadStr(SError)),
          mb_Ok + mb_IconError);
        SizeE.Text := '';
        ActiveControl := SizeE;
        Exit;
      end;
    Lookup := True;
    LookupDataset := FLookup;
    KeyFields := lFieldCB.Text;
    LookupKeyFields := lKeyCB.Text;
    LookupResultField := lResultCB.Text;
    FieldName := NameE.Text;
    Dataset := Self.Dataset;
  end;
end;

procedure TfrDBLookupFieldForm.lDatasetCBChange(Sender: TObject);
begin
  FLookup := frFindComponent(DataSet.Owner, lDatasetCB.Text) as TDataset;
  lKeyCB.Items.Clear;
  lResultCB.Items.Clear;
  if FLookup <> nil then
  begin
    FLookup.GetFieldNames(lKeyCB.Items);
    lResultCB.Items.Assign(lKeyCB.Items);
  end;
  lKeyCB.Text := '';
  lResultCB.Text := '';
end;

procedure TfrDBLookupFieldForm.Localize;
begin
  Caption := frLoadStr(frRes + 3070);
  GroupBox1.Caption := frLoadStr(frRes + 3071);
  Label1.Caption := frLoadStr(frRes + 3072);
  Label2.Caption := frLoadStr(frRes + 3073);
  Label3.Caption := frLoadStr(frRes + 3074);
  GroupBox2.Caption := frLoadStr(frRes + 3075);
  Label4.Caption := frLoadStr(frRes + 3076);
  Label5.Caption := frLoadStr(frRes + 3077);
  Label6.Caption := frLoadStr(frRes + 3078);
  Label7.Caption := frLoadStr(frRes + 3079);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrDBLookupFieldForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.

