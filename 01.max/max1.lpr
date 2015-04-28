(******************************************************************************
  Max1 - Threads demonstration program.

  Written in 2015 by Dmitriy Pomerantsev pda2@yandex.ru

  To the extent possible under law, the author(s) have dedicated all copyright
  and related and neighboring rights to this software to the public domain
  worldwide. This software is distributed without any warranty.

  You should have received a copy of the CC0 Public Domain Dedication along
  with this software.
  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 ******************************************************************************)
{$MODE OBJFPC}{$H+}
program max1;

uses
  Classes, SysUtils, Types, Math;

const
  NUMBERS = 100 * 1024 *1024 div SizeOf(Integer);

var
  Data: TIntegerDynArray;
  i, Result: Integer;

begin
  Writeln('This is "Max1" sequental demonstration application.');
  Writeln('Generating numbers.');
  SetLength(Data, NUMBERS);
  for i := Low(Data) to High(Data) do
    Data[i] := Random(High(Integer));

  Writeln('Searching for max number.');
  Result := 0;
  for i := Low(Data) to High(Data) do
    Result := Max(Result, Data[i]);

  Writeln('Max number is: ', Result);

  {$IFDEF WINDOWS}
  Writeln('Press "Enter" key to close program.');
  Readln;
  {$ENDIF}
end.

