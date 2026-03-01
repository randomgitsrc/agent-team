#!/bin/bash
cd ~/projects/personal/taskflow
source venv/bin/activate
taskflow list --status in_progress >> ~/.openclaw/workspace/memory/logs/taskflow-morning.log 2>&1
