# Security

Do not publish private server details in this repository.

Never commit:

- passwords or one-time login secrets
- private SSH keys
- real server IP addresses, ports, or usernames
- host-key fingerprints tied to a private server
- calculation data that should remain private

The setup helper uses `DFT_SERVER_PASSWORD` only for the current process when bootstrapping SSH key login. It does not write the password to disk.
