import SwiftUI
import Alamofire

struct User: Decodable {
    let name: String
    let email: String
}

struct apitest: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var id: Int = 1;
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
                AF.request(url, method: .get).responseDecodable(of: [String: User].self) { response in
                    switch response.result {
                    case .success(let dictionary):
                        for (_, user) in dictionary {
                            if user.name == self.name && user.email == self.email {
                                print("로그인 성공")
                                return
                            }
                        }
                        print("로그인에 실패하였습니다.")
                    case .failure(let error):
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
            case .success(let dictionary):
                for(_, user) in dictionary {
                    if user.name == self.name && user.email == self.email {
                        print("이미 등록된 사용자입니다.")
                        return
                    }
                }
                let parameters: [String: Any] = ["name": name,"email": email,"id":(id += 1)]
                print(parameters)
                AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .response{ response in
                        debugPrint(response)
                    }
            case .failure(let error):
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
