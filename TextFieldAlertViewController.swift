//
//  TextFieldAlertViewController.swift
//  Make Soap
//
//  Created by Galina Aleksandrova on 23/05/22.
//

import SwiftUI
import Combine

class TextFieldAlertViewController: UIViewController {
    
    //lifecycle
    internal init(title: String, message: String, recipeName: Binding<String>?, isPresented: Binding<Bool>? = nil, subscription: AnyCancellable? = nil, saveAction: @escaping (String) -> Void) {
        self.alertTitle = title
        self.message = message
        self.recipeName = recipeName
        self.isPresented = isPresented
        self.saveAction = saveAction
        super.init(nibName: nil, bundle: nil)
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let alertTitle: String
    let message: String
    var recipeName: Binding<String>?
    var isPresented: Binding<Bool>?
    var subscription: AnyCancellable?
    var saveAction: (String) -> Void
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAlertController()
    }
    
    func presentAlertController() {
        guard subscription == nil else { return }
        let ac = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        
        ac.addTextField()
        ac.textFields![0].placeholder = "Enter soap recipe name"
        ac.view.tintColor = UIColor(red: 75/255, green: 122/255, blue: 113/255, alpha: 1)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.isPresented?.wrappedValue = false
        }
        
        let saveAlertAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            self?.saveAction(ac.textFields![0].text ?? "No name")
            self?.isPresented?.wrappedValue = false
        }
        
        ac.addAction(cancelAction)
        ac.addAction(saveAlertAction)
        present(ac, animated: true, completion: nil)
    }
    
}

struct TextFieldAlert: UIViewControllerRepresentable {
    
    let title: String
    let message: String?
    var isPresented: Binding<Bool>? = nil
    let recipeName: Binding<String>?
    var saveAction: (String) -> Void
    
    typealias UIViewControllerType = TextFieldAlertViewController
    
    func dismissable(_ isPresented: Binding<Bool>) -> TextFieldAlert {
        TextFieldAlert(title: title, message: message, isPresented: isPresented, recipeName: recipeName, saveAction: saveAction)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TextFieldAlert>) -> UIViewControllerType {
        TextFieldAlertViewController(title: title, message: message ?? "", recipeName: recipeName, isPresented: isPresented, saveAction: saveAction)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<TextFieldAlert>) {
        //nothing
    }
}

struct TextFieldWrapper<PresentingView: View>: View {
    @Binding var isPresented: Bool
    
    let presentingView: PresentingView
    let content: () -> TextFieldAlert
    
    var body: some View {
        ZStack {
            if isPresented {
                content()
                    .dismissable($isPresented)
            }
            
            presentingView
        }
    }
}

extension View {
    func textFieldAlert(isPresented: Binding<Bool>, content: @escaping () -> TextFieldAlert) -> some View {
        TextFieldWrapper(isPresented: isPresented, presentingView: self, content: content)
    }
}
