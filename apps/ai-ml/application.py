#!/usr/bin/env python3
"""
Application entry point for uWSGI
"""

from app import app

# uWSGI will look for this variable
application = app

if __name__ == "__main__":
    app.run()
