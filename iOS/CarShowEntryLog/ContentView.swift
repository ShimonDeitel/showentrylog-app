import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ShowEntryStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: ShowEntry? = nil
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                ShowEntryTheme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            row(for: item)
                        }
                        .listRowBackground(ShowEntryTheme.card)
                        .accessibilityIdentifier("row_\(item.name)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Car Show Entry Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ShowEntryFormView(mode: .add) { new in
                    if !store.add(new) {
                        showingPaywall = true
                    }
                }
            }
            .sheet(item: $editingItem) { item in
                ShowEntryFormView(mode: .edit(item)) { updated in
                    store.update(updated)
                } onDelete: {
                    store.delete(id: item.id)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(ShowEntryTheme.accent)
    }

    @ViewBuilder
    private func row(for item: ShowEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(ShowEntryTheme.bodyFont)
                .foregroundColor(ShowEntryTheme.textPrimary)
            Text(item.detail)
                .font(ShowEntryTheme.captionFont)
                .foregroundColor(ShowEntryTheme.textSecondary)
            Text(item.date, style: .date)
                .font(ShowEntryTheme.captionFont)
                .foregroundColor(ShowEntryTheme.accent)
        }
        .padding(.vertical, 4)
    }
}

enum ShowEntryFormMode {
    case add
    case edit(ShowEntry)
}

struct ShowEntryFormView: View {
    let mode: ShowEntryFormMode
    var onSave: (ShowEntry) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var detail: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Show name") {
                    TextField("Show name", text: $name)
                        .accessibilityIdentifier("nameField")
                }
                Section("Category") {
                    TextField("Category", text: $detail)
                        .accessibilityIdentifier("detailField")
                }
                Section("Entry date") {
                    DatePicker("Entry date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("dateField")
                }
                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .accessibilityIdentifier("noteField")
                }
                if case .edit = mode, let onDelete {
                    Section {
                        Button("Delete", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear(perform: populate)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func populate() {
        if case .edit(let item) = mode {
            name = item.name
            detail = item.detail
            date = item.date
            note = item.note
        }
    }

    private func save() {
        var item: ShowEntry
        if case .edit(let existing) = mode {
            item = existing
        } else {
            item = ShowEntry(name: name, detail: detail, date: date)
        }
        item.name = name
        item.detail = detail
        item.date = date
        item.note = note
        onSave(item)
        dismiss()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(ShowEntryStore())
        .environmentObject(PurchaseManager())
}
