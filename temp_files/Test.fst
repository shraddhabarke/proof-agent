module Test

open FStar.List.Tot
open FStar.Mul // for the + operator on nat (though often not strictly necessary)

// Define our own append function, though FStar.List.Tot.append exists.
let rec append #a (l1: list a) (l2: list a) : Tot (list a) =
  match l1 with
  | [] -> l2
  | x :: xs -> x :: append xs l2

// Define a length function, though FStar.List.Tot.length exists.
let rec length #a (l: list a) : Tot nat =
  match l with
  | [] -> 0
  | _ :: xs -> 1 + length xs

// Lemma: length (append l1 l2) = length l1 + length l2
// We prove it by structural induction on l1.
let rec lemma_append_length #a (l1: list a) (l2: list a)
  : Lemma (requires True)
          (ensures (length (append l1 l2) == length l1 + length l2))
  = match l1 with
    | [] -> ()  // Base case: append [] l2 = l2, so length is length l2.
    | _ :: xs -> // Inductive step: assume property holds for xs, prove it for x::xs.
      lemma_append_length #a xs l2
      // No extra steps are required; F*'s simplification resolves the final equality.