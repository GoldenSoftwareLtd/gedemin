unit gsSynEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SynEdit, SynDBEdit, contnrs;

type
  TgsLineState = class
  public
    property ShowOnly: Boolean;
  end;

type
  TgsSynEdit = class(TDBSynEdit)
  private
    { Private declarations }
    FObjectsList: TObjectList;
  protected
    { Protected declarations }
    procedure UpdateData(Sender: TObject); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadMemo;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SynEdit', [TgsSynEdit]);
end;

{ TgsSynEdit }

constructor TgsSynEdit.Create(AOwner: TComponent);
begin
  inherited;

  FObjectsList := TObjectList.Create(True);
end;

destructor TgsSynEdit.Destroy;
begin
  inherited;
  
  FObjectsList.Free;
end;

procedure TgsSynEdit.LoadMemo;
var
  I: Integer;
  LS: TgsLineState;
begin
  inherited;

  FObjectsList.Clear;
  for I := 0 to Lines.Count - 1 do
  begin
    LS := TgsLineState.Create;
    FObjectsList.Add(LS);
    LS.ShowOnly := False;
    Lines.Objects[I] := LS;
  end;
end;

procedure TgsSynEdit.UpdateData(Sender: TObject);
var
  BlobStream: TStream;
  lLines: TStrings;
begin
  lLines := TSttinsList.Create;
  try
    lLines.Assign(Lines);
    if FDataLink.Field.IsBlob then
    begin
      BlobStream := FDataLink.DataSet.CreateBlobStream(FDataLink.Field, bmWrite);
      try
        Lines.SaveToStream(BlobStream);
      finally
        BlobStream.Free;
      end;
    end else
      FDataLink.Field.AsString := Text;
  finally
    lLines.Free;
  end;
end;

end.
