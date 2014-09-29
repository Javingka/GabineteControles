
/**
 * Codigo de control para programação do Gabinete de Alice
 * 
 * by Toni Oliveira e Javier Cruz.
 */
ControlP5 control;

Controles controles;

void setup () {
  size (displayWidth, displayHeight/2); 
  setLocation(0, 0);
  controles = new Controles(this);
}

void draw () { 
  background(0);
  
}

