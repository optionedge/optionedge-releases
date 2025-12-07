# OptionEdge  - Find your Edge

[![Latest Release](https://img.shields.io/github/v/release/optionedge/optionedge-releases?style=for-the-badge)](https://github.com/optionedge/optionedge-releases/releases)

[![Docker Compose YAML](https://img.shields.io/badge/Download-Docker%20Compose-blue)](https://store-api.optionedge.in/releases/docker-compose.yml) 

## Updates: December 2025
OptionEdge is no longer accepting new registrations.
We will be gradually phasing out the platform for existing users by February 2026.

Thank you for being a part of our journey.

# [Click to view Quick Start Guide](#optionedge-quick-start-guide)

## Introduction

**OptionEdge** is a self-hosted, web-based trading platform designed to help traders execute trades live quickly, manage positions efficiently, and optimize their strategies with advanced risk management capabilities. Whether you're a beginner or an experienced trader, OptionEdge provides a powerful toolkit to forward-test ideas, visualize payoffs, and adjust strategies without risking real capital or execute live with your favourite broker.

## 🚀 Key Features

- **Quick Trade Execution** – Execute trades instantly to capitalize on market opportunities.
- **Trade Management** – Monitor and manage executed trades effectively.
- **Payoff Visualization** – Get real-time insights into your strategy’s potential outcomes.
- **Strategy Testing (Drafts)** – Forward-test trading ideas without any financial risk.
- **Adjustments & Optimization** – Modify and optimize strategies based on market conditions.
- **Risk Management** – Set Stop-Loss (SL) and Target levels at multiple layers: Position, Basket, or Global.
- **Multi-Broker Support** – Seamlessly integrate and execute strategies across multiple brokers.
- **Live Execution** – Execute strategies against brokers and track live PnL and payoffs.
- **Basket Organization** – Group strategies into baskets for better P&L tracking.
- **Cross-Platform Compatibility** – Self-host on **Windows, Linux, macOS**, or deploy on a **VPS/cloud server**.
- **Web-Based Access** – Use OptionEdge from any modern web browser.

## 📊 Baskets & Strategy Organization

Organize your trading strategies into **baskets and basket groups** to efficiently track the profit and loss at different levels. This feature helps traders manage multiple strategies in a structured manner.

## 🔥 Live Execution & Draft Testing

- **Live Execution** – Instantly execute strategies against a configured broker, track live PnL, and set exit targets.
- **Draft Testing** – Forward-test strategies in a **simulated environment** before going live. Convert drafts into live strategies with a single click.

## 🛠️ Installation & Hosting

OptionEdge is a **self-hosted** platform that can run on:
- **Local Machines** – Windows, Linux, macOS
- **Cloud/VPS Servers** – Deploy on any cloud provider (AWS, Azure, DigitalOcean, Linode, etc.)

---

# OptionEdge Quick Start Guide

### **Linux/Mac Installation (Using Docker)**

#### **Prerequisites: Install Docker**

**Install Docker on Linux (Ubuntu):**

   - Update package index:
     ```bash
     sudo apt update
     ```
   - Install required dependencies:
     ```bash
     sudo apt install ca-certificates curl gnupg
     ```
   - Add Docker’s official GPG key:
     ```bash
     sudo install -m 0755 -d /etc/apt/keyrings
     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
     sudo chmod a+r /etc/apt/keyrings/docker.asc
     ```
   - Set up the repository:
     ```bash
     echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
     ```
   - Install Docker:
     ```bash
     sudo apt update
     sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
     ```
   - Verify installation:
     ```bash
     docker --version
     ```

#### **Download and Run OptionEdge with Docker Compose**

1. **Create a Local Folder for OptionEdge:**

   ```bash
   mkdir ~/optionedge && cd ~/optionedge
   ```

2. **Download the Docker Compose YAML File:**

   - Use the following link to download the `docker-compose.yml` file:

   - [![Docker Compose YAML](https://img.shields.io/badge/Download-Docker%20Compose-blue)](https://store-api.optionedge.in/releases/docker-compose.yml)

   - Alternatively, download via terminal:
     ```bash
     curl -o docker-compose.yml https://optionedgereleasessa.blob.core.windows.net/optionedge-github-releases/docker-compose.yml
     ```

3. **Start OptionEdge using Docker Compose:**

   ```bash
   docker-compose up -d
   ```

   - The `-d` flag runs it in detached mode (background mode).
   - This will start both the OptionEdge Engine and UI.

4. **Access the UI:**

   - Open Chrome (recommended) and go to [`http://localhost:7500`](http://localhost:7500).
   - Log in with your credentials and complete the setup.

5. **Persistent Data Storage:**

   - User data (logs, configuration, etc.) is stored in the `data` folder where the `docker-compose.yml` file is downloaded.

#### **Upgrading to the Latest Version**

To update to the latest version of OptionEdge using Docker Compose:

1. **Backup the Data Folder:**

   ```bash
   cp -r ~/optionedge/data ~/optionedge/data_backup
   ```

2. **Download the Updated Docker Compose File:**

   ```bash
   curl -o docker-compose.yml https://optionedgereleasessa.blob.core.windows.net/optionedge-github-releases/docker-compose.yml
   ```

3. **Stop the Running Instance:**

   ```bash
   docker-compose down
   ```

4. **Pull and Run the Latest Docker Compose Version:**

   ```bash
   docker-compose pull
   docker-compose up -d
   ```

5. **Restore Backup if Needed:**

   - If anything goes wrong, restore the backup by copying the backup folder back to the original location:
     ```bash
     rm -rf ~/optionedge/data
     mv ~/optionedge/data_backup ~/optionedge/data
     ```

---

This completes the installation and setup of OptionEdge on Windows, Linux, and Mac. Enjoy using OptionEdge!


---

💡 **Start exploring OptionEdge today and take your trading to the next level!**
