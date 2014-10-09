/** Essa classe implemente uma outra escreta no final dessa aba
* 
*/
class PreviewModelo3D {
  PApplet p5; //objeto da clase inicial de processing
  PMatrix3D matrixA, matrixB; //matrices para definiar as rotacoes do modelo e da camara
  Quaternion quatA, quatB; //Um quaternion para cada sistema de rotacao, do modelo e da camara  
  float headingA, pitchA, bankA; //angulos para o quaternion A: heading (Y), pitch(X), bank(Z)
  float headingB, pitchB, bankB; //angulos para o quaternion B: heading (Y), pitch(X), bank(Z)
  PVector vectorReferencaA, vectorRotadoA; //O vetor de referenca e aquele que vai ser rotado
  PVector vectorReferencaB, vectorRotadoB; //O vetor de referenca e aquele que vai ser rotado
  PVector vectorRotadoAB; //O vetor resultante da suma dos vetores rotados A e B
  PVector normalCamara;
  
  float diametroModelo; //diametro do desenho do modelo
  public PVector angulosCamaraManual; //angulos que determinan a posicao da camara manualmente
  float distanciaFoco;
  PVector distanciaFocoModoExterno;
  
  ArrayList <PontoCenario> cenarios;
  ArrayList <String> listaCenariosLigados;
  
  PreviewModelo3D(PApplet _p5) {
    p5 = _p5;
    matrixA        = new PMatrix3D();
    matrixB        = new PMatrix3D();
    quatA = new Quaternion();
    quatB = new Quaternion();
    headingA = pitchA = bankA = 0; //angulo inicial 0
    headingB = pitchB = bankB = 0; //angulo inicial 0
    vectorReferencaA = new PVector(0, -1, 0);
    vectorRotadoA = new PVector();
    vectorReferencaB = new PVector(0, 0, -1);
    vectorRotadoB = new PVector();
    angulosCamaraManual = new PVector();
    diametroModelo = 200; //diametro da esfera modelo
    distanciaFoco = 100.0; //O valro que representa o rango de distanca posivel
    
    distanciaFocoModoExterno = new PVector (0, -200, 400); //vector que permite mudar a distancia de foco na cena grl
    cenarios = new ArrayList <PontoCenario>();
    listaCenariosLigados = new ArrayList <String>();
    println("clase PreviewModelo3D criada");
  }
  public void agregaUmCenario( PMatrix3D _matrix, String _nome, PVector angulosPos) {
    
    cenarios.add( new PontoCenario (p5, _matrix, _nome, angulosPos) );
    println("Um cenario agregado na classe PreviewModelo3D. Nome: "+_nome+" posicao: "+angulosPos);
    println("cenarios.size(): " + cenarios.size());
  }
  public void desenhaModelo() { 
//    println("cenarios.size(): " + cenarios.size());
    p5.pushStyle();
//Linhas dos vectores
    p5.stroke(255,200,120);  p5.line(0,0,0, vectorRotadoA.x, vectorRotadoA.y, vectorRotadoA.z);
    p5.stroke(0,255,0);  p5.line(vectorRotadoA.x, vectorRotadoA.y, vectorRotadoA.z, vectorRotadoAB.x, vectorRotadoAB.y, vectorRotadoAB.z);
//    p5.box(diametroModelo);
//Linhas Origem
    p5.stroke(255, 0, 0);    p5.line(-diametroModelo*.5, 0, 0, diametroModelo*.5, 0, 0);
    p5.stroke(0, 255, 0);    p5.line(0, -diametroModelo*.5, 0, 0, diametroModelo*.5, 0);
    p5.stroke(0, 0, 255);    p5.line(0, 0, -diametroModelo*.5, 0, 0, diametroModelo*.5);  
//Esfera
    p5.stroke(255, 120);    p5.noFill();    p5.sphereDetail(15);
    p5.sphere(diametroModelo*.5);
//Desenho dos cenarios
    
    for (PontoCenario pc : cenarios) {
      String n = pc.getNome();
//      println("listaCenariosLigados.contains("+n+"): " + listaCenariosLigados.contains(n));
      
      if (listaCenariosLigados.contains(n)) {
        pc.desenha(diametroModelo, radians(angulosCamaraManual.y));
      } 
    }
//Desenho do ponto do olho
    p5.pushMatrix();
    p5.translate(vectorRotadoA.x, vectorRotadoA.y, vectorRotadoA.z);
    
    p5.noFill(); p5.stroke(0,255,255);
    p5.box(10);
    p5.popMatrix();
    
//ponto centro da imagem
    p5.pushMatrix();
    p5.pushStyle();
    p5.translate(vectorRotadoAB.x, vectorRotadoAB.y, vectorRotadoAB.z);
    matrixB.invert();
    p5.applyMatrix(matrixB);
    p5.noFill(); p5.stroke(255,255,0);
    p5.rectMode(CENTER);
    p5.rect(0,0, 50,20);
    p5.sphere(4);
    p5.popStyle();
    p5.popMatrix();
    
    p5.camera();
    p5.textAlign(CENTER);
    p5.textSize(12);
    p5.text("arraste o mouse para girar o modelo", p5.width/2, p5.height*.9);
    p5.popStyle();
  }
  private void aplicaCamara( int index ){
    matrixA.reset();
    matrixA.rotateZ(bankA);
    matrixA.rotateX(pitchA);
    matrixA.rotateY(headingA);
    quatA.set(matrixA);
    quatA.mult(vectorReferencaA, vectorRotadoA); //vectorReferenca  é um vetor em direcao de +Y, vectorRotado é o vetor resultante dos giros aplicados ao primeiro vector
    vectorRotadoA.setMag(diametroModelo); // para deslocar ponto desde o centro ate a superficie da esfera base
    
    matrixB.reset();
    matrixB.rotateZ(bankB);
    matrixB.rotateX(pitchB);
    matrixB.rotateY(headingB);
    matrixB.apply(matrixA);
    quatB.set(matrixB);
    
    vectorReferencaB = new PVector(0, 0, -1); // O vetor de referencia é criado em cada loop para poder variar a distancia do vetor
    vectorReferencaB.setMag(distanciaFoco); //a variavel distancia é dada desde ModeloGabinete, no PApp3
    quatB.mult(vectorReferencaB, vectorRotadoB);//vectorReferenca  é um vetor em direcao de +Y, vectorRotado é o vetor resultante dos giros aplicados ao primeiro vector     

    vectorRotadoA.setMag(diametroModelo);
    vectorRotadoAB = PVector.add(  vectorRotadoA , vectorRotadoB );
    seleccaoDeCamara(index);
  }
  public void seleccaoDeCamara(int index) {
    switch (index) {
      case 1: 
        PVector normal = new PVector(-vectorRotadoAB.x, -vectorRotadoAB.y, -vectorRotadoAB.z);
        normal.normalize();
        p5.camera(vectorRotadoA.x, vectorRotadoA.y, vectorRotadoA.z,  vectorRotadoAB.x, vectorRotadoAB.y, vectorRotadoAB.z,   normal.x, normal.y, normal.z); 
      break;
      default:
        
        p5.camera(distanciaFocoModoExterno.x, distanciaFocoModoExterno.y, distanciaFocoModoExterno.z,   0, 0, 0,   0, 1, 0); 
        if(p5.mousePressed) {
          angulosCamaraManual.y += p5.mouseX - p5.pmouseX;
 //         angulosCamaraManual.x += p5.mouseY - p5.pmouseY;
        }
        p5.rotateY(radians(angulosCamaraManual.y)); //cambio de angulo
        p5.rotateX(radians(angulosCamaraManual.x)); //cambio de angulo
      break;
    }
  }
  public void ligaCenario(String nomeC) {
    if ( !listaCenariosLigados.contains(nomeC) ) {
       listaCenariosLigados.add(nomeC);
    } 
    
  }
  public void desligaCenario(String nomeC) {
    if ( listaCenariosLigados.contains(nomeC) ) {
       listaCenariosLigados.remove(nomeC);
    } 
  }
  public void zoomIn() {
    float mag = distanciaFocoModoExterno.mag();
    distanciaFocoModoExterno.normalize();
    distanciaFocoModoExterno.setMag(mag * 1.1);
  }
  public void zoomOut() {
    float mag = distanciaFocoModoExterno.mag();
    distanciaFocoModoExterno.normalize();
    distanciaFocoModoExterno.setMag(mag * .9);
  }
  public void novosAngulosVectorA(PVector novosAng) {
    headingA = novosAng.y;
    pitchA = novosAng.x;
    bankA = novosAng.z;
  }
  public void novosAngulosVectorB(PVector novosAng) {
    headingB = novosAng.y;
    pitchB = novosAng.x;
    bankB = novosAng.z;
  }
  public void setDistanciaFoco(float _dist) {   
    distanciaFoco = 200 * _dist;
  }
  public void setAng_X_Puntero(float _ang) {    pitchA = _ang;  }
  public void setAng_Y_Puntero(float _ang){     headingA = _ang;  }
  public void setAng_Z_Puntero(float _ang){     bankA = _ang;  }
  public void setAng_X_Camara(float _ang) {    pitchB = _ang;  }
  public void setAng_Y_Camara(float _ang){     headingB = _ang;  }
  public void setAng_Z_Camara(float _ang){     bankB = _ang;  }
	public ArrayList<String> getListaCenariosLigados() {
		return listaCenariosLigados;
	}  
}

class PontoCenario {
 PApplet p5;
 PMatrix3D matrixCenario;
 String nome;
 PVector angulosCenario;
 
 public PontoCenario(PApplet _p5, PMatrix3D _matrix, String _nome, PVector angulos) {
   p5 = _p5;
   println("novo PontoCenario: " + _nome);
   matrixCenario = _matrix;
   nome = _nome;
   angulosCenario = angulos;
 } 
 public PVector getAngulosCenarios() {
   return angulosCenario;
 }
 public String getNome(){
   return nome; 
 }
 public void desenha(float largo){ 
   p5.pushMatrix();
   p5.pushStyle();
 //  p5.applyMatrix(matrixCenario);
 //println("angulosCenario.x: " + angulosCenario.x);
   p5.rotateX(angulosCenario.x);
   p5.rotateY(angulosCenario.y);
   p5.rotateZ(angulosCenario.z);
   p5.translate(0, -largo, 0);
   p5.box(10);
   p5.stroke(255);
   p5.rotateZ(-angulosCenario.z);
   p5.rotateY(-angulosCenario.y);
   p5.rotateX(-angulosCenario.x);
   p5.textSize(20);
   p5.text(nome, 0,0);
   p5.popMatrix();
   
   p5.popStyle();
 }
 public void desenha(float largo, float angYvar){ //inclui uma variavel para a variação do angulo Y do preview, assim os nomes dos cenarios ficam sempre olhando pra frente 
   p5.pushMatrix();
   p5.pushStyle();
 //  p5.applyMatrix(matrixCenario);
 //println("angulosCenario.x: " + angulosCenario.x);
   p5.rotateX(angulosCenario.x);
   p5.rotateY(angulosCenario.y);
   p5.rotateZ(angulosCenario.z);
   p5.translate(0, -largo, 0);
   p5.box(10);
   p5.stroke(255);
   p5.rotateZ(-angulosCenario.z);
   p5.rotateY(-angulosCenario.y);
   p5.rotateX(-angulosCenario.x);
   p5.rotateY(-angYvar);
   p5.textSize(20);
   p5.text(nome, 0,0);
   p5.popMatrix();
   
   p5.popStyle();
 }

}
