# File Rename Utility - AppleScript

A powerful AppleScript utility that intelligently renames files with customizable delimiters, capitalization options, and conflict handling. Perfect for organizing messy filenames into clean, consistent formats.

## 🚀 Features

- **Multiple Delimiter Options**: Choose between Underscore (_), Dash (-), or Dot (.)
- **Smart Capitalization**: Option to capitalize each word or preserve original casing
- **Conflict Prevention**: Automatically adds numeric suffixes (_1, _2, etc.) to prevent overwrites
- **Extension Preservation**: Safely preserves only the last file extension
- **Non-alphanumeric Cleanup**: Replaces all special characters with chosen delimiter
- **Multiple File Support**: Process multiple files at once
- **Quick Action Integration**: Works as a macOS Quick Action

## 📋 Requirements

- macOS (tested on macOS 10.14+)
- Automator (for Quick Action setup)
- Files with read/write permissions

## 🛠️ Installation

### Method 1: Quick Action (Recommended)

1. Open **Automator**
2. Choose **Quick Action**
3. Set workflow receives: **Files or Folders**
4. Set in: **Any application**
5. Add **Run AppleScript** action
6. Copy the script from `rename.workflow`
7. Save as **"Rename Files"**

### Method 2: Direct AppleScript

1. Open **Script Editor**
2. Copy the script from `rename.workflow`
3. Save as **"Rename Files.scpt"**
4. Run from Script Editor or create a droplet

## 📖 Usage

### Quick Action Method

1. **Select files** in Finder (single or multiple)
2. **Right-click** → **Services** → **Rename Files**
3. **Choose delimiter** (Underscore, Dash, or Dot)
4. **Choose capitalization** (Capitalize Each Word or Preserve Original)
5. **Files are renamed** automatically!

### Direct Script Method

1. Open **Script Editor**
2. Run the script
3. Select files when prompted
4. Follow the same steps as Quick Action

## 🎯 Examples

### Example 1: Basic Renaming

| Original Filename | Delimiter | Capitalization | Result |
|-------------------|-----------|----------------|---------|
| `my-file name.jpg` | Underscore | Capitalize | `My_File_Name.jpg` |
| `messy.file.name.txt` | Dash | Capitalize | `Messy-File-Name.txt` |
| `data backup.tar.gz` | Dot | Preserve | `Data.Backup.tar.gz` |

### Example 2: Complex Filenames

| Original Filename | Delimiter | Capitalization | Result |
|-------------------|-----------|----------------|---------|
| `Sbi.Bank.Statement.Copy.png` | Underscore | Capitalize | `Sbi_Bank_Statement_Copy.png` |
| `messy-file name__V2.jpg` | Dash | Capitalize | `Messy-File-Name-V2.jpg` |
| `report.final.version-1.docx` | Dot | Preserve | `Report.Final.Version.1.docx` |

### Example 3: Conflict Handling

| Original Filename | New Filename | Conflict Resolution |
|-------------------|--------------|-------------------|
| `test.jpg` | `Test.jpg` | `Test.jpg` (no conflict) |
| `test.jpg` | `Test.jpg` (exists) | `Test_1.jpg` |
| `test.jpg` | `Test_1.jpg` (exists) | `Test_2.jpg` |

## ⚙️ Configuration Options

### Delimiters

- **Underscore (_)**: `my_file_name.jpg`
- **Dash (-)**: `my-file-name.jpg`
- **Dot (.)**: `my.file.name.jpg`

### Capitalization

- **Capitalize Each Word**: `My_File_Name.jpg`
- **Preserve Original Casing**: `my_file_name.jpg`

## 🔧 How It Works

1. **File Analysis**: Extracts base name and extension
2. **Character Cleaning**: Replaces non-alphanumeric characters with chosen delimiter
3. **Collapse Duplicates**: Removes consecutive delimiters
4. **Capitalization**: Applies chosen capitalization style
5. **Conflict Check**: Ensures unique filename
6. **Rename**: Applies the new filename

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Can't get name of alias" error
- **Solution**: Ensure files are selected properly in Finder

**Issue**: Files not being renamed
- **Solution**: Check file permissions and ensure files aren't locked

**Issue**: Capitalization not working
- **Solution**: The script uses awk for capitalization - ensure it's available

**Issue**: Adding unwanted `_1` suffix
- **Solution**: This happens when the new filename already exists - it's working as designed

### Debug Mode

To enable debug information, uncomment the debug lines in the script:
```applescript
display dialog "Step X - Debug info: " & variable_name
```

## 📝 Script Structure

```
Main Function
├── User Input (Delimiter Selection)
├── User Input (Capitalization Selection)
└── File Processing Loop
    ├── Filename Splitting
    ├── Character Cleaning
    ├── Capitalization
    ├── Conflict Resolution
    └── File Renaming
```

## 🔒 Security Notes

- Script only renames files, never deletes
- Always creates unique names to prevent data loss
- Requires user confirmation for all operations
- Works within user's file permissions

## 📄 License

This utility is provided as-is for personal and educational use.

## 🤝 Contributing

Feel free to submit issues or improvements:
- Bug reports
- Feature requests
- Code improvements
- Documentation updates

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Verify file permissions
3. Test with simple filenames first
4. Check macOS version compatibility

---

**Happy File Organizing! 🎉**
