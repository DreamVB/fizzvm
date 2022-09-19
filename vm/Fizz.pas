program Fizz;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
                             {$ENDIF}
  Classes,
  SysUtils,
  cLables,
  cStack,
  cVars { you can add units after this };

type
  TOpcodes = (NOP = 0, ICONST, ICONST_M1, ICONST_0, ICONST_1, ICONST_2,
    ICONST_3, ICONST_4, ICONST_5, IADD, ISUB,
    IMUL, IDIV, IREM, IINC, IDEC, INOT, IAND, IOR, IXOR, ISHL, ISHR,
    DUP, NEG, SWAP, POP, POP2,
    ISTORE, ISTORE_0, ISTORE_1, ISTORE_2, ISTORE_3,
    ILOAD, ILOAD_0, ILOAD_1, ILOAD_2, ILOAD_3,
    LT, GT, LEQ, GEQ, EQ, NEQ, IGOTO, JT, JZ, JNZ, SYSCALL, CALL, RET,
    HALT, OpError);

var
  ds: TMyStack;
  cs: TMyStack;
  lables: TLabelCollection;
  variables: TVariable;

  //Program counter
  ByteCode: array of integer;
  ByteLength: integer;
  PC: integer;
  SrcFile: string;

const
  MAX_STACK = 960;
const
  MAX_VARS = 256;
const
  MAX_LABLES = 256;

const
  MAX_RETURNS = 265;

  procedure Split(Delimiter: char; Str: string; ListOfStrings: TStrings);
  begin
    ListOfStrings.Clear;
    ListOfStrings.Delimiter := Delimiter;
    ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
    ListOfStrings.DelimitedText := Str;
  end;

  function IsCharConst(S: string): boolean;
  begin
    Result := False;
    if (Length(S) = 3) and (LeftStr(S, 1) = '''') and (RightStr(S, 1) = '''') then
    begin
      Result := True;
    end;
  end;

  function BoolToInt(B: boolean): integer;
  begin
    if B then
    begin
      Result := 1;
    end
    else
    begin
      Result := 0;
    end;
  end;

  function IsInt(S: string): boolean;
  var
    X: integer;
    flag: boolean;
  begin
    flag := True;

    for X := 1 to Length(S) do
    begin
      if not (S[X] in ['0'..'9', '-']) then
      begin
        flag := False;
        Break;
      end;
    end;

    Result := flag;

  end;

  function InstToInt(tok: string): integer;
  begin
    if tok = 'ICONST' then
    begin
      Result := Ord(ICONST);
    end
    else if tok = 'ICONST_M1' then
    begin
      Result := Ord(ICONST_M1);
    end
    else if tok = 'ICONST_0' then
    begin
      Result := Ord(ICONST_0);
    end
    else if tok = 'ICONST_1' then
    begin
      Result := Ord(ICONST_1);
    end
    else if tok = 'ICONST_2' then
    begin
      Result := Ord(ICONST_2);
    end
    else if tok = 'ICONST_3' then
    begin
      Result := Ord(ICONST_3);
    end
    else if tok = 'ICONST_4' then
    begin
      Result := Ord(ICONST_4);
    end
    else if tok = 'ICONST_5' then
    begin
      Result := Ord(ICONST_5);
    end
    else if tok = 'ADD' then
    begin
      Result := Ord(IADD);
    end
    else if tok = 'SUB' then
    begin
      Result := Ord(ISUB);
    end
    else if tok = 'MUL' then
    begin
      Result := Ord(IMUL);
    end
    else if tok = 'DIV' then
    begin
      Result := Ord(IDIV);
    end
    else if tok = 'REM' then
    begin
      Result := Ord(IREM);
    end
    else if tok = 'AND' then
    begin
      Result := Ord(IAND);
    end
    else if tok = 'OR' then
    begin
      Result := Ord(IOR);
    end
    else if tok = 'XOR' then
    begin
      Result := Ord(IXOR);
    end
    else if tok = 'SHL' then
    begin
      Result := Ord(ISHL);
    end
    else if tok = 'SHR' then
    begin
      Result := Ord(ISHR);
    end
    else if tok = 'INC' then
    begin
      Result := Ord(IINC);
    end
    else if tok = 'DEC' then
    begin
      Result := Ord(IDEC);
    end
    else if tok = 'DUP' then
    begin
      Result := Ord(DUP);
    end
    else if tok = 'NEG' then
    begin
      Result := Ord(NEG);
    end
    else if tok = 'NOT' then
    begin
      Result := Ord(INOT);
    end
    else if tok = 'SWAP' then
    begin
      Result := Ord(SWAP);
    end
    else if tok = 'POP' then
    begin
      Result := Ord(POP);
    end
    else if tok = 'POP2' then
    begin
      Result := Ord(POP2);
    end
    else if tok = 'ILOAD' then
    begin
      Result := Ord(ILOAD);
    end
    else if tok = 'ILOAD_0' then
    begin
      Result := Ord(ILOAD_0);
    end
    else if tok = 'ILOAD_1' then
    begin
      Result := Ord(ILOAD_1);
    end
    else if tok = 'ILOAD_2' then
    begin
      Result := Ord(ILOAD_2);
    end
    else if tok = 'ILOAD_3' then
    begin
      Result := Ord(ILOAD_3);
    end
    else if tok = 'ISTORE' then
    begin
      Result := Ord(ISTORE);
    end
    else if tok = 'ISTORE_0' then
    begin
      Result := Ord(ISTORE_0);
    end
    else if tok = 'ISTORE_1' then
    begin
      Result := Ord(ISTORE_1);
    end
    else if tok = 'ISTORE_2' then
    begin
      Result := Ord(ISTORE_2);
    end
    else if tok = 'ISTORE_3' then
    begin
      Result := Ord(ISTORE_3);
    end
    else if tok = 'LT' then
    begin
      Result := Ord(LT);
    end
    else if tok = 'GT' then
    begin
      Result := Ord(GT);
    end
    else if tok = 'LEQ' then
    begin
      Result := Ord(LEQ);
    end
    else if tok = 'GEQ' then
    begin
      Result := Ord(GEQ);
    end
    else if tok = 'EQ' then
    begin
      Result := Ord(EQ);
    end
    else if tok = 'NEQ' then
    begin
      Result := Ord(NEQ);
    end
    else if tok = 'SYSCALL' then
    begin
      Result := Ord(SYSCALL);
    end
    else if tok = 'CALL' then
    begin
      Result := Ord(CALL);
    end
    else if tok = 'RET' then
    begin
      Result := Ord(RET);
    end
    else if tok = 'GOTO' then
    begin
      Result := Ord(IGOTO);
    end
    else if tok = 'JZ' then
    begin
      Result := Ord(JZ);
    end
    else if tok = 'JT' then
    begin
      Result := Ord(JT);
    end
    else if tok = 'JNZ' then
    begin
      Result := Ord(JNZ);
    end
    else if tok = 'NOP' then
    begin
      Result := Ord(NOP);
    end
    else if tok = 'HALT' then
    begin
      Result := Ord(HALT);
    end
    else
    begin
      Result := Ord(OpError);
    end;
  end;

  function GetWSPos(S: string): integer;
  var
    i, idx: integer;
  begin
    idx := 0;

    for i := 1 to length(s) do
    begin
      if s[i] in [#32, #9] then
      begin
        idx := i;
        Break;
      end;
    end;

    Result := idx;
  end;

  procedure Abort_1(code: integer; args: string = '');
  begin

    writeln('FizzVM Version 1.0');
    writeln('Compile Error');
    writeln('Code: ' + IntToStr(code));

    case code of
      0:
      begin
        writeln('No filename present');
      end;
      1:
      begin
        writeln('Source filename not found: ' + args);
      end;
      2:
      begin
        writeln('Source filename was empty');
      end;
      3:
      begin
        writeln('Unknown token found: , ' + args);
      end;
      4:
      begin
        writeln('Syntax error in declare .globals');
      end;
    end;
  end;

  procedure Abort_2(code: integer; args: string = '');
  begin
    //Set the program counter to the length of the bytecode
    PC := ByteLength;

    writeln('FizzVM Version 1.0');
    writeln('Runtime Error');
    writeln('Code: ' + IntToStr(code));

    case code of
      1:
      begin
        writeln('Unknown system call, ' + args);
      end;
      2:
      begin
        writeln('There should be aleast two items on the stack');
      end;
      3:
      begin
        writeln('There should be aleast one item on the stack');
      end;
      4:
      begin
        writeln('Integer value expected');
      end
      else
      begin
        writeln('Unkown runtime error');
      end;
    end;
  end;

  function assemble_code(Lines: TStringList): boolean;
  var
    I, J: integer;
    BCode: integer;
    sLine: string;
    flag: boolean;
    s_pos: integer;
    Tokens, Parts: TStringList;
    gVars: TStringList;
    gVarSlot: string;
  begin

    flag := True;
    Tokens := TStringList.Create;
    Parts := TStringList.Create;

    variables := TVariable.Create(MAX_VARS);
    lables := TLabelCollection.Create(MAX_LABLES);

    sLine := '';

    for I := 0 to Lines.Count - 1 do
    begin
      sLine := Trim(Lines[I]);

      if (Length(sLine) > 0) and (LeftStr(sLine, 1) <> '#') then
      begin
        //Check for decalre global variables
        if leftstr(sLine, 1) = '.' then
        begin
          gVars := TStringList.Create;
          //Split the decalare line
          Split(#32, sLine, gVars);
          //Check count must be 3
          if gVars.Count <> 3 then
          begin
            flag := False;
            Abort_1(4);
            Break;
          end;

          //Check for decalre global variables
          if UpperCase(gVars[0]) <> '.GLOBALS' then
          begin
            flag := False;
            Abort_1(3, gVars[0]);
            Break;
          end
          else
          begin
            gVarSlot := Trim(gVars[1]);
            //Remove [ and ]
            Delete(gVarSlot, 1, 1);
            Delete(gVarSlot, length(gVarSlot), 1);
            //Add the variable.
            variables.AddVar(gVars[2], StrToInt(gVarSlot));
          end;
          //Clear split parts
          gVars.Clear;
        end
        else
        begin
          s_pos := GetWSPos(sLine);

          if s_pos > 0 then
          begin
            Parts.Add(Trim(LeftStr(sLine, s_pos)));
            Parts.Add(Trim(Copy(sLine, s_pos)));
          end
          else
          begin
            //code
            Parts.Add(sLine);
          end;

          for J := 0 to Parts.Count - 1 do
          begin
            sLine := Parts[J];

            if Length(sLine) > 0 then
            begin
              //Check for lables
              if RightStr(sLine, 1) = ':' then
              begin
                Delete(sLine, Length(sLine), 1);
                //Add lable name and location to lables collection.
                lables.AddNewLabel(sLine, Tokens.Count - 1);
              end
              else
              begin
                //Add the tokens found to the tokens string list
                Tokens.Add(sLine);
              end;
            end;
          end;
          Parts.Clear;
        end;
      end;
    end;

    ByteLength := Tokens.Count;
    flag := ByteLength > 0;

    if flag then
    begin
      SetLength(ByteCode, ByteLength + 1);

      for J := 0 to ByteLength - 1 do
      begin
        sLine := UpperCase(Tokens[J]);
        BCode := InstToInt(sLine);

        if BCode <> Ord(OpError) then
        begin
          ByteCode[J] := BCode;
        end
        else if IsInt(sLine) then
        begin
          ByteCode[J] := StrToInt(sLine);
        end
        else if variables.IsVar(Tokens[J]) then
        begin
          ByteCode[J] := variables.GetVarLoc(Tokens[J]);
        end
        else if lables.LabelExsits(Tokens[J]) then
        begin
          ByteCode[J] := lables.GetLabelID(Tokens[J]);
        end
        else if IsCharConst(Tokens[J]) then
        begin
          ByteCode[J] := Ord(Tokens[J][2]);
        end
        else
        begin
          Abort_1(3, Tokens[J]);
          flag := False;
          Break;
        end;
      end;
    end;

    Tokens.Clear;

    if not flag then
    begin
      ByteLength := 0;
      SetLength(ByteCode, ByteLength);
    end;
    //Return flag result
    Result := flag;
  end;

  function LoadSource(Filename: string): boolean;
  var
    flag: boolean;
    fData: TStringList;
  begin
    flag := FileExists(Filename);

    if not flag then
    begin
      Abort_1(1, Filename);
      Result := flag;
    end
    else
    begin
      fData := TStringList.Create;
      fData.LoadFromFile(Filename);

      if fData.Count = 0 then
      begin
        flag := False;
        Abort_1(2);
      end
      else
      begin
        flag := assemble_code(fData);
      end;
    end;
    fData.Clear;
    Result := flag;
  end;

  procedure ResetVM;
  begin
    lables.Free;
    variables.Free;
    ds.Free;
    cs.Free;
    SetLength(ByteCode, 0);
  end;

  procedure DoILoad(inst: TOpcodes);
  begin
    case inst of
      ILOAD_0:
      begin
        ds.Push(variables.GetVarData(0));
      end;
      ILOAD_1:
      begin
        ds.Push(variables.GetVarData(1));
      end;
      ILOAD_2:
      begin
        ds.Push(variables.GetVarData(2));
      end;
      ILOAD_3:
      begin
        ds.Push(variables.GetVarData(3));
      end;
    end;
  end;

  procedure DoIStore(inst: TOpcodes);
  begin
    case inst of
      ISTORE_0:
      begin
        variables.SetVar(0, ds.Pop());
      end;
      ISTORE_1:
      begin
        variables.SetVar(1, ds.Pop());
      end;
      ISTORE_2:
      begin
        variables.SetVar(2, ds.Pop());
      end;
      ISTORE_3:
      begin
        variables.SetVar(3, ds.Pop());
      end;
    end;
  end;

  procedure CreateConst(inst: TOpcodes);
  begin
    case inst of
      ICONST_M1:
      begin
        ds.Push(-1);
      end;
      ICONST_0:
      begin
        ds.Push(0);
      end;
      ICONST_1:
      begin
        ds.Push(1);
      end;
      ICONST_2:
      begin
        ds.Push(2);
      end;
      ICONST_3:
      begin
        ds.Push(3);
      end;
      ICONST_4:
      begin
        ds.Push(4);
      end;
      ICONST_5:
      begin
        ds.Push(5);
      end;
    end;
  end;

  procedure DoBinaryOp(inst: TOpcodes);
  var
    A, B: integer;
  begin

    B := ds.Pop();
    A := ds.Pop();

    case inst of
      IADD:
      begin
        ds.Push(A + B);
      end;
      ISUB:
      begin
        ds.Push(A - B);
      end;
      IMUL:
      begin
        ds.Push(A * B);
      end;
      IDIV:
      begin
        ds.Push(A div B);
      end;
      IREM:
      begin
        ds.Push(A mod B);
      end;
      SWAP:
      begin
        ds.Push(A);
        ds.Push(B);
      end;
    end;
  end;

  procedure DoCompare(inst: TOpcodes);
  var
    A, B: integer;
  begin
    B := ds.Pop();
    A := ds.Pop();

    case inst of
      LT:
      begin
        ds.Push(BoolToInt(A < B));
      end;
      GT:
      begin
        ds.Push(BoolToInt(A > B));
      end;
      LEQ:
      begin
        ds.Push(BoolToInt(A <= B));
      end;
      GEQ:
      begin
        ds.Push(BoolToInt(A >= B));
      end;
      EQ:
      begin
        ds.Push(BoolToInt(A = B));
      end;
      NEQ:
      begin
        ds.Push(BoolToInt(A <> B));
      end;
    end;
  end;

  procedure DoBitWise(inst: TOpcodes);
  var
    A, B: integer;
  begin
    B := ds.Pop();
    A := ds.Pop();

    case inst of
      IAND:
      begin
        ds.Push(A and B);
      end;
      IOR:
      begin
        ds.Push(A or B);
      end;
      IXOR:
      begin
        ds.Push(A xor B);
      end;
      ISHL:
      begin
        ds.Push(A shl B);
      end;
      ISHR:
      begin
        ds.Push(A shr B);
      end;
    end;
  end;

  procedure DoSysCall(id: integer);
  var
    iNum: string;
  begin

    if ds.Count < 1 then
    begin
      if (id = 1) or (id = 2) or (id = 3) then
      begin
        Abort_2(3);
        exit;
      end;
    end;

    case id of
      1:
      begin
        Write(ds.Pop());
      end;
      2:
      begin
        writeln(ds.Pop());
      end;
      3:
      begin
        Write(chr(ds.Pop()));
      end;
      4:
      begin
        Read(iNum);
        if not IsInt(iNum) then
        begin
          Abort_2(4);
        end
        else
        begin
          ds.Push(StrToInt(iNum));
        end;
      end
      else
      begin
        Abort_2(1, IntToStr(id));
      end;
    end;
  end;

  function StartVM: boolean;
  var
    inst: TOpcodes;
    con: integer;
  begin
    PC := 0;
    con := 0;

    ds := TMyStack.Create(MAX_STACK);
    cs := TMyStack.Create(MAX_RETURNS);

    while PC < ByteLength do
    begin
      //Get insturction
      inst := TOpcodes(ByteCode[PC]);

      case inst of
        NOP:
        begin
          //Do nothing
        end;
        ICONST:
        begin
          Inc(PC);
          ds.Push(ByteCode[PC]);
        end;
        ICONST_M1, ICONST_0, ICONST_1, ICONST_2, ICONST_3, ICONST_4, ICONST_5:
        begin
          CreateConst(inst);
        end;
        ISTORE:
        begin
          Inc(PC);
          variables.SetVar(ByteCode[PC], ds.Pop());
        end;
        ISTORE_0, ISTORE_1, ISTORE_2, ISTORE_3:
        begin
          DoIStore(inst);
        end;
        ILOAD_0, ILOAD_1, ILOAD_2, ILOAD_3:
        begin
          DoILoad(inst);
        end;
        ILOAD:
        begin
          Inc(PC);
          ds.Push(variables.GetVarData(ByteCode[PC]));
        end;
        IADD, ISUB, IMUL, IDIV, IREM, SWAP:
        begin
          if ds.Count < 2 then
          begin
            Abort_2(2);
          end
          else
          begin
            DoBinaryOp(inst);
          end;
        end;
        LT, GT, LEQ, GEQ, EQ, NEQ:
        begin
          if ds.Count < 2 then
          begin
            Abort_2(2);
          end
          else
          begin
            DoCompare(inst);
          end;
        end;
        IAND, IOR, IXOR, ISHL, ISHR:
        begin
          if ds.Count < 2 then
          begin
            Abort_2(2);
          end
          else
          begin
            DoBitWise(inst);
          end;
        end;
        IINC:
        begin
          ds.Push(ds.Pop() + 1);
        end;
        IDEC:
        begin
          ds.Push(ds.Pop() - 1);
        end;
        DUP:
        begin
          ds.Push(ds.Peek());
        end;
        NEG:
        begin
          ds.Push(-ds.Pop());
        end;
        INOT:
        begin
          ds.Push(not ds.Pop());
        end;
        IGOTO:
        begin
          Inc(PC);
          PC := ByteCode[PC];
        end;
        JZ:
        begin
          Inc(PC);
          if ds.Pop() = 0 then
          begin
            PC := ByteCode[PC];
          end;
        end;
        JT:
        begin
          Inc(PC);
          if ds.Pop() = 1 then
          begin
            PC := ByteCode[PC];
          end;
        end;
        JNZ:
        begin
          Inc(PC);
          if ds.Peek() <> 0 then
          begin
            PC := ByteCode[PC];
          end;
        end;
        POP:
        begin
          ds.Pop();
        end;
        POP2:
        begin
          if ds.Count < 2 then
          begin
            Abort_2(2);
          end
          else
          begin
            ds.Pop();
            ds.Pop();
          end;
        end;
        SYSCALL:
        begin
          Inc(PC);
          con := ByteCode[PC];
          DoSysCall(con);
        end;
        CALL:
        begin
          cs.Push(PC + 1);
          Inc(PC);
          PC := ByteCode[PC];
        end;
        RET:
        begin
          PC := cs.Pop();
        end;
        HALT:
        begin
          PC := ByteLength;
        end;
      end;

      Inc(PC);
    end;

    Result := False;
  end;

begin
  if paramcount = 0 then
  begin
    Abort_1(0);
    Exit;
  end
  else
  begin
    //Get source file.
    SrcFile := ParamStr(1);

    //Load the source
    if not LoadSource(SrcFile) then
    begin
      Exit;
    end
    else
    begin
      if StartVM then ResetVM;
    end;
  end;
end.
