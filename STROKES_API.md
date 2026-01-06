# PencilKit Strokes API

这个文档描述了新添加的 `getStrokes()` 方法，它允许你直接获取绘图的笔画数据，而不仅仅是 base64 编码的图像数据。

## 新增方法

### `getStrokes()`

获取当前绘图的所有笔画数据，以结构化格式返回。

```dart
Future<List<Map<String, dynamic>>> getStrokes()
```

#### 返回值

返回一个包含笔画对象的列表，每个笔画对象包含以下字段：

- **`inkType`** (int): 墨水类型
  - `0`: Pen (钢笔)
  - `1`: Pencil (铅笔)
  - `2`: Marker (马克笔)
  - `3`: Monoline (单线笔，iOS 17+)
  - `4`: Fountain Pen (钢笔，iOS 17+)
  - `5`: Watercolor (水彩笔，iOS 17+)
  - `6`: Crayon (蜡笔，iOS 17+)

- **`color`** (String): 颜色值，格式为 `#AARRGGBB`

- **`pathPoints`** (List): 路径点数组，每个点包含：
  - `location`: `{x: double, y: double}` - 点的位置
  - `timeOffset`: `double` - 时间偏移
  - `size`: `{width: double, height: double}` - 笔刷大小
  - `opacity`: `double` - 透明度 (0.0-1.0)
  - `force`: `double` - 压力值 (0.0-1.0)
  - `azimuth`: `double` - 方位角
  - `altitude`: `double` - 高度角

- **`transform`** (Map): 变换矩阵
  - `a`, `b`, `c`, `d`, `tx`, `ty`: 2D 变换矩阵的六个参数

- **`mask`** (List, 可选): 遮罩路径数据（如果存在）

## 使用示例

### 基本用法

```dart
try {
  final strokes = await controller.getStrokes();
  print('总共有 ${strokes.length} 个笔画');
  
  for (int i = 0; i < strokes.length; i++) {
    final stroke = strokes[i];
    print('笔画 $i:');
    print('  墨水类型: ${stroke['inkType']}');
    print('  颜色: ${stroke['color']}');
    print('  点数: ${stroke['pathPoints']?.length ?? 0}');
  }
} catch (e) {
  print('获取笔画数据失败: $e');
}
```

### 分析笔画数据

```dart
Future<void> analyzeStrokes() async {
  final strokes = await controller.getStrokes();
  
  // 统计不同类型的笔画
  Map<int, int> inkTypeCount = {};
  int totalPoints = 0;
  
  for (final stroke in strokes) {
    final inkType = stroke['inkType'] as int;
    inkTypeCount[inkType] = (inkTypeCount[inkType] ?? 0) + 1;
    
    final pathPoints = stroke['pathPoints'] as List?;
    totalPoints += pathPoints?.length ?? 0;
  }
  
  print('笔画统计:');
  inkTypeCount.forEach((type, count) {
    print('  类型 $type: $count 个笔画');
  });
  print('总点数: $totalPoints');
}
```

### 重建绘图路径

```dart
void reconstructDrawing(List<Map<String, dynamic>> strokes) {
  for (final stroke in strokes) {
    final pathPoints = stroke['pathPoints'] as List;
    final color = stroke['color'] as String;
    
    // 创建路径
    final path = Path();
    bool isFirst = true;
    
    for (final pointData in pathPoints) {
      final location = pointData['location'] as Map<String, dynamic>;
      final x = location['x'] as double;
      final y = location['y'] as double;
      
      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    // 使用路径和颜色进行绘制
    // ... 你的绘制逻辑
  }
}
```

## 示例应用

在示例应用中，我们添加了两个新按钮：

1. **数据图标按钮** (📊): 在控制台打印笔画数据
2. **列表图标按钮** (📋): 打开详细的笔画查看器

笔画查看器显示：
- 每个笔画的基本信息（类型、颜色、点数）
- 变换矩阵详情
- 前3个路径点的详细信息
- 遮罩信息（如果存在）

## 与现有方法的比较

| 方法 | 返回类型 | 用途 | 数据大小 |
|------|----------|------|----------|
| `getBase64Data()` | String | 保存/加载绘图 | 小 |
| `getBase64PngData()` | String | 导出为图像 | 大 |
| `getBase64JpegData()` | String | 导出为图像 | 中等 |
| **`getStrokes()`** | **List<Map>** | **分析笔画数据** | **可变** |

## 注意事项

1. 这个方法只在 iOS 13.0+ 上可用
2. 返回的数据量取决于绘图的复杂程度
3. 对于复杂的绘图，数据可能会很大
4. 坐标系统使用 PencilKit 的原生坐标系统

## 错误处理

```dart
try {
  final strokes = await controller.getStrokes();
  // 处理笔画数据
} on PlatformException catch (e) {
  print('平台错误: ${e.message}');
} catch (e) {
  print('未知错误: $e');
}
```