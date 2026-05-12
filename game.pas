uses
  GraphABC,ABCObjects,GameMechanics;  
begin
  Window.Maximize();
  OnKeyDown := KeyDown;
  BackgroundChange();
end.