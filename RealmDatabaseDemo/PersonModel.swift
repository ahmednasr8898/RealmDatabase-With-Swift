//
//  PersonModel.swift
//  RealmDatabaseDemo
//
//  Created by Ahmed Nasr on 11/14/20.
//

import Foundation
import RealmSwift

class PersonModel: Object{
    @objc dynamic var name = ""
    @objc dynamic var age = 0
}
