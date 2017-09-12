//
//  CGRect+Extensions.swift
//  Swift_Coding
//
//  Created by Zack on 2017/9/11.
//  Copyright © 2017年 liuyao. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary {
    
    
    /// 合并 Dictionary
    ///
    /// - Parameter dict: 合并后的 Dictionary
    mutating func merge(_ dict: [Key: Value]) {
        for (k, v) in dict {
            self.updateValue(v, forKey: k)
        }
    }
    
    /// EZSE: Returns the value of a random Key-Value pair from the Dictionary
    public func random() -> Value? {
        return Array(values).random()
    }
    
    /// EZSE:合并字典
    public func union(_ dictionaries: Dictionary...) -> Dictionary {
        var result = self
        dictionaries.forEach { (dictionary) -> Void in
            dictionary.forEach { (key, value) -> Void in
                result[key] = value
            }
        }
        return result
    }
    
    /// EZSE: 字典交集
    /// Two dictionaries are considered equal if they contain the same [key: value] copules.
    public func intersection<K, V>(_ dictionaries: [K: V]...) -> [K: V] where K: Equatable, V: Equatable {
        //  Casts self from [Key: Value] to [K: V]
        let filtered = mapFilter { (item, value) -> (K, V)? in
            if let item = item as? K, let value = value as? V {
                return (item, value)
            }
            return nil
        }
        
        //  Intersection
        return filtered.filter { (key: K, value: V) -> Bool in
            //  check for [key: value] in all the dictionaries
            dictionaries.testAll { $0.has(key) && $0[key] == value }
        }
    }
    /// EZSE: 检查字典中是否存在键.
    public func has(_ key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    /// EZSE: 通过运行生成的值创建一个数组
    /// each [key: value] of self through the mapFunction.
    public func toArray<V>(_ map: (Key, Value) -> V) -> [V] {
        return self.map(map)
    }
    
    /// EZSE: 创建一个与自己和运行生成的值相同的键的词典
    /// each [key: value] of self through the mapFunction.
    public func mapValues<V>(_ map: (Key, Value) -> V) -> [Key: V] {
        var mapped: [Key: V] = [:]
        forEach {
            mapped[$0] = map($0, $1)
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with the same keys as self and values generated by running
    /// each [key: value] of self through the mapFunction discarding nil return values.
    public func mapFilterValues<V>(_ map: (Key, Value) -> V?) -> [Key: V] {
        var mapped: [Key: V] = [:]
        forEach {
            if let value = map($0, $1) {
                mapped[$0] = value
            }
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with keys and values generated by running
    /// each [key: value] of self through the mapFunction discarding nil return values.
    public func mapFilter<K, V>(_ map: (Key, Value) -> (K, V)?) -> [K: V] {
        var mapped: [K: V] = [:]
        forEach {
            if let value = map($0, $1) {
                mapped[value.0] = value.1
            }
        }
        return mapped
    }
    
    /// EZSE: Creates a Dictionary with keys and values generated by running
    /// each [key: value] of self through the mapFunction.
    public func map<K, V>(_ map: (Key, Value) -> (K, V)) -> [K: V] {
        var mapped: [K: V] = [:]
        forEach {
            let (_key, _value) = map($0, $1)
            mapped[_key] = _value
        }
        return mapped
    }
    
    /// EZSE: Constructs a dictionary containing every [key: value] pair from self
    /// for which testFunction evaluates to true.
    public func filter(_ test: (Key, Value) -> Bool) -> Dictionary {
        var result = Dictionary()
        for (key, value) in self {
            if test(key, value) {
                result[key] = value
            }
        }
        return result
    }
    
    /// EZSE: Checks if test evaluates true for all the elements in self.
    public func testAll(_ test: (Key, Value) -> (Bool)) -> Bool {
        return !contains { !test($0, $1) }
    }
    
    /// EZSE:  JSON 转 Dictionary
    public static func constructFromJSON (json: String) -> Dictionary? {
        if let data = (try? JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8, allowLossyConversion: true)!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Dictionary {
            return data
        } else {
            return nil
        }
    }
    
    /// EZSE:  Dictionary 转 JSON string
    public func formatJSON() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions()) {
            let jsonStr = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            return String(jsonStr ?? "")
        }
        return nil
    }
    
}

extension Dictionary where Value: Equatable {
    /// EZSE: 
    /// Two dictionaries are considered equal if they contain the same [key: value] pairs.
    public func difference(_ dictionaries: [Key: Value]...) -> [Key: Value] {
        var result = self
        for dictionary in dictionaries {
            for (key, value) in dictionary {
                if result.has(key) && result[key] == value {
                    result.removeValue(forKey: key)
                }
            }
        }
        return result
    }
}

/// EZSE: Combines the first dictionary with the second and returns single dictionary
public func += <KeyType, ValueType> (left: inout [KeyType: ValueType], right: [KeyType: ValueType]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

/// EZSE: Difference operator
public func - <K, V: Equatable> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.difference(second)
}

/// EZSE: Intersection operator
public func & <K, V: Equatable> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.intersection(second)
}

/// EZSE: Union operator
public func | <K: Hashable, V> (first: [K: V], second: [K: V]) -> [K: V] {
    return first.union(second)
}