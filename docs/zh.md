[English](../README.md) | [中文](./zh.md)

# 时间追踪

## 简介

时间追踪是一个简单的命令行工具，用于记录和查看时间。追踪各项任务的花费时间。


## 特点

- **自动时区检测**：默认使用当前时区，确保时间记录的准确性。
- **简洁易用**：通过简单的命令即可记录和查看时间。
- **未来功能**：
    - 统计每项事件时间

## 使用

确保你已经安装了 [Zig](https://ziglang.org/download/) 编译器。
```bash
git clone https://github.com/rockorager/time-trek.git
cd time-trek
zig build run

# or 

zig build
./zig-out/bin/time-trek
```

## 示例

当你输入内容后，程序会将当前信息与当前时间一起记录，如下所示：
```
./zig-out/bin/time-trek 
输入信息

cat ./time-trek.txt
# [2024-12-28 14:12:24]: 输入信息
```

## 贡献

欢迎任何形式的贡献！请提交 [Pull Request](https://github.com/tsingksan/time-trek/pulls) 或在 [Issues](https://github.com/tsingksan/time-trek/issues) 中报告问题。

## 许可证

此项目采用 [MIT 许可证](LICENSE) 许可。
