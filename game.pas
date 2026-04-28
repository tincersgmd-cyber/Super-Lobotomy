program Game;

USES
  GraphABC, ABCObjects, Timers;

type
  Level = ARRAY[,] OF SquareABC;
  Blocks = array of SquareABC;

var
  Flag: BOOLEAN;
  level1: Level;
  Player: PictureABC;
  level1Blocks: Blocks;
  OnGround: boolean;
  velocityY: integer;
  gravity: integer;
  jumpForce: integer;
  speed: integer;

procedure CheckCollision();
begin
  OnGround := false;
  
  foreach var x in level1Blocks do
  begin
    if (Player.Intersect(x)) AND (velocityY > 0)
    then
    begin
      Player.Top := x.Top - Player.Height;
      velocityY := 0;
      OnGround := true;
      gravity := 0;
      speed := 5;
    end;
    
    if (x.Top - Player.Top - Player.Height < 2) and not ((Player.Left + Player.Width < x.Left) or (Player.Left > x.Left + x.Width)) and not (Player.Top >= x.Top + x.Height)
    then
    begin
      OnGround := true;
      gravity := 0;
    end; 
    
    if (velocityY < 0) and (Player.Intersect(x)) and (x.Top + x.Height - Player.Top > -x.Height DIV 2)
    then
    begin
      Player.Top := x.Top + x.Height;
      velocityY := 0;
      jumpForce := 0;
      OnGround := false;
      gravity := 1;
    end;
    
    if((Player.Left + Player.Width < x.Left) or (Player.Left > x.Left + x.Width)) and (OnGround = FALSE)
    then
      gravity := 1;
  end;
end;


procedure GameTick();
begin
  velocityY += gravity;
  player.Top += velocityY;
  CheckCollision();
end;

procedure PlayerJump();
begin
  if OnGround
  then
  begin
    velocityY := jumpForce;
    OnGround := false;
    jumpForce := -20;
    gravity := 1;
    speed := 20;
  end;
end;

procedure PlayerController(key: INTEGER);
begin
  case key OF
    VK_D: Player.Left += speed;
    VK_A: Player.Left -= speed;
    VK_SPACE: PlayerJump;
  end;
end;

procedure GameStart();
begin
  level1 := new SquareABC[100, 27];
  level1Blocks := new SquareABC[1024];
  var i := 0;
  for VAR Row := 0 TO 47
  DO
  begin
    for VAR Col := 24 TO 25
    DO
    begin
      level1Blocks[i] := level1[Row, Col];
      level1Blocks[i] := new SquareABC(40 * Row, 40 * Col, 40, clBlack);
      level1Blocks[i].BorderWidth := 2;
      level1Blocks[i].BorderColor := clWhite;
      i += 1;
    end;
  end;
  for VAR Row := 2 TO 45
  DO
  begin
    var Col := 20;
    level1Blocks[i] := level1[Row, Col];
    level1Blocks[i] := new SquareABC(40 * Row, 40 * Col, 40, clBlack);
    level1Blocks[i].BorderWidth := 2;
    level1Blocks[i].BorderColor := clWhite;
    i += 1;
  end;
  Player := new PictureABC(0, WindowHeight - 100, 'images\player.png');
  OnKeyDown := PlayerController;
  speed := 5;
  gravity := 1;
  jumpForce := -20;
  var GameTimer := new Timer(5, GameTick);
  GameTimer.Start();
end;

procedure BackgroundChange();
begin
  var Counter := 1;
  while TRUE
  DO
  begin
    case Counter OF
      1: Window.Fill('images\StartBackground.png');
      -1: Window.Fill('images\StartBackground2.png');
    end;
    Counter *= -1;
    SLEEP(500);
    if FLAG
      THEN
      BREAK;
  end;
end;

procedure KeyDown(Key: INTEGER);
begin
  case KEY OF
    VK_F4:
      begin
        SLEEP(100);
        Window.Close();
      end;
    VK_F7:
      begin
        Flag := TRUE;
        Window.Load('images\FinalBackground.png');
      end;
    VK_ENTER:
      begin
        OnKeyDown := nil;
        Flag := TRUE;
        Window.Clear(RGB(0, 162, 232));
        GameStart();
      end;
  end;
end;

begin
  Window.Maximize();
  OnKeyDown := KeyDown;
  BackgroundChange();
  
end.