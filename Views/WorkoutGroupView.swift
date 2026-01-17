import SwiftUI

struct WorkoutGroupView: View {
    let group: TrainingGroup
    @StateObject private var viewModel = ExerciseListViewModel()
    @StateObject private var groupViewModel = TrainingGroupViewModel()
    @ObservedObject var settingsService = SettingsService.shared
    @State private var expandedExerciseId: UUID?
    
    var body: some View {
        ZStack {
            Color(hex: "81ecec")
                .ignoresSafeArea()
            
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
}
