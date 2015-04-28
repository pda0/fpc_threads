(******************************************************************************
  Max3 - Threads demonstration program.

  Written in 2015 by Dmitriy Pomerantsev pda2@yandex.ru

  To the extent possible under law, the author(s) have dedicated all copyright
  and related and neighboring rights to this software to the public domain
  worldwide. This software is distributed without any warranty.

  You should have received a copy of the CC0 Public Domain Dedication along
  with this software.
  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 ******************************************************************************)
{$MODE OBJFPC}{$H+}
program max3;

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, Types, Math;

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
    constructor Create(const AData: TIntegerDynArray; StartIdx, EndIdx: Integer);
  end;

var
  Data: TIntegerDynArray;
  MaxThread1: TMaxThread = nil;
  MaxThread2: TMaxThread = nil;
  i: Integer;

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
  Writeln('This is "Max3" two thread demonstration application.');
  Writeln('Generating numbers.');
  SetLength(Data, NUMBERS);
  for i := Low(Data) to High(Data) do
    Data[i] := Random(High(Integer));

  Writeln('Searching for max number.');
  MaxThread1 := TMaxThread.Create(Data, 0, High(Data) div 2);
  MaxThread2 := TMaxThread.Create(Data, (High(Data) div 2) + 1, High(Data));
  try
    MaxThread1.Start;
    MaxThread2.Start;
    Writeln('Max number is: ', Max(MaxThread1.WaitFor, MaxThread2.WaitFor));
  finally
    FreeAndNil(MaxThread2);
    FreeAndNil(MaxThread1);
  end;

  {$IFDEF WINDOWS}
  Writeln('Press "Enter" key to close program.');
  Readln;
  {$ENDIF}
end.


