# Implementation plan: FAIR heat-bath Potts repository with uv

Placeholders to replace throughout: `<Your Name>`, `<github-username>`, `<your-orcid>`, `<ZENODO-DOI>`.

Each step names the FAIR principle it serves (F, A, I, R).

---

## Step 1 – Install uv and create the GitHub repository

1. Install uv: `curl -LsSf https://astral.sh/uv/install.sh | sh` (macOS/Linux) or `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"` (Windows). Check with `uv --version`.
2. On GitHub, create a **public**, empty repository called `potts-heatbath` (no README or licence yet; those come from this plan). **(A)**
3. Add a description and topics: `monte-carlo`, `potts-model`, `statistical-physics`, `heat-bath`, `fair`, `python`. **(F)**

## Step 2 – Scaffold the project with uv

```bash
uv init --package potts-heatbath
cd potts-heatbath
uv python pin 3.12
```

`--package` creates a `src/` layout and a build system, so the code is installable (needed for the CLI and for others to import it). `uv python pin` writes `.python-version`, so everyone uses the same interpreter. **(R)**

## Step 3 – Add dependencies and lock them

```bash
uv add numpy matplotlib
uv add --dev pytest ruff
```

This updates `pyproject.toml` and creates `uv.lock`, which pins the exact version of every direct and indirect dependency. **Commit `uv.lock`** – it is the core of the reproducibility story. **(R)**

## Step 4 – Refactor `heatbath.py` into the package

Course scripts usually mix parameters, simulation, plotting and printing in one file. Split them:

| New module | Move here from `heatbath.py` |
|---|---|
| `lattice.py` | Lattice creation, neighbour indexing (`np.roll` or index tables) |
| `heatbath.py` | The sweep function: for each site, count neighbours in each state, compute weights `exp(beta*J*n_s)`, sample new state |
| `observables.py` | Energy per site, order parameter `(q*max_s(N_s/N) - 1)/(q - 1)` |
| `io.py` | Writing `timeseries.csv` and `metadata.json` |
| `cli.py` | Argument parsing (`argparse`), calls the above |
| `plotting.py` (optional) | Any figure code, kept separate from the physics |

Rules to apply while refactoring:

- **No global state or hard-coded parameters.** Everything (`L`, `q`, `beta`, `J`, sweeps) becomes a function argument. **(R)**
- **Pass an explicit RNG**: functions take `rng: np.random.Generator` instead of calling `np.random.*` globally. Create it with `np.random.default_rng(seed)`. This is what makes runs exactly repeatable. **(R)**
- **Docstrings** on every public function stating parameters, units (β in 1/J) and return values, in NumPy docstring style. **(R)**
- **Type hints** on public functions. **(I)**
- Expose the public API in `__init__.py`:

```python
from importlib.metadata import version
from .lattice import PottsLattice
from .heatbath import run_simulation

__version__ = version("potts-heatbath")
__all__ = ["PottsLattice", "run_simulation", "__version__"]
```

## Step 5 – Fill in `pyproject.toml` metadata

```toml
[project]
name = "potts-heatbath"
version = "1.0.0"
description = "Heat-bath Monte Carlo simulation of the 2D q-state Potts model"
readme = "README.md"
license = "MIT"
license-files = ["LICENSE"]
authors = [{ name = "<Your Name>", email = "<you@example.com>" }]
requires-python = ">=3.10"
keywords = ["Potts model", "Monte Carlo", "heat bath", "statistical physics", "FAIR"]
classifiers = [
    "Programming Language :: Python :: 3",
    "Topic :: Scientific/Engineering :: Physics",
    "Intended Audience :: Science/Research",
    "Intended Audience :: Education",
]
dependencies = ["numpy", "matplotlib"]   # uv fills in version bounds

[project.urls]
Repository = "https://github.com/<github-username>/potts-heatbath"
Documentation = "https://github.com/<github-username>/potts-heatbath#readme"

[project.scripts]
potts-heatbath = "potts_heatbath.cli:main"
```

Keep the `[build-system]` and `[dependency-groups]` sections uv generated. This metadata is machine-readable by every Python tool and indexer. **(F, I)**

## Step 6 – Record provenance in every output

`io.py` should write `metadata.json` alongside the CSV:

```python
import json, platform, datetime
import numpy as np
from . import __version__

def write_metadata(path, params: dict, seed: int) -> None:
    meta = {
        "software": "potts-heatbath",
        "version": __version__,
        "parameters": params,
        "seed": seed,
        "python": platform.python_version(),
        "numpy": np.__version__,
        "created": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }
    path.write_text(json.dumps(meta, indent=2))
```

Open formats (CSV, JSON) plus full provenance make the outputs usable in any tool and reproducible. **(I, R)**

## Step 7 – Write tests

`tests/test_heatbath.py` should cover physics checks, not just "it runs":

1. **Ground state energy**: an all-aligned lattice has energy per site exactly `-2J` (two bonds per site on a periodic square lattice).
2. **Infinite temperature**: at `beta = 0`, after many sweeps each state occupies ≈ `1/q` of sites.
3. **Low temperature ordering**: at `beta` well above `ln(1 + sqrt(q))`, the order parameter approaches 1.
4. **Reproducibility**: two runs with the same seed give identical time series; different seeds differ.
5. **Valid states**: all spins stay in `{0, …, q-1}`.
6. **CLI smoke test**: running the CLI with tiny `L` and few sweeps writes both output files.

Run with `uv run pytest`. **(R)**

## Step 8 – Continuous integration

`.github/workflows/tests.yml`:

```yaml
name: tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ["3.10", "3.12"]
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v6   # check for the latest major version
        with:
          python-version: ${{ matrix.python-version }}
      - run: uv sync --locked
      - run: uv run ruff check .
      - run: uv run pytest
```

`--locked` makes CI fail if `uv.lock` is out of date with `pyproject.toml`, so the lock file can never silently drift. Testing on three operating systems shows the code is portable. **(A, R)**

## Step 9 – Add README, LICENSE and CITATION.cff

- Copy the provided `README.md` and `LICENSE` to the repository root; replace placeholders.
- Create `CITATION.cff` (GitHub then shows a "Cite this repository" button): **(F)**

```yaml
cff-version: 1.2.0
message: "If you use this software, please cite it as below."
title: "potts-heatbath: Heat-bath Monte Carlo for the q-state Potts model"
version: 1.0.0
date-released: 2026-11-01
license: MIT
repository-code: "https://github.com/<github-username>/potts-heatbath"
keywords: [Potts model, Monte Carlo, heat bath, statistical physics]
authors:
  - family-names: "<Family>"
    given-names: "<Given>"
    orcid: "https://orcid.org/<your-orcid>"
identifiers:
  - type: doi
    value: "<ZENODO-DOI>"
```

Validate it with `uvx cffconvert --validate` (uvx runs a tool without installing it permanently).

- Add a `.gitignore` (uv creates one; also add `results/`).

## Step 10 – Commit and push

```bash
git add .
git commit -m "Initial FAIR-structured release of potts-heatbath"
git branch -M main
git remote add origin https://github.com/<github-username>/potts-heatbath.git
git push -u origin main
```

Confirm the Actions tab shows green tests.

## Step 11 – Get a DOI through Zenodo

1. Log in to [zenodo.org](https://zenodo.org) with GitHub, go to the GitHub settings page and switch the `potts-heatbath` repository on.
2. On GitHub, create a release with tag `v1.0.0`. Zenodo archives that exact snapshot and mints a DOI automatically.
3. Put the DOI into the README badge and `CITATION.cff`, then commit.

The DOI is a persistent identifier that outlives the GitHub URL, and Zenodo keeps the metadata accessible even if the code is removed. This is the single most important step for **F** and **A**.

## Step 12 – (Optional) Publish to PyPI

```bash
uv build
uv publish        # needs a PyPI API token
```

After this, anyone can run `uv add potts-heatbath` or `pip install potts-heatbath`. Further improves **A** and **F**.

## Step 13 – Final FAIR checklist

| | Check |
|---|---|
| F | DOI minted; `CITATION.cff` valid; keywords in `pyproject.toml`; GitHub topics set |
| A | Public repo; one-command install; archived on Zenodo |
| I | PEP 621 `pyproject.toml`; CSV/JSON outputs; CLI and Python API; NumPy arrays in and out |
| R | Licence present; `uv.lock` committed; seeds and metadata recorded; tests pass in CI; docstrings and README usage examples; semantic versioning on releases |

You can also run the repository through the [FAIR-checker / howfairis](https://github.com/fair-software/howfairis) tool (`uvx howfairis https://github.com/<github-username>/potts-heatbath`) and add its badge to the README.
