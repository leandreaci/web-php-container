#!/bin/sh
set -e

# Optional: install sqlplus CLI if needed alongside Instant Client installed by install-php-extensions
if [ -d "/usr/lib/oracle" ] || [ -d "/opt/oracle" ]; then
    echo "Oracle Instant Client and OCI8 extension already installed."
fi

