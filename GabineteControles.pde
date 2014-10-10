
/**
 * Codigo de control para programação do Gabinete de Alice
 * 
 * by Toni Oliveira e Javier Cruz.
 */
 
import hypermedia.net.*; // import UDP library
ControlP5 control;

Controles controles;
UDP udp;  // the UDP object

/** Indicador para reconhecer no PC O tipo de dado enviado no array de bytes */
String [] indicadorDadosEnviados = { "CenarioOn", "cenarioOff", "cenarioPosicao", "dadosContinuos", "dadosFinais" };

void setup () {
  size (displayWidth, displayHeight/2); 
  setLocation(0, 0);
  controles = new Controles(this);
}

void draw () { 
  background(0);
  if (controles.estaSeExecutandoSequencia()) { 
		controles.gerenciadorSequencia();
	}
}
