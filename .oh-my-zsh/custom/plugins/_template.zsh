# =============================================================================
# Plugin Template
# =============================================================================
# Use this file as a template when creating new plugins.
#
# Instructions:
# 1. Copy this file and rename to the tool name (e.g., mytool.zsh)
# 2. Add initialization/config commands for the tool
# 3. The file will be sourced automatically by .zshrc
#
# Guidelines:
# - Keep plugin initialization simple (one tool per file)
# - Handle missing tools gracefully (check if command exists)
# - Use 'command -v' to check for availability before init
#
# Example:
#   if command -v mytool &>/dev/null; then
#     eval "$(mytool init zsh)"
#   fi
# =============================================================================

# Check if the tool is installed
# if command -v <tool-command> &>/dev/null; then
#   # Initialize the tool
#   eval "$(<tool-command> init zsh)"
# fi
