#!/usr/bin/env bash

# Clone a repository as bare for worktree usage
# Based on: https://morgan.cugerone.com/blog/workarounds-to-git-worktree-using-bare-repository-and-cannot-fetch-remote-branches/

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handling
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Cleanup function
cleanup() {
    if [[ -n "${basename:-}" ]] && [[ -d "$basename" ]] && [[ "$cleanup_on_error" == "true" ]]; then
        echo -e "${YELLOW}Cleaning up failed clone...${NC}"
        rm -rf "$basename"
    fi
}

trap cleanup EXIT
cleanup_on_error=false

# Parse arguments
url=""
basename=""
skip_default_worktree=false
shallow=false

usage() {
    echo "Usage: git clone-for-worktrees [options] <repository-url> [directory-name]"
    echo ""
    echo "This clones a repository as bare and sets it up for worktree usage."
    echo "The repository will be cloned to <directory-name>/.bare"
    echo "A default worktree for the main branch will be created at <directory-name>/<main-branch>"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -n, --no-worktree       Skip creating the default worktree"
    echo "  -s, --shallow           Create a shallow clone (depth=1)"
    echo ""
    echo "Examples:"
    echo "  git clone-for-worktrees https://github.com/user/repo.git"
    echo "  git clone-for-worktrees git@github.com:user/repo.git my-project"
    echo "  git clone-for-worktrees --no-worktree git@github.com:user/repo.git"
    echo "  git clone-for-worktrees --shallow https://github.com/user/repo.git"
    exit ${1:-0}
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage 0
            ;;
        -n|--no-worktree)
            skip_default_worktree=true
            shift
            ;;
        -s|--shallow)
            shallow=true
            shift
            ;;
        -*)
            error "Unknown option: $1\nRun with --help for usage information."
            ;;
        *)
            if [[ -z "$url" ]]; then
                url="$1"
            elif [[ -z "$basename" ]]; then
                basename="$1"
            else
                error "Too many arguments provided"
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$url" ]]; then
    usage 1
fi

# Validate URL format
if ! [[ "$url" =~ ^(https?://|git@|ssh://|git://) ]]; then
    error "Invalid repository URL format: $url"
fi

# Extract basename from URL if not provided
if [[ -z "$basename" ]]; then
    # Handle various URL formats including SSH with custom ports
    basename=$(echo "$url" | sed -E 's|.*/||; s|\.git$||; s|:.*||')
    basename=${basename##*/}
fi

# Validate basename
if [[ -z "$basename" ]]; then
    error "Could not determine repository name from URL"
fi

# Check if directory already exists
if [[ -e "$basename" ]]; then
    error "Directory '$basename' already exists"
fi

# Enable cleanup on error from this point
cleanup_on_error=true

# Clone the repository as bare
echo -e "${GREEN}Cloning $url as bare repository to $basename/.bare${NC}"
if [[ "$shallow" == "true" ]]; then
    git clone --bare --depth 1 "$url" "$basename/.bare" || error "Failed to clone repository"
else
    git clone --bare "$url" "$basename/.bare" || error "Failed to clone repository"
fi

# Enter the repository directory
cd "$basename/.bare" || error "Failed to enter repository directory"

# Configure fetch to get all branches
echo -e "${GREEN}Configuring repository for worktree usage...${NC}"
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" || error "Failed to configure fetch"

# Fetch all remote branches (skip for shallow clones)
if [[ "$shallow" != "true" ]]; then
    echo -e "${GREEN}Fetching all remote branches...${NC}"
    git fetch origin || error "Failed to fetch remote branches"
fi

# Get the default branch name
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "")

# If we couldn't determine the default branch, try common names
if [[ -z "$default_branch" ]]; then
    for branch in main master; do
        if git show-ref --verify --quiet "refs/heads/$branch" || git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
            default_branch="$branch"
            break
        fi
    done
fi

if [[ -z "$default_branch" ]]; then
    error "Could not determine default branch"
fi

# Create a .git file that points to the bare repository
cd .. || error "Failed to change directory"
echo "gitdir: .bare" > .git

# Create the first worktree for the default branch (unless skipped)
if [[ "$skip_default_worktree" != "true" ]]; then
    echo -e "${GREEN}Creating worktree for $default_branch branch...${NC}"
    cd .bare || error "Failed to enter .bare directory"
    git worktree add "../$default_branch" "$default_branch" || error "Failed to create worktree"
else
    echo -e "${YELLOW}Skipping default worktree creation${NC}"
    cd .bare || error "Failed to enter .bare directory"
fi

# Create a helper script for easier worktree management
cat > ../add-worktree.sh << 'EOF'
#!/usr/bin/env bash
# Helper script to add new worktrees

branch=$1
if [[ -z "$branch" ]]; then
    echo "Usage: ./add-worktree.sh <branch-name>"
    echo "This will create a new worktree for the specified branch"
    exit 1
fi

# Check if we need to fetch the branch first
if ! git -C .bare show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    echo "Fetching branch $branch from remote..."
    git -C .bare fetch origin "$branch:refs/remotes/origin/$branch"
fi

# Create the worktree
echo "Creating worktree for branch $branch..."
git -C .bare worktree add "$branch" "$branch" || git -C .bare worktree add "$branch" -b "$branch" "origin/$branch"

echo "Worktree created at ./$branch"
EOF

chmod +x ../add-worktree.sh

# Disable cleanup on successful completion
cleanup_on_error=false

# Show summary
echo ""
echo -e "${GREEN}✅ Repository cloned successfully!${NC}"
echo ""
echo "📁 Structure:"
echo "   $basename/"
echo "   ├── .bare/          # Bare repository (git database)"
echo "   ├── .git            # Points to .bare"
if [[ "$skip_default_worktree" != "true" ]]; then
    echo "   ├── $default_branch/          # Worktree for $default_branch branch"
fi
echo "   └── add-worktree.sh # Helper to add new worktrees"
echo ""
echo "🔧 To add a new worktree:"
echo "   cd $basename"
echo "   ./add-worktree.sh <branch-name>"
echo ""
echo "📝 Useful commands:"
echo "   git -C .bare worktree list           # List all worktrees"
echo "   git -C .bare worktree remove <path>  # Remove a worktree"
echo "   git -C .bare fetch --all             # Fetch all branches"
if [[ "$shallow" == "true" ]]; then
    echo ""
    echo -e "${YELLOW}Note: This is a shallow clone. To fetch full history:${NC}"
    echo "   git -C $basename/.bare fetch --unshallow"
fi