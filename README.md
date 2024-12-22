# Git Scanner

A security analysis tool that automates GitLeaks scanning across multiple GitHub repositories.

## Features

- Bulk repository scanning
- Smart repository handling (skips existing repos)
- Automatic repository cloning and cleanup
- JSON formatted scan results
- Progress tracking and error handling
- Cross-platform compatibility (macOS, Linux)
- Working directory safety checks

## Requirements

To use this tool, you need:

- Git
- GitLeaks
- curl
- jq (JSON processor)

For macOS, install using Homebrew:

    brew install gitleaks jq

## Installation

Clone the repository:

    git clone https://github.com/yourusername/git-scanner.git
    cd git-scanner
    chmod +x scan_repos.sh

## Usage

Scan all repositories for a user or organization:

    ./git-scanner.sh <github-user-or-org>

The script accepts both usernames and full GitHub URLs:

    ./git-scanner.sh microsoft
    ./git-scanner.sh https://github.com/microsoft/

Before scanning, the script will:
1. Show your current working directory
2. Ask for confirmation before proceeding
3. Check for existing repositories

Note: The script will NOT delete existing repositories in your working directory.

## Output Structure

Results are saved in the results directory with the following structure:

    results/
    ├── repo1/
    │   └── scan_results.json
    ├── repo2/
    │   └── scan_results.json
    └── repo3/
        └── scan_results.json

## Scan Results

Each scan produces a JSON file containing:
- Repository metadata
- Detected secrets or sensitive data
- Scan timestamp
- File locations and line numbers

## Error Handling

The script handles:
- Missing dependencies
- Failed repository clones
- API rate limiting
- Invalid usernames/organizations
- Network connectivity issues
- Existing repository detection
- Working directory verification
- Organization vs user repository detection

## Security Notes

- Results may contain sensitive data - handle with care
- Default scan uses public API access
- Consider rate limiting for large organizations
- Clean up results after analysis
- Follow responsible disclosure practices

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

MIT License

## Author

@johnforfar

## Acknowledgments

- GitLeaks Project
- GitHub API Documentation

## Future Improvements

- GitHub token support
- Custom GitLeaks rules
- Parallel scanning
- HTML report generation
- Slack/Discord notifications
- Repository filtering options
- Dry-run mode
- Force re-clone option
- Custom working directory support
- Enhanced logging options