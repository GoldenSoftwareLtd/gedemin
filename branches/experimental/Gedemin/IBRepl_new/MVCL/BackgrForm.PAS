Unit BackgrForm;

Interface
Uses
   Windows,Messages,Sysutils,Classes,
   Graphics,Controls,Forms,Dialogs;

Type
  Tbackground=Class (Tgraphiccontrol)
  Private
    Images   : tpicture;
    Fonchange: tnotifyevent;
    Procedure PicChange (Sender: TObject);
    Procedure SetPicture (v: TPicture);
  Protected
    Procedure Paint; Override;
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
  Published
    Property Image:TPicture Read Images Write Setpicture;
    Property Align;
End;

Procedure Register;

Implementation

Procedure Register;
Begin;
 RegisterComponents ('Samples', [TBackground]);
End;

Constructor TBackGround.Create (Aowner: TComponent);
Begin;
  Inherited Create (Aowner);
  Images:=Tpicture.Create;
  Images.OnChange:=picChange;
  Align:=alClient;
  Invalidate;
End;

Destructor tbackground.destroy;
begin;
   Images.Onchange:=Nil;
   Images.Free;
   Inherited Destroy;
end;

Procedure Tbackground.PicChange;
Begin;
 if Assigned(FonChange) then Begin
  fOnchange(Self);
 End;
End;

Procedure Tbackground.Paint;
Var
   I,O:Integer;
   W,H:Integer;
Begin
if images.graphic<>nil then begin
 W:=Images.Width;
 H:=Images.Height;
   With Inherited Canvas Do Begin
    For I:=0 To Width Div W Do
     For O:= 0 To Height Div H Do
       draw (i*w,o*h,images.graphic);
     End;
 End;
End;

Procedure Tbackground.Setpicture(V: Tpicture);
Begin
 Images.Assign(V);
 Invalidate;
End;

End.
