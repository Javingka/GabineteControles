// ============================================================
// Classe Quaternion
// ============================================================
class Quaternion {
  public double w, x, y, z;
   
  // ----------------------------------------------------------
  // Constructor
  // ----------------------------------------------------------
  public Quaternion() {
    set(1, 0, 0, 0);  // Quatérnion Unidade da parte imaginária de zero
  }
  public Quaternion(double x, double y, double z) {
    set(0, x, y, z);
  }
  public Quaternion(double w, double x, double y, double z) {
    set(w, x, y, z);
  } 
  public Quaternion(final PVector p) {
    set(p);
  }
  public Quaternion(final PMatrix3D mat) {
    set(mat);
  }
  public Quaternion(final Quaternion q) {
    set(q);
  }
   
  // ----------------------------------------------------------
  // setter
  // ----------------------------------------------------------
  public Quaternion set(double w, double x, double y, double z) {
    this.w = w; 
    this.x = x;
    this.y = y;
    this.z = z;
     
    return this;
  }
  public Quaternion set(final PVector p) {
    this.w = 0;
    this.x = p.x;
    this.y = p.y;
    this.z = p.z;
     
    return this;
  } 
  public Quaternion set(final PMatrix3D mat) {
    double fourWSquaredMinus1 = mat.m00 + mat.m11 + mat.m22;
    double fourXSquaredMinus1 = mat.m00 - mat.m11 - mat.m22;
    double fourYSquaredMinus1 = mat.m11 - mat.m00 - mat.m22;
    double fourZSquaredMinus1 = mat.m22 - mat.m00 - mat.m11;
     
    int    biggestIndex = 0;
    double fourBiggestSquaredMinus1 = fourWSquaredMinus1;
    if(fourXSquaredMinus1 > fourBiggestSquaredMinus1) {
      fourBiggestSquaredMinus1 = fourXSquaredMinus1;
      biggestIndex = 1;
    }
    if(fourYSquaredMinus1 > fourBiggestSquaredMinus1) {
      fourBiggestSquaredMinus1 = fourYSquaredMinus1;
      biggestIndex = 2;
    }
    if(fourZSquaredMinus1 > fourBiggestSquaredMinus1) {
      fourBiggestSquaredMinus1 = fourZSquaredMinus1;
      biggestIndex = 3;
    }
     
    // Quero calcular a divisão e raiz quadrada
    double biggestVal = Math.sqrt(fourBiggestSquaredMinus1 + 1.0) * 0.5;
    double mult = 0.25 / biggestVal;
     
    // Eu quero calcular o valor do Quatérnion
    switch (biggestIndex) {
      case 0:
        w = biggestVal;
        x = -(mat.m12 - mat.m21) * mult;
        y = -(mat.m20 - mat.m02) * mult;
        z = -(mat.m01 - mat.m10) * mult;
        break;
      case 1:
        x = biggestVal;
        w = -(mat.m12 - mat.m21) * mult;
        y = (mat.m01 + mat.m10) * mult;
        z = (mat.m20 + mat.m02) * mult;
        break;
      case 2:
        y = biggestVal;
        w = -(mat.m20 - mat.m02) * mult;
        x = (mat.m01 + mat.m10) * mult;
        z = (mat.m12 + mat.m21) * mult;
        break;
      case 3:
        z = biggestVal;
        w = -(mat.m01 - mat.m10) * mult;
        x = (mat.m20 + mat.m02) * mult;
        y = (mat.m12 + mat.m21) * mult;
        break;
    }
    return this;
  }
  public Quaternion set(Quaternion q) {
    return set(q.w, q.x, q.y, q.z);
  }
   
   
  // ----------------------------------------------------------
  // É multiplicado a partir do Quatérnion esquerdo dado e retornar o resultado mais
  //
  // ※ Em outras palavras, torna-se (Q1) = q1 * q0 q0.preApply
  // Não é intuitivo, mas eu fiz de acordo com as especificações do pmatrix
  // ----------------------------------------------------------
  //
  // argumento
  // ----------------------------------------------------------
  //   left : Fator deixou de produto cruzado
  //
  // O valor de retorno
  // ----------------------------------------------------------
  //   produtos Cruz
  public Quaternion preApply(final Quaternion left) {
    double newW = left.w * w - left.x * x - left.y * y - left.z * z;
    double newX = left.w * x + left.x * w + left.z * y - left.y * z;
    double newY = left.w * y + left.y * w + left.x * z - left.z * x;
    double newZ = left.w * z + left.z * w + left.y * x - left.x * y;
     
    return set(newW, newX, newY, newZ);
  }
   
   
  // ----------------------------------------------------------
  // Quaternions individuais, eu retornar o resultado mais escalar dada
  // ----------------------------------------------------------
  //
  // argumento
  // ----------------------------------------------------------
  //   scalar : Número de dividir o Quatérnion
  //
  // O valor de retorno
  // ----------------------------------------------------------
  //  Resultado da divisão do escalar quaternion dada
  public Quaternion div(double scalar) {
    w /= scalar;
    x /= scalar;
    y /= scalar;
    z /= scalar;
     
    return this;
  }
   
   
  // ----------------------------------------------------------
  // Aplicar el cuaternión a un vector dado, se somete a rotación
  //
  // argumento
  // ----------------------------------------------------------
  //   src : vector inicial
  //   dst : Guarde el resultado
  //
  // valor de retorno
  // ----------------------------------------------------------
  // Ninguno
  public void mult(final PVector src, PVector dst) {
    Quaternion q = new Quaternion(this);
    Quaternion p = new Quaternion(src);
    Quaternion r = new Quaternion(this);
    r.invert().preApply(p.preApply(q));
    dst.set((float)r.x, (float)r.y, (float)r.z);
  }
   
   
  // ----------------------------------------------------------
  // Calcule o Kyoyaku q * do q Quatérnion, e retorna o resultado 
  // Conjugacao do Quaternion
  // ----------------------------------------------------------
  //
  // argumento
  // ----------------------------------------------------------
  //   Nenhum
  //
  // valor de retorno
  // ----------------------------------------------------------
  //   Quaternion Kyoyaku // Quaterinon conjugado
  public Quaternion conjugate() {
    return set(w, -x, -y, -z);
  }
   
 
  // ----------------------------------------------------------
  // Eu procuro o valor absoluto do Quatérnion
  //
  // O valor de retorno
  // ----------------------------------------------------------
  //   |q| = √(w^2 + x^2 + y^2 + z^2)
  // ----------------------------------------------------------
  public double mag() {
    return Math.sqrt(w * w + x * x + y * y + z * z);
  }
   
 
  // ----------------------------------------------------------
  // Eu quero normalizar o Quatérnion
  //
  // O valor de retorno
  // ----------------------------------------------------------
  //   q / |q|
  public Quaternion normalize() {
    double mag = mag();
    div(mag);
    return this;
  }
   
   
  // ----------------------------------------------------------
  // Acho que o inverso da Quatérnion
  //
  // O valor de retorno
  // ----------------------------------------------------------
  //   q^-1 = q* / |q|
  // ----------------------------------------------------------
  public Quaternion invert() {
    double mag = mag();
    conjugate();
    div(mag);
    return this;
  }
   
   
  // ----------------------------------------------------------
  // Recebo a matriz de rotação correspondente à Quatérnion
  // ----------------------------------------------------------
  public PMatrix3D getMatrix() {
    PMatrix3D mat = new PMatrix3D();
    mat.m00 = (float)(1 - 2 * y * y - 2 * z * z);
    mat.m10 = (float)(2 * x * y - 2 * w * z);
    mat.m20 = (float)(2 * x * z + 2 * w * y);
     
    mat.m01 = (float)(2 * x * y + 2 * w * z);
    mat.m11 = (float)(1 - 2 * x * x - 2 * z * z);
    mat.m21 = (float)(2 * y * z - 2 * w * x);
     
    mat.m02 = (float)(2 * x * z - 2 * w * y);
    mat.m12 = (float)(2 * y * z + 2 * w * x);   
    mat.m22 = (float)(1 - 2 * x * x - 2 * y * y);
     
    return mat;
  }
}
 
 
// ============================================================
// Interpolação linear esférica
// ============================================================
 
// Quaternion q0 ~ q1 I suavemente interpolação entre o
//
// argumento
// ------------------------------------------------------------
//   q0 : estado Inicial
//   q1 : estado final
//   t  : (Na gama de [0-1]) fracção
//
//  O valor de retorno
// ------------------------------------------------------------
//   Quatérnion na direcção de interpolação
Quaternion slerp(Quaternion q0, final Quaternion q1, double t) {
  Quaternion dst = new Quaternion();
  slerp(q0, q1, t, dst);
  return dst;
}
 
// Quaternion q0 ~ q1 I suavemente interpolação entre o
//
// argumento
// ------------------------------------------------------------
//   q0 : estado Inicial
//   q1 : estado final
//   t  : (Na gama de [0-1]) fracção
//   dst : Armazene o resultado
//
// O valor de retorno
// ------------------------------------------------------------
//  Nenhum
void slerp(Quaternion q0, final Quaternion q1, double t, Quaternion dst) {
   
  double cosOmega = q0.w * q1.w + q0.x * q1.x + q0.y * q1.y + q0.z * q1.z;
   
  // Produto interno é negativo, invertendo o sinal da Quatérnion uma entrada, e tomar o arco mais curto
  if(cosOmega < 0.0) {
    q0.w = -q0.w;
    q0.x = -q0.x;
    q0.y = -q0.y;
    q0.z = -q0.z;
  }
   
  // A fim de impedir a divisão por 0, verifica-se se ou não o próximo conjunto
  double k0, k1;
  if(cosOmega > 0.9999) {
    // Se eu fechar, para executar uma interpolação linear simples
    k0 = 1.0 - t;
    k1 = t;
  } else {
    // Triângulo equação seção sin ^ 2 (ômega) + cos ^ 2 (omega) = 1
    // Usando para calcular o seno do ângulo
    double sinOmega = Math.sqrt(1.0 - cosOmega * cosOmega);
     
    // Eu calcular o ângulo do seno e cosseno
    double omega = Math.atan2(sinOmega, cosOmega);
     
    // Para evitar se apenas uma divisão, para calcular o recíproco do denominador 
    double oneOverSinOmega = 1.0 / sinOmega;
     
    // Para calcular o parâmetro de interpolaçãos
    k0 = Math.sin((1.0 - t) * omega) * oneOverSinOmega;
    k1 = Math.sin(t * omega) * oneOverSinOmega;
  }
   
  dst.w = q0.w * k0 + q1.w * k1;
  dst.x = q0.x * k0 + q1.x * k1;
  dst.y = q0.y * k0 + q1.y * k1;
  dst.z = q0.z * k0 + q1.z * k1;
  dst.normalize();
}
