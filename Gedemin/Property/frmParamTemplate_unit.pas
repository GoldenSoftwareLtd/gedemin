unit frmParamTemplate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, prm_ParamFunctions_unit, Menus;

type
  TfrmParamTemplate = class(TForm)
    pnlButtons: TPanel;
    pnlList: TPanel;
    lv: TListView;
    btnOk: TButton;
    btnCancel: TButton;
    pm: TPopupMenu;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);

  private
    FParamList: TgsParamList;

    procedure FillData;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function GetParam: TgsParamData;
  end;

var
  frmParamTemplate: TfrmParamTemplate;

implementation

{$R *.DFM}

uses
  DB, IBSQL, IBBlob, gdcBaseInterface, Clipbrd;

{ TfrmParamTemplate }

constructor TfrmParamTemplate.Create(AnOwner: TComponent);
begin
  inherited;
  FParamList := TgsParamList.Create;
end;

destructor TfrmParamTemplate.Destroy;
begin
  FParamList.Free;
  inherited;
end;

procedure TfrmParamTemplate.FillData;
var
  q: TIBSQL;
  PL: TgsParamList;
  bs: TIBBlobStream;
  J, I: Integer;
begin
  PL := TgsParamList.Create;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT name, enteredparams FROM gd_function';
    q.ExecQuery;
    while not q.EOF do
    begin
      bs := TIBBlobStream.Create;
      try
        bs.Mode := bmRead;
        bs.Database := q.Database;
        bs.Transaction := q.Transaction;
        bs.BlobID := q.FieldByName('enteredparams').AsQuad;
        PL.LoadFromStream(bs);
      finally
        bs.Free;
      end;

      for I := 0 to PL.Count - 1 do
      begin
        if PL.Params[I].ParamType in [prmLinkElement, prmLinkSet] then
        begin
          if FParamList.Find(PL.Params[I]) = -1 then
          begin
            J := FParamList.Add(TgsParamData.Create(PL.Params[I]));
            with lv.Items.Add do
            begin
              Data := Pointer(J);
              Caption := FParamList.Params[J].DisplayName;
              SubItems.Add(FParamList.Params[J].Comment);
              SubItems.Add(FParamList.Params[J].LinkTableName);
              SubItems.Add(FParamList.Params[J].LinkDisplayField);
              SubItems.Add(FParamList.Params[J].LinkPrimaryField);
              SubItems.Add(FParamList.Params[J].LinkConditionFunction);
              SubItems.Add(IntToStr(Integer(FParamList.Params[J].SortOrder)));
              SubItems.Add(q.FieldByName('name').AsTrimString);
            end;
          end;
        end;
      end;

      q.Next;
    end;
  finally
    q.Free;
    PL.Free;
  end;
end;

procedure TfrmParamTemplate.FormCreate(Sender: TObject);
begin
  FillData;
end;

function TfrmParamTemplate.GetParam: TgsParamData;
begin
  if lv.Selected <> nil then
    Result := FParamList.Params[Integer(lv.Selected.Data)]
  else
    Result := nil;
end;

procedure TfrmParamTemplate.N1Click(Sender: TObject);
begin
  if (lv.Selected <> nil) and (lv.Selected.SubItems.Count >= 7) then
  begin
    Clipboard.AsText := lv.Selected.SubItems[6];
  end;
end;

end.
