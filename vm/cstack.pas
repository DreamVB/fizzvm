unit cStack;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TMyStack = class

  private
    //Hold stack size and stack position.
    Stack_size, StackPtr: integer;
    //This hold items for our stack
    //Stack items
    T_Items: array of integer;
  public
    //To create the stack
    constructor Create(Size: integer);
    //Return stack count
    property Count: integer read StackPtr;
    //Push items onto stack
    procedure Push(Item: integer);
    //Pop items of stack
    function Pop(): integer;
    //Peek at the first item.
    function Peek(): integer;
    //Tells us if stack id full.
    function IsFull(): boolean;
    //Tells us if stack empry.
    function IsEmpty(): boolean;
    procedure Free;
  end;

implementation

constructor TMyStack.Create(Size: integer);
begin
  StackPtr := 0;
  Stack_size := Size;
  //Set size of stack
  SetLength(T_Items, Stack_size);
end;

procedure TMyStack.Push(Item: integer);
begin
  if not IsFull then
  begin
    //Push items on the stack.
    T_Items[StackPtr + 1] := Item;
    StackPtr := StackPtr + 1;
  end;
end;

function TMyStack.Pop(): integer;
begin
  if not IsEmpty then
  begin
    //Return item from stack.
    Result := T_Items[StackPtr];
    StackPtr := StackPtr - 1;
  end;
end;

function TMyStack.Peek(): integer;
begin
  Peek := T_Items[StackPtr];
end;

function TMyStack.IsFull(): boolean;
begin
  IsFull := (StackPtr = Stack_size);
end;

function TMyStack.IsEmpty(): boolean;
begin
  Result := (StackPtr = 0);
end;

procedure TMyStack.Free();
begin
  Stack_size := 0;
  StackPtr := 0;
  SetLength(T_Items, 0);
end;

end.
