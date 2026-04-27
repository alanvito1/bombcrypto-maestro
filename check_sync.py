import subprocess
import os

def run(cmd, cwd=None):
    return subprocess.check_output(cmd, shell=True, cwd=cwd).decode().strip()

def check_sync():
    print("--- Main Repository ---")
    main_head = run("git rev-parse HEAD")
    main_remote = run("git rev-parse origin/master")
    print(f"HEAD: {main_head}")
    print(f"Remote (origin/master): {main_remote}")
    if main_head == main_remote:
        print("[OK] Aligned")
    else:
        print("[FAIL] Not Aligned")

    print("\n--- Submodules ---")
    submodules = run("git submodule status").splitlines()
    for sub in submodules:
        parts = sub.strip().split()
        # Format: [-/+/ ]commit path (branch)
        sha = parts[0].strip('+- ')
        path = parts[1]
        
        print(f"\nSubmodule: {path}")
        try:
            # Get current branch in submodule
            sub_path = os.path.join(os.getcwd(), path)
            current_branch = run("git branch --show-current", cwd=sub_path)
            current_sha = run("git rev-parse HEAD", cwd=sub_path)
            
            # Try main then master
            try:
                remote_sha = run("git rev-parse origin/main", cwd=sub_path)
                remote_branch = "main"
            except:
                remote_sha = run("git rev-parse origin/master", cwd=sub_path)
                remote_branch = "master"
            
            print(f"Current Branch: {current_branch}")
            print(f"Current SHA: {current_sha}")
            print(f"Remote SHA ({remote_branch}): {remote_sha}")
            
            if current_sha == remote_sha:
                print(f"[OK] Aligned with {remote_branch}")
            else:
                print(f"[FAIL] Not Aligned with {remote_branch}")
                if current_branch not in ['main', 'master']:
                    print(f"[WARN] Warning: On feature branch '{current_branch}'")
        except Exception as e:
            print(f"Error checking {path}: {e}")

if __name__ == "__main__":
    check_sync()
