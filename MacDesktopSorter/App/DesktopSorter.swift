import AppKit
import Foundation

enum SortCriterion: String, CaseIterable, Identifiable { case creationDate, modificationDate, name, kind, size; var id: String { rawValue }; var title: String { switch self { case .creationDate: "Fecha de creación"; case .modificationDate: "Fecha de modificación"; case .name: "Nombre"; case .kind: "Tipo"; case .size: "Tamaño" } } }
enum DesktopProfile { case recent, work, archive; var value: (SortCriterion, Bool, Bool) { switch self { case .recent: (.creationDate, true, false); case .work: (.modificationDate, true, true); case .archive: (.creationDate, false, true) } } }

@MainActor final class DesktopSorter: ObservableObject {
    @Published private(set) var isWorking = false
    @Published var statusMessage: String?
    @Published var criterion: SortCriterion { didSet { UserDefaults.standard.set(criterion.rawValue, forKey: "criterion") } }
    @Published var foldersFirst: Bool { didSet { UserDefaults.standard.set(foldersFirst, forKey: "foldersFirst") } }
    init() { criterion = SortCriterion(rawValue: UserDefaults.standard.string(forKey: "criterion") ?? "") ?? .creationDate; foldersFirst = UserDefaults.standard.bool(forKey: "foldersFirst") }
    func setCriterion(_ value: SortCriterion) { criterion = value }
    func applyProfile(_ profile: DesktopProfile) { let value = profile.value; criterion = value.0; foldersFirst = value.2; sort(descending: value.1) }
    func toggleOrder() { sort(descending: !UserDefaults.standard.bool(forKey: "descending")) }
    func sort(descending: Bool) {
        guard !isWorking else { return }; isWorking = true; statusMessage = nil
        let selected = criterion; let folders = foldersFirst
        DispatchQueue.global(qos: .userInitiated).async {
            let result = FinderScriptRunner.sortDesktop(criterion: selected, descending: descending, foldersFirst: folders)
            DispatchQueue.main.async { self.isWorking = false; switch result { case .success(let count): UserDefaults.standard.set(descending, forKey: "descending"); self.statusMessage = "\(count) iconos ordenados por \(selected.title.lowercased())."; case .failure(let error): self.fail(error) } }
        }
    }
    private func fail(_ error: SortError) { statusMessage = error.localizedDescription; let alert = NSAlert(); alert.alertStyle = .warning; alert.messageText = "No se pudo ordenar el Escritorio"; alert.informativeText = error.localizedDescription ?? ""; alert.addButton(withTitle: "Aceptar"); alert.runModal() }
}
