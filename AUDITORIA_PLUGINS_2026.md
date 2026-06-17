# Relatório de Modernização e Auditoria de Plugins - FORTIVUS (Maio/2026)

Este documento registra o estado atual do projeto para continuidade da sessão.

## 🟢 Status do Projeto
- **Versão Flutter:** 3.44.0 Stable (Canal Stable).
- **Saúde do Código:** Zero erros de compilação. Build estável.
- **Modernização:** Concluída (Checks de `mounted`, `debugPrint`, `initialValue` em Dropdowns, etc).
- **Lints Pendentes:** 137 avisos (exclusivamente nomenclatura `UPPER_CASE` de Enums mantidos por regra de negócio/API).

## 🛠️ Auditoria de Dependências (Realizada em 24/05/2026)

### 1. Plugins Críticos e Legados
- **`bcrypt: ^1.1.3`**: Classificado como **Legado**. Funciona, mas não é otimizado para as novas VMs Dart/WASM.
  - *Recomendação:* Substituir futuramente por `hashlib` ou `cryptography` (Argon2id).
- **`open_filex`**: Atualizado e ativo (Migração do `open_file` concluída).
- **`flutter_appauth`**: Versão 12.0.1 (Estado da arte para OAuth2 no Flutter).

### 2. Gaps de Versão Identificados
- **`device_info_plus`**: Atual: `12.4.0` ➔ Disponível: `13.1.0` (Conflito detectado com `file_picker 11.0.2` via `win32`). Mantido em `12.4.0` para estabilidade.
- **`latlong2`**: Atual: `0.9.1` ➔ Disponível: `0.10.1` (Conflito detectado com `flutter_map 8.3.0`). Mantido em `0.9.1`.

### 3. Infraestrutura (iOS/Android)
- **KGP (Kotlin):** Confirmado `2.2.20` (definido no `settings.gradle`).
- **iOS:** Atenção à transição para Swift Package Manager (SPM) em substituição ao CocoaPods.

## 📋 Próximos Passos
1. **Avaliação de Argon2id:** Pesquisar implementação de substituição para BCrypt.
2. **Validação do Android 15:** Testar leitura de Device Info no SDK 35 (mesmo com plugin 12.4.0).

---
*Relatório atualizado pelo Gemini CLI em 24 de maio de 2026.*
