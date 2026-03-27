# Decompression Module

**Author**: Supan Roy

This directory contains all the scripts needed to decompress files that were compressed by the Hybrid Compression System. The decompression process reverses the compression pipeline to restore original files faithfully.

## Overview

The decompression system intelligently detects the compression method and file type, then applies the appropriate decompression algorithm to restore the original data.

### Supported Compression Methods
- **Auto-Detected GZIP (.gz)**: Automatically detects and reverses RLE+LZW+GZIP pipeline
- **Auto-Detected PDF (.pdf.gz)**: Automatically detects and decompresses GZIP-compressed PDFs

---

## Directory Structure

```
decompression/
├── README.md                       # This file - Documentation
├── decompress.sh                   # Main entry point (auto-detects method)
├── smart_gzip_decompress.sh       # Smart GZIP decompression with auto-detection
├── lzw_decode.sh                  # LZW decoder
└── rle_decode.sh                  # RLE decoder
```

---

## Decompression Pipeline Logic

### Automatic Method Detection

The decompression system **auto-detects** compression method based on file extension:

- **Files ending with `.pdf.gz`** → PDF decompression via GZIP
- **Files ending with `.gz`** → Intelligent GZIP decompression
  - Automatically detects if RLE+LZW pipeline was applied
  - Decompresses accordingly (with or without RLE/LZW reversal)

### For GZIP Compressed Files (.gz)

The GZIP decompression process reverses the compression pipeline in **reverse order**:

```
Compressed File (GZIP)
    ↓
gunzip (decompress GZIP layer)
    ↓
[Auto-detect: Check if LZW encoded]
    ↓
[If LZW detected] LZW Decode + RLE Decode
[If plain GZIP] → use as-is
    ↓
Original File
```

---

## Script Details

### 1. **decompress.sh** (Main Orchestrator with Auto-Detection)

**Purpose**: Single entry point for all decompression operations with automatic method detection

**Usage**:
```bash
./decompress.sh <input_file> <output_file>
```

**Parameters**:
- `<input_file>`: Path to the compressed file (any .gz or .pdf.gz file)
- `<output_file>`: Path where the decompressed file will be saved

**Example**:
```bash
# Decompress a text file (auto-detects as GZIP)
./decompress.sh myfile_compressed.gz myfile_restored.txt

# Decompress a PDF (auto-detected as PDF GZIP)
./decompress.sh document_compressed.pdf.gz document_restored.pdf
```

**How It Works**:
- **Auto-detects** the compression method based on file extension
- **`.pdf.gz` files** → Routes to smart GZIP decompression (for PDFs)
- **`.gz` files** → Routes to smart GZIP decompression (with LZW/RLE detection)
- **Other extensions** → Returns error (unsupported format)
- Validates input file exists before proceeding

---

### 2. **smart_gzip_decompress.sh** (Intelligent GZIP Decompression)

**Purpose**: Automatically detects whether a GZIP file contains LZW+RLE encoded data or just plain GZIP data, and decompresses accordingly.

**Usage**:
```bash
./smart_gzip_decompress.sh <input_file> <output_file>
```

**Parameters**:
- `<input_file>`: GZIP compressed file
- `<output_file>`: Destination for decompressed file

**How It Works**:
1. Decompresses the GZIP layer using `gunzip`
2. **Detects** if the decompressed content is LZW-encoded by checking if all initial lines contain only numeric values
3. **If LZW encoded** (detected by numeric lines):
   - Decodes LZW layer
   - Decodes RLE layer
4. **If plain GZIP** (not numeric):
   - Copies the decompressed content directly
5. Cleans up temporary files automatically

**Example**:
```bash
# For text files that were compressed with full pipeline
./smart_gzip_decompress.sh document_compressed.gz document.txt

# For binary files (like .docx) that were GZIP only
./smart_gzip_decompress.sh presentation_compressed.gz presentation.docx
```

**Advantages**:
- Automatically detects compression method
- Handles both pipeline and plain GZIP files
- Prevents errors from attempting wrong decompression

---

### 3. **lzw_decode.sh** (LZW Decoder)

**Purpose**: Reverses LZW (Lempel-Ziv-Welch) encoding

**Usage**:
```bash
./lzw_decode.sh <input_file> <output_file>
```

**Parameters**:
- `<input_file>`: LZW-encoded file (one integer code per line)
- `<output_file>`: Destination for decoded file

**LZW Algorithm (Decoding)**:
- Rebuilds the dictionary identically to how it was built during encoding
- Reads numeric codes from input, one per line
- Reconstructs the original byte sequence from dictionary lookups
- Dictionary starts with entries 0-255 for all single bytes
- Dictionary expands as new sequences are encountered (256+)

**Example**:
```bash
./lzw_decode.sh encoded.lzw decoded.txt
```

**Implementation Details**:
- Uses AWK for efficient dictionary management
- Handles up to 4096 dictionary entries (256-4096)
- Maintains state across lines using AWK arrays

---

### 4. **rle_decode.sh** (RLE Decoder)

**Purpose**: Reverses Run-Length Encoding

**Usage**:
```bash
./rle_decode.sh <input_file> <output_file>
```

**Parameters**:
- `<input_file>`: RLE-encoded file
- `<output_file>`: Destination for decoded file

**RLE Algorithm (Decoding)**:
- Format: `<count><character>` for sequences of 3+ identical characters
- Single/double occurrences are stored as-is without count prefix
- Examples: `11A` → 11 A's, `BB` → 2 B's, `5X` → 5 X's

**Decoding Process**:
1. Parse each line character by character
2. When a digit is found, collect all consecutive digits to form the count
3. Convert count string to **numeric value** (important for proper loop iteration)
4. Get the character after the count
5. Output the character repeated by the count
6. For non-digit characters, output them as-is

**Example**:
```bash
# Input: 11ABBBCCCC
# Output: AAAAAAAAAABBBBCCCC

./rle_decode.sh encoded.rle decoded.txt
```

**Important Bug Fix**:
The decoder uses numeric count calculation (`count = count * 10 + digit`) instead of string concatenation to ensure correct loop iterations:
```awk
count = 0
while (i <= n && substr(line, i, 1) ~ /[0-9]/) {
    count = count * 10 + substr(line, i, 1)  # Numeric calculation
    i++
}
```

---

## Complete Workflow Example

### Scenario: Decompressing a File

**Step 1: Decompress (no method selection needed)**
```bash
bash decompression/decompress.sh myjournal_compressed.gz myjournal_restored.txt
# Auto-detects: .gz file → uses smart GZIP decompression
# Smart GZIP automatically detects if RLE+LZW was applied
# Result: myjournal_restored.txt
```

**Step 2: Verify**
```bash
diff myjournal.txt myjournal_restored.txt
# No output = files are identical ✓
```

### Scenario: Decompressing a PDF

**Step 1: Decompress (no method selection needed)**
```bash
bash decompression/decompress.sh mydocument_compressed.pdf.gz mydocument_restored.pdf
# Auto-detects: .pdf.gz file → uses smart GZIP decompression
# Result: mydocument_restored.pdf
```

**Step 2: Verify**
```bash
file mydocument_restored.pdf
# Should output: PDF document...
```

---

## Performance Characteristics

| File Type | Compression Method | Best For | Compression Ratio |
|-----------|-------------------|----------|-------------------|
| Plain Text | RLE+LZW+GZIP | Documents, logs, code | 30-70% reduction |
| Already Compressed | GZIP only | .docx, .jpg, .zip | 5-15% reduction |
| PDFs | Ghostscript | PDF documents | 40-60% reduction |
| Binary Data | GZIP only | Executables, archives | Variable |

---

## Error Handling

### Common Errors and Solutions

**Error: "Ghostscript (gs) not installed"**
```bash
sudo apt install ghostscript
```

**Error: "Unknown method"**
- Ensure method is one of: `gzip`, `lzw`, `rle`, `pdf`
- Check spelling and capitalization

**Error: "File not found"**
- Verify the input file path exists
- Use absolute paths if relative paths fail

**Error: "Decompression failed"**
- Ensure the correct decompression method is used
- Verify the file is actually compressed with that method
- Check file integrity (not corrupted)

---

## Integration with GUI

The decompression scripts are integrated into the main GUI (`main.sh`):

1. Run: `bash main.sh`
2. Select "Decompress File"
3. Choose your compressed file
4. Select the decompression method:
   - **GZIP (RLE+LZW+GZIP Pipeline)** - for text files
   - **RLE** - for RLE-only compressed files
   - **LZW** - for LZW-only compressed files
   - **PDF** - for PDF files
5. Choose output location
6. File is decompressed automatically

---

## Testing

To test the decompression system:

```bash
# Create a test file
echo "AAAAAABBBBBBCCCCCCCCC" > test.txt

# Compress it (from compression folder)
bash compression/compress.sh test.txt test_compressed.gz

# Decompress it
bash decompression/decompress.sh test_compressed.gz test_restored.txt gzip

# Verify
diff test.txt test_restored.txt
echo $?  # Should output 0 (success)
```

---

## Key Algorithms Summary

### RLE (Run-Length Encoding)
- **Compression**: Replaces 3+ identical consecutive characters with `<count><char>`
- **Decompression**: Expands `<count><char>` back to original characters
- **Best for**: Text with repeated characters

### LZW (Lempel-Ziv-Welch)
- **Compression**: Builds dictionary of frequent sequences, replaces with codes
- **Decompression**: Rebuilds identical dictionary from codes, reconstructs sequences
- **Best for**: General-purpose compression

### GZIP
- **Compression**: Industry-standard deflate compression
- **Decompression**: Reverses compression layers
- **Best for**: Final compression stage

---

## Version History

- **v1.0** (March 27, 2026): Initial release with smart detection and RLE fix

---

## Support

For issues or questions:
1. Check this documentation
2. Review the script comments in the source files
3. Test with example files from the main directory
4. Check file permissions: `chmod +x *.sh`
