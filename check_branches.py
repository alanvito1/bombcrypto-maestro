import subprocess
import os

def run(cmd, cwd=None):
    try:
        return subprocess.check_output(cmd, shell=True, cwd=cwd).decode().strip()
    except:
        return ""

submodules = ["bombcrypto-api-v2", "bombcrypto-client-v2", "bombcrypto-contract-v2", "bombcrypto-market-v2", "bombcrypto-server-v2"]

for sub in submodules:
    print(f"\n--- {sub} ---")
    branches = run("git branch -r", cwd=sub)
    print(branches)
