import subprocess
import os

def run(cmd, cwd=None):
    try:
        # Using shell=True for Windows compatibility with git
        result = subprocess.check_output(cmd, shell=True, cwd=cwd, stderr=subprocess.STDOUT).decode().strip()
        return result
    except subprocess.CalledProcessError as e:
        return f"ERROR: {e.output.decode().strip()}"

submodules = ["bombcrypto-api-v2", "bombcrypto-client-v2", "bombcrypto-contract-v2", "bombcrypto-market-v2", "bombcrypto-server-v2"]

print("Starting total sync with Senspark (Upstream)...")

for sub in submodules:
    print(f"--- Processing: {sub} ---")
    sub_path = os.path.join(os.getcwd(), sub)
    
    # 1. Fetch upstream
    print(f"[{sub}] Fetching upstream updates...")
    run("git fetch upstream", cwd=sub_path)
    
    # 2. Detectar branch principal (main ou master)
    remote_branches = run("git branch -r", cwd=sub_path)
    if "upstream/main" in remote_branches:
        primary = "main"
    elif "upstream/master" in remote_branches:
        primary = "master"
    else:
        print(f"ERR: [{sub}] Main/master branch not found on upstream.")
        continue
    
    print(f"[{sub}] Primary branch detected: {primary}")
    
    # 3. Checkout e Reset
    print(f"[{sub}] Checkout and Reset to upstream/{primary}...")
    run(f"git checkout {primary}", cwd=sub_path)
    res = run(f"git reset --hard upstream/{primary}", cwd=sub_path)
    print(f"[{sub}] {res}")
    
    # 4. Sincronizar Fork (origin)
    print(f"[{sub}] Syncing your fork (origin/{primary})...")
    push_res = run(f"git push origin {primary} --force", cwd=sub_path)
    print(f"[{sub}] {push_res}")

print("\n--- Main Repository ---")
print("Updating Maestro index...")
run("git add .")
run('git commit -m "chore: sync submodules with official Senspark upstream repositories"')
print("Sync completed!")
