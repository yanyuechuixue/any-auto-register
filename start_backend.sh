#!/usr/bin/env bash

set -e

# ===== 参数设置 =====
ENV_NAME="any-auto-register"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"
RESTART_EXISTING="${RESTART_EXISTING:-1}"

# ===== 检查 conda =====
if ! command -v conda >/dev/null 2>&1; then
  echo "[ERROR] 未找到 conda 命令。请先安装 Miniconda/Anaconda，并确保 conda 可在终端中使用。"
  exit 1
fi

# ===== 进入脚本所在目录 =====
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "[INFO] 项目目录: $PWD"
echo "[INFO] 使用 conda 环境: $ENV_NAME"
echo "[INFO] 启动后端: http://localhost:$PORT"
echo "[INFO] 按 Ctrl+C 可停止服务"

# ===== 清理旧进程 =====
if [ "$RESTART_EXISTING" = "1" ]; then
  echo "[INFO] 启动前先清理旧的后端 / Solver 进程"
  # 假设你有一个对应的 shell 脚本版本
  if [ -f "$SCRIPT_DIR/stop_backend.sh" ]; then
    bash "$SCRIPT_DIR/stop_backend.sh" "$PORT" 8889 0
  else
    echo "[WARN] 未找到 stop_backend.sh，跳过清理步骤"
  fi
fi

# ===== 获取 python 路径 =====
PYTHON_EXE=$(conda run -n "$ENV_NAME" python -c "import sys; print(sys.executable)")

if [ ! -f "$PYTHON_EXE" ]; then
  echo "[ERROR] 无法解析 conda 环境 \"$ENV_NAME\" 对应的 python 路径。"
  exit 1
fi

echo "[INFO] Python: $PYTHON_EXE"

# ===== 启动服务 =====
"$PYTHON_EXE" main.py
