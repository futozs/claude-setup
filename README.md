# claude-setup

Saját Claude Code konfiguráció: karcsú, gyors, és arra hangolva, hogy a kimenet ne legyen „AI-ízű”, se kódban, se dizájnban, se szövegben. Egy paranccsal visszaállítható bármelyik Macen.

```bash
git clone https://github.com/futozs/claude-setup.git ~/claude-setup
cd ~/claude-setup && ./install.sh
```

Az `install.sh` symlinkeli a saját fájlokat a `~/.claude`-ba, felírja a `settings.json`-t, lehúzza a külső skilleket és plugineket, és feltelepíti a language servereket. Bármit, amit felülír, előtte elment a `~/claude-backups/<időbélyeg>/` mappába. Bármikor újrafuttatható. Ha csak a linkeket akarod frissíteni hálózat nélkül: `./install.sh --links`.

## Filozófia

1. **Minden betöltött sor tokenbe kerül, minden sessionben.** A globális `CLAUDE.md` rövid. A nyelvi szabályok `paths:` frontmatterrel csak akkor töltődnek be, ha olyan fájlhoz nyúl. A tudás skillekben van, amelyekből csak a leírás él a kontextusban.
2. **Ami kötelező, az hook; ami preferencia, az szöveg.** Hook csak ott van, ahol determinisztikus kényszer kell (veszélyes parancsok, formázás, git flow). Minden hook bash + jq, nem node, ezért pár ms alatt lefut.
3. **Egy terület, egy gazda.** Designra három egymást kiegészítő skill van, nem nyolc átfedő. Folyamatra egy plugin (mattpocock), nem kettő.
4. **Anti-slop.** A kódra, a szövegre és a dizájnra külön, konkrét tiltólisták vonatkoznak (CLAUDE.md, `stop-slop`, `magyar-szoveg`, `impeccable` detektor).

## Mi van benne

| Rész | Tartalom |
|---|---|
| `CLAUDE.md` | Globális utasítások: kommunikáció, munkamódszer, anti-slop kód- és szövegszabályok, design alapelvek, alap stack, git szabályok (auto commit+push, teamflow, nincs attribúció). |
| `rules/` | `web-ui`, `typescript-react`, `python`, `mobile`, `rust`. Csak a megfelelő fájltípusoknál töltődnek be. |
| `agents/` | 12 reviewer: code, security, silent-failure, typescript, react, python, swift, kotlin, flutter, rust, database, a11y. `sonnet` modellen futnak (olcsóbb). |
| `skills/magyar-szoveg` | Saját skill: magyar weboldal-szöveg AI-ízek nélkül (tükörfordítások, üres jelzők, angolos írásjelek, tegezés/magázás). |
| `hooks/guard-bash.sh` | Blokkolja: `rm -rf /`, `~` és `~/.claude`; `--force` push; `--no-verify`; `curl … \| sh`; main-re push teamflow repóban. |
| `hooks/format-queue.sh` | Szerkesztéskor csak felírja a fájlt, a turn végén egyszer formáz a projekt saját biome/prettier-jével. Így nem akad össze a következő Edittel. |
| `hooks/auto-push.sh` | Stop: pusholja a fel nem küldött commitokat (`CLAUDE_AUTO_PUSH=0` kikapcsolja). |
| `hooks/team-sync.sh` | Csapat/verseny repók git flow-ja (`git config claude.teamflow true`). |
| `hooks/notify.sh` | macOS értesítés, ha Claude vár rád (csak a terminálos CLI-ben). |
| `statusline.sh` | modell · kontextus % (színezve) · mappa · branch(*) · költség |
| `settings.json` | Engedélyek (gyakori git/bun/teszt parancsok engedélyezve, kulcsok/titkok olvasása tiltva), hookok, pluginek. |

### Pluginek és külső skillek

| Mire | Mi | Mikor hívd |
|---|---|---|
| Design, fő skill | [impeccable](https://github.com/pbakaus/impeccable) | Meglévő oldal építése, polish, audit: `/impeccable polish`, `/impeccable audit`, `/impeccable critique`. A hookja szerkesztéskor magától jelzi a slop mintákat. |
| Design, új oldal | [hallmark](https://github.com/Nutlope/hallmark) | Új landing vagy redesign, akár egy referencia URL-ből. |
| Mozgás, interakció | [emil-design-eng](https://github.com/emilkowalski/skills), `review-animations` | Hover/press állapotok, átmenetek, animációk finomhangolása. |
| Mérnöki folyamat | [mattpocock-skills](https://github.com/mattpocock/skills) | `tdd`, `diagnosing-bugs`, `grill-me`, `to-spec`, `implement`, `improve-codebase-architecture`, `handoff`. |
| Írás | [stop-slop](https://github.com/hardikpandya/stop-slop), `magyar-szoveg` | Angol, illetve magyar szövegek AI-ízek nélkül. |
| SEO | [claude-seo](https://github.com/AgriciDaniel/claude-seo) | `/seo audit <url>`, schema, GEO, helyi SEO, tartalom. |
| Cloudflare | [cloudflare/skills](https://github.com/cloudflare/skills) | Workers, D1/R2/KV, wrangler, Next on Cloudflare. |
| Vercel | vercel-plugin | Deploy, env, AI SDK, cache. |
| Dokumentáció | context7 | Aktuális library dokumentáció, verzióhelyesen. |
| Kódnavigáció | typescript-, pyright-, swift-, rust-analyzer-lsp | Szimbólum-alapú keresés grep helyett, ami kevesebb tokent visz. |
| Egyszerűsítés | code-simplifier | A friss kód tisztítása, a viselkedés megtartásával. |

## Napi használat

- **Egy sessionre kikapcsolás:** `CLAUDE_AUTO_PUSH=0`, `CLAUDE_TEAMFLOW=0`, `CLAUDE_FORMAT=0`.
- **Settings visszaszinkronizálása** (ha `/model`, `/plugin` stb. átírta): `scripts/sync-settings.sh`, utána commit.
- **Pluginek frissítése:** `claude plugin marketplace update && claude plugin update --all` (vagy a `/plugin` menü).
- **Külső skillek frissítése:** `./install.sh` (újraklónozza őket).
- **Ellenőrzés:** új sessionben `/context` (mennyi tokent visz az alap) és `/doctor`.
- **A bash-őr tesztjei:** `bash scripts/test-guard.sh`.

## Amit szándékosan kihagytam

- **Everything Claude Code (ECC) full profil.** 82 agent, 85 command, ~250 skill és ~30 hook volt fent. Minden tool hívás 4-10 node folyamatot indított (~1 mp/hívás), és ~25k token ment el minden sessionben szabályokra és leírásokra. A ~200 ECC skill be sem töltődött, mert túl mély mappában volt. A szabályai („mindig kezelj minden hibát”, „kötelező TDD és 80% lefedettség”, „használd PROAKTÍVAN az agenteket”) pont a túlbiztosított, felfújt kód felé tolták a modellt.
- **GateGuard.** Minden session első parancsa előtt „tényeket” követelt. Ez csak időt és tokent vitt, valódi védelmet nem adott. A valódi védelem a `guard-bash.sh` és a `deny` szabályok.
- **taste-skill, ui-ux-pro-max, avoid-ai-design, frontend-design, animate, motion-dev, libre-uiux, bencium.** Átfedtek az impeccable/hallmark/emil hármassal. Egy független összehasonlításban (Opus 5.5, 2026. november) alig verték a skill nélküli alapot, és együtt egymásnak ellentmondó utasításokat adtak.
- **superpowers.** Kiváló, de lassú és tokenigényes. A mattpocock-skills ugyanazt adja kevesebb ceremóniával.

## További tippek (kézzel)

- A claude.ai fiókról szinkronizált céges pluginek (sales, finance, legal, HR, bio-research, brand-voice stb.) a `settings.json`-ban `"<név>@synced": false` értékkel ki vannak kapcsolva a Claude Code-ban, a chatben elérhetők maradnak. Új plugin esetén: `claude plugin disable <név>@synced`, utána `scripts/sync-settings.sh`.
- A nem kellő claude.ai connectorokat (Vercel MCP, az elavult Cloudflare bindings, Spotify, Stripe, Three.js demó) a `deniedMcpServers` blokkolja URL alapján. A Gmail, Calendar, Drive, Sheets, Docs és ClickUp aktív marad. Ha ezeket sem használod kódolás közben, vedd fel őket ugyanide.
- A Control Chrome asztali bővítményt a Claude appban kell kikapcsolni (Settings → Extensions), mert a beépített böngésző és a Claude in Chrome ugyanazt tudja.
- Opcionálisan: [rtk](https://github.com/rtk-ai/rtk) tömöríti a parancskimeneteket (`brew install rtk && rtk init -g`). Nincs benne alapból, mert minden bash parancsot átír.

## Hitelesítés

A `agents/` reviewerek az [Everything Claude Code](https://github.com/affaan-m/ECC) agentjeiből lettek átírva (MIT). A külső skillek és pluginek a saját repójukból települnek, nincsenek bemásolva ide.
