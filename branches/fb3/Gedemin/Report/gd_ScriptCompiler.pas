unit gd_ScriptCompiler;

interface

uses
  classes, contnrs;

procedure InternalScriptList(const Script: String; NameList: TStrings;
  ErrorList: TObjectList = nil; FunctionKey: Integer = 0);

implementation

uses
  Sysutils, gd_i_ScriptFactory;

procedure InternalScriptList(const Script: String;
  NameList: TStrings; ErrorList: TObjectList; FunctionKey: Integer);
//procedure TgdcCustomFunction.InternalScriptList(const Script: String;
//  NameList: TStrings);
var
  LStr: String;
  classDetect: Boolean;
//  I: Integer;
  LineNum: Integer;

const
  prClass      = 'CLASS ';
  prSub        = 'SUB ';
  prFunction   = 'FUNCTION ';
  prComment    = '''';
  prSpace      = ' ';
  prStr        = '"';
  prStrExt     = ' _';
  prInNewStr   = ':';
  prStrExtSymb = '_';
  prVoid       = '';


  function CutCommentAndStrConst(const Str: String; const BeginPos: Integer; ResList: TStrings): Boolean;
  var
    CI, CL: Integer;
    CStrDetect: Boolean;
    CName: String;
    CEndNamePos: Integer;
    CNewStrPos: Integer;

    function GetNextEndNamePos(const StrWithName: String; BeginNamePos: Integer): Integer;
    var
      GEI: Integer;
    begin
      for GEI := BeginNamePos to Length(StrWithName) do
      begin
        if StrWithName[GEI] in [':', '(', #13, ''''] then
        begin
          Result := GEI;
          Exit;
        end;
      end;
      Result := Length(StrWithName);
    end;

    function GetNewStrPos(const Str: String; const CurPos: Integer): Integer;
    var
      GNI: Integer;
    begin
      Result := Length(Str);
      for GNI := CurPos to Result - 1 do
      begin
        if (Str[GNI] = #13) and (Str[GNI + 1] = #10) then
        begin
          Result := GNI + 2;
          Inc(LineNum);
          Break;
        end;
      end;
    end;

    function GetName(const DeclName: String): String;
    var
      ANDeclSize: Integer;
    begin
      Result := '';
      ANDeclSize := Length(DeclName);
      if (System.Copy(Str, CI, ANDeclSize) = DeclName) then
      begin
        CEndNamePos := GetNextEndNamePos(Str, CI + ANDeclSize);
        CName := Trim(System.Copy(Str, CI + ANDeclSize, CEndNamePos - (CI + ANDeclSize)));
        CI := CEndNamePos;

        while CName = prStrExtSymb do
        begin
          CNewStrPos := GetNewStrPos(Str, CI);
          CName := Trim(System.Copy(Str, CI, CNewStrPos - CI));
          //name not correct
          if CName <> prVoid then
            Break;
          CI := CNewStrPos;
          CNewStrPos := GetNextEndNamePos(Str, CI);
          CName := Trim(System.Copy(Str, CI, CNewStrPos - CI));
          CI := CNewStrPos;
        end;
        Result := CName;
      end;
    end;

    procedure AddName(const AddName: String; AddSFID: Integer);
    var
      AddCompileItem: TgdCompileItem;
    begin
      if (ErrorList <> nil) and (ResList.IndexOf(AddName) > -1) then
      begin
        AddCompileItem := TgdCompileItem.Create;
        AddCompileItem.AutoClear := True;
        AddCompileItem.Line := AddSFID;
        AddCompileItem.Msg :=
          '[ќшибка имени] ќбъ€вление имени ' + AddName + ' дублируетс€.';
        AddCompileItem.SFID := FunctionKey;
        ErrorList.Add(AddCompileItem);
      end;
      ResList.AddObject(AddName, TObject(AddSFID));
    end;

  begin
    CL := Length(Str);
    Result := True;
    if System.Copy(Str, CL - 1, 2) = prStrExt then
      Result := False;
    CI := BeginPos;
//    CSeach := True;
    CStrDetect := False;

    CEndNamePos := 0;

    while CI < CL do
    begin
      if Str[CI] <> prSpace then
        Break;
      Inc(CI);
    end;

    CName := '';

    if not classDetect then
    begin
      ClassDetect := (System.Copy(Str, CI, 6) = prClass);
      if not classDetect then
      begin
        CName := GetName(prSub);
        if Length(CName) > 0 then
          AddName(CName, LineNum)
//         ResList.AddObject(CName, TObjectList(LineNum))
        else
          begin
            CName := GetName(prFunction);
            if Length(CName) > 0 then
              AddName(CName, LineNum);
//              ResList.AddObject(CName, TObjectList(LineNum));
          end;

      end;
    end else
      begin
        if System.Copy(Str, CI, 4) = 'END ' then
        begin
          ClassDetect := not (GetName('END ') = 'CLASS');
        end;
      end;


    CL := Length(Str);

    while CI <= CL do
    try
      if not CStrDetect then
      begin
        case Str[CI] of
          prStr:
          begin
            CStrDetect := True;
          end;
          prComment:
          begin
//            CI := GetNewStrPos(Str, CI) - 1;
            if CI < CL then
            begin
              CI := GetNewStrPos(Str, CI);
              Result := CutCommentAndStrConst(Str, CI, ResList);
              Break;
            end;
          end;
          prInNewStr:
          begin
            Result := CutCommentAndStrConst(Str, CI + 1, ResList);
            Break;
          end;
          prStrExtSymb:
          begin
            if (CI > 1) and (Str[CI - 1] = prSpace) then
            begin
              CI := GetNewStrPos(Str, CI + 1);
              Result := CutCommentAndStrConst(Str, CI + 2, ResList);
              Break;
            end;
          end;
          #13:
          begin
            if Str[CI + 1] = #10 then
            begin
              Inc(LineNum);
              Result := CutCommentAndStrConst(Str, CI + 2, ResList);
              Break;
            end;
          end;
        end;
      end else
        begin
          if Str[CI] = prStr then
          begin
            if Str[CI + 1] <> prStr then
              CStrDetect := False
            else
              Inc(CI);
          end;
        end;
    finally
      Inc(CI);
    end
  end;

begin
  LineNum := 1;
  ClassDetect := False;
  NameList.Clear;
  LStr := AnsiUpperCase(Script);
  CutCommentAndStrConst(LStr, 1, NameList);
end;

end.
