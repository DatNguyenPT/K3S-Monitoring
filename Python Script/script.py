import paramiko
import os

# VM IPs
master_ip = "54.226.88.143"
worker_ips = ["98.83.80.134", "34.203.99.250"]

# Use pair to store username for master and workers
master_user = "ubuntu"  # Adjust this to your actual master username
worker_user = "ubuntu"   # Adjust this to your actual worker username

# Scripts
master_script = "BashScript/MasterSetup.sh"
worker_script = "BashScript/WorkerSetup.sh"

# Path to your PEM key files
master_key_file = "ssh-key-master.pem"
worker_keys = ["ssh-key-worker-1.pem", "ssh-key-worker-2.pem"]

# Connect to machines
def execute_command_on_server(ip, script_path, username, key_file):
    # Create a new SSH client
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    print(f"Connecting to {username}@{ip} using key: {key_file}")
    
    try:
        # Load the PEM key
        private_key = paramiko.RSAKey.from_private_key_file(key_file)
        
        # Connect to machine using the PEM key
        ssh.connect(ip, username=username, pkey=private_key)
        print(f"Connected to {ip}.")

        # Copy scripts to machine
        sftp = ssh.open_sftp()
        local_script = os.path.basename(script_path)
        sftp.put(script_path, local_script)
        sftp.chmod(local_script, 0o755)  # Set script permission
        print(f"Uploaded {local_script} to {ip}.")

        # Execute script
        stdin, stdout, stderr = ssh.exec_command(f"./{local_script}")
        print(f"Executing script on {ip}...")
        print(stdout.read().decode())
        error_output = stderr.read().decode()
        if error_output:
            print(f"Error executing script on {ip}: {error_output}")

    except paramiko.AuthenticationException:
        print(f"Authentication failed for {username}@{ip}. Please check your credentials.")
    except paramiko.SSHException as e:
        print(f"SSH error occurred for {ip}: {e}")
    except Exception as e:
        print(f"Error connecting to {ip}: {e}")
    finally:
        ssh.close()

# Execute on master node
execute_command_on_server(master_ip, master_script, master_user, master_key_file)

# Execute on worker nodes
for i in range(len(worker_ips)):
    execute_command_on_server(worker_ips[i], worker_script, worker_user, worker_keys[i])
