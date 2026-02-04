import SwiftUI

struct MyKaomojiView: View {
    @State private var registered: [RegisteredKaomoji] = []
    @State private var editingEntry: RegisteredKaomoji?

    private let storage = KaomojiStorage.shared

    var body: some View {
        Group {
            if registered.isEmpty {
                VStack(spacing: 16) {
                    Text("(　´・ω・｀)")
                        .font(.system(size: 40))
                    Text("工房で顔文字を作って登録しよう！")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(registered) { entry in
                        HStack(spacing: 12) {
                            Text(entry.kaomoji)
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button { editingEntry = entry } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)

                            Button { deleteEntry(entry) } label: {
                                Image(systemName: "trash.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
                .listStyle(.plain)
                .toolbar {
                    EditButton()
                }
            }
        }
        .onAppear { reload() }
        .sheet(item: $editingEntry) { entry in
            NavigationStack {
                WorkshopView(editingEntry: entry) {
                    editingEntry = nil
                    reload()
                }
                .navigationTitle("編集")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("キャンセル") { editingEntry = nil }
                    }
                }
            }
        }
    }

    private func reload() {
        registered = storage.getRegistered()
    }

    private func deleteEntry(_ entry: RegisteredKaomoji) {
        storage.removeRegistered(entry.id)
        reload()
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            storage.removeRegistered(registered[index].id)
        }
        reload()
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        var items = registered
        items.move(fromOffsets: source, toOffset: destination)
        storage.reorderRegistered(items.map(\.id))
        reload()
    }
}
