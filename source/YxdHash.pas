{*******************************************************}
{                                                       }
{       YxdHash    ��ϣ����ϣ����                     }
{                                                       }
{       ��Ȩ���� (C) 2013 - 2019      YangYxd           }
{                                                       }
{*******************************************************}
{
 --------------------------------------------------------------------
  ˵��
 --------------------------------------------------------------------
  YxdHash�������� swish �� Qrbtree����лswish������qrbtree
  YxdHash�汾�� swish �� YangYxd���У�����һ��Ȩ��
  Qrbtree����QDAC��Ŀ����Ȩ��swish(QQ:109867294)����
  QDAC�ٷ�Ⱥ��250530692

 --------------------------------------------------------------------
  ���¼�¼
 --------------------------------------------------------------------

 2018.03.26 ver 1.0.11
 --------------------------------------------------------------------
  - ��ǿ StringHash, IntHash ����

 2015.06.29 ver 1.0.10
 --------------------------------------------------------------------
  - �� MemPool ���� YxdMemPool ��Ԫ��

 2015.04.22 ver 1.0.9
 --------------------------------------------------------------------
  - �� TYXDHashMapChainTable ����Ϊ TYXDHashMapLinkTable

 2015.03.30 ver 1.0.8
 --------------------------------------------------------------------
  - �޸� TYXDHashMapChainTable: Addʱ�������nil����
  
 2014.11.17 ver 1.0.7
 --------------------------------------------------------------------

 2014.11.08 ver 1.0.6
 --------------------------------------------------------------------
  - ���� TLinkedList �࣬����˫���������

 2014.10.11 ver 1.0.5
 --------------------------------------------------------------------
  - ���� TStringHash �࣬��IniFiles��Ԫ����ֲ������

 2014.10.11 ver 1.0.4
 --------------------------------------------------------------------
  - �޸�TYXDHashMapChainTable��ɾʱ˫��������ҵ�BUG(��Ҫ).
 
 2014.10.10 ver 1.0.3
 --------------------------------------------------------------------
  - ����YxdMemPool��ʹ���ڴ��.
  - ����TYXDHashMapTable
  - ����TYXDHashMapList
  - ����TYXDHashMapChainTable

 2014.08.27 ver 1.0.2
 --------------------------------------------------------------------
  - �Ż���һ��Insert��΢����.
  
 2014.08.15 ver 1.0.1
 --------------------------------------------------------------------
  - �˵�Ԫ��ΪHash�����Ļ�����.
  - ��ԭQRBTree�е�RBNote��Ϊrecord��  
 --------------------------------------------------------------------
}

unit YxdHash;

interface

{$IF defined(FPC) or defined(VER170) or defined(VER180) or defined(VER190) or defined(VER200) or defined(VER210)}
  {$DEFINE USEINLINE}
{$IFEND}

{$DEFINE USE_MEMPOOL}         // �Ƿ�ʹ���ڴ��
{$DEFINE USE_ATOMIC}          // �Ƿ�����ԭ�Ӳ�������
{.$DEFINE AUTORESIE}           // ��ϣ���Ƿ��Զ�����Ͱ��С

uses
  {$IFDEF MSWINDOWs}Windows, {$ENDIF}
  YxdMemPool,
  SysUtils, Classes, Types, SyncObjs;

type
  {$if CompilerVersion < 23}
  NativeUInt = Cardinal;
  NativeInt = Integer;
  {$ifend}
  Number = NativeInt;
  NumberU = NativeUInt;
  PNumber = ^Number;
  PNumberU = ^NumberU;
  PDWORD = ^DWORD;

type
  /// Ͱ��Ԫ�صĹ�ϣֵ�б�
  THashType = NumberU;
  PPHashList = ^PHashList;
  PHashList = ^THashList;
  THashList = {$IFNDEF USEINLINE}object{$ELSE}packed record{$ENDIF}
    Next: PHashList;  // ��һԪ��
    Data: Pointer;    // �������ݳ�Ա
    Hash: THashType;  // ��ǰԪ�ع�ϣֵ����¼�Ա����·���Ͱʱ����Ҫ�ٴ��ⲿ����
    procedure Reset; {$IFDEF USEINLINE}inline;{$ENDIF}
  end;
  THashArray = array of PHashList;

type
  PHashValue = ^THashValue;
  THashValue = {$IFNDEF USEINLINE}object{$ELSE}packed record{$ENDIF}
    Size: Cardinal;       // ���ݴ�С
    Data: Pointer;        // ����ָ��
    function AsString: string;
    procedure Clear;
  end;

type
  PHashMapValue = ^THashMapValue;
  THashMapValue = {$IFNDEF USEINLINE}object{$ELSE}packed record{$ENDIF}
    Value: THashValue;      // ����
    IsStrKey: WordBool;     // �Ƿ����ַ��� Key
    Key: string;            // �ַ��� Key
    function GetNumKey: Number; {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure SetNumKey(const AValue: Number); {$IFDEF USEINLINE}inline;{$ENDIF}
  end;

type
  PHashMapList = ^THashMapList;
  THashMapList = {$IFNDEF USEINLINE}object{$ELSE}packed record{$ENDIF}
    Next: PHashList;      // ��һԪ��
    Data: PHashMapValue;  // �������ݳ�Ա
    Hash: THashType;      // ��ǰԪ�ع�ϣֵ����¼�Ա����·���Ͱʱ����Ҫ�ٴ��ⲿ����
  end;

type
  PHashMapLinkItem = ^THashMapLinkItem;
  THashMapLinkItem = {$IFNDEF USEINLINE}object{$ELSE}packed record{$ENDIF}
    Next: PHashMapLinkItem;
    Prev: PHashMapLinkItem;
    Value: PHashMapValue;
  end;

type
  /// <summary>�ȽϺ���</summary>
  /// <param name='P1'>��һ��Ҫ�ȽϵĲ���</param>
  /// <param name='P2'>�ڶ���Ҫ�ȽϵĲ���</param>
  /// <returns> ���P1<P2������С��0��ֵ�����P1>P2���ش���0��ֵ�������ȣ�����0</returns>
  TYXDCompare = function (P1, P2:Pointer): Integer of object;

type
  /// <summary>ɾ����ϣ��һ��Ԫ�ص�֪ͨ</summary>
  /// <param name="ATable">��ϣ�����</param>
  /// <param name="AHash">Ҫɾ���Ķ���Ĺ�ϣֵ</param>
  /// <param name="AData">Ҫɾ���Ķ�������ָ��</param>
  TYXDHashDeleteNotify = procedure (ATable: TObject; AHash: THashType; AData: Pointer) of object;

type
  PPHashItem = ^PHashItem;
  PHashItem = ^THashItem;
  THashItem = record
    Next: PHashItem;
    Key: string;
    case Int64 of
      0: (Value: Number);
      1: (AsNumber: Number);
      2: (AsDouble: Double);
      3: (AsInt64: Int64);
      4: (AsPointer: Pointer);
  end;

type
  /// <summary>ɾ����ϣ��һ��Ԫ�ص�֪ͨ</summary>
  /// <param name="ATable">��ϣ�����</param>
  /// <param name="AHash">Ҫɾ���Ķ���Ĺ�ϣֵ</param>
  /// <param name="AData">Ҫɾ���Ķ�������ָ��</param>
  TYXDStrHashItemFreeNotify = procedure (Item: PHashItem) of object;

  TStringHash = class
  private
    FCount: Integer;
    FOnFreeItem: TYXDStrHashItemFreeNotify;
    function GetBucketsCount: Integer;
    function GetValueItem(const Key: string): Number;
    procedure SetValueItem(const Key: string; const Value: Number);
    function GetItem(const Key: string): THashItem;
  public
    Buckets: array of PHashItem;
    FLocker: TCriticalSection;
    constructor Create(Size: Cardinal = 331);
    destructor Destroy; override;
    function Find(const Key: string): PPHashItem;
    procedure Clear;
    procedure Lock;
    procedure UnLock;
    procedure Remove(const Key: string);

    procedure GetItems(AList: TList);
    procedure GetKeyList(AList: TStrings);

    procedure DoFreePointerItem(Item: PHashItem); 
    
    function ValueOf(const Key: string; const DefaultValue: Number = -1): Number;
    function Exists(const Key: string): Boolean;

    procedure Add(const Key: string; const Value: Number); overload;
    procedure Add(const Key: string; const Value: Double); overload;
    procedure Add(const Key: string; const Value: Int64); overload;
    procedure Add(const Key: string; const Value: Pointer); overload;

    procedure AddOrUpdate(const Key: string; const Value: Number); overload;
    procedure AddOrUpdate(const Key: string; const Value: Double); overload;
    procedure AddOrUpdate(const Key: string; const Value: Int64); overload;
    procedure AddOrUpdate(const Key: string; const Value: Pointer); overload;

    function Modify(const Key: string; const Value: Number): Boolean; overload;
    function Modify(const Key: string; const Value: Double): Boolean; overload;
    function Modify(const Key: string; const Value: Int64): Boolean; overload;
    function Modify(const Key: string; const Value: Pointer): Boolean; overload;

    function TryGetValue(const Key: string; var OutValue: Number): Boolean; overload;
    function TryGetValue(const Key: string; var OutValue: Int64): Boolean; overload;
    function TryGetValue(const Key: string; var OutValue: Double): Boolean; overload;
    function TryGetValue(const Key: string; var OutValue: Pointer): Boolean; overload;

    function GetInt(const Key: string; const DefaultValue: Number = -1): Number;
    function GetInt64(const Key: string; const DefaultValue: Int64 = -1): Int64;
    function GetFolat(const Key: string; const DefaultValue: Double = -1): Double;
    function GetPointer(const Key: string): Pointer;

    property Values[const Key: string]: Number read GetValueItem write SetValueItem;
    property Items[const Key: string]: THashItem read GetItem;
    property Count: Integer read FCount;
    property BucketsCount: Integer read GetBucketsCount;
    property OnFreeItem: TYXDStrHashItemFreeNotify read FOnFreeItem write FOnFreeItem;
  end;

type
  PPIntHashItem = ^PIntHashItem;
  PIntHashItem = ^TIntHashItem;
  TIntHashItem = record
    Next: PIntHashItem;
    Key: THashType;
    case Int64 of
      0: (Value: Number);
      1: (AsNumber: Number);
      2: (AsDouble: Double);
      3: (AsInt64: Int64);
      4: (AsPointer: Pointer);
  end;

  /// <summary>ɾ����ϣ��һ��Ԫ�ص�֪ͨ</summary>
  /// <param name="ATable">��ϣ�����</param>
  /// <param name="AHash">Ҫɾ���Ķ���Ĺ�ϣֵ</param>
  /// <param name="AData">Ҫɾ���Ķ�������ָ��</param>
  TYXDIntHashItemFreeNotify = procedure (Item: PIntHashItem) of object;

  TIntHash = class
  private
    FCount: Integer;
    FLocker: TCriticalSection;
    FOnFreeItem: TYXDIntHashItemFreeNotify;
    function GetBucketsCount: Integer;
    function GetValueItem(const Key: THashType): Number;
    procedure SetValueItem(const Key: THashType; const Value: Number);
    function GetItem(const Key: THashType): TIntHashItem;
  public
    Buckets: array of PIntHashItem;
    constructor Create(Size: Cardinal = 331);
    destructor Destroy; override;
    procedure Clear;
    procedure Lock;
    procedure UnLock;
    function Find(const Key: THashType): PPIntHashItem;
    function Remove(const Key: THashType): Boolean;
    function ValueOf(const Key: THashType; const DefaultValue: Number = -1): Number;
    function Exists(const Key: THashType): Boolean;

    procedure GetItems(AList: TList);
    procedure GetKeyList(AList: TStrings);
    procedure DoFreePointerItem(Item: PHashItem); 

    procedure Add(const Key: THashType; const Value: Number); overload;
    procedure Add(const Key: THashType; const Value: Double); overload;
    procedure Add(const Key: THashType; const Value: Int64); overload;
    procedure Add(const Key: THashType; const Value: Pointer); overload;

    procedure AddOrUpdate(const Key: THashType; const Value: Number); overload;
    procedure AddOrUpdate(const Key: THashType; const Value: Double); overload;
    procedure AddOrUpdate(const Key: THashType; const Value: Int64); overload;
    procedure AddOrUpdate(const Key: THashType; const Value: Pointer); overload;

    function Modify(const Key: THashType; const Value: Number): Boolean; overload;
    function Modify(const Key: THashType; const Value: Double): Boolean; overload;
    function Modify(const Key: THashType; const Value: Int64): Boolean; overload;
    function Modify(const Key: THashType; const Value: Pointer): Boolean; overload;

    function TryGetValue(const Key: THashType; var OutValue: Number): Boolean; overload;
    function TryGetValue(const Key: THashType; var OutValue: Int64): Boolean; overload;
    function TryGetValue(const Key: THashType; var OutValue: Double): Boolean; overload;
    function TryGetValue(const Key: THashType; var OutValue: Pointer): Boolean; overload;

    function GetInt(const Key: THashType; const DefaultValue: Number = -1): Number;
    function GetInt64(const Key: THashType; const DefaultValue: Int64 = -1): Int64;
    function GetFolat(const Key: THashType; const DefaultValue: Double = -1): Double;
    function GetPointer(const Key: THashType): Pointer;

    property Values[const Key: THashType]: Number read GetValueItem write SetValueItem;
    property Items[const Key: THashType]: TIntHashItem read GetItem;
    property Count: Integer read FCount;
    property BucketsCount: Integer read GetBucketsCount;
    property OnFreeItem: TYXDIntHashItemFreeNotify read FOnFreeItem write FOnFreeItem;
  end;

type
  /// <summary>
  /// ��ϣ��, ���ڴ���һЩ���ڲ�ѯ��ɢ������
  /// </summary>
  TYXDHashTable = class(TObject)
  private
    FPool: TMemPool;
    procedure SetAutoSize(const Value: Boolean);
    procedure FreeBucket(var ABucket: PHashList); virtual;
    function GetMemSize: Int64; virtual;
  protected
    FCount: Integer;
    FBuckets: THashArray;
    FOnDelete: TYXDHashDeleteNotify;
    FOnCompare: TYXDCompare;
    FAutoSize : Boolean; 
    procedure DoDelete(AHash: THashType; AData:Pointer); virtual;
    function GetBuckets(AIndex: Integer): PHashList; {$IFDEF USEINLINE}inline;{$ENDIF}
    function GetBucketCount: Integer; {$IFDEF USEINLINE}inline;{$ENDIF}
    function Compare(Data1, Data2: Pointer; var AResult: Integer): Boolean; {$IFDEF USEINLINE}inline;{$ENDIF}
  public
    ///���캯������Ͱ����Ϊ���������ڿ��Ե���Resize����
    constructor Create(ASize: Integer); overload; virtual;
    ///���캯��
    constructor Create; overload;
    destructor Destroy;override;
    procedure Clear; virtual;
    procedure DeleteBucket(Index: Integer);
    procedure ReSize(ASize: Cardinal);
    procedure Add(AData: Pointer; AHash: THashType);
    // �ҳ���ϣֵΪAHash������HashList����Ҫ�Լ��ͷŷ��ص�HashList
    function Find(AHash: THashType): PHashList; overload;
    function Find(AData: Pointer; AHash: THashType): Pointer; overload;
    function FindFirstData(AHash: THashType): Pointer;
    function FindFirst(AHash: THashType): PHashList; {$IFDEF USEINLINE}inline;{$ENDIF}
    function FindNext(AList: PHashList): PHashList; {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure FreeHashList(AList: PHashList);
    function Exists(AData: Pointer; AHash: THashType):Boolean;
    procedure Delete(AData: Pointer; AHash: THashType);
    procedure Update(AData: Pointer; AOldHash, ANewHash: THashType);
    // Ԫ�ظ���
    property Count: Integer read FCount;
    // Ͱ����
    property BucketCount: Integer read GetBucketCount;
    // Ͱ�б�
    property Buckets[AIndex:Integer]: PHashList read GetBuckets;default;
    // �ȽϺ���
    property OnCompare:TYXDCompare read FOnCompare write FOnCompare;
    // ɾ���¼�֪ͨ
    property OnDelete: TYXDHashDeleteNotify read FOnDelete write FOnDelete;
    // �Ƿ��Զ�����Ͱ��С
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    // �ڴ�ռ�ô�С
    property MemSize: Int64 read GetMemSize;
  end;

type
  /// <summary>
  /// ���ַ���Ϊ Key ��Hash��
  /// �ص㣺
  ///   1. ���ַ�����ΪKey
  ///   2. �ɿ���ɾ������
  ///   3. �ɿ����������
  ///   4. ��������ֻ��ͨ��Ͱ������ÿһ������
  /// </summary>
  TYXDHashMapTable = class(TYXDHashTable)
  private
    FListPool: TMemPool;
    procedure FreeBucket(var ABucket: PHashList); override;
    function GetMemSize: Int64; override;
  protected
    procedure DoAdd(ABucket: PHashMapList); virtual;
  public
    constructor Create(ASize: Integer); override;
    destructor Destroy; override;
    procedure Add(const Key: string; AData: PHashValue); overload;
    procedure Add(const Key: Number; AData: PHashValue); overload;
    procedure Add(const Key: string; AData: Integer); overload;
    procedure Add(const Key: Number; AData: Integer); overload;
    procedure Clear; override;
    function Exists(const Key: string): Boolean; overload; {$IFDEF USEINLINE}inline;{$ENDIF}
    function Exists(const Key: Number): Boolean; overload; {$IFDEF USEINLINE}inline;{$ENDIF}
    function Find(const Key: string): PHashMapValue; overload;
    function Find(const Key: Number): PHashMapValue; overload;
    function FindList(const Key: string): PPHashList; overload;
    function FindList(const Key: Number): PPHashList; overload;
    function Update(const Key: string; Value: PHashValue): Boolean; overload;
    function Update(const Key: Number; Value: PHashValue): Boolean; overload;
    function Remove(const Key: string): Boolean; overload;
    function Remove(const Key: Number): Boolean; overload;
    function Remove(const P: PHashMapValue): Boolean; overload;
    function ValueOf(const Key: string): PHashValue; overload;
    function ValueOf(const Key: Number): PHashValue; overload;
  end;

type
  TYXDHashMapListBase = class(TYXDHashMapTable)
  private
    function GetItem(Index: Integer): PHashMapValue; virtual; abstract;
  public
    property Items[Index: Integer]: PHashMapValue read GetItem;
  end;

type
  /// <summary>
  /// ���ַ���ΪKey���������� Hash �б�
  /// �ص㣺
  ///   1. ���ַ�����ΪKey
  ///   2. �ɿ���ʹ�� Index ���ʱ�������
  ///   3. ��ͨ��Indexɾ�����ݡ�ɾ���ٶȽ���
  ///   4. �ɿ����������
  /// </summary>
  TYXDHashMapList = class(TYXDHashMapListBase)
  private
    FList: TList;
    function GetItem(Index: Integer): PHashMapValue; override;
  protected
    procedure DoAdd(ABucket: PHashMapList); override;
    procedure DoDelete(AHash: THashType; AData:Pointer); override;
  public
    constructor Create(ASize: Integer); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Delete(Index: Integer);
  end;

type
  /// <summary>
  /// ���ַ���ΪKey����˫������������ Hash ����
  /// �ص㣺
  ///   1. ���ַ�����ΪKey
  ///   2. ��ʹ�� Index ����ÿһ�����ݣ��ٶ���������ʹ������ʽ���У�
  ///   3. �ɿ���ɾ������
  ///   4. �ɿ����������
  /// </summary>
  TYXDHashMapLinkTable = class;

  TYXDHashMapLinkTableEnumerator = class
  private
    FItem: PHashMapLinkItem;
  public
    constructor Create(AList: TYXDHashMapLinkTable);
    function GetCurrent: PHashMapLinkItem; {$IFDEF USEINLINE}inline;{$ENDIF}
    function MoveNext: Boolean;
    property Current: PHashMapLinkItem read GetCurrent;
  end;

  TYXDHashMapLinkTable = class(TYXDHashMapListBase)
  private
    FFirst: PHashMapLinkItem;
    FLast: PHashMapLinkItem;
    ListBuckets: THashArray;
    FLinkHashPool: TMemPool;
    function GetItem(Index: Integer): PHashMapValue; override;
    function GetMemSize: Int64; override;
    function FindLinkItem(AData: Pointer; isDelete: Boolean): PHashMapLinkItem;
    procedure FreeLinkList;
    function GetLast: PHashMapValue;
  protected
    procedure DoAdd(ABucket: PHashMapList); override;
    procedure DoDelete(AHash: THashType; AData:Pointer); override;
  public
    constructor Create(ASize: Integer); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Delete(Index: Integer);
    function GetEnumerator: TYXDHashMapLinkTableEnumerator;   
    property First: PHashMapLinkItem read FFirst;
    property Last: PHashMapLinkItem read FLast;
    property LastValue: PHashMapValue read GetLast;
  end;

  // �����ɵ����ƣ������¼���
  TYXDHashMapChainTable = TYXDHashMapLinkTable;

// --------------------------------------------------------------------------
//  HASH ������
// --------------------------------------------------------------------------

// HASH ����
function HashOf(const Key: Pointer; KeyLen: Cardinal): THashType; overload;
function HashOf(const Key: string): THashType; {$IFDEF USEINLINE}inline;{$ENDIF} overload;
// ����һ���ο��ͻ�ֵ�������ʵ��Ĺ�ϣ���С
function CalcBucketSize(dataSize: Cardinal): THashType;

implementation

const
  BucketSizes: array[0..47] of Cardinal = (
    17,37,79,163,331,673,1361,2729,5471,10949,21911,43853,87719,175447,350899,
    701819,1403641,2807303,5614657,8999993,11229331,22458671,30009979,44917381,
    50009969, 60009997, 70009987, 80009851, 89834777,100009979,110009987,120009979,
    130009903, 140009983,150009983,165009937,179669557,200009959,359339171,
    400009999, 450009883,550009997,718678369,850009997,1050009979,1437356741,
    1850009969, 2147483647
  );

const
  HASHITEMSize = SizeOf(THashMapList) + SizeOf(THashMapValue);

function HashOf(const Key: Pointer; KeyLen: Cardinal): THashType; overload;
var
  ps: PCardinal;
  lr: Cardinal;
begin
  Result := 0;
  if KeyLen > 0 then begin
    ps := Key;
    lr := (KeyLen and $03);//��鳤���Ƿ�Ϊ4��������
    KeyLen := (KeyLen and $FFFFFFFC);//��������
    while KeyLen > 0 do begin
      Result := ((Result shl 5) or (Result shr 27)) xor ps^;
      Inc(ps);
      Dec(KeyLen, 4);
    end;
    if lr <> 0 then begin
      case lr of
        1: KeyLen := PByte(ps)^;
        2: KeyLen := PWORD(ps)^;
        3: KeyLen := PWORD(ps)^ or (PByte(Cardinal(ps) + 2)^ shl 16);
      end;
      Result := ((Result shl 5) or (Result shr 27)) xor KeyLen;
    end;
  end;
end;

function HashOf(const Key: string): THashType; {$IFDEF USEINLINE}inline;{$ENDIF} overload;
begin
  Result := HashOf(PChar(Key), Length(Key){$IFDEF UNICODE} shl 1{$ENDIF});
end;

function CalcBucketSize(dataSize: Cardinal): THashType;
var
  i: Integer;
begin
  for i := 0 to High(BucketSizes) do
    if BucketSizes[i] > dataSize then begin
      Result := BucketSizes[i];
      Exit;
    end;
  Result := BucketSizes[High(BucketSizes)];
end;

{ THashValue }

function THashValue.AsString: string;
begin
  SetLength(Result, Size);
  if Size > 0 then
    Move(Data^, Result[1], Size);
end;

procedure THashValue.Clear;
begin
  Size := 0;
  Data := nil;
end;

{ TStringHash }

procedure TStringHash.Add(const Key: string; const Value: Number);
var
  Hash: Integer;
  Bucket: PHashItem;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.Value := Value;
  FLocker.Enter;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
  Inc(FCount);
  FLocker.Leave;
end;

procedure TStringHash.Add(const Key: string; const Value: Double);
var
  Hash: Integer;
  Bucket: PHashItem;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.AsDouble := Value;
  FLocker.Enter;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
  Inc(FCount);
  FLocker.Leave;
end;

procedure TStringHash.Add(const Key: string; const Value: Int64);
var
  Hash: Integer;
  Bucket: PHashItem;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.AsInt64 := Value;
  FLocker.Enter;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
  Inc(FCount);
  FLocker.Leave; 
end;

procedure TStringHash.Add(const Key: string; const Value: Pointer);
var
  Hash: Integer;
  Bucket: PHashItem;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.AsPointer := Value;
  FLocker.Enter;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
  Inc(FCount);
  FLocker.Leave;
end;

procedure TStringHash.AddOrUpdate(const Key: string; const Value: Number);
begin
  if not Modify(Key, Value) then
    Add(Key, Value);
end;

procedure TStringHash.AddOrUpdate(const Key: string; const Value: Int64);
begin
  if not Modify(Key, Value) then
    Add(Key, Value);
end;

procedure TStringHash.AddOrUpdate(const Key: string; const Value: Double);
begin
  if not Modify(Key, Value) then
    Add(Key, Value);
end;

procedure TStringHash.AddOrUpdate(const Key: string; const Value: Pointer);
begin
  if not Modify(Key, Value) then
    Add(Key, Value);
end;

procedure TStringHash.Clear;
var
  I: Integer;
  P, N: PHashItem;
begin
  FLocker.Enter;
  for I := 0 to Length(Buckets) - 1 do begin
    P := Buckets[I];
    while P <> nil do begin
      N := P^.Next;
      if Assigned(FOnFreeItem) then
        FOnFreeItem(P);
      Dispose(P);
      P := N;
    end;
    Buckets[I] := nil;
  end;
  FCount := 0;
  FLocker.Leave;
end;

constructor TStringHash.Create(Size: Cardinal);
begin
  inherited Create;
  FCount := 0;
  FLocker := TCriticalSection.Create;
  SetLength(Buckets, Size);
end;

destructor TStringHash.Destroy;
begin
  FLocker.Enter;
  try
    Clear;
    inherited Destroy;
  finally
    FLocker.Free;
  end;
end;

procedure TStringHash.DoFreePointerItem(Item: PHashItem);
begin
  if (Item <> nil) and (Item.AsPointer <> nil) then
    Dispose(Item.AsPointer);
end;

function TStringHash.Exists(const Key: string): Boolean;
begin
  FLocker.Enter;
  Result := Find(Key)^ <> nil;
  FLocker.Leave;
end;

function TStringHash.Find(const Key: string): PPHashItem;
var
  Hash: Integer;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  Result := @Buckets[Hash];
  while Result^ <> nil do
  begin
    if Result^.Key = Key then
      Exit
    else
      Result := @Result^.Next;
  end;
end;

function TStringHash.GetBucketsCount: Integer;
begin
  Result := Length(Buckets);
end;

function TStringHash.GetFolat(const Key: string;
  const DefaultValue: Double): Double;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.AsDouble
  else
    Result := DefaultValue;
  FLocker.Leave;
end;

function TStringHash.GetInt(const Key: string;
  const DefaultValue: Number): Number;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.AsNumber
  else
    Result := DefaultValue;
  FLocker.Leave;
end;

function TStringHash.GetInt64(const Key: string;
  const DefaultValue: Int64): Int64;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.AsInt64
  else
    Result := DefaultValue;
  FLocker.Leave;
end;

function TStringHash.GetItem(const Key: string): THashItem;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^
  else begin
    Result.Next := nil;
    Result.Key := '';
    Result.AsInt64 := 0;
  end;
  FLocker.Leave;
end;

procedure TStringHash.GetItems(AList: TList);
var
  P: PHashItem;
  I: Integer;
begin
  if not Assigned(AList) then
    Exit;
  FLocker.Enter;
  try
    for I := 0 to High(Buckets) do begin
      P := Buckets[I];
      while P <> nil do begin
        if P.AsPointer <> nil then
          AList.Add(P.AsPointer);
        P := P.Next;
      end;
    end;
  finally
    FLocker.Leave;
  end;
end;

procedure TStringHash.GetKeyList(AList: TStrings);
var
  P: PHashItem;
  I: Integer;
begin
  if not Assigned(AList) then
    Exit;
  FLocker.Enter;
  try
    for I := 0 to High(Buckets) do begin
      P := Buckets[I];
      while P <> nil do begin
        if P.Key <> '' then
          AList.Add(P.Key);
        P := P.Next;
      end;
    end;
  finally
    FLocker.Leave;
  end;
end;

function TStringHash.GetPointer(const Key: string): Pointer;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.AsPointer
  else
    Result := nil;
  FLocker.Leave;
end;

function TStringHash.GetValueItem(const Key: string): Number;
begin
  Result := ValueOf(Key);
end;

procedure TStringHash.Lock;
begin
  FLocker.Enter;
end;

function TStringHash.Modify(const Key: string; const Value: Pointer): Boolean;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    P^.AsPointer := Value;
  end else
    Result := False;
  FLocker.Leave;
end;

function TStringHash.Modify(const Key: string; const Value: Int64): Boolean;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    P^.AsInt64 := Value;
  end else
    Result := False;
  FLocker.Leave;
end;

function TStringHash.Modify(const Key: string; const Value: Double): Boolean;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    P^.AsDouble := Value;
  end else
    Result := False;
  FLocker.Leave;
end;

function TStringHash.Modify(const Key: string; const Value: Number): Boolean;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    P^.Value := Value;
  end
  else
    Result := False;
  FLocker.Leave;
end;

procedure TStringHash.Remove(const Key: string);
var
  P: PHashItem;
  Prev: PPHashItem;
begin
  FLocker.Enter;
  Prev := Find(Key);
  P := Prev^;
  if P <> nil then
  begin
    Dec(FCount);
    Prev^ := P^.Next;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    Dispose(P);
  end;
  FLocker.Leave;
end;

procedure TStringHash.SetValueItem(const Key: string; const Value: Number);
begin
  AddOrUpdate(Key, Value);
end;

function TStringHash.TryGetValue(const Key: string;
  var OutValue: Int64): Boolean;
var
  P: PHashItem;
begin
  Result := False;
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then begin
    OutValue := P^.AsInt64;
    Result := True;
  end;
  FLocker.Leave;
end;

function TStringHash.TryGetValue(const Key: string;
  var OutValue: Double): Boolean;
var
  P: PHashItem;
begin
  Result := False;
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then begin
    OutValue := P^.AsDouble;
    Result := True;
  end;
  FLocker.Leave;
end;

function TStringHash.TryGetValue(const Key: string;
  var OutValue: Pointer): Boolean;
var
  P: PHashItem;
begin
  Result := False;
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then begin
    OutValue := P^.AsPointer;
    Result := True;
  end;
  FLocker.Leave;
end;

function TStringHash.TryGetValue(const Key: string;
  var OutValue: Number): Boolean;
var
  P: PHashItem;
begin
  Result := False;
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then begin
    OutValue := P^.AsNumber;
    Result := True;
  end;
  FLocker.Leave;
end;

procedure TStringHash.UnLock;
begin
  FLocker.Leave;
end;

function TStringHash.ValueOf(const Key: string; const DefaultValue: Number): Number;
var
  P: PHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.Value
  else
    Result := DefaultValue;
  FLocker.Leave;
end;

{ TIntHash }

procedure TIntHash.Add(const Key: THashType; const Value: Number);
var
  Hash: Integer;
  Bucket: PIntHashItem;
begin
  Hash := Key mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.Value := Value;
  FLocker.Enter;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
  Inc(FCount);
  FLocker.Leave;
end;

procedure TIntHash.Add(const Key: THashType; const Value: Int64);
var
  Hash: Integer;
  Bucket: PIntHashItem;
begin
  Hash := Key mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.AsInt64 := Value;
  FLocker.Enter;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
  Inc(FCount);
  FLocker.Leave;
end;

procedure TIntHash.Add(const Key: THashType; const Value: Double);
var
  Hash: Integer;
  Bucket: PIntHashItem;
begin
  Hash := Key mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.AsDouble := Value;
  FLocker.Enter;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
  Inc(FCount);
  FLocker.Leave;
end;

procedure TIntHash.Add(const Key: THashType; const Value: Pointer);
var
  Hash: Integer;
  Bucket: PIntHashItem;
begin
  Hash := Key mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.AsPointer := Value;
  FLocker.Enter;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
  Inc(FCount);
  FLocker.Leave;
end;

procedure TIntHash.AddOrUpdate(const Key: THashType; const Value: Number);
begin
  if not Modify(Key, Value) then
    Add(Key, Value);
end;

procedure TIntHash.AddOrUpdate(const Key: THashType; const Value: Double);
begin
  if not Modify(Key, Value) then
    Add(Key, Value);
end;

procedure TIntHash.AddOrUpdate(const Key: THashType; const Value: Pointer);
begin
  if not Modify(Key, Value) then
    Add(Key, Value);
end;

procedure TIntHash.AddOrUpdate(const Key: THashType; const Value: Int64);
begin
  if not Modify(Key, Value) then
    Add(Key, Value);
end;

procedure TIntHash.Clear;
var
  I: Integer;
  P, N: PIntHashItem;
begin
  FLocker.Enter;
  for I := 0 to Length(Buckets) - 1 do begin
    P := Buckets[I];
    while P <> nil do begin
      N := P^.Next;
      if Assigned(FOnFreeItem) then
        FOnFreeItem(P);
      Dispose(P);
      P := N;
    end;
    Buckets[I] := nil;
  end;
  FLocker.Leave;
end;

constructor TIntHash.Create(Size: Cardinal);
begin
  inherited Create;
  FLocker := TCriticalSection.Create;
  SetLength(Buckets, Size);
  FCount := 0;
end;

destructor TIntHash.Destroy;
begin
  FLocker.Enter;
  try
    Clear;
    inherited Destroy;
  finally
    FLocker.Free;
  end;
end;

procedure TIntHash.DoFreePointerItem(Item: PHashItem);
begin

end;

function TIntHash.Exists(const Key: THashType): Boolean;
begin
  FLocker.Enter;
  Result := Find(Key)^ <> nil;
  FLocker.Leave;
end;

function TIntHash.Find(const Key: THashType): PPIntHashItem;
begin
  Result := @Buckets[Key mod Cardinal(Length(Buckets))];
  while Result^ <> nil do begin
    if Result^.Key = Key then
      Exit
    else
      Result := @Result^.Next;
  end;
end;

function TIntHash.GetBucketsCount: Integer;
begin
  Result := Length(Buckets);
end;

function TIntHash.GetFolat(const Key: THashType;
  const DefaultValue: Double): Double;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.AsDouble
  else
    Result := DefaultValue;
  FLocker.Leave;
end;

function TIntHash.GetInt(const Key: THashType;
  const DefaultValue: Number): Number;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.AsNumber
  else
    Result := DefaultValue;
  FLocker.Leave;
end;

function TIntHash.GetInt64(const Key: THashType;
  const DefaultValue: Int64): Int64;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.AsInt64
  else
    Result := DefaultValue;
  FLocker.Leave;
end;

function TIntHash.GetItem(const Key: THashType): TIntHashItem;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^
  else begin
    Result.Next := nil;
    Result.Key := 0;
    Result.AsInt64 := 0;
  end;
  FLocker.Leave;
end;

procedure TIntHash.GetItems(AList: TList);
var
  P: PIntHashItem;
  I: Integer;
begin
  if not Assigned(AList) then
    Exit;
  FLocker.Enter;
  try
    for I := 0 to High(Buckets) do begin
      P := Buckets[I];
      while P <> nil do begin
        if Pointer(P.Value) <> nil then
          AList.Add(Pointer(P.Value));
        P := P.Next;
      end;
    end;
  finally
    FLocker.Leave;
  end;
end;

procedure TIntHash.GetKeyList(AList: TStrings);
var
  P: PIntHashItem;
  I: Integer;
begin
  if not Assigned(AList) then
    Exit;
  FLocker.Enter;
  try
    for I := 0 to High(Buckets) do begin
      P := Buckets[I];
      while P <> nil do begin
        if P.Key <> 0 then
          AList.Add(IntToStr(P.Key));
        P := P.Next;
      end;
    end;
  finally
    FLocker.Leave;
  end;
end;

function TIntHash.GetPointer(const Key: THashType): Pointer;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.AsPointer
  else
    Result := nil;
  FLocker.Leave;
end;

function TIntHash.GetValueItem(const Key: THashType): Number;
begin
  Result := ValueOf(Key);
end;

procedure TIntHash.Lock;
begin
  FLocker.Enter;
end;

function TIntHash.Modify(const Key: THashType; const Value: Double): Boolean;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    P^.AsDouble := Value;
  end
  else
    Result := False;
  FLocker.Leave;
end;

function TIntHash.Modify(const Key: THashType; const Value: Pointer): Boolean;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    P^.AsPointer := Value;
  end
  else
    Result := False;
  FLocker.Leave;
end;

function TIntHash.Modify(const Key: THashType; const Value: Int64): Boolean;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    P^.AsInt64 := Value;
  end
  else
    Result := False;
  FLocker.Leave;
end;

function TIntHash.Modify(const Key: THashType; const Value: Number): Boolean;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    P^.Value := Value;
  end
  else
    Result := False;
  FLocker.Leave;
end;

function TIntHash.Remove(const Key: THashType): Boolean;
var
  P: PIntHashItem;
  Prev: PPIntHashItem;
begin
  Result := False;
  FLocker.Enter;
  Prev := Find(Key);
  P := Prev^;
  if P <> nil then begin
    Result := True;
    Prev^ := P^.Next;
    if Assigned(FOnFreeItem) then
      FOnFreeItem(P);
    Dispose(P);
  end;
  FLocker.Leave;
end;

procedure TIntHash.SetValueItem(const Key: THashType; const Value: Number);
begin
  AddOrUpdate(Key, Value);
end;

function TIntHash.TryGetValue(const Key: THashType;
  var OutValue: Double): Boolean;
var
  P: PIntHashItem;
begin
  Result := False;
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then begin
    OutValue := P^.AsDouble;
    Result := True;
  end;
  FLocker.Leave;
end;

function TIntHash.TryGetValue(const Key: THashType;
  var OutValue: Pointer): Boolean;
var
  P: PIntHashItem;
begin
  Result := False;
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then begin
    OutValue := P^.AsPointer;
    Result := True;
  end;
  FLocker.Leave;
end;

function TIntHash.TryGetValue(const Key: THashType;
  var OutValue: Number): Boolean;
var
  P: PIntHashItem;
begin
  Result := False;
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then begin
    OutValue := P^.AsNumber;
    Result := True;
  end;
  FLocker.Leave;
end;

function TIntHash.TryGetValue(const Key: THashType;
  var OutValue: Int64): Boolean;
var
  P: PIntHashItem;
begin
  Result := False;
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then begin
    OutValue := P^.AsInt64;
    Result := True;
  end;
  FLocker.Leave;
end;

procedure TIntHash.UnLock;
begin
  FLocker.Leave;
end;

function TIntHash.ValueOf(const Key: THashType; const DefaultValue: Number): Number;
var
  P: PIntHashItem;
begin
  FLocker.Enter;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.Value
  else
    Result := DefaultValue;
  FLocker.Leave;
end;

{ THashList }

procedure THashList.Reset;
begin
  Next := nil;
  Data := nil;
end;  

{ THashMapValue }

function THashMapValue.GetNumKey: Number;
begin
  Result := PNumber(@Key)^;
end;

procedure THashMapValue.SetNumKey(const AValue: Number);
begin
  PNumber(@Key)^ := THashType(AValue);
end;

{ TYXDHashTable }

procedure TYXDHashTable.Add(AData: Pointer; AHash: THashType);
var
  AIndex: Integer;
  ABucket: PHashList;
begin
  ABucket := FPool.Pop;
  ABucket.Hash := AHash;
  ABucket.Data := AData;
  AIndex := AHash mod Cardinal(Length(FBuckets));
  ABucket.Next := FBuckets[AIndex];
  FBuckets[AIndex] := ABucket;
  Inc(FCount);
  {$IFDEF AUTORESIE}
  if (FCount div Length(FBuckets)) > 3 then
    Resize(0);
  {$ENDIF}
end;

procedure TYXDHashTable.Clear;
var
  I,H: Integer;
  ABucket: PHashList;
begin
  H := High(FBuckets);
  for I := 0 to H do begin
    ABucket := FBuckets[I];
    while ABucket <> nil do begin
      FBuckets[I] := ABucket.Next;
      DoDelete(ABucket.Hash, ABucket.Data);
      FreeBucket(ABucket);
      ABucket := FBuckets[I];
    end;
  end;
  FPool.Clear;
  FCount := 0;
end;

function TYXDHashTable.Compare(Data1, Data2: Pointer;
  var AResult: Integer): Boolean;
begin
  if Assigned(FOnCompare) then begin
    AResult := FOnCompare(Data1, Data2);
    Result := True;
  end else
    Result := False;
end;

constructor TYXDHashTable.Create(ASize: Integer);
begin
  //FPool := THashListPool.Create(8192, SizeOf(THashList));
  FPool := TMemPool.Create(SizeOf(THashList), 1024);
  if ASize = 0 then ASize := 17;
  Resize(ASize);
end;

constructor TYXDHashTable.Create;
begin
  Resize(0);
end;

procedure TYXDHashTable.Delete(AData: Pointer; AHash: THashType);
var
  AIndex, ACompare: Integer;
  AHashList, APrior: PHashList;
begin
  AIndex := AHash mod Cardinal(Length(FBuckets));
  AHashList := FBuckets[AIndex];
  APrior := nil;
  while Assigned(AHashList) do begin
    // ͬһ���ݣ���ϣֵ����ֻ����Ϊ����ͬ�������ͬ�����ϵ�ȥ��
    if (AHashList.Data=AData) or ((Compare(AHashList.Data,AData,ACompare) and (ACompare=0))) then
    begin
      DoDelete(AHashList.Hash,AHashList.Data);
      if Assigned(APrior) then
        APrior.Next := AHashList.Next
      else
        FBuckets[AIndex] := AHashList.Next; // yangyxd 2014.10.8
      FreeBucket(AHashList);
      Dec(FCount);
      Break;
    end else begin
      APrior := AHashList;
      AHashList := APrior.Next;
    end;
  end;
end;

procedure TYXDHashTable.DeleteBucket(Index: Integer);
var
  ABucket, P: PHashList;
begin
  if (Index < 0) or (Index > High(FBuckets)) then Exit;
  ABucket := FBuckets[Index];
  FBuckets[Index] := nil;
  while ABucket <> nil do begin
    P := ABucket.Next;
    DoDelete(ABucket.Hash, ABucket.Data);
    FreeBucket(ABucket);
    Dec(FCount);
    ABucket := P;
  end;
end;

destructor TYXDHashTable.Destroy;
begin
  Clear;
  FreeAndNil(FPool);
end;

procedure TYXDHashTable.DoDelete(AHash: THashType; AData: Pointer);
begin
  if Assigned(FOnDelete) then
    FOnDelete(Self, AHash, AData);
end;

function TYXDHashTable.Exists(AData: Pointer; AHash: THashType): Boolean;
var
  AList: PHashList;
  AResult: Integer;
begin
  AList := FindFirst(AHash);
  Result := False;
  while AList <> nil do begin
    if (AList.Data = AData) or (Compare(AList.Data,AData,AResult) and (AResult=0)) then begin
      Result:=True;
      Break;
    end;
    AList := FindNext(AList);
  end;
end;

function TYXDHashTable.Find(AHash: THashType): PHashList;
var
  AIndex: Integer;
  AList, AItem: PHashList;
begin
  AIndex := AHash mod Cardinal(Length(FBuckets));
  Result := nil;
  AList := FBuckets[AIndex];
  while AList <> nil do begin
    if AList.Hash = AHash then begin
      New(AItem);
      AItem.Data := AList.Data;
      AItem.Next := Result;
      AItem.Hash := AHash;
      Result := AItem;
    end;
    AList := AList.Next;
  end;
end;

function TYXDHashTable.Find(AData: Pointer; AHash: THashType): Pointer;
var
  ACmpResult: Integer;
  AList: PHashList;
begin
  Result := nil;
  AList := FindFirst(AHash);
  while AList<>nil do begin
    if (AList.Data = AData) or (Compare(AData, AList.Data, ACmpResult) and (ACmpResult=0)) then begin
      Result := AList.Data;
      Break;
    end;
    AList := AList.Next;
  end;
end;

function TYXDHashTable.FindFirst(AHash: THashType): PHashList;
var
  AIndex: Integer;
  AList: PHashList;
begin
  AIndex := AHash mod Cardinal(Length(FBuckets));
  Result := nil;
  AList := FBuckets[AIndex];
  while AList <> nil do begin
    if AList.Hash = AHash then begin
      Result := AList;
      Break;
    end;
    AList := AList.Next;
  end;
end;

function TYXDHashTable.FindFirstData(AHash: THashType): Pointer;
begin
  Result := FindFirst(AHash);
  if Result <> nil then
    Result := PHashList(Result).Data;
end;

function TYXDHashTable.FindNext(AList: PHashList): PHashList;
begin
  Result := nil;
  if Assigned(AList) then begin
    Result := AList.Next;
    while Result<>nil do begin
      if Result.Hash=AList.Hash then
        Break
      else
        Result := Result.Next;
    end;
  end;
end;

procedure TYXDHashTable.FreeBucket(var ABucket: PHashList);
begin
  FPool.Push(ABucket);
end;

procedure TYXDHashTable.FreeHashList(AList: PHashList);
var
  ANext: PHashList;
begin
  while AList<>nil do begin
    ANext := AList.Next;
    FreeBucket(AList);
    AList := ANext;
  end;
end;

function TYXDHashTable.GetBucketCount: Integer;
begin
  Result := Length(FBuckets);
end;

function TYXDHashTable.GetBuckets(AIndex: Integer): PHashList;
begin
  Result := FBuckets[AIndex];
end;

function TYXDHashTable.GetMemSize: Int64;
begin
  Result := Length(FBuckets) shl 2;
end;

procedure TYXDHashTable.Resize(ASize: Cardinal);
var
  I, AIndex: Integer;
  AHash: Cardinal;
  ALastBuckets: THashArray;
  AList, ANext: PHashList;
begin
  if ASize = 0 then begin
    ASize := CalcBucketSize(FCount);
    if ASize = Cardinal(Length(FBuckets)) then
      Exit;
  end;

  //Ͱ�ߴ��������·���Ԫ�����ڵĹ�ϣͰ��������Զ����õĻ�������Ľ������һ��Ͱ��һ��Ԫ��
  if ASize <> Cardinal(Length(FBuckets)) then begin
    ALastBuckets := FBuckets;
    SetLength(FBuckets, ASize);
    for I := 0 to ASize-1 do
      FBuckets[I] := nil;
    for I := 0 to High(ALastBuckets) do begin
      AList := ALastBuckets[I];
      while AList<>nil do begin
        AHash := AList.Hash;
        AIndex := AHash mod ASize;
        ANext := AList.Next;
        AList.Next := FBuckets[AIndex];
        FBuckets[AIndex] := AList;
        AList := ANext;
      end;
    end;
  end;
end;

procedure TYXDHashTable.SetAutoSize(const Value: Boolean);
begin
  if FAutoSize <> Value then begin
    FAutoSize := Value;
    if AutoSize then begin
      if (FCount div Length(FBuckets)) > 3 then
        Resize(0);
    end;
  end;
end;

procedure TYXDHashTable.Update(AData: Pointer; AOldHash, ANewHash: THashType);
var
  AList, APrior: PHashList;
  ACmpResult: Integer;
  AIndex: Integer;
  AChanged: Boolean;
begin
  AChanged := False;
  AIndex := AOldHash mod Cardinal(Length(FBuckets));
  AList := FBuckets[AIndex];
  APrior := nil;
  while AList <> nil do begin
    if (AList.Hash = AOldHash) then begin
      if (AList.Data=AData) or (Compare(AData, AList.Data, ACmpResult) and (ACmpResult=0)) then begin
        if Assigned(APrior) then
          APrior.Next := AList.Next
        else
          FBuckets[AIndex] := AList.Next;
        AList.Hash := ANewHash;
        AIndex := ANewHash mod Cardinal(Length(FBuckets));
        AList.Next := FBuckets[AIndex];
        FBuckets[AIndex] := AList;
        AChanged := True;
        Break;
      end;
    end;
    APrior := AList;
    AList := AList.Next;
  end;
  if not AChanged then
    Add(AData, ANewHash);
end;

{ TYXDHashMapTable }
  
procedure TYXDHashMapTable.Add(const Key: string; AData: PHashValue);
var
  AIndex: THashType;
  ABucket: PHashMapList;
begin
  AIndex := HashOf(Key);
  ABucket := Pointer(FListPool.Pop);
  ABucket.Hash := AIndex;
  AIndex := AIndex mod Cardinal(Length(FBuckets));
  ABucket.Data := Pointer(NativeUInt(ABucket) + SizeOf(THashMapList));
  Initialize(ABucket.Data.Key);
  if AData <> nil then   
    ABucket.Data.Value := AData^
  else
    ABucket.Data.Value.Clear;
  ABucket.Data.IsStrKey := True;
  ABucket.Data.Key := Key;
  ABucket.Next := FBuckets[AIndex];
  FBuckets[AIndex] := Pointer(ABucket);
  Inc(FCount);
  {$IFDEF AUTORESIE}
  if (FCount div Length(FBuckets)) > 3 then
    Resize(0);
  {$ENDIF}
  DoAdd(ABucket);
end;

procedure TYXDHashMapTable.Add(const Key: Number; AData: PHashValue);
var
  AIndex: THashType;
  ABucket: PHashMapList;
begin
  ABucket := Pointer(FListPool.Pop);
  ABucket.Hash := THashType(Key);
  AIndex := THashType(Key) mod Cardinal(Length(FBuckets));
  ABucket.Data := Pointer(NativeUInt(ABucket) + SizeOf(THashMapList));
  if AData <> nil then   
    ABucket.Data.Value := AData^
  else
    ABucket.Data.Value.Clear;
  ABucket.Data.IsStrKey := False;
  PDWORD(@ABucket.Data.Key)^ := THashType(Key);
  ABucket.Next := FBuckets[AIndex];
  FBuckets[AIndex] := Pointer(ABucket);
  {$IFDEF AUTORESIE}
  if (FCount div Length(FBuckets)) > 3 then
    Resize(0);
  {$ENDIF}
  DoAdd(ABucket);
  Inc(FCount);
end;

procedure TYXDHashMapTable.Add(const Key: string; AData: Integer);
var
  AIndex: THashType;
  ABucket: PHashMapList;
begin
  AIndex := HashOf(Key);
  ABucket := Pointer(FListPool.Pop);
  ABucket.Hash := AIndex;
  AIndex := AIndex mod Cardinal(Length(FBuckets));
  ABucket.Data := Pointer(NativeUInt(ABucket) + SizeOf(THashMapList));
  Initialize(ABucket.Data.Key);
  ABucket.Data.Value.Data := Pointer(AData);
  ABucket.Data.Value.Size := 0;
  ABucket.Data.IsStrKey := True;
  ABucket.Data.Key := Key;
  ABucket.Next := FBuckets[AIndex];
  FBuckets[AIndex] := Pointer(ABucket);
  Inc(FCount);
  {$IFDEF AUTORESIE}
  if (FCount div Length(FBuckets)) > 3 then
    Resize(0);
  {$ENDIF}
  DoAdd(ABucket);
end;

procedure TYXDHashMapTable.Add(const Key: Number; AData: Integer);
var
  AIndex: THashType;
  ABucket: PHashMapList;
begin
  ABucket := Pointer(FListPool.Pop);
  ABucket.Hash := THashType(Key);
  AIndex := THashType(Key) mod Cardinal(Length(FBuckets));
  ABucket.Data := Pointer(NativeUInt(ABucket) + SizeOf(THashMapList));
  ABucket.Data.Value.Data := Pointer(AData);
  ABucket.Data.Value.Size := 0;
  ABucket.Data.IsStrKey := False;
  PDWORD(@ABucket.Data.Key)^ := THashType(Key);
  ABucket.Next := FBuckets[AIndex];
  FBuckets[AIndex] := Pointer(ABucket);
  Inc(FCount);
  {$IFDEF AUTORESIE}
  if (FCount div Length(FBuckets)) > 3 then
    Resize(0);
  {$ENDIF}
  DoAdd(ABucket);
end;

procedure TYXDHashMapTable.Clear;
var
  I: Integer;
  P, N: PHashList;
begin
  for I := 0 to High(FBuckets) do begin
    P := FBuckets[I];
    FBuckets[I] := nil;
    while P <> nil do begin
      N := P^.Next;
      DoDelete(P.Hash, P.Data);
      FreeBucket(P);
      P := N;
    end;
  end;
  FCount := 0;
  FListPool.Clear;
  FPool.Clear;
end;

constructor TYXDHashMapTable.Create(ASize: Integer);
begin
  inherited;
  FListPool := TMemPool.Create(HASHITEMSize, 1024);
end;

destructor TYXDHashMapTable.Destroy;
begin
  inherited;
  FreeAndNil(FListPool);
end;

procedure TYXDHashMapTable.DoAdd(ABucket: PHashMapList);
begin
end;

function TYXDHashMapTable.Exists(const Key: Number): Boolean;
begin
  Result := Find(Key) <> nil;
end;

function TYXDHashMapTable.Exists(const Key: string): Boolean;
begin
  Result := Find(Key) <> nil;
end;

function TYXDHashMapTable.Find(const Key: string): PHashMapValue;
var
  AList: PHashList;
  AHash: Cardinal;
begin
  AHash := HashOf(Key);
  AList := FBuckets[AHash mod Cardinal(Length(FBuckets))];
  while AList <> nil do begin
    if (AList.Hash = AHash) and (AList.Data <> nil) and (PHashMapValue(AList.Data).IsStrKey) and
      (PHashMapValue(AList.Data).Key = Key) then begin
      Result := AList.Data;
      Exit;
    end;
    AList := AList.Next;
  end;
  Result := nil;
end;

function TYXDHashMapTable.Find(const Key: Number): PHashMapValue;
var
  AList: PHashList;
  AHash: THashType;
begin
  AHash := THashType(Key);
  AList := FBuckets[AHash mod Cardinal(Length(FBuckets))];
  while AList <> nil do begin
    if (AList.Hash = AHash) and (AList.Data <> nil) and (not PHashMapValue(AList.Data).IsStrKey) then begin
      Result := AList.Data;
      Exit;
    end;
    AList := AList.Next;
  end;
  Result := nil;
end;

function TYXDHashMapTable.FindList(const Key: Number): PPHashList;
begin
  Result := @FBuckets[THashType(Key) mod Cardinal(Length(FBuckets))];
  while Result^ <> nil do begin
    if (Result^.Hash = THashType(Key)) and (Result^.Data <> nil) and
      (not PHashMapValue(Result^.Data).IsStrKey) then
      Break;
    Result := @Result^.Next;
  end;
end;

function TYXDHashMapTable.FindList(const Key: string): PPHashList;
var
  AHash: Cardinal;
begin
  AHash := HashOf(Key);
  Result := @FBuckets[AHash mod Cardinal(Length(FBuckets))];
  while Result^ <> nil do begin
    if (Result^.Hash = AHash) and (Result^.Data <> nil) and (PHashMapValue(Result^.Data).IsStrKey) and
      (PHashMapValue(Result^.Data).Key = Key) then begin
      Break;
    end;
    Result := @Result^.Next;
  end;
end;

procedure TYXDHashMapTable.FreeBucket(var ABucket: PHashList);
begin
  if PHashMapList(ABucket).Data.IsStrKey then  
    Finalize(PHashMapList(ABucket).Data.Key);
  FListPool.Push(ABucket);
end;

function TYXDHashMapTable.GetMemSize: Int64;
begin
  Result := inherited GetMemSize;
end;

function TYXDHashMapTable.Remove(const Key: Number): Boolean;
var
  AIndex: Integer;
  AHash: THashType;
  AHashList: PPHashList;
  APrior: PHashList;
begin
  Result := False;
  AHash := THashType(Key);
  AIndex := AHash mod Cardinal(Length(FBuckets));
  AHashList := @FBuckets[AIndex];
  while AHashList^ <> nil do begin
    if (AHashList^.Hash = AHash) and (not PHashMapValue(AHashList^.Data).IsStrKey) then begin
      APrior := AHashList^;
      AHashList^ := APrior.Next;
      DoDelete(APrior.Hash, APrior.Data);
      FreeBucket(APrior);
      Dec(FCount);
      Result := True;
      Break;
    end else
      AHashList := @AHashList^.Next;
  end;
end;

function TYXDHashMapTable.Update(const Key: string;
  Value: PHashValue): Boolean;
var
  P: PHashMapValue;
begin
  P := Find(Key);
  if P <> nil then begin
    if Value <> nil then
      P.Value := Value^
    else
      P.Value.Clear;
    Result := True;
  end else
    Result := False;
end;

function TYXDHashMapTable.Remove(const Key: string): Boolean;
var
  AIndex: Integer;
  AHash: Cardinal;
  AHashList: PPHashList;
  APrior: PHashList;
begin
  Result := False;
  AHash := HashOf(Key);
  AIndex := AHash mod Cardinal(Length(FBuckets));
  AHashList := @FBuckets[AIndex];
  while AHashList^ <> nil do begin
    if (AHashList^.Hash = AHash) and (PHashMapValue(AHashList^.Data).IsStrKey) and
      (PHashMapValue(AHashList^.Data).Key = Key) then begin
      APrior := AHashList^;
      AHashList^ := APrior.Next;
      DoDelete(APrior.Hash, APrior.Data);
      FreeBucket(APrior);
      Dec(FCount);
      Result := True;
      Break;
    end else
      AHashList := @AHashList^.Next;
  end;
end;

function TYXDHashMapTable.ValueOf(const Key: string): PHashValue;
var
  P: PHashMapValue;
begin
  P := Find(Key);
  if (P <> nil) then // and (P.Value.Size > 0) then
    Result := @P.Value
  else
    Result := nil;
end;

function TYXDHashMapTable.ValueOf(const Key: Number): PHashValue;
var
  P: PHashMapValue;
begin
  P := Find(Key);
  if (P <> nil) then // and (P.Value.Size > 0) then
    Result := @P.Value
  else
    Result := nil;
end;

function TYXDHashMapTable.Update(const Key: Number; Value: PHashValue): Boolean;
var
  P: PHashMapValue;
begin
  P := Find(Key);
  if P <> nil then begin
    if Value <> nil then
      P.Value := Value^
    else
      P.Value.Clear;
    Result := True;
  end else
    Result := False;  
end;

function TYXDHashMapTable.Remove(const P: PHashMapValue): Boolean;
begin
  if P <> nil then begin
    if P.IsStrKey then
      Result := Remove(P.Key)
    else
      Result := Remove(P.GetNumKey)
  end else
    Result := False;
end;

{ TYXDHashMapList }

procedure TYXDHashMapList.Clear;
begin
  FList.Clear;
  inherited; 
end;

constructor TYXDHashMapList.Create(ASize: Integer);
begin
  inherited;
  FList := TList.Create;
end;

procedure TYXDHashMapList.Delete(Index: Integer);
begin
  if (index >= 0) and (Index < FCount) then
    Remove(Items[index].Key);
end;

destructor TYXDHashMapList.Destroy;
begin
  inherited;
  FreeAndNil(FList);
end;

procedure TYXDHashMapList.DoAdd(ABucket: PHashMapList);
begin
  FList.Add(ABucket.Data);  
end;

procedure TYXDHashMapList.DoDelete(AHash: THashType; AData: Pointer);
begin
  if Assigned(FOnDelete) then
    FOnDelete(Self, AHash, AData);
  if FList.Count > 0 then   
    FList.Remove(AData);
end;

function TYXDHashMapList.GetItem(Index: Integer): PHashMapValue;
begin
  Result := FList.Items[index];
end; 

{ TYXDHashMapLinkTable }

procedure TYXDHashMapLinkTable.Clear;
begin
  if Assigned(Self) then begin
    FreeLinkList;
    inherited Clear;
  end;
end;

constructor TYXDHashMapLinkTable.Create(ASize: Integer);
begin
  inherited Create(ASize);
  FFirst := nil;
  FLast := nil;
  FLinkHashPool := TMemPool.Create(SizeOf(THashList), 1024);
  SetLength(ListBuckets, ASize);
end;

procedure TYXDHashMapLinkTable.Delete(Index: Integer);
var
  P: PHashMapValue;
begin
  P := GetItem(Index);
  if P <> nil then
    Remove(P.Key);
end;

destructor TYXDHashMapLinkTable.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FLinkHashPool);
end;

procedure TYXDHashMapLinkTable.DoAdd(ABucket: PHashMapList);
var
  AIndex: Integer;
  AItem: PHashList;
  P: PHashMapLinkItem;
begin
  P := Pointer(FPool.Pop);
  P.Value := ABucket.Data;
  P.Next := nil;
  if FFirst = nil then begin
    P.Prev := nil;
    FFirst := P;
    FLast := FFirst;
  end else begin
    P.Prev := FLast;
    FLast.Next := P;
    FLast := P;
  end;

  // ��ӵ�Hash����
  AIndex := NativeUInt(ABucket.Data) mod Cardinal(Length(ListBuckets));
  AItem := ListBuckets[AIndex];
  while AItem <> nil do begin
    if AItem.Hash = THashType(ABucket.Data) then begin
      AItem.Data := FLast;
      Exit
    end else
      AItem := AItem.Next;
  end;
  AItem := FLinkHashPool.Pop;
  AItem^.Hash := THashType(ABucket.Data);
  AItem^.Data := FLast;
  AItem^.Next := ListBuckets[AIndex];
  ListBuckets[AIndex] := AItem;
end;

procedure TYXDHashMapLinkTable.DoDelete(AHash: THashType; AData: Pointer);
var
  P: PHashMapLinkItem;
begin
  P := FindLinkItem(AData, True);
  if Assigned(FOnDelete) then begin
    try
      FOnDelete(Self, AHash, AData);
    except
      {$IFDEF MSWINDOWS}
      OutputDebugString(PChar(Exception(ExceptObject).Message));
      {$ENDIF}
    end;
  end;
  if P = nil then Exit;
  if P = FFirst then begin
    FFirst := FFirst.Next;
    if FFirst = nil then
      FLast := nil
    else
      FFirst.Prev := nil;
  end else if P = FLast then begin
    FLast := P.Prev;
    if FLast = nil then
      FFirst := nil
    else
      FLast.Next := nil;
  end else begin
    P.Prev.Next := P.Next;
    P.Next.Prev := P.Prev;
  end;
  FPool.Push(Pointer(P));
end;

function TYXDHashMapLinkTable.FindLinkItem(AData: Pointer;
  isDelete: Boolean): PHashMapLinkItem;
var
  Prev: PPHashList;
  P: PHashList;
begin
  Prev := @ListBuckets[NativeUInt(AData) mod Cardinal(Length(ListBuckets))];
  while Prev^ <> nil do begin
    if PHashMapLinkItem(Prev^.Data).Value = AData then begin
      if isDelete then begin
        P := Prev^;
        Result := P.Data;
        Prev^ := P.Next;
        FLinkHashPool.Push(P);
      end else
        Result := Prev^.Data;
      Exit;
    end else
      Prev := @Prev^.Next;
  end;
  Result := nil;
end;

procedure TYXDHashMapLinkTable.FreeLinkList;
var
  P, N: PHashMapLinkItem;
  I: Integer;
  P1, P2: PHashList;
begin
  P := FFirst;
  while P <> nil do begin
    N := P.Next;
    FPool.Push(Pointer(P));
    P := N;
  end;

  if Length(ListBuckets) > 0 then begin
    for I := 0 to Length(ListBuckets) - 1 do begin
      P1 := ListBuckets[i];
      ListBuckets[i] := nil;
      while P1 <> nil do begin
        P2 := P1.Next;
        FLinkHashPool.Push(P1);
        P1 := P2;
      end;
    end;
  end;

  FLinkHashPool.Clear;
  FFirst := nil;
  FLast := nil;
end;

function TYXDHashMapLinkTable.GetEnumerator: TYXDHashMapLinkTableEnumerator;
begin
  Result := TYXDHashMapLinkTableEnumerator.Create(Self);
end;

function TYXDHashMapLinkTable.GetItem(Index: Integer): PHashMapValue;
var
  P: PHashMapLinkItem;
  I: Integer;
begin
  if Index > (FCount shr 1) then begin
    if Index < FCount then begin
      P := FLast;
      if P <> nil then begin
        for I := FCount - Index - 1 downto 1 do
          P := P.Prev;
        Result := P.Value;
        Exit;
      end;
    end;
  end else if Index > -1 then begin
    P := FFirst;
    if P <> nil then begin
      for I := 0 to Index - 1 do
        P := P.Next;
      Result := P.Value;
      Exit;
    end;
  end;
  Result := nil;
end; 

function TYXDHashMapLinkTable.GetLast: PHashMapValue;
begin
  if FLast <> nil then
    Result := FLast.Value
  else
    Result := nil;
end;

function TYXDHashMapLinkTable.GetMemSize: Int64;
begin
  Result := inherited GetMemSize;
  Inc(Result, Length(ListBuckets) shl 2);
end;

{ TYXDHashMapLinkTableEnumerator }

constructor TYXDHashMapLinkTableEnumerator.Create(AList: TYXDHashMapLinkTable);
begin
  FItem := AList.FFirst;
end;

function TYXDHashMapLinkTableEnumerator.GetCurrent: PHashMapLinkItem;
begin
  Result := FItem;
  FItem := FItem.Next;
end;

function TYXDHashMapLinkTableEnumerator.MoveNext: Boolean;
begin
  Result := FItem <> nil;
end;

end.

