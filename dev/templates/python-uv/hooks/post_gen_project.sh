#!/bin/bash
# 生成されたディレクトリ（project_slugの中）で実行されます

# エラーがあれば停止
set -e

echo "🚀 Initializing project: {{ cookiecutter.project_slug }}..."

# uv の初期化
echo "Running uv init..."
uv init {{ cookiecutter.uv_init_type }} --managed-python --python {{ cookiecutter.python_version }}

echo "#secrets" >> ./.gitignore
echo ".env" >> ./.gitignore
echo "" >> ./.gitignore
echo "#mkdocs" >> ./.gitignore
echo "site/" >> ./.gitignore

echo "" >> ./pyproject.toml
echo "[tool.pyright]" >> ./pyproject.toml
echo 'venvPath = "."' >> ./pyproject.toml
echo 'venv = ".venv"' >> ./pyproject.toml

echo "✅ All done! Happy hacking!"
