# SoundTouchWrapper
变声库的改造


## 使用

### Swift
在 Demo-Bridging-Header.h 中 `#import "Processer.h"`，然后

```
        let src = Bundle.main.url(forResource: "in", withExtension: "wav")
        let dst = lib.appendingPathComponent("new_test").appendingPathExtension("wav")
        
        guard
            let src = src,
            let processer = Processer(
                tempoChange: 0, pitchSemiTones: -2, rateChange: 0)
        else {
            return
        }
        
        let totalBytes = src.path.getFileSize()
        var processedPercent: UInt64 = 0
        processer.convert(src.path, output: dst.path) { progress in
            let ratio = Double(progress) / Double(totalBytes)
            let percent: UInt64 = UInt64(ratio * 100 / 1)
            if processedPercent < percent {
                print("处理进度: \(percent)%")
                processedPercent = percent
            }
        } completion: {
            print("已完成")
        } occurError: { err in
            print("出错了: \(String(describing: err?.localizedDescription))")
        }
```
