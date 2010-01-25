unit tax_objDesignDate;

interface

uses
  tax_frmAvailableTaxFunc_unit, classes;

type
  TtaxGSProp = class(TComponent, ItaxGSProp)
  private
    FIDispatchPropList: TStrings;
    FGSFuncArray: TTaxFuncArray;

    function  GetGSFuncArray: TTaxFuncArray;

    procedure CreateGSFuncArray;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

  end;


implementation

uses
  ActiveX, gdcTaxFunction, Forms, Windows, prp_frmClassesInspector_unit, SysUtils;

var
  taxGSPropObject: TtaxGSProp;

{ TtaxGSProp }

constructor TtaxGSProp.Create(AOwner: TComponent);
begin
  FIDispatchPropList := TStringList.Create;
  TStringList(FIDispatchPropList).Sorted := True;
  FIDispatchPropList.Text := NoShowProp;
  SetLength(FGSFuncArray, 0);
end;

procedure TtaxGSProp.CreateGSFuncArray;
var
  I, J: Integer;
  TypeInfo: ITypeInfo;
  TypeAttr: PTypeAttr;
  BStrList: PBStrList;
  FuncDesc: PFuncDesc;
//  VarDesc: PVarDesc;
  cNames: Integer;
  Str: String;
  pbstrDocString: PWideChar;
  GSArrLength: Integer;

begin
  GSArrLength := 0;
  SetLength(FGSFuncArray, GSArrLength);
  if not Assigned(gsFunction) then
    Exit;

  try
    if (gsFunction.GetTypeInfo(0, 0, TypeInfo) = S_OK) and
      (TypeInfo.GetTypeAttr(TypeAttr) = S_Ok) then
    begin
      New(BStrList);

      for I := 0 to TypeAttr.cFuncs - 1 do
      begin
        if (TypeInfo.GetFuncDesc(I, FuncDesc) = S_OK) and
          (TypeInfo.GetNames(FuncDesc.memid, BStrList, 65535, cNames) =
          S_OK) then
        try
          if FIDispatchPropList.IndexOf(BStrList^[0]) > -1 then Continue;

          if FuncDesc.invkind = DISPATCH_METHOD then
          begin
            Inc(GSArrLength);
            SetLength(FGSFuncArray, GSArrLength);

            Str := '';
            with FGSFuncArray[GSArrLength - 1] do
            begin
              SetLength(ParamArray, cNames - 1);
              for J := 1 to cNames - 1 do
              begin
                if Str <> '' then
                  Str := Str + ', ';
                Str := Str + BStrList^[J];
                ParamArray[J - 1] := BStrList^[J];
              end;
              Str := String(BStrList^[0]) + '(' + Str + ')';

              Name := BStrList^[0];
              Descr := Str;
              FType := ftGS;
              if TypeInfo.GetDocumentation(FuncDesc.memid, nil, @pbstrDocString, nil, nil) = S_OK then
                ShHelp := pbstrDocString;

              SysFreeString(pbstrDocString);
            end;

          end else
            Continue;//            Str := BStrList^[0];
        finally
          try
            for J := cNames - 1  downto 0 do
              SysFreeString(BStrList^[J]);
          except
          end;

          TypeInfo.ReleaseFuncDesc(FuncDesc);
        end
      end;
    end;
  except
  end;
end;

destructor TtaxGSProp.Destroy;
begin
  FIDispatchPropList.Free;
  inherited;
end;

function TtaxGSProp.GetGSFuncArray: TTaxFuncArray;
begin
  Result := FGSFuncArray;
end;

initialization
  taxGSPropObject := TtaxGSProp.Create(Application);
  taxGSProp := taxGSPropObject;

finalization
  taxGSProp := nil;
  FreeAndNil(taxGSPropObject);

end.
