# Tutorial de XSS para Moodle

Apostila digital de consulta para a disciplina de Desenvolvimento Seguro, com aproximadamente 8.400 palavras, nove módulos, exemplos comentados, tabelas e diagramas HTML/CSS. Não contém atividades avaliativas, questionários ou módulo de DOM-Based XSS. Nenhuma aplicação adicional foi criada.

## Arquivos

- `tutorial-xss-moodle.html`: documento HTML5 completo, UTF-8, com CSS incorporado, sem JavaScript ativo nem dependências externas.
- `assets/news-marcador.png`: captura real da área principal de News com marcador fictício.
- `assets/contact-formulario.png`: captura real apenas do formulário vazio de Contact.

Abra o HTML em um navegador mantendo a pasta `assets` ao lado. As referências técnicas são links de consulta, não recursos carregados automaticamente.

## Organização

1. Introdução ao Cross-Site Scripting e fronteira entre dados e código.
2. HTML, JavaScript, propriedades, eventos e atributos.
3. XSS refletido: News, nove payloads e quebra de atributo.
4. XSS armazenado: Contact, fluxo de persistência e seis exemplos.
5. Cookies, sessões, exfiltração conceitual, HttpOnly, Secure, SameSite e CSP.
6. Identificação de XSS e registro de evidências.
7. Prevenção, codificação contextual, sanitização e defesa em profundidade.
8. Comparação entre XSS refletido e armazenado.
9. Referências oficiais.

## Publicação em uma página Moodle

1. No curso, habilite a edição e adicione um recurso **Página**. Abra o modo de código-fonte HTML do editor do campo Conteúdo; o nome do botão varia conforme o editor.
2. Do arquivo, copie o bloco `<style>...</style>` do `head` e, em seguida, o bloco completo `<article class="xss-tutorial-root" ...>...</article>` do `body`. Cole ambos no conteúdo. Não copie `DOCTYPE`, `html`, `head`, `title`, `meta` ou `body`: o Moodle já fornece o documento externo. O comentário no arquivo delimita o artigo, mas o CSS encontra-se no `head` para manter o arquivo completo estruturado como HTML5.
3. Envie as duas imagens pelo gerenciador de arquivos/imagens do próprio editor. Substitua cada `src="assets/..."` pela referência gerada pelo Moodle para a imagem correspondente. Caminhos relativos funcionam no pacote local, mas não apontam automaticamente para os arquivos da página Moodle.
4. Salve e visualize como estudante. Confira índice, blocos escuros, imagens, tabelas com rolagem e apresentação em tela estreita. Reabra o código-fonte para verificar se o editor preservou o CSS e as entidades dos exemplos.
5. Caso o editor remova `style`, a administração pode instalar **o mesmo CSS com escopo `.xss-tutorial-`** na configuração de CSS adicional do tema, e o conteúdo passa a receber somente o artigo. Não é necessário permitir scripts ou desativar proteções de conteúdo. Sem CSS, a ordem semântica do texto permanece legível, mas a apresentação visual não será idêntica.

Há diferenças entre versões, editores, temas, filtros e permissões do Moodle. Não houve acesso a uma instância Moodle para teste de publicação: a compatibilidade estrutural foi revisada e a renderização local foi testada, mas a preservação do bloco `style` precisa ser confirmada no destino. O HTML não exige scripts, iframes, fontes externas, CDN, plugins de realce ou bibliotecas. Os seletores CSS e classes são isolados sob o prefixo solicitado.

Se a política institucional não permitir CSS no conteúdo nem no tema, o arquivo completo também pode ser disponibilizado como recurso Arquivo, com seus assets, sujeito à política local. Essa é uma alternativa de distribuição, não uma publicação em Página já realizada.

Referência oficial: [Moodle — Page resource](https://docs.moodle.org/en/Page_resource).

## Aplicação e URLs inspecionadas

- News: `http://192.168.10.20/fateccorp/index.php?page=pages/news.php`
- Contact: `http://192.168.10.20/fateccorp/index.php?page=pages/contact.php`

A aplicação chamada FatecCorp no enunciado apresenta a marca FatecSeg Corp na interface. As URLs usam a porta HTTP padrão, sem alteração para outro laboratório.

## Evidências efetivamente confirmadas — 27/10/2026

Inspeção do HTML recebido e do DOM com Chromium 148, automatizado por Selenium. Playwright estava instalado parcialmente, mas seu driver não estava disponível; foi usado o navegador Chromium existente. A conexão e o driver exigiram execução fora do sandbox.

### News

- Formulário GET, action `index.php`, campo oculto `page=pages/news.php` e campo de texto `busca`.
- Submissão real do marcador `FATEC_XSS_MARCADOR_20261027` pelo botão Buscar.
- URL resultante: `http://192.168.10.20/fateccorp/index.php?page=pages%2Fnews.php&busca=FATEC_XSS_MARCADOR_20261027`.
- Marcador no atributo `value` do input e em **dois** elementos `strong`.
- Os nove payloads do módulo 3 foram testados individualmente pelo parâmetro `busca`.
- Payloads 1–3: chamadas de alert com XSS, 192.168.10.20 e URL atual, respectivamente; ocorreram duas chamadas nos testes.
- Payload 4: dois registros `XSS executado` no Console.
- Payloads 5–6: chamadas XSS por eventos de imagem/SVG; duas chamadas nos testes.
- Payload 7: chamada XSS por foco no carregamento testado.
- Payload 8: propriedade `document.body.style.backgroundColor` igual a `red`.
- Payload 9: título igual a `XSS executado`.
- Quebra de atributo: input com `value=""`, `onfocus="alert('XSS no Input!')"` e `autofocus=""`; chamada correspondente confirmada.
- Para evitar diálogos bloqueantes, a execução final instrumentou `window.alert` antes do carregamento e registrou seus argumentos. São confirmações de chamada pelo código injetado, não capturas de diálogos nativos. Console, título e estilo foram examinados separadamente.

### Contact

- Formulário POST na própria rota, com campos `name`, `email`, `company` e `message`.
- Foi enviada **uma única mensagem fictícia**: nome “Demonstração didática XSS”, e-mail `tutorial@example.invalid`, empresa “Laboratório autorizado”.
- Mensagem: `FATEC_XSS_20261027 <script>console.log('Payload persistente executado')</script>`.
- Aparição no mural público e registro no Console após o envio.
- Após apagar os cookies e fazer nova navegação GET sem o payload, o marcador e o script reapareceram no conteúdo de um `div`, com novo registro no Console.
- Persistência e execução confirmadas para `message`, com versão em uma linha do payload 4 do módulo 4.
- A aparição no mural foi a confirmação de envio registrada. Não foi preservado texto de banner de sucesso; a apostila não inventa esse texto.
- A mensagem de teste permanece no mural. O controle “Resetar Mural” é global e não foi acionado para não apagar conteúdo de terceiros. Não foi observado um mecanismo de exclusão individual.

### Limites e proteção de dados

- Os outros cinco payloads armazenados são ilustrativos e não foram submetidos. Não foi testada execução em `name`, `email` ou `company`.
- A interface menciona banco de dados e painel administrativo. Não foram inspecionados banco, código PHP ou painel restrito; só a persistência e execução no mural público foram verificadas.
- A nova visita foi feita após apagar cookies no mesmo navegador, não em um segundo navegador independente.
- O ambiente continha conteúdo preexistente. Requisições para `192.168.10.10` foram bloqueadas pelo navegador de análise antes de abrir Contact. Nenhum cookie de autenticação foi coletado ou incluído no material.
- Não foi iniciado receptor e não houve teste de exfiltração. O exemplo `new Image()` com `document.cookie` é texto para análise. A variante com `COOKIE_DE_TESTE=valor_ficticio`, a requisição e o log são representações conceituais, explicitamente identificadas.
- Não houve auditoria completa das políticas/cabeçalhos de segurança da aplicação. As confirmações valem para os exemplos e configuração testados.
- As capturas não incluem mural de terceiros, credenciais, cookies ou dados pessoais. News contém somente o marcador; Contact mostra campos vazios.

## Validação do entregável

- HTML analisado com parser HTML5 (`html5lib`), sem erros de parsing.
- CSS analisado com `tinycss2`, sem erros sintáticos de regras ou declarações; seletores com escopo verificado.
- Nove seções de módulo, quinze fichas de payload, exemplos adicionais de atributos/cookies/correção e links internos válidos.
- Ausência de elementos ativos `script`, `iframe`, `object`, `embed`, formulários, inputs, SVG ou atributos de evento no tutorial. As ocorrências de código são texto escapado em `pre/code`.
- Exemplos obrigatórios de `new Image()`, dados fictícios, `htmlspecialchars` e HttpOnly presentes.
- Imagens locais e referências relativas válidas; nenhuma dependência de rede para renderizar o material.
- Chromium: larguras de 1440, 768, 390 e 320 px verificadas, sem transbordamento horizontal do documento. Tabelas e códigos mantêm rolagem interna; imagens carregaram corretamente.
- Inspeção visual das capturas reais e das renderizações desktop/celular concluída. Console sem erros; nenhum script ativo. Um elemento externo ao artigo manteve a fonte padrão, confirmando isolamento básico do CSS.
- Testes locais não substituem validação dentro do tema/editor Moodle de destino.

As referências técnicas oficiais foram abertas e verificadas. O conteúdo didático foi redigido para esta apostila; os recortes observados da FatecCorp são identificados como tais. Não foi feita publicação externa ou alteração do código da aplicação.
