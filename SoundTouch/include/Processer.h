//
//  Processer.h
//  SoundStretch
//
//  Created by myx on 2021/9/23.
//

#import <Foundation/Foundation.h>

/// 变声的类，导入此 SDK 需要在 Link Binary with Libraries 中添加 libc++.tbd

@interface Processer : NSObject

- (instancetype)init NS_UNAVAILABLE;


/*
 // Sets new rate control value as a difference in percents compared
 // to the original rate (-50 .. +100 %)
 void SoundTouch::setRateChange(double newRate)
 {
     virtualRate = 1.0 + 0.01 * newRate;
     calcEffectiveRateAndTempo();
 }
 **/

/*
 // Sets new tempo control value as a difference in percents compared
 // to the original tempo (-50 .. +100 %)
 void SoundTouch::setTempoChange(double newTempo)
 {
     virtualTempo = 1.0 + 0.01 * newTempo;
     calcEffectiveRateAndTempo();
 }
 **/

/**
 // Sets pitch change in semi-tones compared to the original pitch
 // (-12 .. +12)
 void SoundTouch::setPitchSemiTones(int newPitch)
 {
     setPitchOctaves((double)newPitch / 12.0);
 }

 */

/// 初始化
/// @param tc 节奏控制值，默认值为1，在默认基础上可变区间为 (-50 .. +100 %)，一般不用改
/// @param pst 半高音声调，设置与原始音高相比，以半音为单位的音调变化 (-12 .. +12)
/// @param rc 速率控制值，默认值为1，在默认基础上可变区间为 (-50 .. +100 %)
- (instancetype)initWithTempoChange:(double)tc
                     pitchSemiTones:(int)pst
                         rateChange:(double)rc;


/// 转换 wav 格式音频
/// @param input 待处理文件 path
/// @param output 处理后新文件 path
/// @param progress 已处理的字节数 bytes
/// @param completion 已处理完成
/// @param occurError 出现错误
- (void)convert:(NSString *)input
         output:(NSString *)output
       progress:(void(^)(double))progress
     completion:(void(^)(void))completion
     occurError:(void(^)(NSError *))occurError;

@end
