#!/bin/bash
# Shared utilities for platform-frontend scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print status with color
print_status() {
    local type="$1"
    shift
    local message="$*"

    case "$type" in
        header)
            echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${CYAN}${message}${NC}"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
            ;;
        info)
            echo -e "${BLUE}ℹ${NC} ${message}"
            ;;
        success)
            echo -e "${GREEN}✓${NC} ${message}"
            ;;
        warning)
            echo -e "${YELLOW}⚠${NC} ${message}"
            ;;
        error)
            echo -e "${RED}✗${NC} ${message}"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Get project root (monorepo root)
get_project_root() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(cd "$script_dir/.." && pwd)"
}

# Check if port is in use
check_port() {
    local port="$1"
    local service_name="$2"

    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_status "warning" "Port $port is already in use (possibly $service_name)"
        return 0
    fi
    return 1
}

# Kill process on port
kill_process_on_port() {
    local port="$1"
    local service_name="$2"

    local pid=$(lsof -ti:$port)
    if [[ -n "$pid" ]]; then
        print_status "info" "Killing process $pid on port $port..."
        kill -9 $pid 2>/dev/null
        sleep 1
        return 0
    fi
    return 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure pnpm is available
ensure_pnpm() {
    if ! command_exists pnpm; then
        print_status "error" "pnpm is not installed. Please install pnpm:"
        echo "  npm install -g pnpm"
        echo "  or"
        echo "  corepack enable && corepack prepare pnpm@latest --activate"
        exit 1
    fi
}

# Check Node.js version
check_node_version() {
    local required_major=22

    if ! command_exists node; then
        print_status "error" "Node.js is not installed"
        exit 1
    fi

    local node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ $node_version -lt $required_major ]]; then
        print_status "error" "Node.js $required_major+ required (found: $(node -v))"
        exit 1
    fi
}
