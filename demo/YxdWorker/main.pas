unit main;

interface

uses
  YxdWorker,  YxdHash, 
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls,  
  SyncObjs, ExtCtrls,dateutils,ExtActns;

type
  TForm1 = class(TForm)
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Button25: TButton;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
    Button29: TButton;
    Button30: TButton;
    Button31: TButton;
    Button32: TButton;
    Button33: TButton;
    Button34: TButton;
    Button35: TButton;
    Button36: TButton;
    Button37: TButton;
    Button38: TButton;
    Button39: TButton;
    Button40: TButton;
    Button41: TButton;
    Button42: TButton;
    Button43: TButton;
    Button44: TButton;
    Button45: TButton;
    Button46: TButton;
    Button47: TButton;
    Timer2: TTimer;
    Button48: TButton;
    Button53: TButton;
    Label9: TLabel;
    Timer3: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button29Click(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button30Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button33Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure Button34Click(Sender: TObject);
    procedure Button35Click(Sender: TObject);
    procedure Button36Click(Sender: TObject);
    procedure Button38Click(Sender: TObject);
    procedure Button37Click(Sender: TObject);
    procedure Button39Click(Sender: TObject);
    procedure Button40Click(Sender: TObject);
    procedure Button41Click(Sender: TObject);
    procedure Button42Click(Sender: TObject);
    procedure Button43Click(Sender: TObject);
    procedure Button44Click(Sender: TObject);
    procedure Button46Click(Sender: TObject);
    procedure Button53Click(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FSignalId, FYxdSignalId:Integer;
    FMulticastSignal, FYxdMulticastSignal: Integer;
    YxdWorkers: TYXDWorkers;
    procedure DoPostJobMsg(var AMsg:TMessage);message WM_APP;


    procedure DoYxdPostJobMsg(var AMsg:TMessage);message WM_APP + 10;
    procedure DoYxdSignalJobMsg(var AMsg:TMessage);message WM_APP+ 11;
    procedure DoYxdTimerJobMsg(var AMsg:TMessage);message WM_APP+ 12;
    procedure DoYxdJobProc(AJob:PJob);
    procedure DoYxdPostJobDone(AJob:PJob);
    procedure DoYxdMainThreadWork(AJob:PJob);
    procedure SignalYxdWaitProc(AJob:PJob);
    procedure DoYxdTimerProc(AJob:PJob);
    procedure DoYxdLongtimeWork(AJob:PJob);
    procedure DoYxdLongworkDone(AJob:PJob);
    procedure DoYxdAtTimeJob1(AJob:PJob);
    procedure DoYxdAtTimeJob2(AJob:PJob);
    procedure DoYxdDelayJob(AJob:PJob);
    procedure DoYxdCancelJob(AJob:PJob);
    procedure DoYxdNullJob(AJob:PJob);
    procedure DoYxdTmpTestJob(AJob:PJob);
    procedure DoYxdCOMJob(AJob:PJob);
    procedure DoYxdRandDelay(AJob:PJob);
    procedure DoYxdMsgPackJob(AJob:PJob);
    procedure DoYxdFirstJobStep(AJob:PJob);
    procedure DoYxdSecondJobStep(AJob:PJob);
    procedure SeYxdlfTerminateJob(AJob:PJob);
    procedure DoYxdMulticastSingal1(AJob:PJob);
    procedure DoYxdMulticastSingal2(AJob:PJob);
    procedure DoYxdTimeoutGroupJob(AJob:PJob);
    procedure DoYxdGroupTimeout(ASender:TObject);
    procedure DoYxdGroupTimeoutDone(AJob:PJob);
    procedure DoYxdLoopJob(AJob:PJob);

    function RBCmp(P1, P2: Pointer):Integer;
  public
    { Public declarations }
    procedure ShowMsg(s: string);
  end;
  TAutoFreeTestObject=class
  public
    constructor Create;overload;
    destructor Destroy;override;
  end;
  PAutoFreeRecord=^TAutoFreeRecord;
  TAutoFreeRecord=record
    Id:Integer;
  end;

var
  Form1: TForm1;
implementation
uses comobj;
{$R *.dfm}

procedure TForm1.SeYxdlfTerminateJob(AJob: PJob);
begin
Label8.Caption:='�Խ�����ҵ������ '+IntToStr(AJob.Runs)+'��';
if AJob.Runs=3 then
  begin
  AJob.IsTerminated:=True;
  Label8.Caption:='�Խ�����ҵ�ѽ���.';
  end;
end;

procedure TForm1.ShowMsg(s: string);
begin
  OutputDebugString(PChar(s));
  ShowMessage(s);
end;

procedure TForm1.SignalYxdWaitProc(AJob: PJob);
begin
  PostMessage(Handle,WM_APP+11,AJob.Runs,0);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
YxdWorkers.SendSignal(FYxdSignalId);
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin
  if Assigned(YxdWorker.workers) then begin
    Label9.Caption := Format('YxdWorker: CPU����: %d, �����߳�: %d'#13#10'BUSY�߳�: %d, MaxWorker: %d',
      [YxdWorker.Workers.CPUNum, YxdWorker.Workers.WorkerCount,
        YxdWorker.Workers.BusyWorkerCount, YxdWorker.Workers.MaxWorkers]);
  end else begin
    Label9.Caption := '';
  end;
end;

procedure DoYxdGlobalJob(AJob:PJob);
begin
ShowMessage('ȫ�ֺ�����ҵ�ѵ��á�');
end;

var
  JobTestRef: Integer = 0;

procedure TForm1.Button20Click(Sender: TObject);
begin
{$IFDEF UNICODE}
Workers.Post(
  procedure (AJob:PQJob)
  begin
  ShowMessage('����������ҵ�����Ѿ������á�');
  end,
  nil,True
  );
{$ELSE}
ShowMessage('��ǰDelphi�汾���ͣ�������������֧�֡�');
{$ENDIF}
end;

procedure TForm1.Button25Click(Sender: TObject);
begin
  Timer2Timer(Sender);
end;

procedure TForm1.Button26Click(Sender: TObject);
begin
  YxdWorker.Workers.Post(DoYxdPostJobDone, nil);
end;

procedure TForm1.Button27Click(Sender: TObject);
const
  ACount:Integer=5000000;
var
  I,ARuns:Integer;
  T1:Int64;
  ANeedRuns:Int64;
begin
ARuns:=0;
ANeedRuns:=ACount;
T1:=GetTimeStamp;
//YxdWorkers.Enabled := False;
for I := 0 to ACount-1 do
  begin
  YxdWorkers.Post(DoYxdJobProc, @ARuns);
  end;
//YxdWorkers.Enabled := True;
while (ARuns<ANeedRuns) do begin
  {$IFDEF UNICODE}
  TThread.Yield;
  {$ELSE}
  SwitchToThread;
  {$ENDIF}
  Application.ProcessMessages;
end;
T1:=GetTimeStamp-T1;
ShowMessage('YxdWorker Time Used='+IntToStr(T1)+',Runs='+IntToStr(ARuns)+',Speed='+IntToStr(Int64(ARuns)*1000 div T1));
end;

procedure TForm1.Button28Click(Sender: TObject);
begin
  ShowMessage(IntToStr(YxdWorker.GetTimeStamp));
end;

procedure TForm1.Button29Click(Sender: TObject);
begin
  yxdWorkers.Post(DoYXDMainThreadWork,nil,True);
end;

procedure TForm1.Button30Click(Sender: TObject);
begin
  YxdWorkers.SendSignal('MySignal.Start');
end;

procedure TForm1.Button31Click(Sender: TObject);
begin
  if YxdWorkers.PostLongJob(DoYxdLongtimeWork,nil) = 0 then
    ShowMessage('��ʱ����ҵͶ��ʧ��');
end;

procedure TForm1.Button32Click(Sender: TObject);
begin
ShowMessage('���������5����һ���������Ժ�ÿ��1Сʱ��ʱ����һ�Ρ�');
YxdWorkers.Post(DoYxdAtTimeJob1,nil, true, 5*1000, WODay)
end;

procedure TForm1.Button33Click(Sender: TObject);
begin
  YxdWorkers.Post(DoYxdDelayJob, nil, True, 5*1000)
end;

procedure TForm1.Button34Click(Sender: TObject);
//var
//  ATime:TDateTime;
begin
//ATime:=Now;
//ATime:=IncSecond(ATime,10);
//YxdWorkers.Post(DoYxdAtTimeJob2,ATime,WOHour,nil,True);
//ShowMessage('���������'+FormatDateTime('hh:nn:ss.zzz',ATime)+'ʱ��һ���������Ժ�ÿ��1Сʱ��ʱ����һ�Ρ�');
end;

procedure TForm1.Button35Click(Sender: TObject);
begin
YxdWorkers.Post(DoYxdCancelJob,Pointer(1));
//ֱ��ȡ������ҵ�����е���ҵ�������������û���ļ�ִ��
YxdWorkers.Clear(DoYxdCancelJob,Pointer(1));
YxdWorkers.Post(DoYxdCancelJob,Pointer(2));
//��ҵ�Ѿ������ˣ�ȡ��������ȴ���ҵ���
Sleep(100);
YxdWorkers.Clear(DoYxdCancelJob,Pointer(2));
//�ظ���ҵ
YxdWorkers.Post(DoYxdCancelJob,Pointer(3),False, 0, 1000);
//ֱ��ȡ���ظ���ҵ�����е���ҵ
YxdWorkers.Clear(DoYxdCancelJob,Pointer(3));
//�ظ���ҵ
YxdWorkers.Post(DoYxdCancelJob,Pointer(4),False, 0, 1000);
Sleep(200);
//ֱ��ȡ���ظ���ҵ�����е���ҵ
YxdWorkers.Clear(DoYxdCancelJob,Pointer(4));
//�ź���ҵ����
YxdWorkers.PostWait(DoYxdCancelJob, FYxdSignalId);
YxdWorkers.Clear(DoYxdCancelJob,Pointer(5));
end;

procedure TForm1.Button36Click(Sender: TObject);
var
  AData:PAutoFreeRecord;
begin
yxdWorkers.Post(DoYxdNullJob, TAutoFreeTestObject.Create, false,0, 0, YxdWorker.jdfFreeAsObject);
New(AData);
yxdWorkers.Post(DoYxdNullJob, AData, false, 1000, 0, YxdWorker.jdfFreeAsRecord);
end;

procedure TForm1.Button37Click(Sender: TObject);
begin
YxdWorkers.Post(DoYxdCOMJob,nil);
end;

procedure TForm1.Button38Click(Sender: TObject);
begin
YxdWorkers.SendSignal('MySignal.Start');
YxdWorkers.SendSignal('MySignal.Start');
YxdWorkers.Post(DoYxdNullJob, nil);
YxdWorkers.Clear('MySignal.Start');
end;

procedure TForm1.Button39Click(Sender: TObject);
begin
YxdWorkers.Post(DoYxdRandDelay,nil, False, WOSecond);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
ShowMessage(IntToStr(GetTimeStamp));
end;

procedure TForm1.Button40Click(Sender: TObject);
begin
YxdWorkers.Post(DoYxdGlobalJob,nil,True);
end;

procedure TForm1.Button41Click(Sender: TObject);
begin
YxdWorkers.Post(SeYxdlfTerminateJob, nil, true, 0, 1000);
end;

procedure TForm1.Button42Click(Sender: TObject);
var
  AId:Integer;
  T:Cardinal;
begin
AId:=YxdWorkers.RegisterSignal('Signal.SelfKill');
YxdWorkers.PostWait(SeYxdlfTerminateJob,AId,True);
YxdWorkers.SendSignal(AId);
T:=GetTickCount;
while GetTickCount-T<500 do
  Application.ProcessMessages;
YxdWorkers.SendSignal(AId);
T:=GetTickCount;
while GetTickCount-T<500 do
  Application.ProcessMessages;
YxdWorkers.SendSignal(AId);
T:=GetTickCount;
while GetTickCount-T<500 do
  Application.ProcessMessages;
YxdWorkers.SendSignal(AId);
end;

procedure TForm1.Button43Click(Sender: TObject);
var
  AGroup:TJobGroup;
  AMsg:String;
begin
AGroup:=TJobGroup.Create(False);
if AGroup.WaitFor()<>wrSignaled then
  AMsg:='WaitFor����ҵ�б�ʧ��';
AGroup.Prepare;
AGroup.Add(DoYxdNullJob,nil,false);
AGroup.Add(DoYxdNullJob,nil,false);
AGroup.Add(DoYxdNullJob,nil,false);
AGroup.Add(DoYxdNullJob,nil,false);
AGroup.Add(DoYxdNullJob,nil,false);
JobTestRef := 0;
AGroup.Run;
if AGroup.MsgWaitFor()<>wrSignaled then
  AMsg:='WaitFor�����ҵʧ��';
AGroup.Free;
if Length(AMsg)>0 then
  ShowMessage(AMsg)
else
  ShowMessage('������ҵִ�гɹ���ɡ�');
end;

procedure TForm1.Button44Click(Sender: TObject);
begin
{$IFDEF UNICODE}
YxdWorkers.Post(
  procedure (AJob:PJob)
  begin
  ShowMessage('����������ҵ�����Ѿ������á�');
  end,
  nil,True);
{$ELSE}
ShowMessage('��ǰDelphi�汾���ͣ�������������֧�֡�');
{$ENDIF}
end;

procedure TForm1.Button46Click(Sender: TObject);
begin
yxdWorkers.Post(DoYxdFirstJobStep,nil,false);
end;

procedure TForm1.Button53Click(Sender: TObject);
var
  AGroup:TJobGroup;
  I:Integer;
  ACount:PInteger;
begin
AGroup:=TJobGroup.Create(YxdWorkers, True);
New(ACount);
AGroup.Tag:=ACount;
ACount^:=0;
AGroup.Prepare;
for I := 0 to 10 do
  AGroup.Add(DoYxdTimeoutGroupJob,ACount);
AGroup.Run(100);
AGroup.AfterDone:=DoYxdGroupTimeout;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
//if not Workers.LongtimeJob(DoLongtimeWork,nil) then
//  ShowMessage('��ʱ����ҵͶ��ʧ��');
end;


procedure TForm1.DoPostJobMsg(var AMsg: TMessage);
begin
ShowMessage(Format('��ҵͶ�ĵ�ִ����ʱ %g ms',[AMsg.WParam/10]));
end;

procedure TForm1.DoYxdAtTimeJob1(AJob: PJob);
begin
  ShowMessage('��ʱ5���ִ�е������Ѿ�ִ����'+IntToStr(AJob.Runs+1)+'�Σ�1Сʱ��ִ����һ��');
end;

procedure TForm1.DoYxdAtTimeJob2(AJob: PJob);
begin
  ShowMessage('��ʱ��������'+FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',Now)+'��ʼ��'+IntToStr(AJob.Runs+1)+'��ִ�У�1Сʱ��ִ����һ��'#13#10+
  '���ʱ��:'+IntToStr(AJob.PushTime)+#13#10+
  '����ʱ��:'+IntToStr(AJob.PopTime)
  );
end;

procedure TForm1.DoYxdCancelJob(AJob: PJob);
begin
OutputDebugString(PChar('DoCancelJob('+IntToHex(IntPtr(AJob),8)+')-'+IntToStr(Integer(AJob.Data))+' Started'));
Sleep(5000);
OutputDebugString(PChar('DoCancelJob('+IntToHex(IntPtr(AJob),8)+')-'+IntToStr(Integer(AJob.Data))+' Finished'));
end;

procedure TForm1.DoYxdCOMJob(AJob: PJob);
var
  ADispatch:IDispatch;
begin
AJob.Worker.ComNeeded();
try
  ADispatch:=CreateOleObject('ADODB.Recordset');
except
end;
end;

procedure TForm1.DoYxdDelayJob(AJob: PJob);
begin
  ShowMessage('�ӳٵ������Ѿ�ִ������ˡ�'#13#10+
    '���ʱ��:'+IntToStr(AJob.PushTime)+#13#10+
    '����ʱ��:'+IntToStr(AJob.PopTime)
    );
end;

procedure TForm1.DoYxdFirstJobStep(AJob: PJob);
var
  AUrl:TDownloadURL;
begin
AUrl:=TDownloadUrl.Create(nil);
AUrl.URL:='http://api.map.baidu.com/geocoder/v2/?address=������ͬ��·&output=json&ak=E4805d16520de693a3fe707cdc962045&callback=showLocation';
AUrl.Filename:=ExtractFilePath(Application.ExeName)+'baidu.html';
if AUrl.Execute and (not Assigned(AJob.Data)) then
  begin
  YxdWorkers.Post(DoYxdSecondJobStep,nil,True,0, 0, YxdWorker.jdfFreeAsRecord);
  end;
AUrl.Free;
end;

procedure TForm1.DoYxdGroupTimeout(ASender: TObject);
var
  AGroup:TJobGroup;
begin
AGroup:=ASender as TJobGroup;
OutputDebugString(PChar('���鳬ʱ��ҵʵ�����'+IntToStr(PInteger(AGroup.Tag)^)+'��(�ƻ�10��)'));
Dispose(AGroup.Tag);
FreeAndNil(AGroup);
end;

procedure TForm1.DoYxdGroupTimeoutDone(AJob: PJob);
begin

end;

procedure TForm1.DoYxdJobProc(AJob: PJob);
begin
  AtomicIncrement(PInteger(AJob.Data)^);
  //if GetTimestamp mod 10000 < 5000 then
  //    Sleep(2);
end;

procedure TForm1.DoYxdLongtimeWork(AJob: PJob);
begin
  while not AJob.IsTerminated do
    begin
    Sleep(10);
    //if AJob.EscapedTime>5000 then//5s���������ע���ʱ��λΪ0.1ms
    //  AJob.IsTerminated:=True;
    end;
  if not YxdWorkers.Terminating then//���δ�������򴥷�һ��֪ͨ��ǰ̨����������ǰ̨��һЩ��һ������
    YxdWorkers.sendSignal('Longwork.Done');
end;

procedure TForm1.DoYxdLongworkDone(AJob: PJob);
begin
  ShowMessage('��ʱ����ҵ�Ѿ����');
end;

procedure TForm1.DoYxdLoopJob(AJob: PJob);
begin
while not AJob.IsTerminated do
  begin
  Sleep(50);
  end;
end;

procedure TForm1.DoYxdMainThreadWork(AJob: PJob);
begin
  ShowMessage('���������߳��д������첽��ҵ��');
end;

procedure TForm1.DoYxdMsgPackJob(AJob: PJob);
begin
  //ShowMessage(TQMsgPack(AJob.Data).AsString);
end;

procedure TForm1.DoYxdMulticastSingal1(AJob: PJob);
//var
//  AParams:TQMsgPack;
begin
//AParams:=AJob.Data;
//ShowMessage('����ʾ����DoMulticastSignal1,������'#13#10+AParams.AsString);
end;

procedure TForm1.DoYxdMulticastSingal2(AJob: PJob);
//var
//  AParams:TQMsgPack;
begin
//AParams:=AJob.Data;
//ShowMessage('����ʾ����DoMulticastSignal2,������'#13#10+AParams.AsString);
end;

procedure TForm1.DoYxdNullJob(AJob: PJob);
var
  t: Cardinal;
begin
  OutputDebugString(PChar('JobTestRef: ' + IntToStr(AtomicIncrement(JobTestRef))));     
  OutputDebugString('Null Job Executed');
  t := GetTickCount;
  while not AJob.IsTerminated do begin
    Sleep(100);
    if GetTickCount - t > 1500000 then
      Break;
  end;
end;

procedure TForm1.DoYxdPostJobDone(AJob: PJob);
begin
  PostMessage(Handle,WM_APP + 10,AJob.PopTime-AJob.PushTime,0);
end;

procedure TForm1.DoYxdPostJobMsg(var AMsg: TMessage);
begin
  ShowMessage(Format('��ҵͶ�ĵ�ִ����ʱ %d ms',[AMsg.WParam]));
end;

procedure TForm1.DoYxdRandDelay(AJob: PJob);
begin
//Label7.Caption:='�����ҵĩ���ӳ� '+IntToStr((AJob.PopTime-AJob.PushTime)) +'ms';
//YxdWorkers.Post(AJob.WorkerProc,AJob.Data,True,WOSecond+random(WOSecond));
end;

procedure TForm1.DoYxdSecondJobStep(AJob: PJob);
begin
end;

procedure TForm1.DoYxdSignalJobMsg(var AMsg: TMessage);
begin
  Label6.Caption:=Format('�ź�MySignal.Start�Ѵ��� %d��',[AMsg.WParam]);
end;

procedure TForm1.DoYxdTimeoutGroupJob(AJob: PJob);
begin
  Sleep(50);
  AtomicIncrement(PInteger(AJob.Data)^);
end;

procedure TForm1.DoYxdTimerJobMsg(var AMsg: TMessage);
begin
  Label5.Caption:='��ʱ������ִ��'+IntToStr(AMsg.WParam)+'��';
end;

procedure TForm1.DoYxdTimerProc(AJob: PJob);
begin
  PostMessage(Handle,WM_APP+12,AJob.Runs,0);
end;

procedure TForm1.DoYxdTmpTestJob(AJob: PJob);
begin
  ShowMessage(AJob.ExtData.AsString);
end;

procedure SetLabelValue(P: TComponent);
var i: Integer;
begin
  for i := 0 to P.ComponentCount - 1 do begin
     if P.Components[i] is TLabel then
        TLabel(P.Components[i]).Caption := ''
     else if P.Components[i].ComponentCount > 0 then
        SetLabelValue(P.Components[i])
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  YxdWorkers.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //Cache := TYXDCache.Create();
  //YxdWorker.Workers := TYXDWorkers.Create;
  YxdWorkers := YxdWorker.Workers;
  SetLabelValue(Self);

{$IFDEF USEINLINE}
ReportMemoryLeaksOnShutDown := True;
{$ENDIF}

//ע��һ���źŴ����������Ա��ڴ���ʱִ��
FYxdSignalId:=YxdWorkers.RegisterSignal('MySignal.Start');
YxdWorkers.PostWait(SignalYxdWaitProc,FYxdSignalId);
FYxdMulticastSignal:=YxdWorkers.RegisterSignal('Multicase.Start');
YxdWorkers.PostWait(DoYxdMulticastSingal1,FMulticastSignal);
YxdWorkers.PostWait(DoYxdMulticastSingal2,FMulticastSignal);
YxdWorkers.PostWait(SignalYxdWaitProc, FSignalId);
//ʹ���������������ź�
YxdWorkers.PostWait(DoYxdLongworkDone,YxdWorkers.RegisterSignal('Longwork.Done'),true);
//ע��һ����ʱִ�������źţ�ÿ0.1�봥��һ��
//YxdWorkers.Post(DoYxdTimerProc,nil,False,0,100);
GroupBox2.Caption:='YxdWorker (CPU:'+IntToStr(YxdWorker.GetCpuCount)+')';
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
Workers.Clear(Self);
YxdWorkers.Clear(Self);
end;

function TForm1.RBCmp(P1, P2: Pointer): Integer;
begin
end;

{ TAutoFreeTestObject }

constructor TAutoFreeTestObject.Create;
begin
OutputDebugString('TAutoFreeTestObject.Create');
end;

destructor TAutoFreeTestObject.Destroy;
begin
OutputDebugString('TAutoFreeTestObject.Free');
  inherited;
end;


end.
