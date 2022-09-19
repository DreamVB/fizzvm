unit cVars;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  Item = packed record
    Name: string;
    Loc: integer;
    Data: integer;
  end;

type
  TVariable = class
  private
    mList: array of Item;
    Counter: integer;
  public
    procedure SetVar(Slot: integer; Data: integer);
    procedure AddVar(Key: string; Slot: integer);
    function GetVarData(Loc: integer): integer;
    function GetVarID(Key: string): integer;
    function GetVarLoc(Key: string): integer;
    function IsVar(Name: string): boolean;
    procedure Free;
    constructor Create(Size: integer);
  end;

implementation

constructor TVariable.Create(Size: integer);
var
  I: integer;
begin
  Counter := 0;
  SetLength(mList, Size + 1);

  for I := 0 to Size do
  begin
    mList[I].Loc := 0;
    mList[I].Data := 0;
  end;
end;

procedure TVariable.AddVar(Key: string; Slot: integer);
begin
  mList[Counter].Name := Key;
  mList[Counter].Data := 0;
  mList[Counter].Loc := Slot;
  Inc(Counter);
end;

procedure TVariable.SetVar(Slot: integer; Data: integer);
begin
  mList[Slot].Data := Data;
end;

function TVariable.GetVarID(Key: string): integer;
var
  I: integer;
  idx: integer;
begin
  idx := -1;

  for I := 0 to Counter - 1 do
  begin
    if UpperCase(mList[I].Name) = UpperCase(Key) then
    begin
      idx := I;
      break;
    end;
  end;

  if idx = -1 then
  begin
    Result := -1;
  end
  else
  begin
    Result := idx;
  end;
end;

function TVariable.GetVarLoc(Key: string): integer;
var
  l: integer;
begin
  l := GetVarID(Key);

  if l = -1 then
  begin
    Result := -1;
  end
  else
  begin
    Result := mList[l].Loc;
  end;

end;

function TVariable.GetVarData(Loc: integer): integer;
var
  idx: integer;
begin
  idx := Loc;

  if idx <> -1 then
  begin
    Result := mList[idx].Data;
  end;

end;

function TVariable.IsVar(Name: string): boolean;
begin
  Result := GetVarID(Name) <> -1;
end;

procedure TVariable.Free;
begin
  Counter := 0;
  SetLength(mList, Counter);
end;

end.
