precision highp float;

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

uniform float uTime;

const float base = 200.0;
const float TRI = 0.333333;



void main() {
/*     lowp vec4 sum = vec4(0.0);

    vec2 singleStepOffset = vec2(0, -1);
    vec2 pos = textureCoordinate + singleStepOffset * GetAmplitude(uTime);
    if(pos.y < 0.0) {
        pos.y = 1.0 - fract(-pos.y); 
    }
    if(pos.y > 1.0) {
        pos.y = fract(pos.y);
    } */

    vec2 pos = textureCoordinate;
    if(textureCoordinate.y <= TRI){
        pos.y = TRI + pos.y;
    }
    if(textureCoordinate.y > TRI + TRI){
        pos.y = - TRI + pos.y;
    }

    gl_FragColor = texture2D(inputImageTexture, pos);

}
