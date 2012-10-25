
unit gd_ProgressNotifier_unit;

interface

type
  TgdProgressInfo = record
    InProgress: Boolean;
    Started: TDateTime;
    ProcessName: String;
    NumberOfSteps: Integer;
    CurrentStep: Integer;
    CurrentStepName: String;
    CurrentStepMax: Integer;
    CurrentStepDone: Integer;
  end;

  IgdProgressWatch = interface
    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);
  end;

  TProgressWatchEvent = procedure(Sender: TObject; const AProgressInfo: TgdProgressInfo)
    of object;

implementation

end.
