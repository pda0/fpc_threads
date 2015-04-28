(******************************************************************************
  Max2 - Threads demonstration program.

  Written in 2015 by Dmitriy Pomerantsev pda2@yandex.ru

  To the extent possible under law, the author(s) have dedicated all copyright
  and related and neighboring rights to this software to the public domain
  worldwide. This software is distributed without any warranty.

  You should have received a copy of the CC0 Public Domain Dedication along
  with this software.
  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 ******************************************************************************)
{$MODE OBJFPC}{$H+}
program max2;

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, Types, Math;

const
  NUMBERS = 100 * 1024 *1024 div SizeOf(Integer);

type
  TMaxThread = class(TThread)
  protected
    procedure Execute; override;
  end;

var
  Data: TIntegerDynArray;
  MaxThread: TMaxThread = nil;
  i: Integer;

{ TMaxThread }

procedure TMaxThread.Execute;
var
  i: Integer;
begin
  for i := Low(Data) to High(Data) do
    ReturnValue := Max(ReturnValue, Data[i]);
end;

begin
  Writeln('This is "Max2" one thread demonstration application.');
  Writeln('Generating numbers.');
  SetLength(Data, NUMBERS);
  for i := Low(Data) to High(Data) do
    Data[i] := Random(High(Integer));

  Writeln('Searching for max number.');
  MaxThread := TMaxThread.Create(False);
  try
    Writeln('Max number is: ', MaxThread.WaitFor);
  finally
    FreeAndNil(MaxThread);
  end;

  {$IFDEF WINDOWS}
  Writeln('Press "Enter" key to close program.');
  Readln;
  {$ENDIF}
end.

