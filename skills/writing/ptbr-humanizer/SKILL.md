---
name: ptbr-humanizer
description: "Write or review the pt-BR text that a visitor reads on a site: UI strings, about pages and meta descriptions. The text must sound Brazilian, not like a translation or a model. Use for each change to visible pt-BR copy."
---

# ptbr-humanizer

Site copy that starts as a translation of English shows it: literal words, a stiff passive and
the em dash. The visitors are Brazilian. The copy must sound like a friendly and exact public
service, not like a product page or a translator. For technical pt-BR text, use `ptbr-writer`.

## Where the text is

- The pt-BR string catalog of the site, and the script that builds the bundle from it. Do not
  edit the bundle.
- The pt-BR articles in the HTML pages and the meta description of each page.
- The fallback text in each HTML element that has an i18n key. It must agree with the catalog.

## Rules

1. Write as people speak. "o que é o marola", not "o que é isto". "dá para conferir", not
   "podem ser conferidos".
2. Name each thing exactly: "os dados das praias", "o laudo de balneabilidade". Never use vague
   words such as "o quadro" or "a solução".
3. Do not use the em dash. Use a period, a colon or a comma. Use "·" only in short metadata, one
   time in each line. This rule applies to the English catalog too.
4. Use short sentences, the active voice and "você". Divide a sentence of more than about 25
   words.
5. Do not use marketing words or AI words: inteligente, revolucionário, perfeito, solução,
   jornada, potencializar, "com IA", emoji.
6. Keep data and names word for word: the verdict of an agency, the name of a provider, the name
   of a beach. Put a no-break space between a number and its unit.
7. Keep the house style of the catalog. The marola catalog is lower case.
8. Keep each ICU placeholder. Read the pt-BR result of each branch, not only the template.
9. Honesty comes before polish. Say what is not available yet ("em breve", "ainda não
   publicamos"). Do not hide it.

## Procedure

1. Read the English string and the context of its key. Write the pt-BR from the meaning, not
   word by word.
2. Read the text as a person from Rio or from Florianópolis. If it sounds dubbed, write it again.
3. Build the bundle again and run the site checks. Update the text that the checks hold for the
   strings that you changed.
4. Make a screenshot of the pt-BR page at 390 px. A longer string must still fit its row.
