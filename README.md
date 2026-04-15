<div align="center">

# Hybrid File Compression System

**A Desktop Application for Linux**

**OS Lab Project — Group Submission**

[![nomancsediu](https://img.shields.io/badge/GitHub-nomancsediu-181717?logo=github)](https://github.com/nomancsediu)
[![supan-roy](https://img.shields.io/badge/GitHub-supan--roy-181717?logo=github)](https://github.com/supan-roy)
[![hossain-joy](https://img.shields.io/badge/GitHub-hossain--joy-181717?logo=github)](https://github.com/hossain-joy)
[![jeba234](https://img.shields.io/badge/GitHub-jeba234-181717?logo=github)](https://github.com/jeba234)

</div>

---

## 📌 About The Project

The **Hybrid File Compression System** is a pure Bash-based desktop application designed for Linux. It provides a simple, intuitive Graphical User Interface (GUI) to compress and decompress files and folders. The project utilizes a custom multi-stage compression pipeline combining Run-Length Encoding (RLE) and Lempel-Ziv-Welch (LZW) algorithms, resulting in high compression ratios without the need to rely on external heavyweight libraries.

---

## ✨ Key Features

- **Custom Pipeline**: Compresses any file using a custom 3-stage pipeline (RLE → LZW → GZIP).
- **PDF Optimization**: Compresses PDF files directly using Ghostscript (DCT + Flate).
- **Folder Archiving**: Compresses folders and multiple files by integrating `tar` archiving seamlessly with the pipeline.
- **User-Friendly GUI**: Simple graphical interface built with Zenity — no terminal knowledge required.
- **High Efficiency**: Achieves up to **84.9% compression ratio**.
- **Lightweight**: Written entirely in Bash.

---

## 🛠️ Tech Stack

| Layer       | Technology                        |
|-------------|-----------------------------------|
| Language    | Bash Shell Script                 |
| GUI         | Zenity (GTK-based)                |
| PDF Engine  | Ghostscript                       |
| Algorithms  | RLE, LZW, GZIP, DCT, Tar          |
| Platform    | Linux                             |

---

## ⚙️ Prerequisites

Before running the application, ensure you have the following installed on your Linux system:

- `bash`: Standard Unix shell.
- `zenity`: Used to render the graphical interfaces and file dialogues.
- `ghostscript` (`gs`): Required specifically for PDF compression/optimization.
- `tar` & `gzip`: Standard archiving and compression binaries.

On Debian/Ubuntu-based systems, you can install the dependencies via:
```bash
sudo apt update
sudo apt install bash zenity ghostscript tar gzip
```

---

## 🚀 Installation & Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nomancsediu/Hybrid-Compression-System.git
   cd Hybrid-Compression-System
   ```

2. **Make the scripts executable:**
   ```bash
   chmod +x main.sh
   chmod +x compression/*.sh decompression/*.sh
   ```

3. **Run the application:**
   ```bash
   ./main.sh
   ```

4. **Navigate the GUI:**
   - **Compress File**: Select a single text or PDF file to compress.
   - **Compress Folder**: Select a whole directory to package and compress into an archive.
   - **Decompress File/Archive**: Select a `.gz` or `.tar.gz` bundle produced by the tool to seamlessly extract it.

---

## 🧠 How It Works

### For Text/Binary Files
When a standard file is selected, it passes through a 3-stage pipeline:
1. **Run-Length Encoding (RLE)**: Scans the file and replaces consecutive repeated characters with a count followed by the character (e.g., `AAAAA` becomes `5A`). This reduces repetitive data.
2. **LZW Encoding**: Builds a pattern dictionary from the RLE output and replaces recurring sequences with short integer codes.
3. **GZIP Compression**: Compresses the LZW-encoded output at level 9, producing the final `.gz` file.

### For Folders (Archives)
When a folder is selected for compression, the system groups all containing files and sub-directories into a single `.tar` payload using standard Unix `tar` archiving. The resulting archive is then passed through the standard 3-stage pipeline (RLE → LZW → GZIP), outputting a unified `.tar.gz` payload. Upon decompression, the system automatically detects the archive format, decodes it, and reconstructs the original folder hierarchy in place.

### For PDF Files
PDF files are handled separately using Ghostscript. It applies DCT (Discrete Cosine Transform) to compress embedded images in a lossy manner, while text and fonts are compressed losslessly using Flate encoding. The output is a fully valid, smaller `.pdf` file — no decompression step is needed.

---

## 📁 Project Structure

```text
Hybrid-Compression-System/
├── main.sh                       # Main GUI entry point
├── README.md                     # Project documentation
├── compression/                  # Compression logic
│   ├── compress.sh               # Standard file compression pipeline coordinator
│   ├── compress_pdf.sh           # Ghostscript PDF optimizer
│   ├── lzw_encode.sh             # LZW encoder script
│   └── rle_encode.sh             # Run-Length encoder script
└── decompression/                # Decompression logic
    ├── decompress.sh             # Standard pipeline decoder coordinator
    ├── gzip_decompress.sh        # GZIP decompression script
    ├── lzw_decode.sh             # LZW decoder script
    ├── rle_decode.sh             # Run-Length decoder script
    └── smart_gzip_decompress.sh  # Advanced extraction mapping
```

---

<div align="center">

Version 1.0 &nbsp;·&nbsp; Linux &nbsp;·&nbsp; Open Source

</div>
