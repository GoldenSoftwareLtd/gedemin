{

    TNetUsers  VCL component for Delphi 2,3 & 4.

    Author :  Vijendra Kumar H.
              Software Engineer
              Bangalore, INDIA.
              E-Mail : vijendrah@hotmail.com

    Desc   :
              i) Retrieves all the network user names from the given domain
                 If the user don't specify the domain name, it will take from
                 the default domain(i.e. the domain to which the machine is
                 connected)
             ii) Retrieves all Servers(Domains) on the Network

    Note   : This component is a freeware and can be used by anyone.  If you
             use it for a commercial products, please give credit to me.
             You may modify the source code to your desire and if you make any
             cool modifications, please send me the mods!!! :-)

             For getting the default domain name, I had tried a lot and atlast
             I have followed searching the machine name in each domain.  If anyone
             knows a better way of determining the default domain name, please
             inform me.

   Initial Release   : 9th July 1998
   Mods for Delphi 4 : 15th Mar 1999
   Added GetServerList and Getting DefaultDomainName : 20th Mar 1999.
}

Unit NetUsers;

Interface

Uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

Type
  TNetUsers = Class(TComponent)
  Private
    fServer : String;
    fUser:string;
    Function GetUsers : Boolean;
  Protected
    Procedure SetServer(Server : String);
    Procedure SetUser(User : String);
  Public
     List : TStringList;
     Constructor Create(Owner:TComponent); Override;
     Destructor Destroy; Override;
     Function GetServerList : Boolean;
     Function GetUserList : Boolean;
     Function GetDiskUser :boolean;
   //  procedure NetGetResourceInformation; external mpr name 'NetGetResourceInformation';
  Published
    Property Server :String Read fServer Write SetServer;
    Property User :String Read fUser Write SetUser;
  End;

  PnetResourceArr = ^TNetResource;

Procedure Register;

Implementation

Procedure TNetUsers.SetServer(Server : String);
Begin
  If fServer <> Server Then
    fServer := Server;
End;

Procedure TNetUsers.SetUser(User : String);
Begin
  If fUser <> User Then
    fUser := User;
End;

Constructor TNetUsers.Create(Owner:TComponent);
Begin
  Inherited Create(Owner);
  If Not (csDesigning in ComponentState) Then
  Begin
    List := TStringList.Create;
    List.Sorted := True;
  End;
End;

Destructor TNetUsers.Destroy;
Begin
  If Not(csDesigning In ComponentState) Then
    List.Destroy;
  Inherited Destroy;
End;

Function TNetUsers.GetServerList : Boolean;
Type
  {$H+}
  PMyRec = ^MyRec;
   MyRec = Record
             dwScope       : Integer;
             dwType        : Integer;
             dwDisplayType : Integer;
             dwUsage       : Integer;
             LocalName     : String;
             RemoteName    : String;
             Comment       : String;
             Provider      : String;
           End;
  {H-}
Var
  NetResource : TNetResource;
  TempRec     : PMyRec;
  Buf         : Pointer;
  Count,
  BufSize,
  Res         : DWORD;
  lphEnum     : THandle;
  p           : PNetResourceArr;
  i,
  j           : SmallInt;
  NetworkTypeList : TList;
Begin
  Result := False;
  NetworkTypeList := TList.Create;
  List.Clear;
  GetMem(Buf, 8192);
  Try
    Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK, RESOURCEUSAGE_CONTAINER, Nil,lphEnum);
    If Res <> 0 Then Raise Exception(Res);
    Count := $FFFFFFFF;
    BufSize := 8192;
    Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
    If Res = ERROR_NO_MORE_ITEMS Then Exit;
    If (Res <> 0) Then Raise Exception(Res);
    P := PNetResourceArr(Buf);
    For I := 0 To Count - 1 Do
    Begin
      New(TempRec);
      TempRec^.dwScope := P^.dwScope;
      TempRec^.dwType := P^.dwType ;
      TempRec^.dwDisplayType := P^.dwDisplayType ;
      TempRec^.dwUsage := P^.dwUsage ;
      TempRec^.LocalName := StrPas(P^.lpLocalName);
      TempRec^.RemoteName := StrPas(P^.lpRemoteName);
      TempRec^.Comment := StrPas(P^.lpComment);
      TempRec^.Provider := StrPas(P^.lpProvider);
      NetworkTypeList.Add(TempRec);
      Inc(P);
    End;
    Res := WNetCloseEnum(lphEnum);
    If Res <> 0 Then Raise Exception(Res);
    For J := 0 To NetworkTypeList.Count-1 Do
    Begin
      TempRec := NetworkTypeList.Items[J];
      NetResource := TNetResource(TempRec^);
      Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK, RESOURCEUSAGE_CONTAINER, @NetResource,lphEnum);
      If Res <> 0 Then Raise Exception(Res);
      While true Do
      Begin
        Count := $FFFFFFFF;
        BufSize := 8192;
        Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
        If Res = ERROR_NO_MORE_ITEMS Then Break;
        If (Res <> 0) Then Raise Exception(Res);
        P := PNetResourceArr(Buf);
        For I := 0 To Count - 1 Do
        Begin
          List.Add(P^.lpRemoteName);
          Inc(P);
        End;
      End;
    End;
    Res := WNetCloseEnum(lphEnum);
    If Res <> 0 Then Raise Exception(Res);
    Result := True;
    Finally
      FreeMem(Buf);
      NetworkTypeList.Destroy;
  End;
End;

Function TNetUsers.GetUsers : Boolean;
Var
  NetResource : TNetResource;
  Buf         : Pointer;
  Count,
  BufSize,
  Res         : DWord;
  Ind         : Integer;
  lphEnum     : THandle;
  Temp        : PNetResourceArr;
Begin
  Result := False;
  List.Clear;
  GetMem(Buf, 8192);
  Try
    FillChar(NetResource, SizeOf(NetResource), 0);
    NetResource.lpRemoteName := @fServer[1];
    NetResource.dwDisplayType := RESOURCEDISPLAYTYPE_SERVER;
    NetResource.dwUsage := RESOURCEUSAGE_CONTAINER;
    NetResource.dwScope := RESOURCETYPE_DISK;
    Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK, RESOURCEUSAGE_CONTAINER, @NetResource,lphEnum);
    If Res <> 0 Then Exit;
    While True Do
    Begin
      Count := $FFFFFFFF;
      BufSize := 8192;
      Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
      If Res = ERROR_NO_MORE_ITEMS Then break;
      If (Res <> 0) then Exit;
      Temp := PNetResourceArr(Buf);
      For Ind := 0 to Count - 1 do
      Begin
        List.Add(Temp^.lpRemoteName + 2); { Add all the network usernames to List StringList }
        Inc(Temp);
      End;
    End;
    Res := WNetCloseEnum(lphEnum);
    If Res <> 0 Then Raise Exception(Res);
    Result := True;
  Finally
    FreeMem(Buf);
  End;
End;

Function TNetUsers.GetUserList : Boolean;
Var
  ServerList  : TStringList;
  TempInt,
  Ind         : Integer;
  {$IFDEF VER100}
  MaxLen      : Integer;
  {$ELSE}
  MaxLen      : Cardinal;
  {$ENDIF}
  Buf         : PChar;
  MachineName : String;
Begin
  Result := False;
  If fServer = '' Then
  Begin
    If GetServerList Then
    Begin
      ServerList := List;
      GetMem(Buf,255);
      MaxLen := 255;
      GetComputerName(Buf, MaxLen);
      MachineName := StrPas(Buf);
      Freemem(Buf,255);
      For Ind := 0 to ServerList.Count-1 Do
      Begin
        fServer := ServerList.Strings[Ind];
        If GetUsers Then
          If List.Find(MachineName, TempInt) Then
          Begin
            Result := True;
            Exit;
          End;
      End;
    End;
  End
  Else
    Result := GetUsers;
End;

Procedure Register;
Begin
  RegisterComponents('HVK Utility', [TNetUsers]);
End;

Function TNetUsers.GetDiskUser :boolean;
Var
  NetResource : TNetResource;
  Buf         : Pointer;
  Count,
  BufSize,
  Res         : DWord;
  Ind         : Integer;
  lphEnum     : THandle;
  Temp        : PNetResourceArr;
  l:string;
Begin
  Result := False;
  List.Clear;
  GetMem(Buf, 8192);
  //fUser:='\\User_3';
  l:='C:\';
  Try
    FillChar(NetResource, SizeOf(NetResource), 0);
    NetResource.lpRemoteName := @fUser[1]; //@fServer[1];
    NetResource.dwDisplayType := RESOURCEDISPLAYTYPE_SHARE;//RESOURCEDISPLAYTYPE_SERVER;
    NetResource.dwUsage := RESOURCEUSAGE_CONNECTABLE;//SOURCEUSAGE_CONTAINER;
    NetResource.dwScope := 	RESOURCE_CONNECTED;//RESOURCETYPE_DISK;//RESOURCE_GLOBALNET;//
    NetResource.lpLocalName := @l[1];
    NetResource.dwType := RESOURCETYPE_ANY;
    Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK, RESOURCEUSAGE_CONNECTABLE, @NetResource,lphEnum);
    If Res <> 0 Then Exit;
    While True Do
    Begin
      Count := $FFFFFFFF;
      BufSize := 8192;
      Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
      If Res = ERROR_NO_MORE_ITEMS Then break;
      If (Res <> 0) then Exit;
      Temp := PNetResourceArr(Buf);
      For Ind := 0 to Count - 1 do
      Begin
        List.Add(Temp^.lpRemoteName); { Add all the network usernames to List StringList }
        Inc(Temp);
      End;
    End;
    Res := WNetCloseEnum(lphEnum);
    If Res <> 0 Then Raise Exception(Res);
    Result := True;
  Finally
    FreeMem(Buf);
  End;

end;

End.

