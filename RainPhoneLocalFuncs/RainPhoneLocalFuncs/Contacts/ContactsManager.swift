//
//  ContactsManager.swift
//  NewChama
//
//  Created by ncm on 2017/2/23.
//  Copyright © 2017年 com.NewChama. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import Contacts



/// 获取通讯录权限和联系人的Manager
class ContactsManager: NSObject {
    
    private var sourceArr = [ImportAddressBookModel]()
    
    private var importArr = [ImportAddressBookModel]()
    
    static var ShareManager:ContactsManager{
//        struct Static{
//            static let instance:ContactsManager = ContactsManager()
//        }
//        return Static.instance
        return ContactsManager.init()
    }

    private override init() {}
    
    private var addressBook : ABAddressBook?
    
    private func setAddressBook(){
        var error: Unmanaged<CFError>?
        let addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        self.addressBook = addressBook
    }
	
	//MARK:发出授权信息
	static var addressBookJurisdiction: Bool {
		//高于ios9
		if #available(iOS 9.0, *) {
			let state = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
			return !(state != CNAuthorizationStatus.notDetermined && state != CNAuthorizationStatus.authorized)
		} else {
			let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
			return !(sysAddressBookStatus != ABAuthorizationStatus.notDetermined && sysAddressBookStatus != ABAuthorizationStatus.authorized)
		}
	}
//MARK:权限的获取
    func jurisdictionHaveOrNotHave(doClosure:(()->())?,refuseClosure:(()->())?,errorClosure:(()->())?){
        //高于ios9 发出授权信息
        if #available(iOS 9.0, *) {
            let contactStore = CNContactStore.init()
            if CNContactStore.authorizationStatus(for: CNEntityType.contacts) == CNAuthorizationStatus.notDetermined{
                contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (grante, error) in
                    if (error != nil){
                        debugPrint("通讯录错误\(error)")
                        if let closure = errorClosure {
                            closure()
                        }
                    }else if !grante{
                        if let closure = refuseClosure {
                            closure()
                        }
                    }else{
                        debugPrint("获取到了")
                        if let closure = doClosure {
                            closure()
                        }
                    }
                })
            }else if CNContactStore.authorizationStatus(for: CNEntityType.contacts) == CNAuthorizationStatus.authorized{
                if let closure = doClosure {
                    closure()
                }
            }else{
				if let closure = refuseClosure {
					closure()
				}
            }
        } else {
            let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
            if (sysAddressBookStatus == ABAuthorizationStatus.notDetermined) {
                setAddressBook()
                ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                    if success {
                        if let closure = doClosure {
                            closure()
                        }
                    }else{
                        if let closure = errorClosure {
                            closure()
                        }
                    }
                })
            }else if (sysAddressBookStatus == ABAuthorizationStatus.denied || sysAddressBookStatus == ABAuthorizationStatus.restricted) {
                if let closure = refuseClosure {
                    closure()
                }
            }else if (sysAddressBookStatus == ABAuthorizationStatus.authorized) {
                if let closure = doClosure {
                    closure()
                }
            }
        }
    }
    
    //MARK:获取通讯录的内容
    func contactsGet(taskClosure:((String)->Bool)?,finishClosure:@escaping ([ImportAddressBookModel],[ImportAddressBookModel])->()){
        //通过选线获取内容
        self.jurisdictionHaveOrNotHave(doClosure: {[unowned self] (_) in
            if #available(iOS 9.0, *) {
                self.readContacts(taskClosure: taskClosure, endClosure: {[unowned self] in
                    finishClosure(self.sourceArr, self.importArr)
                })
            } else {
                self.readRecords(endClosure: {[unowned self] in
                    finishClosure(self.sourceArr, self.importArr)
                })
            }
            }, refuseClosure: {
                print("请到设置>隐私>通讯录>打开NewChama的权限设置")
            }, errorClosure: nil)
        
    }
    
    //MARK:********获取通讯录的信息**********
    private func readRecords(endClosure:()->()){
        self.sourceArr.removeAll()
        self.importArr.removeAll()
        let sysContacts: NSArray = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue() as NSArray
        for contact in sysContacts {
            let model = ImportAddressBookModel.init()
            //获取姓
            let lastName = ABRecordCopyValue(contact as ABRecord!, kABPersonLastNameProperty)?.takeRetainedValue() as! String? ?? ""
            if lastName.characters.count != 0{
                model.name = lastName
            }
            
            //名
            let firstName = ABRecordCopyValue(contact as ABRecord!, kABPersonFirstNameProperty)?.takeRetainedValue() as! String? ?? ""
            if firstName.characters.count != 0{
                model.name = firstName
            }
            //昵称
            let nikeName = ABRecordCopyValue(contact as ABRecord!, kABPersonNicknameProperty)?.takeRetainedValue() as! String? ?? ""
            //生日
            let birthday = ABRecordCopyValue(contact as ABRecord!, kABPersonBirthdayProperty)?.takeRetainedValue() as! NSDateComponents? ?? NSDate()
            //公司
            let orgnization = ABRecordCopyValue(contact as ABRecord!, kABPersonOrganizationProperty)?.takeRetainedValue() as! String? ?? ""
            model.company = orgnization
            //职位
            let jobTitle = ABRecordCopyValue(contact as ABRecord!, kABPersonJobTitleProperty)?.takeRetainedValue() as! String? ?? ""
            model.position = jobTitle
            //部门
            let department = ABRecordCopyValue(contact as ABRecord!, kABPersonDepartmentProperty)?.takeRetainedValue() as! String? ?? ""
            model.department = department
            //备注
            let note = ABRecordCopyValue(contact as ABRecord!, kABPersonNoteProperty)?.takeRetainedValue() as! String? ?? ""
            model.note = note
            //获取电话
            let phoneValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact as ABRecord!, kABPersonPhoneProperty).takeRetainedValue()
            if phoneValues != nil {
                for i in 0..<ABMultiValueGetCount(phoneValues) {
                    let value = ABMultiValueCopyValueAtIndex(phoneValues, i)
                    let phone = value?.takeRetainedValue() as! String
                    model.phone.append(phone)
                }
            }else{
                continue
            }
        
            //获取email
            let emailValues: ABMutableMultiValue? = ABRecordCopyValue(contact as ABRecord!, kABPersonEmailProperty).takeRetainedValue()
            if emailValues != nil {
                for i in 0..<ABMultiValueGetCount(emailValues) {
                    //获得标签名
                    let lable = ABMultiValueCopyLabelAtIndex(emailValues, i).takeRetainedValue() as CFString
                    let localizedLable = ABAddressBookCopyLocalizedLabel(lable).takeRetainedValue() as String
                    let value = ABMultiValueCopyLabelAtIndex(emailValues, i)
                    let email = value?.takeRetainedValue() as! String
                    model.email.append(email)
                }
            }
            
            //获取地址
            let addressValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact as ABRecord!, kABPersonAddressProperty).takeRetainedValue()
            if addressValues != nil {
                for i in 0 ..< ABMultiValueGetCount(addressValues){
                    
                    // 获得标签名
                    let label = ABMultiValueCopyLabelAtIndex(addressValues, i).takeRetainedValue()
                        as CFString;
                    let localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                        .takeRetainedValue() as String
                    
                    let value = ABMultiValueCopyValueAtIndex(addressValues, i)
                    let addrNSDict:NSMutableDictionary = value!.takeRetainedValue()
                        as! NSMutableDictionary
                    let country:String = addrNSDict.value(forKey: kABPersonAddressCountryKey as String)
                        as? String ?? ""
                    let state:String = addrNSDict.value(forKey: kABPersonAddressStateKey as String)
                        as? String ?? ""
                    let city:String = addrNSDict.value(forKey: kABPersonAddressCityKey as String)
                        as? String ?? ""
                    let street:String = addrNSDict.value(forKey: kABPersonAddressStreetKey as String)
                        as? String ?? ""
                    let contryCode:String = addrNSDict
                        .value(forKey: kABPersonAddressCountryCodeKey as String) as? String ?? ""
                    model.address = country + state + city + street
                }
            }
            
            
            //获取纪念日
            let dateValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact as ABRecord!, kABPersonDateProperty).takeRetainedValue()
            if dateValues != nil {
                for i in 0 ..< ABMultiValueGetCount(dateValues){
                    
                    // 获得标签名
                    let label = ABMultiValueCopyLabelAtIndex(emailValues, i).takeRetainedValue()
                        as CFString;
                    let localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                        .takeRetainedValue() as String
                    
                    let value = ABMultiValueCopyValueAtIndex(dateValues, i)
                    let date = (value?.takeRetainedValue() as? NSDate)?.description ?? ""
                }
            }
            
            //获取即时通讯
            let imValues:ABMutableMultiValue? =
                ABRecordCopyValue(contact as ABRecord!, kABPersonInstantMessageProperty).takeRetainedValue()
            if imValues != nil {
                for i in 0 ..< ABMultiValueGetCount(imValues){
                    
                    // 获得标签名
                    let label = ABMultiValueCopyLabelAtIndex(imValues, i).takeRetainedValue()
                        as CFString;
                    let localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                        .takeRetainedValue() as String
                    
                    let value = ABMultiValueCopyValueAtIndex(imValues, i)
                    let imNSDict:NSMutableDictionary = value!.takeRetainedValue()
                        as! NSMutableDictionary
                    let serves:String = imNSDict
                        .value(forKey: kABPersonInstantMessageServiceKey as String) as? String ?? ""
                    let userName:String = imNSDict
                        .value(forKey: kABPersonInstantMessageUsernameKey as String) as? String ?? ""
                }
            }
            model.sourceCount = sysContacts.count
            self.sourceArr.append(model)
        }
        endClosure()
    }
    
    @available(iOS 9.0, *)
    private func readContacts(taskClosure:((String)->Bool)?,endClosure:()->()){
        
            self.sourceArr.removeAll()
            self.importArr.removeAll()
            let contactStore = CNContactStore.init()
            
            //获取需要的属性累类型key
            let AllKeys:[CNKeyDescriptor] = getCNKeyDescriptor()
        
            let fetchRequest = CNContactFetchRequest(keysToFetch:AllKeys)
            
            var contacts = [CNContact]()
            
            do {
                try contactStore.enumerateContacts(with: fetchRequest, usingBlock: {
                    ( contact, stop) -> Void in
                    contacts.append(contact)
                })
            }
            catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
            //联系人转模型
            if contacts.count>0 {
                //遍历添加
                for contact in contacts {contact.isKeyAvailable("")
                    let model = ImportAddressBookModel.init()
                    //生日
                    if contact.isKeyAvailable(CNContactBirthdayKey) {
                        if let bit = contact.birthday?.calendar?.date(from: (contact.birthday)!){
                            let formate = DateFormatter()
                            formate.dateFormat = "yyyy-MM-dd HH:mm"
                            let date = formate.string(from: bit)
                            model.birthday = date
                        }
                    }
                    //名字
                    if contact.isKeyAvailable(CNContactGivenNameKey) {
                        model.name = contact.givenName.isEmpty ? "" : contact.givenName
                    }
                    if contact.isKeyAvailable(CNContactMiddleNameKey){
                        let fn = contact.middleName.isEmpty ? "" : contact.middleName
                        model.name = "\(fn)\(model.name)"
                    }
                    //姓名
                    if contact.isKeyAvailable(CNContactFamilyNameKey) {
                        let fn = contact.familyName.isEmpty ? "" : contact.familyName
                        model.name = "\(fn)\(model.name)"
                    }
                    //昵称
                    if contact.isKeyAvailable(CNContactNicknameKey) {
                    }
                    //公司
                    if contact.isKeyAvailable(CNContactOrganizationNameKey) {
                        model.company = contact.organizationName.isEmpty ? "" : contact.organizationName
                    }
                    //部门
                    if contact.isKeyAvailable(CNContactDepartmentNameKey) {
                        model.department = contact.departmentName.isEmpty ? "" : contact.departmentName
                        
                    }
                    //职位
                    if contact.isKeyAvailable(CNContactJobTitleKey) {
                        model.position = contact.jobTitle.isEmpty ? "" : contact.jobTitle
                    }
                    //备注
                    if contact.isKeyAvailable(CNContactNoteKey) {
                        model.note = contact.note.isEmpty ? "" : contact.note
                    }
                    //电话
                    if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
                        //电话的数组
                        let phones = contact.phoneNumbers.count > 0 ? contact.phoneNumbers : [CNLabeledValue]()
                        var numbers = [String]()
                        for value in phones {
                            if let num = value.value as? CNPhoneNumber {
                                var str = num.stringValue as NSString
                                str = str.replacingOccurrences(of: "-", with:"") as NSString
                                str = str.replacingOccurrences(of: "(", with:"") as NSString
                                str = str.replacingOccurrences(of: ")", with:"") as NSString
                                str = str.replacingOccurrences(of: " ", with:"") as NSString
                                numbers.append(str as String)

                            }
                        }
                        model.phone = numbers
                    }else{
                        continue
                    }
                    
                    if model.phone.count < 1 {
                        continue
                    }
                    //Email
                    if contact.isKeyAvailable(CNContactEmailAddressesKey) {
                        //Email的数组
                        let mails = contact.emailAddresses.count > 0 ? contact.emailAddresses : [CNLabeledValue]()
                        var adress = [String]()
                        for value in mails {
                            if let ad = value.value as? String {
                                adress.append(ad)
                            }
                        }
                        model.email = adress
                    }
                    //地址
                    if contact.isKeyAvailable(CNContactPostalAddressesKey) {
                        let mails = contact.postalAddresses.count > 0 ? contact.postalAddresses : [CNLabeledValue]()
                        var address = [String]()
                        var adress = ""
                        for value in mails {
                            if let ad = value.value as? CNPostalAddress {
                                adress = "\(ad.country)\(ad.postalCode)\(ad.state)\(ad.city)\(ad.street)"
                                address.append(adress)
                            }
                        }
                        model.address = address.first ?? ""
                    }
                    //社交
                    if contact.isKeyAvailable(CNContactSocialProfilesKey) {
                        //Email的数组
                        let socical = contact.socialProfiles.count > 0 ? contact.socialProfiles : [CNLabeledValue]()
                        var files = [String]()
                        for value in socical {
                            if let ad = value.value as? CNSocialProfile {
                                let socialUrl = "\(ad.username):\(ad.service).\(ad.urlString)"
                                files.append(socialUrl)
                            }
                        }
                        model.socials = files
                    }
                    //即时通讯相关微信
                    if contact.isKeyAvailable(CNContactInstantMessageAddressesKey) {
                        //Email的数组
                        let messages = contact.instantMessageAddresses.count > 0 ? contact.instantMessageAddresses : [CNLabeledValue]()
                        var files = [String]()
                        for value in messages {
                            if let ad = value.value as? CNInstantMessageAddress {
                                let socialUrl = "\(ad.username).\(ad.service)"
                                files.append(socialUrl)
                            }
                            model.messages = files
                        }
                        //添加
                    }
                    
//                    //头像
//                    if contact.isKeyAvailable(CNContactThumbnailImageDataKey) {
//                        if !model.isUploaded {
//                            if let data = contact.thumbnailImageData {
//                                model.image = UIImage(data: data)
//                            }
//                        }
//                    }

                    model.sourceCount = contacts.count
                    self.sourceArr.append(model)
                }
            }
        endClosure()
    }
    
    
    //MARK:添加通讯录联系人
    func addContactWithModel(model:ImportAddressBookModel,successClosure:@escaping (()->())){
        
        if #available(iOS 9.0, *) {
            self.jurisdictionHaveOrNotHave(doClosure: {[unowned self] (_) in
                self.addContact(model: model, success: successClosure)
            }, refuseClosure: nil, errorClosure: nil)
        } else {
            self.jurisdictionHaveOrNotHave(doClosure: {[unowned self] (_) in
                self.addRecord(model: model, successClo: successClosure)
            }, refuseClosure: nil, errorClosure: nil)

        }
        
    }
    
    @available(iOS 9.0, *)
	func addContact(model:ImportAddressBookModel,success:(()->())){
        let newCantact = CNMutableContact.init()
        newCantact.givenName = model.name 
//        newCantact.familyName = ""
        newCantact.contactType = CNContactType.person //个人联系人
//        //....可以添加其他联系人信息
//        if let comModel =  model.CompanyInfo.first {
//            newCantact.departmentName = comModel.department ?? " "
//            newCantact.organizationName = comModel.company_name ?? " "
//            newCantact.jobTitle = comModel.position ?? " "
//        }
//        
//       //电话
//        var phones = [CNLabeledValue]()
//        for phone in model.mobile_list {
//            let num = CNPhoneNumber.init(stringValue: phone)
//            let value = CNLabeledValue.init(label: CNLabelWork, value: num)
//            phones.append(value)
//        }
//        newCantact.phoneNumbers = phones
//        //email
//        var mails = [CNLabeledValue]()
//        for mail in model.email_list {
//            let value = CNLabeledValue.init(label: CNLabelWork, value: mail)
//            mails.append(value)
//        }
//        newCantact.emailAddresses = mails
//        //备注
//        newCantact.note = model.note ?? " "
//        
//        //社交微信
//        var socials = [CNLabeledValue]()
//        let value = CNLabeledValue.init(label: CNLabelWork, value:CNInstantMessageAddress.init(username:model.wechat, service: "微信"))
//        socials.append(value)
//        newCantact.instantMessageAddresses = socials
        //跳转标识
        var newchamas = [CNLabeledValue<CNSocialProfile>]()
        let newchamaValue = CNLabeledValue.init(label: CNLabelWork, value:CNSocialProfile.init(urlString: "url", username: "随便", userIdentifier:"随便", service: "随便"))
        newchamas.append(newchamaValue)
        newCantact.socialProfiles = newchamas
//        //公司地址
        var company = [CNLabeledValue<CNPostalAddress>]()
        let address = CNMutablePostalAddress.init()
        address.city = model.company 
        let companyInfo = CNLabeledValue.init(label: CNLabelWork, value:address)
        company.append(companyInfo as! CNLabeledValue<CNPostalAddress>)
        newCantact.postalAddresses = company 
        
        let saveRequest = CNSaveRequest.init()
        saveRequest.add(newCantact, toContainerWithIdentifier: nil)
        let contactStore = CNContactStore.init()
        do {
            try contactStore.execute(saveRequest)
            debugPrint("添加成功")
            success()
        }
        catch let error as NSError {
            debugPrint(error.localizedDescription)
            debugPrint(("通讯录添加失败"))
        }
        
    }
    
	func addRecord(model:ImportAddressBookModel,successClo:(()->())){
      
        let _ : Unmanaged<CFError>?
        
        let newContact:ABRecord! = ABPersonCreate().takeRetainedValue()
        var success:
            Bool = false
        
        success = ABRecordSetValue(newContact, kABPersonNicknameProperty, model.name as CFTypeRef??
            ?? " " as CFTypeRef!, nil)
        success = ABRecordSetValue(newContact, kABPersonLastNameProperty, model.name as CFTypeRef?? ?? " " as CFTypeRef!, nil)
        success = ABRecordSetValue(newContact, kABPersonFirstNameProperty, model.name as CFTypeRef?? ?? " " as CFTypeRef!, nil)
//        //phone
//        let phone : ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABStringPropertyType)).takeRetainedValue()
//        for num in model.mobile_list{
//            success = ABMultiValueAddValueAndLabel(phone, num, kABWorkLabel, nil)
//        }
//        success = ABRecordSetValue(newContact, kABPersonPhoneProperty, phone, nil)
//        //email
//        let addr:ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABStringPropertyType)).takeRetainedValue()
//        for mail in model.email_list{
//            success = ABMultiValueAddValueAndLabel(addr, mail, kABWorkLabel, nil)
//        }
//        success = ABRecordSetValue(newContact, kABPersonEmailProperty, addr, nil)
//        //company
//        if let comModel =  model.CompanyInfo.first {
//            ABRecordSetValue(newContact, kABPersonOrganizationProperty, comModel.company_name, nil)
//            ABRecordSetValue(newContact, kABPersonDepartmentProperty, comModel.department, nil)
//            ABRecordSetValue(newContact, kABPersonJobTitleProperty, comModel.position, nil)
//        }
        //跳转标识
        let newchama:ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABStringPropertyType)).takeRetainedValue()
        success = ABMultiValueAddValueAndLabel(newchama, "url" as CFTypeRef!, kABPersonSocialProfileURLKey, nil)
        success = ABMultiValueAddValueAndLabel(newchama, "你的名字" as CFTypeRef!, kABPersonSocialProfileUsernameKey, nil)
        success = ABMultiValueAddValueAndLabel(newchama, "你的名字" as CFTypeRef!, kABPersonSocialProfileServiceKey, nil)
        success = ABRecordSetValue(newContact, kABPersonSocialProfileProperty, newchama, nil)
//        //微信
//        let weixins:ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABStringPropertyType)).takeRetainedValue()
//        success = ABMultiValueAddValueAndLabel(newchama, model.wechat, kABPersonInstantMessageUsernameKey, nil)
//        success = ABMultiValueAddValueAndLabel(newchama, "微信", kABPersonInstantMessageServiceKey, nil)
//        success = ABRecordSetValue(newContact, kABPersonSocialProfileProperty, weixins, nil)
        
//        //note
//        success = ABRecordSetValue(newContact, kABPersonNoteProperty, model.note ?? " ", nil)
        
        success = ABAddressBookAddRecord(addressBook, newContact, nil)
        success = ABAddressBookSave(addressBook, nil)
        
        //存储完毕
        if success {
            successClo()
        }
    }

    
    @available(iOS 9.0, *)
    private func getCNKeyDescriptor()->[CNKeyDescriptor]{
        
        return [
//            CNContactIdentifierKey,
            //name
            CNContactNamePrefixKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
//            CNContactPreviousFamilyNameKey,
//            CNContactNameSuffixKey,
//            CNContactNicknameKey,
            
            //phonetic
            CNContactPhoneticGivenNameKey as CNKeyDescriptor,
//            CNContactPhoneticMiddleNameKey,
            CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
            
            //number
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            
            //email
            CNContactEmailAddressesKey as CNKeyDescriptor,
            
            //postal
            CNContactPostalAddressesKey as CNKeyDescriptor,
            
            //job
            CNContactJobTitleKey as CNKeyDescriptor,
            CNContactDepartmentNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            
            //note
            CNContactNoteKey as CNKeyDescriptor,
            //birthday
//            CNContactBirthdayKey,
            //CNContactNonGregorianBirthdayKey,
            //instantMessageAddresses
            CNContactInstantMessageAddressesKey as CNKeyDescriptor,
            
            //relation
            //CNContactRelationsKey,
            
            //SocialProfiles
            CNContactSocialProfilesKey as CNKeyDescriptor,
            
            //Dates
//            CNContactDatesKey
            
            //image
//            CNContactThumbnailImageDataKey
        ]
    }
}



class ImportAddressBookModel: NSObject {
    
    var name = ""
    var phone = [String]()
    var email = [String]()
    var birthday = ""
    var company = ""
    var department = ""
    var position = ""
    var address = ""
    var homePage = ""
    var sourceCount = -1
    var note = ""
    //社交相关
    var socials = [String]()
    //通讯录联系人对象
    var messages = [String]()
    
    override init() {
        super.init()
    }
}
