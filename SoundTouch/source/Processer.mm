//
//  Processer.m
//  SoundStretch
//
//  Created by myx on 2021/9/23.
//

#import "Processer.h"
#import "SoundTouch.h"
#import "WavFile.h"
#import "stdio.h"

using namespace soundtouch;
using namespace std;

// Processing chunk size (size chosen to be divisible by 2, 4, 6, 8, 10, 12, 14, 16 channels ...)
#define BUFF_SIZE           6720

@interface Processer ()
{
    SoundTouch *mSoundTouch;
}
@end

@implementation Processer

- (instancetype)initWithTempoChange:(double)tc
                     pitchSemiTones:(int)pst
                         rateChange:(double)rc
{
    self = [super init];
    if (self) {
        mSoundTouch = new SoundTouch;
        
        mSoundTouch->setTempoChange(tc);
        mSoundTouch->setPitchSemiTones(pst);
        mSoundTouch->setRateChange(rc);
        
        mSoundTouch->setSetting(SETTING_SEQUENCE_MS, 40);
        mSoundTouch->setSetting(SETTING_USE_AA_FILTER, 1);
    }
    return self;
}

- (void)dealloc {
    delete mSoundTouch;
}

static void openFile(const char *inPath,
                     const char *outPath,
                     WavInFile **inFile,
                     WavOutFile **outFile)
{
    *inFile = new WavInFile(inPath);
    
    int bits, sampleRate, channels;
    bits = (int)(*inFile)->getNumBits();
    sampleRate = (int)(*inFile)->getSampleRate();
    channels = (int)(*inFile)->getNumChannels();
    
    *outFile = new WavOutFile(outPath, sampleRate, bits, channels);
}

- (void)process:(WavInFile *)inFile outFile:(WavOutFile *)outFile progress:(void(^)(double))progress
{
    int nSamples;
    int nChannels;
    int buffSizeSamples;
    SAMPLETYPE sampleBuffer[BUFF_SIZE];
    
    if (inFile == nil || outFile == nil) {
        return;
    }
    
    nChannels = inFile->getNumChannels();
    assert(nChannels > 0);
    buffSizeSamples = BUFF_SIZE / nChannels;
    
    uint processedBytes = 0;
    uint multiplierFactor = nChannels * 2;
    
    // Process samples read from the input file
    while (inFile->eof() == 0)
    {
        int num;
        
        // Read a chunk of samples from the input file
        num = inFile->read(sampleBuffer, BUFF_SIZE);
        nSamples = num / (int)inFile->getNumChannels();
        
        // Feed the samples into SoundTouch processor
        mSoundTouch->putSamples(sampleBuffer, nSamples);
        
        // Read ready samples from SoundTouch processor & write them output file.
        // NOTES:
        // - 'receiveSamples' doesn't necessarily return any samples at all
        //   during some rounds!
        // - On the other hand, during some round 'receiveSamples' may have more
        //   ready samples than would fit into 'sampleBuffer', and for this reason
        //   the 'receiveSamples' call is iterated for as many times as it
        //   outputs samples.
        do
        {
            nSamples = mSoundTouch->receiveSamples(sampleBuffer, buffSizeSamples);
            outFile->write(sampleBuffer, nSamples * nChannels);
            processedBytes += nSamples * multiplierFactor;
        } while (nSamples != 0);
        
        progress(processedBytes);
    }
    
    // Now the input file is processed, yet 'flush' few last samples that are
    // hiding in the SoundTouch's internal processing pipeline.
    mSoundTouch->flush();
    do
    {
        nSamples = mSoundTouch->receiveSamples(sampleBuffer, buffSizeSamples);
        outFile->write(sampleBuffer, nSamples * nChannels);
        processedBytes += nSamples * multiplierFactor;
    } while (nSamples != 0);
    
    progress(processedBytes);
}

- (void)convert:(NSString *)input output:(NSString *)output progress:(void (^)(double))progress completion:(void (^)())completion occurError:(void (^)(NSError *))occurError
{
    WavInFile *inFile;
    WavOutFile *outFile;
    
    try {
        openFile([input UTF8String], [output UTF8String], &inFile, &outFile);
        
        mSoundTouch->setSampleRate(inFile->getSampleRate());
        mSoundTouch->setChannels(inFile->getNumChannels());
        
        [self process:inFile outFile:outFile progress:progress];

        delete inFile;
        delete outFile;
        
        completion();
        
    } catch (const runtime_error &e) {
        NSString *message = [[NSString alloc] initWithUTF8String:e.what()];
        NSError *error = [[NSError alloc] initWithDomain:@"com.sound.touch" code:-9930 userInfo:@{@"e.what": message}];
        occurError(error);
    }
}

@end
