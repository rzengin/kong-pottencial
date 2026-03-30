import sys
import subprocess

lines = open('.kong.env').read().strip().split('\n')
envs = []
current_key = None
current_val = []

for line in lines:
    if '=' in line and not line.startswith('-----'):
        if current_key is not None:
            envs.append((current_key, '\\n'.join(current_val)))
        key, val = line.split('=', 1)
        current_key = key
        current_val = [val]
    else:
        current_val.append(line)
if current_key is not None:
    envs.append((current_key, '\\n'.join(current_val)))

cmd = ['docker', 'run', '-d', '--name', 'charming_curran', '-p', '8000:8000', '-p', '8443:8443']
for k, v in envs:
    cmd.extend(['-e', f"{k}={v}"])
cmd.append('kong/kong-gateway:3.13')

print("Starting Kong DP with tracing enabled...")
result = subprocess.run(cmd, capture_output=True, text=True)
if result.returncode != 0:
    print("Failed to start docker:")
    print(result.stderr)
else:
    print("Docker started successfully:")
    print(result.stdout)
