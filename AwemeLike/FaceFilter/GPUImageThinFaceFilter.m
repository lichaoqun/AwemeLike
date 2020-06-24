//
//  GPUImageThinFaceFilter.m
//  AwemeLike
//
//  Created by w22543 on 2019/8/29.
//  Copyright © 2019年 Hytera. All rights reserved.
//

#import "FaceDetector.h"
#import "GPUImageThinFaceFilter.h"

NSString *const kGPUImageThinFaceFragmentShaderString = SHADER_STRING
(
 
 precision highp float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform int hasFace;
 uniform float facePoints[106 * 2];
 
 uniform highp float aspectRatio;
 uniform float thinFaceDelta;
 uniform float bigEyeDelta;
 
 //圓內放大
 vec2 enlargeEye(vec2 textureCoord, vec2 originPosition, float radius, float delta) {
     
    float weight = distance(vec2(textureCoord.x, textureCoord.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio)) / radius;
     
    weight = 1.0 - (1.0 - pow(weight, 2.0)) * delta;
    weight = clamp(weight,0.0,1.0);
    textureCoord = originPosition + (textureCoord - originPosition) * weight;
    return textureCoord;
 }
 
 // 曲线形变处理
 vec2 curveWarp(vec2 textureCoord, vec2 originPosition, vec2 targetPosition, float delta) {
     
     vec2 offset = vec2(0.0);
     vec2 result = vec2(0.0);
     vec2 direction = (targetPosition - originPosition) * delta;
     
     float radius = distance(vec2(targetPosition.x, targetPosition.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio));
     float ratio = distance(vec2(textureCoord.x, textureCoord.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio)) / radius;
     
     ratio = 1.0 - ratio;
     ratio = clamp(ratio, 0.0, 1.0);
     offset = direction * ratio;
     
     result = textureCoord - offset;
     
     return result;
 }
 
 vec2 thinFace(vec2 currentCoordinate) {

    // - 关键点数据 1 组
    int left_face_1 = 3;
    int right_face_1 = 29;
    int norse_1 = 44;
    
    // - 关键点数据 2 组
    int left_face_2 = 7;
    int right_face_2 = 25;
    int norse_2 = 45;
    
    // - 关键点数据 3 组
    int left_face_3 = 10;
    int right_face_3 = 22;
    int norse_3 = 46;
    
    // - 关键点数据 4 组
    int left_face_4 = 14;
    int right_face_4 = 18;
    int bottom_face_4 = 16;
    int norse_4 = 49;

    // - 关键点 1 组的坐标
    vec2 left_face_1_point = vec2(facePoints[left_face_1 * 2], facePoints[left_face_1 * 2 + 1]);
    vec2 right_face_1_point = vec2(facePoints[right_face_1 * 2], facePoints[right_face_1 * 2 + 1]);
    vec2 norse_1_point = vec2(facePoints[norse_1 * 2], facePoints[norse_1 * 2 + 1]);
    
    // - 关键点 2 组的坐标
    vec2 left_face_2_point = vec2(facePoints[left_face_2 * 2], facePoints[left_face_2 * 2 + 1]);
    vec2 right_face_2_point = vec2(facePoints[right_face_2 * 2], facePoints[right_face_2 * 2 + 1]);
    vec2 norse_2_point = vec2(facePoints[norse_2 * 2], facePoints[norse_2 * 2 + 1]);
    
    // - 关键点 3 组的坐标
    vec2 left_face_3_point = vec2(facePoints[left_face_3 * 2], facePoints[left_face_3 * 2 + 1]);
    vec2 right_face_3_point = vec2(facePoints[right_face_3 * 2], facePoints[right_face_3 * 2 + 1]);
    vec2 norse_3_point = vec2(facePoints[norse_3 * 2], facePoints[norse_3 * 2 + 1]);
    
    // - 关键点 4 组的坐标
    vec2 left_face_4_point = vec2(facePoints[left_face_4 * 2], facePoints[left_face_4 * 2 + 1]);
    vec2 right_face_4_point = vec2(facePoints[right_face_4 * 2], facePoints[right_face_4 * 2 + 1]);
    vec2 bottom_face_4_point = vec2(facePoints[bottom_face_4 * 2], facePoints[bottom_face_4 * 2 + 1]);
    vec2 norse_4_point = vec2(facePoints[norse_4 * 2], facePoints[norse_4 * 2 + 1]);
    
    // - 拉伸关键点 1 组
    currentCoordinate = curveWarp(currentCoordinate, left_face_1_point, norse_1_point, thinFaceDelta);
    currentCoordinate = curveWarp(currentCoordinate, right_face_1_point, norse_1_point, thinFaceDelta);

    // - 拉伸关键点 2 组
    currentCoordinate = curveWarp(currentCoordinate, left_face_2_point, norse_2_point, thinFaceDelta);
    currentCoordinate = curveWarp(currentCoordinate, right_face_2_point, norse_2_point, thinFaceDelta);

    // - 拉伸关键点 3 组
    currentCoordinate = curveWarp(currentCoordinate, left_face_3_point, norse_3_point, thinFaceDelta);
    currentCoordinate = curveWarp(currentCoordinate, right_face_3_point, norse_3_point, thinFaceDelta);

    // - 拉伸关键点 4 组
    currentCoordinate = curveWarp(currentCoordinate, left_face_4_point, norse_3_point, thinFaceDelta);
    currentCoordinate = curveWarp(currentCoordinate, right_face_4_point, norse_4_point, thinFaceDelta);
    currentCoordinate = curveWarp(currentCoordinate, bottom_face_4_point, norse_4_point, thinFaceDelta);
    
     return currentCoordinate;
 }
 
 vec2 bigEye(vec2 currentCoordinate) {
    
    // - 眼睛的关键点序号, 左眼 : left_eye_top -> 72 和  left_eye_center -> 74; 右眼 : right_eye_top -> 75 和 right_eye_center -> 77;
    int left_eye_top = 72;
    int left_eye_center = 74;
    int right_eye_top = 75;
    int right_eye_center = 77;
    
    // - left_eye_top 的坐标
    vec2 left_eye_top_point = vec2(facePoints[left_eye_top * 2], facePoints[left_eye_top * 2 + 1]);
    
    // - left_eye_center 的坐标
    vec2 left_eye_center_point = vec2(facePoints[left_eye_center * 2], facePoints[left_eye_center * 2 + 1]);

    // - right_eye_top 的坐标
    vec2 right_eye_top_point = vec2(facePoints[right_eye_top * 2], facePoints[right_eye_top * 2 + 1]);
    
    // - right_eye_center 的坐标
    vec2 right_eye_center_point = vec2(facePoints[right_eye_center * 2], facePoints[right_eye_center * 2 + 1]);
    
    // - 左眼的放大半径
    float left_radius = distance(vec2(left_eye_top_point.x, left_eye_top_point.y / aspectRatio), vec2(left_eye_center_point.x, left_eye_center_point.y / aspectRatio));
    
    // - 右眼的放大的半径
    float right_radius = distance(vec2(right_eye_top_point.x, right_eye_top_point.y / aspectRatio), vec2(right_eye_center_point.x, right_eye_center_point.y / aspectRatio));
    
    // - 扩大半径, 否则大眼的半径就只有眼睛的位置, 应该是眼睛周边都放大一点
    float multiple = 4.5;
    
    // - 使用圆内放大的算法 放大左眼和右眼
    currentCoordinate = enlargeEye(currentCoordinate, left_eye_top_point, left_radius * multiple, bigEyeDelta);
    currentCoordinate = enlargeEye(currentCoordinate, right_eye_top_point, right_radius * multiple, bigEyeDelta);

    return currentCoordinate;
}
 
 void main()
 {
     vec2 positionToUse = textureCoordinate;
     
     if (hasFace == 1) {
         positionToUse = thinFace(positionToUse);
         positionToUse = bigEye(positionToUse);
     }
     
     gl_FragColor = texture2D(inputImageTexture, positionToUse);
     
 }
 );

@implementation GPUImageThinFaceFilter
{
    GLint aspectRatioUniform;
    GLint facePointsUniform;
    GLint thinFaceDeltaUniform;
    GLint bigEyeDeltaUniform;
    GLint hasFaceUniform;
}


- (instancetype)init {
    
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageThinFaceFragmentShaderString]))
    {
        return nil;
    }
    hasFaceUniform = [filterProgram uniformIndex:@"hasFace"];
    aspectRatioUniform = [filterProgram uniformIndex:@"aspectRatio"];
    facePointsUniform = [filterProgram uniformIndex:@"facePoints"];
    thinFaceDeltaUniform = [filterProgram uniformIndex:@"thinFaceDelta"];
    bigEyeDeltaUniform = [filterProgram uniformIndex:@"bigEyeDelta"];
    
    self.thinFaceDelta = 0.05;
    self.bigEyeDelta = 0.15;
    return self;
}

- (void)setUniformWithLandmarks:(NSArray<NSValue *> *)landmarks {
    
    if (!landmarks.count) {
        [self setInteger:0 forUniform:hasFaceUniform program:filterProgram];
        return;
    }
    [self setInteger:1 forUniform:hasFaceUniform program:filterProgram];
    
    CGFloat aspect = inputTextureSize.width / inputTextureSize.height;
    [self setFloat:aspect forUniform:aspectRatioUniform program:filterProgram];
    [self setFloat:self.thinFaceDelta forUniform:thinFaceDeltaUniform program:filterProgram];
    [self setFloat:self.bigEyeDelta forUniform:bigEyeDeltaUniform program:filterProgram];
    
    GLsizei size = 106 * 2;
    GLfloat *facePoints = malloc(size * sizeof(GLfloat));
    
    int index = 0;
    for (NSValue *value in landmarks) {
        CGPoint point = [value CGPointValue];
        *(facePoints + index) = point.x;
        *(facePoints + index + 1) = point.y;
        index += 2;
        
        if (index == size) {
            break;
        }
    }
    [self setFloatArray:facePoints length:size forUniform:facePointsUniform program:filterProgram];
    
    free(facePoints);
    
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    
    NSArray *landmarks = [FaceDetector shareInstance].oneFace.landmarks;
    [self setUniformWithLandmarks:landmarks];
    
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
}

@end
// - 作者对于大眼瘦脸的实现
// vec2 thinFacex(vec2 currentCoordinate) {
//      vec2 faceIndexs[9];
//
//      faceIndexs[0] = vec2(3., 44.);
//      faceIndexs[1] = vec2(29., 44.);
//
//      faceIndexs[2] = vec2(7., 45.);
//      faceIndexs[3] = vec2(25., 45.);
//
//      faceIndexs[4] = vec2(10., 46.);
//      faceIndexs[5] = vec2(22., 46.);
//
//      faceIndexs[6] = vec2(14., 49.);
//      faceIndexs[7] = vec2(18., 49.);
//      faceIndexs[8] = vec2(16., 49.);
//
//     for(int i = 0; i < 9; i++)
//     {
//         int originIndex = int(faceIndexs[i].x);
//         int targetIndex = int(faceIndexs[i].y);
//         vec2 originPoint = vec2(facePoints[originIndex * 2], facePoints[originIndex * 2 + 1]);
//         vec2 targetPoint = vec2(facePoints[targetIndex * 2], facePoints[targetIndex * 2 + 1]);
//         currentCoordinate = curveWarp(currentCoordinate, originPoint, targetPoint, thinFaceDelta);
//     }
//}
//
//vec2 bigEye(vec2 currentCoordinate) {
//
//    vec2 faceIndexs[2];
//    faceIndexs[0] = vec2(74., 72.);
//    faceIndexs[1] = vec2(77., 75.);
//
//    for(int i = 0; i < 2; i++)
//    {
//        int originIndex = int(faceIndexs[i].x);
//        int targetIndex = int(faceIndexs[i].y);
//
//        vec2 originPoint = vec2(facePoints[originIndex * 2], facePoints[originIndex * 2 + 1]);
//        vec2 targetPoint = vec2(facePoints[targetIndex * 2], facePoints[targetIndex * 2 + 1]);
//
//        float radius = distance(vec2(targetPoint.x, targetPoint.y / aspectRatio), vec2(originPoint.x, originPoint.y / aspectRatio));
//        radius = radius * 5.;
//        currentCoordinate = enlargeEye(currentCoordinate, originPoint, radius, bigEyeDelta);
//    }
//    return currentCoordinate;
//}
