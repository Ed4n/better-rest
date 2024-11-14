//
//  ContentView.swift
//  BetterRest
//
//  Created by Edgardo Valencia on 17/10/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakup = defaultWakeTime
    @State private var sleepAmount = 8.0
    
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    //We add statick to tell swfit that this belong to the struct itlsef, meaning that it can be used in any time without needing to wait something else.
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? .now
    }
    
    
    var body: some View {
        NavigationStack {
            
            
            Form {
                
                
                Section("When do you want to wake up?") {
                    HStack{
                        
                        DatePicker("Time:", selection: $wakup, displayedComponents: .hourAndMinute)
                        
                    }
                }
                
                
                Section("Desired aount of sleep"){
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25 )
                }
                
                Section("Daily coffe intake"){
                    Stepper("^[\(coffeAmount) cup](inflect: true)", value: $coffeAmount, in: 1...10) // This is a way to add plurals if is needed like here "1 cup" "2 cups"
                }
                
                // Conditionally render the Text view only if alertMessage is not empty
                if let bedtimeMessage = bedtimeText {
                    bedtimeMessage
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .listRowBackground(Color.clear)
                }
                
                Button("Calculate", role: .none, action: calculateBedtime )
                    .frame(maxWidth: .infinity)
                
            }
            .navigationTitle("Better Sleep")
            .alert(alertTitle, isPresented: $showingAlert){
                Button("Ok"){}
            }message: {
                Text(alertMessage)
            }
            
            
        }
    }
    
    func calculateBedtime() {
        do {
            let confing = MLModelConfiguration()
            let model = try SleepCalculator(configuration: confing)
            
            let componentes = Calendar.current.dateComponents([.hour, .minute], from: wakup)
            let hour = (componentes.hour ?? 0 ) * 60 * 60
            let minute = (componentes.minute ?? 0) * 60
            // Is done this way becuase we have to extract the hours & minutes by seconds.
            //Also we are using the "??" nil coaliscing beuase it will return an optional
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleepTime = wakup - prediction.actualSleep
            
            alertTitle = "Your ideal Bed Time is:"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch {
            alertTitle = "Error"
            alertMessage = "Srry there was an error"
            
        }
        showingAlert = true
    }
    
    // Computed property for bedtime message
    private var bedtimeText: Text? {
        guard !alertMessage.isEmpty else { return nil }
        return Text("Bed time: ").bold() + Text(alertMessage)
    }
}



#Preview {
    ContentView()
}
