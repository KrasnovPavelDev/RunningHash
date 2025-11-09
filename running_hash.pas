{ In this program, the # symbol runs along
  the border of a square drawn in the center
  
  ESC to exit the program
  SPACE to change the direction of #
  -> to increase the delay
  <- to decrease the delay }
program RunningHash;
uses crt;
const
	MaxHashIndex = 35;
	MinWindowSize = 12;
	SquareSize = 10;
type
	coords = record
		x, y: integer;
	end;
	Sides = (right, left);

procedure GetKey(var code: integer);
var
	c: char;
begin
	c := ReadKey;
	if c = #0 then
	begin
		c := ReadKey;
		code := -ord(c)
	end
	else
	begin
		code := ord(c)
	end
end;

{ This procedure fills an array that stores the
  coordinates of each point of the square }
procedure SquareCoords(var SqCoords: array of coords; SqSize: integer);
var
	i: integer;
begin
	{ We find the top-left corner of the square }
	SqCoords[0].x := (ScreenWidth div 2) - (SqSize div 2);
	SqCoords[0].y := (ScreenHeight div 2) - (SqSize div 2);
	for i := 1 to SqSize*SqSize-1 do
	begin
		{ We fill the coordinates array row by row: every
		10 elements a new row begins, which means we need
		to increase Y and reset X to its initial position }
		if i mod 10 = 0 then
		begin
			SqCoords[i].x := SqCoords[0].x;
			SqCoords[i].y := SqCoords[i-1].y + 1
		end
		else
		begin
			SqCoords[i].x := SqCoords[i-1].x + 1;
			SqCoords[i].y := SqCoords[i-1].y
		end
	end
end;

{ This procedure draws a square using the coordinates }
procedure DrawSquare(SqCoords: array of coords; SqSize: integer);
var
	i: integer;
begin
	for i := 0 to SqSize*SqSize-1 do
	begin
		GotoXY(SqCoords[i].x, SqCoords[i].y);
		write('*')
	end;
	GotoXY(1, 1)
end;

{ This procedure calculates the coordinates along
  which the # will move}
procedure HashCoords(var HsCoords: array of integer);
var
	i, r, l: integer;
begin
	{ We calculate the indices of the top and bottom rows.
	There are 18 indices between each bottom and each top
	index. The top indices range from 0 to 9, the bottom
	indices from 99 to 90 }
	for i := 0 to 9 do
	begin
		HsCoords[i] := i;
		HsCoords[i+18] := 99 - i
	end;
	{We calculate the indices of the right and left columns.
	There are 18 indices between each right and left index.
	The left indices range from 80 to 10, the right indices
	from 19 to 89}
	r := 19;
	l := 80;
	for i := 10 to 17 do
	begin
		HsCoords[i] := r;
		HsCoords[i+18] := l;
		r := r + 10;
		l := l - 10
	end;
	for i := 0 to 35 do
		writeln(i, ' ', HsCoords[i])
end;

{ This procedure draws the # at the required coordinate }
procedure DrawHash(var HsCoords: array of integer;
					var SqCoords: array of coords; index: integer);
begin
	GotoXY(SqCoords[HsCoords[index]].x, SqCoords[HsCoords[index]].y);
	write('#');
	GotoXY(1, 1)
end;

{ This procedure is responsible for moving the # }
procedure MoveHash(HsCoords: array of integer; SqCoords: array of coords;
					var index: integer; var direction: Sides;
					MaxHashIndex: integer);
begin
	DrawHash(HsCoords, SqCoords, index);
	if direction = right then
	begin
		index := index + 1;
		if index > MaxHashIndex then
			index := 0
	end
	else
	begin
		index := index - 1;
		if index < 0 then
			index := MaxHashIndex
	end
end;

procedure ChangeDirection(var direction: Sides);
begin
	if direction = right then
		direction := left
	else
		direction := right
end;

procedure UpDelay(var DelayD: integer);
var
	delayMax, delayStep: integer;
begin
	delayMax := 500;
	delayStep := 50;
	DelayD := DelayD + delayStep;
	if DelayD > delayMax then
		DelayD := delayMax;
end;

procedure DownDelay(var DelayD: integer);
var
	delayMin, delayStep: integer;
begin
	delayMin := 50;
	delayStep := 50;
	DelayD := DelayD - delayStep;
	if DelayD < delayMin then
		DelayD := delayMin
end;

procedure CheckWindow(size: integer);
begin
	if (ScreenHeight < size) or (ScreenWidth < size) then
	begin
		writeln('The window size is too small');
		halt(1)
	end
end;

var
	coordinates: array [0..99] of coords;
	indexes: array [0..35] of integer;
	c, HsIndex, DelayDuration: integer;
	direction: Sides;
begin
	CheckWindow(MinWindowSize);
	DelayDuration := 100;  { Default delay value }
	direction := right;
	HsIndex := 0;
	SquareCoords(coordinates, SquareSize);
	HashCoords(indexes);
	clrscr;
	while true do
	begin
		if not KeyPressed then
		begin
			DrawSquare(coordinates, SquareSize);
			MoveHash(indexes, coordinates, HsIndex, direction, MaxHashIndex);
			delay(DelayDuration);
			continue
		end;
		GetKey(c);
		case c of
			-77: UpDelay(DelayDuration);
			-75: DownDelay(DelayDuration);
			32: ChangeDirection(direction);
			27: break
		end
	end;
	clrscr
end.
