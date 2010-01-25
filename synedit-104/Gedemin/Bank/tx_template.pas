
unit tx_template;

interface

uses
  Classes, Contnrs, DB;

// tdb -- text database

type
  TtdbFileDef = class(TObject)
  private
    FBeginChars, FEndChars: String;
    FAreas: TObjectList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromFile(const FileName: String);

    property BeginChars: String read FBeginChars write FBeginChars;
    property EndChars: String read FEndChars write FEndChars;
  end;

  TtdbArea = class(TObject)
  private

  public
  end;

implementation


{ TtdbFileDef }

constructor TtdbFileDef.Create;
begin
  inherited;
  FBeginChars := '';
  FEndChars := '';
  FAreas := TObjectList.Create;
end;

destructor TtdbFileDef.Destroy;
begin
  inherited;
  FAreas.Free;
end;

procedure TtdbFileDef.LoadFromFile(const FileName: String);
begin
  
end;

end.
