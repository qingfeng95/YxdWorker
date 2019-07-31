{*******************************************************}
{                                                       }
{       YxdMemPool    �ڴ��                            }
{                                                       }
{       ��Ȩ���� (C) 2013  YangYxd                      }
{                                                       }
{*******************************************************}
{
 --------------------------------------------------------------------
  ���¼�¼
 --------------------------------------------------------------------
 
 2015.07.21 ver 1.0.1
 --------------------------------------------------------------------
  - ����TAutoSyncMemPool�Զ��ڴ�أ��̰߳�ȫ
  
 2015.06.29 ver 1.0.0
 --------------------------------------------------------------------
  - �ڴ�أ� TMemPool Ϊ���߳���ȫ���ڴ�ء�
             TSyncMemPool Ϊ�̰߳�ȫ���ڴ��
    �Զ��ڴ����TAutoMemPool ���̰߳�ȫ
    �����: TObjectPool �̰߳�ȫ
}

unit YxdMemPool;

interface

{$IF RTLVersion>=24}
{$LEGACYIFEND ON}
{$IFEND}

{$IF defined(FPC) or defined(VER170) or defined(VER180) or defined(VER190) or defined(VER200) or defined(VER210)}
  {$DEFINE USEINLINE}
{$IFEND}

uses
  {$IFDEF MSWINDOWS}Windows, {$ENDIF}
  SysUtils, Classes, SyncObjs, Types;

{$if CompilerVersion < 23}
type
  NativeUInt = Cardinal;
  NativeInt = Integer;
  IntPtr = Cardinal;
{$ifend}

const
  MemoryDelta = $2000; { Must be a power of 2 }
  MaxListSize = MaxInt div 16;

type
  MAddrList = array of Pointer;
  PMAddrList = ^MAddrList;

type
  TMemPoolNotify = procedure(Sender: TObject; const AData: Pointer) of object;
  TMemPoolNew = procedure(Sender: TObject; var AData: Pointer) of object;

type
  /// <summary>
  /// �̶���С�ڴ�أ����̰߳�ȫ
  ///  ע�����Push ʱ��������ѹ��������Ƿ��Ѿ�Push����
  ///  �ظ�Push�ؽ�����AV���쳣�����غ��
  /// </summary>
  TMemPool = class(TObject)
  private
    FPool: MAddrList;
    FCount: Integer;
    FMaxSize: Integer;
    FBlockSize: Cardinal;
    FOnFree: TMemPoolNotify;
    FOnNew: TMemPoolNew;
    FOnReset: TMemPoolNotify;
  protected
    procedure DoFree(const AData: Pointer); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure DoReset(const AData: Pointer); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure DoNew(var AData: Pointer); {$IFDEF USEINLINE}inline;{$ENDIF}
  public
    constructor Create(BlockSize: Cardinal; MaxSize: Integer = 64);
    destructor Destroy; override;
    procedure Clear;
    function Pop(): Pointer;
    procedure Push(const V: Pointer);
    property BlockSize: Cardinal read FBlockSize;
    property MaxSize: Integer read FMaxSize;
    property Count: Integer read FCount;
    property OnFree: TMemPoolNotify read FOnFree write FOnFree;
    property OnNew: TMemPoolNew read FOnNew write FOnNew;
    property OnReset: TMemPoolNotify read FOnReset write FOnReset;
  end;

type
  /// <summary>
  /// �̶���С�ڴ�أ� �̰߳�ȫ
  ///  ע�����Push ʱ��������ѹ��������Ƿ��Ѿ�Push����
  ///  �ظ�Push�ؽ�����AV���쳣�����غ��
  /// </summary>
  TSyncMemPool = class(TObject)
  private
    FPool: MAddrList;
    FCount: Integer;
    FMaxSize: Integer;
    FBlockSize: Cardinal;
    FLocker: TCriticalSection;
    FOnFree: TMemPoolNotify;
    FOnNew: TMemPoolNew;
    FOnReset: TMemPoolNotify;
  protected
    procedure DoFree(const AData: Pointer); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure DoReset(const AData: Pointer); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure DoNew(var AData: Pointer); {$IFDEF USEINLINE}inline;{$ENDIF}
  public
    constructor Create(BlockSize: Cardinal; MaxSize: Integer = 64);
    destructor Destroy; override;
    procedure Clear;
    procedure Lock; {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure Unlock; {$IFDEF USEINLINE}inline;{$ENDIF}
    function Pop(): Pointer;
    procedure Push(const V: Pointer);
    property BlockSize: Cardinal read FBlockSize;
    property MaxSize: Integer read FMaxSize;
    property Count: Integer read FCount;
    property OnFree: TMemPoolNotify read FOnFree write FOnFree;
    property OnNew: TMemPoolNew read FOnNew write FOnNew;
    property OnReset: TMemPoolNotify read FOnReset write FOnReset;
  end;

type
  PPMemPoolHashItem = ^PMemPoolHashItem;
  PMemPoolHashItem = ^TMemPoolHashItem;
  TMemPoolHashItem = record
    Next: PMemPoolHashItem;
    Key: Cardinal;
    Value: TMemPool;
  end;

type
  /// <summary>
  /// �Զ��ڴ�أ����̰߳�ȫ
  /// </summary>
  TAutoMemPool = class(TObject)
  private
    Buckets: array of PMemPoolHashItem;
    FBucketsSize: Cardinal;
    FBucketsPool: TMemPool;

    FPool_4: TMemPool;
    FPool_8: TMemPool;
    FPool_12: TMemPool;
    FPool_16: TMemPool;
    FPool_24: TMemPool;
    FPool_32: TMemPool;
    FPool_48: TMemPool;
    FPool_64: TMemPool;
    FPool_96: TMemPool;
    FPool_128: TMemPool;
    FPool_256: TMemPool;
    FPool_320: TMemPool;
    FPool_512: TMemPool;
    FPool_640: TMemPool;
    FPool_768: TMemPool;
    FPool_1024: TMemPool;
    FPool_1280: TMemPool;
    FPool_2048: TMemPool;
    FPool_4096: TMemPool;
    FPool_5120: TMemPool;
    FPool_8192: TMemPool;
    
    FPoolList: array of TMemPool;
    FPoolListSize: Cardinal;
  protected
    function GetMinMemPool(const ASize: Cardinal): TMemPool;
    function GetMemPool(const ASize: Cardinal): TMemPool;
    procedure AddItem(const V: Pointer; const Pool: TMemPool);
    function FindItem(const V: Pointer): TMemPool;
    procedure ClearBuckets;
  public
		constructor Create(ARefBuckets: Integer = 999983);
		destructor Destroy; override;
    function Pop(const ASize: Cardinal): Pointer; virtual;
    procedure Push(const V: Pointer); virtual;
    function GetMem(const ASize: Cardinal): Pointer; {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure FreeMem(var V: Pointer); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure Clear; virtual;
    function GetRealPopSize(const ASize: Cardinal): Cardinal;
  end;

type
  /// <summary>
  /// �Զ��ڴ�أ��̰߳�ȫ
  /// </summary>
  TAutoSyncMemPool = class(TAutoMemPool)
  private
    FLocker: TCriticalSection;
  public
		constructor Create(ARefBuckets: Integer = 99991);
		destructor Destroy; override;
    function Pop(const ASize: Cardinal): Pointer; override;
    procedure Push(const V: Pointer); override;
    procedure Clear; override;
  end;

type
  /// <summary>
  /// ���ݻ��λ���
  /// <code>
  /// Ĭ�Ϸ���1M�ռ�,���䵽����ͷ�������䣬�������ͷ�����(���账���ٶ��㹻������������ô������)
  /// </code>
  /// </summary>
  TCircleBuffer = class(TObject)
  private
    FDataBuf: Pointer;
    FBufIndex: Integer;
    FBufSize: Integer;
  private
    procedure SetBufSize(const Value: Integer);
	public
		constructor Create(ASize: Integer = 1024 * 1024);
		destructor Destroy; override;
    function GetBuffer(ASize: integer): Pointer;
    property BufferSize: Integer read FBufSize write SetBufSize;
  end;

type
  TObjectPool = class;
  TOnNotifyObject = procedure(Sender: TObjectPool; var Obj: TObject) of Object;
  TOnResetObject = procedure(Sender: TObjectPool; Obj: TObject) of Object;
  /// <summary>
  /// ����أ� �̰߳�ȫ
  /// </summary>
  TObjectPool = class(TObject)
  private
    FUses, FUnUses: TList;
    FObjClass: TClass;
    FMaxObjCount: Integer;
    FLocker: TCriticalSection;
    FOnCreate: TOnNotifyObject;
    FOnReset: TOnResetObject;
    FOnFree: TOnNotifyObject;
  protected
    procedure DoFree(var Obj: TObject); {$IFDEF USEINLINE}inline;{$ENDIF}
  public
    constructor Create(AMaxCount: Integer); overload;
    constructor Create(AMaxCount: Integer; ObjClass: TClass);overload;
    destructor Destroy; override;
    function GetObject: TObject;
    procedure FreeObject(Obj: TObject);
    function Pop: TObject; {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure Push(Obj: TObject); {$IFDEF USEINLINE}inline;{$ENDIF}
    property OnCreateObject: TOnNotifyObject read FOnCreate write FOnCreate;
    property OnResetObject: TOnResetObject read FOnReset write FOnReset;
    property OnFreeObject: TOnNotifyObject read FOnFree write FOnFree;
  end;

implementation

resourcestring
  sErrorGetBufFailed = 'Gain buffer failed. Want to apply to the Cache size exceed range.';

function ClacBlockSize(const V: Cardinal): Cardinal;
begin
  Result := V;
  if Result > 64 then begin
    // ���С��64�ֽڶ��룬������ִ��Ч�����
    if Result mod 64 > 0 then
      Result := (Result div 64 + 1) * 64;
  end;
end;

{ TMemPool }

procedure TMemPool.Clear;
var
  I: Integer;
begin
  I := 0;
  while I < FCount do begin
    DoFree(FPool[I]);
    Inc(I);
  end;
  FCount := 0;
end;

constructor TMemPool.Create(BlockSize: Cardinal; MaxSize: Integer);
begin
  FCount := 0;
  if MaxSize < 4 then
    FMaxSize := 4
  else
    FMaxSize := MaxSize;
  SetLength(FPool, FMaxSize);
  FBlockSize := ClacBlockSize(BlockSize);
end;

destructor TMemPool.Destroy;
begin
  Clear;
  inherited;
end;

procedure TMemPool.DoFree(const AData: Pointer);
begin
  if Assigned(FOnFree) then
    FOnFree(Self, AData)
  else
    FreeMem(AData);
end;

procedure TMemPool.DoNew(var AData: Pointer);
begin
  if Assigned(FOnNew) then
    FOnNew(Self, AData)
  else
    GetMem(AData, FBlockSize);
end;

procedure TMemPool.DoReset(const AData: Pointer);
begin
  if Assigned(FOnReset) then
    FOnReset(Self, AData);
end;

function TMemPool.Pop: Pointer;
begin
  if FCount > 0 then begin
    Dec(FCount);
    Result := FPool[FCount];
    if Result = nil then
      DoNew(Result);
  end else
    DoNew(Result);
  if Result <> nil then
    DoReset(Result);
end;

procedure TMemPool.Push(const V: Pointer);
begin
  if V = nil then Exit;
  if FCount < FMaxSize then begin
    FPool[FCount] := V;
    Inc(FCount);
  end else
    DoFree(V);
end;

{ TSyncMemPool }

procedure TSyncMemPool.Clear;
var
  I: Integer;
begin
  FLocker.Enter;
  try
    I := 0;
    while I < FCount do begin
      DoFree(FPool[I]);
      Inc(I);
    end;
  finally
    FLocker.Leave;
  end;
end;

constructor TSyncMemPool.Create(BlockSize: Cardinal; MaxSize: Integer);
begin
  FLocker := TCriticalSection.Create;
  FCount := 0;
  if MaxSize < 4 then
    FMaxSize := 4
  else
    FMaxSize := MaxSize;
  SetLength(FPool, FMaxSize);
  FBlockSize := ClacBlockSize(BlockSize);
end;

destructor TSyncMemPool.Destroy;
begin
  try
    Clear;
  finally
    FreeAndNil(FLocker);  
    inherited;
  end;
end;

procedure TSyncMemPool.DoFree(const AData: Pointer);
begin
  if Assigned(FOnFree) then
    FOnFree(Self, AData)
  else
    FreeMem(AData);
end;

procedure TSyncMemPool.DoNew(var AData: Pointer);
begin
  if Assigned(FOnNew) then
    FOnNew(Self, AData)
  else
    GetMem(AData, FBlockSize);
end;

procedure TSyncMemPool.DoReset(const AData: Pointer);
begin
  if Assigned(FOnReset) then
    FOnReset(Self, AData);
end;

procedure TSyncMemPool.Lock;
begin
  FLocker.Enter;
end;

function TSyncMemPool.Pop: Pointer;
begin
  Result := nil;
  FLocker.Enter;
  if FCount > 0 then begin
    Dec(FCount);
    Result := FPool[FCount];
  end;
  FLocker.Leave;
  if Result = nil then
    DoNew(Result);
  if Result <> nil then
    DoReset(Result);
end;

procedure TSyncMemPool.Push(const V: Pointer);
var
  ADoFree: Boolean;
begin
  if V = nil then Exit;
  ADoFree := True;
  FLocker.Enter;
  if FCount < FMaxSize then begin
    FPool[FCount] := V;
    Inc(FCount);
    ADoFree := False;
  end;
  FLocker.Leave;
  if ADoFree then 
    DoFree(V);
end;

procedure TSyncMemPool.Unlock;
begin
  FLocker.Leave;
end;

{ TAutoMemPool }

procedure TAutoMemPool.AddItem(const V: Pointer; const Pool: TMemPool);
var
  Hash: Integer;
  Bucket: PMemPoolHashItem;
begin
  Hash := Cardinal(V) mod FBucketsSize;
  Bucket := FBucketsPool.Pop;
  Bucket^.Key := Cardinal(V);
  Bucket^.Value := Pool;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
end;

procedure TAutoMemPool.Clear;
begin
  FPool_4.Clear;
  FPool_8.Clear;
  FPool_12.Clear;
  FPool_16.Clear;
  FPool_24.Clear;
  FPool_32.Clear;
  FPool_48.Clear;
  FPool_64.Clear;
  FPool_96.Clear;
  FPool_128.Clear;
  FPool_256.Clear;
  FPool_320.Clear;
  FPool_512.Clear;
  FPool_640.Clear;
  FPool_768.Clear;
  FPool_1024.Clear;
  FPool_1280.Clear;
  FPool_2048.Clear;
  FPool_4096.Clear;
  FPool_5120.Clear;
  FPool_8192.Clear;
  ClearBuckets(); 
end;

procedure TAutoMemPool.ClearBuckets;
var
  I: Integer;
  P, P1: PMemPoolHashItem; 
begin
  for I := 0 to High(Buckets) do begin
    P := Buckets[I];
    while P <> nil do begin
      P1 := P.Next;
      FBucketsPool.Push(P);
      P := P1;
    end;  
  end;
  FillChar(Buckets[0], Length(Buckets) * SizeOf(PMemPoolHashItem), 0);
  FBucketsPool.Clear;
end;

constructor TAutoMemPool.Create(ARefBuckets: Integer);
var
  I: Integer;
begin
  FBucketsPool := TMemPool.Create(SizeOf(TMemPoolHashItem), 8192);
  FPool_4 := TMemPool.Create(4, 2048);
  FPool_8 := TMemPool.Create(8, 2048);
  FPool_12 := TMemPool.Create(12, 1024);
  FPool_16 := TMemPool.Create(16, 1024);
  FPool_24 := TMemPool.Create(24, 1024);
  FPool_32 := TMemPool.Create(32, 1024);
  FPool_48 := TMemPool.Create(48, 1024);
  FPool_64 := TMemPool.Create(64, 1024);
  FPool_96 := TMemPool.Create(96, 1024);
  FPool_128 := TMemPool.Create(128, 1024);
  FPool_256 := TMemPool.Create(256, 1024);
  FPool_320 := TMemPool.Create(320, 1024);
  FPool_512 := TMemPool.Create(512, 1024);
  FPool_640 := TMemPool.Create(640, 1024);
  FPool_768 := TMemPool.Create(768, 1024);
  FPool_1024 := TMemPool.Create(1024, 512);
  FPool_1280 := TMemPool.Create(1280, 512);
  FPool_2048 := TMemPool.Create(2048, 512);
  FPool_4096 := TMemPool.Create(4096, 256);
  FPool_5120 := TMemPool.Create(5120, 128);
  FPool_8192 := TMemPool.Create(8192, 128);

  SetLength(FPoolList, 8192);
  for I := 0 to Length(FPoolList) - 1 do
    FPoolList[I] := GetMinMemPool(I);
  FPoolListSize := Length(FPoolList);
  
  SetLength(Buckets, ARefBuckets);
  FBucketsSize := Length(Buckets);
end;

destructor TAutoMemPool.Destroy;
begin
  ClearBuckets();
  FreeAndNil(FPool_4);
  FreeAndNil(FPool_8);
  FreeAndNil(FPool_12);
  FreeAndNil(FPool_16);
  FreeAndNil(FPool_24);
  FreeAndNil(FPool_32);
  FreeAndNil(FPool_48);
  FreeAndNil(FPool_64);
  FreeAndNil(FPool_96);
  FreeAndNil(FPool_128);
  FreeAndNil(FPool_256);
  FreeAndNil(FPool_320);
  FreeAndNil(FPool_512);
  FreeAndNil(FPool_640);
  FreeAndNil(FPool_768);
  FreeAndNil(FPool_1024);
  FreeAndNil(FPool_1280);
  FreeAndNil(FPool_2048);
  FreeAndNil(FPool_4096);
  FreeAndNil(FPool_5120);
  FreeAndNil(FPool_8192);
  FreeAndNil(FBucketsPool);
  inherited;
end;

function TAutoMemPool.FindItem(const V: Pointer): TMemPool;
var
  P: PMemPoolHashItem;
  Prev: PPMemPoolHashItem;
begin
  Prev := @Buckets[Cardinal(V) mod FBucketsSize];
  while Prev^ <> nil do begin
    if Prev^.Key = Cardinal(V) then begin
      P := Prev^;
      Result := P.Value;
      Prev^ := P^.Next;
      FBucketsPool.Push(P);
      Exit;
    end else
      Prev := @Prev^.Next;
  end;
  Result := nil;
end;

procedure TAutoMemPool.FreeMem(var V: Pointer);
begin
  Push(V);
end;

function TAutoMemPool.GetMem(const ASize: Cardinal): Pointer;
begin
  Result := Pop(ASize);
end;

function TAutoMemPool.GetMemPool(const ASize: Cardinal): TMemPool;
begin
  if ASize < FPoolListSize then
    Result := FPoolList[ASize]
  else
    Result := nil;
end;

function TAutoMemPool.GetMinMemPool(const ASize: Cardinal): TMemPool;
begin
  if ASize <= 4 then
    Result := FPool_4
  else if ASize <= 8 then
    Result := FPool_8
  else if ASize <= 12 then
    Result := FPool_12
  else if ASize <= 16 then
    Result := FPool_16
  else if ASize <= 24 then
    Result := FPool_24
  else if ASize <= 32 then
    Result := FPool_32
  else if ASize <= 48 then
    Result := FPool_48
  else if ASize <= 64 then
    Result := FPool_64
  else if ASize <= 96 then
    Result := FPool_96
  else if ASize <= 128 then
    Result := FPool_128
  else if ASize <= 256 then
    Result := FPool_256
  else if ASize <= 320 then
    Result := FPool_320
  else if ASize <= 512 then
    Result := FPool_512
  else if ASize <= 640 then
    Result := FPool_640
  else if ASize <= 768 then
    Result := FPool_768
  else if ASize <= 1024 then
    Result := FPool_1024
  else if ASize <= 1280 then
    Result := FPool_1280
  else if ASize <= 2048 then
    Result := FPool_2048
  else if ASize <= 4096 then
    Result := FPool_4096
  else if ASize <= 5120 then
    Result := FPool_5120
  else
    Result := FPool_8192;
end;

function TAutoMemPool.GetRealPopSize(const ASize: Cardinal): Cardinal;
begin
  if ASize < FPoolListSize then
    Result := FPoolList[ASize].FBlockSize
  else
    Result := ASize;
end;

function TAutoMemPool.Pop(const ASize: Cardinal): Pointer;
var
  Pool: TMemPool;
begin
  Pool := GetMemPool(ASize);
  if Pool <> nil then begin
    Result := Pool.Pop;
    AddItem(Result, Pool);
  end else
    System.GetMem(Result, ASize);
end;

procedure TAutoMemPool.Push(const V: Pointer);
var
  Pool: TMemPool;
begin
  Pool := FindItem(V);
  if Pool <> nil then
    Pool.Push(V)
  else
    System.FreeMem(V);
end;

{ TCircleBuffer }

constructor TCircleBuffer.Create(ASize: Integer);
begin
  FBufSize := ASize;
  FDataBuf := nil; 
  FBufIndex := 0;
end;

destructor TCircleBuffer.Destroy;
begin
  if FDataBuf <> nil then
    FreeMem(FDataBuf);
  inherited;
end;

function TCircleBuffer.GetBuffer(ASize: integer): Pointer;
begin
  if ASize > FBufSize then
    raise Exception.Create(sErrorGetBufFailed);
  if FBufIndex + ASize >= FBufSize then
    FBufIndex:= 0;
  if FDataBuf = nil then
    FDataBuf := AllocMem(FBufSize);
  Result := Pointer(NativeInt(FDataBuf) + NativeInt(FBufIndex));
  Inc(FBufIndex, ASize);
end;

procedure TCircleBuffer.SetBufSize(const Value: Integer);
begin
  if FBufSize <> Value then begin
    FBufIndex := 0;
    if FDataBuf <> nil then
      FreeMem(FDataBuf);
    FBufSize := Value;
  end;
end;

{ TObjectPool }

constructor TObjectPool.Create(AMaxCount: Integer);
begin
  FUses := TList.Create;
  FUnUses := TList.Create;
  FMaxObjCount := AMaxCount;
  FLocker := TCriticalSection.Create;
end;

constructor TObjectPool.Create(AMaxCount: Integer; ObjClass: TClass);
begin
  Create(AMaxCount);
  FObjClass := ObjClass;
end;

destructor TObjectPool.Destroy;
var
  I: Integer;
begin
  FLocker.Enter;
  try
    for i := 0 to FUses.Count - 1 do
      TObject(FUses[I]).Free;
    for i := 0 to FUnUses.Count - 1 do
      TObject(FUnUses[I]).Free;
  finally
    FLocker.Leave;
    FLocker.Free;
    FUses.Free;
    FUnUses.Free;
  end;
  inherited;
end;

procedure TObjectPool.DoFree(var Obj: TObject);
begin
  if Assigned(FOnFree) then
    FOnFree(Self, Obj)
  else
    Obj.Free;
end;

procedure TObjectPool.FreeObject(Obj: TObject);
begin
  if Obj = nil then Exit;  
  FLocker.Enter;
  try
    FUses.Remove(obj);
    if FUnUses.Count + 1 > FMaxObjCount then begin
      DoFree(Obj)
    end else begin
      if Assigned(FOnReset) then
        FOnReset(Self, Obj);
      FUnUses.Add(Obj);
    end;
  finally
    FLocker.Leave;
  end;
end;

function TObjectPool.GetObject: TObject;
begin
  FLocker.Enter;
  if FUnUses.Count = 0 then begin
    try
      if Assigned(FOnCreate) then
        FOnCreate(Self, Result)
      else if FObjClass.InheritsFrom(TComponent) then
        Result := TComponentClass(FObjClass).Create(nil)
      else if FObjClass <> nil then
        Result := FObjClass.Create
      else
        Result := nil;
      if Result <> nil then
        FUses.Add(Result);
    finally
      FLocker.Leave;
    end;
  end else begin
    Result := TObject(FUnUses[FUnUses.Count - 1]);
    FUnUses.Delete(FUnUses.Count - 1);
    FUses.Add(Result);
    FLocker.Leave;
  end;
end;

function TObjectPool.Pop: TObject;
begin
  Result := GetObject;
end;

procedure TObjectPool.Push(Obj: TObject);
begin
  FreeObject(Obj);
end;

{ TAutoSyncMemPool }

procedure TAutoSyncMemPool.Clear;
begin
  FLocker.Enter;
  inherited Clear;
  FLocker.Leave;
end;

constructor TAutoSyncMemPool.Create(ARefBuckets: Integer);
begin
  inherited Create(ARefBuckets);
  FLocker := TCriticalSection.Create;
end;

destructor TAutoSyncMemPool.Destroy;
begin
  FreeAndNil(FLocker);
  inherited Destroy;
end;

function TAutoSyncMemPool.Pop(const ASize: Cardinal): Pointer;
begin
  FLocker.Enter;
  Result := inherited Pop(ASize);
  FLocker.Leave;
end;

procedure TAutoSyncMemPool.Push(const V: Pointer);
begin
  FLocker.Enter;
  inherited Push(V);
  FLocker.Leave;
end;

initialization

finalization

end.



