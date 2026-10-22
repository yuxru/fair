# Potts-Heatbath Readme

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Heat-bath Monte Carlo simulation of the two-dimensional *q*-state Potts model, packaged with [uv](https://docs.astral.sh/uv/) as a worked example of how the **FAIR principles for research software** (Findable, Accessible, Interoperable, Reusable) can be built into a code base.

The simulation code originates from one of my projects in the course BERN01 – Modelling in Computational Science.

---

## The model

The *q*-state Potts model on an *L × L* square lattice with periodic boundaries has the Hamiltonian

$$
H = -J \sum_{\langle i,j \rangle} \delta(\sigma_i, \sigma_j), \qquad \sigma_i \in \{0, 1, \dots, q-1\}
$$

The **heat-bath algorithm** updates one spin at a time by drawing its new state directly from the conditional Boltzmann distribution given its four neighbours:

$$
P(\sigma_i = s \mid \text{neighbours}) = \frac{e^{\beta J n_s}}{\sum_{s'=0}^{q-1} e^{\beta J n_{s'}}}
$$

where $n_s$ is the number of neighbours in state $s$. Unlike Metropolis, there is no accept/reject step, which makes the method efficient for larger *q*. For the square lattice the exact critical coupling is $\beta_c J = \ln(1 + \sqrt{q})$, which the test suite uses as a reference point.

---

## Installation

The project is managed with **uv**. Install uv first ([instructions](https://docs.astral.sh/uv/getting-started/installation/)), then:

```bash
git clone https://github.com/<github-username>/potts-heatbath.git
cd potts-heatbath
uv sync --locked
```

`uv sync --locked` creates a virtual environment with the exact package versions recorded in `uv.lock`, and installs the correct Python version from `.python-version` if needed. This is what makes results reproducible across machines.

To install only the command-line tool without cloning:

```bash
uv tool install git+https://github.com/<github-username>/potts-heatbath
```

---

## Usage

### Command line

```bash
uv run potts-heatbath --L 32 --q 3 --beta 1.0 --sweeps 10000 --burn-in 1000 --seed 42 --out results/
```

| Option | Meaning | Default |
|---|---|---|
| `--L` | Linear lattice size | 32 |
| `--q` | Number of Potts states | 3 |
| `--beta` | Inverse temperature (in units of 1/J) | 1.0 |
| `--sweeps` | Number of measurement sweeps | 10000 |
| `--burn-in` | Sweeps discarded for equilibration | 1000 |
| `--seed` | Random seed (required for reproducibility) | none |
| `--out` | Output directory | `results/` |

Run `uv run potts-heatbath --help` for the full list.

### Python

```python
import numpy as np
from potts_heatbath import PottsLattice, run_simulation

rng = np.random.default_rng(42)
lattice = PottsLattice(L=32, q=3, rng=rng)
result = run_simulation(lattice, beta=1.0, sweeps=10_000, burn_in=1_000)

print(result.energy.mean(), result.magnetization.mean())
```

### Output

Each run writes two files to the output directory:

- `timeseries.csv` – energy per site and order parameter for every measurement sweep (plain CSV, readable by any tool).
- `metadata.json` – every input parameter, the random seed, the package version, the Python and NumPy versions, and a timestamp. Together with the seed this is enough to regenerate the exact time series.

---

## How this repository applies FAIR

| Principle | What it means for software | How it is done here |
|---|---|---|
| **Findable** | Software has a persistent identifier and rich metadata | Each release is archived on Zenodo with a DOI; `CITATION.cff` and the `[project]` table in `pyproject.toml` carry title, authors, keywords and version; the repository has descriptive GitHub topics |
| **Accessible** | Software and metadata can be retrieved through open, standard protocols | Public GitHub repository over HTTPS/git; installable with a single `uv` command; the Zenodo archive keeps the metadata available even if the repository disappears |
| **Interoperable** | Software uses community standards for inputs, outputs and packaging | Standard `pyproject.toml` (PEP 621) so any Python tool can read it; outputs are CSV and JSON; the core works on plain NumPy arrays; a CLI allows use from shell scripts and workflow managers |
| **Reusable** | Software has a clear licence, provenance and documentation and can be run again | MIT licence; `uv.lock` pins every dependency; explicit seeds and recorded metadata; automated tests in CI; documented API and versioned releases following semantic versioning |

---

## Development

```bash
uv sync                 # install including dev dependencies
uv run pytest           # run tests
uv run ruff check .     # lint
uv run ruff format .    # format
```

To add a dependency: `uv add <package>` (or `uv add --dev <package>` for development tools). This updates both `pyproject.toml` and `uv.lock`; commit both.

### Project layout

```
potts-heatbath/
├── src/potts_heatbath/
│   ├── __init__.py       # public API and version
│   ├── lattice.py        # lattice state and neighbour handling
│   ├── heatbath.py       # heat-bath sweep
│   ├── observables.py    # energy, order parameter
│   ├── io.py             # CSV/JSON output and metadata
│   └── cli.py            # command-line interface
├── tests/
├── .github/workflows/tests.yml
├── pyproject.toml
├── uv.lock
├── .python-version
├── CITATION.cff
├── LICENSE
└── README.md
```

---

## Citing

If you use this software, please cite it using the metadata in [`CITATION.cff`](CITATION.cff) (GitHub shows a "Cite this repository" button), or the Zenodo DOI for the exact version you used:

> <Your Name> (2026). *potts-heatbath: Heat-bath Monte Carlo for the q-state Potts model* (version 1.0.0). Zenodo. https://doi.org/<ZENODO-DOI>

---

## Licence

This software is released under the [MIT License](LICENSE).

### Why MIT?

**It satisfies the Reusable principle directly.** FAIR requires that software be released with a clear and accessible licence (FAIR4RS principle R1.1). Code with no licence is, legally, not reusable at all, since copyright defaults to "all rights reserved". MIT is one of the most widely recognised OSI-approved licences, so users do not need legal advice to understand what they may do.

**It matches the purpose of the project.** This is a teaching and demonstration code. The goal is for students, teachers and researchers to copy it, adapt it, and build on it with as little friction as possible. MIT allows use in any context, including inside other licensed projects, with the single condition that the copyright notice is kept, which also preserves attribution.

**It is compatible with the dependencies.** NumPy and Matplotlib use permissive BSD-style licences. MIT is compatible with them and with almost every other licence, including GPL, so the code can be combined into larger projects without licence conflicts.

**Alternatives considered.**
- *GPL-3.0* would require derivative works to stay open source. That protects openness, but it can block reuse in projects with incompatible licences, which works against the Reusable goal for a small educational code.
- *Apache-2.0* adds an explicit patent grant. That matters for larger projects with corporate contributors, but adds length and complexity with little benefit here.
- *BSD-3-Clause* is functionally very similar to MIT; MIT was preferred because it is shorter and the most common choice in the Python ecosystem.
- *CC-BY-4.0* is designed for text and data, not code, and is not recommended by Creative Commons for software. It would be a sensible choice for any separately published simulation datasets.

---

## Acknowledgements

Developed from a project in BERN01 – Modelling in Computational Science. The FAIR mapping follows Barker et al. (2022), "Introducing the FAIR Principles for research software", *Scientific Data* 9, 622.
