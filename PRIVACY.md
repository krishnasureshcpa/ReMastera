# Privacy Policy

ReMastera is built on a foundation of absolute user privacy and data sovereignty. This document outlines the design principles that ensure your media files and processing transcripts remain completely private.

## The ReMastera Privacy Promise

ReMastera guarantees the following:

- **No Data Uploads**: Your video assets, audio files, and generated subtitle transcripts are processed entirely on your local machine. The application does not contain code to transmit or upload media to external servers.
- **No Telemetry & Analytics**: We do not collect usage analytics, click metrics, runtime performance data, or crash reports. There are no tracking scripts or analytic SDKs integrated into the codebase.
- **No Cloud API Integrations**: The core restoration features do not rely on remote AI models or external server endpoints.
- **No Silent Model Downloads**: ReMastera will not download neural network files or software dependencies in the background. Model downloads must be triggered manually by the user, with destination paths clearly disclosed.

## Local Data Storage

All application data is stored locally in standard macOS directory locations:

- Neural Network Models: `~/Library/Application Support/ReMastera/Models/`
- Local Execution Logs: `~/Library/Logs/ReMastera/`

You can inspect or delete these directories at any time using Finder or the macOS Terminal.
