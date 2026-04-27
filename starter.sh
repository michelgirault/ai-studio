#!/bin/bash
set -e

# Make sure persistent dirs exist on the workspace volume
mkdir -p /workspace/aistudio/.huggingface/hub \
         /workspace/aistudio/.huggingface/datasets \
         /workspace/aistudio/.aws \
         /workspace/aistudio/notebooks \
         /workspace/aistudio/datasets \
         /workspace/aistudio/checkpoints \
         /workspace/aistudio/models

# Show GPU info
echo "=== GPU ==="
nvidia-smi || echo "No GPU detected"
echo ""

# Show storage
echo "=== Workspace ==="
df -h /workspace/aistudio/ 2>/dev/null || true
echo ""

# Launch JupyterLab
# - bound to 0.0.0.0 so RunPod can proxy it
# - root_dir is /workspace so notebooks live on persistent volume
# - token auth (printed in logs)
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --ServerApp.root_dir=/workspace/aistudio/ \
    --ServerApp.allow_origin='*' \
    --ServerApp.allow_remote_access=True \
    --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}'