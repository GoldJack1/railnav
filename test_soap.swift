import Foundation

let baseURL = "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/ldb12.asmx"
let url = URL(string: baseURL)!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("text/xml;charset=UTF-8", forHTTPHeaderField: "Content-Type")
request.setValue("\"http://thalesgroup.com/RTTI/2012-01-13/ldb/GetServiceDetails\"", forHTTPHeaderField: "SOAPAction")
request.setValue("gzip,deflate", forHTTPHeaderField: "Accept-Encoding")
request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
request.setValue("Apache-HttpClient/4.5.5 (Java/17.0.12)", forHTTPHeaderField: "User-Agent")

let soapBody = """
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://thalesgroup.com/RTTI/2013-11-28/Token/types" xmlns:ldb="http://thalesgroup.com/RTTI/2021-11-01/ldb/">
   <soapenv:Header>
      <typ:AccessToken>
         <typ:TokenValue>c487598e-7f29-4a7c-bd18-5f867de9c0b6</typ:TokenValue>
      </typ:AccessToken>
   </soapenv:Header>
   <soapenv:Body>
      <ldb:GetServiceDetailsRequest>
         <ldb:serviceID>419386DWBY____</ldb:serviceID>
      </ldb:GetServiceDetailsRequest>
   </soapenv:Body>
</soapenv:Envelope>
"""

request.httpBody = soapBody.data(using: .utf8)

print("🚂 === Request Details ===")
print("URL: \(request.url?.absoluteString ?? "nil")")
print("\nHeaders:")
request.allHTTPHeaderFields?.forEach { key, value in
    print("\(key): \(value)")
}
print("\nRequest Body:")
print(soapBody)

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
        print("Error: \(error)")
        return
    }
    
    if let httpResponse = response as? HTTPURLResponse {
        print("\n🚂 === Response Details ===")
        print("Status code: \(httpResponse.statusCode)")
        print("\nResponse Headers:")
        for (key, value) in httpResponse.allHeaderFields {
            print("\(key): \(value)")
        }
    }
    
    if let data = data, let responseString = String(data: data, encoding: .utf8) {
        print("\nResponse Body:")
        print(responseString)
    }
}

task.resume()

// Keep the program running until the request completes
RunLoop.main.run(until: Date(timeIntervalSinceNow: 10)) 