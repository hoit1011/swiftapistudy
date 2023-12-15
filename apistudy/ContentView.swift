import SwiftUI
import SwiftyJSON
import Alamofire

struct User: Decodable {
    let name: String
    let email: String
}

struct apitest: View {
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        VStack(spacing: 10){
            TextField("이름을 입력해주세요", text: $name)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
            TextField("이메일을 입력해주세요", text: $email)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
            Button(action: {
                signup { result in
                    switch result {
                    case .success(let result):
                        print("Fetched data: \(result)")
                    case .failure(let error):
                        print("Error fetching data: \(error.localizedDescription)")
                    }
                }
            }, label: {
                Text("회원가입")
            })
            Button(action: {
                let url = "https://dailynote-e0942-default-rtdb.firebaseio.com/users.json"
                // Alamofire를 사용하여 Firebase로부터 데이터를 가져옴
                // responseDecodable 메서드를 사용하여 반환된 JSON 데이터를 User 모델에 디코딩
                AF.request(url, method: .get).responseDecodable(of: [String: User].self) { response in
                    switch response.result {
                    case .success(let dictionary):
                        // 디코딩에 성공하면 디코딩된 데이터를 사용
                        // dictionary의 모든 요소에 대해 반복
                        for (_, user) in dictionary {
                            // 반환된 name과 email이 입력된 name과 email과 일치하는지 확인
                            if user.name == self.name && user.email == self.email {
                                // 일치하면 로그인 성공 메시지 출력
                                print("로그인 성공")
                                return
                            }
                        }
                        // 일치하는 사용자가 없으면 로그인 실패 메시지 출력
                        print("로그인에 실패하였습니다.")
                    case .failure(let error):
                        // 디코딩이 실패하면 오류 메시지 출력
                        print("Failed to get users: \(error)")
                    }
                }
            }) {
                Text("Log in")
            }
        }
    }
    
    func signup(completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://dailynote-e0942-default-rtdb.firebaseio.com/users.json"
        AF.request(url, method: .get).responseDecodable(of: [String: User].self) { response in
            switch response.result {
                // 요청이 성공했을 경우
            case .success(let dictionary):
                // 가져온 사용자 정보를 반복하여 확인합니다.
                for(_, user) in dictionary {
                    // 입력한 이름과 이메일이 이미 존재하는 사용자의 것과 일치하는지 확인합니다.
                    if user.name == self.name && user.email == self.email {
                        // 일치하는 사용자가 있으면 이미 등록된 사용자라는 메시지를 출력하고 종료합니다.
                        print("이미 등록된 사용자입니다.")
                        return
                    }
                }
                // 일치하는 사용자가 없으면 해당 이름과 이메일로 새 사용자를 등록합니다.
                let parameters: [String: Any] = ["name": name,"email": email]
                print(parameters)
                AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .response{ response in
                        // 새 사용자 등록 요청의 결과를 출력합니다.
                        debugPrint(response)
                    }
                // 요청이 실패했을 경우
            case .failure(let error):
                // 에러 메시지를 출력합니다.
                completion(.failure(error))
            }
        }
    }
}

struct apitest_Previews: PreviewProvider {
    static var previews: some View {
        apitest()
    }
}
