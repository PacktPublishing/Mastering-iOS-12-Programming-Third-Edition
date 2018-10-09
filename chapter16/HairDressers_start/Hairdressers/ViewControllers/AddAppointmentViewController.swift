import UIKit
import CoreData

class AddAppointmentViewController: UIViewController {
  var viewContext: NSManagedObjectContext {
    return PersistentHelper.shared.persistentContainer.viewContext
  }
  
  let hairdressers = HairdressersDataSource.hairdressers
  let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  
  @IBOutlet var dateField: UITextField!
  @IBOutlet var hairdresserField: UITextField!
  
  var pickedDay: String?
  var pickedHairdresser: String?
  
  let dayPicker = UIPickerView()
  let hairdresserPicker = UIPickerView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateField.inputView = dayPicker
    hairdresserField.inputView = hairdresserPicker
    
    hairdresserPicker.delegate = self
    hairdresserPicker.dataSource = self

    dayPicker.delegate = self
    dayPicker.dataSource = self
  }
  
  @IBAction func didTapSave() {
    guard let day = pickedDay, let hairdresser = pickedHairdresser
      else { return }

    viewContext.persist { [unowned self] in
      let appointment = Appointment(context: self.viewContext)
      appointment.day = day
      appointment.hairdresser = hairdresser
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func didTapCancel() {
    dismiss(animated: true, completion: nil)
  }
}

extension AddAppointmentViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == hairdresserPicker {
      return hairdressers.count
    } else {
      return days.count
    }
  }
}

extension AddAppointmentViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView == hairdresserPicker {
      return hairdressers[row]
    } else {
      return days[row]
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView == hairdresserPicker {
      pickedHairdresser = hairdressers[row]
      hairdresserField.text = pickedHairdresser
    } else {
      pickedDay = days[row]
      dateField.text = pickedDay
    }
  }
}

