PROGRAM Game;

USES
  GraphABC, ABCObjects, Timers;
TYPE
  Level = ARRAY[,] OF SquareABC;
VAR
  Flag: BOOLEAN;
  level1: Level;
  Player: PictureABC;
  OnGround: boolean;
  velocityY: integer;
  gravity: integer;
  jumpForce: integer;
  speed: integer;
  
procedure CheckCollision();
begin
  OnGround := false;
  
  for var I := 0 to 47
  do
    begin
      for var j := 24 to 25
      do
      begin
        
        if (Player.Intersect(Level1[I,j])) AND (velocityY > 0)
        then
          begin
            Player.Top := Level1[I,j].Top - Player.Height;
            velocityY := 0;
            OnGround := true;
            gravity := 0;
          end;
          
        if (level1[I,j].Top - Player.Top - Player.Height < 2)
        then
          OnGround := true;
      end;
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
      gravity := 1;
    end;
end;
  
PROCEDURE PlayerController(key: INTEGER);
BEGIN
  CASE key OF
    VK_D: Player.Left += speed;
    VK_A: Player.Left -= speed;
    VK_SPACE: PlayerJump;
  end;
end;
  
PROCEDURE GameStart();
BEGIN
  level1 := new SquareABC[100, 27];
  FOR VAR Row := 0 TO 47
  DO
    BEGIN
      FOR VAR Col := 24 TO 25
      DO
        BEGIN
          level1[Row,Col] := new SquareABC(40 * Row, 40 * Col, 40, clBlack);
          level1[Row,Col].BorderWidth := 2;
          level1[Row,Col].BorderColor := clWhite;
        end;
    END;
  Player := new PictureABC(0, WindowHeight-100, 'images\player.png');
  OnKeyDown := PlayerController;
  speed := 5;
  gravity := 1;
  jumpForce := -20;
  var GameTimer := new Timer(5, GameTick);
  GameTimer.Start();
END;  
  
PROCEDURE BackgroundChange();
BEGIN
  VAR Counter := 1;
  WHILE TRUE
  DO
  begin
    CASE Counter OF
      1: Window.Fill('images\StartBackground.png');
      -1: Window.Fill('images\StartBackground2.png');
    end;
    Counter *= -1;
    SLEEP(500);
    IF FLAG
    THEN
      BREAK;
  end;
END;

PROCEDURE KeyDown(Key: INTEGER);
BEGIN
  CASE KEY OF
    VK_F4: BEGIN
      SLEEP(100);
      Window.Close();
    end;
    VK_F7: BEGIN
      Flag := TRUE;
      Window.Load('images\FinalBackground.png');
    END;
    VK_ENTER: BEGIN
      OnKeyDown := nil;
      Flag := TRUE;
      Window.Clear(RGB(0, 162, 232));
      GameStart();
    END;
  end;
END;
BEGIN
  Window.Maximize();
  OnKeyDown := KeyDown;
  BackgroundChange();
  
end.