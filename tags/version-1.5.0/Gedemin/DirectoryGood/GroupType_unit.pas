unit GroupType_unit;

interface

type
  PArChar = ^TArChar;

  TArChar = array[0..179] of char;

type
  PGroupData = ^TGroupData;

  TGroupData = Record
    GroupKey: Integer;
    Name: String[60];
    AFull: Integer;
    AChag: Integer;
    AView: Integer;
  end;

  procedure AssignGroupData(const SourceData: TGroupData; var TargetData: TGroupData);

implementation

procedure AssignGroupData(const SourceData: TGroupData; var TargetData: TGroupData);
begin
  TargetData.GroupKey := SourceData.GroupKey;
  TargetData.Name := SourceData.Name;
  TargetData.AFull := SourceData.AFull;
  TargetData.AChag := SourceData.AChag;
  TargetData.AView := SourceData.AView;
end;

end.
