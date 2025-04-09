### **1. 构造函数**
```cpp
std::map<Key, T> m;            // 默认构造函数
std::map<Key, T> m2(m);        // 拷贝构造
std::map<Key, T> m3(begin, end); // 用迭代器范围初始化
```

---

### **2. 插入元素**
#### **`insert`**
```cpp
m.insert(std::pair<Key, T>(key, value)); // 插入键值对
m.insert(std::make_pair(key, value));    // 简化写法
m.insert({key, value});                  // C++11 初始化列表
```

#### **`emplace` (C++11)**
更高效，直接在容器内构造元素：
```cpp
m.emplace(key, value); // 无需显式创建 pair
```

#### **`operator[]`**
若键不存在，会自动插入默认值：
```cpp
m[key] = value; // 插入或修改值
```

---

### **3. 访问元素**
#### **`operator[]`**
```cpp
T value = m[key]; // 返回键对应的值（若不存在会插入默认值）
```

#### **`at` (C++11)**
安全访问，键不存在时抛出 `std::out_of_range`：
```cpp
T value = m.at(key); 
```

---

### **4. 查找元素**
#### **`find`**
返回指向键的迭代器，未找到则返回 `end()`：
```cpp
auto it = m.find(key);
if (it != m.end()) {
    // 找到元素 it->first, it->second
}
```

#### **`count`**
返回键的数量（0 或 1，因为键唯一）：
```cpp
if (m.count(key) > 0) {
    // 存在
}
```

#### **`contains` (C++20)**
直接判断键是否存在：
```cpp
if (m.contains(key)) {
    // 存在
}
```

---

### **5. 删除元素**
#### **`erase`**
```cpp
m.erase(key);      // 删除键为 key 的元素
m.erase(iterator); // 删除迭代器指向的元素
m.erase(begin, end); // 删除迭代器范围内的元素
```

---

### **6. 大小与容量**
#### **`size`**
```cpp
int num = m.size(); // 返回元素数量
```

#### **`empty`**
```cpp
if (m.empty()) {
    // map 为空
}
```

---

### **7. 遍历**
#### **迭代器**
```cpp
for (auto it = m.begin(); it != m.end(); ++it) {
    // it->first 是键，it->second 是值
}

// C++11 范围循环
for (const auto& pair : m) {
    // pair.first, pair.second
}
```

---

### **8. 其他操作**
#### **`clear`**
清空所有元素：
```cpp
m.clear();
```

#### **`swap`**
交换两个 `map` 的内容：
```cpp
m1.swap(m2);
```

#### **`lower_bound` / `upper_bound`**
用于范围查询：
```cpp
auto lower = m.lower_bound(key); // 第一个 >= key 的迭代器
auto upper = m.upper_bound(key); // 第一个 > key 的迭代器
```

---

### **示例代码**
```cpp
#include <iostream>
#include <map>

int main() {
    std::map<std::string, int> scores;

    // 插入
    scores["Alice"] = 90;
    scores.emplace("Bob", 85);
    scores.insert({"Charlie", 95});

    // 查找
    if (scores.find("Alice") != scores.end()) {
        std::cout << "Alice's score: " << scores["Alice"] << std::endl;
    }

    // 删除
    scores.erase("Bob");

    // 遍历
    for (const auto& pair : scores) {
        std::cout << pair.first << ": " << pair.second << std::endl;
    }

    return 0;
}
```

---

### **注意事项**
- `operator[]` 在键不存在时会插入默认值，可能产生副作用。
- `map` 的键是唯一的，重复插入相同键会覆盖原有值。
- 迭代器按键的升序遍历（默认使用 `std::less<Key>`）。

如果需要允许重复键，可以使用 `std::multimap`。