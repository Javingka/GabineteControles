
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
  
}

void enviaLigacaoDeCenario(String nomeCenario){
  udp.send( indicadorDadosEnviados[0] ); //posição primeira: CenarioOn
  
  String nome = nomeCenario;
  byte[] data = nome.getBytes();
  udp.send( data );//envia o nome do cenário para ligar
  
  //String (byte[] bytes) | para converter de volta para string
}
void enviaApagaCenario(String nomeCenario){
  udp.send( indicadorDadosEnviados[1] ); //segunda posição: cenarioOff
  
  String nome = nomeCenario;
  byte[] data = nome.getBytes();
  udp.send( data );//envia o nome do cenário para ligar
  
  //String (byte[] bytes) | para converter de volta para string
}
/** Envia dados de posição no modelo e da câmara */
void envioDadosPosicaoCenario(){
  udp.send( indicadorDadosEnviados[2] ); //terceira posição: cenarioPosicao
  
  byte[] data = new byte[8];  // os dados a serem enviados
  data[0] = byte ( controles.getAngXPuntero() );
  data[1] = byte (  controles.getAngYPuntero() );
  data[2] = byte (  controles.getAngZPuntero() );
  data[3] = byte (  controles.getAngXCamara() );
  data[4] = byte (  controles.getAngYCamara() );
  data[5] = byte (  controles.getAngZCamara() );
  data[6] = byte (  controles.getDistanciaFoco() );
  
  //getVerTelas() entrega um boolean, vamos converter para float antes de enviar 
  if ( controles.getVerTelas() )
    data[7] = byte ( 1.0 );
  else
    data[7] = byte ( 0.0 );  
    
  udp.send( data );   
}
/** Envio continuo de dados de interação quando o cenário ativo precise.*/
void envioDadosInteracaoContinua(){
  udp.send( indicadorDadosEnviados[3] ); //quarta posição: dadosContinuos
  
   float valPosicaoFruidor = 0;
   float valMovimentacao = 0;
   float valDeslocamento = 0;
   
   byte[] data = new byte[3];  // os dados a serem enviados
   
   data[0] = byte ( valPosicaoFruidor );
   data[1] = byte ( valMovimentacao );
   data[2] = byte ( valDeslocamento );
   
   udp.send( data );   
}
/** Envio de dados processados de interação no fim do cenário.*/
void enviaDadosInteracaoFinal() {
  udp.send( indicadorDadosEnviados[4] ); //quinta posição: dadosFinais
  
  
}
