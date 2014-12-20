
import SimpleOpenNI.*;
import hypermedia.net.*; // import UDP library
import java.net.InetAddress; //biblioteca para obter o IP

/**
 * Codigo de control para programação do Gabinete de Alice
 * 
 * by Toni Oliveira e Javier Cruz.
 */

ControlP5 control;

Controles controles;

InetAddress inet, othernet; // objetos da classe para obter os IPs
String myIP; //armazena o IP
String otherIP; //armazena o outro IP
int udpPort = 6000; //porta de destino da mensagem via udp
UDP udp;  // the UDP object
KinectControl kinectControl;
boolean MousePlay = false;
int tempoBaseclic  ;
int tempoDuploClic = 200;
byte [] dataParaReenviar; //array de bytes que guardan]m a ultima mensagem para se re-enviada como medida de seguranza para que todas as msn chegem no pc
boolean re_envio_dados = false; //boolean que indica quando enviar a info
int tempoPrimeiroEnvio; //tambiem para o reenvi guardamos o tempo em millis do primeiro intento

/** Indicador para reconhecer no PC O tipo de dado enviado no array de bytes */
String [] indicadorDadosEnviados = { 
  "CenarioOn", "cenarioOff", "cenarioPosicao", "dadosContinuos", "dadosFinais"
};

String getIP() { //metodo que retorna o IP
  try {
    inet = InetAddress.getLocalHost();
    myIP = inet.getHostAddress();
  } 
  catch (Exception e) {
    e.printStackTrace();
    myIP = "Nao conseguiu obter IP";
  }
  return myIP;
}

String getOtherIP() { //metodo que retorna o outro IP
  try {
    //othernet = InetAddress.getByName("MacBook-de-Toni-Oliveira.local"); //nome do outro comp na rede
        othernet = InetAddress.getByName("GABINETE-PC.local"); //nome do outro comp na rede

      otherIP = othernet.toString();
    //otherIP = otherIP.substring(31); //exclui "MacBook-de-Toni-Oliveira.local/" do inicio da string
        otherIP = otherIP.substring(18); //exclui "GABINETE-PC.local/" do inicio da string
  } 
  catch (Exception e) {
    e.printStackTrace();
    otherIP = "Nao conseguiu obter o outro IP";
  }
  return otherIP;
}

void setup () {
  myIP = getIP();
  otherIP = getOtherIP();
  udp = new UDP(this, 6100);
  udp.log(true);
  udp.listen(true);
  size (displayWidth, displayHeight); 
  setLocation(0, 0);
  controles = new Controles(this);
  kinectControl = new KinectControl(this);
}

void draw () { 
  background(0);
  // println(myIP); println(otherIP);
  if (controles.estaSeExecutandoSequencia()) {
    // controla o tempo, encendido e apagado de cenários. Pega o valor da kinect para quando estiver no cenario Arvore evaluar se ir ou não para o cenário Toroide
    controles.gerenciadorSequencia( kinectControl.getMovimentacaoFruidor() ); 
  }
  kinectControl.desenhaPlantaDeslocamento();
  stroke(255);
  line (0, height*.5, width, height*.5);
  if (re_envio_dados) {
    if (millis() - tempoPrimeiroEnvio > 10) {
      udp.send( dataParaReenviar, otherIP, udpPort );//envia o nome do cenário para ligar
      re_envio_dados = false;
    }  
  }
}

void enviaLigacaoDeCenarioComTempo(String nomeCenario) {
  String infoDado = "cn"; //indica que se trata de cenario (c) on (n)
  String nome = infoDado + nomeCenario;
  byte[] data = nome.getBytes();
  udp.send( data, otherIP, udpPort );//envia o nome do cenário para ligar

  //String (byte[] bytes) | para converter de volta para string
}

void enviaLigacaoDeCenario(String nomeCenario) {
  String infoDado = "cn"; //indica que se trata de cenario (c) on (n)
  String nome = infoDado + nomeCenario;
  byte[] data = nome.getBytes();
  udp.send( data, otherIP, udpPort );//envia o nome do cenário para ligar

  dataParaReenviar = data; //array de bytes que guardan]m a ultima mensagem para se re-enviada como medida de seguranza para que todas as msn chegem no pc
  re_envio_dados = true;
  tempoPrimeiroEnvio = millis();
  //String (byte[] bytes) | para converter de volta para string
}
/** Envia nome do cenario para desligar com um delay que o PC agrega quando recebe f*/
void enviaApagaCenario(String nomeCenario) {
  String infoDado = "cf"; //indica que se trata de cenario (c) off (f)
  String nome = infoDado + nomeCenario;
  byte[] data = nome.getBytes();
  udp.send( data, otherIP, udpPort );//envia o nome do cenário para ligar

  //String (byte[] bytes) | para converter de volta para string
}

/** Envia nome do cenario para desligar na hora */
void enviaApagaCenarioNaHora(String nomeCenario) {
  String infoDado = "ch"; //indica que se trata de cenario (c) off (f)
  String nome = infoDado + nomeCenario;
  byte[] data = nome.getBytes();
  udp.send( data, otherIP, udpPort );//envia o nome do cenário para ligar

  //String (byte[] bytes) | para converter de volta para string
}

/** Envia dados de posição no modelo e da câmara */
  void envioDadosPosicaoCenario() {
  println("envioDadosPosicaoCenario");
  String infoDado = "px"; //d indica que se trata de dados de posicao do cenario // x preenche a estrutura de dados (sem efeito)
  String dados = infoDado + str(controles.getAngXPuntero()) + "," + str(controles.getAngYPuntero()) + "," + str(controles.getAngZPuntero()) +
                  "," + str(controles.getAngXCamara()) + "," + str(controles.getAngYCamara()) + "," + str(controles.getAngZCamara()) +
                  "," + str(controles.getDistanciaFoco());

  //getVerTelas() entrega um boolean, vamos converter para float antes de enviar 
  if ( controles.getVerTelas() )
    dados = dados + "," + "1.0";
  else
    dados = dados + "," + "0.0";
  if ( controles.getViraKinect() )
    dados = dados + "," + "1.0";
  else
    dados = dados + "," + "0.0";  
    
  byte[] data = dados.getBytes();
  udp.send( data, otherIP, udpPort );
}
/** Envio continuo de dados de interação quando o cenário ativo precise.*/
void envioDadosInteracaoContinua() {
  println("envioDadosInteracaoContinua");
  float valPosicaoFruidor = kinectControl.getPosicaoFruidor();//0.0;
//  println("valPosicaoFruidor: " + valPosicaoFruidor);
  float valMovimentacao = kinectControl.getMovimentacaoFruidor(); //0.0;
  float valDeslocamento = 0.5;
  String infoDado = "dx"; //d indica que se trata de dados continuos // x preenche a estrutura de dados (sem efeito)
  String dados = infoDado + str(valPosicaoFruidor) + "," + str(valMovimentacao) + "," + str(valDeslocamento);
  byte[] data = dados.getBytes();
  udp.send( data, otherIP, udpPort );
}
/** Envio de dados processados de interação no fim do cenário.*/
void enviaDadosInteracaoFinal() {
  udp.send( indicadorDadosEnviados[4], otherIP, udpPort ); //quinta posição: dadosFinais
}

/** Envio nuvem de pontos do usuario lidos pela Kinect */
void enviaNuvemPontosKinect() {
  //envia info so nos cenários que é utilizada
  if (  controles.getNomeCenarioRolando().equals("BigBang") || controles.getNomeCenarioRolando().equals("Arvores") ) {
    println("Enviando nuvem de pontos da kinec no array de byte");
    byte[] data;
    data = kinectControl.getArrayBytesNuvemPontos("kx");
    udp.send( data, otherIP, udpPort );
  }
  
}

////PARA TESTE
void keyPressed() {
  switch (key) {
  case 'p':
    envioDadosPosicaoCenario();
    break;
  case 'd':
    envioDadosInteracaoContinua();
    break;
  case 'k':
    enviaNuvemPontosKinect();
    break;  
  }
}
// -----------------------------------------------------------------

void mousePressed() {
  if (millis() < tempoBaseclic + tempoDuploClic && !controles.estaSeExecutandoSequencia()) {
    controles.PlayFromMouse();    
  }
  tempoBaseclic = millis();
  
/*  if ( !controles.estaSeExecutandoSequencia() && MousePlay) {
    controles.PlayFromMouse();
  }*/
  
}
// -----------------------------------------------------------------
    // SimpleOpenNI events

    void onNewUser(SimpleOpenNI curContext, int userId) {
      println("onNewUser - deviceIndex: " + curContext.deviceIndex() + " , " + "userId: " + userId);
      println("\tstart tracking skeleton");
      curContext.startTrackingSkeleton(userId);
    }
    void onLostUser(SimpleOpenNI curContext, int userId) {
      println("onLostUser - userId: " + userId);
    }
    void onVisibleUser(SimpleOpenNI curContext, int userId) {
      //println("onVisibleUser - userId: " + userId);
    }
    void onOutOfSceneUser(SimpleOpenNI curContext, int userId) {
      println("onOutOfSceneUserUser - userId: " + userId);
    }
