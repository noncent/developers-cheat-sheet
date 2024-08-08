# Learn Git by use case

## Use Case

### [1]: Git local setup

> I want to setup my first git locally from remote code repository.

#### Option 1.1

```bash
cd /var/www/html
mkdir work-folder
cd work-folder
git clone <repository_url>
cd <repository_name>
```

#### Option 1.2

```bash
cd /var/www/html
mkdir work-folder
cd work-folder
git init
git config --global user.name "<Your Name>"
git config --global user.email "<your_email@example.com>"
git remote add origin <repository_url>
git checkout -b <branch>
git pull origin <branch>
```

### [2]: Clone the code repository

> I want to clone the git repo

#### Option 2.1

```bash
cd /var/www/html
mkdir work-folder
cd work-folder
git clone <repository_url>
cd <repository_name>
```

> **Tips:**
> 
> Q. Which Branch Git Uses When Cloning a Repo?
> 
> By default, when you clone a Git repository, you clone all branches.
> Git will check out the default branch, which is typically main (or
> master in older repositories).


#### Option 2.2

```bash
cd /var/www/html
mkdir work-folder
cd work-folder
git clone --depth 1 <repository_url>
cd <repository_name>
```

> **Tips:**
>
> Shallow clone: For large repositories, consider using --depth 1 to clone only the latest commit.
>


### [3]: Single branch cloning

> I want to clone the git repo for a specific branch only

#### Option 3.1

```bash
cd /var/www/html
mkdir work-folder
cd work-folder
git clone --branch <branch> <repository_url>
cd <repository_name>
```

> **Help:**
>
> - Clones the entire repository, including all branches.
> - Checks out the specified branch as the local branch.
> - Allows you to switch to other branches later without needing to re-clone.

#### Option 3.2

```bash
cd /var/www/html
mkdir work-folder
cd work-folder
git clone --branch <branch> --single-branch <repository_url>
cd <repository_name>
```

> **Help:**
>
> - Clones only the specified branch and its history.
> - Checks out the cloned branch as the local branch.
> - Significantly reduces the amount of data transferred compared to the first option.
> - Limits you to working only on the cloned branch without additional fetches.

#### Option 3.3

```bash
cd /var/www/html
mkdir work-folder
cd work-folder
git clone --branch <branch_name> --depth 1 <repository_url>
cd <repository_name>
```

> **Help:**
>
> Shallow clone: For large repositories, consider using --depth 1 to clone only the latest commit of the specified branch.
>

### [4]: Multi stack code in single repo 

> My repo has single branch `master` which is for backend code, now I want to push my frontend code in `frontend` branch in same repo.

#### Option 4.1

```bash
cd /var/www/html
mkdir work-folder
cd work-folder
git clone <repository_url>
cd <repository_name>
# Create a new branch frontend and switch to it:
git checkout --orphan frontend
# The --orphan option creates a new branch with no commit history, essentially making it a clean slate.
# Remove all existing files (they are from the master branch):
git rm -rf .
# Add the HTML code you want in this branch. For example, create an index.html file:
echo "<h1>Hello, Frontend!</h1>" > index.html
git add index.html
# Commit the new changes:
git commit -m "Initial commit for frontend branch"
# Push the frontend branch to the remote repository:
git push origin frontend
```






git checkout -b release/Production release/Production
git clone --depth 1 <https://bitbucket.unileversolutions.com/scm/flf/galcblog.in.git>
git remote set-url origin <https://bitbucket.unileversolutions.com/scm/flf/upgrade-ui-bd.git>
environment.recaptcha
git clone --branch release/production --single-branch ssh://git@bitbucket.unileversolutions.com:7999/flf/upgrade-ui-bd.git
git remote add origin <https://bitbucket.unileversolutions.com/scm/flf/upgrade-ui-bd.git>

Sure, here's a proper README file that includes the list of Git commands and the rewritten troubleshooting section:

---

# Git & Cheatsheet

## Git Commands

### 1. Clone a Single Branch

```bash
git clone --branch release/production --single-branch https://bitbucket.org/user/repo.git
git clone --branch production --single-branch https://bitbucket.org/user/repo.git
git clone --branch frontend https://bitbucket.org/user/repo.git
```

Clones the `release/production` branch from the specified repository.
Clones the `production` branch from the specified repository.
Clones the `frontend` branch from the specified repository.

### 2. Generate a New SSH Key

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Generates a new SSH key with RSA encryption and the provided email.

### 3. Start the SSH Agent

```bash
eval "$(ssh-agent -s)"
```

Starts the SSH agent in the background.

### 4. Add SSH Private Key to Agent

```bash
ssh-add -K ~/.ssh/id_rsa
```

Adds your SSH private key to the SSH agent.

### 5. Copy SSH Public Key to Clipboard

```bash
pbcopy < ~/.ssh/id_rsa.pub
```

Copies the SSH public key to your clipboard.

### 6. Test SSH Connection to Bitbucket

```bash
ssh -T git@bitbucket.org
```

Tests your SSH connection to Bitbucket.

### 7. Set Remote URL to Use SSH

```bash
git remote set-url origin git@bitbucket.org:username/repository.git
```

Sets the remote URL for your Git repository to use SSH.

## Troubleshooting Git Fetch Issues

If you encounter issues like `RPC failed; curl 18 transfer closed with outstanding read data remaining`, follow these steps:

1. **Check Network Connectivity**:
   - Ensure your internet connection is stable without packet loss.
   - Verify by fetching from other repositories or websites.

2. **Increase Git Buffer Size**:
   - Set `http.postBuffer` to a larger value to accommodate larger repositories or slower connections:

     ```bash
     git config --global http.postBuffer 524288000
     ```

3. **Retry Fetch Operation**:
   - After adjusting the buffer size, retry the `git fetch` command.

4. **Verify Server Status**:
   - Ensure the Git server is operational and not experiencing downtime.
   - Contact server administrators for updates if needed.

5. **Switch to SSH**:
   - If using HTTPS, switch to SSH for potentially more reliable connections:

     ```bash
     git remote set-url origin git@github.com:username/repository.git
     ```

6. **Verbose Mode**:
   - Use `--verbose` option for `git fetch` to get detailed debug information:

     ```bash
     git fetch --verbose
     ```

7. **Update Git**:
   - Ensure you are using the latest Git version to fix bugs related to network operations.

8. **Contact Support**:
   - If issues persist, contact the support team for the Git hosting service or server administrators.

---

Here's a comprehensive list of essential Git commands that cover various aspects of version control, from initializing a repository to collaborating with others:

### Setup and Configuration

1. **git init**
   - Initialize a new Git repository locally.

2. **git clone [url]**
   - Clone a repository from a remote server to your local machine.

3. **git config**
   - Set or get configuration options.

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "youremail@example.com"
   ```

### Basic Snapshotting

4. **git add**
   - Add file contents to the index (staging area) for the next commit.

   ```bash
   git add <file>
   git add .
   ```

5. **git status**
   - Show the working tree status.

6. **git diff**
   - Show changes between commits, commit and working tree, etc.

   ```bash
   git diff
   git diff --staged
   ```

7. **git commit**
   - Record changes to the repository.

   ```bash
   git commit -m "Commit message"
   ```

### Branching and Merging

8. **git branch**
   - List, create, or delete branches.

   ```bash
   git branch
   git branch <branch_name>
   git branch -d <branch_name>
   ```

9. **git checkout**
   - Switch branches or restore working tree files.

   ```bash
   git checkout <branch_name>
   git checkout -b <new_branch>
   ```

10. **git merge**
    - Join two or more development histories together.

    ```bash
    git merge <branch_name>
    ```

### Remotes

11. **git remote**
    - Manage set of tracked repositories.

    ```bash
    git remote add origin <remote_url>
    git remote -v
    ```

12. **git fetch**
    - Download objects and refs from another repository.

    ```bash
    git fetch <remote>
    ```

13. **git pull**
    - Fetch from and integrate with another repository or a local branch.

    ```bash
    git pull <remote> <branch>
    ```

14. **git push**
    - Update remote refs along with associated objects.

    ```bash
    git push <remote> <branch>
    ```

### Undoing Changes

15. **git reset**
    - Reset current HEAD to the specified state.

    ```bash
    git reset --soft HEAD~1
    git reset --hard HEAD
    ```

16. **git revert**
    - Revert commits.

    ```bash
    git revert <commit>
    ```

17. **git checkout -- <file>**
    - Discard changes in the working directory.

    ```bash
    git checkout -- <file>
    ```

### Inspection and Comparison

18. **git log**
    - Show commit logs.

    ```bash
    git log
    ```

19. **git show**
    - Show various types of objects.

    ```bash
    git show <commit>
    ```

20. **git blame**
    - Show what revision and author last modified each line of a file.

    ```bash
    git blame <file>
    ```

### Git Submodules

21. **git submodule**
    - Initialize, update, or inspect submodules.

    ```bash
    git submodule add <repo_url>
    git submodule update --init --recursive
    ```

### Miscellaneous

22. **git tag**
    - Create, list, delete or verify a tag object signed with GPG.

    ```bash
    git tag
    git tag -a v1.0 -m "Version 1.0"
    ```

23. **git stash**
    - Stash changes in a dirty working directory away.

    ```bash
    git stash
    git stash pop
    ```

24. **git clean**
    - Remove untracked files from the working tree.

    ```bash
    git clean -n   # Dry run
    git clean -f   # Force remove
    ```

To pull a remote branch and override local files and everything else with the latest changes from the remote branch, you can follow these steps:

### Option 1: Using `git fetch` and `git reset` (Recommended)

1. **Fetch the Latest Changes from Remote:**

   First, fetch the latest changes from the remote repository. This updates your local copy of the remote branches without merging any changes into your local branches.

   ```bash
   git fetch origin
   ```

   Replace `origin` with the name of your remote if it's different.

2. **Reset Local Branch to Match Remote:**

   After fetching, reset your local branch to match the remote branch. This will move the HEAD and the branch pointer to the latest commit on the remote branch, effectively discarding any local changes and making your local branch identical to the remote branch.

   ```bash
   git reset --hard origin/<branch_name>
   ```

   Replace `<branch_name>` with the name of the remote branch you want to pull and reset to.

### Option 2: Using `git pull` with `--force` (Use with Caution)

Alternatively, you can use `git pull` with the `--force` or `-f` option to forcefully overwrite local changes. This option should be used carefully as it discards all local changes without prompting.

```bash
git pull origin <branch_name> --force
```

Replace `<branch_name>` with the name of the remote branch you want to pull forcefully.

**Note:** Using `git reset --hard` or `git pull --force` will discard all local changes and commits that are not in the remote branch. This action cannot be undone easily, so ensure you really want to discard local changes before proceeding.

### Additional Notes

- **Commit or Stash Local Changes:** Before performing a forceful pull or reset, it's a good practice to commit your local changes if they are ready to be committed, or stash them using `git stash` (`git stash save` in older versions of Git) if you want to temporarily save them.

- **Backup Important Changes:** If you have critical changes that you might need later, make sure to back them up elsewhere before proceeding with any destructive operation.

- **Review Changes Carefully:** Forceful operations can lead to irreversible data loss. Always review what changes are being discarded before proceeding.

By following these steps, you can effectively pull a remote branch and override all local changes with the latest state from the remote repository.

To merge multiple files in Git and either accept all incoming changes (the remote version) or resolve conflicts by choosing the remote version (or other options), you can use Git's merge strategies and tools. Here’s how you can approach it:

### Merging and Accepting Incoming Changes

1. **Fetch and Merge Changes from Remote:**

   First, ensure you have the latest changes from the remote repository fetched into your local repository:

   ```bash
   git fetch origin
   ```

   Replace `origin` with the name of your remote if it's different.

2. **Merge with `git merge` using `--strategy-option=theirs`:**

   The `theirs` merge strategy resolves conflicts by choosing the changes from the branch being merged in (in this case, the remote branch). To merge and accept all incoming changes from the remote branch, you can use:

   ```bash
   git merge origin/<branch_name> --strategy-option=theirs
   ```

   Replace `<branch_name>` with the name of the remote branch you want to merge from.

   This will merge the specified branch (`origin/<branch_name>`) into your current branch, resolving conflicts by accepting changes from the incoming branch (theirs).

### Accepting All Incoming Changes (Non-Interactive)

If you want to perform a non-interactive merge where all conflicts are automatically resolved by accepting incoming changes, you can use:

```bash
git merge origin/<branch_name> --strategy=recursive --strategy-option=theirs
```

This command specifies the `recursive` merge strategy with the `theirs` option, ensuring all conflicts are resolved by accepting the incoming version.

### Handling Merge Conflicts (Manual Resolution)

If there are conflicts that Git cannot automatically resolve (for example, conflicting changes in the same part of a file), Git will mark these files as conflicted. You will need to manually resolve these conflicts:

1. Git will mark conflicted files. Open each conflicted file in your text editor.
2. Locate and edit the conflicting sections to choose the version you want to keep.
3. Remove the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) and save the file.
4. Add the resolved files to the staging area:

   ```bash
   git add <resolved_file>
   ```

5. Commit the merge:

   ```bash
   git commit -m "Merge branch 'origin/<branch_name>'"
   ```

### Additional Options

- **Abort Merge:** If you encounter issues during the merge and want to start over, you can abort the merge with:

  ```bash
  git merge --abort
  ```

- **Visual Merge Tools:** Git also supports various visual merge tools (`git mergetool`) that can help you resolve conflicts interactively.

By following these steps, you can merge multiple files in Git while accepting all incoming changes from the specified branch or resolving conflicts manually as needed. Adjust commands based on your specific repository setup and workflow requirements.

If you want to completely override local files with the versions from the remote repository without merging or keeping any local changes, you can use the following approach:

### Option 1: Resetting the Branch

1. **Fetch the Latest Changes from Remote:**

   Ensure you have the latest changes from the remote repository fetched into your local repository:

   ```bash
   git fetch origin
   ```

   Replace `origin` with the name of your remote if it's different.

2. **Reset the Local Branch to Match Remote:**

   Use `git reset --hard` to move the current branch (`HEAD`) to the latest commit on the remote branch, discarding any local changes and making your working directory match exactly with the remote branch:

   ```bash
   git reset --hard origin/<branch_name>
   ```

   Replace `<branch_name>` with the name of the remote branch you want to reset to.

### Option 2: Checking Out a Fresh Copy

Alternatively, if you want to start fresh and ensure all files are exactly as they are on the remote branch, you can delete the local branch and checkout a new copy from the remote:

1. **Delete the Local Branch:**

   If you're okay with deleting the local branch and recreating it from the remote:

   ```bash
   git branch -D <branch_name>
   ```

   This deletes the local branch `<branch_name>`. Be careful as this is a destructive operation and cannot be undone easily.

2. **Checkout a Fresh Copy from Remote:**

   Check out the branch again from the remote repository:

   ```bash
   git fetch origin
   git checkout -b <branch_name> origin/<branch_name>
   ```

   This creates a new local branch `<branch_name>` tracking the remote branch and checks it out.

### Notes

- **Data Loss Warning:** Both approaches (`git reset --hard` and deleting the local branch) will discard all local changes that are not committed. This action cannot be undone easily, so ensure you have backups or have committed important changes before proceeding.

- **Force Push Considerations:** If you've already pushed changes from this branch to a remote repository and you reset it locally, you may need to force push (`git push --force`) the changes to update the remote branch with the overridden version. Be cautious with force pushing as it can overwrite others' work.

- **Safety Measures:** Always double-check and ensure you're performing these operations on the correct branch and repository to avoid accidental data loss.

By following these steps, you can effectively override local files with the exact versions from the remote branch in your Git repository. Adjust commands based on your specific repository setup and workflow requirements.

To reset a branch in Git means to move the branch pointer to a specific commit, optionally modifying the working directory and staging area to match the state of that commit. Here’s how you can reset a branch:

### Types of Reset

Git provides different modes for resetting a branch, primarily using `git reset` command with different options:

1. **Soft Reset (`git reset --soft`):**
   - Moves the branch pointer to the specified commit.
   - Leaves working directory and index (staging area) unchanged.
   - Changes are staged for commit.

   ```bash
   git reset --soft <commit>
   ```

2. **Mixed Reset (`git reset --mixed` or `git reset`):**
   - Default mode if no option is provided.
   - Moves the branch pointer to the specified commit.
   - Resets the index (staging area) to match the specified commit.
   - Working directory is unchanged.
   - Changes are not staged for commit.

   ```bash
   git reset <commit>
   ```

3. **Hard Reset (`git reset --hard`):**
   - Moves the branch pointer to the specified commit.
   - Resets the index (staging area) to match the specified commit.
   - Resets the working directory to match the specified commit.
   - Discards all changes in the working directory and staging area that are not committed.

   ```bash
   git reset --hard <commit>
   ```

### Steps to Reset a Branch

Here’s how you can perform a reset on a branch using the `git reset` command:

1. **Identify the Commit to Reset To:**
   - Determine which commit you want to move the branch pointer to. This can be a commit hash, a branch name, or `HEAD~n` (n is the number of commits back).

2. **Perform the Reset:**
   - Choose the appropriate reset mode (`--soft`, `--mixed`, or `--hard`) based on your requirements.

   ```bash
   # Example: Resetting branch 'mybranch' to a specific commit with a hard reset
   git reset --hard <commit>
   ```

   Replace `<commit>` with the commit hash, branch name, or `HEAD~n` as needed.

3. **Pushing Changes (if necessary):**
   - If you've already pushed changes to a remote repository and reset the branch locally, you may need to force push (`git push --force`) to update the remote branch. Be cautious with force pushing as it can overwrite others' work.

### Example Scenarios

- **Soft Reset:** Useful if you want to keep changes in the working directory and staging area as staged changes.

  ```bash
  git reset --soft HEAD~1
  ```

- **Mixed Reset:** Default mode; useful if you want to keep changes in the working directory but unstage them.

  ```bash
  git reset HEAD~1
  ```

- **Hard Reset:** Discards all changes in the working directory and staging area, resetting them to match the specified commit.

  ```bash
  git reset --hard HEAD~1
  ```

### Safety Considerations

- **Data Loss:** Hard reset (`--hard`) will discard all changes in the working directory and staging area that are not committed. Use with caution and ensure you have backups of any important changes.

- **Branch Protection:** If the branch has been pushed to a remote repository and shared with others, coordinate with your team before performing a reset, especially a hard reset (`--hard`).

By following these steps and understanding the different reset modes (`--soft`, `--mixed`, `--hard`), you can effectively reset a branch in Git to a specific commit, adjusting your working directory and staging area as needed. Adjust commands based on your specific requirements and Git workflow.

To checkout a single file from a remote branch in Git, you can use the `git checkout` command with the path to the file you want to retrieve. Here’s how you can do it:

### Syntax

```bash
git checkout <remote_branch_name> -- <file_path>
```

### Steps

1. **Fetch Latest Changes from Remote:**

   Before checking out a file from a remote branch, ensure you have the latest changes from the remote repository fetched into your local repository:

   ```bash
   git fetch origin
   ```

   Replace `origin` with the name of your remote if it's different.

2. **Checkout the File:**

   Use the `git checkout` command to retrieve the file from the specified remote branch:

   ```bash
   git checkout origin/<remote_branch_name> -- path/to/file
   ```

   - Replace `<remote_branch_name>` with the name of the remote branch you want to retrieve the file from.
   - Replace `path/to/file` with the path to the specific file you want to checkout from the remote branch.

### Example

For example, to retrieve a file named `README.md` from a remote branch named `feature/123`:

```bash
git checkout origin/feature/123 -- README.md
```

This command will fetch the `README.md` file from the `feature/123` branch on the remote repository (`origin`) and overwrite your local `README.md` with the version from that branch.

### Notes

- **Local Changes:** Any local modifications to the file will be overwritten by the version from the remote branch. Make sure you have committed or stashed any local changes you want to keep.

- **Branch Name:** Ensure you provide the correct remote branch name (`origin/branch_name`) and the correct path to the file relative to the root of the repository.

By following these steps, you can checkout a single file from a remote branch in Git, allowing you to retrieve specific files without having to checkout the entire branch. Adjust the file path and branch name according to your specific repository structure and needs.

To merge a branch named `uat` into another branch named `production` in Git, you would follow these steps:

### Steps to Merge Branch `uat` into Branch `production`

1. **Checkout the Target Branch (`production`):**

   First, switch to the branch (`production`) into which you want to merge `uat`:

   ```bash
   git checkout production
   ```

2. **Fetch the Latest Changes from Remote (Optional):**

   It's a good practice to fetch the latest changes from the remote repository to ensure you have the most up-to-date history of branches:

   ```bash
   git fetch origin
   ```

   Replace `origin` with the name of your remote if it's different.

3. **Merge Branch `uat` into `production`:**

   Once you are on the `production` branch and have the latest changes fetched, you can merge the `uat` branch into it using `git merge`:

   ```bash
   git merge uat
   ```

   This command merges all the changes from the `uat` branch into your current branch (`production`), creating a new merge commit if there are divergent changes between the two branches.

### Resolving Merge Conflicts (if any)

If there are conflicts during the merge (conflicting changes in the same part of a file), Git will pause the merge process and ask you to resolve those conflicts manually. Follow the steps mentioned earlier under "Resolving Merge Conflicts" in the previous response.

### Pushing Changes (if necessary)

After completing the merge and resolving any conflicts, push the changes to the remote repository:

```bash
git push origin production
```

Replace `origin` with the name of your remote repository and `production` with the branch name.

### Additional Notes

- **Testing:** After merging `uat` into `production`, it's essential to thoroughly test the merged code in the `production` environment to ensure it works as expected.
  
- **Branch Cleanup:** Once the merge is successful and tested, you might want to delete the `uat` branch if it's no longer needed:

  ```bash
  git branch -d uat
  ```

  Use `-D` instead of `-d` to force delete the branch if it hasn't been fully merged yet.

By following these steps, you can effectively merge changes from branch `uat` into branch `production` in your Git repository. Adjust branch names and repository specifics according to your actual setup and workflow.

These are the core Git commands that cover the majority of typical workflows and tasks. Adjust parameters and options according to your specific needs and preferences.

This README provides a comprehensive list of commands and troubleshooting steps to help you effectively manage Git operations and resolve common issues. Adjust paths and URLs as per your specific environment and repository settings.
