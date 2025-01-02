# Windows Shadow Viewer PowerShell Application

This repository contains a PowerShell-based GUI application that simplifies connecting to and managing remote desktop (RDP) shadow sessions on Windows machines. The tool allows you to:

- Query active sessions on a remote computer.
- Automatically parse the session ID of the active user session.
- Initiate a shadow (remote viewing) session with or without control.
- Optionally connect as a different (RunAs) user.

## Features

- Stores previously used computer names and usernames in a local CSV file for quick reuse.
- Supports querying sessions via SSH (using *plink*).
- Allows toggling *Request Control* to interact with the remote session.
- Enables connecting via *mstsc* shadow sessions with flexible options.

## Getting Started

### Prerequisites

1. **PowerShell**: This script runs in a PowerShell environment.
2. **PuTTY's plink**: Required for SSH querying of sessions (make sure *plink* is in your PATH).
3. **mstsc**: Standard Windows Remote Desktop client (built into most Windows installations).

### Installation

1. **Clone or download** this repository to your local machine.
2. Place the script in a directory of your choice.
3. Ensure your environment has *plink* installed and accessible.

### Usage

1. Open a **PowerShell** window.
2. Navigate to the directory containing the script.
3. Run:
```bash
'.\ShadowViewer.ps1'
```
   
   - If *Execution Policy* is restricted, you may need to set:
```bash
'Set-ExecutionPolicy RemoteSigned -Scope Process'
```

5. **Fill in the GUI fields** once it opens:
   - **Computer Name**: The hostname or IP address of the remote computer.
   - **SSH Username**: A valid user on the remote system (for the *plink* connection).
   - **SSH Password**: The password for the SSH user (hidden in the GUI).
   - **Session ID**: Automatically filled after you press **Query Session**.
   - **Request Control**: Check this if you want mouse/keyboard control in the shadow session.

6. **Query Session**:
   - Click the **Query Session** button to SSH into the remote computer and retrieve active session IDs.
   - If an active session is found, the script populates the **Session ID** field.

7. **Connect**:
   - If an active session ID is available, click **Connect** to start the shadow session with *mstsc*.
   - Alternatively, click **Connect as RunAs User** to shadow as a different user (requires additional credentials).

### Example

1. Enter 'MyRemotePC' in **Computer Name**.  
2. Enter 'adminuser' in **SSH Username**.  
3. Enter 'password123' in **SSH Password**.  
4. Click **Query Session** to find the active user session ID.  
5. If found, the session ID appears in **Session ID**.  
6. Check **Request Control** if you wish to interact with the remote desktop.  
7. Click **Connect** to open the shadow session.

## Contributing

Contributions, bug fixes, or feature requests are welcome. Please open an issue or submit a pull request with any improvements or changes you would like to see.

## License

This project is provided as-is with no specific license. If you use or modify the code, please retain appropriate credit.
