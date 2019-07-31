unit Unit1;

interface

uses
  YxdWorker, SyncObjs, CommCtrl,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    ListView1: TListView;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
    FLogs: TStrings;       // �����־����
    FAutoScroll: Boolean;  // �Ƿ��Զ�����
    FLogsIsDel: Boolean;   // �Ƿ��Ѿ�ɾ����־
    FLogRef: Integer;      // ״̬������
    FLocker: TCriticalSection;

    FTestRef: Integer;
  public
    { Public declarations }
    procedure UpdateList();
    procedure DoDataChange();
    procedure DoWriteLog(Sender: TObject; const Log: string);
    procedure OnDataChange(AJob: PJob);

    procedure DoTest(AJob: PJob);
    procedure Log(const Text: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  Workers.Post(DoTest, nil);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FLocker.Enter;
  FLogs.Clear;
  FLogsIsDel := True;
  FLocker.Leave;
  DoDataChange();
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Log('дһ����־');
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Workers.Clear(DoTest, nil);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  FLocker.Enter;
  FAutoScroll := CheckBox1.Checked;
  FLocker.Leave;
end;

procedure TForm1.DoDataChange;
begin
  // FLogRef �ܹؼ�������ʲôʱ������������ʾ��
  // ���߳�д��־ʱ��FLogRef > 1����ôҲֻ����һ�Ρ�
  if InterlockedIncrement(FLogRef) = 1 then
    // ��ʱ50ms���¡���ֵ�趨��Խ���б���µ�Խ����
    // ����ʱ�Ļ�������ˢ��̫�죬ռ����Դ��Ƚϴ�
    Workers.Post(OnDataChange, nil, True, 50)
  else
    InterlockedDecrement(FLogRef);
end;

procedure TForm1.DoTest(AJob: PJob);
var
  I, M: Integer;
begin
  M := 0;
  while (not AJob.IsTerminated) and (M < 500) do begin
    Inc(M);
    I := InterlockedIncrement(FTestRef);
    Log(Format('��־���ݡ������ߣ�%d. (%d)', [AJob.Handle, I]));
    Sleep(10);
  end;
end;

procedure TForm1.DoWriteLog(Sender: TObject; const Log: string);
var
  I: Integer;
begin
  if Assigned(FLogs) and (Assigned(Self)) then begin
    FLocker.Enter;
    // ����10����ʱ��ɾ��ǰ���1����
    if FLogs.Count > 100000 then begin
      FLogsIsDel := True;
      for I := 10000 downto 0 do
        FLogs.Delete(I);  
    end;
    // ��ӵ�ǰ��־����
    FLogs.Add('[' + FormatDateTime('hh:mm:ss.zzz', Now) + '] ' + Log);
    FLocker.Leave;
    // ����һ�����֪ͨ
    //DoDataChange();
  end;
end;

// ��ʼ��
procedure TForm1.FormCreate(Sender: TObject);
begin
  FLogsIsDel := False;
  FLogRef := 0;
  FTestRef := 0;
  FLogs := TStringList.Create();
  FLocker := TCriticalSection.Create;
  FAutoScroll := CheckBox1.Checked;
  // ����������������ô�һЩ����Ϊ̫�ٵĻ��������߲����ã�û��ʱ������ʾ��־�ˡ�
  //Workers.MaxWorkers := 512;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Workers.Clear(Self);
  FreeAndNil(FLogs);
  FreeAndNil(FLocker);
end;

procedure TForm1.ListView1Data(Sender: TObject; Item: TListItem);
begin
  FLocker.Enter;
  if Assigned(FLogs) and (Item.Index < FLogs.Count) then
    Item.Caption := FLogs[Item.Index];
  FLocker.Leave;
end;

procedure TForm1.Log(const Text: string);
begin
  if Assigned(Self) then    
    DoWriteLog(Self, Text);
end;

procedure TForm1.OnDataChange(AJob: PJob);
begin
  if Assigned(Self) and Assigned(FLogs) then begin
    UpdateList;
    InterlockedDecrement(FLogRef);
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if not Assigned(Workers) then Exit;  
  Label1.Caption := Format('CPU: %d, Workers: %d,%d, Busy: %d, Idle: %d, Count: %d. '
    + 'JOB: Simple: %d, Repeat: %d, Signal: %d',
    [Workers.CPUNum, Workers.MinWorkers, Workers.MaxWorkers,
      Workers.BusyWorkerCount, Workers.IdleWorkerCount,
      Workers.WorkerCount, Workers.SimpleJobCount, Workers.RepeatJobCount,
      Workers.SignalJobCount]);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  UpdateList;
end;

procedure TForm1.UpdateList;
begin
  if Assigned(ListView1) and (ListView1.HandleAllocated = True) then begin
    ListView_SetItemCountEx(ListView1.Handle, FLogs.Count,
      LVSICF_NOINVALIDATEALL or LVSICF_NOSCROLL); // �޸��б���������������ı������λ��
    if FAutoScroll then
      SendMessage(ListView1.Handle, WM_VSCROLL, SB_BOTTOM, 0);
    if FLogsIsDel then begin
      FLogsIsDel := False;
      ListView1.Invalidate;
    end;
  end;
end;

end.
