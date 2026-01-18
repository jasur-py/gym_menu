import SwiftUI
import Combine
import UserNotifications

struct WorkoutGroupView: View {
    let group: TrainingGroup
    @StateObject private var viewModel = ExerciseListViewModel()
    @StateObject private var groupViewModel = TrainingGroupViewModel()
    @ObservedObject var settingsService = SettingsService.shared
    @State private var expandedExerciseId: UUID?
    @ObservedObject private var timerStore = WorkoutTimerStore.shared
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    group.color.opacity(0.85),
                    group.color.opacity(0.7),
                    group.color.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.12)
                    .ignoresSafeArea()
            )
            
            VStack(spacing: 12) {
                List {
                    ForEach(viewModel.filteredExercises) { exercise in
                        ExerciseRowView(
                            exercise: exercise,
                            isExpanded: expandedExerciseId == exercise.id,
                            groupViewModel: groupViewModel,
                            onToggleExpand: {
                                withAnimation {
                                    if expandedExerciseId == exercise.id {
                                        expandedExerciseId = nil
                                    } else {
                                        expandedExerciseId = exercise.id
                                    }
                                }
                            },
                            onUpdateExercise: { updatedExercise in
                                viewModel.updateExercise(updatedExercise)
                            },
                            settingsService: settingsService,
                            onDelete: { exerciseToDelete in
                                viewModel.deleteExercise(exerciseToDelete)
                                if expandedExerciseId == exerciseToDelete.id {
                                    expandedExerciseId = nil
                                }
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteExercise(exercise)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteExercise)
                    .onMove(perform: viewModel.moveExercise)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                
                workoutTimerCard
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.groupViewModel = groupViewModel
            viewModel.selectedGroupId = group.id
            
            for groupItem in groupViewModel.groups {
                if groupItem.exerciseOrder.isEmpty {
                    groupViewModel.initializeExerciseOrder(for: groupItem, with: viewModel.exercises)
                }
            }
        }
    }
    
    private var workoutTimerCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                
                Text("Workout Timer")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(formattedTime(timerStore.elapsedSeconds))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button(action: {
                    timerStore.toggleWorkout()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: timerStore.workoutIsRunning ? "pause.fill" : "play.fill")
                        Text(timerStore.workoutIsRunning ? "Pause" : "Start")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    timerStore.resetWorkout()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .overlay(Color.white.opacity(0.2))
            
            HStack(spacing: 10) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
                
                Text("Rest Timer")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(formattedTime(timerStore.restRemainingSeconds))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                restPresetButton(title: "1 min", seconds: 60)
                restPresetButton(title: "3 min", seconds: 180)
                restPresetButton(title: "5 min", seconds: 300)
                
                Button(action: {
                    timerStore.stopRest()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "636e72"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.25)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
    }
    
    private func restPresetButton(title: String, seconds: Int) -> some View {
        Button(action: {
            timerStore.startRest(seconds: seconds)
        }) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
        }
        .buttonStyle(.plain)
    }
    
    private func formattedTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

final class WorkoutTimerStore: ObservableObject {
    static let shared = WorkoutTimerStore()
    private let settingsService = SettingsService.shared
    
    @Published var elapsedSeconds: Int = 0
    @Published var workoutIsRunning: Bool = false
    @Published var restRemainingSeconds: Int = 0
    @Published var restIsRunning: Bool = false
    
    private var timer: Timer?
    
    private init() {}
    
    func toggleWorkout() {
        workoutIsRunning ? stopWorkout() : startWorkout()
    }
    
    func startWorkout() {
        workoutIsRunning = true
        startTimerIfNeeded()
    }
    
    func stopWorkout() {
        workoutIsRunning = false
        stopTimerIfPossible()
    }
    
    func resetWorkout() {
        stopWorkout()
        elapsedSeconds = 0
        sendNotificationIfEnabled(
            title: "Workout Complete",
            body: "Your workout timer was stopped."
        )
    }
    
    func startRest(seconds: Int) {
        restRemainingSeconds = seconds
        restIsRunning = true
        startTimerIfNeeded()
    }
    
    func stopRest() {
        restIsRunning = false
        restRemainingSeconds = 0
        stopTimerIfPossible()
    }
    
    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func stopTimerIfPossible() {
        guard !workoutIsRunning && !restIsRunning else { return }
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        if workoutIsRunning {
            elapsedSeconds += 1
        }
        if restIsRunning {
            restRemainingSeconds = max(0, restRemainingSeconds - 1)
            if restRemainingSeconds == 0 {
                restIsRunning = false
                sendNotificationIfEnabled(
                    title: "Rest Complete",
                    body: "Your rest timer is done."
                )
            }
        }
        stopTimerIfPossible()
    }
    
    private func sendNotificationIfEnabled(title: String, body: String) {
        guard settingsService.isNotificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
