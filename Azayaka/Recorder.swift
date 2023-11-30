//
//  AudioRecorder.swift
//  audioenginetest
//
//  Created by Daniel Lee on 11/29/23.
//

import Foundation
import AVFoundation

class AudioRecorder{
    fileprivate var audioFile: AVAudioFile! = nil
    fileprivate var audioEngine: AVAudioEngine!
    fileprivate let mixerNode = AVAudioMixerNode()
    fileprivate let playerNode = AVAudioPlayerNode()
    fileprivate let bus = 0
    
 
    private func getAudioFile(audioFormat: AVAudioFormat)->AVAudioFile {
//        let audioSettings: [String : Any] = [
//            AVFormatIDKey: kAudioFormatMPEG4AAC,
//            AVSampleRateKey: 16000,
//            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
//        ]
        
        let userDesktop = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd HH.mm.ss"
        let filePathUrl = URL(string: "\(userDesktop)/test.caf")!
        let audioFile = try! AVAudioFile(forWriting: filePathUrl, settings: audioEngine.inputNode.outputFormat(forBus: bus).settings)
        return audioFile
    }
    
    init(){
        configureAudioEngine()
    }
    
    private func addAudio(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
        // Add the audio to the current match request.
        do{
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))!
            try  audioFile.write(from: audioBuffer)
        }catch{
            debugPrint(error)
        }
    }
    
    private func configureAudioEngine() {
        audioEngine = AVAudioEngine()
        // Get the native audio format of the engine's input bus.
        let format = audioEngine.inputNode.inputFormat(forBus: 0)
        
        // Create a mixer node to convert the input.
        audioEngine.attach(mixerNode)
        
        
        // Attach the mixer to the microphone input and the output of the audio engine.
        audioEngine.connect(audioEngine.inputNode, to: mixerNode, format: format)
//        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: format)
//        playerNode.volume = 0

        
        // Install a tap on the mixer node to capture the microphone audio.
        let file = getAudioFile(audioFormat: audioEngine.outputNode.outputFormat(forBus: bus))
        mixerNode.installTap(onBus: bus,
                             bufferSize: 1024,
                             format: format) {buffer, audioTime in
            // Add captured audio to the buffer used for making a match.
            
//            self?.addAudio(buffer: buffer, audioTime: audioTime)
            try! file.write(from: buffer)
        }
        
//        try! setupInputNode()
        audioEngine.prepare()
    }
    
    private func setupInputNode() throws {
        // Throw an error if the audio engine is already running.
        let inputNode = audioEngine.inputNode
        
        inputNode.installTap(onBus: bus, bufferSize: 2048, format: inputNode.inputFormat(forBus: bus)) {
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            
            let theLength = Int(buffer.frameLength)
            print("theLength = \(theLength)")
            
            var samplesAsDoubles:[Double] = []
            for i in 0 ..< Int(buffer.frameLength)
            {
                let theSample = Double((buffer.floatChannelData?.pointee[i])!)
                samplesAsDoubles.append( theSample )
            }
            
            print("samplesAsDoubles.count = \(samplesAsDoubles.count)")
            
        }
    }
    
    
    //MARK: - Public interface
    func stopRecording()
    {
        audioFile = nil
        let inputNode = audioEngine.inputNode
        mixerNode.removeTap(onBus: bus)
        inputNode.removeTap(onBus: bus)
        audioEngine.stop()

    }
    
    
    func newRecording() throws{
//        audioFile = getAudioFile(audioFormat: audioEngine.outputNode.outputFormat(forBus: bus))
        configureAudioEngine()
        do{
            
            try audioEngine.start()
        }catch{
            debugPrint(error)
        }
        
    }
}


