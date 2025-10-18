#!/bin/bash

BACKUP_DIR="/root/backups/pronas-ia"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "📦 Criando backup do sistema..."
echo ""

# Backup dos arquivos principais
tar -czf "$BACKUP_DIR/sistema_ia_$DATE.tar.gz" \
  backend/app/ai/ \
  backend/app/api/ai_assistant.py \
  backend/requirements.txt \
  .env \
  docker-compose.yml \
  test_sistema_completo.sh \
  README_SISTEMA_IA.md

echo "✅ Backup criado: $BACKUP_DIR/sistema_ia_$DATE.tar.gz"
echo ""

# Listar backups
echo "📋 Backups disponíveis:"
ls -lh $BACKUP_DIR/

# Manter apenas últimos 5 backups
cd $BACKUP_DIR
ls -t | tail -n +6 | xargs -r rm
