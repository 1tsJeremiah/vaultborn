# PATCH-P0005: default log level configuration
import os

# Environment variable LOG_LEVEL; defaults to DEBUG if not set
LOG_LEVEL = os.getenv('LOG_LEVEL', 'DEBUG')
