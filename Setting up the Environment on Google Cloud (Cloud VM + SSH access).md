# Google Cloud VM Setup with Docker and Anaconda

This guide walks you through setting up a Google Cloud Platform (GCP) Virtual Machine (VM), configuring SSH access, installing Docker, and setting up Docker Compose and Anaconda.

## Prerequisites
- A Google Cloud Platform account
- A terminal with SSH access

## Steps

### 1. Generate SSH Keys
First, create an SSH key pair to access your Google Cloud VM.

```bash
# Navigate to the home directory and create an `.ssh` directory if it doesn't exist.
cd ~
# Create a hidden directory `.ssh` to store your SSH keys.
mkdir -p .ssh
# Navigate into the `.ssh` directory.
cd .ssh/

# Generate a new RSA key pair for GCP
# - `-t rsa`: Specifies the type of key to create (RSA).
# - `-f gcp`: Specifies the filename for the key.
# - `-C co2project`: Adds a comment (this is optional, useful for identifying the key).
# - `-b 2048`: Specifies the key size (2048 bits, which is a good default for RSA).
ssh-keygen -t rsa -f gcp -C co2project -b 2048
```

### 2. Add SSH Key to Google Cloud
1. In the Google Cloud Console, go to **Compute Engine** > **VM instances** > **Metadata** > **SSH Keys**.
2. Add your SSH public key:
   ```bash
   # Display the public key
   cat gcp.pub
   ```
   - Copy the output of the `gcp.pub` file.
   - Paste it into the **SSH Keys** section in Google Cloud Console, then click **Save**.

### 3. Create a VM Instance
1. In Google Cloud Console, go to **Compute Engine** > **VM instances** > **Create Instance**.
2. Configure the instance:
   - Change the instance name.
   - Select the desired region.
   - Choose the machine type (`e2-standard-4`).
   - Select Ubuntu as the operating system.
3. After creating the instance, copy its external IP address.

### 4. Connect to the VM via SSH

```bash
# Use the private key to connect to the VM
# - `-i ~/.ssh/gcp`: Specifies the private key for authentication.
# - Connect to the instance with the user at the provided IP address.
ssh -i ~/.ssh/gcp user@<external-ip-address>
```

### 5. Install Anaconda
1. Once connected, download the Anaconda installer (choose the latest version https://repo.anaconda.com/archive):
   ```bash
   wget https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh
   ```

2. Run the installer:
   ```bash
   bash Anaconda3-2024.06-1-Linux-x86_64.sh
   ```

### 6. Configure SSH for Easier Access

You can simplify future SSH access by configuring an alias in the `~/.ssh/config` file.

```bash
# Navigate to the `.ssh` directory
cd ~/.ssh/

# Create a new SSH config file if it doesn't exist
touch config

# Open the config file and add the following entry
# Replace `<external-ip-address>` with your VM's external IP
code config

# - `Host : Assigns an alias to this connection (so you can type `ssh alias` to connect).
# - `HostName`: The external IP address of your instance.
# - `User`: The username you use to connect to the instance.
# - `IdentityFile`: The path to your private SSH key.

Host co2-project
    HostName <external-ip-address>
    User co2project
    IdentityFile ~/.ssh/gcp
```

Now, you can connect to your VM using the alias:

```bash
ssh co2-project
```

### 7. Install Docker

Once connected to your VM, install Docker:

```bash
# Update package lists
sudo apt-get update

# Install Docker
sudo apt-get install docker.io
```

To run Docker without `sudo`, follow these steps:

```bash
# Add the Docker group (if it doesn't already exist)
sudo groupadd docker

# Add your user to the Docker group
sudo gpasswd -a $USER docker

# Restart the Docker service to apply changes
sudo service docker restart

# Log out and log back in for the changes to take effect
CTRL+D
ssh co2-project

# Test Docker installation
docker run hello-world
```

### 8. Install Docker Compose

1. Create a `bin` directory in your home folder to store binaries like Docker Compose:
   ```bash
   mkdir -p ~/bin
   cd ~/bin/
   ```

2. Download Docker Compose:
   ```bash
   wget https://github.com/docker/compose/releases/download/v2.29.5/docker-compose-linux-x86_64 -O docker-compose
   ```

3. Make the Docker Compose binary executable:
   ```bash
   chmod +x docker-compose
   ```

4. Add the `~/bin` directory to your system `PATH`:
   ```bash
   nano ~/.bashrc
   ```

   At the end of the `.bashrc` file, add the following line:

   ```bash
   export PATH="${HOME}/bin:${PATH}"
   ```

5. Save the file and apply the changes:
   ```bash
   # Save and close the editor (in `nano`: CTRL+O, then CTRL+X)
   source ~/.bashrc
   ```

6. Verify Docker Compose installation:
   ```bash
   docker-compose --version
   ```

## Summary of Commands

- **SSH Key Generation**:
  ```bash
  ssh-keygen -t rsa -f gcp -C co2project -b 2048
  ```

- **Connect to VM**:
  ```bash
  ssh -i ~/.ssh/gcp co2project@<external-ip-address>
  ```

- **Install Docker**:
  ```bash
  sudo apt-get update
  sudo apt-get install docker.io
  ```

- **Install Docker Compose**:
  ```bash
  mkdir ~/bin
  wget https://github.com/docker/compose/releases/download/v2.29.5/docker-compose-linux-x86_64 -O ~/bin/docker-compose
  chmod +x ~/bin/docker-compose
  ```

- **Update `.bashrc` for PATH**:
  ```bash
  export PATH="${HOME}/bin:${PATH}"
  source ~/.bashrc
  ```

## Additional Resources
- [Google Cloud Compute Documentation](https://cloud.google.com/compute/docs)
- [Anaconda Installation Guide](https://docs.anaconda.com/anaconda/install/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Releases](https://github.com/docker/compose/releases)
```

### How to use this `README.md`
- Add this to the root of your GitHub repository.
- The commands and explanations are formatted as steps that users can follow, with explanations for each part of the setup.
