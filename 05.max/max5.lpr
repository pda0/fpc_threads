(******************************************************************************
  Max5 - Threads demonstration program.

  Written in 2015 by Dmitriy Pomerantsev pda2@yandex.ru

  To the extent possible under law, the author(s) have dedicated all copyright
  and related and neighboring rights to this software to the public domain
  worldwide. This software is distributed without any warranty.

  You should have received a copy of the CC0 Public Domain Dedication along
  with this software.
  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 ******************************************************************************)
{$MODE OBJFPC}{$H+}
program max5;

uses
  {$IFDEF UNIX}
  {$IFDEF UseCThreads}{$IFNDEF DEBUG}cmem,{$ENDIF}cthreads,{$ENDIF}
  {$ENDIF}
  Classes, SysUtils, Types, Math,
  ThreadsPlus in '../ThreadsPlus.pas';

const
  NUMBERS = 100 * 1024 *1024 div SizeOf(Integer);

type
  TMaxThread = class(TThread)
  private
    FData: TIntegerDynArray;
    FStartIdx, FEndIdx: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const AData: TIntegerDynArray; StartIdx, EndIdx: Integer;
      NeedFail: Boolean);
  end;

var
  Data, Results: TIntegerDynArray;
  Workers: array of TMaxThread;
  i, Result, WorkLen: Integer;

{ TMaxThread }

constructor TMaxThread.Create(const AData: TIntegerDynArray; StartIdx, EndIdx:
  Integer; NeedFail: Boolean);
begin
  if NeedFail then
    FStartIdx := -1
  else begin
    FData := AData;
    FStartIdx := StartIdx;
    FEndIdx := EndIdx;
  end;
  inherited Create(True);
end;

procedure TMaxThread.Execute;
var
  i: Integer;
begin
  if FStartIdx < 0 then
    Abort;

  for i := FStartIdx to FEndIdx do
    ReturnValue := Max(ReturnValue, FData[i]);
end;

begin
  Writeln('This is "Max5" n-thread demonstration application.');
  Writeln('Generating numbers.');
  SetLength(Data, NUMBERS);
  for i := Low(Data) to High(Data) do
    Data[i] := Random(High(Integer));

  { Initializing workers }
  Writeln('Single CPU: ', TThread.IsSingleProcessor);
  Writeln('Threads count: ', TThread.ProcessorCount * 2);
  SetLength(Workers, TThread.ProcessorCount * 2);
  SetLength(Results, Length(Workers));
  FillChar(Workers[0], Length(Workers) * SizeOf(TMaxThread), 0);
  FillChar(Results[0], Length(Results) * SizeOf(Integer), 0);

  WorkLen := Length(Data) div Length(Workers);
  for i := 0 to Length(Workers) - 1 do
    if i < Integer(TThread.ProcessorCount) - 1 then
      Workers[i] := TMaxThread.Create(Data, i * WorkLen, ((i + 1) * WorkLen) - 1, i = 1)
    else
      Workers[i] := TMaxThread.Create(Data, i * WorkLen, High(Data), i = 1);

  Writeln('Searching for max number.');
  try
    for i := 0 to Length(Workers) - 1 do
      Workers[i].Start;

    for i := 0 to Length(Workers) - 1 do
      Results[i] := Workers[i].WaitFor;

    Result := -1;
    for i := 0 to Length(Workers) - 1 do
    begin
      Write('Thread ', i, ': ');
      if Assigned(Workers[i].FatalException) then
        Writeln(Workers[i].FatalException.ClassName)
      else begin
        Writeln('OK');
        Result := Max(Result, Results[i]);
      end;
    end;
    Writeln('Max number is: ', Result);
  finally
    for i := 0 to Length(Workers) - 1 do
      FreeAndNil(Workers[i]);
  end;

  {$IFDEF WINDOWS}
  Writeln('Press "Enter" key to close program.');
  Readln;
  {$ENDIF}
end.
