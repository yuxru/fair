#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  footer: align(center)[#context text(size: 10pt)[#counter(page).display("1")]]
)
#set cite(style: "apa") // acs with author name was bugged
#set text(font: "Liberation Serif", size: 11pt, fill: black)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: black, weight: "bold")
// Figure text
#show figure.caption: set text(size: 10pt, style: "italic")
#show figure.caption: it => [#strong[#it.supplement~#it.counter.display():]~#it.body]
// Appendix formatting
#set raw(theme: "dark-plus.tmTheme")
#show raw: set text(font: "DejaVu Sans Mono", size: 8.5pt, fill: rgb("#d4d4d4"))
#show raw.where(block: true): it => block(
  fill: rgb("#332e2a"),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  it,
)

// content
#align(center)[
  #text(size: 17pt, weight: "bold")[FAIR Workflow]
  #v(1.2em)
  #text(size: 11pt)[Preston Stover] \
  #text(size: 10pt)[BERN02] \
  #text(size: 10pt)[October 2026]
]
#v(2em)

= Introduction
This report focuses on the FAIR principles in a workflow. A Jupyter notebook and Typst document are used.

= Methodology
The total energy $E(s)$ of a full lattice configuration $s = {s_1, dots, s_N}$, is given by summing over all nearest-neighbor pairs $chevron.l i, j chevron.r$, where each site $i$ holds a spin state $s_i in {1, dots, q}$. Kronecker delta $delta$ is equal to 1 for same state pairs and 0 for different state pairs. In our model the coupling parameter is set to $J = 1$ and the square lattice has total pair interactions $2N$ which results in the range of possible lattice energies $E$:
$ E(s) = -J sum_(chevron.l i, j chevron.r) delta(s_i, s_j), quad E in [-2N, 0] $ <eq-hamiltonian>
The macroscopic behavior of the model is governed by the canonical Boltzmann distribution:
$ p(s) = 1/Z e^(-beta E(s)), quad Z = sum_(s) e^(-beta E(s)) $ <eq-boltzmann>
where $Z$ is the canonical partition function over all $q^N$ possible lattice configurations. 

== Heat Bath
The Heat Bath algorithm is similar in approach to the Metropolis algorithm but ignores the spin state of selected site $i$ and instead determines the Boltzmann weights exclusively from the neighboring spin states. When updating site $i$, the existing value $s_i$ is discarded, and a new state $s in {1, dots, q}$ is drawn according to the conditional probability distribution given all remaining spins $bold(s)_(-i)$:
$ p(s_i = s | bold(s)_(-i)) = frac(e^(-beta E(s_i = s, bold(s)_(-i))), sum_(s'=1)^q e^(-beta E(s_i = s', bold(s)_(-i)))) = frac(e^(beta n_s), sum_(s'=1)^q e^(beta n_(s'))) $ <eq-heatbath-prob>
where number of neighbors for each spin state $s$ is $n_s in {0, 1, 2, 3, 4}$.

= Results and Discussion

== Convergence
Both Metropolis and heat bath algorithms determine spin state change based on Boltzmann weighted probabilities determined by neighbor identities, and in the case of Metropolis, also the selected site identity. The difference between their Boltzmann-weighted probability functions is apparent, the Metropolis algorithm's neighbor interactions provide a greater energy barrrier to relaxation into a global minimum state under these conditions. At smaller system sizes, the metastable states more easily overcome the energetic barrier, visualized in @fig-hbg.

#figure(
  grid(
    columns: 2,
    gutter: 1em,
    [
      #image("results/heatbath/L60.png", width: 100%)
      #align(center)[(a) Energy]
    ],
    [
      #image("results/heatbath/L20.png", width: 100%)
      #align(center)[(b) Magnetization]
    ],
  ),
  caption: [Characteristic behavior of equilibrium states during heat bath algorithm runs below critical temperature for both $q$ systems at $T = 0.95 dot T_c$ vsualizing the impact of system size on convergence. The larger system frequently is trapped in metastable states as observed in the $L = 60$ system compared to the $L = 20$ system.]
) <fig-hbg>

== Phase Transition and Hysteresis
Phase transitions in our report's simulated lattice are relevant phenomena to study. By measuring equilibrum energy values across a range of temperatures, continuous (second-order) and discontinuous (first-order) phase transitions are apparent and the algrotihms' performance can be compared. Discontinuous phase transitions are observed in $q=10$ models for all three algorithms. The Metropolis, heat bath, and Wang-Landau equilbrium energy values over temperature $T = (0,..., 2)$ show similar phase transitions around critical temperature in @fig-phase_com. The Wang-Landau algorithm is temperature-independent and determines the expected energy $chevron.l E chevron.r (T)$ for a given temperature using the density of states funtion $g(E)$ as outlined in detail in Methodology 2.3 and defined explicity in. @fig-phase_com shows an important strength of the Wang-Landau algorithm, unlike Metropolis and heat bath the lattice does not get trapped in local energy minima as the temperature approaches $T_c$ because visited states are penalized. Wang-Landau ensures that high-, middle-, and low-energy states are visited equally often as shown in Methodology 2.3.

#figure(
  image("results/comparison_q=10.pdf", width: 80%),
  caption: [Energy per site $E/N$ equilibrium values after 1000 Monte Carlo sweeps using the Metropolis and heat bath algorithms as a function of temperature. Energy per site $E/N$ values for Wang-Landau generated by the algorithms' density of states function over the same range $T$. Same relevant parameters used for all algorithms $L = 50$, $q = 10$, $T = (0.1, 2.0, 0.1)$. The cold start algorithm performed the same for Metropolis and heat bath and heat bath cold was removed for readability. Error bars represent standard errors of the mean computed via block averaging.]
) <fig-phase_com>
#figure(
  image("results/metropolis/metropolis_equilibrium.pdf", width: 80%),
  caption: [Energy per site $E/N$ equilibrium values after 1000 Monte Carlo sweeps using the Metropolis and heat bath algorithms as a function of temperature for $q = 2$ and $q = 10$ ($L = 50$). Dashed vertical lines mark the expected critical temperatures given by : $T_c^(q=2) = 1.135$ (orange) and $T_c^(q=10) = 0.701$ (red). For $q = 2$, hot and cold starts behave smoothly across $T_c$, a continuous phase transition. For $q = 10$, a steep jump occurs near $T_c$, a distinct gap is observed between hot and cold trajectories. Error bars represent standard errors of the mean computed via block averaging]
) <fig-metrop-eq>

The gap in temperature between phase transitions of hot and cold starts for $q = 10$ systems observed in @fig-phase_com and @fig-metrop-eq show the hysteresis of the lattice sites' as cold starts require higher temperatures to overcome the free energy barrier resulting from the stability of homogenous spins across the entire lattice. The large difference in energy between hot and cold start simulations observed in the region $T < T_c$ for $q = 10$ systems of both Metropolis and heat bath algorithms seen in @fig-phase_com and @fig-metrop-eq is due to a similar hysteresis effect. The MCMC approach of local single spin changes result in lower temperatures being required to lower the hot start energies to the expected minimum energy equilibrium state. Similar to the energy barrier required for cold starts to reach a global minimum energy state from local minimum states, the hot start simulations also experience an energy barrier trapping the lattice in a disordered state because of the single-change method of MCMC. The two algorithms show an inability to overcome the energy barriers at temperatures below and near $T_c$ resulting in both the gap between phase transition temperatures and low temperature lattice energy between hot and cold starts for $q = 10$ systems.

Continuous phase transitions are observed for $q = 2$ in both Metropolis and heat bath algorithms (@fig-metrop-eq). The sharp, discontinuous drops in energy near $T_c$ characteristic of $q = 10$ systems are absent in $q = 2$, which instead exhibits a smooth change across $T_c$. This distinct transition behavior and lack of hysteresis or energy barriers as observed in the $q = 10$ systems are due to the significantly greater effect of entropy in $q = 10$ systems compared to $q = 2$ ($q^N -> 2^N$ vs. $10^N$). The larger number of disordered states $S_("dis")$ for systems with more spin states gives an entropic advantage which results in the discontinuity between ordered and disordered states. Using our models' determination $k_B = 1$ and system spin states $q = 2, q = 10$ the entropic advantage (@eq-entropy-comparison) is related to Helmholtz free energy $F$ for our 2D canonical ensemble Potts lattice (@eq-helm):
$  F = E - T S quad -> quad F(E, T) = E - T k_B ln g(E)  $ <eq-helm>
$ S_("dis") = k_B ln(q^N) = N k_B ln(q) $ <eq-disordered-entropy>

$ frac(S_("dis"), N) = k_B ln(q) ==> cases(
  frac(S_("dis"), N) = k_B ln(2) approx 0.693 &"for" q = 2,
  frac(S_("dis"), N) = k_B ln(10) approx 2.303 &"for" q = 10
) $ <eq-entropy-comparison>

Where $E$ is internal energy,  $T$ is temperature, $S$ is entropy, $k_B$ is Boltzmann's constant ($= 1$), $g(E)$ is density of states, $S_"dis"$ is disordered phase entropy, $N$ is lattice size, and $q$ is number of spin states.

The disordered phse entropy terms in @eq-entropy-comparison quantify the difference between the transitions of $q = 2$ and $q = 10$ systems. At $T_c$ the larger entropic term causes $q = 10$ systems to jump across a double-well potential energy gap between ordered and disordered states described by $F(E, T)$. Similar to the free energy barriers discussed for hot and cold starts, the system has an increasing probability to cross the barrier as temperature changes until the MCMC simulations experience a discontinuous change in equilibrium energy.

== System Scaling
Simulations were performed across four system sizes $L in {10, 25, 50, 100}$ to compare model performance to the theoretical macroscopic behavior of the systems at infinite lattice size. Discontinuity is expected to increase with system size.(@fig-size-comp) Our results are unexpected. The Wang-Landau discontinuity is difficult to determine, because each energy level E is counted discretely in the density of states function $g(E)$ the noise of the resulting energy values for a given $T$ increases with system size, as the number of discrete energy levels increases exponentially with $L$. This can be amended by binning similar energies into groups to reduce noise. For our model binning the adjacent discrete energy states into groups of 25 would be a reasonable solution.

The performance of the Metropolis algorithm is similar to the heat bath and only Metropolis was plotted for readability. The temperature steps and statistical error of the Metropolis simulations suggest that the expected increase in discontinuity is not observable because of the stochasticity and inaccuracy of the simulation under the chosen parameters. 

#figure(
  image("results/size_comparison_q=10.pdf", width: 80%),
  caption: [Scaling analysis of the $q = 10$ Potts model across lattice dimensions $L in {10, 25, 50, 100}$. Solid curves represent the expectation derived from Wang-Landau density of states $g(E)$, dotted markers represent Metropolis cold start simulations. As the lattice dimension increases from $L = 10$ to $L = 100$, the transition region is expected to progressively sharpen toward  discontinuity at $T_c approx 0.701$.]
) <fig-size-comp>

= Conclusion
This report investigated phase transitions in the two-dimensional $q$-state Potts model utilizing Metropolis, heat bath, and Wang-Landau algorithms. All the models proved successful in simulating macroscopic lattice behavior while bypassing the intractible $q^N$ microstate canonical partition function summation.
1. *Validation:* Metropolis and Heat Bath implementations were verified against Onsager's exact analytical solution for $q = 2$, matching theoretical predictions within $<= 0.05%$ relative error for tested temperatures using block error analysis. All algorithms correctly converged to the system site energy limits ($E/N = -2 "as" T -> 0 "and" E/N = 0 "as" T -> oo$).
2. *Phase Transition:* We demonstrated that the nature of the phase transition is governed by spin degeneracy $q$: continuous (second-order) for $q = 2$, exhibiting smooth energy curves; and discontinuous (first-order) for $q = 10$, displaying an abrupt energy jump at phase transition. The difference in continuity was quantified indirectly by calculating the entropic advantage $S_"dis"/N$ of the $q = 2$ and $ q = 10$ systems.
3. *Hysteresis and Metastability:* Both MCMC methods suffered from hysteresis and metastability trapping at temperature below and near $T_c$ for $q = 10$. The single site spin updates made my the MCMC algorithms struggled to overcome the free energy barriers between ordered and disordered states beyond small ($approx L < 20$) system sizes. This phenomena is seen in the divergence of hot and cold start relaxations below $T_c$ and the temperature deviance of phase transitions from $T_c$ experienced by $q = 10$ systems.
4. *Sampling Comparison:* The Wang-Landau algorithm successfully bypassed the energy barrier issues by sampling the density of states $g(E)$ from the flat histogram $H(E)$ instead of the MCMC Boltzmann-weighted sampling methods. The algorithm proved advantageous when compared to the MCMC algorithms when describing lattice energy as a function of temperature in our trials.

// bib
#v(2em)
#bibliography("references.bib", title: "References", style: "ieee")

// appendix
#pagebreak()
#counter(heading).update(0)
#set heading(numbering: "A.1")

= Python Code <app:code>
Our group wrote our own code separately before working togeteher to run tests, create figures, and optimize. Consequently there are multiple sets of functions that are labeled accordingly.

==  Onsager Expected Values <app:1>

```python
from scipy.special import ellipk
import numpy as np
# based on using Kronecker delta, 2N nearest-neighbor bonds to simplify:
for T in [0.1, 0.5, 1.0, 2.0]:
    b = 1.0 / T
    k = 2 * np.sinh(b) / np.cosh(b)**2
    k1 = 2 * np.tanh(b)**2 - 1
    # ellipk is used for the integral (see 118a in Onsager paper)
    u = -(1 / np.tanh(b)) * (1 + (2 / np.pi) * k1 * ellipk(k**2)) # see 116 in Onsager paper
    print(f"T = {T:3.1f} | E/N = {-1 + 0.5 * u:.4f}")
```

== Heat Bath Algorithm Functions

```python
import numpy as np
import matplotlib.pyplot as plt
from numba import njit

# Lattice Functions:
def lattice(L, q, hot=True):
    '''q number of spins with value s=(1,...,q) in an LxL lattice stored as flat list.
    np.int8 is faster data type for lattice values.'''
    # hot start:
    if hot == True:
        return np.random.randint(1, q + 1, size=(L*L), dtype=np.int8)
    # cold start:
    random_state = np.random.randint(1, q + 1)
    return np.full((L*L), random_state, dtype=np.int8)

def neighbors_index(L):
    '''calculates an index of all (4) neighbor ids for each index site N in the lattice.
    Allows for direct neighbors_index[site] lookup for any point on lattice.
    np.int32 allows for L = 46 000 and N = 2 billion while being efficient.
    Using % for four directions wraps around edges of lattice (periodic).'''
    N = L**2
    # create empty index with 4 values (set to 0) corresponding to each index site N:
    neighbors = np.zeros((N, 4), dtype=np.int32)
    for i in range(N):
        # remainder gives column value and floor division gives row value of L*L matrix in N-site index:
        x = i // L  # row 
        y = i % L   # column   a%b = a − (b * (a // b))
        up = (((x-1) % L) * L) + y
        down = ((x + 1) % L) * L + y
        left = x * L + ((y - 1) % L)
        right = x * L + ((y + 1) % L)
        neighbors[i] = [up, down, left, right] # assign 4 directions' neighbor index IDs for each index site N
    return neighbors

def measure_e(spins, neighbors):
    '''Calculates initial total energy E = -J * sum(delta(s_i, s_j)), J = 1.
    spin -> np.newaxis: 1D np.int8 array of length N'''   
    # look up all neighbor spin values across the entire lattice, associating site spin value with its four neighbor indexes
    # compare each site's spin against its 4 neighbors
    matches = (spins[:, np.newaxis] == spins[neighbors])
    # sum total matching pairs and divide by 2 in return line to correct double counting
    total_matches = np.sum(matches)
    return -(total_matches // 2)  # E = -1 per matching pair

# Heat Bath Algorithm Functions:
def bath(spins, neighbors, E, beta, q):
    ''' Heat bath sweep over N randomly chosen sites m
    Issue: largest possible exponent is 4β, if 4β>710 then exp(4β) goes to NaN, this happens around T<0.0056
    Fix: Since only the ratios of weights effect probabilities of spin outcome, the number of neighbor sites
    with value s(=n) for each q have 4 subtracted from them: 
        instead of exp(β * n) for each q it is exp(β * (n -4)) 
    '''
    N = len(spins)
    q_states = np.arange(1, q+1, dtype=np.int8)
    # for each possible delta n (0,1,2,3,4) generate Boltzmann distribution value
    delta_n_weights = np.exp(beta * (np.arange(5) - 4)) # to prevent inf / NaN subtract 4
    # N_meas x L^2 elementary updates:
    for site in range(N):
        m = np.random.randint(0,N)
        og_spin = spins[m]
        neighbor_spins = spins[neighbors[m]]
        # spins_survey = [np.sum(neighbor_spins == s) for s in q_states]
        # bincount would be faster than np.sum as it runs in C
        spins_survey = np.bincount(neighbor_spins, minlength=q + 1)[1:]
        weights = delta_n_weights[spins_survey]
        spin_probs = weights / np.sum(weights)

        # random value from 0 to 1:
        spin_flip_rand = np.random.rand()
        # divides 0 to 1 space between all probabilities and picks outcome based on random number:
        pick = np.searchsorted(np.cumsum(spin_probs), spin_flip_rand)
        # rounding can make the last cumsum entry < 1 and push pick to q, which is out of range:
        new_spin = q_states[min(pick, q - 1)]
        if new_spin != og_spin:
            n_old = spins_survey[og_spin - 1]
            n_new = spins_survey[new_spin - 1]
            spins[m] = new_spin
            E += -(n_new - n_old)     
    return E

def sim(spins, neighbors, E, beta, q, sweeps):
    '''runs bath() for a given number of sweeps and records E/N after each.'''
    energies = np.empty(sweeps, dtype=np.float64)
    N = len(spins)
    for i in range(sweeps):
        E = bath(spins, neighbors, E, beta, q)
        energies[i] = E / N # changed from append to avoid numpa error
    return energies

# Analysis / Benchmark Functions:
def block_error(y, blocks=12):
    '''divides E/N value data into blocks, computes averages over the blocks, and computes the 
    standard deviation of the mean of the block averages'''
    y = np.asarray(y)  # sim() hands back a list, and .reshape() needs an array
    block_size = len(y)//blocks
    cropped_y = y[:blocks*block_size]
    block_matrix = cropped_y.reshape(blocks, block_size)
    # averages E/N of each matrix row (block)
    block_means = np.mean(block_matrix, axis=1)
    # calc mean and std err of block means group
    block_group_mean = np.mean(block_means)
    # ddof = 1 because it is err of sample (blocks), not population (per sweep)
    block_err = np.std(block_means, ddof=1) / np.sqrt(blocks)
    return block_group_mean, block_err

def Tc(q):
    return 1.0 / np.log(1.0 + np.sqrt(q))

def full_sim(L, q, T, sweeps, burn, hot, blocks=10):
    '''neater function for running bath simulation returning: mean E/N, 
    block error, and full E/N history.
    burn: number of starting sweeps thrown away so the average only uses 
    thermalized data.
    blocks: how many blocks block_error() splits the rest into.'''
    neighbors = neighbors_index(L)
    spins = lattice(L, q, hot=hot)
    E = measure_e(spins, neighbors)
    history = np.array(sim(spins, neighbors, E, 1.0 / T, q, sweeps))
    mean, err = block_error(history[burn:], blocks=blocks)
    return mean, err, history

# numba implementation:
@njit
def bath_numba(spins, neighbors, E, beta, q):
    ''' Heat bath sweep over N randomly chosen sites m
    Issue: largest possible exponent is 4β, if 4β>710 then exp(4β) goes to NaN, this happens around T<0.0056
    Fix: Since only the ratios of weights effect probabilities of spin outcome, the number of neighbor sites
    with value s(=n) for each q have 4 subtracted from them: 
        instead of exp(β * n) for each q it is exp(β * (n -4)) 
    '''
    N = len(spins)
    q_states = np.arange(1, q+1, dtype=np.int8)
    # for each possible delta n (0,1,2,3,4) generate Boltzmann distribution value
    delta_n_weights = np.exp(beta * (np.arange(5) - 4)) # to prevent inf / NaN subtract 4
    # N_meas x L^2 elementary updates:
    for site in range(N):
        m = np.random.randint(0,N)
        og_spin = spins[m]
    
        neighbor_spins = spins[neighbors[m]]
        # rewrote to avoid np.bincount, for loop is faster in numba:
        spins_survey = np.zeros(q + 1, dtype=np.int32)
        for k in range(4):
            nb_idx = neighbors[m, k]
            spins_survey[spins[nb_idx]] += 1

        # replaced np.searchsorted and np.cumsum to avoid array generation and to use unnormalized weights:
        total_weight = 0.0
        for s in range(1, q + 1):
            total_weight += delta_n_weights[spins_survey[s]]
        # random value no longer from 0 to 1, instead over whole range of sum weights:
        spin_flip_rand = np.random.random() * total_weight

        # subtracts Boltzmann factor of each spin in ascending sequence from random value in 
        # range of space between 0 and partition function. When the random value is reduced below
        # zero then that spin states' identity is the new spin:
        new_spin = q
        for s in range(1, q + 1):
            spin_flip_rand -= delta_n_weights[spins_survey[s]]
            if spin_flip_rand <= 0:
                new_spin = s
                break
        if new_spin != og_spin:
            # since spins_survey no longer uses [1:] from np.bincount method, removed [spin-1]:
            n_old = spins_survey[og_spin]
            n_new = spins_survey[new_spin]
            spins[m] = new_spin
            E += -(n_new - n_old)     
    return E

@njit
def sim_numba(spins, neighbors, E, beta, q, sweeps):
    '''runs bath() for a given number of sweeps and records E/N after each.'''
    energies = np.empty(sweeps, dtype=np.float64)
    N = len(spins)
    for i in range(sweeps):
        E = bath_numba(spins, neighbors, E, beta, q)
        energies[i] = E / N # changed from append to avoid numpa error
    return energies
```
== Metropolis Algorithm Functions

```python
import numpy
import numba
def critical_temperature(J, q):
    return J / numpy.log(1 + numpy.sqrt(q))

class Potts:
    def __init__(self, L, J, q, T, initial_condition):
        # CONFIGURATION
        self.L , self.J, self.q, self.T, self.initial_condition = L, J, q, T, initial_condition

        self.N = L * L
        self.T_c = critical_temperature(J, q)

        # INITIALIZATION
        self.states = self.initialize_states()
        self.E = self.calculate_E()

    def initialize_states(self):
        match self.initial_condition:
            case "hot":
                return numpy.random.randint(1, self.q + 1, size = (self.L, self.L))
            case "cold":
                random_state = numpy.random.randint(1, self.q + 1)
                return numpy.full((self.L, self.L), random_state)

    def calculate_E(self):
        right_state = numpy.roll(self.states, -1, axis = 1)
        down_state = numpy.roll(self.states, -1, axis = 0)
        return -self.J * (numpy.sum(self.states == right_state) + numpy.sum(self.states == down_state))

@numba.njit
def metropolis_sweep(states, E, L, J, q, T):
    for _ in range(L * L):
        i, j = numpy.random.randint(0, L, size = 2)
        existing_state = states[i, j]

        proposed_state = numpy.random.randint(1, q)
        if proposed_state >= existing_state:
            proposed_state += 1

        up_state = states[(i - 1) % L, j]
        down_state = states[(i + 1) % L, j]
        left_state = states[i, (j - 1) % L]
        right_state = states[i, (j + 1) % L]

        num_existing_matches = (
            int(up_state == existing_state)
            + int(down_state == existing_state)
            + int(left_state == existing_state)
            + int(right_state == existing_state)
        )
        num_proposed_matches = (
            int(up_state == proposed_state)
            + int(down_state == proposed_state)
            + int(left_state == proposed_state)
            + int(right_state == proposed_state)
        )

        delta_E = J * (num_existing_matches - num_proposed_matches)
        if T == 0:
            accept = delta_E <= 0
        else:
            accept = (delta_E <= 0 or numpy.random.random() < numpy.exp(-delta_E / T))

        if accept:
            states[i, j] = proposed_state
            E += delta_E
    return E


```
== Wang-Landau Algorithm Functions

```python
import numpy as np
import matplotlib.pyplot as plt
from numba import njit


class WangLandau:
    def __init__(
        self,
        L,
        q,
        T,
        initial_condition,
        threshold_H,
        initial_f,
        threshold_f,
    ):
        # CONFIGURATION
        self.L = L
        self.J = 1
        self.q = q
        self.T = T
        self.initial_condition = initial_condition
        self.threshold_H = threshold_H
        self.histograms = []
        self.f = initial_f
        self.threshold_f = threshold_f

        self.N = L * L
        self.T_c = self.J / np.log(1 + np.sqrt(q))

        # INITIALIZATION
        
        # integers, counting visits of a given energy states, indexed by -E
        self.histogram = np.zeros(2*self.N + 1, dtype=int)
        # estimate of energy densities in log scale to avoid overflow, indexed by -E
        self.log_g = np.ones(2*self.N + 1)
        self.previous_indices, self.next_indices = self.generate_neighbour_indices()
        self.states = self.initialize_states()
        self.E = self.calculate_E()

        self.frames = []

    def generate_neighbour_indices(self):
        previous_indices = np.arange(self.L) - 1
        previous_indices[0] = self.L - 1
        next_indices = np.arange(self.L) + 1
        next_indices[-1] = 0
        return previous_indices, next_indices

    def initialize_states(self):
        match self.initial_condition:
            case "hot":
                return np.random.randint(1, self.q + 1, size=(self.L, self.L))
            case "cold":
                random_state = np.random.randint(1, self.q + 1)
                return np.full((self.L, self.L), random_state)
            case "save":
                return save.load_lattice()

    def calculate_E(self):
        right = np.roll(self.states, -1, axis=1)
        down = np.roll(self.states, -1, axis=0)
        return -self.J * (np.sum(self.states == right) + np.sum(self.states == down))


    def record(self):
        self.frames.append(self.states.copy())

    def measure(self):
        self.record()
        self.histograms.append(self.histogram.copy())


    def run(self):
        print("CONFIGURATION")
        print("L:", self.L)
        print("J:", self.J)
        print("q:", self.q)
        print("T_c:", self.T_c)
        print("T:", self.T)
        print(self.initial_condition, "start")

        plt.ion()
        fig, ax = plt.subplots()

        # Main loop oof the algorithm, decreasing the f factor
        while self.f > self.threshold_f:
            self.E = self.calculate_E()
            normalized_div = fast_run(self.states, self.histogram, self.threshold_H, self.L, self.E, self.log_g, self.q, self.f)
            self.f = np.sqrt(self.f)
            print("Updating f...")

            # Plot the histogram to check flatness visually
            ax.clear()
            ax.plot(self.histogram)
            ax.set_title(str(normalized_div))
            plt.pause(0.0001)

        self.save()

    def save(self):
        #save.save_lattice(self.states)
        return

    def g_log_norm(self):
        return self.log_g - np.max(self.log_g)


# Definition of functions ro tun the algorithm outside of class for numba compatibility
@njit
def fast_run(states, histogram, threshold_H, L, E, log_g, q, f):
    E = E
    # noramlized standard diviation as a measure for flatness
    normalized_div = np.inf
    # initialize histogram to 0
    histogram[:] = 0
    # check for flatness
    while normalized_div > threshold_H:
        # run one sweep
        for _ in range(L**2):
            E = step(states, L, q, E, log_g, histogram, f)
        # update flatness measurement
        normalized_div = np.std(histogram) / np.mean(histogram)
    return normalized_div


@njit
def calculate_delta_E(
    i,
    j,
    existing_state,
    proposed_state,
    states,
    L
):
    previous_indices = np.arange(L) - 1
    previous_indices[0] = L - 1
    next_indices = np.arange(L) + 1
    next_indices[-1] = 0
    up_state = states[previous_indices[i], j]
    down_state = states[next_indices[i], j]
    left_state = states[i, previous_indices[j]]
    right_state = states[i, next_indices[j]]

    num_existing_matches = (
        int(up_state == existing_state)
        + int(down_state == existing_state)
        + int(left_state == existing_state)
        + int(right_state == existing_state)
    )

    num_proposed_matches = (
        int(up_state == proposed_state)
        + int(down_state == proposed_state)
        + int(left_state == proposed_state)
        + int(right_state == proposed_state)
    )

    return (
        num_existing_matches - num_proposed_matches
    )

# One Monte Carlo step
@njit
def step(states, L, q, E, log_g, histogram, f):
    # propose a new state at a point (i, j)
    i = np.random.randint(0, L)
    j = np.random.randint(0, L)
    existing_state = states[i, j]
    proposed_state = np.random.randint(1, q + 1)

    delta_E = calculate_delta_E(
        i,
        j,
        existing_state,
        proposed_state,
        states,
        L
    )

    # Calculations are done in log scale to avoid overflow and unnecessary computation
    A = np.exp(log_g[-E] - log_g[-1*(E + delta_E)])
    # sample decision variable and update state if accepted
    alpha = np.random.rand()
    if alpha < A:
        E = E + delta_E
        states[i, j] = proposed_state
    # update g and histogram regardless of acceptance
    histogram[-E] += 1
    log_g[-E] += np.log(f)
    return E
```