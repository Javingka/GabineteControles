import controlP5.*; 
import java.awt.Frame; 
import java.awt.event.KeyEvent; 
import java.text.*; 

class Controles  implements ControlListener { 
  //Variaveis ajustaveis 
  int indexCamara; //variavel sem utilzar, para exluir tem que mudar alguns métodos 
  //  float ang_X_Puntero, ang_Y_Puntero, ang_Z_Puntero; //  
  float ang_X_Camara, ang_Y_Camara, ang_Z_Camara; 
  float zoom; //zoom da visualizacao previa 
  boolean event = false; //boolean para souber cada novo evento nos controles 
  boolean preview = false; //Liga o control com as projeções 
  boolean viewScreens = false; //para visualizar os limites da tela de cada projetor 
  boolean camara_In; //Se a visualizacao esta em estado de 3ra pessoa ou 1era 
  boolean cenariosCarregados;
  boolean anteriorPreview; //boolean para evaluar los cambios entre ocultar e mostrar janela
  boolean PLAY, switchCenarioSeq; 
  int indiceSequencia; //O indice que define o track com o respetivo cenário que é reproducido segundo a divição do tempo 
  int limiteTempoCenarioSeq; //almacenará os límite  de tempo para cada cenário reproducido na sequencia 
  int NinteracaoNoFinalCenario; //para o cenário Toroide, ele só será ligado se tem interação no cenário previo (Arvores)

  String Xp, Yp, Zp, Xc, Yc, Zc; //nomes dos TextField dos angulos do puntero e da camara
  int numeroCenarios;
  String [] listaSeqCenarios; //lista que tem o ordem que os cenários serão exhibidos
  int [] listaTemposSeqCenarios; //array com o tempo em segundos de funcionamento por track. 
  int [] listaTemposSeqCenariosInicial; //array com o tempo em segundos de funcionamento por track que vai desde o inicio
  String [] listaNomeCenarios; //uma lista com os nomes dos cenarios existentes
  PVector [] posicoesCenarios; //Posições dos cenarios, o pvector contém os angulos da posição no modelo
  PMatrix3D [] matrixCenarios; //contém as matrices de giro. basicamente os mesmos angulos do PVector, mas aplicados numa matriz

  ControlTimer timerSequenca;
  String tempoEmTexto;

  PApplet2 PApplet_preview3D;
  PFrame2 frame2;
  PApplet p5;

  /** ==========================================	Construtor da classe ================================================ */
  Controles(PApplet p5) {
    this.p5 = p5;
    frame2 = new PFrame2(); 

    numeroCenarios = 7;
    control = new ControlP5(this.p5);
    control.addListener(this);
    listaSeqCenarios = new String [numeroCenarios];	
    listaTemposSeqCenarios = new int [numeroCenarios];
    listaTemposSeqCenariosInicial = new int [numeroCenarios];
    listaNomeCenarios = new String [numeroCenarios];
    posicoesCenarios = new PVector[numeroCenarios];
    matrixCenarios = new PMatrix3D[numeroCenarios];

/*   LISTA PREDEFINIDA DE CENARIOS*/
    listaSeqCenarios[0] = "Rodape_1";
    listaTemposSeqCenariosInicial[0] = 62; 
    listaSeqCenarios[1] = "BigBang";
    listaTemposSeqCenariosInicial[1] = 52; 
    listaSeqCenarios[2] = "Nuvem";
    listaTemposSeqCenariosInicial[2] = 62; 
    listaSeqCenarios[3] = "Borboleta";
    listaTemposSeqCenariosInicial[3] = 57;
    listaSeqCenarios[4] = "Arvores";
    listaTemposSeqCenariosInicial[4] = 54; 
    listaSeqCenarios[5] = "Final";
    listaTemposSeqCenariosInicial[5] = 88; 
    listaSeqCenarios[6] = null;
    listaTemposSeqCenariosInicial[6] = 0;
    
    makePreviewControls();
    criaCenarios(); //Quando não tiver comunicação com o PC cria valores dos cenários
    carregaCenarios();
    PLAY = false;
    
    //ativa ese o inicio a preview 3d
    control.get(Toggle.class, "preview" ).setState(true);
    trocaToggleText ("preview", "        preview On", "        preview Off", true  );
    println("Fim construtor classe Controles");
  }

  /** Criação dos cenarios, é usando quanto o programa não tem conxão com o programa de visualização no outro computador */
  public void criaCenarios() {

    listaNomeCenarios[0] = "Borboleta";
    posicoesCenarios[0] = new PVector(PI*.5, 0, 0);
    listaNomeCenarios[1] = "Arvores";
    posicoesCenarios[1] = new PVector(0, PI*1.5, PI*.5);
    listaNomeCenarios[2] = "Toroide";
    posicoesCenarios[2] = new PVector(PI, 0, 0);
    listaNomeCenarios[3] = "Nuvem";
    posicoesCenarios[3] = new PVector(0, 0, PI*.5);
    listaNomeCenarios[4] = "Final";
    posicoesCenarios[4] = new PVector(0, 0, PI*1.5  );
    listaNomeCenarios[5] = "Rodape_1";
    posicoesCenarios[5] = new PVector(-PI*.1, 0, 0);
    listaNomeCenarios[6] = "BigBang";
    posicoesCenarios[6] = new PVector(PI*.05, 0, 0);
    
    for (int i=0; i<numeroCenarios; i++) {
      matrixCenarios[i] = criaMatrixFromAngulos(posicoesCenarios[i]); //criação das matrices
    }
  }

  /** Metodo para criar matrices 3d com os dados de angulos */
  public PMatrix3D criaMatrixFromAngulos(PVector ang) {
    PMatrix3D cenarioM = new PMatrix3D();
    cenarioM.reset();
    cenarioM.rotateY(ang.y);
    cenarioM.rotateX(ang.x);
    cenarioM.rotateZ(ang.z);
    return cenarioM;
  }

  /** Carrega cenarios com a informação do nome, angulos de posição, a matrix de giro e quantidade de cenários no modelo Preview 
   também define os controles de controlp5 para o sistema de reprodução de cenários em estado de EXHIBIÇÃO*/
  public void carregaCenarios() { 
    int cenariosTotal = numeroCenarios;
    println("quantidade de cenários a carregar: " + cenariosTotal);

    int y = (int) (height *.025); //posiçãp inicial de Y para colocar os controles
    int x = (int) (width * .55);
    //Objetos de texto controlP5
    control.addTextlabel("labelListaCenarios").setText("LISTA DOS CENARIOS EXISTENTES").setPosition(x, y).setColorValue(0xffffffff);
    control.addTextlabel("labelCenario").setText("ver no modelo                  ir a posicao").setPosition(x+2, y += 11).setColorValue(0xffffffff); 

    /**CRIAÇÃO dos cenários no objeto 'PApplet_preview3D'
     			 CRIAÇÃO dos controles: Toogle: para ver/ocultar o cenario no modelo e | Bang: para levar o pontero do modelo a posição do cenário*/
    for (int i = 0; i < cenariosTotal; i++ ) {
      //Pega os valores dos cenarios
      PMatrix3D matrixTem = matrixCenarios[i];
      String nomeTem = listaNomeCenarios[i];
      PVector angs = posicoesCenarios[i];
      //Coloca os cenarios dentro do modelo Preview no PApplet2
      PApplet_preview3D.agregaUmCenario(matrixTem, nomeTem, angs);
      //Criação dos objetos de control
      String ativador = "ver" + nomeTem; //nome do botao
      control.addToggle(nomeTem, false, x, y += 15, 9, 9).setLabel(nomeTem).getCaptionLabel().align(LEFT, CENTER).style().marginLeft = 15; //move to the right;//align(22, -5);
      control.addBang(ativador).setPosition(x + 120, y).setSize(10, 10).setColorForeground(color(255, 0, 255)).setLabelVisible(false);
    } 

    cenariosCarregados = true; //o variavel vira true para indicar que os cenarios já foram carregados
    println("Processo de carrega de cenarios finalizado");
    criaControlesReproducao(cenariosTotal);
  }

  /** CRIAÇÃO dos objetos de control que definen parámetros da posição e visualização dos cenários no modelo*/
  void makePreviewControls() {
    int yt = 25;

    control.addTextlabel("label_controlangulos").setText("CONTROL PARA POSICAO DO PONTO CENTRAL DA IMAGEM E DA CAMARA").setPosition(180, yt-15).setColorValue(0xffffffff);
    //Controles de texto para ingresar o numero de angulo de posição do centro da imagem enfocada pela câmara
    control.addTextfield("Xp", 150, yt, 30, 9).plugTo(this).align(0, 0, 10, 5);//this is where you type the words
    control.addTextfield("Yp", 150, yt += 10, 30, 9).plugTo(this).align(0, 0, 10, 5);//this is where you type the words
    control.addTextfield("Zp", 150, yt += 10, 30, 9).plugTo(this).align(0, 0, 10, 5);//this is where you type the words
    control.addTextfield("Xc", 150, yt += 10, 30, 9).plugTo(this).align(0, 0, 10, 5);
    control.addTextfield("Yc", 150, yt += 10, 30, 9).plugTo(this).align(0, 0, 10, 5);
    control.addTextfield("Zc", 150, yt += 10, 30, 9).plugTo(this).align(0, 0, 10, 5);

    //Controles sliders para ingresar o angulo de posição do centro da imagem enfocada pela câmara
    int y = 25;
    control.addSlider("ang_X_Puntero", .0, TWO_PI*1.1, .0, 200, y, 500, 9).plugTo(this).setLabel("Giro puntero X").setColorForeground(color(255, 200, 120));//.getCaptionLabel().toUpperCase(true).align(230,0);
    control.addSlider("ang_Y_Puntero", .0, TWO_PI*1.1, .0, 200, y += 10, 500, 9).plugTo(this).setLabel("Giro puntero Y").setColorForeground(color(255, 200, 120));
    control.addSlider("ang_Z_Puntero", .0, TWO_PI*1.1, .0, 200, y += 10, 500, 9).plugTo(this).setLabel("Giro puntero Z").setColorForeground(color(255, 200, 120));
    control.addSlider("ang_X_Camara", .0, TWO_PI*1.1, .0, 200, y += 10, 500, 9).plugTo(this).setLabel("Giro camara X").setColorForeground(color(0, 255, 0));
    control.addSlider("ang_Y_Camara", .0, TWO_PI*1.1, .0, 200, y += 10, 500, 9).plugTo(this).setLabel("Giro camara Y").setColorForeground(color(0, 255, 0));
    control.addSlider("ang_Z_Camara", .0, TWO_PI*1.1, .0, 200, y += 10, 500, 9).plugTo(this).setLabel("Giro camara Z").setColorForeground(color(0, 255, 0));

    //control da distancia emte o ponto centro da imagem e a câmara
    control.addSlider("zoom", .0, 1.0, .5, 175, y += 10, 500, 9).plugTo(this).plugTo(this).setColorForeground(color(0, 0, 255));

    //controles para ligar controles com preview / definir a visualização no preview como 1era ou 3era pessoa / visualizar os límites de projeção de cada projetor
    control.addToggle("preview", false, 10, y = 25, 10, 9)      .plugTo(this).plugTo(this).setLabel("        preview Off")  .setMode(ControlP5.SWITCH).getCaptionLabel().align(LEFT, CENTER);
    control.addToggle("camara_In", false, 10, y += 11, 10, 9)   .plugTo(this).plugTo(this).setLabel("        camara 3ra").setMode(ControlP5.SWITCH).getCaptionLabel().align(LEFT, CENTER);
    control.addToggle("viewScreens", false, 10, y += 11, 10, 9) .plugTo(this).plugTo(this).setLabel("        ver telas").setMode(ControlP5.SWITCH).getCaptionLabel().align(LEFT, CENTER);

    //zoom in e out da visualização em 3era pessoa do preview
    control.addBang("zoom_in").setPosition(10, y += 11) .setSize(10, 10).plugTo(this).setColorForeground(color(255, 0, 255)).setLabel("      zoom preview in").getCaptionLabel().align(LEFT, CENTER);
    control.addBang("zoom_out").setPosition(10, y += 11).setSize(10, 10).plugTo(this).setColorForeground(color(255, 0, 255)).setLabel("      zoom preview out").getCaptionLabel().align(LEFT, CENTER);
    control.addToggle("voltea_KINECT", false, 10, y += 11, 10, 9) .plugTo(this).plugTo(this).setLabel("        KINECT VIRA").setMode(ControlP5.SWITCH).getCaptionLabel().align(LEFT, CENTER);

  }

  /** CRIAÇÃO dos controles da sequencia de tempo para a reprodução dos cenários */
  void criaControlesReproducao(int cenariosTotal) {
    println("Começa criação de controles para reprodução da experiência");
    timerSequenca = new ControlTimer(); //cria um objeto de control de tempo, o objeto fica contando desde o momento que é criado, quando é usado é seteado para voltar a 0
    timerSequenca.setSpeedOfTime(1); //velocidade do contador
    timerSequenca.reset(); //tempo é seteado em 0
    tempoEmTexto = timerSequenca.toString(); //incializa o texto de tempo.
    tempoEmTexto = "TEMPO: " + tempoEmTexto;

    float yb = height*.25; //altura base para o desenho da lista de cenarios
    control.addTextlabel("label_tracks").setText("SEQUENCA DE ATIVACAO DE CENARIOS").setPosition(10, yb).setColorValue(0xffffffff);
    control.addTextlabel("label_tempo").setText(tempoEmTexto).setPosition(250, yb).setColorValue(0xffffffff); //O texto da quantidade de tempo como objeto controlP5

    control.addToggle("PLAY", false, 80, yb + 15, 15, 15).plugTo(this).setLabel("Liga Sequencia        ").getCaptionLabel().align(RIGHT, CENTER);
    println("===================CARREGANDO LISTA DE TRACKS DA SEQUENCA===================");
    yb = yb + 50; 
    int timeValue = 30; //utilizado se todos os cenarios t

    for (int i = 0; i < cenariosTotal; i++ ) {
      String track = "track" + i;
      control.addDropdownList(track).setPosition(100+(100*(i)), yb).setSize(98, 98).setBackgroundColor(color(190)).setItemHeight(20).setBarHeight(15);//.captionLabel().set(nom);
      //Quadro de texto para os Segundos de ativação do cenário
      String trackTime = "trackTime" + i;
      control.addTextfield(trackTime, (180+(100*(i))), int (yb - 30 ), 20, 9).plugTo(this).align(0, 0, 10, 5).setValue(20).setLabel(" ");// O texto que vai definir os segundos de ativação do cenário
      //Texto que mostra os segundos 
      listaTemposSeqCenarios[i] = listaTemposSeqCenariosInicial[i] ; //timeValue;
      String timeVal = (""+listaTemposSeqCenarios[i]) ;
      //println("timeValue: " + control.get(Textfield.class, trackTime ).getValue() + " timeVal: " + timeVal);
      control.addTextlabel(("label_time_track" + i )).setText("Segundos: "+timeVal).setPosition( (100+(100*(i))), int (yb - 30 ) ).setColorValue(0xffffffff);//texto com os segundo do tempo

      print ("Preenchendo " + track + " con cenários: ");
      for (int j=0; j < listaNomeCenarios.length; j++) {
        print(" cenario " + j + " /");
        control.get(DropdownList.class, track).addItem(listaNomeCenarios[j], j);
      }
      println();
    }
    println("===================CENARIOS E LISTA DE TRACKS CARREGADOS===================");
  }
  /**
   ===========================================================================================================================================
   	MÉTODOS DE GERENCIAMENTO DA SEQUENCIA DE CENÁRIOS 
   ===========================================================================================================================================*/
  /** Atualiza o desenho do tempo */
  private void mostrarTempoRolando() {
    tempoEmTexto = timerSequenca.toString(); //incializa o texto de tempo.  
    tempoEmTexto = "TEMPO: " + tempoEmTexto; 
    control.get(Textlabel.class, "label_tempo").setText( tempoEmTexto );
    pushStyle();
    textSize(40);
    text(tempoEmTexto, 20, height*.48);
    popStyle();
  }

  /** GERENCIA a sequencia de cenários, liga um a um os cenários. para o funcionamento dessa classe primeiro é chamada a clase 
   		'iniciazacaoSequencia' no mesmo momento que o PLAY é presionado */
  public void gerenciadorSequencia( float movimentacaoDaKinect ) {
    mostrarTempoRolando();	
    
    int seg = timerSequenca.second() + ( 60 * timerSequenca.minute() );
  //  println("seg: " + seg + " limiteTempoCenarioSeq: " + limiteTempoCenarioSeq );
  
    if (seg > limiteTempoCenarioSeq ) { //o limite de tempo usa %60 por que os segundos da sequencia ficam entre 0 e 60.
      switchCenarioSeq = true;
    }
    
    evaluaSePulaCenario(movimentacaoDaKinect, seg); //evalua o tempo que fica ainda ligado de cada cenário. No caso do Arvore, se tem interação vai para Toroide se não pula
    
    if (switchCenarioSeq) {
      trocaCenarioSequencia();
    }	
    //		println("seg: " + seg + " limiteTempoCenarioSeq: " + limiteTempoCenarioSeq + " indiceSequencia: " + indiceSequencia);
  }
  private void evaluaSePulaCenario( float movimentacaoDaKinect , int seg){
    int contadorInversoCenario = limiteTempoCenarioSeq - seg;
    text( listaSeqCenarios[indiceSequencia] + "\ntempo para apagar: " + contadorInversoCenario, 100+(100*(indiceSequencia)), int (height*.32) );
/*    if (contadorInversoCenario <= 10) {
      if (movimentacaoDaKinect > .7) {
        NinteracaoNoFinalCenario++; //cada leitura sobre .7 fica registrana neste contador
      } 
    }*/
  }
  /** CARREGA a lista de cenarios da sequencia, e os tempos de cada um */
  private void inicializacaoSequencia() {
    println("==================  INICIANDO SEQUENCIA  =====================");
    NinteracaoNoFinalCenario = 0;
    switchCenarioSeq = false; //vira 'false' por que a função 'trocaCenarioSeuqencia' vai ser chamado só uma vez quando essa variavel seja 'true'
    for (int i = 0; i < numeroCenarios; i++ ) { //desligamos todos os cenários para ligar na ordem da sequencia
      control.get(Toggle.class, listaNomeCenarios[i]).setValue(0);
//      PApplet_preview3D.desligaCenarioNaHoraNome( listaNomeCenarios[i] );
    }	
    indiceSequencia = 0;		//é uma inicialização, então o valor de indice da sequencia começã em 0
    limiteTempoCenarioSeq = listaTemposSeqCenarios[indiceSequencia]; 
//    println("primeiro limiteTempoCenarioSeq: " + limiteTempoCenarioSeq); 

    //liga o primeiro cenario
    String nomeCenario = listaSeqCenarios[indiceSequencia]; 
//    println("nome primeiro Cenario ligando em sequencia: " + nomeCenario);
    if (nomeCenario != null) {
      control.get(Toggle.class, nomeCenario ).setValue(1);
//      PApplet_preview3D.ligaCenarioNome( nomeCenario );
      //TODO: enviar dado de ligação do cenario ao PC

      //TROCA PUNTERO
      PVector novaPosicao = PApplet_preview3D.prevModelo.getPositionCenarioByName( nomeCenario );  
//      println( "novaPos: "+ novaPosicao );
      setNovoValorPuntero( novaPosicao ); //Troca de posição o puntero
    } else {
      println("NÃO TEM CENÁRIO NO TRACK " + indiceSequencia + " DA LISTA DE REPRODUÇÃO");
    }
  }

  /** LIGA DESLIGA os cenarios pasando de um a outro */
  private void trocaCenarioSequencia() {
    switchCenarioSeq = false;
    //Desliga o cenario anterior
    if (listaSeqCenarios[ indiceSequencia ] != null) {
      control.get(Toggle.class, listaSeqCenarios[ indiceSequencia]).setValue(0); //apaga o botao de ligado do cenario anterior
//      PApplet_preview3D.desligaCenarioNome( listaSeqCenarios[ indiceSequencia] ); //e desliga o cenário do Preview
    } //envia o apagado para o PC

    indiceSequencia++;	
    	
    if ( indiceSequencia > listaSeqCenarios.length - 1 ) { //se já foram reproduzidos todos os cenários da lista, da Stop e sai do método
          control.get(Toggle.class, "PLAY").setValue(false); 
          for (int i = 0; i < numeroCenarios; i++ ) 
            control.get(Toggle.class, listaNomeCenarios[i]).setValue(0); //apaga botoes de cenarios que ficaram ligados
          return;
        }

    //Liga o seguinte cenário
    String nomeCenario = listaSeqCenarios[indiceSequencia]; 
    if (nomeCenario != null) {
      control.get(Toggle.class, nomeCenario ).setValue(1);
 //     PApplet_preview3D.ligaCenarioComTempoNome( nomeCenario );
//      enviaLigacaoDeCenario(nomeCenario);
      NinteracaoNoFinalCenario = 0; //O contador de interacões para no fim do cenário vai para o 0
      PVector novaPosicao = PApplet_preview3D.prevModelo.getPositionCenarioByName( nomeCenario );  
      println( "novaPos: "+ novaPosicao );
      setNovoValorPuntero( novaPosicao ); //Troca de posição o puntero
    } else {
      println("NÃO TEM CENÁRIO NO TRACK " + indiceSequencia + " DA LISTA DE REPRODUÇÃO");
    }

    limiteTempoCenarioSeq += listaTemposSeqCenarios[indiceSequencia]; //Atualiza o limiar do contador de visualização de cenários
  }
  public void trocaCenarioManual () {
    
  }
  public String getNomeCenarioRolando() {
    String resp = "nada";
    if (PLAY )  {
      if ( listaSeqCenarios[indiceSequencia] != null)
        resp = listaSeqCenarios[indiceSequencia];
    }
    return resp;
  }
  /**
   ===========================================================================================================================================
   METODOS DE LEITURA DO CONTROLP5 | 
   =========================================================================================================================================== */
  boolean temEvento() { //Esse método é chamado desde a clase PApplet_preview3D para souber quando atualizar o preview e as projeções
    if (event) {
      event = false;
      return true;
    }
    return event;
  }
  /** Nesse método filtramos a info do controlP5 quando:  
   *   1 For ativado um elemento do tipo 'Group' ou seja da lista drop-down (ainda sem implementar)
   *   2 é atualizada a informação para a) mostrar/apagar os cenários no modelo | b) definir a posição do 'puntero' no modelo segundo os controles
   */
  public void controlEvent(ControlEvent theEvent) {
    if (theEvent.isGroup()) { // Os controles de controlP5 DropdownList são do tipo 'Group', podem ser filtrados aqui
//      println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup() );
      int indexCenario = 	(int) theEvent.getGroup().getValue();
      String indexTrack = theEvent.getGroup().name();
      indexTrack = indexTrack.substring( indexTrack.length() - 1, indexTrack.length()); //para pegar o número do track no final do nome
      int it = Integer.parseInt( indexTrack );
      listaSeqCenarios[it] = listaNomeCenarios[ indexCenario ];
      print("Lista de sequencia de cenários: ");
      printArray(listaSeqCenarios);
    } else if (theEvent.isController()) { //Todo o resto dos controis são 'Controllers' e são filtranos aqui e nos seus próprios metodos mais embaixo
//      println("Evento detectado: " + theEvent.getController().getName() + " id: " + theEvent.getController().getId() );

      //Evaluação para ligar e desligar cenários, do modelo e das projeções. Botões com o nome dos cenários
      if (listaNomeCenarios.length > 0 ) {
        for ( String n : listaNomeCenarios) { //percorrido por todos os nomes dos cenarios
          if ( theEvent.getController().getName().equals(n) ) { //evalua se algum deles tem relacao com o evento acontecendo
            if (control.get(Toggle.class, n).getState()) { //Se o botao (toggle) é presionado vamos ligar o cenario respectivo
              println("ligaCenarioNome: " + n);
              PApplet_preview3D.ligaCenarioNome(n);
              //TODO: enviar dado de ligação do cenario ao PC
            } else { //Se o botao (toggle) é false vamos desligar os cenarios
              println("desligaCenarioNome: " + n);
              PApplet_preview3D.desligaCenarioNaHoraNome(n); //desligaCenarioNome(n);
              //TODO: enviar dado de ligação do cenario ao PC
            }
          }
        } 

        //Evaluação que determina a posição atual no modelo 3D e na projeção. Botões com nome: ver+(nome do botão)
        int cont = 0; //contador que vai ser o index para escolher o nome do cenário a visualizar
        for ( String n : listaNomeCenarios) { //percorrido por todos os nomes dos cenarios
          String ativador = "ver" + n; //agrega "ver" para que o nome seja o mesmo que o nome do botão correspondente do controlP5
          if ( theEvent.getController().getName().equals(ativador) ) {
            println("Posição do puntero para cenário: " + n);
            PVector novaPos = posicoesCenarios[cont]; //getAngulosCenario(n); //getAngulosCenario() é do PApplet principal, pega os dados da clase EsferaBase
            setNovoValorPuntero( novaPos ); //DEFINE NOVA POSIÇÃO para o puntero. função mas embaixo em 'SETTERS'
          }
          cont++;
        }
      } 
      //evaluação para botar um tempo especifico no cenário
      for (int i = 0; i < numeroCenarios; i++ ) {
        String ativador = "trackTime" + i;	
        if ( theEvent.getController().getName().equals(ativador) ) {
          String val = control.get(Textfield.class, ativador).getStringValue();
          listaTemposSeqCenarios[i] = Integer.parseInt(val);
          control.get(Textlabel.class, ("label_time_track" + i )).setText("Segundos: " + val );	
          println("Foi entregado um dado de tempo para o track: " + i + " val: " + val);
        }
      }
    }
  }
  /**============================================================  TOGGLES  ============================================================*/
  public void PlayFromMouse() {
    control.get(Toggle.class, "PLAY").setValue(1); //liga o Play
  }
  public void PLAY (boolean val) {
    PLAY = val;
    trocaToggleText ("PLAY", "Sequencia ligada       ", "Liga Sequencia        ", val);
    if (PLAY) {
      println("PLAY true. começa sequencia de cenários");
      switchCenarioSeq = true;
      inicializacaoSequencia();
    } else {
      for (int i = 0; i < numeroCenarios; i++ ) 
         control.get(Toggle.class, listaNomeCenarios[i]).setValue(0); //apaga botoes de cenarios que ficaram ligados
    }
  }
  public void viewScreens(boolean val) {
    trocaToggleText ("viewScreens", "        telas visiveis", "        telas invisiveis", val);
    envioDadosPosicaoCenario();
  }
  public void voltea_KINECT(boolean val) {
    trocaToggleText ("voltea_KINECT", "      KINECT VIRA", "        KINECT VIRA", val);
    envioDadosPosicaoCenario();
  }
  public void preview (boolean val) {
    trocaToggleText ("preview", "        preview On", "        preview Off", val);
  }
  public void camara_In (boolean val) {
    trocaToggleText ("camara_In", "        camara 1ra", "        camara 3ra", val);
  }
  /**============================================================  SLIDERS  ============================================================*/
  public void ang_X_Puntero(float val) {
    control.get(Textfield.class, "Xp").setText( fromFloatToFormatedString (val) ); //O control Xp recebi o valor. Usamos o metodo fromFloatToString() implementado no final dessa aba
    envioDadosPosicaoCenario();
  }
  public void ang_Y_Puntero(float val) {
    control.get(Textfield.class, "Yp").setText( fromFloatToFormatedString (val) );
    envioDadosPosicaoCenario();
  }
  public void ang_Z_Puntero(float val) {
    control.get(Textfield.class, "Zp").setText( fromFloatToFormatedString (val) );
    envioDadosPosicaoCenario();
  }
  public void ang_X_Camara(float val) {
    control.get(Textfield.class, "Xc").setText( fromFloatToFormatedString (val) );
    envioDadosPosicaoCenario();
  }
  public void ang_Y_Camara(float val) {
    control.get(Textfield.class, "Yc").setText( fromFloatToFormatedString (val) );
    envioDadosPosicaoCenario();
  }
  public void ang_Z_Camara(float val) {
    control.get(Textfield.class, "Zc").setText( fromFloatToFormatedString (val) );
    envioDadosPosicaoCenario();
  }
  public void zoom (float val) {
    //TODO: enviar os dados do zoom, que representa a distancia entre a câmara e o ponto centro da imagem para o PC
    PApplet_preview3D.prevModelo.setDistanciaFoco( val ); //atualiza o zoom no preview
    envioDadosPosicaoCenario();
  }
  /**============================================================  BANGS  ============================================================*/
  public void zoom_out () {
    PApplet_preview3D.generalZoomIn();  //zoom out para ver o modelo de preview mais de longe
  }
  public void zoom_in () { 
    PApplet_preview3D.generalZoomOut();  //zoom in para ver o modelo de preview mais de perto
  }
  /**============================================================  TEXT FIELD  ============================================================*/
  public void Xp(String theText) {
    setSliderValueFromString ("ang_X_Puntero", theText) ; //O slider ang_X_Puntero recebe theText. Usamos o metodo setSliderValueFromString() implementado no final dessa aba
  }
  public void Yp(String theText) {
    setSliderValueFromString ("ang_Y_Puntero", theText) ;
  }
  public void Zp(String theText) {
    setSliderValueFromString ("ang_Z_Puntero", theText) ;
  }
  public void Xc(String theText) {
    setSliderValueFromString ("ang_X_Camara", theText) ;
  }
  public void Yc(String theText) {
    setSliderValueFromString ("ang_Y_Camara", theText) ;
  }
  public void Zc(String theText) {
    setSliderValueFromString ("ang_Z_Camara", theText) ;
  }
  /**============================================================  GETTERS  ============================================================*/
  public boolean estaSeExecutandoSequencia() {
    return PLAY;
  }
  public int getCamaraIn() {
    int r = 0;
    if (control.get(Toggle.class, "camara_In").getState()) r = 1;
    return r;
  }
  public boolean getVerTelas() {
    return control.get(Toggle.class, "viewScreens").getState();
  }
  public boolean getViraKinect(){
    return control.get(Toggle.class, "voltea_KINECT").getState(); 
  }
  public boolean getPreview() {
    return control.get(Toggle.class, "preview").getState();
  }
  public float getAngXPuntero() {
    return control.getController("ang_X_Puntero").getValue();
  }
  public float getAngYPuntero() {
    return control.getController("ang_Y_Puntero").getValue();
  }
  public float getAngZPuntero() {
    return control.getController("ang_Z_Puntero").getValue();
  }
  public float getAngXCamara() {
    return control.getController("ang_X_Camara").getValue();
  }
  public float getAngYCamara() {
    return control.getController("ang_Y_Camara").getValue();
  }
  public float getAngZCamara() {
    return control.getController("ang_Z_Camara").getValue();
  }
  public float getDistanciaFoco() {
    return control.getController("zoom").getValue();
  }
  /**============================================================  SETTERS  ============================================================*/
  private void setNovoValorPuntero( PVector np ) {
    control.getController("ang_X_Puntero").setValue(TWO_PI-np.x); //TWO-PI permite cambiar o sentido de giro. ControlP2, troca o valor de novaPos.x, a resta neutraliza a mudanza
    control.getController("ang_Y_Puntero").setValue(TWO_PI-np.y);
    control.getController("ang_Z_Puntero").setValue(TWO_PI-np.z);
    control.getController("ang_X_Puntero").update();
    control.getController("ang_Y_Puntero").update();
    control.getController("ang_Z_Puntero").update();
  }
  /**
   	============================================================================================================================================
   	PFrame 2 | Frame que contém o PApplet da previsualização 3D |
   	===========================================================================================================================================
   	*/
  public class PFrame2 extends Frame {
    public PFrame2() {
      println("Construtor de PFrame2");
      setUndecorated(true);
      int widthTela = 400;
      int heightTela = 400;
      setBounds(0, 0, widthTela, heightTela);//1200, 768);
      setLocation( (p5.width - widthTela - 10 ), 50);
      setAlwaysOnTop(true);
      PApplet_preview3D = new PApplet2();
      add(PApplet_preview3D);
      PApplet_preview3D.init();
      show();
    }
  }

  public class PApplet2 extends PApplet {
    public PreviewModelo3D prevModelo;

    public void setup() {
      println("Inicio setup do PApplet2");
      size(400, 400, P3D);
      println("Fim setup do PApplet2");
    }

    public void draw() {
      background(0);
      if ( getPreview() ) {
        prevModelo.setAng_X_Puntero( getAngXPuntero() );
        prevModelo.setAng_Y_Puntero( getAngYPuntero() );
        prevModelo.setAng_Z_Puntero( getAngZPuntero() );
        prevModelo.setAng_X_Camara( getAngXCamara() );
        prevModelo.setAng_Y_Camara( getAngYCamara() );
        prevModelo.setAng_Z_Camara( getAngZCamara() );
      }
      prevModelo.aplicaCamara( getCamaraIn() ); 
      prevModelo.desenhaModelo();
      
      camera();
      noFill();
      stroke(255);
      rect(0,0,400,400);
    }
    /** Metodo que é chamado desde a clase Controles para souber quando o PApplet2 estiver pronto com a clase prevModelo instanciada */
    public boolean isPreviewModeloOn() {
      boolean r = false;
      if (prevModelo != null) r = true;
      return r;
    }

    /** Coloca cenarios com os dados recebidos pela Classe Controles nessa mesma abba.  */
    public void agregaUmCenario (PMatrix3D m, String _name, PVector angulosPos) {
      println("Chamada a agregar um cenário de nome " + _name  + " no PApplet_preview3D desde clase Controles");
      if (prevModelo == null) { //se o Objeto que desenha o modelo preview ainda não é inicializado, ele cria o objeto
        println("inicialização do objeto 'prevModelo' da classe PreviewModelo3D");
        prevModelo = new PreviewModelo3D(this);
      }
      prevModelo.agregaUmCenario(m, _name, angulosPos);
    }
    public void ligaCenarioComTempoNome(String nome) {
      prevModelo.ligaCenario(nome);
        enviaLigacaoDeCenarioComTempo(nome);
    }
    
    public void ligaCenarioNome(String nome) {
      prevModelo.ligaCenario(nome);
      enviaLigacaoDeCenario(nome);
    }
    public void desligaCenarioNome(String nome) {
      prevModelo.desligaCenario(nome);
      enviaApagaCenario(nome);
    }
    public void desligaCenarioNaHoraNome(String nome) {
      prevModelo.desligaCenario(nome);
      enviaApagaCenarioNaHora(nome);
    }
    public void generalZoomIn () {
      if (prevModelo != null)  prevModelo.zoomIn();
    }
    public void generalZoomOut () {
      if (prevModelo != null) prevModelo.zoomOut();
    }
  }
  /**
   	===========================================================================================================================================
   	 ControlP5 | Metodos utilizados na leitura dos dados de ControlP5  
   	===========================================================================================================================================
   	*/
  public String fromFloatToFormatedString (float val) {
    double number = val;
    DecimalFormat numberFormat = new DecimalFormat("#.00");
    String stg = numberFormat.format(number); 
    return stg;
  } 
  public void setSliderValueFromString (String nomeSlider, String value) {
    float val = parseFloat(value); 
    control.get(Slider.class, nomeSlider).setValue(val);
    control.get(Slider.class, nomeSlider).update();
  }
  public void trocaToggleText(String nomeToggle, String estadoOn, String estadoOff, boolean val) {
    if (val) {
      control.get(Toggle.class, nomeToggle).setLabel(estadoOn);
      timerSequenca.reset();
    } else {
      control.get(Toggle.class, nomeToggle).setLabel(estadoOff);
    }
  }
}



