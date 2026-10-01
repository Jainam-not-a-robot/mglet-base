#!/bin/bash
# =============================================================================
# install_deps.sh - Install the system packages needed to build mglet-base
#
# Run once (or after changing machines/OS packages), then use ./build.sh.
# Only installs what is actually missing; safe to run repeatedly.
#
# Usage:
#   ./install_deps.sh
# =============================================================================
set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[✗ ERROR]${NC} $1"; exit 1; }
step()    { echo -e "\n${BOLD}──── $1 ────${NC}"; }

# ── Detect OS ─────────────────────────────────────────────────────────────────
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"; ARCH=$(uname -m)
    elif [ -f /etc/debian_version ]; then
        OS="debian"; ARCH=$(uname -m)
    elif [ -f /etc/fedora-release ]; then
        OS="fedora"; ARCH=$(uname -m)
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"; ARCH=$(uname -m)
    elif [ -f /etc/arch-release ]; then
        OS="arch"; ARCH=$(uname -m)
    else
        OS="unknown"; ARCH=$(uname -m)
    fi
    NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    info "OS: $OS | Arch: $ARCH | CPUs: $NPROC"
}

has() { command -v "$1" &>/dev/null; }

# ── Install dependencies ──────────────────────────────────────────────────────
# Only installs what is actually missing; safe to run repeatedly.
ensure_deps() {
    step "Checking dependencies"

    case "$OS" in
      macos)
        if ! has brew; then
            info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
        fi

        brew_install() {
            local pkg=$1; local check=${2:-$pkg}
            if has "$check" || [ -d "/opt/homebrew/opt/$pkg" ]; then
                success "Already installed: $pkg"
            else
                info "Installing $pkg..."; brew install "$pkg"
            fi
        }

        brew_install gcc          gcc-15
        brew_install open-mpi     mpirun
        brew_install cmake
        brew_install ninja

        # hdf5-mpi conflicts with plain hdf5
        if [ -d "/opt/homebrew/opt/hdf5" ] && [ ! -d "/opt/homebrew/opt/hdf5-mpi" ]; then
            warning "plain hdf5 installed — unlinking for hdf5-mpi"
            brew unlink hdf5 2>/dev/null || true
        fi
        brew_install hdf5-mpi     /opt/homebrew/opt/hdf5-mpi/bin/h5pfc
        brew link hdf5-mpi 2>/dev/null || true
        ;;

      debian)
        sudo apt-get update -qq
        apt_install() {
            local pkg=$1; local check=${2:-$1}
            has "$check" && { success "Already installed: $pkg"; return; }
            info "Installing $pkg..."; sudo apt-get install -y "$pkg"
        }
        apt_install gcc; apt_install g++; apt_install gfortran
        apt_install cmake; apt_install ninja-build ninja
        apt_install libopenmpi-dev mpirun; apt_install openmpi-bin mpirun
        apt_install libhdf5-mpi-dev h5pfc; apt_install hdf5-tools h5pfc
        apt_install zlib1g-dev; apt_install git; apt_install curl
        ;;

      fedora)
        dnf_install() {
            local pkg=$1; local check=${2:-$1}
            has "$check" && { success "Already installed: $pkg"; return; }
            info "Installing $pkg..."; sudo dnf install -y "$pkg"
        }
        dnf_install gcc; dnf_install gcc-c++ g++; dnf_install gcc-gfortran gfortran
        dnf_install cmake; dnf_install ninja-build ninja
        dnf_install openmpi-devel mpirun; dnf_install hdf5-openmpi-devel h5pfc
        dnf_install zlib-devel; dnf_install git; dnf_install curl
        source /etc/profile.d/modules.sh 2>/dev/null || true
        module load mpi 2>/dev/null || true
        ;;

      rhel)
        sudo yum install -y gcc gcc-c++ gcc-gfortran cmake ninja-build \
            openmpi-devel hdf5-openmpi-devel zlib-devel git curl
        source /etc/profile.d/modules.sh 2>/dev/null || true
        module load mpi 2>/dev/null || true
        ;;

      arch)
        pacman_install() {
            local pkg=$1; local check=${2:-$1}
            has "$check" && { success "Already installed: $pkg"; return; }
            info "Installing $pkg..."; sudo pacman -Sy --noconfirm "$pkg"
        }
        pacman_install gcc; pacman_install cmake; pacman_install ninja
        pacman_install openmpi mpirun; pacman_install hdf5-openmpi h5pfc
        pacman_install zlib; pacman_install git; pacman_install curl
        ;;

      *)
        warning "Unknown OS — please install manually: gcc g++ gfortran cmake ninja openmpi hdf5-mpi"
        ;;
    esac

    success "Dependencies ready"
}

# ── Main ──────────────────────────────────────────────────────────────────────
detect_os
ensure_deps
