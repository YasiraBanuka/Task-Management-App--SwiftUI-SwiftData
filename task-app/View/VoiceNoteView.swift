//
//  VoiceNoteView.swift
//  task-app
//
//  Created by Yasira Banuka on 2025-05-02.
//

import SwiftUI
import AVFoundation

// Audio player manager class to handle delegation
class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    var onPlaybackFinished: (() -> Void)?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onPlaybackFinished?()
    }
}

struct VoiceNoteView: View {
    @Bindable var task: Task
    @StateObject private var voiceRecorder = VoiceRecorder()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var audioPlayerManager = AudioPlayerManager()
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Voice Note")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    // Save changes and dismiss
                    if let path = voiceRecorder.recordingURL?.lastPathComponent {
                        task.voiceNotePath = path
                        task.voiceNoteText = voiceRecorder.transcribedText
                        try? context.save()
                    }
                    dismiss()
                } label: {
                    Text("Save")
                        .fontWeight(.medium)
                        .foregroundColor(.darkBlue)
                }
            }
            .padding(.horizontal)
            
            // Task title
            Text(task.taskTitle)
                .font(.headline)
                .padding(.top, 10)
            
            Spacer()
            
            // Recording status
            if voiceRecorder.isRecording {
                Text("Recording...")
                    .foregroundColor(.red)
                    .font(.title3)
                
                // Audio waveform visualization (simple version)
                HStack(spacing: 4) {
                    ForEach(0..<15) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: 3, height: CGFloat.random(in: 10...50))
                            .foregroundColor(.red)
                            .animation(.easeInOut(duration: 0.2).repeatForever(), value: voiceRecorder.isRecording)
                    }
                }
                .padding()
            } else if let text = voiceRecorder.transcribedText, !text.isEmpty {
                VStack(alignment: .leading) {
                    Text("Transcription:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Text(text)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
            } else if task.voiceNotePath != nil {
                if let text = task.voiceNoteText, !text.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Transcription:")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Text(text)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                // Show playback controls if we have a recording
                HStack(spacing: 30) {
                    Button {
                        if isPlaying {
                            audioPlayer?.stop()
                            isPlaying = false
                        } else {
                            playRecording()
                        }
                    } label: {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        // Delete recording
                        deleteRecording()
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.red.opacity(0.15))
                            .foregroundColor(.red)
                            .clipShape(Circle())
                    }
                }
                .padding()
            } else {
                Text("Tap to record a voice note")
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Recording button
            Button {
                if voiceRecorder.isRecording {
                    voiceRecorder.stopRecording()
                } else {
                    voiceRecorder.startRecording()
                }
            } label: {
                Image(systemName: voiceRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .foregroundColor(voiceRecorder.isRecording ? .red : .darkBlue)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    )
            }
            .padding(.bottom, 30)
        }
        .onAppear {
            // If there's an existing recording, prepare the player
            if let path = task.voiceNotePath {
                preparePlayer(withPath: path)
            }
        }
        .onDisappear {
            // Clean up
            audioPlayer?.stop()
        }
    }
    
    private func preparePlayer(withPath path: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsPath.appendingPathComponent(path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            // Set up delegate through the manager class
            audioPlayerManager.onPlaybackFinished = {
                isPlaying = false
            }
            audioPlayer?.delegate = audioPlayerManager
        } catch {
            print("Failed to load audio file: \(error.localizedDescription)")
        }
    }
    
    private func playRecording() {
        if let player = audioPlayer {
            player.play()
            isPlaying = true
        } else if let path = task.voiceNotePath {
            preparePlayer(withPath: path)
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    private func deleteRecording() {
        // Stop playback if it's playing
        audioPlayer?.stop()
        isPlaying = false
        
        // Delete the file
        if let path = task.voiceNotePath {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documentsPath.appendingPathComponent(path)
            
            do {
                try FileManager.default.removeItem(at: url)
                task.voiceNotePath = nil
                task.voiceNoteText = nil
                try? context.save()
            } catch {
                print("Failed to delete recording: \(error.localizedDescription)")
            }
        }
    }
}

// AVAudioPlayerDelegate extension
//extension VoiceNoteView: AVAudioPlayerDelegate {
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        isPlaying = false
//    }
//}
