## 🛠️ Simple Process Logger - Version 1.0

This project provides a **process logger** written in Batch and PowerShell. It logs active processes, creates secure backups, and encrypts logs to ensure data integrity. Designed with automation and error handling, this script helps monitor system activities effectively over time.

---

### ✨ **Features**

1. **🚀 Process Monitoring**
   - Logs all currently running processes with their names and paths.
   - Appends logs to `process_log.txt` with timestamps and cycle numbers.

2. **📦 Cycle-Based Backup Management**
   - Creates a backup log (`process_log_bk.txt`) every alternate cycle.
   - Ensures the original log is safely stored before new data is logged.

3. **🔒 Encryption & Security**
   - Uses **RSA encryption** to secure log file hashes.
   - Protects data integrity with **SHA-256 hashing**.

4. **🧩 Modular PowerShell Integration**
   - Dynamically generates and executes PowerShell scripts during each cycle to capture processes.

5. **🛑 Error Handling and Debugging**
   - Gracefully exits with error messages if critical operations (logging, encryption) fail.
   - Includes detailed logs with color-coded console outputs for better visibility.

6. **⏲️ 30-Second Interval Between Cycles**
   - Uses a 30-second timeout between logging cycles to ensure smooth performance.

---

### 🛠 **How to Use**

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/BharatAscendEsports/process-logger.git
   cd process-logger
   ```

2. **Ensure Public Key for Encryption**  
   - Place the RSA public key file as `public_key.xml` in the same directory.

3. **Run the Script as Administrator**  
   - **Important**: The `.bat` file must be run **as an administrator** for it to function properly.  
     - To do this, right-click `process_logger.bat` and select **"Run as Administrator"**.
     - Or, from the terminal:
       ```bash
       runas /user:Administrator process_logger.bat
       ```

4. **Monitor Console Outputs**  
   - The script will log information with color-coded messages (info, success, and errors).

---

### 📂 **Logs and Files**

| File                     | Description                                      |
|--------------------------|--------------------------------------------------|
| `process_logger.bat`     | Main script to start the logging process         |
| `process_log.txt`        | Primary log file containing the logged processes |
| `process_log_bk.txt`     | Backup of the primary log (every alternate cycle)|
| `temp_process_log.txt`   | Temporary file for each cycle’s process data     |
| `public_key.xml`         | RSA public key used for encrypting log file hashes |
| `process_log_encrypted.txt` | Encrypted hash of the main log               |
| `process_log_bk_encrypted.txt` | Encrypted hash of the backup log         |

---

### 🔍 **Script Flow Overview**

1. **Start Logging**:  
   The script initializes with **cycle count 1** and starts logging processes.

2. **Generate PowerShell Script**:  
   It dynamically creates a PowerShell script to list all active processes.

3. **Create Backups and Encrypt Logs**:  
   - On **odd cycles**, it hashes and encrypts the backup log.
   - On **even cycles**, it creates a new backup of the main log.

4. **Cycle Management**:  
   - The **cycle counter** increments with each iteration.
   - The script waits for **30 seconds** between cycles and continues indefinitely.

---

### 🧑‍💻 **Contributing**

We welcome contributions! 🚀 Here’s how you can get involved:

1. **Fork the repository**.
2. **Create a new branch** for your changes:
   ```bash
   git checkout -b feature-branch
   ```
3. **Commit your changes**:
   ```bash
   git commit -m "Add feature XYZ"
   ```
4. **Push your branch**:
   ```bash
   git push origin feature-branch
   ```
5. **Open a pull request** and we’ll review it.

---

### 📜 **License**

This project is licensed under the **MIT License**.

---

### 🛡️ **Troubleshooting**

1. **Encryption Issues**  
   - Ensure the `public_key.xml` is correctly placed and formatted.

2. **Permission Errors**  
   - Make sure the script has necessary write permissions in the directory.  

3. **Script Exiting Unexpectedly**  
   - Check console messages for detailed error logs.  

4. **Not Running as Administrator**  
   - If the script encounters issues (e.g., missing logs or encryption failures), ensure it was run **as administrator**.

---

Enjoy seamless process monitoring with 🛠️ Simple Process Logger.
