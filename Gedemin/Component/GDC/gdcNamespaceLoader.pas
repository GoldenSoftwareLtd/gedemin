
unit gdcNamespaceLoader;

interface

type
  TgdcNamespaceLoader = class(TObject)
  private
    FDontRemove: Boolean;
    FAlwaysOverwrite: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    property AlwaysOverwrite: Boolean read FAlwaysOverwrite write FAlwaysOverwrite;
    property DontRemove: Boolean read FDontRemove write FDontRemove;
  end;

implementation

{ TgdcNamespaceLoader }

constructor TgdcNamespaceLoader.Create;
begin

end;

destructor TgdcNamespaceLoader.Destroy;
begin
  inherited;
end;

end.
