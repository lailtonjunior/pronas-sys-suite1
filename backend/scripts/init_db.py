import sys
sys.path.append('..')
from app.database.session import engine, Base
from app.models import user, project, anexo, historical_case

print("🗄️  Criando tabelas do banco de dados...")
Base.metadata.create_all(bind=engine)
print("✅ Tabelas criadas com sucesso!")
