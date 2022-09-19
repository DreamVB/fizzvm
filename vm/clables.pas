unit cLables;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  Item = packed record
    id: integer;
    Name: string;
  end;

type
  TLabelCollection = class
  private
    mList: array of Item;
    Counter: integer;
  public
    procedure AddNewLabel(Key: string; id: integer);
    function GetLabelID(Key: string): integer;
    function LabelExsits(Key: string): boolean;
    constructor Create(Size: integer);
    procedure Free;
  end;

implementation

constructor TLabelCollection.Create(Size: integer);
begin
  Counter := 0;
  SetLength(mList, Size + 1);
end;

procedure TLabelCollection.AddNewLabel(Key: string; id: integer);
begin
  mList[Counter].id := id;
  mList[Counter].Name := UpperCase(Key);
  Inc(Counter);
end;

function TLabelCollection.LabelExsits(Key: string): boolean;
var
  I: integer;
  idx: integer;
begin
  idx := -1;

  for I := 0 to Counter - 1 do
  begin
    if mList[I].Name = UpperCase(Key) then
    begin
      idx := I;
      break;
    end;
  end;

  Result := idx <> -1;
end;

function TLabelCollection.GetLabelID(Key: string): integer;
var
  I: integer;
  idx: integer;
begin
  idx := -1;

  for I := 0 to Counter - 1 do
  begin
    if mList[I].Name = UpperCase(Key) then
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
    Result := mList[idx].id;
  end;
end;

procedure TLabelCollection.Free;
begin
  Counter := 0;
  SetLength(mList, 0);
end;

end.
