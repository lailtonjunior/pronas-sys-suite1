#!/usr/bin/env python3
"""
Inicializa as tabelas do banco de dados
"""
import sys
import os

# Adicionar o diretório app ao path
sys.path.insert(0, '/app')
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

print("🗄️  Inicializando banco de dados...")

try:
    from app.database.session import engine, Base
    from app.models.user import User
    from app.models.project import Project
    from app.models.anexo import Anexo
    from app.models.historical_case import HistoricalCase
    
    print("✅ Modelos importados com sucesso")
    
    # Criar todas as tabelas
    Base.metadata.create_all(bind=engine)
    
    print("✅ Tabelas criadas com sucesso!")
    print("\n📋 Tabelas disponíveis:")
    print("   • users - Usuários do sistema")
    print("   • projects - Projetos PRONAS/PCD")
    print("   • anexos - Anexos dos projetos")
    print("   • historical_cases - Casos históricos")
    
except Exception as e:
    print(f"❌ Erro ao criar tabelas: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
