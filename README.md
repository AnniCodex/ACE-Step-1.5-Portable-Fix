# ACE-Step 1.5 Portable Fix (Windows)

> [!IMPORTANT]
> **Run `fix_ace_step.bat` as Administrator, right after extracting the official archive and BEFORE launching `start_gradio_ui.bat` for the first time.**
>
> 1. Extract `ACE-Step-1.5.7z`.
> 2. Copy `fix_ace_step.bat` into the extracted root folder (the one that contains `python_embeded`, `.git` and `start_gradio_ui.bat`).
> 3. Right-click `fix_ace_step.bat` → **Run as administrator**.
> 4. When it says `=== DONE ===`, close it and start `start_gradio_ui.bat` as usual.

🇮🇹 [Versione italiana più sotto](#italiano)

---

## What is this?

The official **Windows portable package** of [ACE-Step 1.5](https://github.com/ace-step/ACE-Step-1.5), linked from the official repository and downloaded from
`https://files.acemusic.ai/acemusic/win/ACE-Step-1.5.7z`, ships with a few problems that break it out of the box:

| Problem in the official package | Consequence |
|---|---|
| Hardcoded `http.proxy` / `https.proxy` in the bundled repo's local git config | `git fetch` / updates fail for anyone not behind that proxy |
| The bundled git remote does not point to the official GitHub repository over plain HTTPS | Updates cannot reach the upstream repo |
| The Python folder is named `python_embeded` (typo) | Scripts that expect `python_embedded` cannot find Python |
| The embedded Python has **no `pip`** | You cannot install or update any package |
| Missing dependencies for **DCW** (`PyWavelets`, `pytorch_wavelets`) | The DCW feature fails to load |

`fix_ace_step.bat` fixes all of this in one pass, and then updates the installation to the latest upstream code.

This is an **unofficial** community fix. It is not affiliated with or endorsed by the ACE-Step team.

## What the script does, step by step

Every step is printed on screen and written to `fix_ace_step.log` next to the script.

| Step | Action |
|---|---|
| **1/6 Python folder** | If `python_embedded\python.exe` is missing and `python_embeded\python.exe` exists, renames `python_embeded` → `python_embedded`. |
| **2/6 Git** | Uses the bundled `PortableGit\bin\git.exe` if present, otherwise the system `git` found on `PATH`. |
| **3/6 Git config** | In the bundled repo's **local** config only: removes `http.proxy` and `https.proxy`, and sets `origin` to `https://github.com/ace-step/ACE-Step-1.5.git`. Your global git config is not touched. |
| **4/6 pip** | If the embedded Python has no pip, downloads `get-pip.py` from `https://bootstrap.pypa.io/get-pip.py` and installs it. |
| **5/6 DCW** | Installs `PyWavelets` (from PyPI) and `pytorch_wavelets` (from `git+https://github.com/fbcotter/pytorch_wavelets`) into the embedded Python, if they are not already importable. |
| **6/6 Update** | `git fetch origin`; if the local commit differs from `origin/<branch>`, stashes local changes (`git stash push -m "auto-backup"`) and runs `git reset --hard origin/<branch>`. |

Each step is skipped (with a message) if its prerequisite is missing, so the script never stops halfway.

## Requirements

- Windows 10/11.
- The official `ACE-Step-1.5.7z` extracted somewhere.
- An internet connection (for pip, the DCW packages and the git update).

## ⚠️ Notes

- **Step 6 overwrites modified source files** with the upstream version. Your local changes are saved first with `git stash` (named `auto-backup`) and can be recovered with `git stash list` / `git stash pop` from the ACE-Step folder.
  Untracked files (models, outputs, your own files) are not removed by `git reset --hard`.
- `pytorch_wavelets` is installed by pip directly from GitHub, so pip needs a `git` on `PATH`. If only the bundled PortableGit is available, this step may print `WARN: pytorch_wavelets`; installing [Git for Windows](https://git-scm.com/download/win) and re-running the script fixes it.
- The script is safe to run again: steps that are already fine are reported as `OK` and skipped.
- If something fails, open `fix_ace_step.log` and include it when you open an issue.

## Troubleshooting

| Log line | Meaning / fix |
|---|---|
| `ERR: no python folder` | The script is not in the ACE-Step root folder. Move it next to `python_embeded` / `python_embedded`. |
| `ERR: rename failed` | The folder is in use (ACE-Step running, Explorer window open inside it) or you did not run as Administrator. Close everything and retry. |
| `ERR: git not found` | No `PortableGit` folder and no system git. Install Git for Windows. |
| `ERR: download failed` | `bootstrap.pypa.io` not reachable (firewall/proxy/antivirus). |
| `ERR: fetch failed` | GitHub not reachable from git. Check your network, or a global git proxy (`git config --global --get http.proxy`). |

## License

[MIT](LICENSE). ACE-Step itself is a separate project with its own license: see the [official repository](https://github.com/ace-step/ACE-Step-1.5).

---

## Italiano

> [!IMPORTANT]
> **Esegui `fix_ace_step.bat` come Amministratore subito dopo aver estratto l'archivio ufficiale e PRIMA di avviare `start_gradio_ui.bat` per la prima volta.**
>
> 1. Estrai `ACE-Step-1.5.7z`.
> 2. Copia `fix_ace_step.bat` nella cartella principale estratta (quella con `python_embeded`, `.git` e `start_gradio_ui.bat`).
> 3. Tasto destro su `fix_ace_step.bat` → **Esegui come amministratore**.
> 4. Quando compare `=== DONE ===`, chiudi e avvia `start_gradio_ui.bat` come al solito.

### A cosa serve

Il pacchetto portable ufficiale per Windows di ACE-Step 1.5 (`https://files.acemusic.ai/acemusic/win/ACE-Step-1.5.7z`) ha alcuni bug:

- **proxy hardcoded** (`http.proxy` / `https.proxy`) nella configurazione git locale e remote non impostato sul GitHub ufficiale in HTTPS: gli aggiornamenti falliscono;
- cartella Python chiamata `python_embeded` (refuso) invece di `python_embedded`;
- **manca `pip`** nel Python incluso, quindi non si può installare né aggiornare nulla;
- mancano le dipendenze di **DCW** (`PyWavelets`, `pytorch_wavelets`).

### Cosa fa

1. Rinomina `python_embeded` → `python_embedded` se serve.
2. Trova git (PortableGit incluso o git di sistema).
3. Nella sola config git **locale** del repo: rimuove i proxy e imposta `origin` su `https://github.com/ace-step/ACE-Step-1.5.git`.
4. Installa `pip` nel Python incluso (da `get-pip.py` ufficiale).
5. Installa `PyWavelets` e `pytorch_wavelets` per DCW.
6. Aggiorna all'ultima versione ufficiale: `git fetch`, salva le modifiche locali con `git stash` (`auto-backup`) e fa `git reset --hard origin/<branch>`.

Tutto viene scritto anche in `fix_ace_step.log`. Lo script si può rilanciare senza problemi: i passi già a posto vengono saltati.

**Attenzione:** il passo 6 sovrascrive i file sorgente modificati (le modifiche restano recuperabili con `git stash pop`). Modelli, output e file non tracciati non vengono toccati.

Fix non ufficiale, non affiliato al team ACE-Step. Licenza [MIT](LICENSE).
