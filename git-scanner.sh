#!/bin/bash

# GitLeaks Repository Scanner
# This script clones all repositories from a given GitHub user/organization
# and runs GitLeaks against each one.

# Check if required tools are installed
check_requirements() {
    local requirements=("git" "gitleaks" "curl" "jq")
    for cmd in "${requirements[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: $cmd is required but not installed."
            echo "Please install the required tools:"
            echo "  - git: Built into macOS or 'brew install git'"
            echo "  - GitLeaks: brew install gitleaks"
            echo "  - curl: Built into macOS"
            echo "  - jq: brew install jq"
            exit 1
        fi
    done
}

# Function to get all repository URLs for a GitHub user/org
get_repos() {
    local target=$1
    local page=1
    local per_page=100
    local repos=()
    
    # Clean the target name (remove https://github.com/ if present)
    target=${target#"https://github.com/"}
    target=${target%"/"}
    
    # Try organization endpoint first
    while true; do
        local response=$(curl -s "https://api.github.com/orgs/$target/repos?page=$page&per_page=$per_page")
        
        # If org request fails, try user endpoint
        if [[ $(echo "$response" | jq -r 'if type=="object" and has("message") then .message else empty end') == "Not Found" ]]; then
            response=$(curl -s "https://api.github.com/users/$target/repos?page=$page&per_page=$per_page")
        fi
        
        local batch=($(echo "$response" | jq -r '.[].clone_url'))
        
        if [ ${#batch[@]} -eq 0 ]; then
            break
        fi
        
        repos+=("${batch[@]}")
        ((page++))
    done

    echo "${repos[@]}"
}

# Function to clone and scan a single repository
scan_repo() {
    local repo_url=$1
    local repo_name=$(basename "$repo_url" .git)
    
    echo "Processing repository: $repo_name"
    
    # Check if repository already exists
    if [ -d "$repo_name" ]; then
        echo "Repository $repo_name already exists locally - skipping clone"
        local use_existing=true
    else
        # Clone the repository
        if git clone "$repo_url" "$repo_name" 2>/dev/null; then
            echo "Successfully cloned $repo_name"
            local use_existing=false
        else
            echo "Error: Failed to clone $repo_name"
            return 1
        fi
    fi
    
    # Create output directory for results
    mkdir -p "results/$repo_name"
    
    # Run GitLeaks
    echo "Running GitLeaks scan on $repo_name..."
    if gitleaks detect -s "./$repo_name" --report-format json --report-path "results/$repo_name/scan_results.json"; then
        echo "Scan completed for $repo_name"
    else
        echo "Warning: GitLeaks scan found potential secrets in $repo_name"
    fi
    
    # Cleanup only if we cloned it
    if [ "$use_existing" = false ]; then
        rm -rf "$repo_name"
    fi
}

# Main function to process all repositories
scan_all_repos() {
    local target=$1
    local current_dir=$(pwd)
    
    # Warn user about working directory
    echo "This script will:"
    echo "1. Create a 'results' directory in: $current_dir"
    echo "2. Temporarily clone repositories here"
    echo "3. Generate scan results in: $current_dir/results"
    echo ""
    read -p "Continue in current directory? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        exit 1
    fi
    
    # Get all repository URLs
    echo "Fetching repository list for $target..."
    local repos=($(get_repos "$target"))
    
    if [ ${#repos[@]} -eq 0 ]; then
        echo "Error: No repositories found or invalid user/org name"
        exit 1
    fi
    
    echo "Found ${#repos[@]} repositories"
    
    # Create results directory
    mkdir -p results
    
    # Process each repository
    for repo in "${repos[@]}"; do
        scan_repo "$repo"
    done
    
    echo "Scan complete! Results are stored in the 'results' directory"
}

# Script usage information
usage() {
    echo "Usage: $0 <github-user-or-org>"
    echo "Example: $0 microsoft"
    exit 1
}

# Main script execution
main() {
    # Check arguments
    if [ $# -ne 1 ]; then
        usage
    fi
    
    # Check requirements
    check_requirements
    
    # Run the scanner
    scan_all_repos "$1"
}

# Execute main function with all arguments
main "$@"