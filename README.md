[English](./README.md) | [中文](./docs/zh.md)

# Time Trek

## Introduction

Time Tracking is a simple command-line tool for recording and viewing time. It tracks the time spent on various tasks.

## Features

- **Automatic Timezone Detection**: Defaults to the current timezone, ensuring accurate time recording.
- **Simple and Easy to Use**: Record and view time with simple commands.
- **Future Features**:
    - Statistics on time per event

## Usage

Ensure you have the [Zig](https://ziglang.org/download/) compiler installed.
```bash
git clone https://github.com/rockorager/time-trek.git
cd time-trek
zig build run

# or 

zig build
./zig-out/bin/time-trek
```

## Example

After you input content, the program will record the current information along with the current time, as shown below:
```bash
./zig-out/bin/time-trek 
Input information

cat ./time-trek.txt
# [2024-12-28 14:12:24]: Input information
```

## Contributing

All forms of contributions are welcome! Please submit a [Pull Request](https://github.com/tsingksan/time-trek/pulls) or report issues in [Issues](https://github.com/tsingksan/time-trek/issues).

## License

This project is licensed under the [MIT License](LICENSE).
