#!/usr/bin/env python3
"""
Importa casos históricos de exemplo
"""
import sys
import os

sys.path.insert(0, '/app')
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

print("📚 Importando casos históricos...")

try:
    from app.database.session import SessionLocal
    from app.models.historical_case import HistoricalCase
    from app.ai.rag.embeddings import generate_embedding
    from app.ai.rag.vectorstore import get_qdrant_client
    from qdrant_client.models import PointStruct
    
    print("✅ Dependências importadas")
    
    db = SessionLocal()
    qdrant = get_qdrant_client()
    
    # Verificar se já existem casos
    existing = db.query(HistoricalCase).count()
    if existing > 0:
        print(f"⚠️  Já existem {existing} casos no banco. Pulando importação.")
        print("   Para reimportar, delete os casos existentes primeiro.")
        db.close()
        sys.exit(0)
    
    # Casos de exemplo
    casos = [
        {
            "titulo": "Implantação de Centro de Reabilitação Física para PcD",
            "instituicao": "Hospital Regional de Saúde - SP",
            "ano": 2024,
            "area": "prestacao_servicos",
            "area_prioritaria": "Reabilitação Física",
            "aprovado": True,
            "pontuacao": 85,
            "orcamento": 500000,
            "texto": """Projeto aprovado com excelência para implantação de centro especializado em reabilitação física. 
            PONTOS FORTES: Objetivos claros e mensuráveis alinhados às necessidades da comunidade. Metodologia bem definida 
            com cronograma realista de 24 meses. Equipe técnica altamente qualificada com fisioterapeutas, terapeutas 
            ocupacionais e médicos especializados. Orçamento detalhado conforme tabela SINAPI e preços de mercado. 
            Parcerias estratégicas firmadas com universidades para capacitação continuada. Indicadores de avaliação 
            mensuráveis (número de atendimentos, taxa de melhora funcional, satisfação dos usuários). Plano de 
            sustentabilidade consistente com contrapartida institucional e busca de financiamentos complementares."""
        },
        {
            "titulo": "Programa de Capacitação em Transtornos do Espectro Autista",
            "instituicao": "Instituto Nacional de Formação em Saúde - RJ",
            "ano": 2024,
            "area": "formacao_treinamento",
            "area_prioritaria": "Transtornos do Espectro Autista",
            "aprovado": True,
            "pontuacao": 78,
            "orcamento": 200000,
            "texto": """Projeto de capacitação profissional aprovado. Curso estruturado em 5 módulos progressivos de 
            120 horas totais. Material didático de alta qualidade desenvolvido por especialistas. Corpo docente com 
            expertise comprovada na área de TEA e métodos ABA. Metodologia teórico-prática com estudos de caso reais. 
            Avaliação continuada dos participantes. Certificação reconhecida pelo MEC. Meta de capacitar 200 profissionais 
            da rede pública de saúde. Infraestrutura adequada com laboratórios e recursos tecnológicos."""
        },
        {
            "titulo": "Pesquisa sobre Tecnologias Assistivas Inovadoras",
            "instituicao": "Universidade Federal de Pesquisa",
            "ano": 2024,
            "area": "realizacao_pesquisas",
            "area_prioritaria": "Tecnologias Assistivas",
            "aprovado": True,
            "pontuacao": 82,
            "orcamento": 350000,
            "texto": """Projeto de pesquisa científica aprovado. Metodologia robusta com protocolo de pesquisa bem 
            fundamentado. Equipe multidisciplinar com pesquisadores doutores e mestres. Revisão bibliográfica extensa. 
            Cronograma de 36 meses bem distribuído entre fases de desenvolvimento, testes e validação. Comitê de ética 
            aprovado. Potencial de impacto social elevado com desenvolvimento de dispositivos de baixo custo. 
            Plano de divulgação científica em periódicos indexados."""
        },
        {
            "titulo": "Projeto Sem Detalhamento Orçamentário Adequado",
            "instituicao": "Entidade Beneficente XYZ",
            "ano": 2023,
            "area": "prestacao_servicos",
            "area_prioritaria": "",
            "aprovado": False,
            "pontuacao": 35,
            "orcamento": 0,
            "texto": """Projeto REPROVADO por múltiplas deficiências graves. MOTIVOS DE REPROVAÇÃO: 
            1) Orçamento apresentado sem detalhamento adequado, valores genéricos sem base em tabelas oficiais como SINAPI.
            2) Objetivos vagos e não mensuráveis, impossibilitando avaliação de resultados.
            3) Metodologia superficial sem descrição clara das etapas de execução.
            4) Ausência de documentação comprobatória da qualificação da equipe técnica.
            5) Falta de indicadores quantitativos e qualitativos de avaliação.
            6) Cronograma irrealista com prazos incompatíveis com as atividades propostas.
            7) Ausência de plano de sustentabilidade pós-financiamento.
            8) Parcerias mencionadas sem documentos formais de compromisso."""
        },
        {
            "titulo": "Atendimento a Pessoas com Deficiência Visual - Projeto Incompleto",
            "instituicao": "Associação de Apoio",
            "ano": 2023,
            "area": "prestacao_servicos",
            "area_prioritaria": "Deficiência Visual",
            "aprovado": False,
            "pontuacao": 42,
            "orcamento": 150000,
            "texto": """Projeto REPROVADO por incompletude e inconsistências. Apesar de orçamento apresentado, 
            faltaram justificativas para os valores. Equipe técnica mencionada sem comprovação de vínculo institucional. 
            Metodologia pouco detalhada. Ausência de diagnóstico situacional da região de atuação. Público-alvo 
            mal caracterizado. Metas sem fundamentação em dados epidemiológicos."""
        }
    ]
    
    print(f"\n📥 Importando {len(casos)} casos de exemplo...\n")
    
    count = 0
    for i, caso_data in enumerate(casos, 1):
        print(f"[{i}/{len(casos)}] Processando: {caso_data['titulo'][:50]}...")
        
        # Criar no PostgreSQL
        case = HistoricalCase(
            project_title=caso_data['titulo'],
            institution_name=caso_data['instituicao'],
            year=caso_data['ano'],
            field=caso_data['area'],
            priority_area=caso_data.get('area_prioritaria', ''),
            is_approved=caso_data['aprovado'],
            score=caso_data['pontuacao'],
            budget=caso_data['orcamento'],
            full_text=caso_data['texto'],
            summary=caso_data['texto'][:200] + "...",
            key_points=[],
            rejection_reasons=[]
        )
        
        db.add(case)
        db.commit()
        db.refresh(case)
        
        print(f"   ✅ Salvo no PostgreSQL (ID: {case.id})")
        
        # Gerar embedding
        print(f"   🤖 Gerando embedding...")
        embedding = generate_embedding(caso_data['texto'])
        
        # Adicionar ao Qdrant
        point = PointStruct(
            id=case.id,
            vector=embedding,
            payload={
                "title": case.project_title,
                "institution": case.institution_name,
                "field": case.field,
                "approved": case.is_approved,
                "score": case.score,
                "text": caso_data['texto'][:500]
            }
        )
        
        qdrant.upsert(
            collection_name="pronas_pcd_cases",
            points=[point]
        )
        
        status = "✅ APROVADO" if caso_data['aprovado'] else "❌ REPROVADO"
        print(f"   {status} | Score: {caso_data['pontuacao']}/100\n")
        count += 1
    
    db.close()
    
    print("═" * 70)
    print(f"✅ IMPORTAÇÃO CONCLUÍDA!")
    print("═" * 70)
    print(f"📊 Total de casos importados: {count}")
    print(f"   • Aprovados: {sum(1 for c in casos if c['aprovado'])}")
    print(f"   • Reprovados: {sum(1 for c in casos if not c['aprovado'])}")
    print(f"\n🔮 Embeddings criados no Qdrant para busca semântica")
    print(f"🗄️  Casos salvos no PostgreSQL")
    
except Exception as e:
    print(f"\n❌ Erro durante importação: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
