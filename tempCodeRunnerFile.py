stdin, stdout, stderr = ssh.exec_command(f"./{local_script}")
        # print(f"Executing script on {ip}...")
        # print(stdout.read().decode())
        # error_output = stderr.read().decode()
        # if error_output:
        #     print(f"Error executing script on {ip}: {error_output}")