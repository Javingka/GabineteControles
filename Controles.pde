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

  boolean anteriorPreview; //boolean para evaluar los cambios entre ocultar e mostrar janela

  String Xp, Yp, Zp, Xc, Yc, Zc; //nomes dos TextField dos angulos do puntero e da camara
  ArrayList <String> listaCenarios; //uma lista com os nomes dos cenarios existentes
  PVector [] posicoesCenarios;
  ControlTimer timerSequenca;
  String tempoCero;

  Controles() {
    frame2 = new PFrame2(); 
    listaCenarios = new ArrayList <String>();
    control = new ControlP5(this);
    makePreviewControls();
 //   carregaCenarios();
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
}

