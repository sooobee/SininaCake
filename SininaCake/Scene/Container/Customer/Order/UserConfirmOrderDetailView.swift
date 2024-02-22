//
//  UserConfirmOrderDetailView.swift
//  SininaCake
//
//  Created by 이종원 on 2/18/24.
//

import SwiftUI
import PhotosUI

struct UserConfirmOrderDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var orderVM: OrderViewModel
    @ObservedObject var photoVM: PhotoPickerViewModel
    @State private var showNavManager = false
    
    var statusTitle: (String, UIColor, String) {
        switch orderVM.orderItem.status {
        case .assign:
            return ("승인 주문건 현황", .customBlue, "VectorTrue")
        case .notAssign:
            return ("미승인 주문건 현황", .customGray, "VectorFalse")
        case .complete:
            return ("완료 주문건 현황", .black, "VectorTrue")
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Image(statusTitle.2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(Color(statusTitle.1))
                    CustomText(title: statusTitle.0, textColor: .black, textWeight: .semibold, textSize: 18)
                    Spacer()
                }
                .padding(.leading, 24)
                .padding(.top, 40)
                
                Spacer()
                    .frame(height: 42)
                
                OrderInfoView(orderItem: $orderVM.orderItem)
                
                DividerView()
                
                CakeInfoView(orderItem: $orderVM.orderItem)
                
                Spacer()
                    .frame(height: 18)
                
//                PhotoView(orderItem: $orderItem, orderDetailVM: orderDetailVM)
                DetailPhotoView(orderItem: $orderVM.orderItem, photoVM: photoVM)
                
                Spacer()
                    .frame(height: 32)
                
                EtcView(orderItem: $orderVM.orderItem)
                
                DividerView()
                
                DetailPriceView(orderItem: $orderVM.orderItem)
                
                Spacer()
                    .frame(height: 18)
                
                CustomButton(action: {
                    orderVM.addOrderItem()
                    showNavManager = true
                }, title: "주문서 보내기", titleColor: .white, backgroundColor: .customBlue, leading: 12, trailing: 12)
                .fullScreenCover(isPresented: $showNavManager) {
                    ContainerView()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("주문현황")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                    Image("angle-left")
                        .foregroundStyle(Color.black)
                })
            }
        }
    }
}

struct DetailPriceView: View {
    @Binding var orderItem: OrderItem
    
    var priceText: (String, String) {
        switch orderItem.status {
        case .notAssign:
            return ("총 예상금액", intToString(orderItem.expectedPrice))
        case .assign, .complete:
            return ("총 확정금액", intToString(orderItem.confirmedPrice))
        }
    }
    
    var body: some View {
        HStack {
            CustomText(title: priceText.0, textColor: .customDarkGray, textWeight: .semibold, textSize: 16)
            Spacer()
                .frame(width: 45)
            CustomText(title: priceText.1, textColor: .black, textWeight: .semibold, textSize: 16)
            Spacer()
        }
        .padding(.leading, 24)
        .padding(.trailing, 24)
    }
}

struct DetailPhotoView: View {
    @Binding var orderItem: OrderItem
    @ObservedObject var photoVM: PhotoPickerViewModel
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    let imageWidth = (UIScreen.main.bounds.width - 60) / 2
    
    var body: some View {
        VStack {
            HStack {
                CustomText(title: "사진", textColor: .customDarkGray, textWeight: .semibold, textSize: 16)
                Spacer()
            }
            
            Spacer()
                .frame(height: 24)
            
            LazyVGrid(columns: columns) {
                if photoVM.selectedImages.isEmpty {
                    ForEach(0...1, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.customGray))
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(.clear)
                            .overlay(
                                Image("emptyPhoto")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .scaledToFit()
                            )
                    }
                } else {
                    ForEach(photoVM.selectedImages, id: \.self) { image in
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.customGray))
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(.clear)
                            .overlay(
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imageWidth, height: imageWidth)
                                    .cornerRadius(12)
                            )
                    }
                    
                    if orderItem.imageURL.count % 2 == 1 {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.customGray))
                            .frame(width: imageWidth, height: imageWidth)
                            .foregroundStyle(.clear)
                            .overlay(
                                Image("emptyPhoto")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .scaledToFit()
                            )
                    }
                }
            }
        }
        .padding(.leading, 24)
        .padding(.trailing, 24)
    }
}

// MARK: - Convert Method
private func intToString(_ price: Int) -> String {
    let priceString = String(price)
    var result = ""
    var count = 0
    
    for str in priceString.reversed() {
        result += String(str)
        count += 1
        if count % 3 == 0 && count != priceString.count {
            result += ","
        }
    }
    
    return result.reversed() + "원"
}

// TODO:OrderViewModel 전달해서 여기서 주문 DB에 저장


//#Preview {
//    UserConfirmOrderDetailView(orderVM: )
//}