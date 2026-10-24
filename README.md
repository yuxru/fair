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
git clone https://github.com/yuxru/fair.git
cd potts-heatbath
uv sync --locked
```

`uv sync --locked` creates a virtual environment with the exact package versions recorded in `uv.lock`, and installs the correct Python version from `.python-version` if needed. This is what makes results reproducible across machines.

To install only the command-line tool without cloning:

```bash
uv tool install git+https://github.com/yuxru/fair
```

## Acknowledgements

Developed from a project in BERN01 – Modelling in Computational Science. The FAIR mapping follows Barker et al. (2022), "Introducing the FAIR Principles for research software", *Scientific Data* 9, 622.
