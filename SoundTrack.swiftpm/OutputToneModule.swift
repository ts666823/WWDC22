//
//  File.swift
//  Sound
//
//  Created by 唐烁 on 2022/4/22.
//

import Foundation
import AudioUnit
import AVFoundation

class OutputToneModule: NSObject{
    var auAudioUnit: AUAudioUnit! = nil     // 声音输出单元
       
    var avActive     = false             // AVAudioSession 是否活跃
    var audioRunning = false             // 声音输出单元是否运行
       
    var sampleRate : Double = 44100  // 采样频率
    
    var channels : Int = 1          //声道数量
       
    var f0  =    880.0              // 默认频率   'A' above Concert A
    var v0  =  16383.0              // 音调的默认频率:      half full scale
    
    var toneCount : Int32 = 0       // 音调的样本数  0 for silence
    
    var soundTime :Double = 0.0
       
    private var phY = 0.0       // 正弦波波形图 save phase of sine wave to prevent clicking
    private var interrupted = false     // 音频中断重启提示
    
    private var curPos : Int32 = 0 //当前所处的位置
    
    private var y:[Int16] = []
    private var x:Double = 0
    
    private var assistant:Double = 0
    
    private var pos = 0
       
    func setFrequency(freq : Double) {  // ⚠️频率低于500可能难以听到
        f0 = freq
    }
       
    func setToneVolume(vol : Double) {  // 从0到1
        v0 = vol * 32766.0
    }
       
    func setToneTime(t : Double) { // 样本数
        soundTime = t
        toneCount = Int32(t * sampleRate);
    }
       
    func enableSpeaker() {
        if audioRunning {
            print("returned")
            return
        }           // 正在运行就保持运行
        do {        // 不在运行则启动
            let audioComponentDescription = AudioComponentDescription(
                componentType: kAudioUnitType_Output,
                componentSubType: kAudioUnitSubType_RemoteIO, //kAudioUnitSubType_SystemOutput For output to the local sound system
                componentManufacturer: kAudioUnitManufacturer_Apple,
                componentFlags: 0,
                componentFlagsMask: 0 )
               
            if (auAudioUnit == nil) {
                
                auAudioUnit = try AUAudioUnit(componentDescription: audioComponentDescription)
                
                let bus0 = auAudioUnit.inputBusses[0]
                let audioFormat = AVAudioFormat(
                    commonFormat: AVAudioCommonFormat.pcmFormatInt16,   // Int16
                    sampleRate: Double(sampleRate),    // SampeRate
                    channels:AVAudioChannelCount(1), //Single Channel
                    interleaved: false )                                 // interleaved stereo
               
               try bus0.setFormat(audioFormat ?? AVAudioFormat())  //      for speaker bus
               auAudioUnit.outputProvider = { (    //  AURenderPullInputBlock?
                   actionFlags,
                   timestamp,
                   frameCount,
                   inputBusNumber,
                   inputDataList ) -> AUAudioUnitStatus in
                   self.fillSpeakerBuffer(inputDataList: inputDataList, frameCount: frameCount)
                   return(0)
               }
           }
                       
           auAudioUnit.isOutputEnabled = true
           toneCount = 0
           try auAudioUnit.allocateRenderResources()  //  v2 AudioUnitInitialize()
           try auAudioUnit.startHardware()            //  v2 AudioOutputUnitStart()
           audioRunning = true
       } catch /* let error as NSError */ {
           print("error 2 \(error)")
       }
   }
    
   // helper functions
    // 每固定帧数个取样点
   private func fillSpeakerBuffer(     // process RemoteIO Buffer for output
       inputDataList : UnsafeMutablePointer<AudioBufferList>, frameCount : UInt32 ) {
           
       let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
       let nBuffers = inputDataPtr.count

       if (nBuffers > 0) {
           let mBuffers : AudioBuffer = inputDataPtr[0]
           let count = Int(frameCount)
           
           
           // Speaker Output == play tone at frequency f0
           if (  self.v0 > 0)
               && (self.toneCount > 0 )
           {
               // audioStalled = false
               
               var v  = self.v0 ; if v > 32767 { v = 32767 }
               let sz = Int(mBuffers.mDataByteSize)
               
               var a  = self.phY        // last phase
               let d  = 2.0 * Double.pi * self.f0 / self.sampleRate     // delta
               
               let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
               if var bptr = bufferPointer {
                   for i in 0..<(count) {
                       let u  = sin(a)             // create a sinewave
                       a += d ; if (a > 2.0 * Double.pi) { a -= 2.0 * Double.pi }
                       let x = Int16(v * u + 0.5)      // scale & round
                       
                       if (i < (sz / 2)) {
                           bptr.assumingMemoryBound(to: Int16.self).pointee = x
                           bptr += 2   // increment by 2 bytes for next Int16 item
                       }
                   }
               }
               
               self.phY        =   a                   // save sinewave phase
               self.toneCount  -=  Int32(frameCount)   // decrement time remaining
           } else {
               // audioStalled = true
               memset(mBuffers.mData, 0, Int(mBuffers.mDataByteSize))  // silence
           }
       }
   }
    
    // 每固定帧数个取样点
    // 声音频率 * 持续时间 得到周期数目 周期数目 * 2 pi 就是x的范围
    // 在上诉范围内取toneCount个点 toneCount = 采样频率 * 持续时间
    // Int16 : 32767到-32768
    // TODO 优化内存，不用那么大的连续空间
    func caculateWave(){
        let delta = f0 * 2 * Double.pi * soundTime / Double(toneCount)
        for _ in 0...toneCount {
            y.append(Int16(sin(x) * 32767))
            x += delta
        }
        print(y)
    }
    
    private func fillOutputBuffer(     // process RemoteIO Buffer for output
        inputDataList : UnsafeMutablePointer<AudioBufferList>, frameCount : UInt32 ) {
            
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let nBuffers = inputDataPtr.count

        if (nBuffers > 0) {
            let mBuffers : AudioBuffer = inputDataPtr[0]
            let count = Int(frameCount)
            // Speaker Output == play tone at frequency f0
            if (  self.v0 > 0)
                && (self.pos < self.toneCount )
            {
                // audioStalled = false
                var v  = self.v0 ; if v > 32767 { v = 32767 }
                let sz = Int(mBuffers.mDataByteSize)
                let delta = f0 * 2 * Double.pi * soundTime / Double(toneCount)
                let deltaG = 3 * Double.pi / Double(toneCount / 3)
                var a  = self.x
                var g = self.assistant
                let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
                if var bptr = bufferPointer {
                    for i in 0..<(count) {
                        let before:Double = 1 - g / (10 * Double.pi) + (1 - g / (6 * Double.pi)) * sin(g) * 0.5
                        let after:Double = 0.7 * exp(-a)
                        var cur = Int16(sin(a) * 32767)
                        print(cur)
                        print(before)
                        print(Double(cur) * before)
                        if(a < 44100){
                            cur = Int16(before * Double(cur) * 0.8)
                        }
                        else{
                            cur = Int16(after * Double(cur))
                        }
                        a += delta
                        g += deltaG
                    
                        if (i < (sz / 2)) {
                            bptr.assumingMemoryBound(to: Int16.self).pointee = cur
                            bptr += 2   // increment by 2 bytes for next Int16 item
                            bptr.assumingMemoryBound(to: Int16.self).pointee = cur
                            bptr += 2   // stereo, so fill both Left & Right channels
                        }
                    }
                }
                
                self.x = a
                self.pos += Int(frameCount)
            
            } else {
                // audioStalled = true
                memset(mBuffers.mData, 0, Int(mBuffers.mDataByteSize))  // silence
            }
        }
    }
    
    
    // Guitar Effect Array 将等幅sinx波转换为吉他波形
    // let before = 1 - a / (10 * Double.pi) + (1 - a / (6 * Double.pi)) * sin(a) * 0.5
    // let after = 0.7 * exp(-a)
    
   
   
   
   func stop() {
       if (audioRunning) {
           auAudioUnit.stopHardware()
           audioRunning = false
       }
   }
}
