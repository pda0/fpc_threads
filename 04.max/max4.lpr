(******************************************************************************
  Max4 - Threads demonstration program.

  Written in 2015 by Dmitriy Pomerantsev pda2@yandex.ru

  To the extent possible under law, the author(s) have dedicated all copyright
  and related and neighboring rights to this software to the public domain
  worldwide. This software is distributed without any warranty.

  You should have received a copy of the CC0 Public Domain Dedication along
  with this software.
  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 ******************************************************************************) 
{$MODE OBJFPC}{$H+}
program max4;

uses
  {$IF FPC_FULlVERSION < 20701}
    {$IF DEFINED(WINDOWS)}
    Windows,
    {$ELSEIF DEFINED(UNIX)}
      {$IFDEF UseCThreads}cthreads,{$ENDIF}
    ctypes,
      {$IF DEFINED(FREEBSD) OR DEFINED(DARWIN)}
      sysctl,
      {$IFEND}
    {$IFEND}
  {$ELSE}
    {$IFDEF UNIX}{$IFDEF UseCThreads}
    cmem, cthreads,
    {$ENDIF}{$ENDIF}
  {$ENDIF}
  Classes, SysUtils, Types, Math;

const
  NUMBERS = 100 * 1024 *1024 div SizeOf(Integer);

type
  TMaxThread = class(TThread)
  private
    class var FProcessorCount: LongWord;
  private
    FData: TIntegerDynArray;
    FStartIdx, FEndIdx: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const AData: TIntegerDynArray; StartIdx, EndIdx: Integer);
    class property ProcessorCount: LongWord read FProcessorCount;
  end;

var
  Data: TIntegerDynArray;
  Workers: array of TMaxThread;
  i, Result, WorkLen: Integer;

{$IF FPC_FULlVERSION < 20701}
  {$PUSH}
  {$WARN SYMBOL_PLATFORM OFF}
  {$IF DEFINED(WINDOWS)}
var
  SysInfo: TSystemInfo;
  {$ELSEIF DEFINED(LINUX)}
const
  _SC_NPROCESSORS_ONLN = 83;

function sysconf(i: cint): clong; cdecl; external 'c' name 'sysconf';
  {$ELSEIF DEFINED(FREEBSD) OR DEFINED(DARWIN)}
var
  mib: array[0..1] of cint;
  len: cint;
  t: cint;
  {$IFEND}
  {$POP}
{$IFEND}

{ TMaxThread }

constructor TMaxThread.Create(const AData: TIntegerDynArray; StartIdx, EndIdx:
  Integer);
begin
  FData := AData;
  FStartIdx := StartIdx;
  FEndIdx := EndIdx;
  inherited Create(True);
end;

procedure TMaxThread.Execute;
var
  i: Integer;
begin
  for i := FStartIdx to FEndIdx do
    ReturnValue := Max(ReturnValue, FData[i]);
end;

begin
{$IF FPC_FULlVERSION < 20701}
  {$IF DEFINED(WINDOWS)}
  {$PUSH}
  {$HINTS OFF}
  FillChar(SysInfo, SizeOf(SysInfo), 0);
  {$POP}
  GetSystemInfo(@SysInfo);
  TMaxThread.FProcessorCount := SysInfo.dwNumberOfProcessors;
  {$ELSEIF DEFINED(LINUX)}
  TMaxThread.FProcessorCount := sysconf(_SC_NPROCESSORS_ONLN);
  {$ELSEIF DEFINED(FREEBSD) OR DEFINED(DARWIN)}
  mib[0] := CTL_HW;
  mib[1] := HW_NCPU;
  len := SizeOf(t);
  fpsysctl(PChar(@mib), 2, @t, @len, nil, 0);
  TMaxThread.FProcessorCount := t;
  {$ELSE}
  TMaxThread.FProcessorCount := 1;
  {$IFEND}
{$IFEND}
  Writeln('This is "Max4" n-thread demonstration application.');
  Writeln('Generating numbers.');
  SetLength(Data, NUMBERS);
  for i := Low(Data) to High(Data) do
    Data[i] := Random(High(Integer));

  { Initializing workers }
  Writeln('Threads count: ', TMaxThread.ProcessorCount);
  SetLength(Workers, TMaxThread.ProcessorCount);
  FillChar(Workers[0], TMaxThread.ProcessorCount * SizeOf(TMaxThread), 0);

  WorkLen := Length(Data) div Integer(TMaxThread.ProcessorCount);
  for i := 0 to Integer(TMaxThread.ProcessorCount) - 1 do
    if i < Integer(TMaxThread.ProcessorCount) - 1 then
      Workers[i] := TMaxThread.Create(Data, i * WorkLen, ((i + 1) * WorkLen) - 1)
    else
      Workers[i] := TMaxThread.Create(Data, i * WorkLen, High(Data));

  Writeln('Searching for max number.');
  try
    for i := 0 to Integer(TMaxThread.ProcessorCount) - 1 do
      Workers[i].Start;

    Result := 0;
    for i := 0 to Integer(TMaxThread.ProcessorCount) - 1 do
      Result := Max(Result, Workers[i].WaitFor);
    Writeln('Max number is: ', Result);
  finally
    for i := 0 to Integer(TMaxThread.ProcessorCount) - 1 do
      FreeAndNil(Workers[i]);
  end;

  {$IFDEF WINDOWS}
  Writeln('Press "Enter" key to close program.');
  Readln;
  {$ENDIF}
end.
