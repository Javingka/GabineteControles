import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;

class KinectControl {
  PApplet p5;

  PFrameKinect frameKinect;
  PAppletKinect PAppKinect;

  SimpleOpenNI cam1; //Kinect um
  SimpleOpenNI cam2; //Kinect dois

  ArrayList <PVector> nuvemPontosUsuario; //ArrayList con os pontos que formam ao usuario no espaço virtual
  PVector posicaoFruidor; //posiçao com valores X e Y. do fruidor no espaço
  float posicaoFrudorNormal; //variavel normalizada da posição em Z do fruidor
  float posicaoFruidorNormal_X; //variavel normalizada da posição em X do fruidor
  float movimentacao, movimentacaoMedia, cantMuestrasMov; //variavel de 0 a 1. com nivel de movimentação
  float deslocamento; //variavel de 0 a 1. com nivel de deslocamento
  float posicao; //variavel de 0 a 1. Representa a posição desde um extremo do espaço ao outro.
  
  PGraphics imagemKinect; //desenho do fruidor

  float maximaDistanca_X, maximaDistanca_Y;

  PVector  posicaoCentroPlanta; //A posição do centro do retangulo que desenha a planta de deslocamento do fruidor.
  PVector posMap; //posição mapeada da pessoa no espaço, também utilizada para o envio dos dados de posicao para o PC
    public KinectControl ( PApplet _p5 ) {
    println( "\n Criando objetos SimpleOpenNI para KINECTS \n");
    p5 = _p5;
    settingKinects();
    frameKinect = new PFrameKinect();
    posicaoCentroPlanta = new PVector (p5.width *.43, p5.height - 275);
    posicaoFruidor = new PVector();
    //Os valores de maximo desplazamento desde o ponto 0,0,0 no centro do espaço. A uniade é em milímetros.
    maximaDistanca_X = 2000;
    maximaDistanca_Y = 1000;
    nuvemPontosUsuario = new ArrayList <PVector>();
    imagemKinect = createGraphics(640, 480);
  }

  private void settingKinects () {
    // start OpenNI, load the library
    SimpleOpenNI.start();

    // print all the cams 
    StrVector strList = new StrVector();
    SimpleOpenNI.deviceNames(strList);
    for (int i=0; i<strList.size (); i++)
      println(i + ":" + strList.get(i));

    // verifica se tem as câmaras suficientes. se não sai do código. 
    if (strList.size() < 2)
    {
      println("PARE AÍ. Tem menos de dois câmaras!. Only works with 2 cams");
      //exit();  
      //return;
    }

    // init the cameras
    cam1 = new SimpleOpenNI(0, p5);
    cam2 = new SimpleOpenNI(1, p5);    

    if (cam1.isInit() == false) {
      println("SimpleOpenNI não pode iniciar, Camara Kinect um 'cam1' pode não estar conectada");
    } else {
      println("Carregando 'depth image' e 'User Info' Camara 1");
      // Define as coordenadas da câmara
      cam1.setUserCoordsys( 183.77469, -900.5925, 3621.0  , 657.8145, -900.5714, 3546.0 , 300.73447, -880.36255, 4296.0  );  
      cam1.enableDepth();
      cam1.enableUser();
      /* Saida
nullPoint3d: [ ]
xDirPoint3d: [ ]
zDirPoint3d: [ ]*/
      
    }
    if (cam2.isInit() == false) {
      println("SimpleOpenNI não pode iniciar, Camara Kinect dois 'cam2' pode não estar conectada");
    } else {
      println("Carregando 'depth image' e 'User Info' Camara 2");
      // Define as coordenadas da câmara
      cam2.setUserCoordsys( 59.522213, -635.418, 3779.0, -239.31526, -636.41125, 3907.0, -50.181892, -658.475, 3186.0 ); 
      /* Entrada
      nullPoint3d: [  ]
xDirPoint3d: [  ]
zDirPoint3d: [ ]*/


      cam2.enableDepth();
      cam2.enableUser();
    }
  }

  public void desenhaPlantaDeslocamento() {
    pushMatrix();
    pushStyle();

    posMap = mapeaPosicaoNoRect();
    float posF_X = posMap.x * 160; //variavel de posição por a mitade da largura do rectangulo de visualização
    float posF_Y = posMap.y * 120; //variavel de posição por a mitade da altura do rectangulo de visualização
    translate(posicaoCentroPlanta.x, posicaoCentroPlanta.y); //fica no centro do rectangulo que desenha a posicao do fruidor
    stroke(255);
    rectMode(CENTER);
    textAlign(CENTER, CENTER);
    fill(0, 20);
    rect(0, 0, 320, 240);
    line(0, 120, 0, -120);

    //desenha linhas da posição do fruidor 
    stroke(255, 80);
    line(-160, posF_Y, 160, posF_Y);
    line(posF_X, -120, posF_X, 120);

    //desenha ponto central da visualização
    stroke(255, 0, 0);
    strokeWeight(3);
    point(0, 0);
    fill(255);

    //desenha a posição do fruidor na tela
    text( ("posicao: " + posicaoFruidor + "\nposicaoFruidorNormal_X: " + posicaoFruidorNormal_X + 
    "\nposicaoFruidorNormalZ: " +posicaoFrudorNormal ), 0, -150);
    stroke(0, 255, 0, 50);
    ellipse(posF_X, posF_Y, 10, 10);
    stroke(0, 255, 0);
    point( posF_X, posF_Y);

    //desenha valor de movimentação
    strokeWeight(1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         );
    translate( -200, 120);
    text ("MOVIMENTACAO", 0, 40); 
    stroke(255);
    line(0, 0, 0, -240);
    line(-20, -240 * .75, 20, -240 * .75);
    stroke (255, 0, 0, 120);
    strokeWeight(15);
    line(0, 0, 0, movimentacao * -240);

    translate( -110, 0);
    float mm = (movimentacaoMedia / cantMuestrasMov);
    text ("MOVIMENTACAO\nMEDIA", 0, 50); 
    stroke (0, 255, 0, 120);
    line(0, 0, 0, mm * -240);

    popMatrix();  
    popStyle();
  }

  /** A posição z da kinect pasa a ser a posição x no desenha na tela 
   A posição x da kinect pasa a ser a posição y no desenho na tela */
  private PVector mapeaPosicaoNoRect() {
    float px = constrain ( map(posicaoFruidor.z, -maximaDistanca_X, maximaDistanca_X, -1, 1), -1, 1);
    float py = constrain ( map(posicaoFruidor.x, -maximaDistanca_Y, maximaDistanca_Y, -1, 1), -1, 1);
    PVector posMap = new PVector(px, py);

    return posMap;
  }  
  public void setPosicaoFruidor (PVector pf) {
    posicaoFruidor = pf;
    envioDadosInteracaoContinua();
  }
  public void setMovimentacaoFruidor (float mval, boolean subendo) {
    cantMuestrasMov++;
    movimentacaoMedia += mval;
    if (subendo)
      movimentacao = mval;
    else
      movimentacao = lerp ( movimentacao, mval, .08);
  }
  public float getPosicaoFruidor() {
    float pos = constrain ( map(posicaoFruidor.z, -maximaDistanca_X, maximaDistanca_X, 1, 0), 0, 1);
    pos = constrain ( lerp(posicaoFrudorNormal,  pos, .3), 0, 1);
    posicaoFrudorNormal = pos;
    return  pos;
  }
  public float getMovimentacaoFruidor() {
    return  movimentacao;
  }
  public float getPosicaoFruidorLargura() {
    float pos = abs(posMap.y);
    pos = constrain ( lerp(posicaoFruidorNormal_X,  pos, .3), 0, 1);
    posicaoFruidorNormal_X = pos;
 //   println("XXXXXXXXXX pos: " + pos);
    return  pos;
  }
  public byte[] getArrayBytesNuvemPontos(String infoDado) {
    
    println("nuvemPontosUsuario.size(): " + nuvemPontosUsuario.size() );
    ArrayList <String> listS = getStringListFromPVectorList ( nuvemPontosUsuario , infoDado );
    
    // write to byte array
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    DataOutputStream out = new DataOutputStream(baos);
    for (String element : listS) {
      try {
        out.writeUTF(element);
      } 
      catch(Exception e) {
      }
    }
    byte[] bytes = baos.toByteArray();

    return bytes;
  }
  private ArrayList<String> getStringListFromPVectorList ( ArrayList<PVector> PVectorList , String infoDado) {
    ArrayList<String> stringList = new ArrayList<String>();
    stringList.add(infoDado);
    
    for (int p=0 ; p < PVectorList.size() ; p++ ) {
      PVector pv = PVectorList.get(p);
      stringList.add("" + pv.x + "," + pv.y + "," + pv.z );
    }
    
    return stringList;
  }
  /**
   ============================================================================================================================================
   PFrame Kinects | Frame que contém o PApplet com os Kinects
   ===========================================================================================================================================
   */

  public class PFrameKinect extends Frame {
    public PFrameKinect() {
      println("Construtor de PFrameKinect");
      setUndecorated(true);
      int widthTela = 640;
      int heightTela = 240;
      setBounds(0, 0, widthTela, heightTela);//1200, 768);
      setLocation(p5.width - 650, p5.height - 350);
      setAlwaysOnTop(true);
      PAppKinect = new PAppletKinect();
      add(PAppKinect);
      PAppKinect.init();
      show();
    }
  }

  public class PAppletKinect extends PApplet {
    PVector posicaoTemporal = new PVector (); //Se utiliza para leitura de posição em cada novo frame
    PVector posicaoMaoDir0, posicaoMaoDir; //posições, atual e anterior da mão direita
    PVector posicaoMaoEsq0, posicaoMaoEsq; //posições, atual e anterior da mão esquerda
    PVector movimentoMaoDireita, mocimentoMaoEsquerda; //vetores resultantes da resta entre posição atual e previa  
    float maiorMovimento = 1; //variavel auto ajustavel

    int cantDeteccoesPosicao, cantDeteccoesMovDir, cantDeteccoesMovEsq; //cantidad de câmaras que estão detectando o skeleton data, vai ser 0, ou 1 ou 2
    boolean testaLeturaMapaUsuario;
    boolean getNuvemPontos; //boolean para pegar só uma vez a nuvem de pontos quando tem duas kinects lendo

    public void setup() {
      println("Inicio setup do PAppletKinect");
      size(640, 240);
      textAlign(CENTER, CENTER);
      println("Fim setup do PAppletKinect");
    }

    public void draw() {
      pushMatrix();
      scale(.5);
      //     println("draw PAppletKinect");
      // update the cam
      SimpleOpenNI.updateAll();

      //Variaveis usadas na detacção
      posicaoTemporal = new PVector ();
      posicaoMaoDir0 = posicaoMaoDir;
      posicaoMaoEsq0 = posicaoMaoEsq;
      posicaoMaoDir = posicaoMaoEsq = new PVector ();
      movimentoMaoDireita = mocimentoMaoEsquerda = new PVector ();
      cantDeteccoesPosicao = cantDeteccoesMovDir = cantDeteccoesMovEsq = 0;
      getNuvemPontos = false; //boolean para pegar só uma vez a nuvem de pontos quando tem duas kinects lendo
      testaLeturaMapaUsuario = false;
      maiorMovimento--;
      
      // draw depthImageMap
      deteccaoUsuario(cam1, 0, 0, "camera1");
      translate(cam1.depthWidth() + 10, 0);
      deteccaoUsuario(cam2, 0, 0, "camera2"); 
//      println( " nuvemPontosUsuario: " + nuvemPontosUsuario.size() );

      if (getNuvemPontos) { //se teve leitura dos pontos da kinect
        enviaNuvemPontosKinect(); //envia dados para o PC, esse método é parta da classe principal GabineteControles
      }
      
      
      //Se houve detecção de usuario, atualiza o valor da posição do fruidor segundo os dados lidos
      if (posicaoTemporal.y != 0 && posicaoTemporal.x != 0 ) {
        //        posicaoFruidor = posicaoTemporal;  
        if (cantDeteccoesPosicao > 1)  posicaoTemporal.div(cantDeteccoesPosicao); 
        if (cantDeteccoesMovDir > 1)  posicaoMaoDir.div(cantDeteccoesMovDir);
        if (cantDeteccoesMovEsq > 1)  posicaoMaoEsq.div(cantDeteccoesMovEsq); 

        setPosicaoFruidor(posicaoTemporal); //'setPosicaoFruidor' é um método da classe pai, KinectControl. Define a posição final do fruidor

        if ( posicaoMaoDir != null && posicaoMaoEsq != null) {
          movimentoMaoDireita = PVector.sub(posicaoMaoDir, posicaoMaoDir0);
          mocimentoMaoEsquerda = PVector.sub(posicaoMaoEsq, posicaoMaoEsq0);
          PVector movTotal = PVector.add(movimentoMaoDireita, mocimentoMaoEsquerda);
          movTotal.div(2);
  //        movTotal.sub(posicaoTemporal);
  //        println("movTotal.mag(): " + movTotal.mag() + " maiorMovimento: " + maiorMovimento);
   /*       if (movTotal.mag() > maiorMovimento && movTotal.mag() < 500) { //   se o valor a movimentação é maior que o maximo conhecido e não é maior que 500 mm atualiza
            maiorMovimento = movTotal.mag();
          }
          println();
          float movimentoNormalizado = constrain ( map ( movTotal.mag(), 500, maiorMovimento, 0, 1), 0, 1);*/
          if ( movTotal.mag() < 500) {
            float movimentoNormalizado = constrain ( map ( movTotal.mag(), 150, 300, 0, 1), 0, 1);
            if (movimentoNormalizado > movimentacao)
              setMovimentacaoFruidor(movimentoNormalizado, true);
            else 
              setMovimentacaoFruidor(movimentoNormalizado, false    );
          }
          
        }
      }

      //     print("cantDeteccoesPosicao: "+ cantDeteccoesPosicao); //esse método é parte da classe pai, diferente do metodo colocatexto nesse PAppletKinect
      //      println("  posicaoTemporal: "+posicaoTemporal);
      //     println();
      popMatrix();
    }
    public void colocatexto(String texto, float px, float py ) {
      textSize(20);
      fill(255, 0, 0);
      text(texto, px, py);
    }
    public void colocatextoCfundo(String texto, float px, float py ) {
      rectMode(CENTER);
      textSize(25);
      texto = texto.toUpperCase();  
      fill(0);
      rect(px,py, texto.length()*20 , 30);  
      fill(255, 200, 0);
      text(texto, px, py);
      
      
    }
    /** Detecção do usuario na cena */
    public void deteccaoUsuario (SimpleOpenNI c, float px, float py, String camNome) {
      boolean detectaEsqueleton = false;
      PVector[] depthPoints = null;
      // draw the skeleton if it's available
      int[] userList = c.getUsers();
      PVector posicaoTorsoParaAjusteNuvem = new PVector();
      int [] userMap = null; //Array com os pixeles que isenhm ao fruidor
      
      for (int i=0; i<userList.length; i++) {
        if (c.isTrackingSkeleton(userList[0])) {
          stroke( 255, 0, 0 );
          //          drawSkeleton(c, userList[i]);
          
          float confidence_pt = c.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_TORSO, posicaoTorsoParaAjusteNuvem );
          if (!testaLeturaMapaUsuario) {
            userMap = c.userMap();//getUsersPixels(SimpleOpenNI.USERS_ALL); //pegamos o array de pixels que desenham ao fruidor
            depthPoints = c.depthMapRealWorld(); //Obter os pontos da nuvem 
            testaLeturaMapaUsuario = true;
          }
          if (confidence_pt > 0.3) {//evalua que aleitura seja confíavel
            cantDeteccoesPosicao++; //somamos um à variavel que conta as detecções feitas só quando o PVector tem um valor.
            posicaoTemporal.add (getValorPos(userList[i], SimpleOpenNI.SKEL_TORSO, c, camNome ) ); //Pega o valor do torso para definir a posição do fruidor
            detectaEsqueleton = true; 
          }

          float confidence_md = c.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, new PVector());
          if (confidence_md > 0.6) {
            posicaoMaoDir.add (getValorPos(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, c, camNome ) ); //Pega o valor da mão direita 
            cantDeteccoesMovDir++;
            detectaEsqueleton = true;
    //        nuvemPontosUsuario.clear();
            
          }

          float confidence_me = c.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, new PVector());
          if (confidence_me > 0.6) {
            posicaoMaoEsq.add (getValorPos(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, c, camNome ) ); //Pega o valor da mão esquerda 
            cantDeteccoesMovEsq++;
            detectaEsqueleton = true;
    //        nuvemPontosUsuario.clear();
            
          }
        
          
          //      if ( posicaoTemporal.y != 0 && posicaoTemporal.x != 0 )  {} //if (posicaoMaoDir0.z != posicaoMaoDir.z && posicaoMaoEsq.x != posicaoMaoEsq0.x )  {
        }
      }
      image(c.depthImage(), px, py);
      colocatextoCfundo(camNome, width*.1, 10);
      if (!detectaEsqueleton) {
        
      } else {
          drawSkeleton(c, userList[0]);
          
      }
      if (testaLeturaMapaUsuario && !getNuvemPontos) {//depthPoints != null) {
 //         imagemKinect.beginDraw();
 //         imagemKinect.background(100);
 //         imagemKinect.loadPixels();
         nuvemPontosUsuario.clear();
//         println("userMap.length: " + userMap  .length + "depthPoints.length: " + depthPoints.length);
         int cont = 0;
         for (int j =0; j < userMap.length; j++) {
            // if the pixel is part of the user
            if (userMap[j] != 0) {
              cont++;
              // set the sketch pixel to the color pixel
              if ( cont%60 ==0 ) {
                //resta da posição do ponto com a posição do torso, para que a nuvem de pontos possa ter seu proprio mapa de referencia
 //               println(" DADO: ");
 //               println("depthPoints[j]: " + depthPoints[j] +  " - posicaoTorsoParaAjusteNuvem: " + posicaoTorsoParaAjusteNuvem);
                if (nuvemPontosUsuario.size() < 1500) {
                  nuvemPontosUsuario.add( PVector.sub(depthPoints[j] , posicaoTorsoParaAjusteNuvem) );  
                }
        //        nuvemPontosUsuario.get( nuvemPontosUsuario.size()-1 ) = .sub( posicaoTorsoParaAjusteNuvem ); 
              }
  //            imagemKinect.pixels[j] = color(0, 0, 255);
            }
          }
  //        imagemKinect.updatePixels();
          
  //        imagemKinect.endDraw();
   //       println("nuvemPontosUsuario.size: " + nuvemPontosUsuario.size() );
          colocatexto("Pègando pontos!!", width*.5,  height*.5);
          getNuvemPontos = true;
          println(" CARREGA nuvemPontosUsuario ");
        } 
//        image(c.depthImage(), px, py);
   //     image(imagemKinect, px, py);
    }

    // draw the skeleton with the selected joints
    void drawSkeleton(SimpleOpenNI curContext, int userId)
    {
      stroke(0,255,0);
      desenhaMembro(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT, curContext);
      desenhaMembro(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP, curContext);
      fill(255, 0, 0);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_HEAD, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_NECK, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_NECK, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_TORSO, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_LEFT_HIP, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_LEFT_KNEE, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_RIGHT_HIP, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_LEFT_FOOT, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_LEFT_HIP, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_RIGHT_HAND, curContext);
      desenhaArticulacao(userId, SimpleOpenNI.SKEL_LEFT_HAND, curContext);
    }
    void desenhaMembro(int userId, int jointID_1, int  jointID_2, SimpleOpenNI kinect) {
      PVector joint1 = new PVector();
      float confidence1 = kinect.getJointPositionSkeleton(userId, jointID_1, joint1);
      if (confidence1 < 0.5) {
        return;
      }
      PVector convertedJoint1 = new PVector();
      kinect.convertRealWorldToProjective(joint1, convertedJoint1);

      PVector joint2 = new PVector();
      float confidence2 = kinect.getJointPositionSkeleton(userId, jointID_2, joint2);
      if (confidence2 < 0.5) {
        return;
      }
      PVector convertedJoint2 = new PVector();
      kinect.convertRealWorldToProjective(joint2, convertedJoint2);
 /*     imagemKinect.beginDraw();
      imagemKinect.stroke(255);
      imagemKinect.line(convertedJoint1.x, convertedJoint1.y, convertedJoint2.x, convertedJoint2.y);
      imagemKinect.endDraw();*/
      stroke(255);
      line(convertedJoint1.x, convertedJoint1.y, convertedJoint2.x, convertedJoint2.y);
    }

    void desenhaArticulacao(int userId, int jointID, SimpleOpenNI kinect) {
      PVector joint = new PVector();
      float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
      if (confidence < 0.5) {
        return;
      }
      PVector convertedJoint = new PVector();
      kinect.convertRealWorldToProjective(joint, convertedJoint);
/*      imagemKinect.beginDraw();
      imagemKinect.ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
      imagemKinect.endDraw();*/
      ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
      
    }
    PVector getValorPos (int userId, int jointID, SimpleOpenNI kinect, String cam) {
      PVector joint = new PVector();
      float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
      //      print(" " + cam + ": " + joint);
 //     if (confidence < 0.5) {
 //       return new PVector();
 //     }
      return joint;
    }
  }
}

