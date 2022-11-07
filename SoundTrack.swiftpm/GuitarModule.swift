//
//  File.swift
//  Sound
//
//  Created by 唐烁 on 2022/4/22.
//

import Foundation
import AudioUnit
import AVFoundation
import SwiftUI

class GuitarModule: NSObject{
    var speed = 80
    var frameRate = 44100.0
    
    var auAudioUnit: AUAudioUnit! = nil     // 声音输出单元
       
    var avActive     = false             // AVAudioSession 是否活跃
    var audioRunning = false             // 声音输出单元是否运行
    
    var v0 = 32767
    
    var assistant = 0 //遍历位置
    
    var guitarSoundData:[Int16] = []
    
    func getGuitarModule() -> [Double]{
        var x = Array(stride(from: 0, to: 3 * Double.pi, by: 3 * Double.pi / Double((2 * Int(Int(frameRate) * 60/speed)))))
        var y :[Double] = []
        for i in x {
            let temp = 1 - i / (10 * Double.pi) + (1 - i / (6 * Double.pi)) * sin(i) * 0.5
            y.append(temp)
        }
        x = Array(stride(from: 0, to: Double(6*Int(Int(frameRate)*60/speed)), by: 1))
        for i in x {
            y.append(0.7*exp(-(i/Double(Int(Int(frameRate)*60/speed)))))
        }
        return y
    }
    
    func getFrequency(pos:String) -> Double{
        let fs = [329.6, 246.9, 196.0, 146.8, 110.0, 82.4]
        let i = (pos as NSString).intValue
        print(i)
        if(i >= 100){
            if pos.first == "0"{
                return 0
            }
            else{
                return fs[(Int(i) / 100) % 10 - 1] * pow(2,Double((i % 100)) / 12)
            }
        }
        else{
            if pos.first == "0"{
                return 0
            }
            else{
                return fs[(Int(i) / 10) % 10 - 1] * pow(2,Double((i % 10)) / 12)
            }
        }
    }
    
    func guitarEffect(soundData:[Double]) -> [Double]{
        var result:[Double] = []
        let guitarModule = getGuitarModule()
        for i in 0..<soundData.count{
            result.append(soundData[i] * guitarModule[i])
        }
        return result
    }
    
    func getWave(beat:Double, frequecy:Double) -> [Double]{
        var result:[Double] = []
        var temp:[[Double]] = []
        let duration = Double(beat) * 60 / Double(speed)
        let sampleNum = Double(duration) * Double(frameRate)
        var minLength = Int.max
        let ps = [0.4,0.3,0.2,0.1]
        var ks = [1,2,3,4]
        for (p,k) in zip(ps,ks){
            let delta = 2 * Double(duration) * Double(frequecy) * Double(k) * Double.pi / Double(sampleNum)
            var x:[Double] = []
            if(frequecy == 0){
                x = [Double](repeating: 0, count: Int(sampleNum) + 1)
            }
            else{
                x = Array(stride(from: 0, to: 2 * Double(duration) * frequecy * Double(k) * Double.pi, by: delta))
            }
            var ys:[Double] = []
            for i in x{
                var y = sin(i) * p
                ys.append(y)
            }
            if(ys.count < minLength){
                minLength = ys.count
            }
            temp.append(ys)
        }
        for i in 0..<minLength{
            result.append(temp[0][i] + temp[1][i] + temp[2][i] + temp[3][i])
        }
        
        return guitarEffect(soundData: result)
    }
    
    func play(melody:[[[(String,Double)]]]){
        var orginData : [Double] = []
        for section in melody{
            var sectionData:[[Double]] = []
            for cords in section{
                var cordData:[Double] = []
                cords.forEach { pos ,beat in
                    let frequency = getFrequency(pos: pos)
                    let dw = getWave(beat: beat, frequecy: frequency)
                    print(frequency)
                    cordData.append(contentsOf: dw)
                }
                sectionData.append(cordData)
            }
            var d = sectionData[0]
            for i in 1..<sectionData.count{
                if(d.count > sectionData[i].count){
                    for j in 0..<sectionData[i].count{
                        d[j] += sectionData[i][j]
                    }
                }
                else{
                    for j in 0..<d.count{
                        sectionData[i][j] += d[j]
                    }
                    d = sectionData[i]
                }
            }
            orginData.append(contentsOf: d)
            
        }
        var data:[Int16] = []
        var max = 0.0
        for i in orginData{
            if i > max{
                max = i
            }
        }
        for i in orginData{
            var temp = Int16(i * 20000 / max)
            guitarSoundData.append(temp)
        }
        print(guitarSoundData.count)
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
                commonFormat: AVAudioCommonFormat.pcmFormatInt16,   // 设置量化精度
                sampleRate: frameRate,    // 设置采样评率
                   channels:AVAudioChannelCount(1), //设置声道为单声道
                   interleaved: true )                                 // interleaved stereo
               
               try bus0.setFormat(audioFormat ?? AVAudioFormat())  //      for speaker bus
               auAudioUnit.outputProvider = { (    //  AURenderPullInputBlock?
                   actionFlags,
                   timestamp,
                   frameCount,
                   inputBusNumber,
                   inputDataList ) -> AUAudioUnitStatus in
                   self.fillOutputBuffer(inputDataList: inputDataList, frameCount: frameCount)
                   return(0)
               }
           }
           auAudioUnit.isOutputEnabled = true
           try auAudioUnit.allocateRenderResources()  //  v2 AudioUnitInitialize()
           try auAudioUnit.startHardware()            //  v2 AudioOutputUnitStart()
           audioRunning = true
       } catch /* let error as NSError */ {
           print("error 2 \(error)")
       }
   }
    
    private func fillOutputBuffer(     // process RemoteIO Buffer for output
        inputDataList : UnsafeMutablePointer<AudioBufferList>, frameCount : UInt32 ) {
            
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let nBuffers = inputDataPtr.count

        if (nBuffers > 0) {
            let mBuffers : AudioBuffer = inputDataPtr[0]
            let count = Int(frameCount)
            // Speaker Output == play tone at frequency f0
            if (self.v0 > 0) && (self.assistant < self.guitarSoundData.count )
            {
                // audioStalled = false
                var v  = self.v0 ; if v > 32767 { v = 32767 }
                let sz = Int(mBuffers.mDataByteSize)
                var g = self.assistant
                let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
                if var bptr = bufferPointer {
                    for i in 0..<(count) {
                        var cur = self.guitarSoundData.last
                        if(g >= self.guitarSoundData.count){
                            cur = self.guitarSoundData.last
                        }
                        else{
                            cur = self.guitarSoundData[g]
                        }
                        g += 1
                        if (i < (sz / 2)) {
                            bptr.assumingMemoryBound(to: Int16.self).pointee = cur!
                            bptr += 2   // increment by 2 bytes for next Int16 item
                        }
                    }
                }
                self.assistant = g
            } else {
                memset(mBuffers.mData, 0, Int(mBuffers.mDataByteSize))  // silence
            }
        }
    }
    
    
    
    
    
}
