#!/bin/bash
      USERNAME="worker1"
      PASSWORD="worker1"

      # Create the user
      sudo useradd -m -s /bin/bash $USERNAME

      # Set the password
      echo "$USERNAME:$PASSWORD" | sudo chpasswd

      # Optionally add the user to the sudo group
      sudo usermod -aG sudo $USERNAME