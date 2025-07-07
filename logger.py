# PATCH-P0005: simple project logger
import logging

from config import LOG_LEVEL

level = getattr(logging, LOG_LEVEL.upper(), logging.DEBUG)
logging.basicConfig(level=level)
logger = logging.getLogger(__name__)
