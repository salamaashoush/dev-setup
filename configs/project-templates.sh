#!/usr/bin/env bash
# Project template creation functions

# Quick project creation using templates
project() {
    local name="$1"
    local type="${2:-node}"
    local templates_dir="$HOME/.config/project-templates"
    
    if [ -z "$name" ]; then
        echo "Usage: project <name> [type]"
        echo "Types: node, rust, cpp"
        return 1
    fi
    
    if [ ! -d "$templates_dir/$type" ]; then
        echo "Template '$type' not found in $templates_dir"
        return 1
    fi
    
    # Create project directory
    mkdir -p "$name" && cd "$name"
    
    # Initialize based on type
    case "$type" in
        "rust")
            # Initialize with cargo first
            cargo init --name "$name"
            # Copy additional template files
            cp -r "$templates_dir/$type"/. .
            ;;
        # REMOVED: Go template
        # "go")
        #     # Initialize go module first
        #     go mod init "$name"
        #     # Copy template files
        #     cp -r "$templates_dir/$type"/. .
        #     ;;
        *)
            # Copy template files for other types
            cp -r "$templates_dir/$type"/. .
            ;;
    esac
    
    # Replace PROJECT_NAME placeholder in all files
    if [[ "$OSTYPE" == "darwin"* ]]; then
        find . -type f -name "*.json" -o -name "*.toml" -o -name "*.ts" -o -name "*.js" -o -name "*.rs" -o -name "*.cpp" -o -name "*.hpp" -o -name "*.h" -o -name "*.txt" -o -name "*.md" -o -name "justfile" -o -name "CMakeLists.txt" | \
        xargs sed -i '' "s/PROJECT_NAME/$name/g"
    else
        find . -type f -name "*.json" -o -name "*.toml" -o -name "*.ts" -o -name "*.js" -o -name "*.rs" -o -name "*.cpp" -o -name "*.hpp" -o -name "*.h" -o -name "*.txt" -o -name "*.md" -o -name "justfile" -o -name "CMakeLists.txt" | \
        xargs sed -i "s/PROJECT_NAME/$name/g"
    fi
    
    # REMOVED: Python package handling
    
    # Special handling for C++ include directory
    if [[ "$type" == "cpp" ]] && [[ -d "include/PROJECT_NAME" ]]; then
        mv "include/PROJECT_NAME" "include/$name"
    fi
    
    # Post-initialization steps
    case "$type" in
        "node")
            echo "Installing dependencies with pnpm..."
            pnpm install
            ;;
        # REMOVED: Python template
        # "python")
        #     echo "Creating virtual environment..."
        #     uv venv
        #     echo "Activate with: source .venv/bin/activate"
        #     echo "Then install deps: uv pip install -e '.[dev]'"
        #     ;;
        "rust")
            echo "Building project..."
            cargo build
            ;;
        # REMOVED: Go post-init
        # "go")
        #     echo "Tidying modules..."
        #     go mod tidy
        #     ;;
        "cpp")
            echo "Configuring CMake project..."
            just configure
            echo "Building project..."
            just build
            echo "Ready! Run: just run"
            ;;
    esac
    
    # Initialize git
    git init
    git add .
    git commit -m "Initial commit"
    
    echo ""
    echo "✨ Project '$name' created with '$type' template!"
    echo ""
    
    # Show next steps
    case "$type" in
        "node")
            echo "Next steps:"
            echo "  pnpm dev       # Start development server"
            echo "  pnpm test      # Run tests"
            echo "  pnpm lint      # Run linter"
            echo "  pnpm build     # Build for production"
            ;;
        "python")
            echo "Next steps:"
            echo "  source .venv/bin/activate"
            echo "  uv pip install -e '.[dev]'"
            echo "  just test      # Run tests"
            echo "  just check     # Run all checks"
            ;;
        "rust")
            echo "Next steps:"
            echo "  just run       # Run the project"
            echo "  just test      # Run tests"
            echo "  just check     # Run all checks"
            ;;
        "go")
            echo "Next steps:"
            echo "  just run       # Run the project"
            echo "  just test      # Run tests"
            echo "  just check     # Run all checks"
            ;;
        "cpp")
            echo "Next steps:"
            echo "  just run       # Run the project"
            echo "  just test      # Run tests"
            echo "  just format    # Format code"
            echo "  just analyze   # Run static analysis"
            echo "  just check     # Run all checks"
            ;;
    esac
}