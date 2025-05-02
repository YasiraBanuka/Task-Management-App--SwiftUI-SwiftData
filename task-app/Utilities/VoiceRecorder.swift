//
//  VoiceRecorder.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-05-02.
//

import Foundation
import AVFoundation
import Speech

class VoiceRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var recordingURL: URL?
    @Published var transcribedText: String?
    
    private var audioRecorder: AVAudioRecorder?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override init() {
        super.init()
        requestPermissions()
    }
    
    func requestPermissions() {
        // Request microphone permissions
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if !granted {
                    print("Microphone permission denied")
                }
            }
        }
        
        // Request speech recognition permissions
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    print("Speech recognition permission denied")
                }
            }
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // Create a unique filename for the recording
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            recordingURL = audioFilename
            isRecording = true
            
            // Start speech recognition
            startSpeechRecognition()
            
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        // Stop speech recognition
        recognitionRequest?.endAudio()
    }
    
    // MARK: - Speech Recognition
    
    private func startSpeechRecognition() {
        // Make sure we have a URL
        guard let url = recordingURL else { return }
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let audioEngine = AVAudioEngine()
        
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create a speech recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        do {
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }
            
        } catch {
            print("Speech recognition failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}
