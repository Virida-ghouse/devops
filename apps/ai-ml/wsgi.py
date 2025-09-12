#!/usr/bin/env python3
"""
WSGI entry point for VIRIDA AI/ML Prediction Engine
"""

import os
import sys

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(__file__))

from app import app

# This is the WSGI application that uWSGI will use
application = app

if __name__ == "__main__":
    app.run()