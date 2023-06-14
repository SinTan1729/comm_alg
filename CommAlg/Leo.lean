import Mathlib.RingTheory.Ideal.Operations
import Mathlib.RingTheory.FiniteType
import Mathlib.Order.Height
import Mathlib.RingTheory.PrincipalIdealDomain
import Mathlib.RingTheory.DedekindDomain.Basic
import Mathlib.RingTheory.Ideal.Quotient
import Mathlib.RingTheory.Localization.AtPrime
import Mathlib.AlgebraicGeometry.PrimeSpectrum.Basic
import Mathlib.Order.ConditionallyCompleteLattice.Basic
import CommAlg.krull

--trying and failing to prove ht p = dim R_p
section Localization

variable {R : Type _} [CommRing R] (I : PrimeSpectrum R)
variable {S : Type _} [CommRing S] [Algebra R S] [IsLocalization.AtPrime S I.asIdeal]

open Ideal
open LocalRing
open PrimeSpectrum

#check algebraMap R (Localization.AtPrime I.asIdeal)
#check PrimeSpectrum.comap (algebraMap R (Localization.AtPrime I.asIdeal))

#check krullDim
#check dim_eq_bot_iff
#check height_le_krullDim

variable (J₁ J₂ : PrimeSpectrum (Localization.AtPrime I.asIdeal))
example (h : J₁ ≤ J₂) : PrimeSpectrum.comap (algebraMap R (Localization.AtPrime I.asIdeal)) J₁ ≤
  PrimeSpectrum.comap (algebraMap R (Localization.AtPrime I.asIdeal)) J₂ := by
  intro x hx
  exact h hx

def gadslfasd' : Ideal S := (IsLocalization.AtPrime.localRing S I.asIdeal).maximalIdeal

-- instance gadslfasd : LocalRing S := IsLocalization.AtPrime.localRing S I.asIdeal

example (f : α → β) (hf : Function.Injective f) (h : a₁ ≠ a₂) : f a₁ ≠ f a₂ := by library_search

instance map_prime (J : PrimeSpectrum R) (hJ : J ≤ I) :
  (Ideal.map (algebraMap R S) J.asIdeal : Ideal S).IsPrime where
    ne_top' := by
      intro h
      rw [eq_top_iff_one, map, mem_span] at h
    mem_or_mem' := sorry

lemma comap_lt_of_lt (J₁ J₂ : PrimeSpectrum S) (J_lt : J₁ < J₂) : 
  PrimeSpectrum.comap (algebraMap R S) J₁ < PrimeSpectrum.comap (algebraMap R S) J₂ := by
  apply lt_of_le_of_ne
  apply comap_mono (le_of_lt J_lt)
  sorry

lemma lt_of_comap_lt (J₁ J₂ : PrimeSpectrum S)
(hJ : PrimeSpectrum.comap (algebraMap R S) J₁ < PrimeSpectrum.comap (algebraMap R S) J₂) :
J₁ < J₂ := by
  apply lt_of_le_of_ne
  sorry

/- If S = R_p, then height p = dim S -/
lemma height_eq_height_comap (J : PrimeSpectrum S) :
  height (PrimeSpectrum.comap (algebraMap R S) J) = height J := by
  simp [height]
  have H : {J_1 | J_1 < (PrimeSpectrum.comap (algebraMap R S)) J} = 
    (PrimeSpectrum.comap (algebraMap R S))'' {J_2 | J_2 < J}
  . sorry
  rw [H]
  apply Set.chainHeight_image
  intro x y
  constructor
  apply comap_lt_of_lt
  apply lt_of_comap_lt
  
lemma disjoint_primeCompl (I : PrimeSpectrum R) :
  { p | Disjoint (I.asIdeal.primeCompl : Set R) p.asIdeal} = {p | p ≤ I} := by
  ext p; apply Set.disjoint_compl_left_iff_subset

theorem localizationPrime_comap_range [Algebra R S] (I : PrimeSpectrum R) [IsLocalization.AtPrime S I.asIdeal] :
    Set.range (PrimeSpectrum.comap (algebraMap R S)) = { p | p ≤ I} := by
    rw [← disjoint_primeCompl]
    apply localization_comap_range


#check Set.chainHeight_image

lemma height_eq_dim_localization : height I = krullDim S := by
  --first show height I = height gadslfasd'
  simp [@krullDim_eq_height _ _ (IsLocalization.AtPrime.localRing S I.asIdeal)]
  simp [height]
  let f := (PrimeSpectrum.comap (algebraMap R S))
  have H : {J | J < I} = f '' {J | J < closedPoint S}
  
lemma height_eq_dim_localization' :
  height I = krullDim (Localization.AtPrime I.asIdeal) := Ideal.height_eq_dim_localization I

end Localization




section Polynomial

open Ideal Polynomial
variables {R : Type _} [CommRing R]

--given ideals I J, I ⊔ J is their sum
--given a in R, span {a} is the ideal generated by a
--the map R → R[X] is C →+*
--to show p[x] is prime, show p[x] is the kernel of the map R[x] → R → R/p
#check RingHom.ker_isPrime

def adj_x_map (I : Ideal R) : R[X] →+* R ⧸ I := (Ideal.Quotient.mk I).comp (evalRingHom 0)
def adjoin_x (I : Ideal R) : Ideal (Polynomial R) := RingHom.ker (adj_x_map I)
def adjoin_x' (I : PrimeSpectrum R) : PrimeSpectrum (Polynomial R) where
  asIdeal := adjoin_x I.asIdeal
  IsPrime := RingHom.ker_isPrime _

@[simp]
lemma adj_x_comp_C (I : Ideal R) : RingHom.comp (adj_x_map I) C = Ideal.Quotient.mk I := by
  ext x; simp [adj_x_map]

lemma adjoin_x_eq (I : Ideal R) : adjoin_x I = I.map C ⊔ Ideal.span {X} := by
  apply le_antisymm
  . sorry
  . rw [sup_le_iff]
    constructor
    . simp [adjoin_x, RingHom.ker, ←map_le_iff_le_comap, Ideal.map_map]
    . simp [span_le, adjoin_x, RingHom.mem_ker, adj_x_map]

lemma adjoin_x_strictmono (I J : Ideal R) (h : I < J) : adjoin_x I < adjoin_x J := by
  rw [lt_iff_le_and_ne] at h ⊢
  rw [adjoin_x_eq, adjoin_x_eq]
  constructor
  . apply sup_le_sup_right
    apply map_mono h.1
  . intro H
    have H' : Ideal.comap C (Ideal.map C I ⊔ span {X}) = Ideal.comap C (Ideal.map C J ⊔ span {X})
    . rw [H]
    sorry


/- Given an ideal p in R, define the ideal p[x] in R[x] -/
lemma ht_adjoin_x_eq_ht_add_one (I : PrimeSpectrum R) : height I + 1 ≤ height (adjoin_x' I) := by
  have H : ∀ l ∈ {J : PrimeSpectrum R | J < I}.subchain, ∃

lemma ne_bot_iff_exists (n : WithBot ℕ∞) : n ≠ ⊥ ↔ ∃ m : ℕ∞, n = m := by
  cases' n with n;
  simp
  intro x hx
  cases hx
  simp
  use n
  rfl

lemma ne_bot_iff_exists' (n : WithBot ℕ∞) : n ≠ ⊥ ↔ ∃ m : ℕ∞, n = m := by
  convert WithBot.ne_bot_iff_exists using 3
  exact comm


lemma dim_le_dim_polynomial_add_one [Nontrivial R] :
  krullDim R + (1 : ℕ∞) ≤ krullDim (Polynomial R) := by
  cases' krullDim_nonneg_of_nontrivial R with n hn
  rw [hn]
  change ↑(n + 1) ≤ krullDim R[X]
  have hn' := le_of_eq hn.symm
  rw [le_krullDim_iff'] at hn' ⊢
  cases' hn' with I hI
  use adjoin_x' I
  apply WithBot.coe_mono
  calc n + 1 ≤ height I + 1 := by
        apply add_le_add_right
        rw [WithBot.coe_le_coe] at hI
        exact hI
    _ ≤ height (adjoin_x' I) := ht_adjoin_x_eq_ht_add_one I
  

end Polynomial

open Ideal

variable {R : Type _} [CommRing R]

lemma height_le_top_iff_exists {I : PrimeSpectrum R} (hI : height I ≤ ⊤) :
  ∃ n : ℕ, true := by
  sorry

lemma eq_of_height_eq_of_le {I J : PrimeSpectrum R} (I_le_J : I ≤ J) (hJ : height J < ⊤)
  (ht_eq : height I = height J) : I = J := by
  by_cases h : I = J
  . exact h
  . have I_lt_J := lt_of_le_of_ne I_le_J h
    exfalso
    sorry

section Quotient

variables {R : Type _} [CommRing R] (I : Ideal R)

#check List.map <| PrimeSpectrum.comap <| Ideal.Quotient.mk I

lemma comap_chain {l : List (PrimeSpectrum (R ⧸ I))} (hl : l.Chain' (· < ·)) :
  List.Chain' (. < .) ((List.map <| PrimeSpectrum.comap <| Ideal.Quotient.mk I) l) := by


lemma dim_quotient_le_dim : krullDim (R ⧸ I) ≤ krullDim R := by

end Quotient