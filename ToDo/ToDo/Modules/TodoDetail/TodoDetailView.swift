//
//  TodoDetailView.swift
//  ToDo
//
//  Created by DISSEMBILL on 20.05.2025.
//

import Foundation
import SwiftUI

struct TodoDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var presenter: TodoDetailPresenter
    
    @State private var title = ""
    @State private var description = ""
    
    var backButton : some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Назад")
        }
    }
    
    var body: some View {
        VStack {
            TextField("Название", text: $title)
                .font(.title)
                .foregroundColor(.black)
                .padding(16)
            
            ZStack(alignment: .leading) {
                VStack {
                    Text("Описание (не обязательно)")
                        .foregroundColor(.gray)
                        .opacity(description.count == 0 ? 1 : 0)
                        .padding(6)
                    Spacer()
                }
                TextEditor(text: $description)
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .scrollContentBackground(.hidden)
                    .padding(0)
            }
            .padding(12)
            
            Button("Сохранить") {
                presenter.didSaveTodo(title: title, description: description.isEmpty ? nil : description)
                self.presentationMode.wrappedValue.dismiss()
            }
            .opacity(title.count == 0 ? 0 : 1)
            
            Spacer()
        }
        .navigationBarTitle(presenter.isEditing ? "Редактировать" : "Новая задача", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            presenter.viewDidLoad()
            title = presenter.todo?.title ?? ""
            description = presenter.todo?.description ?? ""
        }
    }
}
