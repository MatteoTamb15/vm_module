#!/bin/bash

# Crea utente e gruppo
USER_NAME="matteo"
GROUP_NAME="gruppo1"

# Crea il gruppo se non esiste
if ! getent group "$GROUP_NAME" > /dev/null 2>&1; then
    groupadd "$GROUP_NAME"
fi

# Crea utente e imposta password
USER_PASSWORD="password" 
if ! id "$USER_NAME" > /dev/null 2>&1; then
    useradd -m -s /bin/bash -g "$GROUP_NAME" "$USER_NAME"
fi
echo "$USER_NAME:$USER_PASSWORD" | chpasswd

# Aggiunge utente a sudo
usermod -aG sudo "$USER_NAME" || true

# Setup SSH directory
mkdir -p "/home/$USER_NAME/.ssh"
chmod 700 "/home/$USER_NAME/.ssh"
touch "/home/$USER_NAME/.ssh/authorized_keys"
chmod 600 "/home/$USER_NAME/.ssh/authorized_keys"
chown -R "$USER_NAME:$GROUP_NAME" "/home/$USER_NAME/.ssh"

# ABILITA password auth per primo login (disabilita dopo setup SSH)
sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config || true
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config || true
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config || true
systemctl restart sshd

# Log
echo "$(date): User '$USER_NAME' e gruppo '$GROUP_NAME'" >> /var/log/startup-script.log
cat /var/log/startup-script.log
