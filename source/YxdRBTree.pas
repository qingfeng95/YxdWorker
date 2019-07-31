unit YxdRBTree;

interface

{$IF RTLVersion>=24}
{$LEGACYIFEND ON}
{$IFEND}

{$IF defined(FPC) or defined(VER170) or defined(VER180) or defined(VER190) or defined(VER200) or defined(VER210)}
  {$DEFINE USEINLINE}
{$IFEND}

uses
  YxdMemPool,
  SysUtils, Classes, SyncObjs;

type
  /// <summary>�ȽϺ���</summary>
  /// <param name='P1'>��һ��Ҫ�ȽϵĲ���</param>
  /// <param name='P2'>�ڶ���Ҫ�ȽϵĲ���</param>
  /// <returns> ���P1<P2������С��0��ֵ�����P1>P2���ش���0��ֵ�������ȣ�����0</returns>
  TYXDCompare = function (P1, P2:Pointer): Integer of object;

type
  PRBNode = ^TRBNode;
  PPRBNode = ^PRBNode;
  TRBNode = {$IFNDEF USEINLINE}object{$ELSE}packed record{$ENDIF}
  private
    FParentColor: IntPtr;
    function GetParent: PRBNode;
    procedure SetParent(const Value: PRBNode);
    function RedParent: PRBNode; {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure SetBlack; {$IFDEF USEINLINE}inline;{$ENDIF}
  public
    Left: PRBNode;  // ����
    Right: PRBNode; // �ҽ��
    Data: Pointer;  // �������ݳ�Ա
  public
    procedure Free;
    procedure Assign(src: PRBNode);
    // ����Ϊ�ս�㣬���ú�IsEmpty������true
    procedure Clear;
    // ��һ��������㣬��Ӧ��rb_next_postorder����
    function NextPostOrder: PRBNode;
    // ��һ���ڵ�
    function Next: PRBNode;
    // ǰһ�����
    function Prior: PRBNode;
    // �Ƿ�Ϊ��
    function IsEmpty: Boolean; {$IFDEF USEINLINE}inline;{$ENDIF}
    // �Ƿ��Ǻڽ��
    function IsBlack: Boolean; {$IFDEF USEINLINE}inline;{$ENDIF}
    // �Ƿ�Ϊ����
    function IsRed: Boolean; {$IFDEF USEINLINE}inline;{$ENDIF}
    // �����������
    function LeftDeepest: PRBNode;
    // ���ø�������ɫ
    procedure SetParentAndColor(AParent: PRBNode; AColor:Integer); {$IFDEF USEINLINE}inline;{$ENDIF}
    // �����
    property Parent: PRBNode read GetParent write SetParent;
  end;

type
  TRBTree = class;
  TRBCompare = TYXDCompare;
  /// <summary>ɾ�����֪ͨ�¼�����ɾ��һ�������ʱ����</summary>
  /// <param name="ASender">�����¼��ĺ��������</param>
  /// <param name="ANode">Ҫɾ���Ľ��</param>
  TRBDeleteNotify = procedure (ASender: TRBTree; ANode: PRBNode) of object;
  // ���������¼�����û�뵽ɶʱ��Ҫ��ԭLinux�����д����ˣ���Ҳ�ͱ�����
  TRBRotateNotify = procedure (ASender: TRBTree; AOld, ANew: PRBNode) of object;
  TRBPropagateNotify = procedure (ASender: TRBTree; ANode, AStop: PRBNode) of object;
  TRBCopyNotify = TRBRotateNotify;

  /// <summary>
  /// �����Delphi�����װ (Դ��swish����Linux 3.14.4�ں˺����ʵ��)
  /// </summary>
  TRBTree = class
  private
    function GetIsEmpty: Boolean; {$IFDEF USEINLINE}inline;{$ENDIF}
  protected
    FRoot: PRBNode;
    FCount: Integer;
    FRBMempool: TMemPool;
    FOnCompare: TYXDCompare;
    FOnDelete: TRBDeleteNotify;
    FOnRotate: TRBRotateNotify;
    FOnCopy: TRBCopyNotify;
    FOnPropagate: TRBPropagateNotify;
    function EraseAugmented(node: PRBNode): PRBNode; {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure RotateSetParents(AOld, ANew: PRBNode; color: Integer); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure EraseColor(AParent: PRBNode); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure ChangeChild(AOld, ANew, parent: PRBNode); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure DoCopy(node1, node2: PRBNode); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure DoPropagate(node1, node2: PRBNode); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure InsertColor(AChild: PRBNode); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure InsertNode(node: PRBNode); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure DoRotate(AOld,ANew: PRBNode); {$IFDEF USEINLINE}inline;{$ENDIF}
    procedure LinkNode(node,parent: PRBNode; var rb_link: PRBNode); {$IFDEF USEINLINE}inline;{$ENDIF}
  public
    /// <summary>
    /// ���캯��������һ����С�ȽϺ�����ȥ���Ա��ڲ���Ͳ���ʱ�ܹ���ȷ������
    /// </summary>
    constructor Create(AOnCompare: TRBCompare); virtual;
    destructor Destroy;override;

    // ������еĽ��
    procedure Clear;
    // ɾ��һ�����, �ɹ������ر�ɾ������Data���ݳ�Ա��ַ��ʧ�ܻ򲻴��ڣ�����nil
    function Delete(AChild: PRBNode): Pointer; //rb_erase
    // �׸����
    function First: PRBNode;//rb_first
    // ���һ�����
    function Last: PRBNode; //rb_last
    // �׸����������
    function FirstPostOrder: PRBNode;//rb_first_postorder
    // ����һ�����ݣ��Ƚ��ɹ���ʱ������¼��ص���������, �ɹ�������true (���ָ����������ͬ�����Ѿ����ڣ��ͻ᷵��false)
    function Insert(AData:Pointer):Boolean;
    // ������ָ��������������ͬ�Ľ��, �����ҵ��Ľ��
    function Find(AData:Pointer): PRBNode;
    // �滻���, �滻Ҫ�Լ���֤���ݺ�Srcһ�£����������������ң�������ܱ�֤����ɾ��+���������滻
    procedure Replace(Src, ANew: PRBNode);

    // �ж����Ƿ�Ϊ����
    property IsEmpty: Boolean read GetIsEmpty;
    // �ȽϺ�����ע�ⲻҪ�����������ıȽ��㷨
    property OnCompare: TRBCompare read FOnCompare write FOnCompare;
    // ɾ���¼���Ӧ����
    property OnDelete: TRBDeleteNotify read FOnDelete write FOnDelete;
    // ��ת�¼�
    property OnRotate: TRBRotateNotify read FOnRotate write FOnRotate;
    // �����¼�
    property OnCopy: TRBCopyNotify read FOnCopy write FOnCopy;
    // ��ɢ�¼�
    property OnPropagate: TRBPropagateNotify read FOnPropagate write FOnPropagate;
    // �������
    property Count:Integer read FCount;
  end;

implementation

const
  RB_RED = 0;
  RB_BLACK = 1;

{ TRBNode }

procedure TRBNode.Assign(src: PRBNode);
begin
  FParentColor := src.FParentColor;
  Left := src.Left;
  Right := src.Right;
  Data := src.Data;
end;

procedure TRBNode.Clear;
begin
  FParentColor := IntPtr(@Self);
end;

procedure TRBNode.Free;
begin
  if Left <> nil then begin
    Left.Free;
    Dispose(Left);
  end;
  if Right <> nil then begin
    Right.Free;
    Dispose(Right);
  end;
end;

function TRBNode.GetParent: PRBNode;
begin
  Result := PRBNode(IntPtr(FParentColor) and (not $3));
end;

function TRBNode.IsBlack: Boolean;
begin
  Result := (IntPtr(FParentColor) and $1) <> 0;
end;

function TRBNode.IsEmpty: Boolean;
begin
  Result := (FParentColor = IntPtr(@Self));
end;

function TRBNode.IsRed: Boolean;
begin
  Result := ((IntPtr(FParentColor) and $1)=0);
end;

function TRBNode.LeftDeepest: PRBNode;
begin
  Result := @Self;
  while True do begin
    if Result.Left <> nil then
      Result := Result.Left
    else if Result.Right <> nil then
      Result := Result.Right
    else
      Break;
	end;
end;

function TRBNode.Next: PRBNode;
var
  node, LParent: PRBNode;
begin
  if IsEmpty then
    Result := nil
  else begin
    if Right <> nil then begin
      Result := Right;
      while Result.Left <> nil do
        Result := Result.Left;
      Exit;
    end;
    node := @Self;
    repeat
      LParent := node.Parent;
      if Assigned(LParent) and (node = LParent.Right) then
        node := LParent
      else
        Break;
    until LParent = nil;
    Result := LParent;
  end;
end;

function TRBNode.NextPostOrder: PRBNode;
begin
  Result := Parent;
  if (Result <> nil) and (@Self = Result.Left) and (Result.Right <> nil) then
    Result := Result.Right.LeftDeepest;
end;

function TRBNode.Prior: PRBNode;
var
  node, AParent: PRBNode;
begin
  if IsEmpty then
    Result := nil
  else begin
    if (Left <> nil) then begin
      Result := Left;
      while (Result.Right <> nil) do
        Result := Result.Right;
      Exit;
    end;
    node := @Self;
    repeat
      AParent := node.Parent;
      if (Parent <> nil) and (node = AParent.Left) then
        node := AParent
      else
        Break;
    until AParent = nil;
    Result := AParent;
  end;
end;

function TRBNode.RedParent: PRBNode;
begin
  Result := PRBNode(FParentColor);
end;

procedure TRBNode.SetBlack;
begin
  FParentColor := FParentColor or RB_BLACK;
end;

procedure TRBNode.SetParent(const Value: PRBNode);
begin
  FParentColor := IntPtr(Value) or (IntPtr(FParentColor) and $1);
end;

procedure TRBNode.SetParentAndColor(AParent: PRBNode; AColor: Integer);
begin
  FParentColor := IntPtr(AParent) or IntPtr(AColor);
end;

{ TRBTree }

procedure TRBTree.ChangeChild(AOld, ANew, parent: PRBNode);
begin
  if parent <> nil then begin
    if parent.Left = AOld then
      parent.Left := ANew
    else
      parent.Right := ANew;
  end else
    FRoot := ANew;
end;

procedure TRBTree.Clear;
var
  ANode: PRBNode;
begin
  if Assigned(OnDelete) then begin
    ANode := First;
    while ANode<>nil do begin
      OnDelete(Self, ANode);
      ANode := ANode.Next;
    end;
  end;
  if (FRoot <> nil) then begin
    FRoot.Free;
    Dispose(FRoot);
    FRoot := nil;
  end;
  FCount := 0;
end;

constructor TRBTree.Create(AOnCompare: TRBCompare);
begin
  FOnCompare := AOnCompare;
  FRBMempool := TMemPool.Create(SizeOf(TRBNode), 1024);
end;

function TRBTree.Delete(AChild: PRBNode): Pointer;
var
  rebalance: PRBNode;
begin
  Result := AChild.Data;
  rebalance := EraseAugmented(AChild);
  if rebalance <> nil then
    EraseColor(rebalance);
  AChild.Left := nil;
  AChild.Right := nil;
  Dec(FCount);
  if Assigned(FOnDelete) then
    FOnDelete(Self, AChild);
  AChild.Free;
  Dispose(AChild);
end;

destructor TRBTree.Destroy;
begin
  Clear;
  inherited;
  FreeAndNil(FRBMempool);
end;

procedure TRBTree.DoCopy(node1, node2: PRBNode);
begin
  if Assigned(FOnCopy) then
    FOnCopy(Self, node1, node2);
end;

procedure TRBTree.DoPropagate(node1, node2: PRBNode);
begin
  if Assigned(FOnPropagate) then
    FOnPropagate(Self, node1, node2);
end;

procedure TRBTree.DoRotate(AOld, ANew: PRBNode);
begin
  if Assigned(FOnRotate) then
    FOnRotate(Self, AOld, ANew);
end;

function TRBTree.EraseAugmented(node: PRBNode): PRBNode;
var
  child, tmp, AParent, rebalance: PRBNode;
  successor, child2: PRBNode;
  pc, pc2: IntPtr;
begin
  child := node.Right;
  tmp := node.Left;
  if tmp = nil then begin
    pc := node.FParentColor;
    AParent := node.Parent;
    ChangeChild(node, child, AParent);
    if child <> nil then begin
      child.FParentColor := pc;
      rebalance := nil;
    end else if (pc and RB_BLACK)<>0 then
      rebalance := AParent
    else
      rebalance := nil;
    tmp := AParent;
  end else if (child = nil) then begin
    tmp.FParentColor:=node.FParentColor;
    AParent := node.Parent;
    ChangeChild(node, tmp, AParent);
    rebalance := nil;
    tmp := AParent;
  end else begin
    successor := child;
    tmp := child.Left;
    if tmp = nil then begin
      AParent := successor;
      child2 := successor.Right;
      DoCopy(node, successor);
    end else begin
      repeat
        AParent := successor;
        successor := tmp;
        tmp := tmp.Left;
      until tmp=nil;
      AParent.Left := successor.Right;
      child2 := successor.Right;
      successor.Right := child;
      child.Parent := successor;
      DoCopy(node, successor);
      DoPropagate(AParent, successor);
    end;
    successor.Left := node.Left;
    tmp := node.Left;
    tmp.Parent := successor;
    pc := node.FParentColor;
    tmp := node.Parent;
    ChangeChild(node, successor, tmp);
    if child2 <> nil then begin
      successor.FParentColor := pc;
      child2.SetParentAndColor(AParent, RB_BLACK);
      rebalance := nil;
    end else begin
      pc2 := successor.FParentColor;
      successor.FParentColor := pc;
      if (pc2 and RB_BLACK)<>0 then
        rebalance := AParent
      else
        rebalance:=nil;
    end;
    tmp := successor;
  end;
  DoPropagate(tmp, nil);
  Result := rebalance;
end;

procedure TRBTree.EraseColor(AParent: PRBNode);
var
  node, sibling, tmp1, tmp2: PRBNode;
begin
  node := nil;
  while (true)do begin
    sibling := AParent.Right;
    if node <> sibling then begin
      {.$REGION 'node<>sibling'}
      if sibling.IsRed then begin
        {.$REGION 'slbling.IsRed'}
        AParent.Right := sibling.Left;
        tmp1 := sibling.Left;
        sibling.Left := AParent;
        tmp1.SetParentAndColor(AParent, RB_BLACK);
        RotateSetParents(AParent, sibling, RB_RED);
        DoRotate(AParent, sibling);
        sibling := tmp1;
      end;
      {.$ENDREGION 'slbling.IsRed'}
      tmp1:=sibling.Right;
      if (not Assigned(tmp1)) or tmp1.IsBlack then begin
        {.$REGION 'tmp1.IsBlack'}
        tmp2 := sibling.Left;
        if (not Assigned(tmp2)) or tmp2.IsBlack then begin
          {.$REGION 'tmp2.IsBlack'}
          sibling.SetParentAndColor(AParent, RB_RED);
          if AParent.IsRed then
            AParent.SetBlack
          else begin
            Node:=AParent;
            AParent:=node.Parent;
            if Assigned(AParent) then
              Continue;
          end;
          Break;
          {.$ENDREGION 'tmp2.IsBlack'}
        end;
        sibling.Left := tmp2.Right;
        tmp1 := tmp2.Right;
        tmp2.Right := sibling;
        AParent.Right := tmp2;
        if (tmp1 <> nil) then
          tmp1.SetParentAndColor(sibling, RB_BLACK);
        DoRotate(sibling, tmp2);
        tmp1 := sibling;
        sibling := tmp2;
        {.$ENDREGION 'tmp1.IsBlack'}
      end;
      AParent.Right := sibling.Left;
      tmp2 := sibling.Left;
      sibling.Left := AParent;
      tmp1.SetParentAndColor(sibling, RB_BLACK);
      if (tmp2 <> nil) then
        tmp2.Parent:=AParent;
      RotateSetParents(AParent, sibling, RB_BLACK);
      DoRotate(AParent, sibling);
      Break;
      {.$ENDREGION 'node<>sibling'}
    end else begin
      {.$REGION 'RootElse'}
      sibling := AParent.Left;
      if (sibling.IsRed) then begin
        {.$REGION 'Case 1 - right rotate at AParent'}
        AParent.Left := sibling.Right;
        tmp1 := sibling.Right;
        sibling.Right := AParent;
        tmp1.SetParentAndColor(AParent, RB_BLACK);
        RotateSetParents(AParent, sibling, RB_RED);
        DoRotate(AParent, sibling);
        sibling := tmp1;
        {.$ENDREGION 'Case 1 - right rotate at AParent'}
      end;
      tmp1 := sibling.Left;
      if (tmp1=nil) or tmp1.IsBlack then begin
        {.$REGION 'tmp1.IsBlack'}
        tmp2 := sibling.Right;
        if (tmp2=nil) or tmp2.IsBlack then begin
          {.$REGION 'tmp2.IsBlack'}
          sibling.SetParentAndColor(AParent, RB_RED);
          if AParent.IsRed then
            AParent.SetBlack
          else begin
            node := AParent;
            AParent := node.Parent;
            if Assigned(AParent) then
              continue;
          end;
          break;
          {.$ENDREGION 'tmp2.IsBlack'}
        end;
        sibling.Right := tmp2.Left;
        tmp1 := tmp2.Left;
        tmp2.Left := sibling;
        AParent.Left := tmp2;
        if Assigned(tmp1) then
          tmp1.SetParentAndColor(sibling, RB_BLACK);
        DoRotate(sibling, tmp2);
        tmp1 := sibling;
        sibling := tmp2;
        {.$ENDREGION ''tmp1.IsBlack'}
      end;
      AParent.Left := sibling.Right;
      tmp2 := sibling.Right;
      sibling.Right := AParent;
      tmp1.SetParentAndColor(sibling, RB_BLACK);
      if Assigned(tmp2) then
        tmp2.Parent := AParent;
      RotateSetParents(AParent, sibling, RB_BLACK);
      DoRotate(AParent, sibling);
      Break;
      {.$ENDREGION 'RootElse'}
    end;
  end;
end;

function TRBTree.Find(AData: Pointer): PRBNode;
var
  rc:Integer;
begin
  Result := FRoot;
  while Assigned(Result) do begin
    rc := OnCompare(AData,Result.Data);
    if rc < 0 then
      Result := Result.Left
    else if rc>0 then
      Result := Result.Right
    else
      Break;
	end
end;

function TRBTree.First: PRBNode;
begin
  Result := FRoot;
  if Result<>nil then begin
    while Assigned(Result.Left) do
      Result := Result.Left;
  end;
end;

function TRBTree.FirstPostOrder: PRBNode;
begin
  if Assigned(FRoot) then
    Result := FRoot.LeftDeepest
  else
    Result := nil;
end;

function TRBTree.GetIsEmpty: Boolean;
begin
  Result := (FRoot = nil);
end;

function TRBTree.Insert(AData: Pointer): Boolean;
var
  ANew: PPRBNode;
  parent, AChild: PRBNode;
  rc: Integer;
begin
  parent := nil;
  ANew := @FRoot;
  while ANew^ <> nil do begin
    parent := ANew^;
    rc := OnCompare(AData, parent.Data);
    if rc < 0 then
      ANew := @parent.Left
    else if rc > 0 then
      ANew := @parent.Right
    else begin //�Ѵ���
      Result := False;
      Exit;
    end;
  end;
  New(AChild);
  AChild.Data := AData;
  LinkNode(AChild, parent, ANew^);
  InsertNode(AChild);
  Inc(FCount);
  Result := True;
end;

procedure TRBTree.InsertColor(AChild: PRBNode);
begin
  InsertNode(AChild);
end;

procedure TRBTree.InsertNode(node: PRBNode);
var
  AParent, GParent, tmp: PRBNode;
begin
  AParent := Node.RedParent;
  while True do begin
    if AParent = nil then begin
      node.SetParentAndColor(nil, RB_BLACK);
      Break;
    end else if AParent.IsBlack then
      Break;
    gParent := AParent.RedParent;
    tmp := gParent.Right;
    if AParent <> tmp then begin
      if (tmp <> nil) and tmp.IsRed then begin
        tmp.SetParentAndColor(gParent, RB_BLACK);
        AParent.SetParentAndColor(gParent, RB_BLACK);
        node := gParent;
        AParent := node.Parent;
        node.SetParentAndColor(AParent, RB_RED);
        continue;
      end;
      tmp := AParent.Right;
      if node = tmp then begin
        AParent.Right := node.Left;
        tmp := node.Left;
        node.Left := AParent;
        if (tmp <> nil) then
          tmp.SetParentAndColor(AParent, RB_BLACK);
        AParent.SetParentAndColor(node, RB_RED);
        DoRotate(AParent, node);//augment_rotate(parent,node)
        AParent := node;
        tmp := Node.Right;
      end;
      gParent.Left := tmp;
      AParent.Right := gParent;
      if tmp <> nil then
        tmp.SetParentAndColor(gParent, RB_BLACK);
      RotateSetParents(gParent, AParent, RB_RED);
      DoRotate(gParent, AParent);
      Break;
    end else begin
      tmp := gParent.Left;
      if Assigned(tmp) and tmp.IsRed then begin
        tmp.SetParentAndColor(gParent, RB_BLACK);
        AParent.SetParentAndColor(gParent, RB_BLACK);
        node:=gParent;
        AParent:=node.Parent;
        node.SetParentAndColor(AParent,RB_RED);
        continue;
      end;
      tmp := AParent.Left;
      if node = tmp then begin
        AParent.Left := node.Right;
        tmp := Node.Right;
        node.Right := AParent;
        if tmp <> nil then
          tmp.SetParentAndColor(AParent, RB_BLACK);
        AParent.SetParentAndColor(node, RB_RED);
        DoRotate(AParent, node);
        AParent := node;
        tmp := node.Left;
      end;
      gParent.Right := tmp;
      AParent.Left := gParent;
      if tmp <> nil then
        tmp.SetParentAndColor(gParent, RB_BLACK);
      RotateSetParents(gparent, AParent, RB_RED);
      DoRotate(gParent, AParent);
      Break;
    end;
  end;
end;

function TRBTree.Last: PRBNode;
begin
  Result := FRoot;
  if Result<>nil then begin
    while Assigned(Result.Right) do
      Result := Result.Right;
	end;
end;

procedure TRBTree.LinkNode(node, parent: PRBNode; var rb_link: PRBNode);
begin
  node.FParentColor := IntPtr(parent);
  node.Left := nil;
  node.Right := nil;
  rb_link := node;
end;

procedure TRBTree.Replace(Src, ANew: PRBNode);
var
  parent: PRBNode;
begin
  parent := Src.Parent;
  ChangeChild(Src, ANew, parent);
  if Assigned(Src.Left) then
    Src.Left.SetParent(ANew)
  else
    Src.Right.SetParent(ANew);
  ANew.Assign(Src);
end;

procedure TRBTree.RotateSetParents(AOld, ANew: PRBNode; color: Integer);
var
  AParent: PRBNode;
begin
  AParent := AOld.Parent;
  ANew.FParentColor := AOld.FParentColor;
  AOld.SetParentAndColor(ANew, color);
  ChangeChild(AOld, ANew, AParent);
end;

end.
