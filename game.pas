PROGRAM Game;
{$reference 'PresentationCore.dll'}
USES
  GraphABC, ABCObjects, Timers, System.Windows.Media, System.IO;

CONST
  Standart_Direction = -1;

TYPE
  Level = ARRAY[,] OF SquareABC;
  Blocks = ARRAY OF SquareABC;
  Enemy = CLASS
  PRIVATE
    fp: PictureABC;
    fx, fy: integer;
    fMovePointL, fMovePointR: integer;
    fdirection: shortint;
    pfname: string;
    
    PROCEDURE setX(x: integer);
    BEGIN
      fp.MoveTo(x, fy);
      fx := x;
    END;
    
    FUNCTION getX: integer;
    BEGIN
      Result := fx;
    END;
    
    FUNCTION getDirection: shortint;
    BEGIN
      Result := fdirection;
    END;
    
    PROCEDURE setDirection(value: shortint);
    BEGIN
      fdirection := value;
    END;
    
    function getMovePointL: integer;
    begin
      Result := fMovePointL;
    end;
    
    function getMovePointR: integer;
    begin
      Result := fMovePointR;
    end;
    
    function getCollider: PictureABC;
    begin
      Result := fp;
    end;
  
  public
    constructor Create(x, y, MovePointL, MovePointR: integer; fname: string);
    begin
      fx := x;
      fy := y;
      fp := new PictureABC(fx, fy, fname);
      fp.Transparent := False;
      fMovePointL := MovePointL;
      fMovePointR := MovePointR;
      fdirection := Standart_Direction;
      pfname := fname;
    end;
    
    destructor Destroy();
    begin
      fx := 0;
      fy := 0;
      fp.Destroy();
      fMovePointL := 0;
      fMovePointR := 0;
      fdirection := 0;
    end;
    
    property x: integer read getX write setX;
    property y: integer read fy;
    property MovePointL: integer read getMovePointR;
    property MovePointR: integer read getMovePointL;
    property direction: shortint read getDirection write setDirection;
    property collider: PictureABC read getCollider;
  end;
  Enemies = array of Enemy;

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
  EnemySpeed: integer;
  level1Enemies: Enemies;
  level1Enemy: Enemy;
  DebugText: TextABC;
  PlayerDirection: Shortint;
  GameTimer: Timer;
  score: word;
  highscore: Text;
  scoreText: TextABC;
  

procedure CheckCollision(t: TIMER);
begin
  OnGround := false;
  if Player.Top > windowheight
    then
    Player.Top := 0;
  
  if Player.Left < 0
  then
    begin
    Player.MoveTo(0, Player.Top);
    PlayerDirection *= -1;
  end;
  
  if Player.Left + Player.Width > WindowWidth
  then
    begin
    Player.MoveTo(WindowWidth - Player.Width, Player.Top);  
    PlayerDirection *= -1;
  end;
  
  if (Player.Intersect(level1Enemy.collider)) AND (velocityY <> 0)
  then
    begin
      level1Enemy.Destroy;
      score += 100;
      sleep(100);
      t.Stop;
      VAR hScore: INTEGER;
      assign(highscore,'Player_Data\Player__highscore.txt');
      Reset(highscore);
      Read(highscore, hScore);
      Close(highscore);
      assign(highscore,'Player_Data\Player__highscore.txt');
      REWRITE(highscore);
      IF score > hScore
      THEN
        begin
          WRITE(highscore, score);
          hScore := score;
        end; 
      CLOSE(highscore);
      Window.Load('images\FinalBackground.png');
      VAR EndText := new TextABC(WindowWidth DIV 2, WindowHeight DIV 2, 72, $'You Win! highscore: {hScore}', clGreen);
      EndText.MoveTo(WindowWidth DIV 2 - EndText.Width DIV 2, WindowHeight DIV 2 - EndText.Height DIV 2);
      EndText.TransparentBackground := TRUE;
      VAR txt := new TextABC(WindowWidth DIV 3, WindowHeight DIV 2 + 200, 32, 'leave to restart', clGreen);
      txt.TransparentBackground := TRUE;
    end;
  
  if (Player.Intersect(level1Enemy.collider)) AND (velocityY = 0)
  then
    begin
      t.Stop;
      assign(highscore,'Player_Data\Player__highscore.txt');
      RESET(highscore);
      READLN(highscore,score);
      CLOSE(highscore);
      ClearWindow(clBlack);
      VAR EndText := new TextABC(WindowWidth DIV 2, WindowHeight DIV 2, 72, $'YOU DIED {Chr(10)} highscore: {score}', clRed);
      EndText.MoveTo(WindowWidth DIV 2 - EndText.Width DIV 2, WindowHeight DIV 2 - EndText.Height DIV 2);
      EndText.TransparentBackground := TRUE;
      VAR txt := new TextABC(WindowWidth DIV 3, WindowHeight DIV 2 + 200, 32, 'leave to restart', clRed);
      txt.TransparentBackground := TRUE;
    end;
  
  foreach var x in level1Blocks do
  begin
    if (Player.Intersect(x)) AND (velocityY > 0)
    then
    begin
      Player.Top := x.Top - Player.Height;
      velocityY := 0;
      OnGround := true;
      gravity := 0;
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
  Player.Left += speed * PlayerDirection;
  //DebugText.Text := level1Enemy.x.ToString;
  level1Enemy.x += EnemySpeed * level1Enemy.direction;
  if(level1Enemy.x >= level1Enemy.MovePointL) OR (level1Enemy.x <= level1Enemy.MovePointR)
  then
    level1Enemy.direction *= -1;
  score += 1;
  scoreText.Text := $'Score: {score}';
  CheckCollision(GameTimer);
end;

procedure PlayerJump();
begin
  if OnGround
  then
  begin
    jumpForce := -20;
    velocityY := jumpForce;
    OnGround := false;
    gravity := 1;
  end;
end;

procedure PlayerController(key: INTEGER);
begin
  case key OF
    VK_D: PlayerDirection := 1;
    VK_A: PlayerDirection := -1;
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
  //level1Enemies := new Enemy[3];
  level1Enemy := new Enemy(40 * 20, 40 * 19, 40 * 10, 40 * 25, 'images\enemy.png');
  //level1Enemies[1] := new Enemy(40 * 17, 40*19, 40*14, 40*19, 'images\enemy.png');
  //level1Enemies[2] := new Enemy(40 * 25, 40*19, 40*22, 40*27, 'images\enemy.png');
  EnemySpeed := 2;
  PlayerDirection := 1;
  score := 0;
  //DebugText := new TextABC(0,120,32,level1Enemy.x.ToString,clBlack);
  GameTimer := new Timer(10, GameTick);
  GameTimer.Start();
  scoreText:= new TextABC(20,120, 40,$'Score: {score}', clWhite);
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

PROCEDURE KeyDown(Key: INTEGER);
BEGIN
  
  CASE KEY OF
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
      END;
    VK_Tab:
      begin
        OnKeyDown := nil;
        Flag := TRUE;
        SetWindowCaption('FireInTheHole.exe');
        Window.Load('images\FireInTheHole.exe.png');
        VAR sound := new MediaPlayer;
        sound.Open(new System.Uri(Directory.GetCurrentDirectory + '\sounds\IAMGOD.mp3', System.UriKind.Absolute));
        sound.Play();
      end;
  END;
END;

PROCEDURE GameEnd;
BEGIN
  OnKeyDown := nil;
  GameTimer.Stop();
  Level1Enemy.Destroy;
  Player.Destroy;
  foreach var x in level1Blocks
    do
    x.destroy;
  Flag := TRUE;
  OnKeyDown := KeyDown;
  BackgroundChange();
END;

BEGIN
  SetWindowSize(1920, 1080);
  Window.CenterOnScreen;
  SetWindowCaption('Super Lobotomy');
  OnKeyDown := KeyDown;
  BackgroundChange();
END.