---
name: pfa-fiscal
description: Compute annual fiscal taxes for a Romanian self-employed person (Persoană Fizică Autorizată / PFA). Calculates impozit pe venit (10% flat), CAS (pension, 25% on capped base), and CASS (health, 10% on capped base) based on gross income, deductible expenses, and the confirmed minimum gross wage for the fiscal year. Shows full bracket breakdown, formulas, and net take-home. Trigger when the user asks about PFA taxes, "cât plătesc la stat ca PFA", CAS/CASS/impozit for freelancers, or Romanian self-employment fiscal obligations.
---

# Skill: PFA Fiscal Tax Calculator (Romania)

## Purpose
Compute the three annual fiscal obligations for a Romanian **Persoană Fizică Autorizată (PFA)**:
- **Impozit pe venit** (income tax)
- **CAS** – Contribuția de Asigurări Sociale (pension)
- **CASS** – Contribuția de Asigurări Sociale de Sănătate (health insurance)

> **Scope:** This skill covers PFA taxation in **sistem real** (actual income/expense accounting) only.
> Support for **norma de venit** (flat-rate income norm) will be added in a future version.
>
> **Year validity:** The bracket structure implemented here (CAS tiered at 12x/24x minimum wage, CASS tiered at 6x/12x/24x minimum wage) is confirmed correct for fiscal year 2025 only. Thresholds, and even the calculation method, have changed across years (see Step 0 below) and may change again. Do not assume they apply unmodified to any other year without checking.

Always show a full breakdown: which bracket applies, the formula used, and the resulting amount.
Also compute the **net take-home** after all three taxes.

---

## Trigger phrases
Use this skill when the user asks any of the following (in Romanian or English):
- "calculează taxele PFA", "calculează impozitele PFA"
- "cât plătesc la stat ca PFA"
- "impozit pe venit PFA", "CAS PFA", "CASS PFA"
- "taxe persoană fizică autorizată"
- "PFA tax calculator", "compute PFA taxes"
- Any mention of CAS + CASS + impozit together in a PFA / freelance context

---

## Step 0 — Select the CASS model for the fiscal year (mandatory)

CAS (pension) uses a single tiered model (12x/24x minimum wage) that has been confirmed stable for income years 2023-2025. No model selection is needed for CAS.

CASS (health) has **two possible calculation models**. Which one applies depends on the fiscal year:

| Fiscal year       | CASS model to use                                  | Status |
|--------------------|-----------------------------------------------------|--------|
| 2025               | **Tiered** (6x/12x/24x, fixed base) — see Step 3b Model T | Fixed by explicit user decision. Note: some sources describe the proportional model (Model P) as already effective from income year 2024 onward, which would include 2025 — this is a known open discrepancy, not a verified fact. Treat the 2025 result as based on the tiered model by deliberate choice, not as independently confirmed against current law. |
| 2024               | **Proportional** (floor 6x, proportional 6x-60x, cap 60x) — see Step 3b Model P | Confirmed via OUG 115/2023 and multiple sources |
| 2023 and earlier   | Tiered (6x/12x/24x) — matches pre-2024 law | Search the Internet to confirm before computing; not independently re-verified for each historical year |
| 2026 and later     | Unknown — do not assume either model | **Mandatory:** search the Internet to confirm which CASS model and which minimum wage value apply, before computing |

For any year not covered with a confirmed status above (2023 and earlier, or 2026 and later):
1. Search the Internet to confirm the minimum gross wage valid as of 1 January of that year.
2. Search to confirm whether CASS uses the tiered model (Model T) or the proportional model (Model P) for that year.
3. If sources conflict or no clear answer is found, **stop before computing**, tell the user what was found, and ask how to proceed rather than guessing.

Once the year, minimum wage, and CASS model are confirmed, proceed to Step 1.

---

## Step 1 — Gather inputs

Ask for **all of the following** before computing (if not already provided):

1. **Fiscal year** (e.g. 2024, 2025) — needed to look up the correct minimum gross wage and to run the Step 0 validity check.
2. **Gross income (venit brut)** in RON — total invoiced/received during the year.
3. **Deductible expenses (cheltuieli deductibile)** in RON — professional expenses that reduce the taxable base. If the user has no expenses, use 0.
4. **Minimum monthly gross wage (salariul minim brut pe economie)** — already looked up and confirmed in Step 0 for years other than 2025. For 2025, look this up on the Internet (1 January 2025 value) and **present the value found and ask the user to confirm** before proceeding.

> Known reference values (verify online before using):
> - 2025: **4 050 RON/month**
> - 2024: **3 300 RON/month**

Do **not** assume a wage value without confirmation from the user.

---

## Step 2 — Derived base values

Once inputs are confirmed, compute:

```
Venit net = Venit brut - Cheltuieli deductibile
Salariu minim anual = Salariu minim lunar × 12
```

Define the **annual thresholds** used by the three taxes:

| Threshold name | Formula                        | Used by                          |
|----------------|---------------------------------|-----------------------------------|
| P6             | 6  × salariu minim lunar        | CASS (both models)                |
| P12            | 12 × salariu minim lunar        | CAS, CASS Model T                 |
| P24            | 24 × salariu minim lunar        | CAS, CASS Model T                 |
| P60            | 60 × salariu minim lunar        | CASS Model P only (see Step 3b)   |

> Only compute P60 if Step 0 determined the year uses CASS Model P (proportional).

---

## Step 3 — Compute each tax

> **Computation order matters:** compute CAS first (3a), then CASS (3b), then Impozit pe venit last (3c) — because the income tax base requires the CAS value.

### 3a. CAS (Contribuția de Asigurări Sociale — Pensie)
**Rate:** 25%, applied to a capped base determined by net income vs. annual thresholds.

| Condition                       | Baza de calcul CAS | Formula                  |
|---------------------------------|--------------------|--------------------------|
| Venit net < P12                 | 0                  | CAS = 0                  |
| P12 ≤ Venit net < P24           | P12                | CAS = 25% × P12          |
| Venit net ≥ P24                 | P24                | CAS = 25% × P24          |

Where:
- P12 = 12 × salariu minim lunar
- P24 = 24 × salariu minim lunar

---

### 3b. CASS (Contribuția de Asigurări Sociale de Sănătate — Sănătate)
**Rate:** 10%. Use the model selected in Step 0 for the fiscal year.

#### Model T — Tiered (use for fiscal year 2025; verify for years ≤ 2023)
Applied to a capped base determined by net income vs. annual thresholds.

| Condition                       | Baza de calcul CASS | Formula                  |
|---------------------------------|---------------------|--------------------------|
| Venit net < P6                  | 0                   | CASS = 0                 |
| P6 ≤ Venit net < P12            | P6                  | CASS = 10% × P6          |
| P12 ≤ Venit net < P24           | P12                 | CASS = 10% × P12         |
| Venit net ≥ P24                 | P24                 | CASS = 10% × P24         |

Where:
- P6  = 6  × salariu minim lunar
- P12 = 12 × salariu minim lunar
- P24 = 24 × salariu minim lunar

---

#### Model P — Proportional (use for fiscal year 2024; verify for years ≥ 2026)
Applied directly to net income, with a floor and a cap (no fixed-tier base in the middle range).

| Condition                       | CASS                            |
|---------------------------------|----------------------------------|
| Venit net < P6                  | CASS = 10% × P6  *(minimum due — not zero)* |
| P6 ≤ Venit net ≤ P60            | CASS = 10% × Venit net  *(proportional to actual net income)* |
| Venit net > P60                 | CASS = 10% × P60  *(capped)*    |

Where:
- P6  = 6  × salariu minim lunar
- P60 = 60 × salariu minim lunar

> **Key difference from Model T:** under Model P, CASS is never zero once the person has any income from independent activities (PFA) — there is a minimum due of 10% × P6 even below the floor. Possible exemptions (e.g. a fully inactive PFA with zero declared activity) exist in the underlying legislation but are not modeled here — flag this to the user rather than assuming an exemption applies.

---

### 3c. Impozit pe venit *(compute last — requires CAS from 3a)*
**Rate:** 10% applied on venit net **minus CAS**.

```
Baza impozit pe venit = Venit net - CAS
Impozit pe venit      = 10% × (Venit net - CAS)
```

> There are no income brackets — the rate is always 10% regardless of income level.

---

## Step 4 — Net take-home

```
Total taxe = Impozit pe venit + CAS + CASS
Venit rămas (take-home) = Venit net - Total taxe
```

> Note: "Venit net" here already excludes deductible expenses.
> Take-home = what the PFA actually keeps after paying all fiscal obligations.

---

## Step 5 — Present results

Use the following structured output format:

---

### 📊 Calcul fiscal PFA — [Year]

**Date de intrare**
| Parametru                        | Valoare        |
|----------------------------------|----------------|
| Venit brut                       | X RON          |
| Cheltuieli deductibile           | X RON          |
| **Venit net**                    | **X RON**      |
| Salariu minim lunar (confirmat)  | X RON          |

**Praguri anuale**
| Prag | Calcul         | Valoare   |
|------|----------------|-----------|
| P6   | 6 × X RON      | X RON     |
| P12  | 12 × X RON     | X RON     |
| P24  | 24 × X RON     | X RON     |
| P60  | 60 × X RON     | X RON     |  *(only if CASS Model P applies)*

**CAS** *(3a — compute first)*
- Venit net față de praguri: [bracket description, e.g. "≥ P12 și < P24"]
- Baza de calcul: P12 = X RON
- Formulă: 25% × X RON
- **= X RON**

**CASS** *(3b — model used: [Tiered / Proporțional], per Step 0)*
- *If Model T:* Venit net față de praguri: [bracket description] · Baza de calcul: P12 = X RON *(or P6 / P24)* · Formulă: 10% × X RON
- *If Model P:* Venit net față de P6/P60: [below floor / proportional / capped] · Formulă: 10% × [P6 / Venit net / P60]
- **= X RON**

**Impozit pe venit** *(3c — compute last)*
- Baza: Venit net − CAS = X RON − X RON = X RON
- Formulă: 10% × X RON
- **= X RON**

**Sumar — Impozitare PFA în sistem real**
| Parametru                | Valoare   |
|--------------------------|-----------|
| Venit brut               | X RON     |
| Cheltuieli deductibile   | X RON     |
| Venit net                | X RON     |
| CAS                      | X RON     |
| CASS                     | X RON     |
| Impozit pe venit         | X RON     |
| **Total taxe**           | **X RON** |
| **Venit rămas**          | **X RON** |

---

## Edge cases & notes

- **Cheltuieli > Venit brut:** Venit net becomes 0 or negative. Under Model T (tiered) all three taxes become 0 in that case. Under Model P (proportional), CASS may still be due at the minimum floor (10% × P6) even when Venit net is 0 — flag this explicitly to the user rather than assuming CASS = 0.
- **Exact threshold boundaries:** P6, P12, P24, P60 are **inclusive lower bounds** (≥), as specified in the tax rules.
- **Which CASS model applies:** always confirmed in Step 0 before computing — never assume Model T or Model P without checking the year against the table in Step 0.
- **Rounding:** All final tax values are rounded to the **nearest integer (RON, no decimals)**. Intermediate calculations keep full precision; round only the final CAS, CASS, Impozit pe venit, Total taxe, and Venit rămas values.
- **Currency:** All amounts in RON. If the user provides EUR or other currency, ask them to convert first.
- **This skill computes taxes for a single fiscal year.** For multi-year scenarios, run the skill once per year.
- **Disclaimer:** Always end with: *"Acest calcul are scop informativ. Pentru depunerea Declarației Unice și plata efectivă, consultați un contabil sau ANAF."*

---

## Example calculation A — 2025, CASS Model T (tiered, reference only)

**Inputs:** Venit brut = 120 000 RON, Cheltuieli = 20 000 RON, Salariu minim = 4 050 RON

**Derived:**
- Venit net = 100 000 RON
- P6  = 24 300 RON
- P12 = 48 600 RON
- P24 = 97 200 RON

**CAS** *(first)*: Venit net (100 000) ≥ P24 (97 200) → baza = P24 → 25% × 97 200 = **24 300 RON**

**CASS (Model T):** Venit net (100 000) ≥ P24 (97 200) → baza = P24 → 10% × 97 200 = **9 720 RON**

**Impozit pe venit:** 10% × (Venit net − CAS) = 10% × (100 000 − 24 300) = 10% × 75 700 = **7 570 RON**

**Total taxe:** 7 570 + 24 300 + 9 720 = **41 590 RON**

**Venit rămas:** 100 000 − 41 590 = **58 410 RON**

---

## Example calculation B — 2024, CASS Model P (proportional, reference only)

**Inputs:** Venit brut = 120 000 RON, Cheltuieli = 20 000 RON, Salariu minim = 3 300 RON (2024 value)

**Derived:**
- Venit net = 100 000 RON
- P6  = 19 800 RON
- P12 = 39 600 RON
- P24 = 79 200 RON
- P60 = 198 000 RON

**CAS** *(first, tiered — unchanged by the CASS model)*: Venit net (100 000) ≥ P24 (79 200) → baza = P24 → 25% × 79 200 = **19 800 RON**

**CASS (Model P):** P6 (19 800) ≤ Venit net (100 000) ≤ P60 (198 000) → proportional → 10% × 100 000 = **10 000 RON**

**Impozit pe venit:** 10% × (Venit net − CAS) = 10% × (100 000 − 19 800) = 10% × 80 200 = **8 020 RON**

**Total taxe:** 19 800 + 10 000 + 8 020 = **37 820 RON**

**Venit rămas:** 100 000 − 37 820 = **62 180 RON**
