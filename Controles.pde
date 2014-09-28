class Controles {
  //Variaveis ajustaveis
  int indexCamara; //variavel sem utilzar, para exluir tem que mudar alguns métodos
  float ang_X_Puntero, ang_Y_Puntero, ang_Z_Puntero; //angulos que definen a posição do ponto centro da imagem no modelo
  float ang_X_Camara, ang_Y_Camara, ang_Z_Camara; //angulos que definen a posição da câmara em relação ao ponto centro
  float zoom; //zoom da visualizacao previa

  boolean event = false; //boolean para souber cada novo evento nos controles
  boolean preview = false; //Liga o control com as projeções
  boolean viewScreens = false; //para visualizar os limites da tela de cada projetor
  boolean camara_In; //Se a visualizacao esta em estado de 3ra pessoa ou 1era
  boolean cenariosCarregados;
  boolean anteriorPreview; //boolean para evaluar los cambios entre ocultar e mostrar janela

  String Xp, Yp, Zp, Xc, Yc, Zc; //nomes dos TextField dos angulos do puntero e da camara
  int numeroCenarios;
  String [] listaCenarios; //uma lista com os nomes dos cenarios existentes
  PVector [] posicoesCenarios; //Posições dos cenarios, o pvector contém os angulos da posição no modelo
  PMatrix3D [] matrixCenarios; //contém as matrices de giro. basicamente os mesmos angulos do PVector, mas aplicados numa matriz

  ControlTimer timerSequenca;
  String tempoCero;

  PApplet2 PApp2;
  PFrame2 frame2;

  Controles(PApplet p5) {
    frame2 = new PFrame2(); 
    numeroCenarios = 5;
    
    listaCenarios = new String [numeroCenarios];
    posicoesCenarios = new PVector[numeroCenarios];
    matrixCenarios = new PMatrix3D[numeroCenarios];
    
    control = new ControlP5(p5);
    
    makePreviewControls();
    criaCenarios();
    carregaCenarios();
  }

  /** Criação dos cenarios, é usando quanto o programa não tem conxão com o programa de visualização no outro computador */
  public void criaCenarios() {
    
    listaCenarios[0] = "Revoada";
    posicoesCenarios[0] = new PVector(PI,      0,        PI*.5);
    listaCenarios[1] = "Atraccao";
    posicoesCenarios[1] = new PVector(0,      PI*1.5,    PI*.5);
    listaCenarios[2] = "Ser01";
    posicoesCenarios[2] = new PVector(PI*.25,   0,       0);
    listaCenarios[3] = "Nuvem";
    posicoesCenarios[3] = new PVector(0,        0,       PI*.5);
    listaCenarios[4] = "Rodape_0";
    posicoesCenarios[4] = new PVector(0,        0,       0);
    
    
    for (int i=0 ; i<numeroCenarios ; i++) {
      matrixCenarios[i] = criaMatrixFromAngulos(posicoesCenarios[i]); //criação das matrices
    }
    
  }
  public PMatrix3D criaMatrixFromAngulos(PVector ang){
     PMatrix3D cenarioM = new PMatrix3D();
     cenarioM.reset();
     cenarioM.rotateY(ang.y);
     cenarioM.rotateX(ang.x);
     cenarioM.rotateZ(ang.z);
     return cenarioM;
  }
  /** Carrega cenarios com a informação do nome, angulos de posição, a matrix de giro e quantidade de cenários. */
  public void carregaCenarios() { 
    int cenariosTotal = numeroCenarios;
    println("Cenarios carregados na clase esfera: " + cenariosTotal);
    int y = 11; 
    int contador = 0 ;

    for (int i = 0; i < cenariosTotal; i++ ) {
      PMatrix3D matrixTem = matrixCenarios[i];
      String nomeTem = listaCenarios[i];
      PVector angs = posicoesCenarios[i];

//      if (PApp2.agregaUmCenario(matrixTem, nomeTem, angs)) {
//        listaCenarios.add(nomeTem);
        contador++; 
        println("...criando control do cenario... nome: "+nomeTem );
        control.addToggle(nomeTem, false, width*.75, y += 11, 9, 9).setLabel(nomeTem).getCaptionLabel().align(LEFT, CENTER).style().marginLeft = 15; //move to the right;//align(22, -5);
        String ativador = "ver" + nomeTem;
        control.addBang(ativador).setPosition(width*.82, y).setSize(10, 10).setColorForeground(color(255, 0, 255)).setLabelVisible(false);
 //     }
    } 
    if (contador == cenariosTotal) { //Quando todos os cenarios estever criados
      control.addTextlabel("labelCenario").setText("CENARIOS      ir").setPosition(width*.76, 10).setColorValue(0xffffffff); //desenhamos o Texto
  //    settingTimerControl(cenariosTotal);
      cenariosCarregados = true;
    }
  }

  void makePreviewControls() {
    int yt = 80;
    control.addTextfield("Xp", 10, yt += 10, 30, 9).align(0, 0, 10, 5);//this is where you type the words
    control.addTextfield("Yp", 10, yt += 10, 30, 9).align(0, 0, 10, 5);//this is where you type the words
    control.addTextfield("Zp", 10, yt += 10, 30, 9).align(0, 0, 10, 5);//this is where you type the words
    control.addTextfield("Xc", 10, yt += 10, 30, 9).align(0, 0, 10, 5);
    control.addTextfield("Yc", 10, yt += 10, 30, 9).align(0, 0, 10, 5);
    control.addTextfield("Zc", 10, yt += 10, 30, 9).align(0, 0, 10, 5);

    int y = 80;

    control.addSlider("ang_X_Puntero", .0, TWO_PI*1.1, .0, 45, y += 10, 500, 9).setLabel("Giro puntero X").setColorForeground(color(255, 200, 120));//.getCaptionLabel().toUpperCase(true).align(230,0);
    control.addSlider("ang_Y_Puntero", .0, TWO_PI*1.1, .0, 45, y += 10, 500, 9).setLabel("Giro puntero Y").setColorForeground(color(255, 200, 120));
    control.addSlider("ang_Z_Puntero", .0, TWO_PI*1.1, .0, 45, y += 10, 500, 9).setLabel("Giro puntero Z").setColorForeground(color(255, 200, 120));
    control.addSlider("ang_X_Camara", .0, TWO_PI*1.1, .0, 45, y += 10, 500, 9).setLabel("Giro camara X").setColorForeground(color(0, 255, 0));
    control.addSlider("ang_Y_Camara", .0, TWO_PI*1.1, .0, 45, y += 10, 500, 9).setLabel("Giro camara Y").setColorForeground(color(0, 255, 0));
    control.addSlider("ang_Z_Camara", .0, TWO_PI*1.1, .0, 45, y += 10, 500, 9).setLabel("Giro camara Z").setColorForeground(color(0, 255, 0));
    control.addSlider("zoom", .0, 1.0, .5, 10, y += 10, 230, 9).setColorForeground(color(0, 0, 255));
    control.addToggle("preview", false, 10, y = 25, 9, 9).setLabel("      preview").getCaptionLabel().align(LEFT, CENTER);
    control.addToggle("camara_In", false, 10, y += 11, 9, 9).setLabel("      camara_In").getCaptionLabel().align(LEFT, CENTER);
    control.addBang("zoom_in").setPosition(10, y += 11).setSize(10, 10).setColorForeground(color(255, 0, 255)).setLabel("      zoom_in").getCaptionLabel().align(LEFT, CENTER);
    control.addBang("zoom_out").setPosition(10, y += 11).setSize(10, 10).setColorForeground(color(255, 0, 255)).setLabel("      zoom_out").getCaptionLabel().align(LEFT, CENTER);
    control.addToggle("viewScreens", false, 10, y += 11, 9, 9).setLabel("      ver telas").getCaptionLabel().align(LEFT, CENTER);
  }

  public class PFrame2 extends Frame {

    public PFrame2() {
      println("frame: PFrame2 e PApplet: PApplet2 / segunda janela de projecao");
      setUndecorated(true);
      int widthTela = 50;
      int heightTela = 50;
      setBounds(0, 0, widthTela, heightTela);//1200, 768);
      setLocation((int)(width*.25), heightTela +10);
      PApp2 = new PApplet2();
      add(PApp2);
      PApp2.init();
      show();
    }
  }

  public class PApplet2 extends PApplet {

    public void setup() {
    }

    public void draw() {
    }
  }
}

